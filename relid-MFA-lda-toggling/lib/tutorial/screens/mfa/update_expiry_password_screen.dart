// ============================================================================
// File: update_expiry_password_screen.dart
// Description: Update Expiry Password Screen (Password Expiry Flow)
//
// Transformed from: UpdateExpiryPasswordScreen.tsx
// Handles expired password update with challengeMode = 4 (RDNA_OP_UPDATE_ON_EXPIRY)
//
// This screen is specifically designed for updating expired passwords during
// authentication flows. It handles the challengeMode = 4 scenario where users
// need to update their expired password by providing both current and new passwords.
//
// Key Features:
// - Current password, new password, and confirm password inputs with validation
// - Password policy parsing and validation
// - Real-time error handling and loading states
// - Success/error feedback
// - Password policy display
// - Challenge mode 4 handling for password expiry
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

/// Update Expiry Password Screen Component
///
/// Handles the password expiry flow where users must update their expired
/// password by providing current password, new password, and confirmation.
class UpdateExpiryPasswordScreen extends ConsumerStatefulWidget {
  final RDNAGetPassword? eventData;

  const UpdateExpiryPasswordScreen({
    super.key,
    this.eventData,
  });

  @override
  ConsumerState<UpdateExpiryPasswordScreen> createState() =>
      _UpdateExpiryPasswordScreenState();
}

