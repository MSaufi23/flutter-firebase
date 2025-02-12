import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String _selectedUserType = 'student';
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> _deleteUser(String userId, String userType) async {
    try {
      await _database.child('users/${userType}s/$userId').remove();
      
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // User Type Selection
          Padding(
            padding: const EdgeInsets.all(16.0),
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
              selected: {_selectedUserType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedUserType = newSelection.first;
                });
              },
            ),
          ),
          // User List
          Expanded(
            child: StreamBuilder(
              stream: _database
                  .child('users/${_selectedUserType}s')
                  .orderByChild('createdAt')
                  .onValue,
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

                Map<dynamic, dynamic> users = 
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                List<MapEntry<dynamic, dynamic>> userList = users.entries.toList();
                // Sort by creation time (newest first)
                userList.sort((a, b) => (b.value['createdAt'] ?? 0)
                    .compareTo(a.value['createdAt'] ?? 0));

                return ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    final entry = userList[index];
                    final userId = entry.key;
                    final userData = entry.value as Map<dynamic, dynamic>;
                    final displayId = _selectedUserType == 'student' 
                        ? userData['studID'] 
                        : userData['email'];
                    final createdAt = DateTime.fromMillisecondsSinceEpoch(
                        userData['createdAt'] ?? 0);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ListTile(
                        leading: Icon(
                          _selectedUserType == 'student'
                              ? Icons.school
                              : Icons.work,
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
            ),
          ),
        ],
      ),
    );
  }
}
