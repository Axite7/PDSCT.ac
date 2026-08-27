import 'dart:io';
import 'package:flutter/material.dart';
import 'package:college_app/services/attendance_service.dart';
import 'package:college_app/services/notification_service.dart';
import 'package:intl/intl.dart';

class TodayAttendancePage extends StatefulWidget {
  const TodayAttendancePage({super.key});

  @override
  State<TodayAttendancePage> createState() =>
      _TodayAttendancePageState();
}

class _TodayAttendancePageState extends State<TodayAttendancePage> {

  List todayList = [];

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
    loadToday();
  }

  Future loadToday() async {
    final data = await AttendanceService.getTodayAttendance();

    setState(() {
      todayList = data;
    });
  }

  // 🔥 REJECT
  Future reject(Map student) async {

    await AttendanceService.markAbsent(
      username: student["username"],
      date: student["date"],
    );

    await NotificationService.addNotification(
      username: student["username"],
      title: "Attendance Rejected",
      message: "Your attendance for today was rejected",
    );

    await loadToday();
  }

  // 🔵 HEADER
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
          const Text(
            "Today's Attendance",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ],
      ),
    );
  }

  // 🔥 CARD
  Widget studentCard(Map s, int index) {

    final gradient = gradients[index % gradients.length];

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => detailSheet(s),
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
              color: gradient[0].withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),

        child: Row(
          children: [

            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              backgroundImage:
              s["image"] != null ? FileImage(File(s["image"])) : null,
              child: s["image"] == null
                  ? const Icon(Icons.person)
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s["displayName"],
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  Text("@${s["username"]}",
                      style: const TextStyle(color: Colors.white70)),
                  Text("Enroll: ${s["enrollment"]}",
                      style: const TextStyle(color: Colors.white)),
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

  // 🔥 DETAIL SHEET (FULL SAFE VERSION)
  Widget detailSheet(Map s) {

    // 🔥 SAFE LOCATION PARSE
    String lat = "";
    String lng = "";

    if (s["location"] != null &&
        s["location"].toString().contains(",")) {

      final parts = s["location"].split(",");

      if (parts.length >= 2) {
        lat = parts[0];
        lng = parts[1];
      }
    }

    // 🔥 SAFE TIME
    String time = "N/A";
    try {
      if (s["time"] != null) {
        time = DateFormat("hh:mm a")
            .format(DateTime.parse(s["time"]));
      }
    } catch (_) {}

    // 🔥 MAP URL (NO CRASH)
    String mapUrl = "";
    if (lat.isNotEmpty && lng.isNotEmpty) {
      mapUrl =
      "https://maps.googleapis.com/maps/api/staticmap"
          "?center=$lat,$lng"
          "&zoom=15"
          "&size=600x300"
          "&markers=color:red|$lat,$lng";
      // 👉 optionally add: &key=YOUR_API_KEY
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Text(s["displayName"],
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          Text("@${s["username"]}"),
          Text("Enrollment: ${s["enrollment"]}"),
          Text("${s["branch"]} • ${s["year"]}"),

          const SizedBox(height: 10),

          // 🕒 TIME
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 5),
              Text(time),
            ],
          ),

          const SizedBox(height: 10),

          // 📸 IMAGE
          if (s["image"] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(s["image"]), height: 180),
            ),

          const SizedBox(height: 10),

          // 📍 MAP SAFE
          if (mapUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                mapUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            const Text("Location not available"),

          const SizedBox(height: 10),

          if (lat.isNotEmpty)
            Text("Lat: $lat, Lng: $lng"),

          const SizedBox(height: 15),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              reject(s);
            },
            child: const Text("Reject Attendance",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget empty() {
    return const Center(
      child: Text("No attendance marked today"),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      body: SafeArea(
        top: false,
        child: Column(
          children: [

            header(),

            Expanded(
              child: todayList.isEmpty
                  ? empty()
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: todayList.length,
                itemBuilder: (context, index) {
                  return studentCard(todayList[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}