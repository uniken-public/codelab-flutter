// ============================================================================
// File: set_password_screen.dart
// Description: Set Password Screen for MFA Password Creation
//
// Transformed from: SetPasswordScreen.tsx
// Handles password creation with policy validation (challengeMode = 1)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../../../uniken/services/rdna_service.dart';
import '../../../uniken/utils/password_policy_utils.dart';
import '../../../uniken/utils/rdna_event_utils.dart';
import '../components/custom_button.dart';
import '../components/custom_input.dart';
import '../components/status_banner.dart';
import '../components/close_button.dart';

class SetPasswordScreen extends ConsumerStatefulWidget {
  final RDNAGetPassword? eventData;

  const SetPasswordScreen({
    super.key,
    this.eventData,
  });

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  String? _error;
  bool _isSubmitting = false;
  String? _validationMessage;
  bool _validationSuccess = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordPolicy;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _processEventData();
  }

  @override
  void didUpdateWidget(SetPasswordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-process when eventData changes
    if (widget.eventData != oldWidget.eventData) {
      print('SetPasswordScreen - Event data updated, re-processing');
      _processEventData();
    }
  }

  void _processEventData() {
    if (widget.eventData == null) return;

    final data = widget.eventData!;

    setState(() {
      _userId = data.userId;
    });

    print('SetPasswordScreen - Processing event data');
    print('  Status Code: ${data.challengeResponse?.status?.statusCode}');
    print('  API Error Code: ${data.error?.longErrorCode}');

    // Extract password policy from challenge data
    final policyValue = RDNAEventUtils.getChallengeValue(
      data.challengeResponse?.challengeInfo,
      'RELID_PASSWORD_POLICY',
    );
    if (policyValue != null) {
      final policyMessage = parseAndGeneratePolicyMessage(policyValue);
      setState(() {
        _passwordPolicy = policyMessage;
      });
      print('SetPasswordScreen - Password policy extracted: $policyMessage');
    }

    // Check for API errors first
    if (RDNAEventUtils.hasApiError(data.error)) {
      final errorMessage = RDNAEventUtils.getErrorMessage(data.error, null);
      print('SetPasswordScreen - API error: $errorMessage');
      setState(() {
        _error = errorMessage;
        _validationSuccess = false;
        _validationMessage = errorMessage;
      });
      return;
    }

    // Check for status errors
    if (RDNAEventUtils.hasStatusError(data.challengeResponse?.status)) {
      final errorMessage = RDNAEventUtils.getErrorMessage(null, data.challengeResponse?.status);
      print('SetPasswordScreen - Status error: $errorMessage');
      setState(() {
        _error = errorMessage;
        _validationSuccess = false;
        _validationMessage = errorMessage;
      });
      return;
    }

    // Success - ready for password input
    print('SetPasswordScreen - Successfully processed event data');
    setState(() {
      _validationSuccess = true;
      _validationMessage = 'Ready to create password';
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

  void _onConfirmPasswordChanged(String value) {
    setState(() {
      _confirmPasswordController.text = value;
      if (_error != null) _error = null;
      if (_validationMessage != null) _validationMessage = null;
    });
  }

  Future<void> _handleSetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate passwords match
    if (password != confirmPassword) {
      setState(() {
        _error = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
      _validationMessage = null;
    });

    final rdnaService = RdnaService.getInstance();
    final response = await rdnaService.setPassword(
      password,
      RDNAChallengeOpMode.RDNA_CHALLENGE_OP_SET,
    );

    if (response.error?.longErrorCode == 0) {
      setState(() {
        _validationSuccess = true;
        _validationMessage = 'Password set successfully!';
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
    print('SetPasswordScreen - Calling resetAuthState');
    final rdnaService = RdnaService.getInstance();
    final response = await rdnaService.resetAuthState();

    if (response.error?.longErrorCode == 0) {
      print('SetPasswordScreen - ResetAuthState successful');
    } else {
      print('SetPasswordScreen - ResetAuthState error: ${response.error?.errorString}');
    }
  }

  bool _isFormValid() {
    return _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _error == null;
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
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Set Password',
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
                    ? 'Create a secure password for user: $_userId'
                    : 'Create a secure password',
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

              if (_passwordPolicy != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe8f4f8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password Requirements:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _passwordPolicy!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7f8c8d),
                        ),
                      ),
                    ],
                  ),
                ),

              CustomInput(
                label: 'Password',
                value: _passwordController.text,
                onChanged: _onPasswordChanged,
                placeholder: 'Enter password',
                obscureText: _obscurePassword,
                enabled: !_isSubmitting,
                focusNode: _passwordFocusNode,
                textInputAction: TextInputAction.next,
                onSubmitted: () => _confirmPasswordFocusNode.requestFocus(),
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
              const SizedBox(height: 20),

              CustomInput(
                label: 'Confirm Password',
                value: _confirmPasswordController.text,
                onChanged: _onConfirmPasswordChanged,
                placeholder: 'Confirm password',
                obscureText: _obscureConfirmPassword,
                enabled: !_isSubmitting,
                focusNode: _confirmPasswordFocusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: _isFormValid() ? _handleSetPassword : null,
                error: _error,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF7f8c8d),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              CustomButton(
                title: _isSubmitting ? 'Setting Password...' : 'Set Password',
                onPress: _handleSetPassword,
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
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}
