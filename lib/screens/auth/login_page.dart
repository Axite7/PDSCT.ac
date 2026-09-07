import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'signup_page.dart';
import 'package:college_app/models/user_model.dart';
import 'package:college_app/screens/home/home_page.dart';
import 'package:college_app/models/user_role.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool loginAsAdmin = false;

  // Handles user authentication, root bypass, role resolution, and session saving
  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // 1. Hardcoded Root Super-Admin Login check
    if (username == "Axite7" && password == "Axite@717") {
      await prefs.setString("currentUser", username);
      await prefs.setString("role", "root");
      await prefs.setBool("isLoggedIn", true);

      if (!mounted) return;
      // Navigate to HomeScreen and replace login page in the route stack
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userName: username),
        ),
      );
      return;
    }

    // 2. Fetch saved registered users from SharedPreferences
    final usersData = prefs.getStringList("users") ?? [];

    final users = usersData
        .map((e) => UserModel.fromJson(jsonDecode(e)))
        .toList();

    // 3. Match username and password against registered users
    final user = users.where((u) =>
    u.username == username && u.password == password);

    if (user.isEmpty) {
      _showMessage("Invalid credentials");
      return;
    }

    // 4. Resolve user role (checks root and approvedAdmins list)
    String role = await UserRole.getRole(username);

    // 5. If user checked "Login as Admin" but is a regular user, trigger an admin request
    if (loginAsAdmin && role == "user") {
      await UserRole.requestAdmin(username);
      _showMessage("Admin request sent");
    }

    // 6. Save active session data to SharedPreferences
    await prefs.setString("currentUser", username);
    await prefs.setString("role", role);
    await prefs.setBool("isLoggedIn", true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(userName: username),
      ),
    );
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
            child: const Column(
              children: [
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Login to continue",
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

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Checkbox(
                        value: loginAsAdmin,
                        onChanged: (val) {
                          setState(() => loginAsAdmin = val ?? false);
                        },
                      ),
                      const Text("Login as Admin"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A6CF7),
                      ),
                      onPressed: login,
                      child: const Text("Login",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupPage(),
                        ),
                      );
                    },
                    child: const Text("Create Account"),
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