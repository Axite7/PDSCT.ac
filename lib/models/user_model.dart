import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String username;
  final String role; // 'user', 'admin', 'root'
  final String? profilePicUrl;
  final String enrollmentNo;
  final String branch;
  final String semester;
  final String year;
  final String phone;
  final String age;
  final String? fcmToken;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.username,
    this.role = 'user',
    this.profilePicUrl,
    this.enrollmentNo = '',
    this.branch = '',
    this.semester = '',
    this.year = '',
    this.phone = '',
    this.age = '',
    this.fcmToken,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'username': username,
      'role': role,
      'profilePicUrl': profilePicUrl,
      'enrollmentNo': enrollmentNo,
      'branch': branch,
      'semester': semester,
      'year': year,
      'phone': phone,
      'age': age,
      'fcmToken': fcmToken,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? 'user',
      profilePicUrl: json['profilePicUrl'],
      enrollmentNo: json['enrollmentNo'] ?? '',
      branch: json['branch'] ?? '',
      semester: json['semester'] ?? '',
      year: json['year'] ?? '',
      phone: json['phone'] ?? '',
      age: json['age'] ?? '',
      fcmToken: json['fcmToken'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel.fromJson({...data, 'uid': doc.id});
  }
}