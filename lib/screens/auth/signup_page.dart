import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../models/user_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final displayNameController = TextEditingController();

  bool obscurePassword = true;
  File? image;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  Future<void> signup() async {
    final prefs = await SharedPreferences.getInstance();

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final displayName = displayNameController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage("Username and password are required");
      return;
    }

    final usersData = prefs.getStringList("users") ?? [];

    final users = usersData
        .map((e) => UserModel.fromJson(jsonDecode(e)))
        .toList();

    if (users.any((u) => u.username == username)) {
      _showMessage("Username already exists");
      return;
    }

    users.add(UserModel(username: username, password: password));

    await prefs.setStringList(
      "users",
      users.map((u) => jsonEncode(u.toJson())).toList(),
    );

    if (displayName.isNotEmpty) {
      await prefs.setString("displayName_$username", displayName);
    }

    if (image != null) {
      await prefs.setString("profilePic_$username", image!.path);
    }

    if (!mounted) return;
    _showMessage("Account created successfully");
    Navigator.pop(context);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _input(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      body: Column(
        children: [

          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A6CF7), Color(0xFF6A8CFF)],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [

                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    backgroundImage:
                    image != null ? FileImage(image!) : null,
                    child: image == null
                        ? const Icon(Icons.camera_alt,
                        color: Color(0xFF4A6CF7))
                        : null,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Join your college app",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  TextField(
                    controller: displayNameController,
                    decoration: _input("Display Name (optional)"),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: usernameController,
                    decoration: _input("Username"),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: _input(
                      "Password",
                      suffix: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A6CF7),
                      ),
                      onPressed: signup,
                      child: const Text("Sign Up",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          bottomBanner(),
        ],
      ),
    );
  }

  Widget bottomBanner() {
    return ClipPath(
      clipper: BottomCurveClipper(),
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A6CF7), Color(0xFF6A8CFF)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage("assets/logo.png"),
            ),
            SizedBox(height: 10),
            Text(
              "PDSCT",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "WELCOMES YOU",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 80);
    path.quadraticBezierTo(size.width / 2, -30, size.width, 80);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}