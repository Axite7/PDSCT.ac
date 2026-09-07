// Represents a user account in the application
class UserModel {
  final String username;
  final String password;
  String branch;
  String semester;
  String? profilePic;

  Map<String, dynamic> attendance;

  UserModel({
    required this.username,
    required this.password,
    this.branch = "",
    this.semester = "",
    this.profilePic,
    Map<String, dynamic>? attendance,
  }) : attendance = attendance ?? {};

  // Converts the user model into a Map for JSON encoding into SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
      "branch": branch,
      "semester": semester,
      "profilePic": profilePic,
      "attendance": attendance,
    };
  }

  // Creates a UserModel instance from a JSON map loaded from storage
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json["username"],
      password: json["password"],
      branch: json["branch"] ?? "",
      semester: json["semester"] ?? "",
      profilePic: json["profilePic"],
      attendance: Map<String, dynamic>.from(json["attendance"] ?? {}),
    );
  }
}