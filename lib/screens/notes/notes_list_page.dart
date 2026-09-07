// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:college_app/services/notification_service.dart';

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

  List approvedNotes = [];
  String role = "user";
  String username = "";

  List<String> dummyNotes = [
    "Module 1 Notes.pdf",
    "Important Questions.pdf",
    "PYQs.pdf",
  ];

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
    loadData();
  }

  // Loads approved notes from SharedPreferences and filters them by subject, year, and branch
  Future loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final approved = prefs.getString("approvedNotes");
    List allNotes = approved != null ? jsonDecode(approved) : [];

    setState(() {
      // Filter to only approved notes matching this subject, academic year, and branch
      approvedNotes = allNotes.where((n) =>
      n["subject"] == widget.subject &&
          n["year"] == widget.year &&
          n["branch"] == widget.branch
      ).toList();

      role = prefs.getString("role") ?? "user";
      username = prefs.getString("currentUser") ?? "";
    });
  }

  // File picker for uploading PDF notes:
  // - Admins/Root: Upload directly into approvedNotes and notify root
  // - Students: Upload to pendingNotes for admin review and notify student
  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();

      final fileName = result.files.single.name;
      final filePath = result.files.single.path;

      Map note = {
        "title": fileName,
        "path": filePath,
        "uploadedBy": username,
        "subject": widget.subject,
        "year": widget.year,
        "branch": widget.branch,
      };

      if (role == "admin" || role == "root") {
        // Direct approval for admins
        final approvedData = prefs.getString("approvedNotes");
        List approved =
        approvedData != null ? jsonDecode(approvedData) : [];

        approved.add(note);

        await prefs.setString("approvedNotes", jsonEncode(approved));
        loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Note added")),
        );
        await NotificationService.addNotification(
          username: "root",
          title: "New Note Uploaded",
          message: "$username uploaded ${widget.subject} notes",
        );
      } else {
        // Submit to pending approval queue for regular students
        final data = prefs.getString("pendingNotes");
        List pending = data != null ? jsonDecode(data) : [];

        pending.add(note);

        await prefs.setString("pendingNotes", jsonEncode(pending));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sent for approval")),
        );
        await NotificationService.addNotification(
          username: username,
          title: "Note Submitted",
          message: "Your ${widget.subject} notes sent for approval",
        );
      }
    }
  }

  // Opens a local PDF file using the default system PDF viewer
  void openPDF(String path) async {
    await OpenFilex.open(path);
  }

  // Admin action: deletes an approved note from SharedPreferences
  Future deleteNote(int index) async {
    if (role != "admin" && role != "root") return;

    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString("approvedNotes");
    List allNotes = data != null ? jsonDecode(data) : [];

    allNotes.removeWhere((n) =>
    n["title"] == approvedNotes[index]["title"] &&
        n["path"] == approvedNotes[index]["path"]);

    await prefs.setString("approvedNotes", jsonEncode(allNotes));

    loadData();
  }

  // Removes a dummy sample note from the local UI list
  void deleteDummy(int index) {
    if (role != "admin" && role != "root") return;

    setState(() {
      dummyNotes.removeAt(index);
    });
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
              color: color.withValues(alpha: 0.35),
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
            if (role == "admin" || role == "root")
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

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                ...List.generate(dummyNotes.length, (index) {
                  return buildCard(
                    title: dummyNotes[index],
                    color: colors[index % colors.length],
                    onDelete: () => deleteDummy(index),
                  );
                }),

                const SizedBox(height: 10),

                ...List.generate(approvedNotes.length, (index) {
                  final note = approvedNotes[index];

                  return buildCard(
                    title: note["title"],
                    color: colors[(index + 1) % colors.length],
                    onTap: () => openPDF(note["path"]),
                    onDelete: () => deleteNote(index),
                  );
                }),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A6CF7),
        onPressed: pickPDF,
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}