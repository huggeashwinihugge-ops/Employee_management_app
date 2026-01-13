import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/payment_service.dart';
import '../utils/payment_constants.dart';

class AdminCreatePaymentScreen extends StatelessWidget {
  final String companyId;

  const AdminCreatePaymentScreen({
    super.key,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final paymentService = PaymentService();

    final approvedExpensesQuery = FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('expenses')
        .where('status', isEqualTo: 'approved');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Payments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: approvedExpensesQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No approved expenses available'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final expenseId = doc.id;
              final userId = data['createdBy'];
              final amount = (data['amount'] ?? 0).toDouble();
              final title = data['title'] ?? 'Expense';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text('₹ $amount'),
                  trailing: FutureBuilder<bool>(
                    future: paymentService.paymentExistsForExpense(
                      companyId: companyId,
                      expenseId: expenseId,
                    ),
                    builder: (context, snapshot) {
                      final alreadyCreated = snapshot.data == true;

                      if (alreadyCreated) {
                        return const Text(
                          'Payment Created',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }

                      return ElevatedButton(
                        child: const Text('Create Payment'),
                        onPressed: () async {
                          await paymentService.createPayment(
                            companyId: companyId,
                            userId: userId,
                            expenseId: expenseId,
                            amount: amount,
                            paymentMethod: PaymentConstants.upi,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment created successfully'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
