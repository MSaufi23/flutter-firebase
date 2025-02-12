import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'student_page.dart';
import 'staff_page.dart';
import 'admin_page.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Check for admin login
        if (_loginController.text == 'admin') {
          final adminSnapshot = await _database.child('admin/credentials').get();

          if (adminSnapshot.exists) {
            final adminData = adminSnapshot.value as Map<Object?, Object?>;
            if (adminData['password'] == _passwordController.text) {
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminPage(),
                ),
              );
              return;
            }
          }
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid admin credentials')),
          );
          return;
        }

        if (RegExp(r'^[0-9]+$').hasMatch(_loginController.text)) {
          // Student login
          final studentSnapshot = await _database.child('users/students').orderByChild('studID').equalTo(_loginController.text).get();

          if (studentSnapshot.exists) {
            final students = studentSnapshot.value as Map<Object?, Object?>;
            final studentData = students.values.first as Map<Object?, Object?>;

            if (studentData['password'] == _passwordController.text) {
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentPage(studentId: _loginController.text),
                ),
              );
              return;
            }
          }
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid student credentials')),
          );
        } else if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_loginController.text)) {
          // Staff login
          final staffSnapshot = await _database.child('users/staff').orderByChild('email').equalTo(_loginController.text).get();

          if (staffSnapshot.exists) {
            final staff = staffSnapshot.value as Map<Object?, Object?>;
            final staffData = staff.values.first as Map<Object?, Object?>;

            if (staffData['password'] == _passwordController.text) {
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StaffPage(email: _loginController.text),
                ),
              );
              return;
            }
          }
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid staff credentials')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _loginController,
                decoration: const InputDecoration(
                  labelText: 'Enter Student ID or Email',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 12345 or staff@example.com',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Student ID or Email';
                  }
                  if (value == 'admin') return null; // Allow admin login
                  bool isNumber = RegExp(r'^[0-9]+$').hasMatch(value);
                  bool isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);

                  if (!isNumber && !isEmail) {
                    return 'Please enter a valid Student ID or Email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpPage(),
                    ),
                  );
                },
                child: const Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
