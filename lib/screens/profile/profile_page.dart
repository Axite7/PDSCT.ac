import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:college_app/screens/auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final name = TextEditingController();
  final age = TextEditingController();
  final year = TextEditingController();
  final branch = TextEditingController();
  final sem = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();

  String? imagePath;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name.text = prefs.getString("username") ?? widget.username;
      age.text = prefs.getString("age") ?? "";
      year.text = prefs.getString("year") ?? "";
      branch.text = prefs.getString("branch") ?? "";
      sem.text = prefs.getString("sem") ?? "";
      phone.text = prefs.getString("phone") ?? "";
      email.text = prefs.getString("email") ?? "";
      imagePath = prefs.getString("profilePic");
    });
  }

  Future pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;

    setState(() {
      imagePath = img.path;
    });
  }

  Future saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("username", name.text);
    await prefs.setString("age", age.text);
    await prefs.setString("year", year.text);
    await prefs.setString("branch", branch.text);
    await prefs.setString("sem", sem.text);
    await prefs.setString("phone", phone.text);
    await prefs.setString("email", email.text);

    if (imagePath != null) {
      await prefs.setString("profilePic", imagePath!);
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Profile Saved")));
  }

  Future logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
    );
  }

  // 🔥 HEADER SAME THEME
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      body: Column(
        children: [

          header(),

          const SizedBox(height: 10),

          // 🔥 SEXY AVATAR WITH BLUE BORDER
          GestureDetector(
            onTap: pickImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFF4A6CF7),
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

                  field("Name", name, Icons.person),
                  field("Age", age, Icons.cake),
                  field("Year", year, Icons.school),
                  field("Branch", branch, Icons.account_tree),
                  field("Sem", sem, Icons.confirmation_number),
                  field("Phone", phone, Icons.phone),
                  field("Email", email, Icons.email),

                  const SizedBox(height: 25),

                  // 🔥 SAVE BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A6CF7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: saveProfile,
                    child: const Text("Save",
                        style: TextStyle(color: Colors.white)),
                  ),

                  const SizedBox(height: 10),

                  // 🔥 LOGOUT BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A6CF7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
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

  // 🔥 SEXY INPUT FIELD
  Widget field(String hint, controller, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          )
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF4A6CF7)),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}