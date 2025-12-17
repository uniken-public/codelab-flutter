// ============================================================================
// File: sdk_event_provider.dart
// Description: SDK Event Provider
//
// Transformed from: src/uniken/providers/SDKEventProvider.tsx
// Original: SDKEventProvider.tsx
//
// Centralized provider for REL-ID SDK event handling.
// Manages all SDK events globally, similar to React Native Context Provider.
//
// Key Features:
// - Global event handling for SDK initialization success
// - Automatic navigation on successful initialization
// - Centralized state management for SDK events
// - React-like provider pattern
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
