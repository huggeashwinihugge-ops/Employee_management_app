import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class CreateEmployeeScreen extends StatefulWidget {
  final String companyId;

  const CreateEmployeeScreen({
    super.key,
    required this.companyId,
  });

  @override
  State<CreateEmployeeScreen> createState() => _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState extends State<CreateEmployeeScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = false;

  Future<void> _createEmployee() async {
    setState(() => _isLoading = true);

    try {
      /// 🔐 Create SECONDARY Firebase App (important)
      FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      /// 1️⃣ Create employee in Firebase Auth (without logging out admin)
      UserCredential userCredential =
          await secondaryAuth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final String employeeUid = userCredential.user!.uid;

      /// 2️⃣ Save employee in Firestore
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .collection('users')
          .doc(employeeUid)
          .set({
        'uid': employeeUid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'employee',
        'companyId': widget.companyId,
        'active': true,
        'createdAt': Timestamp.now(),
      });

      /// 3️⃣ Cleanup secondary app
      await secondaryAuth.signOut();
      await secondaryApp.delete();

      /// 4️⃣ Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee created successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Employee Name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Employee Email',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Temporary Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createEmployee,
                    child: const Text('Create Employee'),
                  ),
          ],
        ),
      ),
    );
  }
}
