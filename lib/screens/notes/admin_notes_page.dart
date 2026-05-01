import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:college_app/services/firestore_service.dart';
import 'package:college_app/services/notification_service.dart';
import 'package:college_app/services/storage_service.dart';
import 'package:college_app/services/auth_service.dart';

class AdminNotesPage extends StatelessWidget {
  const AdminNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      body: Column(
        children: [
          _buildHeader(context),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService.streamPendingNotes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(child: Text("No pending notes"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final noteId = docs[index].id;

                    return _buildCard(context, data, noteId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            "Pending Notes",
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

  Widget _buildCard(BuildContext context, Map<String, dynamic> note, String noteId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            note["title"] ?? "No Title",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                "Subject: ${note['subject'] ?? 'Unknown'}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            "${note['branch'] ?? ''} - ${note['year'] ?? ''} Year",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  final url = note['fileUrl'] ?? '';
                  if (url.isNotEmpty) {
                    launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text("View"),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green),
                onPressed: () async {
                  final uid = AuthService.currentUid ?? '';
                  await FirestoreService.approveNote(noteId, uid);

                  await NotificationService.addNotification(
                    username: note['uploadedBy'] ?? '',
                    title: "Note Approved",
                    message: "${note['title']} approved by admin",
                  );
                },
                child: const Text("Approve",
                    style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red),
                onPressed: () async {
                  await FirestoreService.rejectNote(noteId);

                  // Delete file from storage
                  if (note['fileUrl'] != null) {
                    await StorageService.deleteFileByUrl(note['fileUrl']);
                  }

                  await NotificationService.addNotification(
                    username: note['uploadedBy'] ?? '',
                    title: "Note Rejected",
                    message: "${note['title']} was rejected",
                  );
                },
                child: const Text("Reject",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }
}