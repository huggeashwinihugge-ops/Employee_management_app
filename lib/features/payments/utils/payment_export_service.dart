import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/payment_model.dart';

class PaymentExportService {
  /// EXPORT PAYMENTS TO CSV
  Future<File> exportPaymentsToCSV(
    List<PaymentModel> payments,
  ) async {
    List<List<String>> rows = [
      [
        'Payment ID',
        'User ID',
        'Expense ID',
        'Amount',
        'Method',
        'Status',
        'Transaction ID',
        'Created At',
      ]
    ];

    for (final p in payments) {
      rows.add([
        p.paymentId,
        p.userId,
        p.expenseId,
        p.amount.toString(),
        p.paymentMethod,
        p.status,
        p.transactionId ?? '',
        p.createdAt.toDate().toString(),
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/payments_export.csv');

    return file.writeAsString(csvData);
  }
}
