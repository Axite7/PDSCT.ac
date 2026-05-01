// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:college_app/services/firestore_service.dart';
import 'package:college_app/services/storage_service.dart';
import 'package:college_app/services/notification_service.dart';
import 'package:college_app/services/auth_service.dart';

class NotesListPage extends StatefulWidget {
  final String subject;
  final String year;
  final String branch;

  const NotesListPage({
    super.key,
    required this.subject,
    required this.year,
    required this.branch,
  });

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {

  String role = "user";
  String uid = "";
  bool isUploading = false;

  final colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.deepPurple,
  ];

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future _loadRole() async {
    final r = await AuthService.getUserRole();
    if (mounted) {
      setState(() {
        role = r;
        uid = AuthService.currentUid ?? '';
      });
    }
  }

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => isUploading = true);

      try {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        // Upload to Firebase Storage
        final fileUrl = await StorageService.uploadNotePDF(file);

        // Determine status based on role
        final status = (role == "admin" || role == "root")
            ? 'approved'
            : 'pending';

        // Save to Firestore
        await FirestoreService.uploadNote(
          title: fileName,
          fileUrl: fileUrl,
          subject: widget.subject,
          year: widget.year,
          branch: widget.branch,
          uploadedBy: uid,
          status: status,
        );

        if (status == 'approved') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Note added")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sent for approval")),
          );
          await NotificationService.addNotification(
            username: uid,
            title: "Note Submitted",
            message: "Your ${widget.subject} notes sent for approval",
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      } finally {
        if (mounted) setState(() => isUploading = false);
      }
    }
  }

  Future<void> deleteNote(String noteId, String fileUrl) async {
    if (role != "admin" && role != "root") return;

    await StorageService.deleteFileByUrl(fileUrl);
    await FirestoreService.deleteNote(noteId);
  }

  Widget buildHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 45, 16, 25),
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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard({
    required String title,
    required Color color,
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf,
                color: Colors.white, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if ((role == "admin" || role == "root") && onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      body: Column(
        children: [
          buildHeader(widget.subject),

          if (isUploading)
            const LinearProgressIndicator(),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService.streamApprovedNotes(
                subject: widget.subject,
                year: widget.year,
                branch: widget.branch,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text("No notes available yet"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final noteId = docs[index].id;

                    return buildCard(
                      title: data['title'] ?? 'Untitled',
                      color: colors[index % colors.length],
                      onTap: () {
                        // Open PDF URL in browser
                        final url = data['fileUrl'] ?? '';
                        if (url.isNotEmpty) {
                          launchUrl(Uri.parse(url),
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      onDelete: () => deleteNote(
                        noteId,
                        data['fileUrl'] ?? '',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A6CF7),
        onPressed: isUploading ? null : pickPDF,
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}