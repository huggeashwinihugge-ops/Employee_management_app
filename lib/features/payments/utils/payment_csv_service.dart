import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../models/payment_model.dart';

class PaymentCsvService {
  static Future<void> exportPaymentsCsv({
    required List<PaymentModel> payments,
    required String fileName,
    String? companyName,
    String? companyId,
  }) async {
    final List<List<String>> rows = [];

    final String generatedOn =
        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    /// ===== META INFO =====
    rows.add(['Payments Report']);
    rows.add(['Company Name', companyName ?? '-']);
    rows.add(['Company ID', companyId ?? '-']);
    rows.add(['Generated On', generatedOn]);
    rows.add([]);

    /// ===== HEADER =====
    rows.add([
      'Amount',
      'Payment Method',
      'Status',
      'Transaction ID',
      'User ID',
      'Expense ID',
    ]);

    /// ===== DATA =====
    for (final p in payments) {
      rows.add([
        p.amount.toString(),
        p.paymentMethod.toUpperCase(),
        p.status.toUpperCase(),
        p.transactionId ?? '-',
        p.userId,
        p.expenseId,
      ]);
    }

    final String csvData = const ListToCsvConverter().convert(rows);

    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/$fileName.csv');

    await file.writeAsString(csvData);

    await OpenFilex.open(file.path);
  }
}
