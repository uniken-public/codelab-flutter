// ============================================================================
// File: session_provider.dart
// Description: Session Management Provider
//
// Transformed from: SessionContext.tsx
// Original React Native codelab: relid-MFA-session-management
//
// Manages global session timeout state and provides session management
// functionality across the application using Riverpod state management.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../services/rdna_service.dart';
import '../services/rdna_event_manager.dart';
import '../../tutorial/navigation/app_router.dart';

/// Session state managed by SessionProvider
class SessionState {
  final bool isSessionModalVisible;
  final String? sessionTimeoutMessage;
  final SessionResponse? sessionTimeoutNotificationData;
  final bool isProcessing;

  const SessionState({
    this.isSessionModalVisible = false,
    this.sessionTimeoutMessage,
    this.sessionTimeoutNotificationData,
    this.isProcessing = false,
  });

  SessionState copyWith({
    bool? isSessionModalVisible,
    String? sessionTimeoutMessage,
    SessionResponse? sessionTimeoutNotificationData,
    bool? isProcessing,
    bool clearTimeoutMessage = false,
    bool clearNotificationData = false,
  }) {
    return SessionState(
      isSessionModalVisible: isSessionModalVisible ?? this.isSessionModalVisible,
      sessionTimeoutMessage: clearTimeoutMessage ? null : (sessionTimeoutMessage ?? this.sessionTimeoutMessage),
      sessionTimeoutNotificationData: clearNotificationData ? null : (sessionTimeoutNotificationData ?? this.sessionTimeoutNotificationData),
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

/// Session Management Provider
///
/// Manages global session timeout state and provides session management
/// functionality using Riverpod.
///
/// ## Features
/// - Global session timeout modal management
/// - Session extension API integration
/// - Automatic navigation on session expiry
/// - Loading states for session operations
///
/// ## Events Handled
/// - onSessionTimeout: Hard session timeout (mandatory)
/// - onSessionTimeOutNotification: Idle timeout warning
/// - onSessionExtensionResponse: Extension result
class SessionNotifier extends StateNotifier<SessionState> {
  final RdnaService _rdnaService;
  final RdnaEventManager _eventManager;
  String _currentOperation = 'none';

  SessionNotifier(this._rdnaService, this._eventManager)
      : super(const SessionState()) {
    _setupEventHandlers();
  }

  /// Sets up session event handlers
  void _setupEventHandlers() {
    print('SessionProvider - Setting up session event handlers');

    // Session timeout event (hard timeout - mandatory)
    _eventManager.setSessionTimeoutHandler((String message) {
      print('SessionProvider - Session timeout received: $message');
      _showSessionTimeout(message);
    });

    // Session timeout notification event (idle timeout warning)
    _eventManager.setSessionTimeoutNotificationHandler((dynamic data) {
      print('SessionProvider - Session timeout notification received');

      // Cast to SessionResponse
      final sessionResponse = data as SessionResponse;
      print('SessionProvider - Session notification data:');
      print('  UserID: ${sessionResponse.userID}');
      print('  Message: ${sessionResponse.message}');
      print('  TimeLeft: ${sessionResponse.timeLeftInSeconds}s');
      print('  CanExtend: ${sessionResponse.sessionCanBeExtended}');

      _showSessionTimeoutNotification(sessionResponse);
    });

    // Session extension response event
    _eventManager.setSessionExtensionResponseHandler((dynamic data) {
      print('SessionProvider - Session extension response received');

      // Cast to SessionResponse
      final sessionResponse = data as SessionResponse;
      print('SessionProvider - Extension response data:');
      print('  UserID: ${sessionResponse.userID}');
      print('  Message: ${sessionResponse.message}');
      print('  TimeLeft: ${sessionResponse.timeLeftInSeconds}s');

      _handleSessionExtensionResponse(sessionResponse);
    });
  }

  /// Shows session timeout modal (hard timeout)
  void _showSessionTimeout(String message) {
    print('SessionProvider - Session timed out, showing modal');

    state = state.copyWith(
      isSessionModalVisible: true,
      sessionTimeoutMessage: message,
      clearNotificationData: true,
      isProcessing: false,
    );
    _currentOperation = 'none';
  }

  /// Shows session timeout notification modal (idle timeout warning)
  void _showSessionTimeoutNotification(SessionResponse data) {
    print('SessionProvider - Showing session timeout notification modal');

    state = state.copyWith(
      isSessionModalVisible: true,
      sessionTimeoutNotificationData: data,
      clearTimeoutMessage: true,
      isProcessing: false,
    );
    _currentOperation = 'none';
  }

  /// Hides session modal
  void hideSessionModal() {
    print('SessionProvider - Hiding session modal');

    state = state.copyWith(
      isSessionModalVisible: false,
      clearTimeoutMessage: true,
      clearNotificationData: true,
      isProcessing: false,
    );
    _currentOperation = 'none';
  }

  /// Handles extend session button press
  Future<void> handleExtendSession(BuildContext context) async {
    print('SessionProvider - User chose to extend session');

    if (_currentOperation != 'none') {
      print('SessionProvider - Operation already in progress, ignoring extend request');
      return;
    }

    state = state.copyWith(isProcessing: true);
    _currentOperation = 'extend';

    // Call extend session API and check sync response (like setUser pattern)
    final response = await _rdnaService.extendSessionIdleTimeout();

    print('SessionProvider - ExtendSessionIdleTimeout sync response received');
    print('  Long Error Code: ${response.error?.longErrorCode}');

    // Check sync response for immediate errors
    if (response.error?.longErrorCode != 0) {
      // Sync error - stop and show error
      print('SessionProvider - Extension sync error: ${response.error?.errorString}');
      state = state.copyWith(isProcessing: false);
      _currentOperation = 'none';

      // Show error alert to user
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Extension Failed'),
            content: Text(
              'Failed to extend session:\n\n${response.error?.errorString}\n\nError Code: ${response.error?.longErrorCode}',
            ),
            actions: [
              TextButton(
                onPressed: () => {},
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Sync success - wait for onSessionExtensionResponse event
    print('SessionProvider - Extension sync success, waiting for async event...');
    // Note: Event handler (_handleSessionExtensionResponse) will hide modal
  }

  /// Handles dismiss button press
  void handleDismiss(BuildContext context) {
    print('SessionProvider - User dismissed session modal');

    // Check timeout type BEFORE hiding modal (state will be cleared)
    final hasTimeoutMessage = state.sessionTimeoutMessage != null;
    final hasIdleNotification = state.sessionTimeoutNotificationData != null;

    print('SessionProvider - Dismiss check: hasTimeoutMessage=$hasTimeoutMessage, hasIdleNotification=$hasIdleNotification');

    // Hide modal first
    hideSessionModal();

    // For hard session timeout (mandatory), navigate to home screen
    if (hasTimeoutMessage) {
      print('SessionProvider - Hard session timeout - navigating to home screen');
      appRouter.go('/');
    }

    // For session timeout notification, just dismiss - user chose to let it expire
    if (hasIdleNotification) {
      print('SessionProvider - User chose to let idle session expire');
    }
  }

  /// Handles session extension response event from SDK
  ///
  /// Event fires after extendSessionIdleTimeout() API is called.
  /// Event firing indicates the extension request was processed (success).
  void _handleSessionExtensionResponse(SessionResponse data) {
    print('SessionProvider - Extension response event received');
    print('SessionProvider - Event data: TimeLeft=${data.timeLeftInSeconds}s, Message="${data.message}"');

    // Only process if we're currently extending
    if (_currentOperation != 'extend') {
      print('SessionProvider - Extension response received but no extend operation in progress, ignoring');
      return;
    }

    // Event firing indicates success - hide the modal
    print('SessionProvider - Session extension successful (event received)');
    hideSessionModal();
  }

  /// Cleanup event handlers
  @override
  void dispose() {
    print('SessionProvider - Disposing session provider');
    _eventManager.setSessionTimeoutHandler(null);
    _eventManager.setSessionTimeoutNotificationHandler(null);
    _eventManager.setSessionExtensionResponseHandler(null);
    super.dispose();
  }
}

/// Global session provider
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final rdnaService = RdnaService.getInstance();
  final eventManager = rdnaService.getEventManager();
  return SessionNotifier(rdnaService, eventManager);
});
