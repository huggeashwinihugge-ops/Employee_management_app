import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/payment_constants.dart';

class PaymentModel {
  final String paymentId;
  final String companyId;
  final String userId;
  final String expenseId;
  final double amount;
  final String paymentMethod; // upi / bank / cash
  final String status; // pending / paid / failed
  final String? transactionId;
  final String? remarks;
  final Timestamp createdAt;

  PaymentModel({
    required this.paymentId,
    required this.companyId,
    required this.userId,
    required this.expenseId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.remarks,
    required this.createdAt,
  });

  factory PaymentModel.fromMap(
    String docId,
    Map<String, dynamic> map,
  ) {
    return PaymentModel(
      paymentId: docId,
      companyId: map['companyId'] ?? '',
      userId: map['userId'] ?? '',
      expenseId: map['expenseId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),

      /// ✅ FIXED DEFAULT
      paymentMethod: map['paymentMethod'] ?? PaymentConstants.upi,

      /// ✅ SAFE DEFAULT
      status: map['status'] ?? PaymentConstants.pending,

      transactionId: map['transactionId'],
      remarks: map['remarks'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
