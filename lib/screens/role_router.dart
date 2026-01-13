import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:rms_expense_app/features/dashboard/admin_dashboard_screen.dart';
import 'package:rms_expense_app/features/dashboard/employee_dashboard_screen.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login')),
      );
    }

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('companies').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        for (final company in snapshot.data!.docs) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('companies')
                .doc(company.id)
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, userSnap) {
              if (!userSnap.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (!userSnap.data!.exists) {
                return const Scaffold(
                  body: Center(child: Text('User record not found')),
                );
              }

              final data = userSnap.data!.data() as Map<String, dynamic>;
              final role = data['role'];
              final companyId = data['companyId'];

              if (role == 'admin') {
                return AdminDashboardScreen(companyId: companyId);
              }

              return EmployeeDashboardScreen(
                userId: user.uid,
                companyId: companyId,
              );
            },
          );
        }

        return const Scaffold(
          body: Center(child: Text('No company found')),
        );
      },
    );
  }
}
