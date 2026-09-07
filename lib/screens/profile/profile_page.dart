import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../../models/user_model.dart';
import 'package:college_app/screens/auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final branchMap = {
    "CSE": "Computer Science Engineering",
    "IT": "Information Technology",
    "ME": "Mechanical Engineering",
    "CE": "Civil Engineering",
    "EC": "Electronics & Communication",
    "EE": "Electrical Engineering",
  };

  final displayName = TextEditingController();
  final usernameController = TextEditingController();

  final enrollment = TextEditingController();
  final age = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();

  final oldPass = TextEditingController();
  final newPass = TextEditingController();

  String? imagePath;

  // 🔥 UPDATED DROPDOWN VALUES
  String? selectedYear;
  String? selectedBranch;
  String? selectedSem;

  final years = ["1st", "2nd", "3rd", "4th"];

  final branches = [
    "CSE",
    "IT",
    "ME",
    "CE",
    "EC",
    "EE",
  ];

  final sems = ["1", "2", "3", "4", "5", "6", "7", "8"];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // Loads user profile fields and avatar path from SharedPreferences
  Future loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String user = widget.username;

    String? savedYear = prefs.getString("year_$user");
    String? savedBranch = prefs.getString("branch_$user");
    String? savedSem = prefs.getString("sem_$user");

    setState(() {
      usernameController.text = user;

      displayName.text =
          prefs.getString("displayName_$user") ?? "";

      enrollment.text =
          prefs.getString("enrollment_$user") ?? "";

      age.text = prefs.getString("age_$user") ?? "";

      // Validate dropdown values against allowable items to prevent assertion crashes
      selectedYear = years.contains(savedYear) ? savedYear : null;
      selectedBranch = branchMap.containsKey(savedBranch)
          ? savedBranch
          : null;
      selectedSem = sems.contains(savedSem) ? savedSem : null;

      phone.text = prefs.getString("phone_$user") ?? "";
      email.text = prefs.getString("email_$user") ?? "";

      imagePath = prefs.getString("profilePic_$user");
    });
  }

  // Opens image picker to select a new profile avatar from the device gallery
  Future pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;

    setState(() {
      imagePath = img.path;
    });
  }

  // Persists edited profile information into SharedPreferences
  Future saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String user = widget.username;

    await prefs.setString("displayName_$user", displayName.text);
    await prefs.setString("enrollment_$user", enrollment.text);
    await prefs.setString("age_$user", age.text);

    // Save standardized academic details
    await prefs.setString("year_$user", selectedYear ?? "");
    await prefs.setString("branch_$user", selectedBranch ?? "");
    await prefs.setString(
      "branchFull_$user",
      branchMap[selectedBranch] ?? "",
    );
    await prefs.setString("sem_$user", selectedSem ?? "");

    await prefs.setString("phone_$user", phone.text);
    await prefs.setString("email_$user", email.text);

    if (imagePath != null) {
      await prefs.setString("profilePic_$user", imagePath!);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Profile Saved")));
  }

  // Validates old password and updates the user's password in the 'users' list in SharedPreferences
  Future changePassword() async {
    final prefs = await SharedPreferences.getInstance();

    final usersData = prefs.getStringList("users") ?? [];

    final users = usersData
        .map((e) => UserModel.fromJson(jsonDecode(e)))
        .toList();

    int index = users.indexWhere((u) => u.username == widget.username);

    if (index == -1) {
      _msg("User not found");
      return;
    }

    if (users[index].password != oldPass.text.trim()) {
      _msg("Old password incorrect");
      return;
    }

    if (newPass.text.trim().length < 4) {
      _msg("Password too short");
      return;
    }

    // Update password in UserModel
    users[index] = UserModel(
      username: users[index].username,
      password: newPass.text.trim(),
    );

    // Save updated users list back to SharedPreferences
    await prefs.setStringList(
      "users",
      users.map((u) => jsonEncode(u.toJson())).toList(),
    );

    oldPass.clear();
    newPass.clear();

    if (!mounted) return;
    _msg("Password updated successfully");
  }

  // Clears active login session in SharedPreferences and routes back to LoginPage
  Future logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("isLoggedIn", false);
    await prefs.remove("currentUser");
    await prefs.remove("role");

    if (!mounted) return;
    // Remove all previous navigation routes so the user cannot back-navigate
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  void _msg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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
          const Text("Profile",
              style: TextStyle(color: Colors.white, fontSize: 22)),
        ],
      ),
    );
  }

  Widget dropdown(String hint, String? value, List<String> items,
      Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon:
          const Icon(Icons.school, color: Color(0xFF4A6CF7)),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      body: Column(
        children: [

          header(),

          const SizedBox(height: 10),

          GestureDetector(
            onTap: pickImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4A6CF7),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                imagePath != null ? FileImage(File(imagePath!)) : null,
                child: imagePath == null
                    ? const Icon(Icons.camera_alt, size: 28)
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [

                  field("Display Name", displayName, Icons.person),
                  readOnlyField("Username", usernameController),

                  field("Enrollment No.", enrollment, Icons.badge),
                  field("Age", age, Icons.cake),

                  dropdown("Year", selectedYear, years,
                          (v) => setState(() => selectedYear = v)),

                  dropdown("Branch", selectedBranch, branches,
                          (v) => setState(() => selectedBranch = v)),

                  dropdown("Sem", selectedSem, sems,
                          (v) => setState(() => selectedSem = v)),

                  field("Phone", phone, Icons.phone),
                  field("Email", email, Icons.email),

                  const SizedBox(height: 20),

                  field("Old Password", oldPass, Icons.lock),
                  field("New Password", newPass, Icons.lock),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    style: btnStyle(),
                    onPressed: changePassword,
                    child: const Text("Change Password",
                        style: TextStyle(color: Colors.white)),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: btnStyle(),
                    onPressed: saveProfile,
                    child: const Text("Save",
                        style: TextStyle(color: Colors.white)),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    style: btnStyle(),
                    onPressed: logout,
                    child: const Text("Logout",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget field(String hint, TextEditingController controller, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF4A6CF7)),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget readOnlyField(String hint, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          prefixIcon:
          const Icon(Icons.person, color: Color(0xFF4A6CF7)),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  ButtonStyle btnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4A6CF7),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    );
  }
}