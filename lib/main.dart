import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:college_app/screens/auth/login_page.dart';
import 'package:college_app/screens/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RootPage(),
    );
  }
}

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

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

      // ✅ FIX (important)
      username = prefs.getString("currentUser") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return isLoggedIn! && username.isNotEmpty
        ? HomeScreen(userName: username)
        : const LoginPage();
  }
}