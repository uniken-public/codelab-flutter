// ============================================================================
// File: sdk_event_provider.dart
// Description: SDK Event Provider
//
// Centralized provider for REL-ID SDK event handling.
// Manages all SDK events globally, similar to React Native Context Provider.
//
// Key Features:
// - Global event handling for SDK initialization and MFA events
// - Automatic navigation on SDK events (onInitialized, getUser, getPassword, etc.)
// - Centralized state management for SDK events
// - React-like provider pattern
// - Supports full MFA flow (user, activation code, LDA consent, password, login)
//
// Usage:
// ```dart
// // Wrap your MaterialApp with SDKEventProviderWidget
// runApp(
//   ProviderScope(
//     child: SDKEventProviderWidget(
//       child: MyApp(),
//     ),
//   ),
// );
// ```
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../services/rdna_service.dart';
import '../../tutorial/navigation/app_router.dart';

/// Global RdnaService instance provider
final rdnaServiceProvider = Provider<RdnaService>((ref) {
  final service = RdnaService.getInstance();

  // Cleanup on dispose
  ref.onDispose(() {
    service.cleanup();
  });

  return service;
});

/// Provider for initialized event data
///
/// This provider holds the most recent initialization success data.
/// It's updated by the SDK event handler when onInitialized fires.
final initializedDataProvider =
    StateProvider<RDNAInitialized?>((ref) => null);

/// SDK Event Provider Widget
///
/// Wraps the app and handles global SDK events, similar to React Native's
/// SDKEventProvider Context.
///
/// This widget:
/// - Sets up SDK event listeners on mount
/// - Handles onInitialized event globally
/// - Automatically navigates to success screen
/// - Cleans up event handlers on unmount
class SDKEventProviderWidget extends ConsumerStatefulWidget {
  final Widget child;

