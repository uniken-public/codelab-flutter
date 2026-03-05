// ============================================================================
// File: mtd_threat_provider.dart
// Description: Mobile Threat Detection Provider
//
// Global Riverpod provider for Mobile Threat Detection (MTD) functionality.
// Manages threat detection UI state, user decisions, and platform-specific
// exit strategies.
//
// Key Features:
// - Global threat state management via Riverpod
// - User consent threat handling (proceed or exit options)
// - Terminate threat handling (exit only)
// - Platform-specific exit strategies (iOS: SecurityExitScreen, Android: SystemNavigator.pop())
// - Self-triggered event detection (prevents double-dialog on user exit choice)
// - Threat action API integration
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import 'dart:io' show Platform, exit;

import '../services/rdna_service.dart';

/// MTD Threat State
///
/// Holds the current state of threat detection and modal display
class MTDThreatState {
  final bool isModalVisible;
  final List<RDNAThreat> threats;
  final bool isConsentMode;
  final bool isProcessing;
  final List<int> pendingExitThreats; // Threat IDs being processed for exit
  final bool shouldNavigateToSecurityExit; // Signal for iOS security exit navigation

  const MTDThreatState({
    this.isModalVisible = false,
    this.threats = const [],
    this.isConsentMode = false,
    this.isProcessing = false,
    this.pendingExitThreats = const [],
    this.shouldNavigateToSecurityExit = false,
  });

  MTDThreatState copyWith({
    bool? isModalVisible,
    List<RDNAThreat>? threats,
    bool? isConsentMode,
    bool? isProcessing,
    List<int>? pendingExitThreats,
    bool? shouldNavigateToSecurityExit,
  }) {
    return MTDThreatState(
      isModalVisible: isModalVisible ?? this.isModalVisible,
      threats: threats ?? this.threats,
      isConsentMode: isConsentMode ?? this.isConsentMode,
      isProcessing: isProcessing ?? this.isProcessing,
      pendingExitThreats: pendingExitThreats ?? this.pendingExitThreats,
      shouldNavigateToSecurityExit: shouldNavigateToSecurityExit ?? this.shouldNavigateToSecurityExit,
    );
  }
}

/// MTD Threat Provider
///
/// Riverpod StateNotifier for managing threat detection state and actions
class MTDThreatNotifier extends StateNotifier<MTDThreatState> {
  final RdnaService _rdnaService;

  MTDThreatNotifier(this._rdnaService) : super(const MTDThreatState()) {
    _registerEventHandlers();
  }

  /// Registers SDK event handlers for threat detection
  void _registerEventHandlers() {
    final eventManager = _rdnaService.getEventManager();

    // Override threat handlers with MTD-specific logic
    eventManager.setUserConsentThreatsHandler((threats) {
      print('MTDThreatProvider - User consent threats received: ${threats.length}');
      showThreatModal(threats, true);
    });

    eventManager.setTerminateWithThreatsHandler((threats) {
      print('MTDThreatProvider - Terminate with threats received: ${threats.length}');

      // Check if this is a self-triggered terminate event (result of our own takeActionOnThreats call)
      // by comparing incoming threat IDs with the ones we're currently processing for exit
      final incomingThreatIds = threats.map((threat) => threat.threatId ?? 0).toList();
      final currentPendingThreats = state.pendingExitThreats;

      print('Threat comparison debug:');
      print('  pendingExitThreats: $currentPendingThreats');
      print('  incomingThreatIds: $incomingThreatIds');

      final isSelfTriggered = currentPendingThreats.isNotEmpty &&
          incomingThreatIds.every((id) => currentPendingThreats.contains(id)) &&
          incomingThreatIds.length == currentPendingThreats.length;

      if (isSelfTriggered) {
        print('Self-triggered terminate event - exiting directly without showing dialog');
        // Clear pending state since we're handling the exit now
        state = state.copyWith(
          pendingExitThreats: [],
          isProcessing: false,
          isModalVisible: false,
        );

        // Direct app termination - user already made the decision in consent mode
        print('MTDThreatProvider: Self-triggered terminate event - processing exit');
        _handlePlatformSpecificExit('self-triggered');
      } else {
        print('Genuine terminate event - showing dialog for user action');
        // Genuine terminate event from external source - show dialog as normal
        state = state.copyWith(isProcessing: false);
        showThreatModal(threats, false);
      }
    });
  }

  /// Shows the threat modal with given threats and mode
  void showThreatModal(List<RDNAThreat> threats, bool isConsent) {
    print('Showing threat modal:');
    print('  threatCount: ${threats.length}');
    print('  isConsentMode: $isConsent');

    state = state.copyWith(
      threats: threats,
      isConsentMode: isConsent,
      isModalVisible: true,
    );
  }

  /// Hides the threat modal and resets state
  void hideThreatModal() {
    print('Hiding threat modal');
    state = state.copyWith(
      isModalVisible: false,
      threats: [],
      isConsentMode: false,
      isProcessing: false,
    );
  }

