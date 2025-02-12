import 'package:flutter/material.dart';

class StudentPage extends StatelessWidget {
  final String studentId;

  const StudentPage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Student',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'ID: $studentId',
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
