import 'package:flutter/material.dart';

class StaffPage extends StatelessWidget {
  final String email;

  const StaffPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Staff',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Email: $email',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Return to login page
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
