import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payment_model.dart';
import '../utils/payment_constants.dart';
import '../../notifications/services/notification_service.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ==============================
  /// ADMIN → ALL PAYMENTS
  /// ==============================
  Stream<List<PaymentModel>> getCompanyPayments(String companyId) {
    return _firestore
        .collection('companies')
        .doc(companyId)
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PaymentModel.fromMap(doc.id, doc.data()),
              )
              .toList(),
        );
  }

  /// ==============================
  /// EMPLOYEE → OWN PAYMENTS (FIXED ❗)
  /// ==============================
  Stream<List<PaymentModel>> getEmployeePayments({
    required String companyId,
    required String userId,
  }) {
    return _firestore
        .collection('companies')
        .doc(companyId)
        .collection('payments')
        .where('userId', isEqualTo: userId)
        // ❌ removed orderBy to avoid Firestore index / flicker issue
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PaymentModel.fromMap(doc.id, doc.data()),
              )
              .toList(),
        );
  }

  /// ==============================
  /// CHECK → PAYMENT EXISTS FOR EXPENSE
  /// ==============================
  Future<bool> paymentExistsForExpense({
    required String companyId,
    required String expenseId,
  }) async {
    final query = await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('payments')
        .where('expenseId', isEqualTo: expenseId)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  /// ==============================
  /// CREATE PAYMENT (ADMIN)
  /// ==============================
  Future<void> createPayment({
    required String companyId,
    required String userId,
    required String expenseId,
    required double amount,
    required String paymentMethod,
  }) async {
    await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('payments')
        .add({
      'companyId': companyId,
      'userId': userId,
      'expenseId': expenseId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': PaymentConstants.pending,
      'transactionId': null,
      'remarks': '',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  /// ==============================
  /// UPDATE PAYMENT STATUS + 🔔 AUTO NOTIFICATION
  /// ==============================
  Future<void> updatePaymentStatus({
    required String companyId,
    required String paymentId,
    required String userId,
    required double amount,
    required String status,
    String? transactionId,
    String? paymentMethod,
  }) async {
    final DocumentReference paymentRef = _firestore
        .collection('companies')
        .doc(companyId)
        .collection('payments')
        .doc(paymentId);

    /// 🔄 UPDATE PAYMENT
    await paymentRef.update({
      'status': status,
      if (transactionId != null) 'transactionId': transactionId,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      'updatedAt': Timestamp.now(),
    });

    /// 🔔 AUTO NOTIFICATION TO EMPLOYEE
    final NotificationService notificationService = NotificationService();

    await notificationService.createNotification(
      companyId: companyId,
      userId: userId,
      isAdmin: false,
      title: status == PaymentConstants.paid
          ? 'Payment Received'
          : 'Payment Failed',
      message: status == PaymentConstants.paid
          ? 'Your payment of ₹$amount has been marked as PAID.'
          : 'Your payment of ₹$amount has FAILED.',
    );
  }
}
