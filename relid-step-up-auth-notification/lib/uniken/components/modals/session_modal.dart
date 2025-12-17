// ============================================================================
// File: session_modal.dart
// Description: Session Management Modal
//
// Transformed from: SessionModal.tsx
// Original React Native codelab: relid-MFA-session-management
//
// Displays session timeout modals with countdown timers and extension
// capabilities. Handles both hard session timeouts and idle timeout warnings.
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/session_provider.dart';

/// Session Modal Widget
///
/// Displays session timeout information with countdown timer and action buttons.
/// Supports two types of session timeouts:
/// - Hard Timeout: Mandatory session expiration (Close button only)
/// - Idle Timeout: Warning with optional extension (Extend Session + Close buttons)
///
/// ## Features
/// - Countdown timer with accurate background/foreground tracking
/// - Dynamic header colors based on timeout type
/// - Extension button (when session can be extended)
/// - Loading states during extension
/// - Hardware back button prevention on Android
class SessionModal extends ConsumerStatefulWidget {
  const SessionModal({Key? key}) : super(key: key);

  @override
  ConsumerState<SessionModal> createState() => _SessionModalState();
}

class _SessionModalState extends ConsumerState<SessionModal> with WidgetsBindingObserver {
  Timer? _countdownTimer;
  int _countdown = 0;
  DateTime? _backgroundTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app state changes for accurate countdown when app goes to background/foreground
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App going to background - record the time
      _backgroundTime = DateTime.now();
      print('SessionModal - App going to background, recording time');
    } else if (state == AppLifecycleState.resumed && _backgroundTime != null) {
      // App returning to foreground - calculate elapsed time
      final elapsedSeconds = DateTime.now().difference(_backgroundTime!).inSeconds;
      print('SessionModal - App returning to foreground, elapsed: ${elapsedSeconds}s');

      // Update countdown based on actual elapsed time
      setState(() {
        _countdown = (_countdown - elapsedSeconds).clamp(0, double.infinity).toInt();
        print('SessionModal - Countdown updated to: $_countdown');
      });

      _backgroundTime = null;
    }
  }

  void _startCountdown(int timeLeftInSeconds) {
    _countdown = timeLeftInSeconds;
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    final sessionNotifier = ref.read(sessionProvider.notifier);

    // Don't show modal if not visible
    if (!sessionState.isSessionModalVisible) {
      _countdownTimer?.cancel();
      return const SizedBox.shrink();
    }

    // Determine session type
    final isMandatoryTimeout = sessionState.sessionTimeoutMessage != null;
    final isIdleTimeout = sessionState.sessionTimeoutNotificationData != null;

    // Initialize countdown for idle timeout
    if (isIdleTimeout && _countdownTimer == null) {
      final data = sessionState.sessionTimeoutNotificationData;
      if (data != null) {
        _startCountdown(data.timeLeftInSeconds);
      }
    }

    // Get display message
    String displayMessage = 'Session timeout occurred.';
    if (isMandatoryTimeout) {
      displayMessage = sessionState.sessionTimeoutMessage!;
    } else if (isIdleTimeout && sessionState.sessionTimeoutNotificationData != null) {
      displayMessage = sessionState.sessionTimeoutNotificationData!.message;
    }

    // Check if session can be extended
    bool canExtendSession = false;
    if (isIdleTimeout && sessionState.sessionTimeoutNotificationData != null) {
      canExtendSession = sessionState.sessionTimeoutNotificationData!.sessionCanBeExtended == 1;
    }

    // Get modal configuration
    final config = _getModalConfig(isMandatoryTimeout, isIdleTimeout, canExtendSession);

    return PopScope(
      canPop: false, // Prevent back button dismissal
      child: GestureDetector(
        onTap: () {}, // Absorb taps - prevent background interaction
        child: Material(
          color: Colors.black.withOpacity(0.8), // Full-screen modal barrier
          child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: config.headerColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      config.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      config.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Icon and Message
                    Column(
                      children: [
                        Text(
                          config.icon,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayMessage,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1f2937),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    // Countdown display for idle timeout
                    if (isIdleTimeout && _countdown > 0) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFfef3c7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFf59e0b),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Time Remaining:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF92400e),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(_countdown / 60).floor()}:${(_countdown % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFd97706),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFf3f4f6)),
                  ),
                ),
                child: Column(
                  children: [
                    // Hard timeout - only Close option
                    if (isMandatoryTimeout)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => sessionNotifier.handleDismiss(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6b7280),
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    // Idle timeout - extend or dismiss options
                    if (isIdleTimeout) ...[
                      if (canExtendSession)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: sessionState.isProcessing
                                ? null
                                : () => sessionNotifier.handleExtendSession(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3b82f6),
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: sessionState.isProcessing
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Extending...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Extend Session',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: sessionState.isProcessing
                              ? null
                              : () => sessionNotifier.handleDismiss(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6b7280),
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Get modal configuration based on session type
  _ModalConfig _getModalConfig(bool isMandatoryTimeout, bool isIdleTimeout, bool canExtendSession) {
    if (isMandatoryTimeout) {
      return _ModalConfig(
        title: '🔐 Session Expired',
        subtitle: 'Your session has expired. You will be redirected to the home screen.',
        headerColor: const Color(0xFFdc2626), // Red for hard timeout
        icon: '🔐',
      );
    }

    if (isIdleTimeout) {
      return _ModalConfig(
        title: '⚠️ Session Timeout Warning',
        subtitle: canExtendSession
            ? 'Your session will expire soon. You can extend it or let it timeout.'
            : 'Your session will expire soon.',
        headerColor: const Color(0xFFf59e0b), // Orange for idle timeout
        icon: '⏱️',
      );
    }

    return _ModalConfig(
      title: '⏰ Session Management',
      subtitle: 'Session timeout notification',
      headerColor: const Color(0xFF6b7280),
      icon: '🔐',
    );
  }
}

class _ModalConfig {
  final String title;
  final String subtitle;
  final Color headerColor;
  final String icon;

  _ModalConfig({
    required this.title,
    required this.subtitle,
    required this.headerColor,
    required this.icon,
  });
}
