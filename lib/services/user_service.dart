import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Used by RoleRouter
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Used by CreateEmployeeScreen
  Future<void> createEmployee({
    required String email,
    required String password,
    required String companyId,
  }) async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(cred.user!.uid).set({
      'email': email,
      'role': 'employee',
      'companyId': companyId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
