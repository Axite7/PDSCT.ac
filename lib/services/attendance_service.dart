import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceService {

  static const String key = "attendance_data";

  static Future<String> _getUserKey(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final year = prefs.getString("year_$username") ?? "";
    final branch = prefs.getString("branch_$username") ?? "";

    return "${username}_${year}_$branch";
  }

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

    final data = prefs.getString(key);
    Map<String, dynamic> allData =
    data != null ? jsonDecode(data) : {};

    List userData = allData[userKey] ?? [];

    bool alreadyMarked =
    userData.any((e) => e["date"] == date);

    if (alreadyMarked) return;

    userData.add({
      "date": date,
      "time": DateTime.now().toIso8601String(), // 🔥 FIX
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

    await prefs.setString(key, jsonEncode(allData));
  }

  static Future<List> getUserAttendance(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final userKey = await _getUserKey(username);

    final data = prefs.getString(key);
    Map<String, dynamic> allData =
    data != null ? jsonDecode(data) : {};

    return allData[userKey] ?? [];
  }

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

  static Future<Map<String, dynamic>> getAllAttendance() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(key);
    return data != null ? jsonDecode(data) : {};
  }

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

  static Future<List> getStudentFullAttendance(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final userKey = await _getUserKey(username);

    final data = prefs.getString(key);
    Map<String, dynamic> allData =
    data != null ? jsonDecode(data) : {};

    return allData[userKey] ?? [];
  }

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