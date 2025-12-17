# REL-ID Flutter Codelab: Push Notification Integration

[![Flutter](https://img.shields.io/badge/Flutter-3.10.3+-blue.svg)](https://flutter.dev/)
[![REL-ID SDK](https://img.shields.io/badge/REL--ID%20SDK-v25.06.03-green.svg)](https://developer.uniken.com/)
[![Dart](https://img.shields.io/badge/Dart-3.10.3+-blue.svg)](https://dart.dev/)
[![Push Notifications](https://img.shields.io/badge/Push%20Notifications-FCM-orange.svg)]()
[![Android](https://img.shields.io/badge/Android-13%2B%20Support-green.svg)]()
[![iOS](https://img.shields.io/badge/iOS-Support-blue.svg)]()

> **Codelab Advanced:** Master Push Notification Integration with REL-ID SDK token management

This folder contains the source code for the solution demonstrating [REL-ID Push Notification Integration](https://codelab.uniken.com/codelabs/flutter-push-notification-integration/index.html?index=..%2F..index#0) with secure token registration.

## 🔔 What You'll Learn

In this advanced push notification codelab, you'll master production-ready FCM integration patterns for Flutter:

- ✅ **FCM Token Management**: Generate and manage Firebase Cloud Messaging tokens for Android & iOS
- ✅ **REL-ID SDK Integration**: Register device tokens using `setDeviceToken()` API
- ✅ **Permission Handling**: Handle Android 13+ POST_NOTIFICATIONS and iOS authorization
- ✅ **Service Architecture**: Implement singleton pattern for push notification services
- ✅ **Token Refresh**: Automatic token refresh handling with REL-ID re-registration
- ✅ **Provider Pattern**: Flutter StatefulWidget providers for automatic service initialization
- ✅ **Error Handling**: Comprehensive error management and logging strategies
- ✅ **Cross-Platform**: Support both Android (FCM) and iOS (APNS via Firebase)

## 🎯 Learning Objectives

By completing this Push Notification Integration codelab, you'll be able to:

1. **Implement FCM token generation** with Firebase Cloud Messaging integration for Android & iOS
2. **Register device tokens with REL-ID** using the secure `setDeviceToken()` API
3. **Handle platform-specific permissions** including Android 13+ notification permissions and iOS authorization
4. **Build scalable service architecture** with singleton patterns and dependency injection
5. **Manage token lifecycle** with automatic refresh and re-registration
6. **Create seamless initialization** with Flutter StatefulWidget providers
7. **Debug push notification flows** and troubleshoot token-related issues
8. **Support cross-platform** with unified FCM API for Android and iOS

## 🏗️ Prerequisites

Before starting this codelab, ensure you have:

- **Flutter Development Environment** - Complete Flutter SDK setup (3.10.3+)
- **Android Development** - Android SDK and development tools configured
- **iOS Development** - Xcode and CocoaPods installed (for iOS support)
- **Firebase Project** - Google Firebase project with FCM enabled
- **Firebase Configuration Files**:
  - Android: `google-services.json` in `android/app/`
  - iOS: `GoogleService-Info.plist` in `ios/Runner/`
- **REL-ID SDK Integration** - Basic understanding of REL-ID SDK architecture
- **Dart Knowledge** - Familiarity with Dart language and Flutter patterns
- **Platform Permissions** - Understanding of Android and iOS permission models

## 📁 Push Notification Project Structure

```
relid-push-notification-token/
├── 📱 Flutter Push Notification App
│   ├── android/                 # Android-specific configuration + Google Services
│   │   ├── app/
│   │   │   ├── build.gradle             # Google Services plugin configuration
│   │   │   └── google-services.json     # 🔥 Firebase configuration (required)
│   │   └── build.gradle                 # Project-level Google Services
│   ├── ios/                     # iOS-specific configuration
│   │   ├── Runner/
│   │   │   └── GoogleService-Info.plist # 🔥 Firebase configuration (required)
│   │   └── Podfile                      # CocoaPods dependencies
│   └── rdna_client/             # REL-ID Native Bridge Plugin
│
├── 📦 Push Notification Source Architecture
│   └── lib/
│       ├── tutorial/            # Tutorial screens and navigation
│       │   ├── navigation/      # App navigation structure
│       │   │   ├── app_router.dart          # GoRouter navigation
│       │   │   └── ...                      # Navigation utilities
│       │   └── screens/         # Tutorial and demo screens
│       │       ├── components/  # Reusable UI components
│       │       │   ├── button.dart                  # Interactive buttons
│       │       │   ├── input.dart                   # Form inputs
│       │       │   ├── status_banner.dart           # Status displays
│       │       │   └── ...                          # Other components
│       │       ├── mfa/         # MFA integration screens
│       │       ├── notification/ # 🔔 Push Notification Demo
│       │       │   ├── get_notifications_screen.dart # Token display and testing
│       │       │   └── ...                           # Notification components
│       │       └── tutorial/    # Base tutorial screens
│       └── uniken/              # 🛡️ REL-ID SDK Integration
│           ├── providers/       # 🆕 Push Notification Providers
│           │   ├── sdk_event_provider.dart          # SDK event handling
│           │   └── push_notification_provider.dart  # 🆕 Auto-initialization provider
│           ├── services/        # 🆕 Push Notification Services
│           │   ├── rdna_service.dart                # 🆕 Enhanced with setDeviceToken()
│           │   ├── push_notification_service.dart   # 🆕 FCM token management singleton
│           │   └── rdna_event_manager.dart          # SDK event management
│           └── utils/           # Helper utilities
│               ├── connection_profile_parser.dart   # Profile configuration
│               └── password_policy_utils.dart       # Utility functions
│
└── 📚 Production Configuration
    ├── pubspec.yaml             # Dependencies with Firebase packages
    │   ├── firebase_core: ^3.8.1         # 🔥 Firebase initialization
    │   ├── firebase_messaging: ^15.1.5   # 🔥 FCM integration
    │   └── permission_handler: ^11.3.1   # 📱 Permission management
    └── analysis_options.yaml
```

## 🚀 Quick Start

### Installation & Setup

```bash
# Navigate to the codelab folder
cd relid-push-notification-token

# Copy the rdna_client plugin to project root
# (Already included in this project structure)

# Install dependencies (includes Firebase packages)
flutter pub get

# iOS additional setup (required for CocoaPods and Firebase)
cd ios && pod install && cd ..

# Run the application
flutter run
# or target specific platform
flutter run -d <device-id>
```

### Firebase Configuration Setup

**Android:**
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/google-services.json`
3. Verify Google Services plugin is configured in `android/app/build.gradle`

**iOS:**
1. Download `GoogleService-Info.plist` from Firebase Console
2. Open Xcode: `open ios/Runner.xcworkspace`
3. Drag `GoogleService-Info.plist` into `Runner` folder in Xcode
4. Verify "Copy items if needed" is checked
5. Ensure file is added to `Runner` target

### Verify Push Notification Features

Once the app launches, verify these push notification capabilities:

1. ✅ FCM token generation on Android and iOS devices
2. ✅ Automatic permission requests for Android 13+ devices
3. ✅ iOS authorization request with alert, sound, and badge permissions
4. ✅ REL-ID SDK token registration via `setDeviceToken()` API
5. ✅ Token refresh handling with automatic re-registration
6. ✅ Service initialization through PushNotificationProvider
7. ✅ Token display and logging for debugging purposes
8. ✅ Cross-platform support with unified FCM API

## 🎓 Learning Checkpoints

### Checkpoint 1: REL-ID setDeviceToken Integration
- [ ] I understand the purpose of `setDeviceToken()` API in REL-ID architecture
- [ ] I can implement REL-ID SDK token registration with proper error handling
- [ ] I know how to integrate FCM tokens with REL-ID's secure communication channel
- [ ] I can debug REL-ID token registration issues and failures
- [ ] I understand the two-channel security model (FCM wake-up + REL-ID secure channel)

### Checkpoint 2: Service Architecture & Singleton Pattern
- [ ] I can implement singleton pattern for push notification service management in Flutter
- [ ] I understand dependency injection patterns with RdnaService integration
- [ ] I can create scalable service architecture with proper initialization
- [ ] I know how to manage service state and prevent double initialization
- [ ] I can implement cleanup and lifecycle management for push notification services

### Checkpoint 3: Cross-Platform Implementation
- [ ] I understand how Firebase handles FCM tokens for both Android and iOS
- [ ] I can implement platform-specific permission handling (Android vs iOS)
- [ ] I know how iOS APNS tokens are mapped to FCM tokens automatically
- [ ] I can debug platform-specific push notification issues
- [ ] I understand the differences between Android POST_NOTIFICATIONS and iOS authorization

## 🔄 Push Notification User Flow

### Token Registration Flow
1. **App launches** → PushNotificationProvider initializes services
2. **Firebase initialization** → Firebase Core initializes from config files
3. **Permission requests** → Platform-specific permission handling (Android 13+, iOS)
4. **Token generation** → Device token generated and retrieved
5. **REL-ID registration** → `setDeviceToken()` registers token with REL-ID backend
6. **Service ready** → Push notification service initialized successfully

### Token Refresh Flow
1. **Token refresh** → System automatically refreshes device token
2. **Listener triggered** → `onTokenRefresh` stream emits new token
3. **REL-ID re-registration** → `setDeviceToken()` updates REL-ID backend with new token
4. **Service continuity** → Push notification service continues with updated token

## 📚 Advanced Resources

- **REL-ID Push Notification Documentation**: [Push Notification Integration Guide](https://developer.uniken.com/docs/push-notifications)
- **Firebase Cloud Messaging (Flutter)**: [FlutterFire FCM Documentation](https://firebase.flutter.dev/docs/messaging/overview/)
- **Android Permissions**: [Notification Permission Guide](https://developer.android.com/develop/ui/views/notifications/notification-permission)
- **iOS Push Notifications**: [Apple Push Notification Service](https://developer.apple.com/documentation/usernotifications)

## 💡 Pro Tips

1. **Initialize early** - Set up REL-ID token registration as early as possible in app lifecycle
2. **Use singleton patterns** - Ensure single point of control for REL-ID service management
3. **Handle setDeviceToken errors** - Always check `response.error?.longErrorCode` from Flutter plugin
4. **Test token refresh** - Verify automatic token refresh and REL-ID re-registration works correctly
5. **Secure token handling** - Never expose device tokens in production logs or analytics
6. **Firebase configuration** - Ensure both `google-services.json` and `GoogleService-Info.plist` are properly configured
7. **iOS permissions** - Request authorization early and handle provisional authorization appropriately
8. **Check APNS token** - On iOS, verify APNS token is available before calling `getToken()`

## 🔗 Key Implementation Files

### Core Push Notification Service
```dart
// push_notification_service.dart - FCM Token Management
class PushNotificationService {
  static PushNotificationService? _instance;
  final RdnaService _rdnaService;
  bool _isInitialized = false;

  static PushNotificationService getInstance() {
    if (_instance == null) {
      final rdnaService = RdnaService.getInstance();
      _instance = PushNotificationService._(rdnaService);
    }
    return _instance!;
  }

  Future<void> initialize() async {
    // Ensure Firebase is initialized
    await _ensureFirebaseInitialized();

    // Platform-specific permissions (Android 13+, iOS)
    final hasPermission = await _requestPermissions();
    if (hasPermission) {
      await _getAndRegisterToken();
      _setupTokenRefreshListener();
    }
  }

  Future<void> _getAndRegisterToken() async {
    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();

    // Register with REL-ID SDK
    final response = await _rdnaService.setDeviceToken(token!);
    if (response.error?.longErrorCode == 0) {
      print('Token registered with REL-ID SDK successfully');
    }
  }
}
```

### REL-ID SDK Integration
```dart
// rdna_service.dart - Device Token Registration
Future<RDNASyncResponse> setDeviceToken(String deviceToken) async {
  print('RdnaService - Registering device push token with REL-ID SDK');
  print('RdnaService - Token length: ${deviceToken.length}');

  // ✅ Call plugin without redundant try-catch
  final response = await _rdnaClient.setDeviceToken(deviceToken);

  if (response.error?.longErrorCode == 0) {
    print('RdnaService - Device push token registration successful');
  } else {
    print('RdnaService - Device push token registration failed: ${response.error?.errorString}');
  }

  return response;
}
```

### Provider Integration Pattern
```dart
// push_notification_provider.dart - Auto-initialization
class PushNotificationProvider extends StatefulWidget {
  final Widget child;

  const PushNotificationProvider({Key? key, required this.child}) : super(key: key);

  @override
  State<PushNotificationProvider> createState() => _PushNotificationProviderState();
}

class _PushNotificationProviderState extends State<PushNotificationProvider> {
  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    try {
      final pushService = PushNotificationService.getInstance();
      await pushService.initialize();
      print('PushNotificationProvider - FCM initialization successful');
    } catch (error) {
      print('PushNotificationProvider - FCM initialization failed: $error');
      // Don't block app startup on FCM initialization failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
```

### Permission Request Implementation
```dart
// Permission handling with Android 13+ and iOS support
Future<bool> _requestPermissions() async {
  // Android 13+ requires POST_NOTIFICATIONS permission
  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted) {
        return false;
      }
    }
  }

  // Request FCM authorization (works for both Android and iOS)
  final messaging = FirebaseMessaging.instance;
  final authStatus = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // iOS supports PROVISIONAL authorization (quiet notifications)
  final enabled = authStatus.authorizationStatus == AuthorizationStatus.authorized ||
                  authStatus.authorizationStatus == AuthorizationStatus.provisional;

  return enabled;
}
```

### Token Refresh Listener
```dart
// Automatic token refresh handling
void _setupTokenRefreshListener() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    print('Token refreshed, length: ${newToken.length}');

    // Register new token with REL-ID SDK
    final response = await _rdnaService.setDeviceToken(newToken);

    if (response.error?.longErrorCode == 0) {
      print('Refreshed token registered with REL-ID SDK');
    } else {
      print('Token refresh registration failed: ${response.error?.errorString}');
    }
  }, onError: (error) {
    print('Token refresh error: $error');
  });
}
```

---

**🔔 Congratulations! You've mastered Push Notification Integration with REL-ID SDK on Flutter!**

*You're now equipped to implement secure, efficient push notification systems that integrate Firebase Cloud Messaging with REL-ID's secure communication architecture across both Android and iOS platforms. Use this knowledge to create robust notification systems that enhance user experience while maintaining the highest security standards.*
