import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:college_app/services/attendance_service.dart';
import 'package:college_app/services/notification_service.dart';

class StudentAttendanceDetailPage extends StatefulWidget {
  final String username;

  const StudentAttendanceDetailPage({
    super.key,
    required this.username,
  });

  @override
  State<StudentAttendanceDetailPage> createState() =>
      _StudentAttendanceDetailPageState();
}

class _StudentAttendanceDetailPageState
    extends State<StudentAttendanceDetailPage> {

  Map<DateTime, String> attendanceMap = {};

  String displayName = "";
  String roll = "";
  String branch = "";
  String year = "";
  String? imagePath;

  DateTime focusedDay = DateTime.now();

  DateTime norm(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    loadProfile();
    loadAttendance();
  }

  Future loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final u = widget.username;

    setState(() {
      displayName = prefs.getString("displayName_$u") ?? u;
      roll = prefs.getString("enrollment_$u") ?? ""; // 🔥 FIXED
      branch = prefs.getString("branch_$u") ?? "";
      year = prefs.getString("year_$u") ?? "";
      imagePath = prefs.getString("profilePic_$u");
    });
  }

  Future loadAttendance() async {
    final data =
    await AttendanceService.getUserAttendance(widget.username);

    Map<DateTime, String> map = {};

    for (var e in data) {
      final d = norm(DateTime.parse(e["date"]));
      map[d] = e["status"];
    }

    setState(() {
      attendanceMap = map;
    });
  }

  // 🔥 CONFIRM REJECT
  Future rejectAttendance(DateTime day) async {

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Attendance"),
        content: const Text("Are you sure you want to mark absent?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {

              Navigator.pop(context);

              final date = norm(day).toIso8601String();

              await AttendanceService.markAbsent(
                username: widget.username,
                date: date,
              );

              await NotificationService.addNotification(
                username: widget.username,
                title: "Attendance Rejected",
                message:
                "Your attendance on ${day.day}-${day.month}-${day.year} was rejected",
              );

              await loadAttendance();
            },
            child: const Text("Reject"),
          )
        ],
      ),
    );
  }

  // 🔥 HEADER
  Widget header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A6CF7), Color(0xFF6A8DFF)],
        ),
        borderRadius:
        BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text(
            "Student Dashboard",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ],
      ),
    );
  }

  // 🔥 PROFILE CARD (SEXY)
  Widget profileCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A6CF7), Color(0xFF6A8DFF)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10)
        ],
      ),
      child: Row(
        children: [

          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            backgroundImage:
            imagePath != null ? FileImage(File(imagePath!)) : null,
            child: imagePath == null
                ? const Icon(Icons.person)
                : null,
          ),

          const SizedBox(width: 14),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Text("@${widget.username}",
                  style: const TextStyle(color: Colors.white70)),
              Text("Enrollment: $roll",
                  style: const TextStyle(color: Colors.white)),
              Text("$branch | $year",
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  // 🔥 CALENDAR CELL
  Widget buildDay(DateTime day) {

    final d = norm(day);
    String? status = attendanceMap[d];

    Color bg = Colors.transparent;

    if (status == "present") {
      bg = Colors.green;
    } else if (status == "absent") {
      bg = Colors.purple; // 🔥 violet
    }

    return GestureDetector(
      onTap: () {
        if (status == "present") {
          rejectAttendance(day);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            "${day.day}",
            style: TextStyle(
              color: bg == Colors.transparent
                  ? Colors.black
                  : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 MONTH BASED COUNT
  int getMonthlyPresentCount() {
    int count = 0;

    for (var entry in attendanceMap.entries) {
      final d = entry.key;

      if (d.month == focusedDay.month &&
          d.year == focusedDay.year &&
          entry.value == "present") {
        count++;
      }
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      body: Column(
        children: [

          header(),

          profileCard(),

          Expanded(
            child: Column(
              children: [

                TableCalendar(
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.utc(2030),
                  focusedDay: focusedDay,

                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),

                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, _) =>
                        buildDay(day),
                    todayBuilder: (context, day, _) =>
                        buildDay(day),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ],
                  ),
                  child: Text(
                    "Present This Month: ${getMonthlyPresentCount()}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}