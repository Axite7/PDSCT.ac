import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:college_app/services/auth_service.dart';
import 'package:college_app/services/firestore_service.dart';

/// Handle background messages (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  print("Background message: ${message.messageId}");
}

class FCMService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Initialize FCM: request permissions, get token, set up handlers
  static Future<void> init() async {
    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request notification permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    // Get FCM token and save to Firestore
    await _saveToken();

    // Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      await _saveTokenToFirestore(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message: ${message.notification?.title}");
      // TODO: Show local notification overlay if needed
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification tapped: ${message.data}");
      // TODO: Navigate to relevant page based on message data
    });

    // Subscribe to all-users topic
    await _fcm.subscribeToTopic('all_users');
  }

  /// Get and save the FCM token
  static Future<void> _saveToken() async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveTokenToFirestore(token);
    }
  }

  /// Save FCM token to Firestore user document
  static Future<void> _saveTokenToFirestore(String token) async {
    final uid = AuthService.currentUid;
    if (uid != null) {
      await FirestoreService.updateFCMToken(uid, token);
    }
  }

  /// Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }
}
