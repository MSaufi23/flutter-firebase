import 'package:flutter/material.dart';
import 'equipment_request_form.dart';
import 'widgets/request_list.dart';

class StudentPage extends StatefulWidget {
  final String studentId;

  const StudentPage({super.key, required this.studentId});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  bool _showRequests = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Student Dashboard'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Welcome Student',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'ID: ${widget.studentId}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EquipmentRequestForm(
                            userId: widget.studentId,
                            userType: 'student',
                            userIdentifier: widget.studentId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.devices),
                    label: const Text('Request Equipment'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Requests Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Requests',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(_showRequests ? Icons.expand_less : Icons.expand_more),
                          onPressed: () {
                            setState(() {
                              _showRequests = !_showRequests;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_showRequests)
                    Expanded(
                      child: RequestList(
                        userId: widget.studentId,
                        userType: 'student',
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
