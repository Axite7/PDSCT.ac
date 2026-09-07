import 'package:flutter/material.dart';
import 'package:college_app/screens/timetable/timetable_page.dart';

// Timetable section entry screen: lets user choose a semester (Sem 1 to Sem 8)
class SemesterPage extends StatelessWidget {
  const SemesterPage({super.key});

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
          const Expanded(
            child: Text(
              "Select Semester",
              style: TextStyle(
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
    // Generates semester labels from Sem 1 to Sem 8
    final semesters = List.generate(8, (index) => "Sem ${index + 1}");

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
          buildHeader(context, "Select Semester"),

          // List semesters for user selection
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: semesters.length,
              itemBuilder: (context, index) {

                final color = colors[index % colors.length];

                return GestureDetector(
                  onTap: () {
                    // Navigate to TimetablePage passing the selected semester number (1-8)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TimetablePage(semester: index + 1),
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
                      semesters[index],
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