import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

import 'package:college_app/screens/notification/notification_page.dart';
import 'package:college_app/screens/profile/profile_page.dart';
import 'package:college_app/screens/events/events_page.dart';
import 'package:college_app/screens/notes/notes_page.dart';
import 'package:college_app/screens/attendance/attendance_page.dart';
import 'package:college_app/screens/timetable/timetable_page.dart';
import 'package:college_app/models/user_role.dart';
import 'package:college_app/screens/attendance/admin_attendance_year_page.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {

  String? imagePath;
  String username = "";
  String displayName = "";
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    loadUserData();
    loadNotificationCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadNotificationCount();
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    String currentUser =
        prefs.getString("currentUser") ?? widget.userName;

    String? storedDisplay =
    prefs.getString("displayName_$currentUser");

    setState(() {
      username = currentUser;

      displayName = (storedDisplay != null && storedDisplay.isNotEmpty)
          ? storedDisplay
          : currentUser;

      imagePath = prefs.getString("profilePic_$currentUser");
    });
  }

  Future<void> loadNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();

    final currentUser = prefs.getString("currentUser");

    if (currentUser == null || currentUser.isEmpty) return;

    final data = prefs.getString("notifications_$currentUser");

    List list = data != null ? jsonDecode(data) : [];

    int unread = list.where((n) => n["read"] == false).length;

    setState(() {
      notificationCount = unread;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      body: SingleChildScrollView(
        child: Column(
          children: [
            topHeader(context),
            sectionTitle(),

            buildCard(
              context,
              "Events",
              "Stay updated with all college events",
              Icons.calendar_month,
              Colors.blue,
            ),

            buildCard(
              context,
              "Notes",
              "Access and download study materials",
              Icons.menu_book,
              Colors.orange,
            ),

            buildCard(
              context,
              "Attendance",
              "Mark and track your attendance",
              Icons.check_circle,
              Colors.green,
            ),

            buildCard(
              context,
              "Timetable",
              "View your class timetable",
              Icons.calendar_today,
              Colors.purple,
            ),

            bottomBanner(),
          ],
        ),
      ),
    );
  }

  Widget topHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A6CF7), Color(0xFF6A8CFF)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [

          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(username: username),
                ),
              );
              loadUserData();
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white24,
              backgroundImage:
              imagePath != null ? FileImage(File(imagePath!)) : null,
              child: imagePath == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Let’s make today productive ✨",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationPage(),
                    ),
                  );

                  loadNotificationCount();
                },
              ),

              if (notificationCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      notificationCount > 9 ? "9+" : "$notificationCount",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget sectionTitle() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.fromLTRB(20, 20, 0, 10),
      child: Row(
        children: const [
          SizedBox(
            width: 4,
            height: 20,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFF4A6CF7)),
            ),
          ),
          SizedBox(width: 10),
          Text(
            "Quick Access",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget buildCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color) {
    return GestureDetector(
      onTap: () async {

        if (title == "Events") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventsPage()),
          );

        } else if (title == "Notes") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotesPage()),
          );

        } else if (title == "Attendance") {

          final role = await UserRole.getRole(username);

          if (!context.mounted) return;
          if (role == "admin" || role == "root") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminAttendanceYearPage(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AttendancePage(username: username),
              ),
            );
          }

        } else if (title == "Timetable") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TimetablePage()),
          );
        }
      },

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget bottomBanner() {
return ClipPath(
clipper: BottomCurveClipper(),
child: Container(
width: double.infinity,
height: 300,
decoration: const BoxDecoration(
gradient: LinearGradient(
colors: [Color(0xFF4A6CF7), Color(0xFF6A8CFF)],
),
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: const [
CircleAvatar(
radius: 45,
backgroundImage: AssetImage("assets/logo.png"),
),
SizedBox(height: 15),
Text(
"PDSCT",
style: TextStyle(
color: Colors.white,
fontSize: 32,
fontWeight: FontWeight.bold),
),
SizedBox(height: 5),
Text(
"WELCOMES YOU",
style:
TextStyle(color: Colors.white70, letterSpacing: 2),
),
],
),
),
);
}
}

class BottomCurveClipper extends CustomClipper<Path> {
@override
Path getClip(Size size) {
Path path = Path();

path.lineTo(0, 100);

path.quadraticBezierTo(
size.width / 2,
-40,
size.width,
100,
);

path.lineTo(size.width, size.height);
path.lineTo(0, size.height);

path.close();
return path;
}

@override
bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}