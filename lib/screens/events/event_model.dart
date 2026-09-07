// Represents a college event with its details and poster image path
class Event {
  final String title;
  final String date;
  final String desc;
  final String image;

  Event({
    required this.title,
    required this.date,
    required this.desc,
    required this.image,
  });

  // Converts an Event object into a Map for JSON storage in SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "date": date,
      "desc": desc,
      "image": image,
    };
  }

  // Creates an Event instance from decoded JSON map
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json["title"],
      date: json["date"],
      desc: json["desc"],
      image: json["image"],
    );
  }
}