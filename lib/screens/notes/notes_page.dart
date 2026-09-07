import 'package:flutter/material.dart';
import 'package:college_app/screens/notes/branch_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:college_app/screens/notes/admin_notes_page.dart';

// Notes section entry screen: allows selecting academic year (1st to 4th year)
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  Widget buildHeader(BuildContext context, String title) {
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
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Show Admin Panel shortcut icon only for admin and root users
          FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final prefs = snapshot.data!;
              final role = prefs.getString("role") ?? "user";

              if (role == "admin" || role == "root") {
                return IconButton(
                  icon: const Icon(Icons.admin_panel_settings,
                      color: Colors.white),
                  onPressed: () {
                    // Navigate to pending notes review screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminNotesPage(),
                      ),
                    );
                  },
                );
              }

              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final years = ["1st", "2nd", "3rd", "4th"];

    // 🔥 SAME COLORS AS SUBJECTS PAGE
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.deepPurple,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      body: Column(
        children: [

          buildHeader(context, "Select Year"),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: years.length,
              itemBuilder: (context, index) {

                final color = colors[index % colors.length];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BranchPage(year: years[index]),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Text(
                      "${years[index]} Year",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}