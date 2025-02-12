import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase collections
final CollectionReference studentCollection = FirebaseFirestore.instance.collection('student');
final CollectionReference staffCollection = FirebaseFirestore.instance.collection('staff');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(options: const FirebaseOptions(apiKey: "AIzaSyBo9ifip49tLQ4Kn1_VG9jAaVxfU6FFD98", authDomain: "lab-work-bf4c6.firebaseapp.com", projectId: "lab-work-bf4c6", storageBucket: "lab-work-bf4c6.firebasestorage.app", messagingSenderId: "545468650872", appId: "1:545468650872:web:f26f772fbb5db80853e48d"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  String _welcomeMessage = '';
  bool _isLoggedIn = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (RegExp(r'^[0-9]+$').hasMatch(_loginController.text)) {
          // Student login
          final studentDoc = await studentCollection.where('studID', isEqualTo: _loginController.text).where('password', isEqualTo: _passwordController.text).get();

          if (studentDoc.docs.isNotEmpty) {
            setState(() {
              _isLoggedIn = true;
              _welcomeMessage = 'Welcome, Student';
            });
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid student credentials')),
            );
          }
        } else if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_loginController.text)) {
          // Staff login
          final staffDoc = await staffCollection.where('email', isEqualTo: _loginController.text).where('password', isEqualTo: _passwordController.text).get();

          if (staffDoc.docs.isNotEmpty) {
            setState(() {
              _isLoggedIn = true;
              _welcomeMessage = 'Welcome, Staff';
            });
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid staff credentials')),
            );
          }
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
      body: Center(
        child: _isLoggedIn
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _welcomeMessage,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoggedIn = false;
                        _loginController.clear();
                        _passwordController.clear();
                      });
                    },
                    child: const Text('Logout'),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
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
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _handleLogin,
                        child: const Text('Login'),
                      ),
                    ],
                  ),
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
