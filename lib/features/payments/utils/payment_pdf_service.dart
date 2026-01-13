import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../models/payment_model.dart';

class PaymentPdfService {
  static Future<void> exportPaymentsPdf({
    required List<PaymentModel> payments,
    required String fileName,
    String? companyName,
    String? companyId,
    String? userId,
  }) async {
    final pdf = pw.Document();

    final String generatedOn =
        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          /// ===== HEADER =====
          pw.Text(
            'Payments Report',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 8),

          if (companyName != null) pw.Text('Company Name: $companyName'),
          if (companyId != null) pw.Text('Company ID: $companyId'),
          if (userId != null) pw.Text('User ID: $userId'),

          pw.Text('Generated On: $generatedOn'),

          pw.SizedBox(height: 16),

          /// ===== TABLE =====
          pw.Table.fromTextArray(
            headers: const [
              'Amount',
              'Method',
              'Status',
              'Transaction ID',
              'Expense ID',
              'User ID',
            ],
            data: payments.map((p) {
              return [
                '₹ ${p.amount}',
                p.paymentMethod.toUpperCase(),
                p.status.toUpperCase(),
                p.transactionId ?? '-',
                p.expenseId,
                p.userId,
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pdf');
    await file.writeAsBytes(await pdf.save());

    await OpenFilex.open(file.path);
  }
}
