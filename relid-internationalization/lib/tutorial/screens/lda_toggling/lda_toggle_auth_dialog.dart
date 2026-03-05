// ============================================================================
// File: lda_toggle_auth_dialog.dart
// Description: LDA Toggle Auth Dialog - Unified Component
//
// Single modal dialog handling ALL authentication challenges during LDA toggling:
// - ChallengeMode 5: Password verification (single field - to disable LDA)
// - ChallengeMode 14: Password creation (two fields + policy - to enable LDA)
// - ChallengeMode 15: Password verification (single field - to disable LDA)
// - ChallengeMode 16: LDA consent (to enable LDA with biometric)
//
// This unified approach keeps all LDA toggling authentication in one place,
// making it simpler to understand and maintain.
//
// Features:
// - Dynamic UI based on challengeMode
// - Password verification with single input (modes 5, 15)
// - Password creation with two inputs and policy display (mode 14)
// - LDA consent interface (mode 16)
// - Attempts counter with color coding (modes 5, 15)
// - Error message display
// - Loading states
// - Auto-focus and keyboard handling
// - Password policy parsing
// - Synchronous error handling:
//   - Checks response.error.longErrorCode directly from API calls
//   - If longErrorCode != 0, displays error.errorString to user
//   - No try-catch needed as SDK returns error codes in response
//
// Location: In lda_toggling folder (post-login feature)
// Style: Dialog/Modal (not full screen navigation)
//
// Transformed from: Cordova LDAToggleAuthDialog.js
// ============================================================================

import 'package:flutter/material.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../../../uniken/services/rdna_service.dart';
import '../../../uniken/utils/password_policy_utils.dart';

/// Dialog Mode enum
enum LDAToggleDialogMode {
  password, // ChallengeMode 5, 15 - Password verification
  passwordCreate, // ChallengeMode 14 - Password creation
  consent, // ChallengeMode 16 - LDA consent
}

/// Authentication Type Mapping (same as LDATogglingScreen)
const Map<int, String> authTypeNames = {
  0: 'None',
  1: 'Biometric Authentication',
  2: 'Face ID',
  3: 'Pattern Authentication',
  4: 'Biometric Authentication',
  9: 'Device Biometric',
};

/// LDA Toggle Auth Dialog
///
/// Unified dialog for handling all LDA toggling authentication challenges.
class LDAToggleAuthDialog extends StatefulWidget {
  final int challengeMode;
  final String userID;
  final int attemptsLeft;
  final RDNAGetPassword? passwordData; // For challengeModes 5, 14, 15
  final GetUserConsentForLDAData? consentData; // For challengeMode 16
  final VoidCallback? onCancelled; // Callback when dialog is cancelled

  const LDAToggleAuthDialog({
    super.key,
    required this.challengeMode,
    required this.userID,
    required this.attemptsLeft,
    this.passwordData,
    this.consentData,
    this.onCancelled,
  });

  /// Shows the dialog based on challengeMode
  static Future<void> show(
    BuildContext context, {
    required int challengeMode,
    required String userID,
    required int attemptsLeft,
    RDNAGetPassword? passwordData,
    GetUserConsentForLDAData? consentData,
    VoidCallback? onCancelled,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LDAToggleAuthDialog(
        challengeMode: challengeMode,
        userID: userID,
        attemptsLeft: attemptsLeft,
        passwordData: passwordData,
        consentData: consentData,
        onCancelled: onCancelled,
      ),
    );
  }

  @override
  State<LDAToggleAuthDialog> createState() => _LDAToggleAuthDialogState();
}

class _LDAToggleAuthDialogState extends State<LDAToggleAuthDialog> {
  late LDAToggleDialogMode _mode;
  late int _attemptsLeft;
  String? _errorMessage;
  bool _isSubmitting = false;

  // Password mode fields
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // Password creation specific
  String? _passwordPolicyMessage;

  // LDA consent specific
  int? _ldaAuthType;
  String? _ldaAuthTypeName;
  String? _customMessage;

