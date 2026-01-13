import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEmployeeListScreen extends StatelessWidget {
  final String companyId;

  const AdminEmployeeListScreen({
    super.key,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final employeesRef = FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('users')
        .where('role', isEqualTo: 'employee');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: employeesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No employees found',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final employees = snapshot.data!.docs;

          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final data = employees[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(data['name'] ?? 'No Name'),
                  subtitle: Text(data['email'] ?? 'No Email'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
