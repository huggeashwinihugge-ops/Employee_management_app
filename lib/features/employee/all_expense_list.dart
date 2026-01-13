import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllExpensesListScreen extends StatelessWidget {
  final String companyId;
  final String userId;

  const AllExpensesListScreen({
    super.key,
    required this.companyId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final expensesQuery = FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('expenses')
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
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

              final title = data['title'] ?? 'Expense';
              final amount = data['amount'] ?? 0;
              final status = data['status'] ?? 'pending';

              Color color = Colors.orange;
              if (status == 'approved') color = Colors.green;
              if (status == 'rejected') color = Colors.red;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('₹$amount'),
                  trailing: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
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
