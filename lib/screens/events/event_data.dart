import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'event_model.dart';

// In-memory list of currently loaded events
List<Event> events = [];

// SharedPreferences key used to persist the events list JSON
const String key = "events_data";

// Loads persisted events from SharedPreferences into the global 'events' list
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

// Encodes the 'events' list as JSON and saves it into SharedPreferences
Future<void> saveEvents() async {
  final prefs = await SharedPreferences.getInstance();

  final encoded = jsonEncode(
    events.map((e) => e.toJson()).toList(),
  );

  await prefs.setString(key, encoded);
}