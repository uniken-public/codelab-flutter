// ============================================================================
// File: main.dart
// Description: Main Application Entry Point
//
// Main entry point for the Flutter REL-ID integration tutorial application.
// Wraps the app with SDKEventProviderWidget for global event handling,
// similar to React Native's Context Provider pattern.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tutorial/navigation/app_router.dart';
import 'uniken/providers/sdk_event_provider.dart';
import 'uniken/providers/mtd_threat_provider.dart';
import 'uniken/components/threat_detection_modal.dart';
import 'dart:io' show Platform;

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Main Application Widget
///
/// Sets up the application with:
/// - Riverpod for state management
/// - SDKEventProviderWidget for global SDK event handling
/// - MTD Threat Provider for Mobile Threat Detection
/// - GoRouter for navigation
/// - Global ThreatDetectionModal overlay

/// ```
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch MTD threat state for global modal display
    final mtdState = ref.watch(mtdThreatProvider);

    // Handle iOS security exit navigation
    ref.listen<MTDThreatState>(mtdThreatProvider, (previous, next) {
      if (next.shouldNavigateToSecurityExit && (previous?.shouldNavigateToSecurityExit != true)) {
        print('MyApp - Detected iOS security exit flag, navigating to /security-exit');
        appRouter.go('/security-exit');
        // Clear the flag after navigation
        ref.read(mtdThreatProvider.notifier).clearSecurityExitNavigation();
      }
    });

    return SDKEventProviderWidget(
      child: MaterialApp.router(
        title: 'REL-ID MTD Tutorial',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
        builder: (context, child) {
          return Stack(
            children: [
              // Main app content
              child ?? const SizedBox.shrink(),
              // Global MTD Threat Detection Modal
              ThreatDetectionModal(
                visible: mtdState.isModalVisible,
                threats: mtdState.threats,
                isConsentMode: mtdState.isConsentMode,
                isProcessing: mtdState.isProcessing,
                processingExit: mtdState.pendingExitThreats.isNotEmpty,
                onProceed: mtdState.isConsentMode
                    ? () => ref.read(mtdThreatProvider.notifier).handleProceed(context)
                    : null,
                onExit: () {
                  final notifier = ref.read(mtdThreatProvider.notifier);
                  if (Platform.isIOS && !mtdState.isConsentMode) {
                    // iOS terminate mode: navigate to SecurityExitScreen
                    appRouter.go('/security-exit');
                    notifier.hideThreatModal();
                  } else {
                    // All other cases: use provider's handleExit
                    notifier.handleExit(context);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
