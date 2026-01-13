// TODO Implement this library.
import 'package:flutter/material.dart';

import 'package:rms_expense_app/features/payments/services/payment_service.dart';
import 'package:rms_expense_app/features/payments/utils/payment_constants.dart';

class AdminCreatePaymentScreen extends StatefulWidget {
  final String companyId;
  final String userId;
  final String expenseId;
  final double amount;

  const AdminCreatePaymentScreen({
    super.key,
    required this.companyId,
    required this.userId,
    required this.expenseId,
    required this.amount,
  });

  @override
  State<AdminCreatePaymentScreen> createState() =>
      _AdminCreatePaymentScreenState();
}

class _AdminCreatePaymentScreenState extends State<AdminCreatePaymentScreen> {
  final PaymentService paymentService = PaymentService();

  String selectedMethod = PaymentConstants.upi;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoTile('Amount', '₹ ${widget.amount}'),
            const SizedBox(height: 16),
            const Text(
              'Payment Method',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
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
                setState(() {
                  selectedMethod = value!;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);

                        await paymentService.createPayment(
                          companyId: widget.companyId,
                          userId: widget.userId,
                          expenseId: widget.expenseId,
                          amount: widget.amount,
                          paymentMethod: selectedMethod,
                        );

                        setState(() => isLoading = false);

                        Navigator.pop(context);
                      },
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Create Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
