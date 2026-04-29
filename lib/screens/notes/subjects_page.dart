import 'package:flutter/material.dart';
import 'package:college_app/screens/notes/notes_list_page.dart';

class SubjectsPage extends StatelessWidget {
  final String branch;
  final String year;

  const SubjectsPage({
    super.key,
    required this.branch,
    required this.year,
  });

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
    final subjects = getSubjects(branch, year);

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

          buildHeader(context, "$branch - $year Year"),

          Expanded(
            child: subjects.isEmpty
                ? const Center(child: Text("No data available"))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              itemBuilder: (context, index) {

                final color = colors[index % colors.length];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            NotesListPage(
                              subject: subjects[index],
                              year: year,       // ✅ FIX
                              branch: branch,   // ✅ FIX
                            ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [

                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            subjects[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 14,
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

  List<String> getSubjects(String branch, String year) {

    // ================= FIRST YEAR =================
    if (year == "1st") {
      return [
        "BT-101 Engineering Chemistry",
        "BT-102 Mathematics-I",
        "BT-103 English for Communication",
        "BT-104 Basic Electrical & Electronics Engineering",
        "BT-105 Engineering Graphics",
        "BT-106 Manufacturing Practices",
        "BT-107 Internship",
        "BT-108 Swachh Bharat Internship",
        "BT-201 Engineering Physics",
        "BT-202 Mathematics-II",
        "BT-203 Basic Mechanical Engineering",
        "BT-204 Basic Civil Engineering & Mechanics",
        "BT-205 Basic Computer Engineering",
        "BT-206 Language Lab & Seminars",
      ];
    }

    // ================= CSE =================
    if (branch == "CSE" && year == "2nd") {
      return [
        "CS-301 Energy & Environmental Engineering",
        "CS-302 Discrete Structure",
        "CS-303 Data Structure",
        "CS-304 Digital Systems",
        "CS-305 Object Oriented Programming",
        "CS-306 Computer Workshop",
        "CS-307 Internship-I",
      ];
    }

    if (branch == "CSE" && year == "3rd") {
      return [
        "CS-501 Operating System",
        "CS-502 Computer Network",
        "CS-503 Theory of Computation",
        "CS-504 Microprocessor",
        "CS-505 Programming Languages",
        "CS-506 Artificial Intelligence",
        "CS-507 Java Programming",
        "CS-508 Advanced Java Lab",
        "CS-509 Internship-II",
      ];
    }

    if (branch == "CSE" && year == "4th") {
      return [
        "CS-701 Software Architecture",
        "CS-702 Big Data",
        "CS-703 Artificial Intelligence",
        "CS-704 Machine Learning",
        "CS-705 Mobile Computing",
        "CS-706 Cryptography & Network Security",
        "CS-707 Data Mining",
        "CS-801 Internet of Things",
        "CS-802 Blockchain Technology",
        "CS-803 Cloud Computing",
        "CS-804 High Performance Computing",
        "CS-805 Object Oriented Software Engineering",
      ];
    }

    // ================= IT =================
    if (branch == "IT" && year == "2nd") {
      return [
        "IT-301 Energy & Environmental Engineering",
        "IT-302 Discrete Structure",
        "IT-303 Data Structure",
        "IT-304 Object Oriented Programming",
        "IT-305 Digital Circuits",
        "IT-306 Java Programming Lab",
        "IT-307 Internship-I",
      ];
    }

    if (branch == "IT" && year == "3rd") {
      return [
        "IT-501 Operating System",
        "IT-502 Computer Network",
        "IT-503 Theory of Computation",
        "IT-504 Microprocessor",
        "IT-505 Artificial Intelligence",
        "IT-506 Java Programming",
        "IT-507 Internship-II",
      ];
    }

    if (branch == "IT" && year == "4th") {
      return [
        "IT-701 Soft Computing",
        "IT-702 Augmented & Virtual Reality",
        "IT-703 Cloud Computing",
        "IT-704 Data Science",
        "IT-705 Simulation & Modeling",
        "IT-706 Cyber Laws",
        "IT-707 Digital Image Processing",
        "IT-708 Internet of Things",
        "IT-801 Information Security",
        "IT-802 Machine Learning",
        "IT-803 NLP",
        "IT-804 Quantum Computing",
        "IT-805 Robotics",
      ];
    }

    // ================= ME =================
    if (branch == "ME" && year == "2nd") {
      return [
        "ME-301 Mathematics-III",
        "ME-302 Thermodynamics",
        "ME-303 Material Technology",
        "ME-304 Strength of Material",
        "ME-305 Manufacturing Process",
        "ME-306 Thermal Engineering Lab",
      ];
    }

    if (branch == "ME" && year == "3rd") {
      return [
        "ME-501 IC Engine",
        "ME-502 Mechanical Vibration",
        "ME-503 Mechatronics",
        "ME-504 Dynamics of Machine",
        "ME-505 Automobile Engineering",
        "ME-506 Industrial Engineering",
        "ME-507 Internship-II",
      ];
    }

    if (branch == "ME" && year == "4th") {
      return [
        "ME-701 Heat & Mass Transfer",
        "ME-702 Advance Machine Design",
        "ME-703 Advanced Machining",
        "ME-704 Industrial Engineering-II",
        "ME-705 Power Plant Engineering",
        "ME-706 Artificial Intelligence",
        "ME-707 Supply Chain Management",
      ];
    }

    // ================= CE =================
    if (branch == "CE" && year == "2nd") {
      return [
        "CE-301 Mathematics-III",
        "CE-302 Construction Materials",
        "CE-303 Surveying",
        "CE-304 Building Drawing",
        "CE-305 Strength of Materials",
      ];
    }

    if (branch == "CE" && year == "3rd") {
      return [
        "CE-501 Fluid Mechanics",
        "CE-502 Environmental Engineering",
        "CE-503 Geotechnical Engineering",
        "CE-504 Transportation Engineering",
        "CE-505 Structural Analysis",
      ];
    }

    if (branch == "CE" && year == "4th") {
      return [
        "CE-701 Geotechnical Engineering-II",
        "CE-702 Environmental Engineering-II",
        "CE-703 Structural Design",
        "CE-704 Structural Dynamics",
        "CE-705 Building Services",
        "CE-706 Project Management",
      ];
    }

    // ================= EC =================
    if (branch == "EC" && year == "2nd") {
      return [
        "EC-301 Mathematics-III",
        "EC-302 Electronic Measurement",
        "EC-303 Digital System Design",
        "EC-304 Electronic Devices",
        "EC-305 Network Analysis",
        "EC-306 Electronics Lab",
      ];
    }

    if (branch == "EC" && year == "3rd") {
      return [
        "EC-501 Microprocessor & Application",
        "EC-502 Digital Communication",
        "EC-503 Control System",
        "EC-504 Mobile Communication",
        "EC-505 Advanced Control System",
        "EC-506 Electromagnetics",
        "EC-507 Internship-II",
      ];
    }

    if (branch == "EC" && year == "4th") {
      return [
        "EC-701 VLSI Design",
        "EC-702 Microwave Engineering",
        "EC-703 Nano Electronics",
        "EC-704 Cellular Communication",
        "EC-705 IoT",
        "EC-801 Optical Fiber Communication",
        "EC-802 Wireless Communication",
        "EC-803 Digital Image Processing",
      ];
    }

    return [];
  }
}