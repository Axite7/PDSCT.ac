import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:college_app/services/firestore_service.dart';
import 'package:college_app/services/storage_service.dart';
import 'package:college_app/services/location_service.dart';
import 'package:college_app/services/auth_service.dart';

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
  bool isMarking = false;

  DateTime norm(DateTime d) => DateTime(d.year, d.month, d.day);

  String get uid => AuthService.currentUid ?? widget.username;

  @override
  void initState() {
    super.initState();
    fetchHolidays(DateTime.now().year);
  }

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
    if (selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a day first")),
      );
      return;
    }

    setState(() => isMarking = true);

    try {
      // Check location
      final locationResult = await LocationService.isWithinCampus();

      if (!mounted) return;

      if (locationResult['isWithin'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(locationResult['message'] ?? 'Not within campus'),
            backgroundColor: Colors.orange,
          ),
        );
        // Allow marking anyway but record the location
      }

      // Take selfie
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) {
        setState(() => isMarking = false);
        return;
      }

      // Upload selfie to Firebase Storage
      final photoUrl = await StorageService.uploadAttendanceSelfie(
        File(image.path),
        uid,
      );

      // Save attendance to Firestore
      GeoPoint? geoPoint;
      if (locationResult['latitude'] != null) {
        geoPoint = GeoPoint(
          locationResult['latitude'],
          locationResult['longitude'],
        );
      }

      await FirestoreService.markAttendance(
        userId: uid,
        date: selectedDay!,
        status: 'present',
        photoUrl: photoUrl,
        location: geoPoint,
      );

      setState(() {
        presentDays.add(norm(selectedDay!));
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Attendance marked successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isMarking = false);
    }
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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.streamAttendance(uid),
        builder: (context, snapshot) {
          // Build present days set from Firestore data
          if (snapshot.hasData) {
            presentDays = snapshot.data!.docs.map((doc) {
              final data = doc.data();
              if (data['date'] is Timestamp) {
                return norm((data['date'] as Timestamp).toDate());
              }
              return norm(DateTime.now());
            }).toSet();
          }

          int totalDays = DateTime.now().difference(
            DateTime(DateTime.now().year, 1, 1),
          ).inDays;
          int presentCount = presentDays.length;
          double percentage = totalDays > 0
              ? (presentCount / totalDays * 100)
              : 0;

          return Column(
            children: [

              header(),

              const SizedBox(height: 10),

              // Attendance Stats
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8)
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem("Present", "$presentCount", Colors.green),
                    _statItem("Percentage",
                        "${percentage.toStringAsFixed(1)}%", Colors.blue),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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

                          todayBuilder: (context, day, _) {
                            final d = norm(day);
                            bool isPresent = presentDays.contains(d);

                            return buildCircle(
                              day,
                              isPresent ? Colors.green : Colors.transparent,
                              border: Border.all(
                                color: const Color(0xFF4A6CF7),
                                width: 2,
                              ),
                            );
                          },

                          selectedBuilder: (context, day, _) {
                            return buildCircle(
                              day,
                              const Color(0xFF4A6CF7).withOpacity(0.3),
                            );
                          },

                          defaultBuilder: (context, day, _) {
                            final d = norm(day);

                            bool isPresent = presentDays.contains(d);
                            bool isSunday = day.weekday == DateTime.sunday;
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

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A6CF7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: isMarking ? null : markAttendance,
                            child: isMarking
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Mark Attendance",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    )),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
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