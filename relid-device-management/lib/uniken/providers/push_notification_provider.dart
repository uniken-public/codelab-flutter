// ============================================================================
// File: push_notification_provider.dart
// Description: Push Notification Provider
//
// Transformed from: PushNotificationProvider.tsx
// Original: React Native REL-ID SDK Push Notification Provider
//
// Ultra-simplified provider that initializes FCM push notifications
// and registers tokens directly with REL-ID SDK. No complex state management
// needed since the pushNotificationService singleton handles everything internally.
// ============================================================================

import 'package:flutter/material.dart';
import '../services/push_notification_service.dart';

/// Push Notification Provider Component
///
/// Simply initializes FCM on mount and lets the service handle everything.
/// This provider wraps the app and ensures FCM is initialized early in the
/// app lifecycle.
///
/// ## Usage
/// ```dart
/// runApp(
///   PushNotificationProvider(
///     child: MyApp(),
///   ),
/// );
/// ```
class PushNotificationProvider extends StatefulWidget {
  final Widget child;

  const PushNotificationProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<PushNotificationProvider> createState() => _PushNotificationProviderState();
}

class _PushNotificationProviderState extends State<PushNotificationProvider> {
  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  /// Initialize FCM on provider mount
  ///
  /// Calls the PushNotificationService singleton to initialize FCM.
  /// Errors are caught and logged but don't block app startup.
  Future<void> _initializeFCM() async {
    print('PushNotificationProvider - Initializing FCM');

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
