import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateExpenseScreen extends StatefulWidget {
  final String companyId;
  final String userId;

  const CreateExpenseScreen({
    super.key,
    required this.companyId,
    required this.userId,
  });

  @override
  State<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends State<CreateExpenseScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  bool isLoading = false;

  Future<void> saveExpense() async {
    if (titleController.text.isEmpty ||
        amountController.text.isEmpty ||
        categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyId)
        .collection('expenses')
        .add({
      'title': titleController.text.trim(),
      'amount': double.parse(amountController.text.trim()),
      'category': categoryController.text.trim(),
      'createdBy': widget.userId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Expense Title',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : saveExpense,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
