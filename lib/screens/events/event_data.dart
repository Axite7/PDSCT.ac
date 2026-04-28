import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'event_model.dart';

List<Event> events = [];

const String key = "events_data";

// 🔥 LOAD EVENTS
Future<void> loadEvents() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString(key);

  if (data != null) {
    final decoded = jsonDecode(data);

    events = (decoded as List)
        .map((e) => Event.fromJson(e))
        .toList();
  }
}

// 🔥 SAVE EVENTS
Future<void> saveEvents() async {
  final prefs = await SharedPreferences.getInstance();

  final encoded = jsonEncode(
    events.map((e) => e.toJson()).toList(),
  );

  await prefs.setString(key, encoded);
}