  /// User chose to proceed despite threats
  Future<void> handleProceed(BuildContext context) async {
    print('User chose to proceed with threats');
    state = state.copyWith(isProcessing: true);

    // Modify all threats to proceed with action
    // This implementation chooses to proceed with all threats and remember the decision
    final modifiedThreats = state.threats.map((threat) {
      return RDNAThreat(
        threatId: threat.threatId,
        threatName: threat.threatName,
        threatMsg: threat.threatMsg,
        threatReason: threat.threatReason,
        threatCategory: threat.threatCategory,
        threatSeverity: threat.threatSeverity,
        configuredAction: threat.configuredAction,
        appInfo: threat.appInfo,
        networkInfo: threat.networkInfo,
        shouldProceedWithThreats: true, // Allow app to continue despite threats
        rememberActionForSession: true, // Remember this decision for the current session
      );
    }).toList();

    print('Calling takeActionOnThreats with ${modifiedThreats.length} threats');

    // Call RdnaService to take action on threats
    final response = await _rdnaService.takeActionOnThreats(modifiedThreats);

    print('RDNA takeAction promise resolved');
    print('  Long Error Code: ${response.error?.longErrorCode}');

    // Check error code (0 = success, non-zero = error)
    if (response.error?.longErrorCode != 0) {
      print('RDNA takeAction API returned error code: ${response.error?.longErrorCode}');
      state = state.copyWith(isProcessing: false);

      // Show error alert
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Failed to proceed with threats'),
            content: Text('Error Code: ${response.error?.longErrorCode}\n${response.error?.errorString ?? "Unknown error"}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    print('RDNA takeAction successful - error code 0');
    // Success will be handled by the async event callbacks
    // Don't need to do anything here as events will navigate to success screen
    hideThreatModal();
  }

  /// User chose to exit application due to threats
  Future<void> handleExit(BuildContext context) async {
    print('User chose to exit application due to threats');

    if (state.isConsentMode) {
      print('Consent mode: calling takeAction with shouldProceedWithThreats = false');
      state = state.copyWith(isProcessing: true);

      // Track threat IDs for pending exit to identify self-triggered terminateWithThreats events
      // This prevents showing the threat dialog twice when the API call triggers terminateWithThreats
      final threatIds = state.threats.map((threat) => threat.threatId ?? 0).toList();
      state = state.copyWith(pendingExitThreats: threatIds);
      print('Tracking pending exit for threat IDs: $threatIds');

      // Modify all threats to NOT proceed with action
      final modifiedThreats = state.threats.map((threat) {
        return RDNAThreat(
          threatId: threat.threatId,
          threatName: threat.threatName,
          threatMsg: threat.threatMsg,
          threatReason: threat.threatReason,
          threatCategory: threat.threatCategory,
          threatSeverity: threat.threatSeverity,
          configuredAction: threat.configuredAction,
          appInfo: threat.appInfo,
          networkInfo: threat.networkInfo,
          shouldProceedWithThreats: false, // Do not allow app to continue with threats
          rememberActionForSession: true, // Remember this decision for the current session
        );
      }).toList();

      print('Calling takeActionOnThreats for exit action with ${modifiedThreats.length} threats');

      // Call RdnaService to take action on threats (required for tracking purposes)
      // This will trigger a terminateWithThreats event which we'll handle differently
      final response = await _rdnaService.takeActionOnThreats(modifiedThreats);

      print('RDNA takeAction promise resolved');
      print('  Long Error Code: ${response.error?.longErrorCode}');

      // Check error code (0 = success, non-zero = error)
      if (response.error?.longErrorCode != 0) {
        print('RDNA takeAction API returned error code: ${response.error?.longErrorCode}');
        // Clear pending state on error
        state = state.copyWith(
          pendingExitThreats: [],
          isProcessing: false,
        );

        // Show error alert
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Failed to process threat action'),
              content: Text('Error Code: ${response.error?.longErrorCode}\n${response.error?.errorString ?? "Unknown error"}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

      print('RDNA takeAction successful - threats rejected, awaiting terminateWithThreats event');
      // The terminateWithThreats event will be handled by the callback
      // and should directly exit without showing dialog since we're tracking this as pending
    } else {
      print('MTDThreatProvider: Terminate mode - directly exiting application');
      // Direct exit for terminate mode (genuine terminate events)
      hideThreatModal();
      _handlePlatformSpecificExit('terminate');
    }
  }

  /// Platform-specific exit handler
  ///
  /// iOS: Signal navigation to SecurityExitScreen (HIG-compliant exit guidance)
  /// Android/Other: Use exit(0) for forceful app termination (required for security threats)
  void _handlePlatformSpecificExit(String exitType) {
    print('MTDThreatProvider: Platform-specific exit called');
    print('  platform: ${Platform.operatingSystem}');
    print('  exitType: $exitType');

    if (Platform.isIOS) {
      print('MTDThreatProvider: iOS detected - signaling SecurityExitScreen navigation');
      // iOS: Signal that we need to navigate to SecurityExitScreen
      // The UI (main.dart) will watch for this flag and handle navigation
      state = state.copyWith(shouldNavigateToSecurityExit: true);
    } else {
      print('MTDThreatProvider: Android detected - using exit(0) for forceful termination');
      // Android: Use exit(0) for forceful app termination
      // This is appropriate for security threat scenarios where app MUST exit
      exit(0);
    }
  }

  /// Clears the navigation flag after navigation has been handled
  void clearSecurityExitNavigation() {
    state = state.copyWith(shouldNavigateToSecurityExit: false);
  }

  @override
  void dispose() {
    print('MTDThreatProvider cleanup');
    super.dispose();
  }
}

/// MTD Threat Provider
///
/// Global provider for threat detection state and actions
final mtdThreatProvider = StateNotifierProvider<MTDThreatNotifier, MTDThreatState>((ref) {
  final rdnaService = RdnaService.getInstance();
  return MTDThreatNotifier(rdnaService);
});
