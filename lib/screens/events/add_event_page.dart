import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:college_app/screens/events/event_model.dart';
import 'package:college_app/screens/events/event_data.dart';
import 'package:college_app/services/notification_service.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final descController = TextEditingController();

  File? image;

  // Lets the administrator pick an event poster image from the gallery
  Future pickImage() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  // Validates form fields, appends new Event to list, saves to storage, and notifies all users
  void saveEvent() async {
    if (titleController.text.isEmpty ||
        dateController.text.isEmpty ||
        descController.text.isEmpty ||
        image == null) {
      return;
    }

    final title = titleController.text;

    // Add new event to the in-memory list
    events.add(Event(
      title: title,
      date: dateController.text,
      desc: descController.text,
      image: image!.path,
    ));

    // Save all events to SharedPreferences
    await saveEvents();

    // Broadcast a notification to all registered users
    await NotificationService.addNotification(
      username: "all",
      title: "New Event Added",
      message: "${titleController.text} event created",
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),

      appBar: AppBar(
        title: const Text("Add Event"),
        backgroundColor: const Color(0xFF4A6CF7),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            _field(titleController, "Event Title"),
            _field(dateController, "Date"),
            _field(descController, "Description"),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF4A6CF7)),
                ),
                child: image == null
                    ? const Center(
                  child: Text("Choose Poster",
                      style: TextStyle(color: Colors.grey)),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(image!, fit: BoxFit.cover),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6CF7),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Add Event",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}