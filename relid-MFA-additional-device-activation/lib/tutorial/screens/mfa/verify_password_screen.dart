// ============================================================================
// File: verify_password_screen.dart
// Description: Verify Password Screen for MFA Login
//
// Transformed from: VerifyPasswordScreen.tsx
// Handles password verification for login (challengeMode = 0)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../../../uniken/services/rdna_service.dart';
import '../../../uniken/utils/rdna_event_utils.dart';
import '../components/custom_button.dart';
import '../components/custom_input.dart';
import '../components/status_banner.dart';
import '../components/close_button.dart';

class VerifyPasswordScreen extends ConsumerStatefulWidget {
  final RDNAGetPassword? eventData;

  const VerifyPasswordScreen({
    super.key,
    this.eventData,
  });

  @override
  ConsumerState<VerifyPasswordScreen> createState() =>
      _VerifyPasswordScreenState();
}

class _VerifyPasswordScreenState extends ConsumerState<VerifyPasswordScreen> {
  final _passwordController = TextEditingController();
  String? _error;
  bool _isSubmitting = false;
  String? _validationMessage;
  bool _validationSuccess = false;
  bool _obscurePassword = true;
  String? _userId;
  int? _attemptsLeft;

  @override
  void initState() {
    super.initState();
    _processEventData();
  }

  @override
  void didUpdateWidget(VerifyPasswordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-process when eventData changes (SDK re-triggers getPassword with error)
    if (widget.eventData != oldWidget.eventData) {
      print('VerifyPasswordScreen - Event data updated, re-processing');
      _processEventData();
    }
  }

  void _processEventData() {
    if (widget.eventData == null) return;

    final data = widget.eventData!;

    setState(() {
      _userId = data.userId;
      _attemptsLeft = data.attemptsLeft;
    });

    print('VerifyPasswordScreen - Processing event data');
    print('  Status Code: ${data.challengeResponse?.status?.statusCode}');
    print('  API Error Code: ${data.error?.longErrorCode}');
    print('  Attempts Left: ${data.attemptsLeft}');

    // Check for API errors first
    if (RDNAEventUtils.hasApiError(data.error)) {
      final errorMessage = RDNAEventUtils.getErrorMessage(data.error, null);
      print('VerifyPasswordScreen - API error: $errorMessage');
      setState(() {
        _error = errorMessage;
        _validationSuccess = false;
        _validationMessage = errorMessage;
      });
      return;
    }

    // Check for status errors (e.g., wrong password)
    if (RDNAEventUtils.hasStatusError(data.challengeResponse?.status)) {
      final errorMessage = RDNAEventUtils.getErrorMessage(null, data.challengeResponse?.status);
      print('VerifyPasswordScreen - Status error: $errorMessage');
      setState(() {
        _error = errorMessage;
        _validationSuccess = false;
        _validationMessage = errorMessage;
      });
      return;
    }

    // Success - ready for password input
    print('VerifyPasswordScreen - Successfully processed event data');
    setState(() {
      _validationSuccess = true;
      _validationMessage = 'Ready to verify password';
      _error = null;
    });
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordController.text = value;
      if (_error != null) _error = null;
      if (_validationMessage != null) _validationMessage = null;
    });
  }

  Future<void> _handleVerifyPassword() async {
    final password = _passwordController.text;

    setState(() {
      _isSubmitting = true;
      _error = null;
      _validationMessage = null;
    });

    final rdnaService = RdnaService.getInstance();
    final response = await rdnaService.setPassword(
      password,
      RDNAChallengeOpMode.RDNA_CHALLENGE_OP_VERIFY,
    );

    if (response.error?.longErrorCode == 0) {
      setState(() {
        _validationSuccess = true;
        _validationMessage = 'Password verified successfully!';
        _isSubmitting = false;
      });
    } else {
      setState(() {
        _error = response.error?.errorString ?? 'Unknown error';
        _isSubmitting = false;
      });
    }
  }

  Future<void> _handleClose() async {
    print('VerifyPasswordScreen - Calling resetAuthState');
    final rdnaService = RdnaService.getInstance();
    final response = await rdnaService.resetAuthState();

    if (response.error?.longErrorCode == 0) {
      print('VerifyPasswordScreen - ResetAuthState successful');
    } else {
      print('VerifyPasswordScreen - ResetAuthState error: ${response.error?.errorString}');
    }
  }

  bool _isFormValid() {
    return _passwordController.text.isNotEmpty && _error == null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Verify Password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              const Text(
                'Enter your password to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7f8c8d),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              if (_validationMessage != null)
                StatusBanner(
                  type: _validationSuccess
                      ? StatusBannerType.success
                      : StatusBannerType.error,
                  message: _validationMessage!,
                ),

              CustomInput(
                label: 'Password',
                value: _passwordController.text,
                onChanged: _onPasswordChanged,
                placeholder: 'Enter password',
                obscureText: _obscurePassword,
                enabled: !_isSubmitting,
                error: _error,
                onSubmitted: _isFormValid() ? _handleVerifyPassword : null,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF7f8c8d),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),

              if (_attemptsLeft != null)
                Text(
                  'Attempts left: $_attemptsLeft',
                  style: TextStyle(
                    fontSize: 14,
                    color: _attemptsLeft! <= 2
                        ? const Color(0xFFe74c3c)
                        : const Color(0xFF7f8c8d),
                    fontWeight: _attemptsLeft! <= 2
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              const SizedBox(height: 24),

              CustomButton(
                title: _isSubmitting ? 'Verifying...' : 'Verify Password',
                onPress: _handleVerifyPassword,
                loading: _isSubmitting,
                disabled: !_isFormValid(),
              ),
            ],
          ),
              ),

              // Close Button
              CustomCloseButton(
                onPressed: _handleClose,
                disabled: _isSubmitting,
              ),
            ],
        ),
      ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
