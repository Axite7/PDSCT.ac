import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String fileUrl; // Firebase Storage URL
  final String subject;
  final String year;
  final String branch;
  final String uploadedBy; // UID
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime? uploadedAt;
  final String? approvedBy;
  final DateTime? approvedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.subject,
    required this.year,
    required this.branch,
    required this.uploadedBy,
    required this.status,
    this.uploadedAt,
    this.approvedBy,
    this.approvedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'fileUrl': fileUrl,
      'subject': subject,
      'year': year,
      'branch': branch,
      'uploadedBy': uploadedBy,
      'status': status,
      'uploadedAt': uploadedAt != null ? Timestamp.fromDate(uploadedAt!) : null,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }

  factory NoteModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return NoteModel(
      id: doc.id,
      title: data['title'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      subject: data['subject'] ?? '',
      year: data['year'] ?? '',
      branch: data['branch'] ?? '',
      uploadedBy: data['uploadedBy'] ?? '',
      status: data['status'] ?? 'pending',
      uploadedAt: data['uploadedAt'] is Timestamp
          ? (data['uploadedAt'] as Timestamp).toDate()
          : null,
      approvedBy: data['approvedBy'],
      approvedAt: data['approvedAt'] is Timestamp
          ? (data['approvedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
