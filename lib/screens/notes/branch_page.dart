import 'package:flutter/material.dart';
import 'package:college_app/screens/notes/subjects_page.dart';

class BranchPage extends StatelessWidget {
  final String year;

  const BranchPage({super.key, required this.year});

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
            onPressed: () {
              Navigator.pop(context);
            },
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // Engineering branches available in the college
    final branches = [
      {"short": "CSE", "full": "Computer Science Engineering"},
      {"short": "IT", "full": "Information Technology"},
      {"short": "ME", "full": "Mechanical Engineering"},
      {"short": "CE", "full": "Civil Engineering"},
      {"short": "EC", "full": "Electronics & Communication"},
      {"short": "EE", "full": "Electrical Engineering"},
    ];

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

          buildHeader(context, "$year Year"),

          // List branches for student to tap and view corresponding subjects
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: branches.length,
              itemBuilder: (context, index) {

                final branch = branches[index];
                final color = colors[index % colors.length];

                return GestureDetector(
                  onTap: () {
                    // Navigate to subjects list passing the short branch code (e.g. "CSE") and year
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubjectsPage(
                          branch: branch["short"]!,
                          year: year,
                        ),
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
                      branch["full"]!,
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