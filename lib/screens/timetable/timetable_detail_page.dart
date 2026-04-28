import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

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

  File? file;

  String get keyName =>
      "file_${widget.semester}_${widget.type}";

  @override
  void initState() {
    super.initState();
    loadFile();
  }

  Future<void> loadFile() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(keyName);

    if (path != null) {
      final f = File(path);
      if (await f.exists()) {
        setState(() {
          file = f;
        });
      }
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result == null) return;

    final originalPath = result.files.single.path;
    if (originalPath == null) return;

    final pickedFile = File(originalPath);

    final dir = await getApplicationDocumentsDirectory();

    final fileName =
        "sem${widget.semester}_${widget.type}.${pickedFile.path.split('.').last}";

    final newFile = await pickedFile.copy("${dir.path}/$fileName");

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyName, newFile.path);

    setState(() {
      file = newFile;
    });
  }

  Future<void> deleteFile() async {
    if (file != null && await file!.exists()) {
      await file!.delete();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyName);

    setState(() {
      file = null;
    });
  }

  void shareFile() {
    if (file != null) {
      Share.shareXFiles([XFile(file!.path)]);
    }
  }

  // 🔵 SAME ROUNDED HEADER STYLE
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

          IconButton(
            onPressed: deleteFile,
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget viewer() {
    if (file == null) {
      return const Center(
        child: Text("No file uploaded"),
      );
    }

    if (file!.path.endsWith(".pdf")) {
      return PDFView(
        filePath: file!.path,
      );
    }

    return InteractiveViewer(
      child: Image.file(file!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      body: Column(
        children: [

          buildHeader(),

          Expanded(child: viewer()),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6CF7),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: pickFile,
                child: const Text(
                  "Upload Timetable",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}