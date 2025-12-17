// ============================================================================
// File: check_user_screen.dart
// Description: Check User Screen for MFA User Validation
//
// Transformed from: CheckUserScreen.tsx
// Provides username input and validation via setUser API
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../../../uniken/services/rdna_service.dart';
import '../../../uniken/utils/rdna_event_utils.dart';
import '../components/custom_button.dart';
import '../components/custom_input.dart';
import '../components/status_banner.dart';

/// Check User Screen
///
/// This screen handles username input and validation for MFA.
/// Cyclical flow: SDK may re-trigger getUser event if validation fails.
class CheckUserScreen extends ConsumerStatefulWidget {
  final RDNAGetUser? eventData;

  const CheckUserScreen({
    super.key,
    this.eventData,
  });

  @override
  ConsumerState<CheckUserScreen> createState() => _CheckUserScreenState();
}

class _CheckUserScreenState extends ConsumerState<CheckUserScreen> {
  final _usernameController = TextEditingController();
  String? _error;
  bool _isValidating = false;
  String? _validationMessage;
  bool _validationSuccess = false;

  @override
  void initState() {
    super.initState();
    _processEventData();
  }

  @override
  void didUpdateWidget(CheckUserScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-process when eventData changes (SDK re-triggers getUser with error)
    if (widget.eventData != oldWidget.eventData) {
      print('CheckUserScreen - Event data updated, re-processing');
      _processEventData();
    }
  }

  /// Process event data from route params
  /// Handles both API errors and status errors like React Native
  void _processEventData() {
    if (widget.eventData == null) return;

    final data = widget.eventData!;

    print('CheckUserScreen - Processing event data');
    print('  Status Code: ${data.challengeResponse?.status?.statusCode}');
    print('  API Error Code: ${data.error?.longErrorCode}');

    // Check for API errors first (using RDNAEventUtils like RN)
    if (RDNAEventUtils.hasApiError(data.error)) {
      final errorMessage = RDNAEventUtils.getErrorMessage(data.error, null);
      print('CheckUserScreen - API error: $errorMessage');
      setState(() {
        _error = errorMessage;
        _validationSuccess = false;
        _validationMessage = errorMessage;
      });
      return;
    }

    // Check for status errors (using RDNAEventUtils like RN)
    if (RDNAEventUtils.hasStatusError(data.challengeResponse?.status)) {
      final errorMessage = RDNAEventUtils.getErrorMessage(null, data.challengeResponse?.status);
      print('CheckUserScreen - Status error: $errorMessage');
      setState(() {
        _error = errorMessage;
        _validationSuccess = false;
        _validationMessage = errorMessage;
      });
      return;
    }

    // Success - ready for username input (statusCode == 100)
    print('CheckUserScreen - Successfully processed event data');
    setState(() {
      _validationSuccess = true;
      _validationMessage = 'Ready to enter username';
      _error = null;
    });
  }

  /// Handle username input change
  void _onUsernameChanged(String value) {
    setState(() {
      _usernameController.text = value;
      if (_error != null) _error = null;
      if (_validationMessage != null) _validationMessage = null;
    });
  }

  /// Handle user validation
  Future<void> _handleValidateUser() async {
    final username = _usernameController.text.trim();

    setState(() {
      _isValidating = true;
      _error = null;
      _validationMessage = null;
    });

    print('CheckUserScreen - Setting user: $username');

    final rdnaService = RdnaService.getInstance();
    final response = await rdnaService.setUser(username);

    print('CheckUserScreen - SetUser sync response received');
    print('  Long Error Code: ${response.error?.longErrorCode}');

    if (response.error?.longErrorCode == 0) {
      setState(() {
        _validationSuccess = true;
        _validationMessage = 'User set successfully! Waiting for next step...';
        _isValidating = false;
      });
    } else {
      setState(() {
        _error = response.error?.errorString ?? 'Unknown error';
        _isValidating = false;
      });
    }
  }

  bool _isFormValid() {
    return _usernameController.text.trim().isNotEmpty && _error == null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // Background from RN
        resizeToAvoidBottomInset: true, // Resize when keyboard appears
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20), // 20px padding from RN
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              const Text(
                'Set User',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50), // Title color from RN
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Enter your username to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7f8c8d), // Subtitle color from RN
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Validation Result
              if (_validationMessage != null)
                StatusBanner(
                  type: _validationSuccess
                      ? StatusBannerType.success
                      : StatusBannerType.error,
                  message: _validationMessage!,
                ),

              // Username Input
              CustomInput(
                label: 'Username',
                value: _usernameController.text,
                onChanged: _onUsernameChanged,
                placeholder: 'Enter your username',
                keyboardType: TextInputType.text,
                enabled: !_isValidating,
                error: _error,
                onSubmitted: _isFormValid() ? _handleValidateUser : null,
              ),
              const SizedBox(height: 24),

              // Validate Button
              CustomButton(
                title: _isValidating ? 'Setting User...' : 'Set User',
                onPress: _handleValidateUser,
                loading: _isValidating,
                disabled: !_isFormValid(),
              ),

              // Help Text
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFecf0f1), // Help container bg from RN
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Enter your username to set the user for the SDK session.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7f8c8d),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
