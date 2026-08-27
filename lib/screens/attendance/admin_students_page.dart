import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'student_attendance_detail_page.dart';

class AdminStudentsPage extends StatefulWidget {
  final String year;
  final String branch;

  const AdminStudentsPage({
    super.key,
    required this.year,
    required this.branch,
  });

  @override
  State<AdminStudentsPage> createState() => _AdminStudentsPageState();
}

class _AdminStudentsPageState extends State<AdminStudentsPage> {

  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];

  final searchController = TextEditingController();

  final gradients = [
    [Color(0xFF4A6CF7), Color(0xFF6A8DFF)],
    [Color(0xFF43A047), Color(0xFF66BB6A)],
    [Color(0xFFE53935), Color(0xFFEF5350)],
    [Color(0xFFFF9800), Color(0xFFFFB74D)],
    [Color(0xFF673AB7), Color(0xFF9575CD)],
    [Color(0xFF009688), Color(0xFF4DB6AC)],
  ];

  @override
  void initState() {
    super.initState();
    loadStudents();

    searchController.addListener(() {
      filterStudents();
    });
  }

  Future loadStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList("users") ?? [];

    List<Map<String, dynamic>> filtered = [];

    for (var u in users) {
      final data = jsonDecode(u);
      final username = data["username"];

      final userYear = prefs.getString("year_$username");
      final userBranch = prefs.getString("branch_$username");

      if (userYear == widget.year &&
          userBranch == widget.branch) {

        filtered.add({
          "username": username,
          "displayName":
          prefs.getString("displayName_$username") ?? username,
          "roll":
          prefs.getString("enrollment_$username") ?? "",
          "image":
          prefs.getString("profilePic_$username"),
        });
      }
    }

    setState(() {
      students = filtered;
      filteredStudents = filtered;
    });
  }

  void filterStudents() {
    final query = searchController.text.toLowerCase();

    final result = students.where((s) {
      return s["displayName"].toLowerCase().contains(query) ||
          s["username"].toLowerCase().contains(query) ||
          s["roll"].toLowerCase().contains(query);
    }).toList();

    setState(() {
      filteredStudents = result;
    });
  }

  Widget header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 25),
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
          Text(
            "${widget.year} - ${widget.branch}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search student...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget studentCard(Map<String, dynamic> student, int index) {

    final gradient = gradients[index % gradients.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentAttendanceDetailPage(
              username: student["username"],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),

        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                backgroundImage: student["image"] != null
                    ? FileImage(File(student["image"]))
                    : null,
                child: student["image"] == null
                    ? const Icon(Icons.person, color: Colors.black)
                    : null,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    student["displayName"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "@${student["username"]}",
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Enrollment: ${student["roll"]}",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No students found",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        top: false,
        child: Column(
          children: [

            header(context),

            searchBar(),

            Expanded(
              child: filteredStudents.isEmpty
                  ? emptyState()
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  return studentCard(filteredStudents[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}