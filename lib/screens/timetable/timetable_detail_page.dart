import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import 'package:college_app/services/firestore_service.dart';
import 'package:college_app/services/storage_service.dart';
import 'package:college_app/services/auth_service.dart';

class TimetableDetailPage extends StatefulWidget {
  final int semester;
  final String type;

  const TimetableDetailPage({
    super.key,
    required this.semester,
    required this.type,
  });

  @override
  State<TimetableDetailPage> createState() =>
      _TimetableDetailPageState();
}

class _TimetableDetailPageState
    extends State<TimetableDetailPage> {

  String? fileUrl;
  bool isUploading = false;
  String role = 'user';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final r = await AuthService.getUserRole();
    if (mounted) setState(() => role = r);
  }

  Future<void> pickFile() async {
    if (role != 'admin' && role != 'root') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only admins can upload timetables")),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() => isUploading = true);

    try {
      final file = File(result.files.single.path!);

      // Upload to Firebase Storage
      final url = await StorageService.uploadTimetable(file);

      // Save to Firestore
      await FirestoreService.uploadTimetable(
        semester: widget.semester,
        type: widget.type,
        fileUrl: url,
        uploadedBy: AuthService.currentUid ?? '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Timetable uploaded!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Future<void> deleteFile() async {
    if (role != 'admin' && role != 'root') return;

    try {
      if (fileUrl != null) {
        await StorageService.deleteFileByUrl(fileUrl!);
      }
      await FirestoreService.deleteTimetable(widget.semester, widget.type);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Timetable deleted")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  void shareFile() {
    if (fileUrl != null) {
      Share.share(
        'Timetable for Sem ${widget.semester} - ${widget.type}\n$fileUrl',
      );
    }
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 50, 16, 20),
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

          const SizedBox(width: 5),

          Expanded(
            child: Text(
              "${widget.type} - Sem ${widget.semester}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          IconButton(
            onPressed: shareFile,
            icon: const Icon(Icons.share, color: Colors.white),
          ),

          if (role == 'admin' || role == 'root')
            IconButton(
              onPressed: deleteFile,
              icon: const Icon(Icons.delete, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget viewer(String? url) {
    if (url == null || url.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text("No timetable uploaded yet",
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    // For images, show from network
    if (url.contains('.jpg') || url.contains('.png') || url.contains('.jpeg') ||
        url.contains('image')) {
      return InteractiveViewer(
        child: CachedNetworkImage(
          imageUrl: url,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              const Center(child: Icon(Icons.error, size: 50)),
        ),
      );
    }

    // For PDFs, show download link
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 80, color: Color(0xFF4A6CF7)),
          const SizedBox(height: 16),
          const Text("PDF Timetable Uploaded",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A6CF7),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              // Open in browser
              // launchUrl(Uri.parse(url));
            },
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text("View PDF",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.streamTimetable(widget.semester, widget.type),
        builder: (context, snapshot) {
          fileUrl = snapshot.data?.data()?['fileUrl'];

          return Column(
            children: [

              buildHeader(),

              if (isUploading)
                const LinearProgressIndicator(),

              Expanded(child: viewer(fileUrl)),

              if (role == 'admin' || role == 'root')
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A6CF7),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isUploading ? null : pickFile,
                      child: const Text(
                        "Upload Timetable",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}