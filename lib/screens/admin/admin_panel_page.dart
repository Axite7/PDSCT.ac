import 'package:flutter/material.dart';

import 'package:college_app/screens/admin/user_management_page.dart';
import 'package:college_app/screens/admin/analytics_page.dart';
import 'package:college_app/screens/notes/admin_notes_page.dart';
import 'package:college_app/services/auth_service.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      body: Column(
        children: [
          _header(context),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  _adminCard(
                    context,
                    "User Management",
                    "View, search & manage all users",
                    Icons.people,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UserManagementPage()),
                    ),
                  ),

                  _adminCard(
                    context,
                    "Analytics Dashboard",
                    "View app statistics & insights",
                    Icons.analytics,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AnalyticsPage()),
                    ),
                  ),

                  _adminCard(
                    context,
                    "Pending Notes",
                    "Review & approve submitted notes",
                    Icons.pending_actions,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminNotesPage()),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Admin Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A6CF7), Color(0xFF6A8CFF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.admin_panel_settings,
                            color: Colors.white, size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          "Admin Panel",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Logged in as: ${AuthService.currentUser?.email ?? 'Admin'}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
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
            "Admin Panel",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
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
              child: Icon(icon, color: color, size: 28),
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
            Icon(Icons.arrow_forward_ios,
                color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}
