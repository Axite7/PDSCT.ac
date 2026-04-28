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

  // 🔥 TO JSON
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "date": date,
      "desc": desc,
      "image": image,
    };
  }

  // 🔥 FROM JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json["title"],
      date: json["date"],
      desc: json["desc"],
      image: json["image"],
    );
  }
}