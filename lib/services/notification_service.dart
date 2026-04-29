import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {

  static Future<void> addNotification({
    required String username,
    required String title,
    required String message,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> targets = [];

    if (username == "all") {
      final users = prefs.getStringList("users") ?? [];

      targets = users.map((e) {
        final u = jsonDecode(e);
        return u["username"].toString();
      }).toList();

      // 🔥 root add
      if (!targets.contains("Axite7")) {
        targets.add("Axite7");
      }

    } else {
      // 🔥 THIS WAS MISSING (main bug)
      targets = [username];
    }

    for (String user in targets) {
      final key = "notifications_$user";

      final data = prefs.getString(key);
      List notifications = data != null ? jsonDecode(data) : [];

      notifications.insert(0, {
        "title": title,
        "message": message,
        "read": false,
        "time": DateTime.now().toIso8601String(),
      });

      await prefs.setString(key, jsonEncode(notifications));
    }
  }

  static Future<List> getNotifications(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString("notifications_$username");
    return data != null ? jsonDecode(data) : [];
  }

  static Future<void> removeNotification(String username, int index) async {
    final prefs = await SharedPreferences.getInstance();

    final key = "notifications_$username";
    final data = prefs.getString(key);

    List notifications = data != null ? jsonDecode(data) : [];

    if (index >= 0 && index < notifications.length) {
      notifications.removeAt(index);
      await prefs.setString(key, jsonEncode(notifications));
    }
  }

  static Future<void> markAllRead(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final key = "notifications_$username";
    final data = prefs.getString(key);

    List notifications = data != null ? jsonDecode(data) : [];

    for (var n in notifications) {
      n["read"] = true;
    }

    await prefs.setString(key, jsonEncode(notifications));
  }
}