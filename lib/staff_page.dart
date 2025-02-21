import 'package:flutter/material.dart';
import 'equipment_request_form.dart';
import 'widgets/request_list.dart';

class StaffPage extends StatefulWidget {
  final String email;

  const StaffPage({super.key, required this.email});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  bool _showRequests = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Staff Dashboard'),
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
                    'Welcome Staff',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'Email: ${widget.email}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EquipmentRequestForm(
                            userId: widget.email,
                            userType: 'staff',
                            userIdentifier: widget.email,
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
                        userId: widget.email,
                        userType: 'staff',
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
