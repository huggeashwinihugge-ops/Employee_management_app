import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 LOGIN
  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return null;

    final docRef = _firestore.collection('users').doc(user.uid);
    final docSnap = await docRef.get();

    // 🔹 STEP 2 FIX: create user record if not exists
    if (!docSnap.exists) {
      await docRef.set({
        'email': user.email,
        'role': 'employee', // default
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return user;
  }

  // 🔹 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
