/// Update Password Screen (Password Update Credentials Flow)
///
/// This screen is designed for updating passwords via the credential update flow.
/// It handles challengeMode = 2 (RDNA_OP_UPDATE_CREDENTIALS) where users can update
/// their password by providing current and new passwords.
///
/// ## Key Features
/// - Current password, new password, and confirm password inputs with validation
/// - Password policy parsing and validation
/// - Real-time error handling and loading states
/// - Attempts left counter display
/// - Success/error feedback
/// - Password policy display
/// - Challenge mode 2 handling for password updates
///
/// ## Usage
/// ```dart
/// context.go('/update-password', extra: {
///   'eventData': data,
///   'title': 'Update Password',
///   'subtitle': 'Update your account password',
///   'responseData': data
/// });
/// ```

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../../../uniken/services/rdna_service.dart';
import '../../../uniken/services/rdna_event_manager.dart';
import '../../../uniken/providers/sdk_event_provider.dart';
import '../../../uniken/utils/password_policy_utils.dart';
import '../components/custom_button.dart';
import '../components/custom_input.dart';
import '../components/status_banner.dart';

/// Update Password Screen Component
class UpdatePasswordScreen extends ConsumerStatefulWidget {
  final RDNAGetPassword? eventData;
  final RDNAGetPassword? responseData;

  const UpdatePasswordScreen({
    Key? key,
    this.eventData,
    this.responseData,
  }) : super(key: key);

  @override
  ConsumerState<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  final _currentPasswordFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  String _error = '';
  bool _isSubmitting = false;
  int _challengeMode = 2;
  String _userName = '';
  String _passwordPolicyMessage = '';
  int _attemptsLeft = 3;

  final _rdnaService = RdnaService.getInstance();

  // Store original handlers for restoration
  RDNAGetPasswordCallback? _originalGetPasswordHandler;

  @override
  void initState() {
    super.initState();
    _setupEventHandlers();
    _processResponseData();
  }

