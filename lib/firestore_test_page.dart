import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreTestPage extends StatelessWidget {
  const FirestoreTestPage({super.key});

  Future<void> addData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('❌ User not logged in');
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .add({
      'title': 'book',
      'amount': 20,
      'category': 'Stationery',
      'createdAt': Timestamp.now(),
    });

    debugPrint('✅ Expense added successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Test'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: addData,
          child: const Text('Add Data to Firestore'),
        ),
      ),
    );
  }
}
