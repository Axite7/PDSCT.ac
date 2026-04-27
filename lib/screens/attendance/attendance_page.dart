import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendancePage extends StatefulWidget {
  final String username;

  const AttendancePage({super.key, required this.username});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  Set<DateTime> presentDays = {};
  Set<DateTime> holidays = {};

  DateTime norm(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    fetchHolidays(DateTime.now().year);
  }

  // 🔥 OPTIONAL API (ignore if fails)
  Future fetchHolidays(int year) async {
    try {
      final url =
          "https://date.nager.at/api/v3/PublicHolidays/$year/IN";

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          holidays = data.map<DateTime>((h) {
            final d = DateTime.parse(h["date"]);
            return norm(d);
          }).toSet();
        });
      }
    } catch (e) {
      print("Holiday API failed");
    }
  }

  Future markAttendance() async {
    if (selectedDay == null) return;

    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() {
      presentDays.add(norm(selectedDay!));
    });
  }

  Widget header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 45, 16, 25),
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
          const Text("Attendance",
              style: TextStyle(color: Colors.white, fontSize: 22)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = norm(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      body: Column(
        children: [

          header(),

          const SizedBox(height: 10),

          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: focusedDay,

            calendarFormat: CalendarFormat.month,

            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),

            selectedDayPredicate: (day) =>
            selectedDay != null && norm(day) == selectedDay,

            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = norm(selected);
                focusedDay = focused;
              });
            },

            onPageChanged: (focused) {
              focusedDay = focused;
              fetchHolidays(focused.year);
            },

            calendarBuilders: CalendarBuilders(

              // 🔵 TODAY
              todayBuilder: (context, day, _) {
                final d = norm(day);
                bool isPresent = presentDays.contains(d);

                return buildCircle(
                  day,
                  isPresent ? Colors.green : Colors.transparent,
                  border: Border.all(
                    color: Color(0xFF4A6CF7),
                    width: 2,
                  ),
                );
              },

              // 🟡 SELECTED
              selectedBuilder: (context, day, _) {
                return buildCircle(
                  day,
                  Color(0xFF4A6CF7).withOpacity(0.3),
                );
              },

              // 🔥 DEFAULT
              defaultBuilder: (context, day, _) {
                final d = norm(day);

                bool isPresent = presentDays.contains(d);

                // 🔥 SUNDAY CHECK
                bool isSunday = day.weekday == DateTime.sunday;

                // 🔥 API HOLIDAY CHECK
                bool isHoliday = holidays.any((h) =>
                h.year == d.year &&
                    h.month == d.month &&
                    h.day == d.day);

                Color bg = Colors.transparent;

                if (isPresent) {
                  bg = Colors.green;
                } else if (isHoliday || isSunday) {
                  bg = Colors.red;
                }

                return buildCircle(day, bg);
              },
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A6CF7),
              padding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            ),
            onPressed: markAttendance,
            child: const Text("Mark Attendance",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildCircle(DateTime day, Color bg, {Border? border}) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: border,
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
}