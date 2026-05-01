import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String userId;
  final DateTime date;
  final String dateKey; // "YYYY-MM-DD" format
  final String status; // 'present', 'absent', 'holiday'
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final DateTime? markedAt;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.dateKey,
    required this.status,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.markedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'dateKey': dateKey,
      'status': status,
      'photoUrl': photoUrl,
      'location': (latitude != null && longitude != null)
          ? GeoPoint(latitude!, longitude!)
          : null,
      'markedAt': markedAt != null ? Timestamp.fromDate(markedAt!) : null,
    };
  }

  factory AttendanceModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    GeoPoint? loc = data['location'];

    return AttendanceModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: data['date'] is Timestamp
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      dateKey: data['dateKey'] ?? '',
      status: data['status'] ?? 'absent',
      photoUrl: data['photoUrl'],
      latitude: loc?.latitude,
      longitude: loc?.longitude,
      markedAt: data['markedAt'] is Timestamp
          ? (data['markedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
