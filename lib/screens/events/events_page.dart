import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:college_app/screens/events/event_data.dart';
import 'package:college_app/screens/events/add_event_page.dart';
import 'package:college_app/screens/events/event_detail_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

  String role = "user"; // 🔥 ADDED

  @override
  void initState() {
    super.initState();

    loadRole(); // 🔥 ADDED

    loadEvents().then((_) {
      setState(() {});
    });
  }

  // 🔥 ADDED
  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString("role") ?? "user";
    });
  }

  Widget buildHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 45, 16, 25),
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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),

      body: Column(
        children: [

          buildHeader("Events"),

          Expanded(
            child: events.isEmpty
                ? const Center(child: Text("No Events Yet"))
                : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EventDetailPage(event: event),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4A6CF7).withValues(alpha: 0.9),
                          const Color(0xFF6C63FF),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [

                        ClipRRect(
                          borderRadius:
                          const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          child: Image.file(
                            File(event.image),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              Text(event.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight:
                                      FontWeight.bold)),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  const Icon(
                                      Icons.calendar_month,
                                      color: Colors.white,
                                      size: 18),
                                  const SizedBox(width: 6),
                                  Text(event.date,
                                      style: const TextStyle(
                                          color: Colors.white)),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Align(
                                alignment:
                                Alignment.centerRight,

                                // 🔥 DELETE BUTTON HIDE FOR USER
                                child: (role == "admin" || role == "root")
                                    ? IconButton(
                                  icon: const Icon(
                                      Icons.delete,
                                      color: Colors.white),
                                  onPressed: () async {

                                    // 🔒 SAFETY CHECK
                                    if (role == "user") return;

                                    setState(() {
                                      events.removeAt(index);
                                    });

                                    await saveEvents();
                                  },
                                )
                                    : const SizedBox(),
                              )
                            ],
                          ),
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

      // 🔥 FAB HIDE FOR USER
      floatingActionButton:
      (role == "admin" || role == "root")
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF4A6CF7),
        child: const Icon(Icons.add),
        onPressed: () async {

          // 🔒 SAFETY CHECK
          if (role == "user") return;

          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEventPage()),
          );

          await loadEvents();
          setState(() {});
        },
      )
          : null,
    );
  }
}