import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../expenses/add_expense_screen.dart';
import '../employee/all_expense_list.dart';
import '../payments/employee/employee_payments_screen.dart';
import '../notifications/ui/notification_list_screen.dart';
import '../notifications/services/notification_service.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  final String companyId;
  final String userId;

  const EmployeeDashboardScreen({
    super.key,
    required this.companyId,
    required this.userId,
  });

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  final NotificationService notificationService = NotificationService();

  int _lastUnreadCount = 0; // ⭐ IMPORTANT FIX

  @override
  Widget build(BuildContext context) {
    final expensesQuery = FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyId)
        .collection('expenses')
        .where('createdBy', isEqualTo: widget.userId);

    final paymentsQuery = FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyId)
        .collection('payments')
        .where('userId', isEqualTo: widget.userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        actions: [
          /// 🔔 NOTIFICATION ICON (FIXED – WILL NEVER DISAPPEAR)
          StreamBuilder<int>(
            stream: notificationService.employeeUnreadCount(
              companyId: widget.companyId,
              userId: widget.userId,
            ),
            initialData: _lastUnreadCount,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _lastUnreadCount = snapshot.data!;
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationListScreen(
                            companyId: widget.companyId,
                            userId: widget.userId,
                            isAdmin: false,
                          ),
                        ),
                      );
                    },
                  ),
                  if (_lastUnreadCount > 0)
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
                          _lastUnreadCount.toString(),
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
              stream: expensesQuery.snapshots(),
              builder: (context, snapshot) {
                int pending = 0;
                int approved = 0;
                int rejected = 0;
                double total = 0;

                if (snapshot.hasData) {
                  for (final doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'];
                    final amount = (data['amount'] ?? 0).toDouble();

                    if (status == 'pending') pending++;
                    if (status == 'approved') {
                      approved++;
                      total += amount;
                    }
                    if (status == 'rejected') rejected++;
                  }
                }

                return Column(
                  children: [
                    _card('Pending', pending, Colors.orange),
                    _card('Approved', approved, Colors.green),
                    _card('Rejected', rejected, Colors.red),
                    _card('Total ₹', total.toInt(), Colors.blue),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            /// ================= PAYMENT SUMMARY =================
            StreamBuilder<QuerySnapshot>(
              stream: paymentsQuery.snapshots(),
              builder: (context, snapshot) {
                double pending = 0;
                double paid = 0;

                if (snapshot.hasData) {
                  for (final doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final amount = (data['amount'] ?? 0).toDouble();
                    final status = data['status'];

                    if (status == 'pending') pending += amount;
                    if (status == 'paid') paid += amount;
                  }
                }

                return Column(
                  children: [
                    _card('Pending Payment ₹', pending.toInt(), Colors.orange),
                    _card('Paid Payment ₹', paid.toInt(), Colors.green),
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
                    builder: (_) => AddExpenseScreen(
                      companyId: widget.companyId,
                      userId: widget.userId,
                    ),
                  ),
                );
              },
              child: const Text('Add Expense'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllExpensesListScreen(
                      companyId: widget.companyId,
                      userId: widget.userId,
                    ),
                  ),
                );
              },
              child: const Text('All Expenses'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmployeePaymentsScreen(
                      companyId: widget.companyId,
                      userId: widget.userId,
                    ),
                  ),
                );
              },
              child: const Text('My Payments'),
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
