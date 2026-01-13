import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// 🔔 BACKGROUND HANDLER (TOP LEVEL FUNCTION)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This runs when app is terminated or background
  debugPrint('🔔 Background message: ${message.notification?.title}');
}

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ==============================
  /// INITIALIZE FCM
  /// ==============================
  Future<void> init({
    required String companyId,
    required String userId,
  }) async {
    // 🔐 Ask permission (Android 13+ / iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 📱 Get FCM token
    final String? token = await _messaging.getToken();

    if (token != null) {
      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('users')
          .doc(userId)
          .set(
        {
          'fcmToken': token,
          'updatedAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    }

    // 🔄 Handle token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('users')
          .doc(userId)
          .set(
        {
          'fcmToken': newToken,
          'updatedAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    });

    // 🟢 FOREGROUND NOTIFICATIONS
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 Foreground message received');

      if (message.notification != null) {
        debugPrint('Title: ${message.notification!.title}');
        debugPrint('Body: ${message.notification!.body}');
      }
    });

    // 🔵 WHEN USER OPENS APP BY TAPPING NOTIFICATION
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📲 Notification clicked');
    });
  }
}