  @override
  void initState() {
    super.initState();

    _attemptsLeft = widget.attemptsLeft;

    // Determine mode based on challengeMode
    if (widget.challengeMode == 16) {
      // LDA Consent mode
      _mode = LDAToggleDialogMode.consent;
      _ldaAuthType = widget.consentData?.authenticationType ?? 1;
      _ldaAuthTypeName = authTypeNames[_ldaAuthType] ?? 'Biometric Authentication';
      // Extract custom message from challengeInfo if available
      _customMessage = _extractCustomMessage(widget.consentData?.challengeInfo);
    } else if (widget.challengeMode == 14) {
      // Password creation mode
      _mode = LDAToggleDialogMode.passwordCreate;
      _parsePasswordPolicy();
    } else {
      // Password verification mode (5, 15)
      _mode = LDAToggleDialogMode.password;
    }

    // Process response data for errors
    _processResponseData();

    // Auto-focus password input after dialog builds
    if (_mode != LDAToggleDialogMode.consent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _passwordFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  /// Extract custom message from challengeInfo
  String? _extractCustomMessage(List<ChallengeInfo>? challengeInfo) {
    if (challengeInfo == null) return null;
    for (var item in challengeInfo) {
      if (item.key == 'CUSTOM_MESSAGE' && item.value != null) {
        return item.value;
      }
    }
    return null;
  }

  /// Process SDK response data and extract errors if any
  /// Follows same pattern as SetPasswordScreen and VerifyPasswordScreen:
  /// 1. Check API errors FIRST (error.longErrorCode !== 0)
  /// 2. THEN check status errors (statusCode !== 100 and !== 0)
  void _processResponseData() {
    if (_mode == LDAToggleDialogMode.consent && widget.consentData != null) {
      // Check API errors first
      if (widget.consentData!.error?.longErrorCode != null && widget.consentData!.error!.longErrorCode != 0) {
        _errorMessage = widget.consentData!.error?.errorString ?? 'An error occurred';
        return;
      }
    } else if (widget.passwordData != null) {
      // Check API errors first
      if (widget.passwordData!.error?.longErrorCode != null && widget.passwordData!.error!.longErrorCode != 0) {
        _errorMessage = widget.passwordData!.error?.errorString ?? 'An error occurred';
        return;
      }

      // Check status errors
      if (widget.passwordData!.challengeResponse?.status?.statusCode != null &&
          widget.passwordData!.challengeResponse!.status!.statusCode != 100 &&
          widget.passwordData!.challengeResponse!.status!.statusCode != 0) {
        _errorMessage = widget.passwordData!.challengeResponse?.status?.statusMessage ?? 'Verification failed';
        return;
      }
    }
  }

  /// Parses password policy from challenge data
  void _parsePasswordPolicy() {
    if (widget.passwordData == null) {
      _passwordPolicyMessage = 'Please create a strong password';
      return;
    }

    try {
      // Extract RELID_PASSWORD_POLICY from challengeResponse.challengeInfo
      final challengeInfo = widget.passwordData?.challengeResponse?.challengeInfo;
      if (challengeInfo != null) {
        for (var item in challengeInfo) {
          if (item.key == 'RELID_PASSWORD_POLICY' && item.value != null) {
            _passwordPolicyMessage = parseAndGeneratePolicyMessage(item.value!);
            print('LDAToggleAuthDialog - Password policy parsed: $_passwordPolicyMessage');
            return;
          }
        }
      }

      print('LDAToggleAuthDialog - RELID_PASSWORD_POLICY not found in challengeInfo');
      _passwordPolicyMessage = 'Please create a strong password';
    } catch (error) {
      print('LDAToggleAuthDialog - Error parsing password policy: $error');
      _passwordPolicyMessage = 'Please create a strong password';
    }
  }

  /// Handle submit button press
  Future<void> _handleSubmit() async {
    if (_mode == LDAToggleDialogMode.password) {
      await _handlePasswordSubmit();
    } else if (_mode == LDAToggleDialogMode.passwordCreate) {
      await _handlePasswordCreateSubmit();
    } else {
      await _handleConsentSubmit();
    }
  }

  /// Handle password verification submission (challengeMode 5, 15)
  Future<void> _handlePasswordSubmit() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password';
      });
      return;
    }

    print('LDAToggleAuthDialog - Submitting password for challengeMode: ${widget.challengeMode}');

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final challengeOpMode = RDNAChallengeOpMode.values[widget.challengeMode];
    final response = await RdnaService.getInstance().setPassword(password, challengeOpMode);

    print('LDAToggleAuthDialog - SetPassword sync response received');
    print('  Long Error Code: ${response.error?.longErrorCode}');

    if (response.error?.longErrorCode != 0) {
      // Handle sync error response
      setState(() {
        _isSubmitting = false;
        _errorMessage = response.error?.errorString ?? 'Failed to verify password';
      });
      return;
    }

    print('LDAToggleAuthDialog - Password submitted successfully');

    // SDK will trigger response:
    // - Success → May trigger getUserConsentForLDA (mode 16) OR onDeviceAuthManagementStatus
    // - Wrong password → re-trigger getPassword with decremented attempts (dialog will update)
    // - Exhausted → critical error

    // Close this dialog after successful submission
    // If SDK needs consent (mode 16), a NEW dialog will be shown
    print('LDAToggleAuthDialog - Closing password dialog after successful submission');
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Handle password creation submission (challengeMode 14)
  Future<void> _handlePasswordCreateSubmit() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validate password is not empty
    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a password';
      });
      return;
    }

    // Validate confirm password is not empty
    if (confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please confirm your password';
      });
      return;
    }

    // Validate passwords match
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    print('LDAToggleAuthDialog - Submitting new password for challengeMode: ${widget.challengeMode}');

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final challengeOpMode = RDNAChallengeOpMode.values[widget.challengeMode];
    final response = await RdnaService.getInstance().setPassword(password, challengeOpMode);

    print('LDAToggleAuthDialog - SetPassword sync response received');
    print('  Long Error Code: ${response.error?.longErrorCode}');

    if (response.error?.longErrorCode != 0) {
      // Handle sync error response
      setState(() {
        _isSubmitting = false;
        _errorMessage = response.error?.errorString ?? 'Failed to create password';
      });
      return;
    }

    print('LDAToggleAuthDialog - Password created successfully');

    // SDK will trigger response:
    // - Success → onDeviceAuthManagementStatus (dialog will close)
    // - Policy violation → re-trigger getPassword with error message (dialog will update)
    // - Exhausted → critical error

    // Close this dialog after successful submission
    print('LDAToggleAuthDialog - Closing password creation dialog after successful submission');
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Handle LDA consent submission (challengeMode 16)
  Future<void> _handleConsentSubmit() async {
    print('LDAToggleAuthDialog - Submitting LDA consent for challengeMode: ${widget.challengeMode}');

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    // User clicked "Enable LDA" - consent is true
    final response = await RdnaService.getInstance().setUserConsentForLDA(
          true,
          widget.challengeMode,
          _ldaAuthType ?? 1,
        );

    print('LDAToggleAuthDialog - SetUserConsentForLDA sync response received');
    print('  Long Error Code: ${response.error?.longErrorCode}');

    if (response.error?.longErrorCode != 0) {
      // Handle sync error response
      setState(() {
        _isSubmitting = false;
        _errorMessage = response.error?.errorString ?? 'Failed to enable LDA';
      });
      return;
    }

    print('LDAToggleAuthDialog - LDA consent submitted successfully');

    // SDK will trigger onDeviceAuthManagementStatus with result
    // Close dialog after successful submission
    print('LDAToggleAuthDialog - Closing consent dialog after successful submission');
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Handle cancel button press
  Future<void> _handleCancel() async {
    print('LDAToggleAuthDialog - User cancelled');
    print('LDAToggleAuthDialog - Current mode: $_mode');
    print('LDAToggleAuthDialog - Challenge mode: ${widget.challengeMode}');
    print('LDAToggleAuthDialog - Is submitting: $_isSubmitting');

    // Prevent double cancellation
    if (_isSubmitting) {
      print('LDAToggleAuthDialog - Already processing, ignoring cancel');
      return;
    }

    // For LDA consent mode, send rejection to SDK
    if (_mode == LDAToggleDialogMode.consent) {
      print('LDAToggleAuthDialog - Sending LDA consent rejection to SDK');
      setState(() {
        _isSubmitting = true;
      });

      final response = await RdnaService.getInstance().setUserConsentForLDA(
            false,
            widget.challengeMode,
            _ldaAuthType ?? 1,
          );

      print('LDAToggleAuthDialog - SetUserConsentForLDA (rejection) sync response received');
      print('  Long Error Code: ${response.error?.longErrorCode}');

      if (response.error?.longErrorCode != 0) {
        print('LDAToggleAuthDialog - LDA consent rejection error: ${response.error?.errorString}');
      } else {
        print('LDAToggleAuthDialog - LDA consent rejection sent successfully');
      }
    }

    if (!mounted) return;
    print('LDAToggleAuthDialog - Closing dialog via Navigator.pop()');

    // Notify parent screen that dialog was cancelled
    if (widget.onCancelled != null) {
      print('LDAToggleAuthDialog - Calling onCancelled callback');
      widget.onCancelled!();
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_mode == LDAToggleDialogMode.password) ..._buildPasswordMode(),
              if (_mode == LDAToggleDialogMode.passwordCreate) ..._buildPasswordCreateMode(),
              if (_mode == LDAToggleDialogMode.consent) ..._buildConsentMode(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds password verification UI (challengeMode 5, 15)
  List<Widget> _buildPasswordMode() {
    // Determine attempts color
    Color attemptsColor = const Color(0xFF27AE60); // green
    if (_attemptsLeft <= 2) attemptsColor = const Color(0xFFF39C12); // orange
    if (_attemptsLeft <= 1) attemptsColor = const Color(0xFFE74C3C); // red

    return [
      // Header
      const Text(
        'Verify Your Password',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
      ),
      const SizedBox(height: 8),
      const Text(
        'Enter your password to disable LDA authentication',
        style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
      ),
      const SizedBox(height: 16),

      // User Info
      Row(
        children: [
          const Text('User: ', style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
          Text(widget.userID, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        ],
      ),
      const SizedBox(height: 8),

      // Attempts Counter
      Row(
        children: [
          const Text('Attempts remaining: ', style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
          Text('$_attemptsLeft', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: attemptsColor)),
        ],
      ),
      const SizedBox(height: 16),

      // Error Message
      if (_errorMessage != null) ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEEBEE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_errorMessage!, style: const TextStyle(fontSize: 14, color: Color(0xFFE74C3C))),
        ),
        const SizedBox(height: 16),
      ],

      // Password Input
      TextField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        obscureText: !_passwordVisible,
        enabled: !_isSubmitting,
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Enter your password',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
          ),
        ),
        onSubmitted: (_) => _handleSubmit(),
      ),
      const SizedBox(height: 24),

      // Buttons
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isSubmitting ? null : _handleCancel,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              disabledBackgroundColor: const Color(0xFFCCCCCC),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Verify', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ];
  }

  /// Builds password creation UI (challengeMode 14)
  List<Widget> _buildPasswordCreateMode() {
    return [
      // Header
      const Text(
        'Create Password',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
      ),
      const SizedBox(height: 8),
      const Text(
        'Set a password to enable LDA authentication',
        style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
      ),
      const SizedBox(height: 16),

      // User Info
      Row(
        children: [
          const Text('User: ', style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
          Text(widget.userID, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        ],
      ),
      const SizedBox(height: 16),

      // Password Policy
      if (_passwordPolicyMessage != null) ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ℹ️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_passwordPolicyMessage!, style: const TextStyle(fontSize: 14, color: Color(0xFF1565C0))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],

      // Error Message
      if (_errorMessage != null) ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEEBEE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_errorMessage!, style: const TextStyle(fontSize: 14, color: Color(0xFFE74C3C))),
        ),
        const SizedBox(height: 16),
      ],

      // Password Input
      TextField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        obscureText: !_passwordVisible,
        enabled: !_isSubmitting,
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Enter password',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
          ),
        ),
        onSubmitted: (_) {
          _confirmPasswordFocusNode.requestFocus();
        },
      ),
      const SizedBox(height: 16),

      // Confirm Password Input
      TextField(
        controller: _confirmPasswordController,
        focusNode: _confirmPasswordFocusNode,
        obscureText: !_confirmPasswordVisible,
        enabled: !_isSubmitting,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          hintText: 'Re-enter password',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(_confirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
          ),
        ),
        onSubmitted: (_) => _handleSubmit(),
      ),
      const SizedBox(height: 24),

      // Buttons
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isSubmitting ? null : _handleCancel,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              disabledBackgroundColor: const Color(0xFFCCCCCC),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Create Password', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ];
  }

  /// Builds LDA consent UI (challengeMode 16)
  List<Widget> _buildConsentMode() {
    return [
      // Header
      const Text(
        'Enable LDA Authentication',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
      ),
      const SizedBox(height: 8),
      const Text(
        'Use biometric authentication for faster and more secure login',
        style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
      ),
      const SizedBox(height: 16),

      // Auth Type Info
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const Text('🔐', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _ldaAuthTypeName ?? 'Biometric Authentication',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Device authentication method',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Custom Message
      if (_customMessage != null && _customMessage!.isNotEmpty) ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ℹ️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_customMessage!, style: const TextStyle(fontSize: 14, color: Color(0xFF1565C0))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],

      // Error Message
      if (_errorMessage != null) ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEEBEE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_errorMessage!, style: const TextStyle(fontSize: 14, color: Color(0xFFE74C3C))),
        ),
        const SizedBox(height: 16),
      ],

      // Info Message
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💡', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Once enabled, you\'ll be able to use ${_ldaAuthTypeName?.toLowerCase() ?? 'biometric authentication'} to authenticate instead of your password.',
                style: const TextStyle(fontSize: 14, color: Color(0xFF1565C0)),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),

      // Buttons
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isSubmitting ? null : _handleCancel,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              disabledBackgroundColor: const Color(0xFFCCCCCC),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Enable LDA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ];
  }
}
