import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:college_app/services/notification_service.dart';

/// Manages user roles and permission checks:
/// - "root": Super-admin with full privileges (hardcoded as "Axite7")
/// - "admin": Approved administrators who can manage notes, events, and attendance
/// - "user": Regular student account
class UserRole {
  static const String _rootUsername = "Axite7";

  /// Checks the role for a given username ("root", "admin", or "user")
  static Future<String> getRole(String username) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Check if username matches hardcoded root administrator
    if (username == _rootUsername) {
      return "root";
    }

    // 2. Read approved admins list from SharedPreferences
    final approvedData = prefs.getString("approvedAdmins");
    final List approvedList =
    approvedData != null ? jsonDecode(approvedData) : [];

    // 3. If username is in approved list, grant admin role
    if (approvedList.contains(username)) {
      return "admin";
    }

    // 4. Default fallback role
    return "user";
  }

  /// Submits an admin access request and notifies the root admin
  static Future<void> requestAdmin(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString("adminRequests");
    final List requests =
    data != null ? jsonDecode(data) : [];

    // Avoid duplicate pending requests for the same user
    final alreadyRequested =
    requests.any((r) => r["username"] == username);

    if (!alreadyRequested) {
      requests.add({
        "username": username,
        "status": "pending",
        "timestamp": DateTime.now().toIso8601String(),
      });

      await prefs.setString(
        "adminRequests",
        jsonEncode(requests),
      );
    }

    // Send a notification directly to the root user
    await NotificationService.addNotification(
      username: "Axite7",
      title: "New Admin Request",
      message: "$username requested admin access",
    );
  }

  /// Approves an admin request: adds username to approvedAdmins list (used by root)
  static Future<void> approveAdmin(String username) async {
    final prefs = await SharedPreferences.getInstance();

    // Add to approved admins list in SharedPreferences
    final approvedData = prefs.getString("approvedAdmins");
    final List approvedList =
    approvedData != null ? jsonDecode(approvedData) : [];

    if (!approvedList.contains(username)) {
      approvedList.add(username);
    }

    await prefs.setString(
      "approvedAdmins",
      jsonEncode(approvedList),
    );

    // Update request entry status to "approved"
    await _updateRequestStatus(username, "approved");
  }

  /// Rejects an admin request by updating its status to "rejected" (used by root)
  static Future<void> rejectAdmin(String username) async {
    await _updateRequestStatus(username, "rejected");
  }

  /// Helper to update the status of a request in the "adminRequests" list
  static Future<void> _updateRequestStatus(
      String username, String status) async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString("adminRequests");
    final List requests =
    data != null ? jsonDecode(data) : [];

    for (var r in requests) {
      if (r["username"] == username) {
        r["status"] = status;
      }
    }

    await prefs.setString(
      "adminRequests",
      jsonEncode(requests),
    );
  }
}