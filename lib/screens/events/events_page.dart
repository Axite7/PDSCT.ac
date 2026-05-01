import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:college_app/models/event_model.dart';
import 'package:college_app/screens/events/add_event_page.dart';
import 'package:college_app/screens/events/event_detail_page.dart';
import 'package:college_app/services/auth_service.dart';
import 'package:college_app/services/firestore_service.dart';
import 'package:college_app/services/storage_service.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

  String role = "user";

  @override
  void initState() {
    super.initState();
    loadRole();
  }

  Future<void> loadRole() async {
    final r = await AuthService.getUserRole();
    if (mounted) {
      setState(() {
        role = r;
      });
    }
  }

  Future<void> _deleteEvent(EventModel event) async {
    // Delete image from storage
    if (event.imageUrl.isNotEmpty) {
      await StorageService.deleteFileByUrl(event.imageUrl);
    }
    // Delete event from Firestore
    await FirestoreService.deleteEvent(event.id);
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
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService.streamEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(child: Text("No Events Yet"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final event = EventModel.fromFirestore(docs[index]);

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
                              const Color(0xFF4A6CF7).withOpacity(0.9),
                              const Color(0xFF6C63FF)
                            ],
                          ),
                        ),
                        child: Column(
                          children: [

                            ClipRRect(
                              borderRadius:
                              const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              child: CachedNetworkImage(
                                imageUrl: event.imageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const SizedBox(
                                      height: 180,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                errorWidget: (context, url, error) =>
                                    const SizedBox(
                                      height: 180,
                                      child: Center(
                                        child: Icon(Icons.broken_image,
                                            color: Colors.white54, size: 50),
                                      ),
                                    ),
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
                                      Text(event.formattedDate,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  Align(
                                    alignment:
                                    Alignment.centerRight,
                                    child: (role == "admin" || role == "root")
                                        ? IconButton(
                                      icon: const Icon(
                                          Icons.delete,
                                          color: Colors.white),
                                      onPressed: () async {
                                        await _deleteEvent(event);
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
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton:
      (role == "admin" || role == "root")
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF4A6CF7),
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEventPage()),
          );
        },
      )
          : null,
    );
  }
}