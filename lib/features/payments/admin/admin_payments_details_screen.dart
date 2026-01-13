import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../payments/services/payment_service.dart';
import '../../payments/utils/payment_constants.dart';
import '../../payments/models/payment_model.dart';

class AdminPaymentsDetailsScreen extends StatefulWidget {
  final String companyId;
  final String paymentId;

  const AdminPaymentsDetailsScreen({
    super.key,
    required this.companyId,
    required this.paymentId,
  });

  @override
  State<AdminPaymentsDetailsScreen> createState() =>
      _AdminPaymentsDetailsScreenState();
}

class _AdminPaymentsDetailsScreenState
    extends State<AdminPaymentsDetailsScreen> {
  final PaymentService paymentService = PaymentService();
  final TextEditingController _referenceController = TextEditingController();

  String selectedMethod = PaymentConstants.cash;
  bool _initialized = false; // 🔒 VERY IMPORTANT

  @override
  Widget build(BuildContext context) {
    final paymentDocStream = FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyId)
        .collection('payments')
        .doc(widget.paymentId)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: paymentDocStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final payment = PaymentModel.fromMap(
            snapshot.data!.id,
            data,
          );

          /// ✅ INITIALIZE STATE ONLY ONCE
          if (!_initialized) {
            selectedMethod = payment.paymentMethod.isNotEmpty
                ? payment.paymentMethod
                : PaymentConstants.cash;

            _referenceController.text = payment.transactionId ?? '';
            _initialized = true;
          }

          final bool isPending = payment.status == PaymentConstants.pending;

          final Color statusColor = payment.status == PaymentConstants.paid
              ? Colors.green
              : payment.status == PaymentConstants.failed
                  ? Colors.red
                  : Colors.orange;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoTile('Amount', '₹ ${payment.amount}'),

                _infoTile(
                  'Status',
                  payment.status.toUpperCase(),
                  color: statusColor,
                ),

                const SizedBox(height: 12),

                /// ================= PAYMENT METHOD =================
                const Text(
                  'Payment Method',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),

                if (isPending)
                  DropdownButtonFormField<String>(
                    initialValue: selectedMethod,
                    items: const [
                      DropdownMenuItem(
                        value: PaymentConstants.upi,
                        child: Text('UPI'),
                      ),
                      DropdownMenuItem(
                        value: PaymentConstants.bank,
                        child: Text('Bank Transfer'),
                      ),
                      DropdownMenuItem(
                        value: PaymentConstants.cash,
                        child: Text('Cash'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedMethod = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  )
                else
                  _infoTile(
                    '',
                    payment.paymentMethod.toUpperCase(),
                  ),

                const SizedBox(height: 16),

                /// ================= TRANSACTION ID =================
                if (selectedMethod != PaymentConstants.cash)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction ID / UTR',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      if (isPending)
                        TextField(
                          controller: _referenceController,
                          decoration: const InputDecoration(
                            hintText: 'Enter reference number',
                            border: OutlineInputBorder(),
                          ),
                        )
                      else
                        _infoTile(
                          '',
                          payment.transactionId ?? '-',
                        ),
                    ],
                  ),

                const SizedBox(height: 16),

                _infoTile('User ID', payment.userId),
                _infoTile('Expense ID', payment.expenseId),

                const SizedBox(height: 24),

                /// ================= ACTION BUTTONS =================
                if (isPending)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            if (selectedMethod != PaymentConstants.cash &&
                                _referenceController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Transaction ID / UTR is required'),
                                ),
                              );
                              return;
                            }

                            await paymentService.updatePaymentStatus(
                              companyId: widget.companyId,
                              paymentId: widget.paymentId,
                              userId: payment.userId,
                              amount: payment.amount,
                              status: PaymentConstants.paid,
                              transactionId: _referenceController.text.trim(),
                              paymentMethod: selectedMethod,
                            );

                            Navigator.pop(context);
                          },
                          child: const Text('Mark as PAID'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            await paymentService.updatePaymentStatus(
                              companyId: widget.companyId,
                              paymentId: widget.paymentId,
                              userId: payment.userId,
                              amount: payment.amount,
                              status: PaymentConstants.failed,
                            );

                            Navigator.pop(context);
                          },
                          child: const Text('Mark as FAILED'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
