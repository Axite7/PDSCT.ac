import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:open_filex/open_filex.dart';

import '../../services/notification_service.dart';

class AdminNotesPage extends StatefulWidget {
  const AdminNotesPage({super.key});

  @override
  State<AdminNotesPage> createState() => _AdminNotesPageState();
}

class _AdminNotesPageState extends State<AdminNotesPage> {
  List pending = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // Loads student-submitted pending notes awaiting administrator approval
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString("pendingNotes");
    pending = data != null ? jsonDecode(data) : [];

    setState(() {});
  }

  // Moves the note from pendingNotes to approvedNotes and notifies the student who uploaded it
  Future<void> approve(int index) async {
    final prefs = await SharedPreferences.getInstance();

    final pendingData = prefs.getString("pendingNotes");
    List pendingList = pendingData != null ? jsonDecode(pendingData) : [];

    final approvedData = prefs.getString("approvedNotes");
    List approvedList =
    approvedData != null ? jsonDecode(approvedData) : [];

    final note = pendingList[index];

    // Add note to approved list and remove from pending queue
    approvedList.add(note);
    pendingList.removeAt(index);

    await prefs.setString("approvedNotes", jsonEncode(approvedList));
    await prefs.setString("pendingNotes", jsonEncode(pendingList));

    // Send approval notification to the uploader
    await NotificationService.addNotification(
      username: note["uploadedBy"],
      title: "Note Approved",
      message: "${note["title"]} approved by admin",
    );

    // Refresh pending notes list
    await loadData();
  }

  // Rejects the note: removes it from pendingNotes and notifies the student
  Future<void> reject(int index) async {
    final prefs = await SharedPreferences.getInstance();

    final pendingData = prefs.getString("pendingNotes");
    List pendingList = pendingData != null ? jsonDecode(pendingData) : [];

    final note = pendingList[index];

    pendingList.removeAt(index);

    await prefs.setString("pendingNotes", jsonEncode(pendingList));

    // Send rejection notification to the uploader
    await NotificationService.addNotification(
      username: note["uploadedBy"],
      title: "Note Rejected",
      message: "${note["title"]} was rejected",
    );

    await loadData();
  }

  // Opens the local PDF for preview before approval
  void openFile(String path) async {
    await OpenFilex.open(path);
  }

  Widget buildHeader() {
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

  Widget buildCard(Map note, int index) {
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

          // 🔥 TITLE
          Text(
            note["title"] ?? "No Title",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          // 🔥 NEW: UPLOADER NAME
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                note["uploadedBy"] ?? "Unknown",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              ElevatedButton(
                onPressed: () => openFile(note["path"]),
                child: const Text("View"),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green),
                onPressed: () => approve(index),
                child: const Text("Approve"),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red),
                onPressed: () => reject(index),
                child: const Text("Reject"),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      body: Column(
        children: [
          buildHeader(),

          Expanded(
            child: pending.isEmpty
                ? const Center(child: Text("No pending notes"))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pending.length,
              itemBuilder: (context, index) {
                return buildCard(pending[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }
}