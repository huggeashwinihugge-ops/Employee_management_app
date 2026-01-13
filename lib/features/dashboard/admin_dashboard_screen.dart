import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../admin/admin_employee_list_screen.dart';
import '../expenses/admin_expense_list_screen.dart';
import '../employee/create_employee_screen.dart';
import '../payments/admin/admin_payments_screen.dart';

import '../notifications/ui/notification_list_screen.dart';
import '../notifications/services/notification_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String companyId;

  const AdminDashboardScreen({
    super.key,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final expensesRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('expenses');

    final paymentsRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('payments');

    final NotificationService notificationService = NotificationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          /// 🔔 ADMIN NOTIFICATION BADGE
          StreamBuilder<int>(
            stream: notificationService.adminUnreadCount(
              companyId: companyId,
            ),
            builder: (context, snapshot) {
              final int count = snapshot.data ?? 0;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationListScreen(
                            companyId: companyId,
                            userId: '', // admin doesn't need userId
                            isAdmin: true,
                          ),
                        ),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          /// 🚪 LOGOUT
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ================= EXPENSE SUMMARY =================
            StreamBuilder<QuerySnapshot>(
              stream: expensesRef.snapshots(),
              builder: (context, snapshot) {
                int pending = 0;
                int approved = 0;
                int rejected = 0;

                if (snapshot.hasData) {
                  for (final doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'];

                    if (status == 'pending') pending++;
                    if (status == 'approved') approved++;
                    if (status == 'rejected') rejected++;
                  }
                }

                return Column(
                  children: [
                    _card('Pending Expenses', pending, Colors.orange),
                    _card('Approved Expenses', approved, Colors.green),
                    _card('Rejected Expenses', rejected, Colors.red),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            /// ================= PAYMENT SUMMARY =================
            StreamBuilder<QuerySnapshot>(
              stream: paymentsRef.snapshots(),
              builder: (context, snapshot) {
                double pendingAmount = 0;
                double paidAmount = 0;

                if (snapshot.hasData) {
                  for (final doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final amount = (data['amount'] ?? 0).toDouble();
                    final status = data['status'];

                    if (status == 'pending') pendingAmount += amount;
                    if (status == 'paid') paidAmount += amount;
                  }
                }

                return Column(
                  children: [
                    _card(
                      'Pending Payments ₹',
                      pendingAmount.toInt(),
                      Colors.orange,
                    ),
                    _card(
                      'Paid Payments ₹',
                      paidAmount.toInt(),
                      Colors.green,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            /// ================= ACTION BUTTONS =================
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateEmployeeScreen(companyId: companyId),
                  ),
                );
              },
              child: const Text('Create Employee'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AdminEmployeeListScreen(companyId: companyId),
                  ),
                );
              },
              child: const Text('View Employees'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AdminExpenseListScreen(companyId: companyId),
                  ),
                );
              },
              child: const Text('Approve Expenses'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminPaymentsScreen(companyId: companyId),
                  ),
                );
              },
              child: const Text('Payments'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, int value, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
