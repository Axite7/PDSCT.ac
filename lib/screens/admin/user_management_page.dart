import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:college_app/services/firestore_service.dart';
import 'package:college_app/services/notification_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      body: Column(
        children: [
          _header(context),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService.streamAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data?.docs ?? [];

                // Filter by search
                if (searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final data = doc.data();
                    final name = (data['displayName'] ?? '').toLowerCase();
                    final email = (data['email'] ?? '').toLowerCase();
                    final username = (data['username'] ?? '').toLowerCase();
                    return name.contains(searchQuery) ||
                        email.contains(searchQuery) ||
                        username.contains(searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final userId = docs[index].id;
                    return _userCard(data, userId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A6CF7), Color(0xFF6A8DFF)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text(
            "User Management",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(Map<String, dynamic> data, String userId) {
    final role = data['role'] ?? 'user';
    final profilePic = data['profilePicUrl'];

    Color roleColor;
    switch (role) {
      case 'root':
        roleColor = Colors.red;
        break;
      case 'admin':
        roleColor = Colors.orange;
        break;
      default:
        roleColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            backgroundImage: profilePic != null
                ? CachedNetworkImageProvider(profilePic)
                : null,
            child: profilePic == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['displayName'] ?? data['username'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data['email'] ?? '',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (data['branch'] != null &&
                        data['branch'].toString().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(data['branch'],
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Role management popup
          if (role != 'root')
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'make_admin') {
                  await FirestoreService.updateUser(userId, {'role': 'admin'});
                  await NotificationService.addNotification(
                    username: userId,
                    title: "Admin Access Granted",
                    message: "You are now an admin",
                  );
                } else if (value == 'make_user') {
                  await FirestoreService.updateUser(userId, {'role': 'user'});
                  await NotificationService.addNotification(
                    username: userId,
                    title: "Role Changed",
                    message: "Your role has been changed to user",
                  );
                }
              },
              itemBuilder: (context) => [
                if (role == 'user')
                  const PopupMenuItem(
                    value: 'make_admin',
                    child: Text("Make Admin"),
                  ),
                if (role == 'admin')
                  const PopupMenuItem(
                    value: 'make_user',
                    child: Text("Remove Admin"),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
