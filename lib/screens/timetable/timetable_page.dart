import 'package:flutter/material.dart';
import 'package:college_app/screens/timetable/timetable_detail_page.dart';

// Lets the user choose between Lecture Timetable and Exam Timetable for a semester
class TimetablePage extends StatelessWidget {
  final int semester;

  const TimetablePage({super.key, required this.semester});

  Widget header(BuildContext context) {
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
          Text(
            "Semester $semester",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Card component for timetable categories (Lecture or Exam)
  Widget fancyCard(BuildContext context, String title, IconData icon, List<Color> colors) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Navigate to TimetableDetailPage passing semester and timetable type ("Lecture Timetable" / "Exam Timetable")
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TimetableDetailPage(
                semester: semester,
                type: title,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.5),
                blurRadius: 12,
              )
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(icon,
                    size: 120,
                    color: Colors.white.withValues(alpha: 0.15)),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Tap to view",
                      style: TextStyle(color: Colors.white70),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: Column(
        children: [
          header(context),

          // Cards for Lecture Timetable and Exam Timetable
          Expanded(
            child: Column(
              children: [
                fancyCard(
                  context,
                  "Lecture Timetable",
                  Icons.menu_book,
                  [Colors.blue, Colors.indigo],
                ),
                fancyCard(
                  context,
                  "Exam Timetable",
                  Icons.edit_calendar,
                  [Colors.orange, Colors.deepOrange],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}