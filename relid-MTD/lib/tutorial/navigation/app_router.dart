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
  ],
);
