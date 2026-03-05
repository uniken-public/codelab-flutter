// ============================================================================
// File: push_notification_service.dart
// Description: Push Notification Service for FCM Integration
//
// Transformed from: pushNotificationService.ts
// Original: React Native REL-ID SDK Push Notification Integration
//
// Cross-platform FCM integration for REL-ID SDK (Android & iOS).
// Handles token registration with REL-ID backend via rdnaService.setDeviceToken().
// ============================================================================

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'rdna_service.dart';

/// Push Notification Service
///
/// Cross-platform singleton for FCM token management (Android & iOS).
/// Integrates with REL-ID SDK to register device push notification tokens.
///
/// ## Features
/// - Android & iOS FCM token retrieval and registration
/// - Android 13+ POST_NOTIFICATIONS permission handling
/// - iOS authorization via FirebaseMessaging (no native changes needed)
/// - Automatic token refresh handling
/// - REL-ID SDK integration via setDeviceToken()
///
/// ## iOS Requirements
/// - GoogleService-Info.plist must be added to ios/Runner/
/// - APNS certificate must be uploaded to Firebase Console
/// - FirebaseMessaging handles APNS delegate methods automatically
///
/// ## Usage
/// ```dart
/// final pushService = PushNotificationService.getInstance();
/// await pushService.initialize();
/// ```
class PushNotificationService {
  static PushNotificationService? _instance;
  final RdnaService _rdnaService;
  bool _isInitialized = false;

  PushNotificationService._(this._rdnaService);

  /// Gets singleton instance
  static PushNotificationService getInstance() {
    if (_instance == null) {
      final rdnaService = RdnaService.getInstance();
      _instance = PushNotificationService._(rdnaService);
    }
    return _instance!;
  }

  /// Initialize FCM and register token with REL-ID SDK
  ///
  /// Supports both Android and iOS platforms. Handles permission requests,
  /// token retrieval, and automatic token refresh registration.
  ///
  /// ## Process
  /// 1. Ensure Firebase is initialized
  /// 2. Request permissions (Android 13+ and iOS)
  /// 3. Get and register initial token
  /// 4. Set up token refresh listener
  ///
  /// ## Throws
  /// - Exception if Firebase initialization fails
  /// - Exception if token retrieval fails
  Future<void> initialize() async {
    if (_isInitialized) {
      print('PushNotificationService - Already initialized');
      return;
    }

    print('PushNotificationService - Starting FCM initialization for ${Platform.operatingSystem}');

    // Ensure Firebase is initialized
    await _ensureFirebaseInitialized();

    // Request permissions (handles both Android and iOS)
    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      print('PushNotificationService - Permission not granted on ${Platform.operatingSystem}');
      return;
    }

    // Get and register initial token
    await _getAndRegisterToken();

    // Set up token refresh listener
    _setupTokenRefreshListener();

