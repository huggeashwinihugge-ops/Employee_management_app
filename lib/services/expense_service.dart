import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getMyExpenses() {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('companies')
        .doc('RMS001')
        .collection('expenses')
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