  @override
  void dispose() {
    // Cleanup event handlers
    _rdnaService.getEventManager().setUpdateCredentialResponseHandler(null);

    // Restore original getPassword handler
    if (_originalGetPasswordHandler != null) {
      _rdnaService.getEventManager().setGetPasswordHandler(_originalGetPasswordHandler);
    }

    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  /// Set up event handlers for onUpdateCredentialResponse and getPassword retry
  void _setupEventHandlers() {
    final eventManager = _rdnaService.getEventManager();

    // Preserve original getPassword handler from SDKEventProvider
    _originalGetPasswordHandler = eventManager.getPasswordHandler;

    // Intercept getPassword events for challengeMode 2 retry handling
    eventManager.setGetPasswordHandler((data) {
      // Only handle challengeMode 2 when this screen is mounted
      if (mounted && data.challengeMode == 2) {
        print('UpdatePasswordScreen - Get password retry received (challengeMode 2)');
        print('  StatusCode: ${data.challengeResponse?.status?.statusCode}');
        print('  AttemptsLeft: ${data.attemptsLeft}');

        // Reset submitting state (this fixes the loader issue)
        setState(() {
          _isSubmitting = false;
        });

        // Check for errors in retry
        final statusCode = data.challengeResponse?.status?.statusCode ?? -1;
        final statusMessage = data.challengeResponse?.status?.statusMessage ?? 'Unknown error';

        if (statusCode != 100) {
          // Wrong password or other error - show error and allow retry
          setState(() {
            _error = statusMessage;
            _attemptsLeft = data.attemptsLeft ?? 3;
          });
          _resetInputs();
        } else {
          // StatusCode 100 - update state for retry
          setState(() {
            _attemptsLeft = data.attemptsLeft ?? 3;
          });
        }

        // Don't call original handler to prevent re-navigation by SDKEventProvider
        return;
      }

      // For other challenge modes, call preserved original handler
      if (_originalGetPasswordHandler != null) {
        _originalGetPasswordHandler!(data);
      }
    });

    // Set up handler for update credential response
    eventManager.setUpdateCredentialResponseHandler((data) {
      print('UpdatePasswordScreen - Update credential response received:');
      print('  userId: ${data.userId}');
      print('  credType: ${data.credType}');
      print('  error.longErrorCode: ${data.error?.longErrorCode}');
      print('  statusCode: ${data.status?.statusCode}');
      print('  statusMessage: ${data.status?.statusMessage}');

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // IMPORTANT: Check error object FIRST before status
      // Following React Native pattern: check hasApiError() before hasStatusError()

      // Check for API-level errors first
      if (data.error != null && data.error!.longErrorCode != 0) {
        final errorMessage = data.error!.errorString ?? 'API error occurred';
        print('UpdatePasswordScreen - API error: $errorMessage');

        // Clear all password fields
        _resetInputs();
        setState(() {
          _error = errorMessage;
        });
        return;
      }

      // Now check status codes
      final statusCode = data.status?.statusCode ?? -1;
      final statusMessage = data.status?.statusMessage ?? 'Unknown error';

      if (statusCode == 100 || statusCode == 0) {
        // Success case - don't clear fields, just navigate
        _showSuccessDialog(statusMessage);
      } else if (statusCode == 110 || statusCode == 153 || statusCode == 190) {
        // Critical error cases that trigger logout
        // statusCode 110: Password has expired
        // statusCode 153: Attempts exhausted, user/device blocked
        // statusCode 190: Password does not meet policy standards

        // Clear all password fields
        _resetInputs();
        setState(() {
          _error = statusMessage;
        });

        _showCriticalErrorDialog(statusMessage);
      } else {
        // Other error cases
        // Clear all password fields
        _resetInputs();
        setState(() {
          _error = statusMessage;
        });
        print('UpdatePasswordScreen - Update credential error: $statusMessage');
      }
    });
  }

  /// Process response data from route params
  void _processResponseData() {
    if (widget.responseData != null) {
      final data = widget.responseData!;
      print('UpdatePasswordScreen - Processing response data from RDNAGetPassword');

      // Extract challenge data from RDNAGetPassword object
      setState(() {
        _userName = data.userId ?? '';
        _challengeMode = data.challengeMode ?? 2;
        _attemptsLeft = data.attemptsLeft ?? 3;
      });

      // Extract and process password policy from challenge info
      final challengeInfo = data.challengeResponse?.challengeInfo;
      if (challengeInfo != null && challengeInfo.isNotEmpty) {
        // Find RELID_PASSWORD_POLICY challenge (note: uses 'key' not 'name')
        try {
          final policyChallenge = challengeInfo.firstWhere(
            (c) => c.key == 'RELID_PASSWORD_POLICY',
          );

          if (policyChallenge.value != null) {
            final policyMessage = parseAndGeneratePolicyMessage(policyChallenge.value!);
            setState(() {
              _passwordPolicyMessage = policyMessage;
            });
            print('UpdatePasswordScreen - Password policy extracted: $policyMessage');
          }
        } catch (e) {
          print('UpdatePasswordScreen - RELID_PASSWORD_POLICY not found in challenge info');
        }
      }

      // Check for API-level errors first
      if (data.error != null && data.error!.longErrorCode != 0) {
        final errorMessage = data.error!.errorString ?? 'Unknown error';
        print('UpdatePasswordScreen - API error: $errorMessage');
        setState(() {
          _error = errorMessage;
        });
        _resetInputs();
        return;
      }

      // Check for status errors
      final statusCode = data.challengeResponse?.status?.statusCode;
      if (statusCode != null && statusCode != 100) {
        final errorMessage = data.challengeResponse?.status?.statusMessage ?? 'Unknown error';
        print('UpdatePasswordScreen - Status error: $errorMessage');
        setState(() {
          _error = errorMessage;
        });
        _resetInputs();
        return;
      }

      // Success case - ready for input
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// Reset form inputs
  void _resetInputs() {
    setState(() {
      _currentPassword = '';
      _newPassword = '';
      _confirmPassword = '';
    });
    _currentPasswordFocus.requestFocus();
  }

  /// Handle password update submission
  Future<void> _handleUpdatePassword() async {
    if (_isSubmitting) return;

    final trimmedCurrentPassword = _currentPassword.trim();
    final trimmedNewPassword = _newPassword.trim();
    final trimmedConfirmPassword = _confirmPassword.trim();

    // Basic validation
    if (trimmedCurrentPassword.isEmpty) {
      setState(() {
        _error = 'Please enter your current password';
      });
      _currentPasswordFocus.requestFocus();
      return;
    }

    if (trimmedNewPassword.isEmpty) {
      setState(() {
        _error = 'Please enter a new password';
      });
      _newPasswordFocus.requestFocus();
      return;
    }

    if (trimmedConfirmPassword.isEmpty) {
      setState(() {
        _error = 'Please confirm your new password';
      });
      _confirmPasswordFocus.requestFocus();
      return;
    }

    // Check password match
    if (trimmedNewPassword != trimmedConfirmPassword) {
      setState(() {
        _error = 'New password and confirm password do not match';
        _newPassword = '';
        _confirmPassword = '';
      });
      _newPasswordFocus.requestFocus();
      return;
    }

    // Check if new password is same as current password
    if (trimmedCurrentPassword == trimmedNewPassword) {
      setState(() {
        _error = 'New password must be different from current password';
        _newPassword = '';
        _confirmPassword = '';
      });
      _newPasswordFocus.requestFocus();
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = '';
    });

    try {
      print('UpdatePasswordScreen - Updating password with challengeMode: $_challengeMode');

      final response = await _rdnaService.updatePassword(
        trimmedCurrentPassword,
        trimmedNewPassword,
        RDNAChallengeOpMode.RDNA_OP_UPDATE_CREDENTIALS,
      );

      print('UpdatePasswordScreen - UpdatePassword sync response received');
      print('UpdatePasswordScreen - Sync response:');
      print('  longErrorCode: ${response.error?.longErrorCode}');
      print('  shortErrorCode: ${response.error?.shortErrorCode}');
      print('  errorString: ${response.error?.errorString}');

      // Check sync response for errors FIRST (Flutter plugin pattern)
      if (response.error?.longErrorCode != 0) {
        final errorMessage = response.error?.errorString ?? 'Update password failed';
        print('UpdatePasswordScreen - UpdatePassword sync error: $errorMessage');

        setState(() {
          _error = errorMessage;
          _isSubmitting = false;
        });
        _resetInputs();
        return;
      }

      print('UpdatePasswordScreen - UpdatePassword sync successful, waiting for async events');
      // Success - wait for onUpdateCredentialResponse event
      // Event handlers will handle the navigation and reset _isSubmitting

    } catch (error) {
      // This catch block handles exceptions (network errors, etc.)
      print('UpdatePasswordScreen - UpdatePassword exception: $error');

      final errorMessage = error.toString();
      setState(() {
        _error = errorMessage;
        _isSubmitting = false;
      });
      _resetInputs();
    }
  }

  /// Show success dialog and navigate to dashboard
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message.isNotEmpty ? message : 'Password updated successfully'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back to dashboard with previous session data
              final sessionData = ref.read(sessionDataProvider);
              context.go('/dashboard', extra: sessionData);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show critical error dialog
  void _showCriticalErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // User will be logged off automatically by SDK
              // getUser event will be triggered and handled
              print('UpdatePasswordScreen - Critical error, waiting for onUserLoggedOff and getUser events');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Check if form is valid
  bool _isFormValid() {
    return _currentPassword.trim().isNotEmpty &&
        _newPassword.trim().isNotEmpty &&
        _confirmPassword.trim().isNotEmpty &&
        _error.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2C3E50), size: 24),
          onPressed: () {
            // Navigate back to dashboard with previous session data
            final sessionData = ref.read(sessionDataProvider);
            context.go('/dashboard', extra: sessionData);
          },
        ),
        title: const Text(
          'Update Password',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Information
              if (_userName.isNotEmpty) ...[
                const Text(
                  'User',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3498DB),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Attempts Left Counter
              if (_attemptsLeft <= 3)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: _attemptsLeft == 1 ? const Color(0xFFF8D7DA) : const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(
                        color: _attemptsLeft == 1 ? const Color(0xFFDC3545) : const Color(0xFFFFC107),
                        width: 4,
                      ),
                    ),
                  ),
                  child: Text(
                    'Attempts remaining: $_attemptsLeft',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _attemptsLeft == 1 ? const Color(0xFF721C24) : const Color(0xFF856404),
                    ),
                  ),
                ),

              // Password Policy Display
              if (_passwordPolicyMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F8FF),
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(
                      left: BorderSide(color: Color(0xFF3498DB), width: 4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password Requirements',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _passwordPolicyMessage,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C3E50),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

              // Error Display
              if (_error.isNotEmpty)
                StatusBanner(
                  type: StatusBannerType.error,
                  message: _error,
                ),

              // Current Password Input
              CustomInput(
                value: _currentPassword,
                focusNode: _currentPasswordFocus,
                label: 'Current Password',
                placeholder: 'Enter current password',
                obscureText: true,
                enabled: !_isSubmitting,
                onChanged: (value) {
                  setState(() {
                    _currentPassword = value;
                    if (_error.isNotEmpty) _error = '';
                  });
                },
                onSubmitted: () => _newPasswordFocus.requestFocus(),
              ),
              const SizedBox(height: 20),

              // New Password Input
              CustomInput(
                value: _newPassword,
                focusNode: _newPasswordFocus,
                label: 'New Password',
                placeholder: 'Enter new password',
                obscureText: true,
                enabled: !_isSubmitting,
                onChanged: (value) {
                  setState(() {
                    _newPassword = value;
                    if (_error.isNotEmpty) _error = '';
                  });
                },
                onSubmitted: () => _confirmPasswordFocus.requestFocus(),
              ),
              const SizedBox(height: 20),

              // Confirm New Password Input
              CustomInput(
                value: _confirmPassword,
                focusNode: _confirmPasswordFocus,
                label: 'Confirm New Password',
                placeholder: 'Confirm new password',
                obscureText: true,
                enabled: !_isSubmitting,
                onChanged: (value) {
                  setState(() {
                    _confirmPassword = value;
                    if (_error.isNotEmpty) _error = '';
                  });
                },
                onSubmitted: () => _handleUpdatePassword(),
              ),
              const SizedBox(height: 20),

              // Submit Button
              CustomButton(
                title: _isSubmitting ? 'Updating Password...' : 'Update Password',
                onPress: _isFormValid() ? _handleUpdatePassword : null,
                loading: _isSubmitting,
                disabled: !_isFormValid(),
              ),

              // Help Text
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Update your password. Your new password must be different from your current password and meet all policy requirements.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
