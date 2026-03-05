// ============================================================================
// File: activation_code_screen.dart
// Description: Activation Code Screen for MFA OTP Validation
//
// Transformed from: ActivationCodeScreen.tsx
// Handles activation code/OTP input with retry support
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

class ActivationCodeScreen extends ConsumerStatefulWidget {
  final RDNAActivationCode? eventData;

  const ActivationCodeScreen({
    super.key,
    this.eventData,
  });

  @override
  ConsumerState<ActivationCodeScreen> createState() =>
      _ActivationCodeScreenState();
}

class _ActivationCodeScreenState extends ConsumerState<ActivationCodeScreen> {
  final _codeController = TextEditingController();
  String? _error;
  bool _isValidating = false;
  String? _validationMessage;
  bool _validationSuccess = false;
  int? _attemptsLeft;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _processEventData();
  }

  @override
  void didUpdateWidget(ActivationCodeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-process when eventData changes (SDK re-triggers getActivationCode with error)
    if (widget.eventData != oldWidget.eventData) {
      print('ActivationCodeScreen - Event data updated, re-processing');
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

    print('ActivationCodeScreen - Processing event data');
    print('  Status Code: ${data.challengeResponse?.status?.statusCode}');
    print('  API Error Code: ${data.error?.longErrorCode}');
    print('  Attempts Left: ${data.attemptsLeft}');

    // Check for API errors first
    if (RDNAEventUtils.hasApiError(data.error)) {
      final errorMessage = RDNAEventUtils.getErrorMessage(data.error, null);
      print('ActivationCodeScreen - API error: $errorMessage');
      setState(() {
        _error = errorMessage;
        _validationSuccess = false;
        _validationMessage = errorMessage;
      });
      return;
    }

    // Check for status errors (e.g., statusCode 106 = invalid code)
    if (RDNAEventUtils.hasStatusError(data.challengeResponse?.status)) {
      final errorMessage = RDNAEventUtils.getErrorMessage(null, data.challengeResponse?.status);
      print('ActivationCodeScreen - Status error: $errorMessage');
      setState(() {
        _error = errorMessage;
        _validationSuccess = false;
        _validationMessage = errorMessage;
      });
      return;
    }

    // Success - ready for code input (statusCode == 100)
    print('ActivationCodeScreen - Successfully processed event data');
    setState(() {
      _validationSuccess = true;
      _validationMessage = 'Ready to enter activation code';
      _error = null;
    });
  }

  void _onCodeChanged(String value) {
    setState(() {
      _codeController.text = value;
      if (_error != null) _error = null;
      if (_validationMessage != null) _validationMessage = null;
    });
  }

  Future<void> _handleVerifyCode() async {
    final code = _codeController.text.trim();

    setState(() {
      _isValidating = true;
      _error = null;
      _validationMessage = null;
    });

    final rdnaService = RdnaService.getInstance();
    final response = await rdnaService.setActivationCode(code);

    if (response.error?.longErrorCode == 0) {
      setState(() {
        _validationSuccess = true;
        _validationMessage = 'Code verified successfully!';
        _isValidating = false;
      });
    } else {
      setState(() {
        _error = response.error?.errorString ?? 'Unknown error';
        _isValidating = false;
      });
    }
  }

  Future<void> _handleResendCode() async {
    setState(() {
      _isValidating = true;
      _error = null;
      _validationMessage = 'Resending code...';
    });

    final rdnaService = RdnaService.getInstance();
    final response = await rdnaService.resendActivationCode();

    if (response.error?.longErrorCode == 0) {
      setState(() {
        _validationSuccess = true;
        _validationMessage = 'Code resent successfully! Check your email/SMS.';
        _isValidating = false;
      });
    } else {
      setState(() {
        _error = response.error?.errorString ?? 'Failed to resend code';
        _validationSuccess = false;
        _validationMessage = _error;
        _isValidating = false;
      });
    }
  }

  Future<void> _handleClose() async {
    print('ActivationCodeScreen - Calling resetAuthState');
    final rdnaService = RdnaService.getInstance();
    final response = await rdnaService.resetAuthState();

    if (response.error?.longErrorCode == 0) {
      print('ActivationCodeScreen - ResetAuthState successful');
    } else {
      print('ActivationCodeScreen - ResetAuthState error: ${response.error?.errorString}');
    }
  }

  bool _isFormValid() {
    return _codeController.text.trim().isNotEmpty && _error == null;
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
                'Enter Activation Code',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                _userId != null
                    ? 'Enter the activation code for user: $_userId'
                    : 'Enter the activation code',
                style: const TextStyle(
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
                label: 'Activation Code',
                value: _codeController.text,
                onChanged: _onCodeChanged,
                placeholder: 'Enter activation code',
                keyboardType: TextInputType.text, // Alphanumeric for activation codes
                enabled: !_isValidating,
                error: _error,
                onSubmitted: _isFormValid() ? _handleVerifyCode : null,
              ),
              const SizedBox(height: 12),

              if (_attemptsLeft != null)
                Text(
                  'Attempts left: $_attemptsLeft',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7f8c8d),
                  ),
                ),
              const SizedBox(height: 24),

              CustomButton(
                title: _isValidating ? 'Verifying...' : 'Verify Code',
                onPress: _handleVerifyCode,
                loading: _isValidating,
                disabled: !_isFormValid(),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: _isValidating ? null : _handleResendCode,
                child: const Text(
                  'Resend Activation Code',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3498db),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
            ),

            // Close Button
            CustomCloseButton(
              onPressed: _handleClose,
              disabled: _isValidating,
            ),
          ],
        ),
      ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
