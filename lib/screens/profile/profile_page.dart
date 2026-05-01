import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import 'package:college_app/screens/auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  final String username; // This is now the UID

  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final displayName = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final enrollment = TextEditingController();
  final age = TextEditingController();
  final year = TextEditingController();
  final branch = TextEditingController();
  final sem = TextEditingController();
  final phone = TextEditingController();

  final oldPass = TextEditingController();
  final newPass = TextEditingController();

  String? profilePicUrl;
  File? newImage;
  bool isLoading = false;
  bool isSaving = false;

  String get uid => AuthService.currentUid ?? widget.username;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future loadProfile() async {
    setState(() => isLoading = true);

    try {
      final data = await FirestoreService.getUser(uid);
      if (data != null && mounted) {
        setState(() {
          displayName.text = data['displayName'] ?? '';
          usernameController.text = data['username'] ?? '';
          emailController.text = data['email'] ?? '';
          enrollment.text = data['enrollmentNo'] ?? '';
          age.text = data['age'] ?? '';
          year.text = data['year'] ?? '';
          branch.text = data['branch'] ?? '';
          sem.text = data['semester'] ?? '';
          phone.text = data['phone'] ?? '';
          profilePicUrl = data['profilePicUrl'];
        });
      }
    } catch (e) {
      if (mounted) _msg("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;

    setState(() {
      newImage = File(img.path);
    });
  }

  Future saveProfile() async {
    setState(() => isSaving = true);

    try {
      String? picUrl = profilePicUrl;

      // Upload new profile pic if selected
      if (newImage != null) {
        picUrl = await StorageService.uploadProfilePic(newImage!, uid);
      }

      await FirestoreService.updateUser(uid, {
        'displayName': displayName.text.trim(),
        'enrollmentNo': enrollment.text.trim(),
        'age': age.text.trim(),
        'year': year.text.trim(),
        'branch': branch.text.trim(),
        'semester': sem.text.trim(),
        'phone': phone.text.trim(),
        'profilePicUrl': picUrl,
      });

      if (mounted) _msg("Profile Saved");
    } catch (e) {
      if (mounted) _msg("Error saving: $e");
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future changePassword() async {
    if (oldPass.text.trim().isEmpty || newPass.text.trim().isEmpty) {
      _msg("Fill both password fields");
      return;
    }

    if (newPass.text.trim().length < 6) {
      _msg("New password must be at least 6 characters");
      return;
    }

    try {
      await AuthService.changePassword(
        oldPassword: oldPass.text.trim(),
        newPassword: newPass.text.trim(),
      );

      oldPass.clear();
      newPass.clear();
      _msg("Password updated successfully");
    } on FirebaseAuthException catch (e) {
      _msg(e.message ?? "Error changing password");
    } catch (e) {
      _msg("Error: $e");
    }
  }

  Future logout() async {
    await AuthService.signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                backgroundImage: newImage != null
                    ? FileImage(newImage!)
                    : (profilePicUrl != null
                        ? CachedNetworkImageProvider(profilePicUrl!)
                        : null) as ImageProvider?,
                child: (newImage == null && profilePicUrl == null)
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
                  readOnlyField("Email", emailController),

                  field("Enrollment No.", enrollment, Icons.badge),
                  field("Age", age, Icons.cake),
                  field("Year", year, Icons.school),
                  field("Branch", branch, Icons.account_tree),
                  field("Sem", sem, Icons.confirmation_number),
                  field("Phone", phone, Icons.phone),

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
                    onPressed: isSaving ? null : saveProfile,
                    child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Save",
                            style: TextStyle(color: Colors.white)),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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