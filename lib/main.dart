import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:college_app/screens/auth/login_page.dart';
import 'package:college_app/screens/home/home_page.dart';

// Application entry point
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // RootPage determines whether to show Login or Home based on saved session
      home: RootPage(),
    );
  }
}

// Handles initial authentication check when the app launches
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool? isLoggedIn;
  String username = "";

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  // Reads saved login state and username from local storage (SharedPreferences)
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
      username = prefs.getString("currentUser") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading spinner while checking SharedPreferences
    if (isLoggedIn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If user is already logged in, navigate to HomeScreen; otherwise show LoginPage
    return isLoggedIn! && username.isNotEmpty
        ? HomeScreen(userName: username)
        : const LoginPage();
  }
}