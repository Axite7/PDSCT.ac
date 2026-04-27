import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

class NotesListPage extends StatefulWidget {
  final String subject;

  const NotesListPage({super.key, required this.subject});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  List<File> uploadedNotes = [];

  // 🎨 ORIGINAL COLOR PALETTE (same as subjects)
  final colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.deepPurple,
  ];

  final dummyNotes = [
    "Module 1 Notes.pdf",
    "Important Questions.pdf",
    "PYQs.pdf",
  ];

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      setState(() {
        uploadedNotes.add(file);
      });
    }
  }

  void openPDF(File file) async {
    await OpenFilex.open(file.path);
  }

  // 🔥 HEADER (same gradient as rest of app)
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
    VoidCallback? onDownload,
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
            IconButton(
              onPressed: onDownload,
              icon: const Icon(Icons.download, color: Colors.white),
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

                // 🔵 DUMMY PDFs
                ...List.generate(dummyNotes.length, (index) {
                  return buildCard(
                    title: dummyNotes[index],
                    color: colors[index % colors.length],

                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Dummy PDF"),
                        ),
                      );
                    },

                    onDownload: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Dummy download"),
                        ),
                      );
                    },
                  );
                }),

                const SizedBox(height: 10),

                // 🔥 UPLOADED PDFs
                ...List.generate(uploadedNotes.length, (index) {
                  final file = uploadedNotes[index];

                  return buildCard(
                    title: file.path.split('/').last,
                    color: colors[(index + 1) % colors.length],

                    onTap: () => openPDF(file),

                    onDownload: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Already on device"),
                        ),
                      );
                    },
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