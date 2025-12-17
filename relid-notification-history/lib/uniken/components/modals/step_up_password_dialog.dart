// ============================================================================
// File: step_up_password_dialog.dart
// Description: Step-Up Password Dialog Component
//
// Modal dialog for step-up authentication during notification actions.
// Handles challengeMode = 3 (RDNA_OP_AUTHORIZE_NOTIFICATION) when the SDK
// requires password verification before allowing a notification action.
//
// Features:
// - Password input with visibility toggle
// - Attempts left counter with color coding
// - Error message display
// - Loading state during authentication
// - Notification context display
// - Auto-focus on password field
// - Hardware back button handling (Android)
//
// Transformed from: React Native StepUpPasswordDialog.tsx
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Step-Up Password Dialog Component
///
/// Modal dialog for step-up authentication during notification actions.
/// Handles challengeMode = 3 (RDNA_OP_AUTHORIZE_NOTIFICATION).
///
/// ## Parameters
/// - [visible]: Whether the dialog is visible
/// - [notificationTitle]: Title of the notification being authorized
/// - [notificationMessage]: Message of the notification being authorized
/// - [userID]: User identifier
/// - [attemptsLeft]: Number of remaining password attempts
/// - [errorMessage]: Error message to display (if any)
/// - [isSubmitting]: Whether password verification is in progress
/// - [onSubmitPassword]: Callback when password is submitted
/// - [onCancel]: Callback when user cancels the dialog
///
/// ## Example
/// ```dart
/// StepUpPasswordDialog(
///   visible: showStepUpAuth,
///   notificationTitle: 'Payment Approval',
///   notificationMessage: 'Approve payment of \$500',
///   userID: 'john.doe',
///   attemptsLeft: 3,
///   errorMessage: errorMsg,
///   isSubmitting: isSubmitting,
///   onSubmitPassword: (password) => handlePasswordSubmit(password),
///   onCancel: () => setState(() => showStepUpAuth = false),
/// )
/// ```
class StepUpPasswordDialog extends StatefulWidget {
  final bool visible;
  final String notificationTitle;
  final String notificationMessage;
  final String userID;
  final int attemptsLeft;
  final String? errorMessage;
  final bool isSubmitting;
  final Function(String) onSubmitPassword;
  final VoidCallback onCancel;

  const StepUpPasswordDialog({
    super.key,
    required this.visible,
    required this.notificationTitle,
    required this.notificationMessage,
    required this.userID,
    required this.attemptsLeft,
    this.errorMessage,
    required this.isSubmitting,
    required this.onSubmitPassword,
    required this.onCancel,
  });

  @override
  State<StepUpPasswordDialog> createState() => _StepUpPasswordDialogState();
}

class _StepUpPasswordDialogState extends State<StepUpPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();

    // Add listener to rebuild when text changes (to enable/disable button)
    _passwordController.addListener(() {
      setState(() {
        // Rebuild to update button state
      });
    });

    // Auto-focus password input when dialog opens
    if (widget.visible) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _passwordFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(StepUpPasswordDialog oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Clear password when modal becomes visible or when error changes
    if (widget.visible && !oldWidget.visible) {
      _passwordController.clear();
      _showPassword = false;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _passwordFocusNode.requestFocus();
        }
      });
    }

    // Clear password field when error message changes (wrong password)
    if (widget.errorMessage != null && widget.errorMessage != oldWidget.errorMessage) {
      _passwordController.clear();
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_passwordController.text.trim().isEmpty || widget.isSubmitting) {
      return;
    }
    widget.onSubmitPassword(_passwordController.text.trim());
  }

  /// Get color for attempts counter based on remaining attempts
  Color _getAttemptsColor() {
    if (widget.attemptsLeft == 1) return const Color(0xFFDC2626); // Red
    if (widget.attemptsLeft == 2) return const Color(0xFFF59E0B); // Orange
    return const Color(0xFF10B981); // Green
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    return PopScope(
      canPop: !widget.isSubmitting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !widget.isSubmitting) {
          widget.onCancel();
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: const Column(
                  children: [
                    Text(
                      '🔐 Authentication Required',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please verify your password to authorize this action',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFDBEAFE),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Notification Title
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(
                              color: Color(0xFF3B82F6),
                              width: 4,
                            ),
                          ),
                        ),
                        child: Text(
                          widget.notificationTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E40AF),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Attempts Left Counter
                      if (widget.attemptsLeft <= 3)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getAttemptsColor().withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.attemptsLeft} attempt${widget.attemptsLeft != 1 ? 's' : ''} remaining',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getAttemptsColor(),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      if (widget.attemptsLeft <= 3) const SizedBox(height: 16),

                      // Error Display
                      if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                            border: const Border(
                              left: BorderSide(
                                color: Color(0xFFDC2626),
                                width: 4,
                              ),
                            ),
                          ),
                          child: Text(
                            widget.errorMessage!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F1D1D),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Password Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFD1D5DB),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFFFFFFFF),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    obscureText: !_showPassword,
                                    enabled: !widget.isSubmitting,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter your password',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(12),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1F2937),
                                    ),
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _handleSubmit(),
                                  ),
                                ),
                                IconButton(
                                  onPressed: widget.isSubmitting
                                      ? null
                                      : () {
                                          setState(() {
                                            _showPassword = !_showPassword;
                                          });
                                        },
                                  icon: Text(
                                    _showPassword ? '👁️' : '🙈',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFF3F4F6),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_passwordController.text.trim().isEmpty ||
                                widget.isSubmitting)
                            ? null
                            : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          disabledBackgroundColor:
                              const Color(0xFF3B82F6).withValues(alpha: 0.6),
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: widget.isSubmitting
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Verifying...',
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Verify & Continue',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.isSubmitting ? null : widget.onCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          disabledBackgroundColor:
                              const Color(0xFFF3F4F6).withValues(alpha: 0.6),
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
