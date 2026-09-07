import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:college_app/models/user_role.dart';
import 'package:college_app/services/attendance_service.dart';
import 'package:college_app/screens/attendance/today_attendance_page.dart';

class AttendancePage extends StatefulWidget {
  final String username;

  const AttendancePage({super.key, required this.username});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {

  bool isRoleLoaded = false;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  Map<DateTime, String> attendanceMap = {};

  String role = "user";

  DateTime norm(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    loadAttendance();
    loadRole();
  }

  // Fetches the user's role to conditionally show admin tools (e.g. View Today's Attendance)
  Future loadRole() async {
    final r = await UserRole.getRole(widget.username);

    debugPrint("USERNAME: ${widget.username}");
    debugPrint("ROLE: $r");

    if (!mounted) return;
    setState(() {
      role = r;
      isRoleLoaded = true;
    });
  }

  // Loads attendance records for this student and maps each date to its status ("present" / "rejected")
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

  // Requests GPS permissions and returns latitude,longitude string
  Future<String> getLocation() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return "Disabled";
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return "Denied";
    }

    final pos = await Geolocator.getCurrentPosition();
    return "${pos.latitude},${pos.longitude}";
  }

  // Validates current date, captures camera selfie, gets GPS, and saves attendance
  Future markAttendance() async {

    final today = norm(DateTime.now());

    // Only allow marking attendance for the current calendar day
    if (norm(selectedDay) != today) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only today's attendance allowed")),
      );
      return;
    }

    // Capture camera selfie
    final image =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;

    // Fetch GPS coordinates
    final location = await getLocation();

    // Save attendance entry through AttendanceService
    await AttendanceService.markAttendance(
      username: widget.username,
      date: today.toIso8601String(),
      image: image.path,
      location: location,
    );

    // Save current formatted time into the record in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final time =
        "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    final data = prefs.getString("attendance_data");
    Map all = data != null ? jsonDecode(data) : {};

    final userKey =
        "${widget.username}_${prefs.getString("year_${widget.username}")}_${prefs.getString("branch_${widget.username}")}";

    List list = all[userKey] ?? [];

    for (var e in list) {
      if (e["date"] == today.toIso8601String()) {
        e["time"] = time;
      }
    }

    all[userKey] = list;
    await prefs.setString("attendance_data", jsonEncode(all));

    // Refresh local calendar map
    await loadAttendance();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Attendance marked")),
    );
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
            "Attendance",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ],
      ),
    );
  }

  // 🔥 DAY UI FIXED
  Widget buildDay(DateTime day,
      {bool isToday = false, bool isSelected = false}) {

    final d = norm(day);
    String? status = attendanceMap[d];

    bool isSunday = day.weekday == DateTime.sunday;

    Color bg = Colors.transparent;

    if (status == "present") {
      bg = Colors.green;
    } else if (status == "rejected") {
      bg = Colors.purple;
    } else if (isSunday) {
      bg = Colors.red; // 🔥 SUNDAY COLOR
    }

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,

        border: isToday
            ? Border.all(
            color: const Color(0xFF4A6CF7), width: 2)
            : null,

        boxShadow: isSelected
            ? [
          BoxShadow(
            color: const Color(0xFF4A6CF7).withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ]
            : [],
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

            TableCalendar(
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2030),
              focusedDay: focusedDay,

              selectedDayPredicate: (day) =>
              norm(day) == norm(selectedDay),

              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                });
              },

              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),

              calendarBuilders: CalendarBuilders(

                dowBuilder: (context, day) {
                  if (day.weekday == DateTime.sunday) {
                    return const Center(
                      child: Text(
                        "Sun",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  return null;
                },

                defaultBuilder: (context, day, _) =>
                    buildDay(day),

                todayBuilder: (context, day, _) =>
                    buildDay(day, isToday: true),

                selectedBuilder: (context, day, _) =>
                    buildDay(day, isSelected: true),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6CF7),
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 14),
              ),
              onPressed: markAttendance,
              child: const Text(
                "Mark Attendance",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 12),

            // 🔥 ADMIN BUTTON
            if (isRoleLoaded && (role == "admin" || role == "root"))
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TodayAttendancePage(),
                    ),
                  );
                },
                child: const Text(
                  "View Today's Attendance",
                  style: TextStyle(color: Colors.white),
                ),
              ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}