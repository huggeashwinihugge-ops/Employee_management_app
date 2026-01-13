import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminExpenseHistoryScreen extends StatelessWidget {
  final String companyId;

  const AdminExpenseHistoryScreen({
    super.key,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('expenses')
            .where('status', whereIn: ['approved', 'rejected'])
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No approved or rejected expenses found'),
            );
          }

          final expenses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final data = expenses[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: ListTile(
                  title: Text(
                    '₹ ${data['amount']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category: ${data['category']}'),
                      Text('Employee ID: ${data['userId']}'),
                      Text('Status: ${data['status']}'),
                    ],
                  ),
                  trailing: Icon(
                    data['status'] == 'approved'
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: data['status'] == 'approved'
                        ? Colors.green
                        : Colors.red,
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
