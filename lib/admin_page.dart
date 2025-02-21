import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String _selectedSection = 'users';
  String _selectedUserType = 'student';
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> _deleteUser(String userId, String userType) async {
    try {
      // Use plural for students, singular for staff
      final path = userType == 'student' ? 'users/students/$userId' : 'users/staff/$userId';

      await _database.child(path).remove();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteRequest(String requestId) async {
    try {
      await _database.child('equipment_requests/$requestId').remove();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting request: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _database.child('equipment_requests/$requestId').update({
        'status': newStatus,
        'updatedAt': ServerValue.timestamp,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $newStatus successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating request: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          automaticallyImplyLeading: false, // Remove back button
          actions: [
            // Logout button in AppBar
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Navigate to login page and remove all previous routes
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
            // Section Selection
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'users',
                    label: Text('Users'),
                    icon: Icon(Icons.people),
                  ),
                  ButtonSegment(
                    value: 'requests',
                    label: Text('Equipment Requests'),
                    icon: Icon(Icons.devices),
                  ),
                ],
                selected: {
                  _selectedSection
                },
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedSection = newSelection.first;
                  });
                },
              ),
            ),
            // User Type Selection (only show when users section is selected)
            if (_selectedSection == 'users')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'student',
                      label: Text('Students'),
                      icon: Icon(Icons.school),
                    ),
                    ButtonSegment(
                      value: 'staff',
                      label: Text('Staff'),
                      icon: Icon(Icons.work),
                    ),
                  ],
                  selected: {
                    _selectedUserType
                  },
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedUserType = newSelection.first;
                    });
                  },
                ),
              ),
            const SizedBox(height: 16),
            // Content Section
            Expanded(
              child: _selectedSection == 'users' ? _buildUserList() : _buildRequestList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _database.child(_selectedUserType == 'student' ? 'users/students' : 'users/staff').orderByChild('createdAt').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return Center(
            child: Text('No ${_selectedUserType}s found'),
          );
        }

        Map<dynamic, dynamic> users = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

        List<MapEntry<dynamic, dynamic>> userList = users.entries.toList();
        userList.sort((a, b) => (b.value['createdAt'] ?? 0).compareTo(a.value['createdAt'] ?? 0));

        return ListView.builder(
          itemCount: userList.length,
          itemBuilder: (context, index) {
            final entry = userList[index];
            final userId = entry.key;
            final userData = entry.value as Map<dynamic, dynamic>;
            final displayId = _selectedUserType == 'student' ? userData['studID'] : userData['email'];
            final createdAt = DateTime.fromMillisecondsSinceEpoch(userData['createdAt'] ?? 0);

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: ListTile(
                leading: Icon(
                  _selectedUserType == 'student' ? Icons.school : Icons.work,
                ),
                title: Text(displayId?.toString() ?? 'N/A'),
                subtitle: Text('Created: ${createdAt.toString()}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete User'),
                      content: Text(
                        'Are you sure you want to delete this ${_selectedUserType}?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteUser(userId.toString(), _selectedUserType);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestList() {
    return StreamBuilder(
      stream: _database.child('equipment_requests').orderByChild('requestDate').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(
            child: Text('No equipment requests found'),
          );
        }

        Map<dynamic, dynamic> requests = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

        List<MapEntry<dynamic, dynamic>> requestList = requests.entries.toList();
        requestList.sort((a, b) => (b.value['requestDate'] ?? 0).compareTo(a.value['requestDate'] ?? 0));

        return ListView.builder(
          itemCount: requestList.length,
          itemBuilder: (context, index) {
            final entry = requestList[index];
            final requestId = entry.key;
            final requestData = entry.value as Map<dynamic, dynamic>;
            final requestDate = DateTime.fromMillisecondsSinceEpoch(requestData['requestDate'] ?? 0);
            final status = requestData['status'] as String;

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: ListTile(
                leading: Icon(
                  requestData['userType'] == 'student' ? Icons.school : Icons.work,
                ),
                title: Text(requestData['equipmentType']?.toString() ?? 'N/A'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('By: ${requestData['userIdentifier']}'),
                    Text('Purpose: ${requestData['purpose']}'),
                    Text('Date: ${requestDate.toString()}'),
                    Text('Status: ${status.toUpperCase()}'),
                  ],
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status == 'pending') ...[
                      IconButton(
                        icon: const Icon(Icons.check_circle),
                        color: Colors.green,
                        onPressed: () => _updateRequestStatus(requestId, 'approved'),
                        tooltip: 'Approve',
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel),
                        color: Colors.red,
                        onPressed: () => _updateRequestStatus(requestId, 'rejected'),
                        tooltip: 'Reject',
                      ),
                    ] else
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Request'),
                            content: const Text('Are you sure you want to delete this request?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteRequest(requestId.toString());
                                },
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
