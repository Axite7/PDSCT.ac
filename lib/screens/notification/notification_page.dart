import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:college_app/services/auth_service.dart';
import 'package:college_app/services/firestore_service.dart';
import 'package:college_app/services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  String role = "";
  String uid = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future _loadData() async {
    uid = AuthService.currentUid ?? '';
    role = await AuthService.getUserRole();

    // Mark all as read
    await FirestoreService.markAllNotificationsRead(uid);

    if (mounted) setState(() {});
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

  Widget _adminRequestCard(Map<String, dynamic> req, String reqId) {
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
                req["username"] ?? "Unknown",
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
                  onPressed: () async {
                    await FirestoreService.approveAdminRequest(
                      req['userId'],
                      uid,
                    );

                    await NotificationService.addNotification(
                      username: req['userId'],
                      title: "Admin Access Granted",
                      message: "You are now an admin",
                    );
                  },
                  child: const Text("Approve",
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    await FirestoreService.rejectAdminRequest(
                      req['userId'],
                      uid,
                    );

                    await NotificationService.addNotification(
                      username: req['userId'],
                      title: "Admin Request Rejected",
                      message: "Your admin request was rejected",
                    );
                  },
                  child: const Text("Reject",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          else if (req["status"] == "approved")
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                await FirestoreService.removeAdmin(req['userId']);

                await NotificationService.addNotification(
                  username: req['userId'],
                  title: "Admin Removed",
                  message: "You have been removed as admin",
                );
              },
              child: const Text("Remove Admin",
                  style: TextStyle(color: Colors.white)),
            )
          else
            Text("Status: ${req['status']}",
                style: const TextStyle(color: Colors.grey)),
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

                // Notifications stream
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirestoreService.streamNotifications(uid),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                          child: Text(
                            "No new notifications",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (role == "root") ...[
                          const Text(
                            "General Notifications",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                        ],

                        ...docs.map((doc) {
                          final data = doc.data();
                          return Dismissible(
                            key: Key(doc.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) async {
                              await FirestoreService.deleteNotification(
                                uid,
                                doc.id,
                              );
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: _card(
                              title: data['title'] ?? '',
                              subtitle: data['message'] ?? '',
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),

                // Admin requests (root only)
                if (role == "root") ...[
                  const SizedBox(height: 20),
                  const Text(
                    "Admin Requests",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirestoreService.streamAdminRequests(),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return const Text("No admin requests",
                            style: TextStyle(color: Colors.grey));
                      }

                      return Column(
                        children: docs.map((doc) {
                          return _adminRequestCard(doc.data(), doc.id);
                        }).toList(),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}