  const SDKEventProviderWidget({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<SDKEventProviderWidget> createState() =>
      _SDKEventProviderWidgetState();
}

class _SDKEventProviderWidgetState
    extends ConsumerState<SDKEventProviderWidget> {
  @override
  void initState() {
    super.initState();
    _setupSDKEventHandlers();
  }

  /// Set up SDK Event Subscriptions on mount
  ///
  /// Similar to React Native's useEffect hook in SDKEventProvider
  void _setupSDKEventHandlers() {
    final rdnaService = RdnaService.getInstance();
    final eventManager = rdnaService.getEventManager();

    // Set up event handlers once on mount
    eventManager.setInitializedHandler(_handleInitialized);
    eventManager.setGetUserHandler(_handleGetUser);
    eventManager.setGetActivationCodeHandler(_handleGetActivationCode);
    eventManager.setGetUserConsentForLDAHandler(_handleGetUserConsentForLDA);
    eventManager.setGetPasswordHandler(_handleGetPassword);
    eventManager.setOnUserLoggedInHandler(_handleUserLoggedIn);
    eventManager.setOnUserLoggedOffHandler(_handleUserLoggedOff);
    eventManager.setCredentialsAvailableForUpdateHandler(_handleCredentialsAvailableForUpdate);

    print('SDKEventProvider - Event handlers registered');
  }

  /// Event handler for successful initialization
  ///
  /// Automatically navigates to TutorialSuccess screen with session data,
  /// just like React Native's NavigationService.navigate call.
  void _handleInitialized(RDNAInitialized data) {
    print('SDKEventProvider - Successfully initialized');
    print('  Session ID: ${data.session?.sessionId}');
    print('  Status Code: ${data.status?.statusCode}');
    print('  Session Type: ${data.session?.sessionType}');

    // Update state
    ref.read(initializedDataProvider.notifier).state = data;

    // Navigate to success screen (React Native equivalent)
    // NavigationService.navigate('TutorialSuccess', {...})
    // Use the router instance directly (since SDKEventProvider wraps MaterialApp)
    appRouter.goNamed('tutorialSuccessScreen', extra: data);
  }

  /// Event handler for get user requests
  ///
  /// Navigates to CheckUserScreen with event data
  void _handleGetUser(RDNAGetUser data) {
    print('SDKEventProvider - Get user event received');
    print('  Status Code: ${data.challengeResponse?.status?.statusCode}');

    appRouter.goNamed('checkUserScreen', extra: data);
  }

  /// Event handler for get activation code requests
  ///
  /// Navigates to ActivationCodeScreen with event data
  void _handleGetActivationCode(RDNAActivationCode data) {
    print('SDKEventProvider - Get activation code event received');
    print('  Status Code: ${data.challengeResponse?.status?.statusCode}');
    print('  UserID: ${data.userId}, AttemptsLeft: ${data.attemptsLeft}');

    appRouter.goNamed('activationCodeScreen', extra: data);
  }

  /// Event handler for get user consent for LDA requests
  ///
  /// Navigates to UserLDAConsentScreen with event data
  void _handleGetUserConsentForLDA(GetUserConsentForLDAData data) {
    print('SDKEventProvider - Get user consent for LDA event received');
    print('  UserID: ${data.userID}');
    print('  ChallengeMode: ${data.challengeMode}');
    print('  AuthenticationType: ${data.authenticationType}');

    appRouter.goNamed('userLDAConsentScreen', extra: data);
  }

  /// Event handler for get password requests
  ///
  /// Navigates to SetPasswordScreen (mode 1) or VerifyPasswordScreen (mode 0)
  /// based on challengeMode
  void _handleGetPassword(RDNAGetPassword data) {
    print('SDKEventProvider - Get password event received');
    print('  Status Code: ${data.challengeResponse?.status?.statusCode}');
    print('  UserID: ${data.userId}, ChallengeMode: ${data.challengeMode}, AttemptsLeft: ${data.attemptsLeft}');

    // Navigate based on challenge mode (challengeMode is int, not enum)
    // 0 = RDNA_CHALLENGE_OP_VERIFY (verify existing password)
    // 1 = RDNA_CHALLENGE_OP_SET (set new password)
    if (data.challengeMode == 0) {
      // Mode 0: Verify existing password (login)
      appRouter.goNamed('verifyPasswordScreen', extra: data);
    } else {
      // Mode 1 or other: Set new password
      appRouter.goNamed('setPasswordScreen', extra: data);
    }
  }

  /// Event handler for user logged in event
  ///
  /// Navigates to Dashboard with session data
  void _handleUserLoggedIn(RDNAUserLoggedIn data) {
    print('SDKEventProvider - User logged in event received');
    print('  UserID: ${data.userId}');
    print('  Session ID: ${data.challengeResponse?.session?.sessionId}');

    appRouter.goNamed('dashboardScreen', extra: data);
  }

  /// Event handler for user logged off event
  ///
  /// Logs the event (SDK will automatically trigger getUser)
  void _handleUserLoggedOff(RDNAUserLogOff data) {
    print('SDKEventProvider - User logged off event received');
    print('  Status Code: ${data.challengeResponse?.status?.statusCode}');
    print('  Error Code: ${data.error?.longErrorCode}');
    // SDK will automatically trigger getUser event, so just log
  }

  /// Event handler for credentials available for update event
  ///
  /// Logs the event (will be handled by dashboard menu visibility)
  void _handleCredentialsAvailableForUpdate(RDNACredentialsAvailableForUpdate data) {
    print('SDKEventProvider - Credentials available for update event received');
    print('  Available options: ${data.options}');
    // Will be handled by dashboard to show/hide update password menu
  }

  @override
  void dispose() {
    // Cleanup on component unmount (React's useEffect cleanup)
    print('SDKEventProvider - Component unmounting, cleaning up event handlers');
    final rdnaService = RdnaService.getInstance();
    rdnaService.cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the rdna service provider to ensure it's initialized
    ref.watch(rdnaServiceProvider);

    // Return the child (wrapped app), similar to React's
    // <SDKEventContext.Provider value={contextValue}>
    //   {children}
    // </SDKEventContext.Provider>
    return widget.child;
  }
}