    _isInitialized = true;
    print('PushNotificationService - Initialization complete for ${Platform.operatingSystem}');
  }

  /// Ensure Firebase is initialized
  ///
  /// Firebase should auto-initialize from GoogleService-Info.plist (iOS) or
  /// google-services.json (Android). This method verifies initialization.
  ///
  /// ## Throws
  /// - Exception if Firebase fails to initialize
  Future<void> _ensureFirebaseInitialized() async {
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        // Initialize Firebase if not already done
        await Firebase.initializeApp();
        print('PushNotificationService - Firebase initialized successfully');
      } else {
        print('PushNotificationService - Firebase already initialized');
      }
    } catch (e) {
      print('PushNotificationService - Firebase initialization failed: $e');
      rethrow;
    }
  }

  /// Request FCM permissions
  ///
  /// ## Android
  /// - Android 13+ (API 33+) requires POST_NOTIFICATIONS permission
  /// - Earlier versions don't need explicit permission
  ///
  /// ## iOS
  /// - Requests notification authorization (Alert, Sound, Badge)
  /// - Supports PROVISIONAL authorization (quiet notifications)
  ///
  /// ## Returns
  /// true if permission granted, false otherwise
  Future<bool> _requestPermissions() async {
    print('PushNotificationService - Platform OS: ${Platform.operatingSystem}');

    // Android 13+ requires POST_NOTIFICATIONS permission
    if (Platform.isAndroid) {
      print('PushNotificationService - Checking Android notification permission');
      final status = await Permission.notification.status;

      if (!status.isGranted) {
        print('PushNotificationService - Requesting POST_NOTIFICATIONS permission (Android 13+)');
        final result = await Permission.notification.request();
        print('PushNotificationService - POST_NOTIFICATIONS result: $result');

        if (!result.isGranted) {
          print('PushNotificationService - POST_NOTIFICATIONS permission denied');
          return false;
        }
      }
    }

    // Request FCM authorization (works for both Android and iOS)
    print('PushNotificationService - Requesting FCM authorization for ${Platform.operatingSystem}');

    final messaging = FirebaseMessaging.instance;
    final authStatus = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('PushNotificationService - FCM auth status: ${authStatus.authorizationStatus}');

    // iOS supports PROVISIONAL authorization (quiet notifications without prompt)
    final enabled = authStatus.authorizationStatus == AuthorizationStatus.authorized ||
                    authStatus.authorizationStatus == AuthorizationStatus.provisional;

    print('PushNotificationService - FCM permission: ${enabled ? "granted" : "denied"}');
    return enabled;
  }

  /// Get FCM token and register with REL-ID SDK
  ///
  /// ## Android
  /// Gets FCM registration token directly
  ///
  /// ## iOS
  /// Gets FCM token (mapped from APNS token by Firebase automatically)
  /// Checks APNS token availability first
  ///
  /// ## Throws
  /// - Exception if token retrieval fails
  Future<void> _getAndRegisterToken() async {
    print('PushNotificationService - Getting FCM token for ${Platform.operatingSystem}');

    final messaging = FirebaseMessaging.instance;

    // On iOS, check if APNS token is available first
    if (Platform.isIOS) {
      final apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) {
        print('PushNotificationService - iOS APNS token available, length: ${apnsToken.length}');
      } else {
        print('PushNotificationService - iOS APNS token not yet available, will retry via getToken()');
      }
    }

    final token = await messaging.getToken();
    if (token == null) {
      print('PushNotificationService - No FCM token received for ${Platform.operatingSystem}');
      return;
    }

    print('PushNotificationService - FCM token received for ${Platform.operatingSystem}, length: ${token.length}');
    print('PushNotificationService - FCM TOKEN: $token');

    // Register with REL-ID SDK (works for both Android FCM and iOS FCM tokens)
    final response = await _rdnaService.setDeviceToken(token);

    if (response.error?.longErrorCode == 0) {
      print('PushNotificationService - Token registered with REL-ID SDK successfully');
    } else {
      print('PushNotificationService - Token registration failed: ${response.error?.errorString}');
      throw Exception('Failed to register token with REL-ID SDK: ${response.error?.errorString}');
    }
  }

  /// Set up automatic token refresh
  ///
  /// Handles token refresh for both Android and iOS. When the token changes,
  /// automatically registers the new token with REL-ID SDK.
  void _setupTokenRefreshListener() {
    print('PushNotificationService - Setting up token refresh listener for ${Platform.operatingSystem}');

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('PushNotificationService - Token refreshed for ${Platform.operatingSystem}, length: ${newToken.length}');
      print('PushNotificationService - REFRESHED FCM TOKEN: $newToken');

      // Register new token with REL-ID SDK
      final response = await _rdnaService.setDeviceToken(newToken);

      if (response.error?.longErrorCode == 0) {
        print('PushNotificationService - Refreshed token registered with REL-ID SDK');
      } else {
        print('PushNotificationService - Token refresh registration failed: ${response.error?.errorString}');
      }
    }, onError: (error) {
      print('PushNotificationService - Token refresh error: $error');
    });
  }

  /// Get current FCM token (for debugging)
  ///
  /// Returns the current FCM token or null if not available.
  /// Works for both Android and iOS.
  ///
  /// ## Returns
  /// Current FCM token string or null
  Future<String?> getCurrentToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    return token;
  }

  /// Cleanup (reset initialization state)
  void cleanup() {
    print('PushNotificationService - Cleanup');
    _isInitialized = false;
  }
}
