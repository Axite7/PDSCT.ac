import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ======================== USERS ========================

  /// Create a new user document in Firestore
  static Future<void> createUser({
    required String uid,
    required String email,
    required String displayName,
    required String username,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'username': username,
      'role': 'user',
      'profilePicUrl': null,
      'enrollmentNo': '',
      'branch': '',
      'semester': '',
      'year': '',
      'phone': '',
      'age': '',
      'fcmToken': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get user document
  static Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  /// Stream user document for real-time updates
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  /// Update user profile fields
  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  /// Get user role
  static Future<String> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] ?? 'user';
  }

  /// Get all users (for admin)
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamAllUsers() {
    return _db.collection('users').orderBy('createdAt', descending: true).snapshots();
  }

  /// Update FCM token for user
  static Future<void> updateFCMToken(String uid, String token) async {
    await _db.collection('users').doc(uid).update({'fcmToken': token});
  }

  // ======================== EVENTS ========================

  /// Add a new event
  static Future<void> addEvent({
    required String title,
    required String description,
    required DateTime date,
    required String imageUrl,
    required String createdBy,
  }) async {
    await _db.collection('events').add({
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream all events (real-time)
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamEvents() {
    return _db.collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Delete an event
  static Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  // ======================== ATTENDANCE ========================

  /// Mark attendance
  static Future<void> markAttendance({
    required String userId,
    required DateTime date,
    required String status,
    String? photoUrl,
    GeoPoint? location,
  }) async {
    final dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    await _db.collection('attendance').doc("${userId}_$dateKey").set({
      'userId': userId,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'dateKey': dateKey,
      'status': status,
      'photoUrl': photoUrl,
      'location': location,
      'markedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get attendance records for a user
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamAttendance(String userId) {
    return _db.collection('attendance')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  /// Get all attendance records (for admin)
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamAllAttendance() {
    return _db.collection('attendance')
        .orderBy('markedAt', descending: true)
        .snapshots();
  }

  // ======================== NOTES ========================

  /// Upload a note (pending or approved based on role)
  static Future<void> uploadNote({
    required String title,
    required String fileUrl,
    required String subject,
    required String year,
    required String branch,
    required String uploadedBy,
    required String status, // 'pending' or 'approved'
  }) async {
    await _db.collection('notes').add({
      'title': title,
      'fileUrl': fileUrl,
      'subject': subject,
      'year': year,
      'branch': branch,
      'uploadedBy': uploadedBy,
      'status': status,
      'uploadedAt': FieldValue.serverTimestamp(),
      'approvedBy': null,
      'approvedAt': null,
    });
  }

  /// Get approved notes for a subject
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamApprovedNotes({
    required String subject,
    required String year,
    required String branch,
  }) {
    return _db.collection('notes')
        .where('subject', isEqualTo: subject)
        .where('year', isEqualTo: year)
        .where('branch', isEqualTo: branch)
        .where('status', isEqualTo: 'approved')
        .snapshots();
  }

  /// Get pending notes (for admin)
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamPendingNotes() {
    return _db.collection('notes')
        .where('status', isEqualTo: 'pending')
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  /// Approve a note
  static Future<void> approveNote(String noteId, String approvedBy) async {
    await _db.collection('notes').doc(noteId).update({
      'status': 'approved',
      'approvedBy': approvedBy,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reject a note
  static Future<void> rejectNote(String noteId) async {
    await _db.collection('notes').doc(noteId).update({
      'status': 'rejected',
    });
  }

  /// Delete a note
  static Future<void> deleteNote(String noteId) async {
    await _db.collection('notes').doc(noteId).delete();
  }

  // ======================== TIMETABLES ========================

  /// Upload or update timetable
  static Future<void> uploadTimetable({
    required int semester,
    required String type,
    required String fileUrl,
    required String uploadedBy,
  }) async {
    final docId = "sem${semester}_$type";
    await _db.collection('timetables').doc(docId).set({
      'semester': semester,
      'type': type,
      'fileUrl': fileUrl,
      'uploadedBy': uploadedBy,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get timetable
  static Future<Map<String, dynamic>?> getTimetable(int semester, String type) async {
    final docId = "sem${semester}_$type";
    final doc = await _db.collection('timetables').doc(docId).get();
    return doc.data();
  }

  /// Stream timetable
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamTimetable(int semester, String type) {
    final docId = "sem${semester}_$type";
    return _db.collection('timetables').doc(docId).snapshots();
  }

  /// Delete timetable
  static Future<void> deleteTimetable(int semester, String type) async {
    final docId = "sem${semester}_$type";
    await _db.collection('timetables').doc(docId).delete();
  }

  // ======================== NOTIFICATIONS ========================

  /// Add notification for a user
  static Future<void> addNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'general',
  }) async {
    await _db
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .add({
      'title': title,
      'message': message,
      'type': type,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Send notification to all users
  static Future<void> addNotificationToAll({
    required String title,
    required String message,
    String type = 'general',
  }) async {
    final usersSnapshot = await _db.collection('users').get();

    final batch = _db.batch();
    for (var userDoc in usersSnapshot.docs) {
      final notifRef = _db
          .collection('notifications')
          .doc(userDoc.id)
          .collection('items')
          .doc();
      batch.set(notifRef, {
        'title': title,
        'message': message,
        'type': type,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Stream notifications for a user
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamNotifications(String userId) {
    return _db
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Mark notification as read
  static Future<void> markNotificationRead(String userId, String notifId) async {
    await _db
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .doc(notifId)
        .update({'read': true});
  }

  /// Mark all notifications as read
  static Future<void> markAllNotificationsRead(String userId) async {
    final snapshot = await _db
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .where('read', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  /// Delete a notification
  static Future<void> deleteNotification(String userId, String notifId) async {
    await _db
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .doc(notifId)
        .delete();
  }

  /// Get unread notification count
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamUnreadNotifications(String userId) {
    return _db
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .where('read', isEqualTo: false)
        .snapshots();
  }

  // ======================== ADMIN REQUESTS ========================

  /// Request admin access
  static Future<void> requestAdmin(String userId, String username) async {
    await _db.collection('admin_requests').doc(userId).set({
      'userId': userId,
      'username': username,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
      'resolvedAt': null,
      'resolvedBy': null,
    });
  }

  /// Stream admin requests
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamAdminRequests() {
    return _db.collection('admin_requests')
        .orderBy('requestedAt', descending: true)
        .snapshots();
  }

  /// Approve admin request
  static Future<void> approveAdminRequest(String userId, String resolvedBy) async {
    await _db.collection('admin_requests').doc(userId).update({
      'status': 'approved',
      'resolvedAt': FieldValue.serverTimestamp(),
      'resolvedBy': resolvedBy,
    });
    // Update user role
    await _db.collection('users').doc(userId).update({'role': 'admin'});
  }

  /// Reject admin request
  static Future<void> rejectAdminRequest(String userId, String resolvedBy) async {
    await _db.collection('admin_requests').doc(userId).update({
      'status': 'rejected',
      'resolvedAt': FieldValue.serverTimestamp(),
      'resolvedBy': resolvedBy,
    });
  }

  /// Remove admin role
  static Future<void> removeAdmin(String userId) async {
    await _db.collection('users').doc(userId).update({'role': 'user'});
    await _db.collection('admin_requests').doc(userId).update({
      'status': 'removed',
    });
  }

  // ======================== ANALYTICS ========================

  /// Get total user count
  static Future<int> getTotalUsers() async {
    final snapshot = await _db.collection('users').count().get();
    return snapshot.count ?? 0;
  }

  /// Get total event count
  static Future<int> getTotalEvents() async {
    final snapshot = await _db.collection('events').count().get();
    return snapshot.count ?? 0;
  }

  /// Get total notes count
  static Future<int> getTotalNotes() async {
    final snapshot = await _db.collection('notes')
        .where('status', isEqualTo: 'approved')
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
