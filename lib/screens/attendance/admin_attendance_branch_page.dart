import 'package:flutter/material.dart';
import 'admin_students_page.dart';

class AdminAttendanceBranchPage extends StatelessWidget {
  final String year;

  const AdminAttendanceBranchPage({super.key, required this.year});

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
            "$year Year - Branch",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // 🔥 FIXED BRANCH LIST (MATCHES PROFILE + ATTENDANCE)
    final branches = [
      {"short": "CSE", "full": "Computer Science Engineering"},
      {"short": "IT", "full": "Information Technology"},
      {"short": "ME", "full": "Mechanical Engineering"},
      {"short": "CE", "full": "Civil Engineering"},
      {"short": "EC", "full": "Electronics & Communication"},
      {"short": "EE", "full": "Electrical Engineering"},
    ];

    // 🎨 SAME COLOR SYSTEM
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.deepPurple,
      Colors.teal,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      body: Column(
        children: [

          header(context),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: branches.length,
              itemBuilder: (context, index) {

                final branch = branches[index];
                final color = colors[index % colors.length];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminStudentsPage(
                          year: year,
                          branch: branch["short"]!, // 🔥 important
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 18),

                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(18),

                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Expanded(
                          child: Text(
                            branch["full"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 18,
                        )
                      ],
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