import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages student attendance data in local storage (SharedPreferences)
class AttendanceService {

  // Central SharedPreferences key holding a map of all attendance records
  static const String key = "attendance_data";

  // Creates a unique composite key (e.g. "student1_2nd_CSE") to group records by student and class
  static Future<String> _getUserKey(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final year = prefs.getString("year_$username") ?? "";
    final branch = prefs.getString("branch_$username") ?? "";

    return "${username}_${year}_$branch";
  }

  // Marks attendance for a student on a specific date (stores selfie path, coordinates, and metadata)
  static Future<void> markAttendance({
    required String username,
    required String date,
    required String image,
    required String location,
  }) async {

    final prefs = await SharedPreferences.getInstance();

    final displayName = prefs.getString("displayName_$username") ?? username;
    final enrollment = prefs.getString("enrollment_$username") ?? "";
    final branch = prefs.getString("branch_$username") ?? "";
    final year = prefs.getString("year_$username") ?? "";

    final userKey = await _getUserKey(username);

    // Read all attendance data from storage
    final data = prefs.getString(key);
    Map<String, dynamic> allData =
    data != null ? jsonDecode(data) : {};

    List userData = allData[userKey] ?? [];

    // Prevent duplicate attendance records for the same date
    bool alreadyMarked =
    userData.any((e) => e["date"] == date);

    if (alreadyMarked) return;

    // Add new present record with timestamp
    userData.add({
      "date": date,
      "time": DateTime.now().toIso8601String(),
      "status": "present",
      "image": image,
      "location": location,

      "username": username,
      "displayName": displayName,
      "enrollment": enrollment,
      "branch": branch,
      "year": year,
    });

    allData[userKey] = userData;

    // Save updated attendance map back to SharedPreferences
    await prefs.setString(key, jsonEncode(allData));
  }

  // Returns all attendance records for a specific student
  static Future<List> getUserAttendance(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final userKey = await _getUserKey(username);

    final data = prefs.getString(key);
    Map<String, dynamic> allData =
    data != null ? jsonDecode(data) : {};

    return allData[userKey] ?? [];
  }

  // Changes a student's attendance status to "rejected" (absent) for a specific date
  static Future<void> markAbsent({
    required String username,
    required String date,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final userKey = await _getUserKey(username);

    final data = prefs.getString(key);
    Map<String, dynamic> allData =
    data != null ? jsonDecode(data) : {};

    List userData = allData[userKey] ?? [];

    for (var entry in userData) {
      if (entry["date"] == date) {
        entry["status"] = "rejected";
      }
    }

    allData[userKey] = userData;

    await prefs.setString(key, jsonEncode(allData));
  }

  // Retrieves the entire attendance map from storage
  static Future<Map<String, dynamic>> getAllAttendance() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(key);
    return data != null ? jsonDecode(data) : {};
  }

  // Filters students by academic year and branch based on existing attendance records
  static Future<List> getStudentsByFilter({
    required String year,
    required String branch,
  }) async {

    final all = await getAllAttendance();

    List result = [];

    all.forEach((userKey, records) {

      if (records.isEmpty) return;

      final sample = records[0];

      if (sample["year"] == year &&
          sample["branch"] == branch) {

        result.add({
          "username": sample["username"],
          "displayName": sample["displayName"],
          "enrollment": sample["enrollment"],
        });
      }
    });

    return result;
  }

  // Retrieves full attendance history for a student
  static Future<List> getStudentFullAttendance(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final userKey = await _getUserKey(username);

    final data = prefs.getString(key);
    Map<String, dynamic> allData =
    data != null ? jsonDecode(data) : {};

    return allData[userKey] ?? [];
  }

  // Collects all attendance entries marked for today's date across all students
  static Future<List> getTodayAttendance() async {
    final all = await getAllAttendance();

    final today = DateTime.now();
    final todayStr =
    DateTime(today.year, today.month, today.day).toIso8601String();

    List result = [];

    all.forEach((userKey, records) {
      for (var r in records) {
        if (r["date"] == todayStr) {
          result.add(r);
        }
      }
    });

    return result;
  }
}