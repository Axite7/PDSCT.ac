import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../models/user_role.dart';
import '../../services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  List requests = [];
  List notifications = [];
  String role = "";
  String username = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // Loads notifications for the current user and admin requests for root, then marks all notifications as read
  Future loadData() async {
    final prefs = await SharedPreferences.getInstance();

    username = prefs.getString("currentUser") ?? "";
    role = await UserRole.getRole(username);

    // Fetch user-specific notifications
    notifications = await NotificationService.getNotifications(username);

    // Fetch admin access requests (visible to root)
    final data = prefs.getString("adminRequests");
    requests = data != null ? jsonDecode(data) : [];

    // Mark current user's notifications as read
    await NotificationService.markAllRead(username);

    setState(() {});
  }

  // Root action: approves a user's admin request and sends them a notification
  Future approve(String username) async {
    await UserRole.approveAdmin(username);

    await NotificationService.addNotification(
      username: username,
      title: "Admin Access Granted",
      message: "You are now an admin",
    );

    await loadData();
  }

  // Root action: rejects a user's admin request and sends them a notification
  Future reject(String username) async {
    await UserRole.rejectAdmin(username);

    await NotificationService.addNotification(
      username: username,
      title: "Admin Request Rejected",
      message: "Your admin request was rejected",
    );

    await loadData();
  }

  // Root action: revokes admin access from a user and updates status to "removed"
  Future removeAdmin(String user) async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString("approvedAdmins");
    List admins = data != null ? jsonDecode(data) : [];
    admins.remove(user);

    await prefs.setString("approvedAdmins", jsonEncode(admins));

    // Update request entry status to "removed"
    final reqData = prefs.getString("adminRequests");
    List reqs = reqData != null ? jsonDecode(reqData) : [];

    for (var r in reqs) {
      if (r["username"] == user) {
        r["status"] = "removed";
      }
    }

    await prefs.setString("adminRequests", jsonEncode(reqs));

    await NotificationService.addNotification(
      username: user,
      title: "Admin Removed",
      message: "You have been removed as admin",
    );

    await loadData();
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A6CF7), Color(0xFF6A8CFF)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          const Text(
            "Notifications",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A6CF7), Color(0xFF6A8CFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminCard(Map req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFF4A6CF7),
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                req["username"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (req["status"] == "pending")
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => approve(req["username"]),
                  child: const Text("Approve"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => reject(req["username"]),
                  child: const Text("Reject"),
                ),
              ],
            )
          else if (req["status"] == "approved")
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () => removeAdmin(req["username"]),
              child: const Text("Remove Admin"),
            )
          else
            Text("Status: ${req["status"]}"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      body: Column(
        children: [
          _header(context),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // 🔥 GENERAL SECTION (for root)
                if (role == "root" && notifications.isNotEmpty) ...[
                  const Text(
                    "General Notifications",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                ],

                // 🔥 EMPTY STATE
                if (notifications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        "No new notifications",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                // 🔥 NOTIFICATIONS
                ...List.generate(notifications.length, (index) {
                  final n = notifications[index];

                  return Dismissible(
                    key: Key(n["time"]),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) async {
                      final actualIndex = notifications.indexOf(n);
                      await NotificationService.removeNotification(username, actualIndex);
                      await loadData();
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: _card(
                      title: n["title"],
                      subtitle: n["message"],
                    ),
                  );
                }),

                // 🔥 ADMIN REQUEST SECTION
                if (role == "root") ...[
                  const SizedBox(height: 20),
                  const Text(
                    "Admin Requests",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...requests.map((req) => _adminCard(req)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}