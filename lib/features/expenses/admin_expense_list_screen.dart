import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../notifications/services/notification_service.dart';
import '../payments/services/payment_service.dart';
import '../payments/utils/payment_constants.dart';

class AdminExpenseListScreen extends StatelessWidget {
  final String companyId;

  const AdminExpenseListScreen({
    super.key,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final expensesQuery = FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('expenses')
        .orderBy('createdAt', descending: true);

    final NotificationService notificationService = NotificationService();
    final PaymentService paymentService = PaymentService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approve Expenses'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: expensesQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No expenses found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String expenseId = doc.id;
              final String status = data['status'] ?? 'pending';
              final double amount = (data['amount'] ?? 0).toDouble();
              final String userId = data['createdBy'] ?? '';

              Color statusColor;
              if (status == 'approved') {
                statusColor = Colors.green;
              } else if (status == 'rejected') {
                statusColor = Colors.red;
              } else {
                statusColor = Colors.orange;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('₹ $amount'),
                  subtitle: Text(
                    'Status: ${status.toUpperCase()}',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: status == 'pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// ✅ APPROVE EXPENSE
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed: () async {
                                /// 1️⃣ UPDATE EXPENSE STATUS
                                await doc.reference
                                    .update({'status': 'approved'});

                                /// 2️⃣ CREATE PAYMENT (ONLY IF NOT EXISTS)
                                final exists = await paymentService
                                    .paymentExistsForExpense(
                                  companyId: companyId,
                                  expenseId: expenseId,
                                );

                                if (!exists) {
                                  await paymentService.createPayment(
                                    companyId: companyId,
                                    userId: userId,
                                    expenseId: expenseId,
                                    amount: amount,
                                    paymentMethod:
                                        PaymentConstants.cash, // default
                                  );
                                }

                                /// 3️⃣ EMPLOYEE NOTIFICATION
                                await notificationService.createNotification(
                                  companyId: companyId,
                                  userId: userId,
                                  isAdmin: false,
                                  title: 'Expense Approved',
                                  message:
                                      'Your expense of ₹$amount has been approved and sent for payment.',
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Expense approved & payment created',
                                    ),
                                  ),
                                );
                              },
                            ),

                            /// ❌ REJECT EXPENSE
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                await doc.reference
                                    .update({'status': 'rejected'});

                                await notificationService.createNotification(
                                  companyId: companyId,
                                  userId: userId,
                                  isAdmin: false,
                                  title: 'Expense Rejected',
                                  message:
                                      'Your expense of ₹$amount has been rejected.',
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Expense rejected successfully'),
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : const Icon(Icons.lock, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
