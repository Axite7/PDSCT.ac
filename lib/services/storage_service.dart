import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const _uuid = Uuid();

  /// Upload an image file and return the download URL
  static Future<String> uploadImage(File file, String folder) async {
    final ext = file.path.split('.').last;
    final fileName = "${_uuid.v4()}.$ext";
    final ref = _storage.ref().child('$folder/$fileName');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/$ext'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  /// Upload a PDF file and return the download URL
  static Future<String> uploadPDF(File file, String folder) async {
    final fileName = "${_uuid.v4()}.pdf";
    final ref = _storage.ref().child('$folder/$fileName');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'application/pdf'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  /// Upload any file and return the download URL
  static Future<String> uploadFile(File file, String folder) async {
    final ext = file.path.split('.').last;
    final fileName = "${_uuid.v4()}.$ext";
    final ref = _storage.ref().child('$folder/$fileName');

    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Delete a file from storage by its download URL
  static Future<void> deleteFileByUrl(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      // File might already be deleted, ignore error
      print("Error deleting file: $e");
    }
  }

  /// Upload profile picture
  static Future<String> uploadProfilePic(File file, String uid) async {
    final ext = file.path.split('.').last;
    final ref = _storage.ref().child('profile_pics/$uid.$ext');

    // Delete old profile pic if exists
    try {
      await ref.delete();
    } catch (_) {}

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/$ext'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  /// Upload event poster
  static Future<String> uploadEventPoster(File file) async {
    return await uploadImage(file, 'event_posters');
  }

  /// Upload attendance selfie
  static Future<String> uploadAttendanceSelfie(File file, String uid) async {
    return await uploadImage(file, 'attendance/$uid');
  }

  /// Upload note PDF
  static Future<String> uploadNotePDF(File file) async {
    return await uploadPDF(file, 'notes');
  }

  /// Upload timetable file
  static Future<String> uploadTimetable(File file) async {
    return await uploadFile(file, 'timetables');
  }
}
