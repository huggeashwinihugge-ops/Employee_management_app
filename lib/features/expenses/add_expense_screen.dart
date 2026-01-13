import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddExpenseScreen extends StatefulWidget {
  final String companyId;
  final String userId;

  const AddExpenseScreen({
    super.key,
    required this.companyId,
    required this.userId,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _category = 'Travel';
  bool _loading = false;

  final List<String> categories = [
    'Travel',
    'Food',
    'Office',
    'Internet',
    'Other',
  ];

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .collection('expenses')
          .add({
        'title': _titleController.text.trim(),
        'amount': double.parse(_amountController.text.trim()),
        'category': _category,
        'description': _descriptionController.text.trim(),
        'createdBy': widget.userId,
        'companyId': widget.companyId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense submitted successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// TITLE
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Expense Title',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Enter expense title' : null,
              ),

              const SizedBox(height: 12),

              /// AMOUNT
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter amount' : null,
              ),

              const SizedBox(height: 12),

              /// CATEGORY
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _category = value!);
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
              ),

              const SizedBox(height: 12),

              /// DESCRIPTION
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              /// SUBMIT BUTTON
              ElevatedButton(
                onPressed: _loading ? null : _submitExpense,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
