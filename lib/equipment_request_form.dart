import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EquipmentRequestForm extends StatefulWidget {
  final String userId;
  final String userType;
  final String userIdentifier;

  const EquipmentRequestForm({
    super.key,
    required this.userId,
    required this.userType,
    required this.userIdentifier,
  });

  @override
  State<EquipmentRequestForm> createState() => _EquipmentRequestFormState();
}

class _EquipmentRequestFormState extends State<EquipmentRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _equipmentController = TextEditingController();
  final _purposeController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _equipmentTypes = [
    'Projector',
    'Laptop',
    'Microphone',
    'Speaker',
    'Camera',
    'Other'
  ];

  String _selectedEquipment = 'Projector';

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final newRequestRef = FirebaseDatabase.instance.ref().child('equipment_requests').push();

        await newRequestRef.set({
          'userId': widget.userId,
          'userType': widget.userType == 'student' ? 'students' : 'staff',
          'userIdentifier': widget.userIdentifier,
          'equipmentType': _selectedEquipment,
          'purpose': _purposeController.text,
          'requestDate': ServerValue.timestamp,
          'status': 'pending',
        });

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting request: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Equipment'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Equipment Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedEquipment,
                decoration: const InputDecoration(
                  labelText: 'Equipment Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.devices),
                ),
                items: _equipmentTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedEquipment = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              // Purpose TextField
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the purpose of your request';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              // Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitRequest,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSubmitting ? 'Submitting...' : 'Submit Request'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _equipmentController.dispose();
    _purposeController.dispose();
    super.dispose();
  }
}
