import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RequestList extends StatelessWidget {
  final String userId;
  final String userType;
  final bool showAllRequests;

  const RequestList({
    super.key,
    required this.userId,
    required this.userType,
    this.showAllRequests = false,
  });

  @override
  Widget build(BuildContext context) {
    final query = FirebaseDatabase.instance.ref().child('equipment_requests').orderByChild(showAllRequests ? 'requestDate' : 'userId').equalTo(showAllRequests ? null : userId);

    return StreamBuilder(
      stream: query.onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text('No requests found'));
        }

        Map<dynamic, dynamic> requests = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        List<MapEntry<dynamic, dynamic>> requestList = requests.entries.toList();
        requestList.sort((a, b) => (b.value['requestDate'] ?? 0).compareTo(a.value['requestDate'] ?? 0));

        return ListView.builder(
          itemCount: requestList.length,
          itemBuilder: (context, index) {
            final entry = requestList[index];
            final requestData = entry.value as Map<dynamic, dynamic>;
            final requestDate = DateTime.fromMillisecondsSinceEpoch(requestData['requestDate'] ?? 0);
            final status = requestData['status'] as String;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListTile(
                leading: Icon(
                  requestData['equipmentType'].toString().toLowerCase().contains('laptop')
                      ? Icons.laptop
                      : requestData['equipmentType'].toString().toLowerCase().contains('projector')
                          ? Icons.video_camera_front
                          : Icons.devices,
                ),
                title: Text(requestData['equipmentType']?.toString() ?? 'N/A'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Purpose: ${requestData['purpose']}'),
                    Text('Date: ${requestDate.toString()}'),
                    Text(
                      'Status: ${status.toUpperCase()}',
                      style: TextStyle(
                        color: status == 'approved'
                            ? Colors.green
                            : status == 'rejected'
                                ? Colors.red
                                : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
