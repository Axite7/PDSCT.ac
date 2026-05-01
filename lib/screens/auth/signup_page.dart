import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/firestore_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
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
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final displayName = displayNameController.text.trim();
    final email = emailController.text.trim();

    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      _showMessage("Email, username and password are required");
      return;
    }

    if (password.length < 6) {
      _showMessage("Password must be at least 6 characters");
      return;
    }

    if (!email.contains('@')) {
      _showMessage("Please enter a valid email");
      return;
    }

    setState(() => isLoading = true);

    try {
      // Create Firebase Auth account + Firestore user doc
      final credential = await AuthService.signUp(
        email: email,
        password: password,
        displayName: displayName.isNotEmpty ? displayName : username,
        username: username,
      );

      // Upload profile picture if selected
      if (image != null && credential.user != null) {
        final picUrl = await StorageService.uploadProfilePic(
          image!,
          credential.user!.uid,
        );
        await FirestoreService.updateUser(credential.user!.uid, {
          'profilePicUrl': picUrl,
        });
      }

      _showMessage("Account created successfully!");

      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Signup failed");
    } catch (e) {
      _showMessage("Signup failed: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _input(String hint, {Widget? suffix, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefix,
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
                    decoration: _input(
                      "Display Name (optional)",
                      prefix: const Icon(Icons.person_outline),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _input(
                      "Email",
                      prefix: const Icon(Icons.email_outlined),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: usernameController,
                    decoration: _input(
                      "Username",
                      prefix: const Icon(Icons.alternate_email),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: _input(
                      "Password (min 6 characters)",
                      prefix: const Icon(Icons.lock_outline),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isLoading ? null : signup,
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              )),
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