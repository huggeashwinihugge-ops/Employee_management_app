import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ==============================
  /// CREATE NOTIFICATION
  /// ==============================
  Future<void> createNotification({
    required String companyId,
    required String title,
    required String message,
    String? userId,
    required bool isAdmin,
  }) async {
    await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('notifications')
        .add({
      'companyId': companyId,
      'userId': userId,
      'isAdmin': isAdmin,
      'title': title,
      'message': message,
      'read': false,
      'createdAt': Timestamp.now(),
    });
  }

  /// ==============================
  /// EMPLOYEE NOTIFICATIONS
  /// ==============================
  Stream<List<AppNotification>> getEmployeeNotifications({
    required String companyId,
    required String userId,
  }) {
    return _firestore
        .collection('companies')
        .doc(companyId)
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// ==============================
  /// ADMIN NOTIFICATIONS
  /// ==============================
  Stream<List<AppNotification>> getAdminNotifications({
    required String companyId,
  }) {
    return _firestore
        .collection('companies')
        .doc(companyId)
        .collection('notifications')
        .where('isAdmin', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// ==============================
  /// UNREAD COUNTS
  /// ==============================
  Stream<int> employeeUnreadCount({
    required String companyId,
    required String userId,
  }) {
    return _firestore
        .collection('companies')
        .doc(companyId)
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<int> adminUnreadCount({
    required String companyId,
  }) {
    return _firestore
        .collection('companies')
        .doc(companyId)
        .collection('notifications')
        .where('isAdmin', isEqualTo: true)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// ==============================
  /// MARK SINGLE AS READ (KEPT)
  /// ==============================
  Future<void> markAsRead({
    required String companyId,
    required String notificationId,
  }) async {
    await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  /// ==============================
  /// MARK ALL EMPLOYEE AS READ (NEW)
  /// ==============================
  Future<void> markAllEmployeeNotificationsAsRead({
    required String companyId,
    required String userId,
  }) async {
    final snapshot = await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'read': true});
    }
  }

  /// ==============================
  /// MARK ALL ADMIN AS READ (NEW)
  /// ==============================
  Future<void> markAllAdminNotificationsAsRead({
    required String companyId,
  }) async {
    final snapshot = await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('notifications')
        .where('isAdmin', isEqualTo: true)
        .where('read', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'read': true});
    }
  }
}
