// ============================================================================
// File: app_router.dart
// Description: Application Router
//
// Defines all application routes using GoRouter for type-safe navigation.
// Handles route parameters for error and success screens.
// ============================================================================

import 'package:go_router/go_router.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../screens/tutorial/tutorial_home_screen.dart';
import '../screens/tutorial/tutorial_success_screen.dart';
import '../screens/tutorial/tutorial_error_screen.dart';
import '../screens/tutorial/security_exit_screen.dart';
import '../screens/mfa/check_user_screen.dart';
import '../screens/mfa/activation_code_screen.dart';
import '../screens/mfa/set_password_screen.dart';
import '../screens/mfa/verify_password_screen.dart';
import '../screens/mfa/update_expiry_password_screen.dart';
import '../screens/mfa/verify_auth_screen.dart';
import '../screens/mfa/user_lda_consent_screen.dart';
import '../screens/mfa/dashboard_screen.dart';
import '../screens/notification/get_notifications_screen.dart';

/// Application Router
///
/// Defines all routes for the application using GoRouter.
/// Provides type-safe navigation with parameter passing via `extra`.
///
/// ## Routes
/// - `/` (home): Tutorial home screen with initialization button
/// - `/success` (success): Success screen after initialization
/// - `/error` (error): Error screen if initialization fails
/// - `/security-exit` (securityExit): iOS-compliant security exit guidance screen
/// - `/check-user` (checkUserScreen): MFA user validation screen
/// - `/activation-code` (activationCodeScreen): MFA activation code/OTP screen
/// - `/set-password` (setPasswordScreen): MFA password creation screen
/// - `/verify-password` (verifyPasswordScreen): MFA password verification screen
/// - `/update-expiry-password` (updateExpiryPasswordScreen): MFA expired password update screen (challengeMode 4)
/// - `/verify-auth` (verifyAuthScreen): Additional device activation via REL-ID Verify
/// - `/user-lda-consent` (userLDAConsentScreen): MFA LDA consent screen
/// - `/dashboard` (dashboardScreen): Post-authentication dashboard
/// - `/get-notifications` (getNotificationsScreen): Notification management (primary device approval)
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'tutorialHomeScreen',
      builder: (context, state) => const TutorialHomeScreen(),
    ),
    GoRoute(
      path: '/tutorial-success-screen',
      name: 'tutorialSuccessScreen',
      builder: (context, state) {
        final data = state.extra as RDNAInitialized;
        return TutorialSuccessScreen(data: data);
      },
    ),
    GoRoute(
      path: '/tutorial-error-screen',
      name: 'tutorialErrorScreen',
      builder: (context, state) {
        final error = state.extra as RDNAInitializeError;
        return TutorialErrorScreen(error: error);
      },
    ),
    GoRoute(
      path: '/security-exit',
      name: 'securityExit',
      builder: (context, state) => const SecurityExitScreen(),
    ),
    // MFA Routes
    GoRoute(
      path: '/check-user',
      name: 'checkUserScreen',
      builder: (context, state) {
        final data = state.extra as RDNAGetUser?;
        return CheckUserScreen(eventData: data);
      },
    ),
    GoRoute(
      path: '/activation-code',
      name: 'activationCodeScreen',
      builder: (context, state) {
        final data = state.extra as RDNAActivationCode?;
        return ActivationCodeScreen(eventData: data);
      },
    ),
    GoRoute(
      path: '/set-password',
      name: 'setPasswordScreen',
      builder: (context, state) {
        final data = state.extra as RDNAGetPassword?;
        return SetPasswordScreen(eventData: data);
      },
    ),
    GoRoute(
      path: '/verify-password',
      name: 'verifyPasswordScreen',
      builder: (context, state) {
        final data = state.extra as RDNAGetPassword?;
        return VerifyPasswordScreen(eventData: data);
      },
    ),
    GoRoute(
      path: '/update-expiry-password',
      name: 'updateExpiryPasswordScreen',
      builder: (context, state) {
        final data = state.extra as RDNAGetPassword?;
        return UpdateExpiryPasswordScreen(eventData: data);
      },
    ),
    GoRoute(
      path: '/verify-auth',
      name: 'verifyAuthScreen',
      builder: (context, state) {
        final data = state.extra as RDNAAddNewDeviceOptions;
        return VerifyAuthScreen(deviceOptions: data);
      },
    ),
    GoRoute(
      path: '/user-lda-consent',
      name: 'userLDAConsentScreen',
      builder: (context, state) {
        final data = state.extra as GetUserConsentForLDAData?;
        return UserLDAConsentScreen(eventData: data);
      },
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboardScreen',
      builder: (context, state) {
        final data = state.extra as RDNAUserLoggedIn?;
        return DashboardScreen(eventData: data);
      },
    ),
    GoRoute(
      path: '/get-notifications',
      name: 'getNotificationsScreen',
      builder: (context, state) {
        final data = state.extra as RDNAUserLoggedIn?;
        return GetNotificationsScreen(sessionData: data);
      },
    ),
  ],
);
