import 'package:firebase_auth/firebase_auth.dart';
import 'package:college_app/services/firestore_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Get current user UID
  static String? get currentUid => _auth.currentUser?.uid;

  /// Stream of auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email & password, then create Firestore user doc
  static Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
    required String username,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name in Firebase Auth
    await credential.user?.updateDisplayName(displayName);

    // Create user document in Firestore
    await FirestoreService.createUser(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName,
      username: username,
    );

    return credential;
  }

  /// Sign in with email & password
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Change password (requires recent sign-in)
  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception("No user signed in");
    }

    // Re-authenticate first
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Update password
    await user.updatePassword(newPassword);
  }

  /// Get user role from Firestore
  static Future<String> getUserRole() async {
    if (currentUid == null) return "user";
    return await FirestoreService.getUserRole(currentUid!);
  }
}
