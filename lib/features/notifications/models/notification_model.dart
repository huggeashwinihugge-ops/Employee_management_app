import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String companyId;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool read;
  final Timestamp createdAt;

  AppNotification({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromMap(
    String docId,
    Map<String, dynamic> map,
  ) {
    return AppNotification(
      id: docId,
      companyId: map['companyId'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'system',
      read: map['read'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
