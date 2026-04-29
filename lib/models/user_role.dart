import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:college_app/services/notification_service.dart';

/// Handles role management for users:
/// - Root user
/// - Admin approvals
/// - Admin requests
class UserRole {
  static const String _rootUsername = "Axite7";

  /// Returns role of a user: root / admin / user
  static Future<String> getRole(String username) async {
    final prefs = await SharedPreferences.getInstance();

    // Root user check
    if (username == _rootUsername) {
      return "root";
    }

    // Fetch approved admins list
    final approvedData = prefs.getString("approvedAdmins");
    final List approvedList =
    approvedData != null ? jsonDecode(approvedData) : [];

    // Check if user is approved admin
    if (approvedList.contains(username)) {
      return "admin";
    }

    return "user";
  }

  /// Sends admin access request
  static Future<void> requestAdmin(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString("adminRequests");
    final List requests =
    data != null ? jsonDecode(data) : [];

    // Avoid duplicate requests
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
    await NotificationService.addNotification(
      username: "Axite7", // 🔥 root ko
      title: "New Admin Request",
      message: "$username requested admin access",
    );
  }

  /// Approves admin request (used by root)
  static Future<void> approveAdmin(String username) async {
    final prefs = await SharedPreferences.getInstance();

    // Update approved admins
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

    // Update request status
    await _updateRequestStatus(username, "approved");
  }

  /// Rejects admin request (used by root)
  static Future<void> rejectAdmin(String username) async {
    await _updateRequestStatus(username, "rejected");
  }

  /// Internal helper to update request status
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