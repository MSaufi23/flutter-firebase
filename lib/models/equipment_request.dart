class EquipmentRequest {
  final String id;
  final String userId;
  final String userType; // 'student' or 'staff'
  final String userIdentifier; // student ID or email
  final String equipmentType;
  final String purpose;
  final DateTime requestDate;
  final String status; // 'pending', 'approved', 'rejected'

  EquipmentRequest({
    required this.id,
    required this.userId,
    required this.userType,
    required this.userIdentifier,
    required this.equipmentType,
    required this.purpose,
    required this.requestDate,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userType': userType,
      'userIdentifier': userIdentifier,
      'equipmentType': equipmentType,
      'purpose': purpose,
      'requestDate': requestDate.millisecondsSinceEpoch,
      'status': status,
    };
  }

  static EquipmentRequest fromJson(String id, Map<dynamic, dynamic> json) {
    return EquipmentRequest(
      id: id,
      userId: json['userId'] as String,
      userType: json['userType'] as String,
      userIdentifier: json['userIdentifier'] as String,
      equipmentType: json['equipmentType'] as String,
      purpose: json['purpose'] as String,
      requestDate: DateTime.fromMillisecondsSinceEpoch(json['requestDate'] as int),
      status: json['status'] as String,
    );
  }
}
