import 'package:flutter/material.dart';

import 'package:rms_expense_app/features/payments/models/payment_model.dart';
import 'package:rms_expense_app/features/payments/services/payment_service.dart';
import 'package:rms_expense_app/features/payments/utils/payment_constants.dart';
import 'package:rms_expense_app/features/payments/admin/admin_payments_details_screen.dart';
import 'package:rms_expense_app/features/payments/utils/payment_pdf_service.dart';
import 'package:rms_expense_app/features/payments/utils/payment_csv_service.dart';

class AdminPaymentsScreen extends StatelessWidget {
  final String companyId;

  const AdminPaymentsScreen({
    super.key,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final PaymentService paymentService = PaymentService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),

        /// ⬇️ EXPORT BUTTONS (PDF + CSV)
        actions: [
          StreamBuilder<List<PaymentModel>>(
            stream: paymentService.getCompanyPayments(companyId),
            builder: (context, snapshot) {
              final payments = snapshot.data ?? [];

              if (payments.isEmpty) {
                return const SizedBox.shrink();
              }

              return Row(
                children: [
                  /// 📄 PDF EXPORT
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Export PDF',
                    onPressed: () async {
                      await PaymentPdfService.exportPaymentsPdf(
                        payments: payments,
                        fileName: 'company_payments',
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('PDF exported successfully'),
                        ),
                      );
                    },
                  ),

                  /// 📊 CSV EXPORT
                  IconButton(
                    icon: const Icon(Icons.table_chart),
                    tooltip: 'Export CSV',
                    onPressed: () async {
                      await PaymentCsvService.exportPaymentsCsv(
                        payments: payments,
                        fileName: 'company_payments',
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('CSV exported successfully'),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),

      /// ================= PAYMENT LIST =================
      body: StreamBuilder<List<PaymentModel>>(
        stream: paymentService.getCompanyPayments(companyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No payments found'));
          }

          final payments = snapshot.data!;

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final p = payments[index];

              final Color statusColor = p.status == PaymentConstants.paid
                  ? Colors.green
                  : p.status == PaymentConstants.failed
                      ? Colors.red
                      : Colors.orange;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('₹ ${p.amount}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Method: ${p.paymentMethod.toUpperCase()}',
                      ),
                      if (p.transactionId != null &&
                          p.transactionId!.isNotEmpty)
                        Text('Txn ID: ${p.transactionId}'),
                    ],
                  ),
                  trailing: Text(
                    p.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  /// 👉 OPEN PAYMENT DETAILS
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminPaymentsDetailsScreen(
                          companyId: companyId,
                          paymentId: p.paymentId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
