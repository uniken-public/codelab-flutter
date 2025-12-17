// ============================================================================
// File: password_challenge_modal.dart
// Description: Password Challenge Modal
//
// Modal for step-up authentication during data signing.
// Similar to Cordova PasswordChallengeModal.js implementation.
//
// Features:
// - Shows modal when getPassword event triggered during data signing
// - Password input with visibility toggle
// - Attempts counter with color coding (green/orange/red)
// - Submit and Cancel buttons
// - Loading state during submission
// - Auto-focus on password input
// - Error message display
//
// Transformed from: Cordova PasswordChallengeModal.js
// ============================================================================

import 'package:flutter/material.dart';
import '../data_signing_service.dart';
import '../data_signing_types.dart';

/// Password Challenge Modal for Data Signing Step-Up Authentication
///
/// This modal is displayed when the SDK triggers a getPassword event
/// during the data signing flow, requiring user password verification.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   barrierDismissible: false,
///   builder: (context) => PasswordChallengeModal(
///     challengeMode: 12,
///     attemptsLeft: 3,
///     onSubmit: (password) async { ... },
///     onCancel: () async { ... },
///   ),
/// );
/// ```
class PasswordChallengeModal extends StatefulWidget {
  final int challengeMode;
  final int attemptsLeft;
  final Future<void> Function(String password) onSubmit;
  final Future<void> Function() onCancel;
  final DataSigningFormState? context;

  const PasswordChallengeModal({
    Key? key,
    required this.challengeMode,
    required this.attemptsLeft,
    required this.onSubmit,
    required this.onCancel,
    this.context,
  }) : super(key: key);

  @override
  State<PasswordChallengeModal> createState() => _PasswordChallengeModalState();
}

class _PasswordChallengeModalState extends State<PasswordChallengeModal> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Auto-focus password input after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _passwordFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Gets color for attempts counter based on remaining attempts
  /// 1 attempt = red, 2 attempts = orange, 3+ = green
  Color _getAttemptsColor() {
    if (widget.attemptsLeft == 1) return const Color(0xFFDC2626); // Red
    if (widget.attemptsLeft == 2) return const Color(0xFFF59E0B); // Orange
    return const Color(0xFF10B981); // Green
  }

  /// Handles submit button press
  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    final password = _passwordController.text;

    // Validate password
    final validation = DataSigningService.validatePassword(password);
    if (!validation.isValid) {
      setState(() {
        _errorMessage = validation.error ?? 'Password is required';
      });
      return;
    }

    // Clear error and set loading state
    setState(() {
      _errorMessage = '';
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(password);
      // Modal will be closed by parent on success
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = error.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  /// Handles cancel button press
  Future<void> _handleCancel() async {
    if (_isSubmitting) return;

    try {
      await widget.onCancel();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      print('PasswordChallengeModal - Cancel error: $error');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Attempts Counter (if <= 3 attempts)
            if (widget.attemptsLeft <= 3) ...[
              _buildAttemptsCounter(),
              const SizedBox(height: 16),
            ],

            // Error Message
            if (_errorMessage.isNotEmpty) ...[
              _buildErrorMessage(),
              const SizedBox(height: 16),
            ],

            // Password Input
            _buildPasswordInput(),
            const SizedBox(height: 24),

            // Buttons
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  /// Builds the header section
  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.lock, size: 32, color: Color(0xFF007AFF)),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Authentication Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Please verify your password to complete data signing',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  /// Builds the attempts counter badge
  Widget _buildAttemptsCounter() {
    final attemptsColor = _getAttemptsColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: attemptsColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: attemptsColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16, color: attemptsColor),
          const SizedBox(width: 8),
          Text(
            '${widget.attemptsLeft} attempt${widget.attemptsLeft != 1 ? 's' : ''} remaining',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: attemptsColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the error message banner
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDC2626).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the password input field
  Widget _buildPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: !_isPasswordVisible,
          enabled: !_isSubmitting,
          onSubmitted: (_) => _handleSubmit(),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF666666),
              ),
              onPressed: _isSubmitting
                  ? null
                  : () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the submit and cancel buttons
  Widget _buildButtons() {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : _handleCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Submit Button
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF007AFF),
              disabledBackgroundColor: const Color(0xFFCCCCCC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: _isSubmitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: const Text(
                          'Authenticating...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Authenticate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