class _UpdateExpiryPasswordScreenState
    extends ConsumerState<UpdateExpiryPasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordFocusNode = FocusNode();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  String? _error;
  bool _isSubmitting = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordPolicyMessage;
  String? _userName;
  int _challengeMode = 4; // RDNA_OP_UPDATE_ON_EXPIRY

  @override
  void initState() {
    super.initState();
    _processEventData();
    // Auto-focus on current password field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentPasswordFocusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(UpdateExpiryPasswordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-process when eventData changes
    if (widget.eventData != oldWidget.eventData) {
      print('UpdateExpiryPasswordScreen - Event data updated, re-processing');
      _processEventData();
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  /// Handle response data from event
  void _processEventData() {
    if (widget.eventData == null) return;

    final responseData = widget.eventData!;
    print('UpdateExpiryPasswordScreen - Processing response data from event');

    setState(() {
      _userName = responseData.userId ?? '';
      _challengeMode = responseData.challengeMode ?? 4;
    });

    // Extract and process password policy
    final policyJsonString = RDNAEventUtils.getChallengeValue(
      responseData.challengeResponse?.challengeInfo,
      'RELID_PASSWORD_POLICY',
    );
    if (policyJsonString != null) {
      final policyMessage = parseAndGeneratePolicyMessage(policyJsonString);
      setState(() {
        _passwordPolicyMessage = policyMessage;
      });
      print(
          'UpdateExpiryPasswordScreen - Password policy extracted: $policyMessage');
    }

    print('UpdateExpiryPasswordScreen - Processed password data:');
    print('  userID: ${responseData.userId}');
    print('  challengeMode: ${responseData.challengeMode}');
    print('  passwordPolicy: ${policyJsonString != null ? "Found" : "Not found"}');

    // Check for API errors first
    if (RDNAEventUtils.hasApiError(responseData.error)) {
      final errorMessage =
          RDNAEventUtils.getErrorMessage(responseData.error, null);
      print('UpdateExpiryPasswordScreen - API error: $errorMessage');
      setState(() {
        _error = errorMessage;
        _isSubmitting = false; // ← Stop loading spinner
      });
      // Clear password fields on error
      _clearPasswordFields();
      return;
    }

    // Check for status errors (including password reuse errors like statusCode 164)
    if (RDNAEventUtils.hasStatusError(responseData.challengeResponse?.status)) {
      final errorMessage = RDNAEventUtils.getErrorMessage(
          responseData.error, responseData.challengeResponse?.status);
      print('UpdateExpiryPasswordScreen - Status error: $errorMessage');
      setState(() {
        _error = errorMessage;
        _isSubmitting = false; // ← Stop loading spinner
      });
      // Clear password fields on error (e.g., password reuse)
      _clearPasswordFields();
      return;
    }
  }

  /// Clear all password fields
  void _clearPasswordFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _currentPasswordFocusNode.requestFocus();
  }

  /// Handle input changes - update controller and clear error when user types
  void _onCurrentPasswordChanged(String value) {
    setState(() {
      _currentPasswordController.text = value;
      if (_error != null) _error = null;
    });
  }

  void _onNewPasswordChanged(String value) {
    setState(() {
      _newPasswordController.text = value;
      if (_error != null) _error = null;
    });
  }

  void _onConfirmPasswordChanged(String value) {
    setState(() {
      _confirmPasswordController.text = value;
      if (_error != null) _error = null;
    });
  }

  /// Handle password update submission
  Future<void> _handleUpdatePassword() async {
    if (_isSubmitting) return;

    final trimmedCurrentPassword = _currentPasswordController.text.trim();
    final trimmedNewPassword = _newPasswordController.text.trim();
    final trimmedConfirmPassword = _confirmPasswordController.text.trim();

    // Basic validation
    if (trimmedCurrentPassword.isEmpty) {
      setState(() {
        _error = 'Please enter your current password';
      });
      _currentPasswordFocusNode.requestFocus();
      return;
    }

    if (trimmedNewPassword.isEmpty) {
      setState(() {
        _error = 'Please enter a new password';
      });
      _newPasswordFocusNode.requestFocus();
      return;
    }

    if (trimmedConfirmPassword.isEmpty) {
      setState(() {
        _error = 'Please confirm your new password';
      });
      _confirmPasswordFocusNode.requestFocus();
      return;
    }

    // Check password match
    if (trimmedNewPassword != trimmedConfirmPassword) {
      setState(() {
        _error = 'New password and confirm password do not match';
      });
      // Show alert dialog
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Password Mismatch'),
            content:
                const Text('New password and confirm password do not match'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _newPasswordController.clear();
                  _confirmPasswordController.clear();
                  _newPasswordFocusNode.requestFocus();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Check if new password is same as current password
    if (trimmedCurrentPassword == trimmedNewPassword) {
      setState(() {
        _error = 'New password must be different from current password';
      });
      // Show alert dialog
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid New Password'),
            content: const Text(
                'Your new password must be different from your current password'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _newPasswordController.clear();
                  _confirmPasswordController.clear();
                  _newPasswordFocusNode.requestFocus();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      print(
          'UpdateExpiryPasswordScreen - Updating password with challengeMode: $_challengeMode');

      final rdnaService = RdnaService.getInstance();
      final response = await rdnaService.updatePassword(
        trimmedCurrentPassword,
        trimmedNewPassword,
        RDNAChallengeOpMode.RDNA_OP_UPDATE_ON_EXPIRY, // challengeMode 4
      );

      print(
          'UpdateExpiryPasswordScreen - UpdatePassword sync response successful, waiting for async events');
      print('UpdateExpiryPasswordScreen - Sync response received:');
      print('  longErrorCode: ${response.error?.longErrorCode}');
      print('  shortErrorCode: ${response.error?.shortErrorCode}');
      print('  errorString: ${response.error?.errorString}');

      // Check sync response for errors
      if (response.error?.longErrorCode != 0) {
        // Sync error
        final errorMessage = response.error?.errorString ?? 'Unknown error';
        print('UpdateExpiryPasswordScreen - Sync error: $errorMessage');
        setState(() {
          _error = errorMessage;
          _isSubmitting = false;
        });
        _clearPasswordFields();
        return;
      }

      // Success - wait for onUserLoggedIn event
      // Event handlers in SDKEventProvider will handle the navigation
      print(
          'UpdateExpiryPasswordScreen - Sync success, waiting for onUserLoggedIn event');
    } catch (error) {
      // Handle any runtime errors
      print('UpdateExpiryPasswordScreen - Runtime error: $error');
      setState(() {
        _error = 'An unexpected error occurred. Please try again.';
        _isSubmitting = false;
      });
      _clearPasswordFields();
    }
  }

  /// Handle close button - reset authentication state
  void _handleClose() {
    print('UpdateExpiryPasswordScreen - Calling resetAuthState');
    final rdnaService = RdnaService.getInstance();
    rdnaService.resetAuthState().then((_) {
      print('UpdateExpiryPasswordScreen - ResetAuthState successful');
    }).catchError((error) {
      print('UpdateExpiryPasswordScreen - ResetAuthState error: $error');
    });
  }

  /// Check if form is valid
  bool get _isFormValid {
    return _currentPasswordController.text.trim().isNotEmpty &&
        _newPasswordController.text.trim().isNotEmpty &&
        _confirmPasswordController.text.trim().isNotEmpty &&
        _error == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60), // Space for close button

                  const Text(
                    'Update Expired Password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3e50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Your password has expired. Please update it to continue.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7f8c8d),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // User Information
                  if (_userName != null && _userName!.isNotEmpty)
                    Column(
                      children: [
                        const Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF2c3e50),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userName!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3498db),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Password Policy Display
                  if (_passwordPolicyMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf0f8ff),
                        border: const Border(
                          left: BorderSide(
                            color: Color(0xFF3498db),
                            width: 4,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Password Requirements',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2c3e50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _passwordPolicyMessage!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2c3e50),
                              height: 1.43, // lineHeight: 20 / fontSize: 14
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Error Display
                  if (_error != null)
                    StatusBanner(
                      type: StatusBannerType.error,
                      message: _error!,
                    ),

                  // Current Password Input
                  CustomInput(
                    label: 'Current Password',
                    value: _currentPasswordController.text,
                    onChanged: _onCurrentPasswordChanged,
                    placeholder: 'Enter current password',
                    obscureText: _obscureCurrentPassword,
                    enabled: !_isSubmitting,
                    focusNode: _currentPasswordFocusNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: () => _newPasswordFocusNode.requestFocus(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF7f8c8d),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // New Password Input
                  CustomInput(
                    label: 'New Password',
                    value: _newPasswordController.text,
                    onChanged: _onNewPasswordChanged,
                    placeholder: 'Enter new password',
                    obscureText: _obscureNewPassword,
                    enabled: !_isSubmitting,
                    focusNode: _newPasswordFocusNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: () =>
                        _confirmPasswordFocusNode.requestFocus(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF7f8c8d),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm New Password Input
                  CustomInput(
                    label: 'Confirm New Password',
                    value: _confirmPasswordController.text,
                    onChanged: _onConfirmPasswordChanged,
                    placeholder: 'Confirm new password',
                    obscureText: _obscureConfirmPassword,
                    enabled: !_isSubmitting,
                    focusNode: _confirmPasswordFocusNode,
                    textInputAction: TextInputAction.done,
                    onSubmitted: _handleUpdatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF7f8c8d),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  CustomButton(
                    title: _isSubmitting
                        ? 'Updating Password...'
                        : 'Update Password',
                    onPress: _handleUpdatePassword,
                    loading: _isSubmitting,
                    disabled: !_isFormValid,
                  ),

                  // Help Text
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFe8f4f8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Update your password. Your new password must be different from your current password.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2c3e50),
                        height: 1.43, // lineHeight: 20 / fontSize: 14
                      ),
                      textAlign: TextAlign.center,
                    ),
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
    );
  }
}
