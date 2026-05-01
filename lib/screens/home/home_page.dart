import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:college_app/screens/notification/notification_page.dart';
import 'package:college_app/screens/profile/profile_page.dart';
import 'package:college_app/screens/events/events_page.dart';
import 'package:college_app/screens/notes/notes_page.dart';
import 'package:college_app/screens/attendance/attendance_page.dart';
import 'package:college_app/screens/timetable/timetable_page.dart';
import 'package:college_app/screens/admin/admin_panel_page.dart';
import 'package:college_app/services/auth_service.dart';
import 'package:college_app/services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {

  String? profilePicUrl;
  String username = "";
  String displayName = "";
  String role = "user";
  int notificationCount = 0;

  String get uid => AuthService.currentUid ?? widget.userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirestoreService.streamUser(uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasData && userSnapshot.data?.data() != null) {
          final data = userSnapshot.data!.data()!;
          displayName = data['displayName'] ?? data['username'] ?? '';
          username = data['username'] ?? '';
          profilePicUrl = data['profilePicUrl'];
          role = data['role'] ?? 'user';
        }

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

                // Admin Panel card (visible to admin/root only)
                if (role == "admin" || role == "root")
                  buildCard(
                    context,
                    "Admin Panel",
                    "Manage users, content & analytics",
                    Icons.admin_panel_settings,
                    Colors.red,
                  ),

                bottomBanner(),
              ],
            ),
          ),
        );
      },
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
                  builder: (_) => ProfilePage(username: uid),
                ),
              );
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white24,
              backgroundImage: profilePicUrl != null
                  ? CachedNetworkImageProvider(profilePicUrl!)
                  : null,
              child: profilePicUrl == null
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
                  "Let's make today productive ✨",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Notification bell with real-time unread count
          StreamBuilder<QuerySnapshot>(
            stream: FirestoreService.streamUnreadNotifications(uid),
            builder: (context, snapshot) {
              int unread = snapshot.data?.docs.length ?? 0;

              return Stack(
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
                    },
                  ),

                  if (unread > 0)
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
                          unread > 9 ? "9+" : "$unread",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
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
      onTap: () {
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AttendancePage(username: uid),
            ),
          );
        } else if (title == "Timetable") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TimetablePage()),
          );
        } else if (title == "Admin Panel") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminPanelPage()),
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
                color: color.withOpacity(0.15),
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
                          fontSize: 18, fontWeight: FontWeight.bold)),
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