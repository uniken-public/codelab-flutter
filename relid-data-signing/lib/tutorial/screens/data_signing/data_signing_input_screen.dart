// ============================================================================
// File: data_signing_input_screen.dart
// Description: Data Signing Input Screen
//
// Screen for collecting data signing parameters from user.
// Includes form with payload input, auth level dropdown, authenticator type
// dropdown, and reason input.
//
// Transformed from: React Native DataSigningInputScreen.tsx
//
// Features:
// - Multi-line payload input with character counter
// - Auth level dropdown with validation
// - Authenticator type dropdown with validation
// - Reason input with character counter
// - Form validation before submission
// - Loading state during API calls
// - Integration with PasswordChallengeModal for step-up auth
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import 'package:go_router/go_router.dart';
import 'data_signing_service.dart';
import 'dropdown_data_service.dart';
import 'data_signing_types.dart';
import '../components/drawer_content.dart';
import '../../../uniken/services/rdna_service.dart';
import '../../../uniken/services/rdna_event_manager.dart';
import 'components/password_challenge_modal.dart';

/// Data Signing Input Screen
///
/// Main screen for data signing input form.
/// Collects payload, auth level, authenticator type, and reason from user.
class DataSigningInputScreen extends ConsumerStatefulWidget {
  final RDNAUserLoggedIn? sessionData;

  const DataSigningInputScreen({
    Key? key,
    this.sessionData,
  }) : super(key: key);

  @override
  ConsumerState<DataSigningInputScreen> createState() => _DataSigningInputScreenState();
}

class _DataSigningInputScreenState extends ConsumerState<DataSigningInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _payloadController = TextEditingController();
  final _reasonController = TextEditingController();

  String? _selectedAuthLevel;
  String? _selectedAuthenticatorType;
  bool _isLoading = false;
  bool _handlersRegistered = false; // Track handler registration state

  RDNADataSigningResponseCallback? _originalDataSigningHandler;
  RDNAGetPasswordCallback? _originalGetPasswordHandler;

  @override
  void initState() {
    super.initState();
    _setupDataSigningEventHandler();
    _setupGetPasswordEventHandler();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-register handlers when coming back to this screen
    if (!_handlersRegistered) {
      print('DataSigningInputScreen - didChangeDependencies: Re-registering handlers');
      _setupDataSigningEventHandler();
      _setupGetPasswordEventHandler();
    }
  }

  @override
  void dispose() {
    _cleanupDataSigningEventHandler();
    _cleanupGetPasswordEventHandler();
    _payloadController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  /// Setup data signing event handler when screen mounts
  void _setupDataSigningEventHandler() {
    final rdnaService = RdnaService.getInstance();
    final eventManager = rdnaService.getEventManager();

    // Preserve existing handler (callback preservation pattern)
    _originalDataSigningHandler = eventManager.getDataSigningResponseHandler;

    // Set our handler
    eventManager.setDataSigningResponseHandler(_handleDataSigningResponse);

    print('DataSigningInputScreen - Data signing event handler registered');
  }

  /// Cleanup data signing event handler when screen unmounts
  void _cleanupDataSigningEventHandler() {
    final rdnaService = RdnaService.getInstance();
    final eventManager = rdnaService.getEventManager();

    // Only restore if current handler is still ours (not overwritten by another screen)
    final currentHandler = eventManager.getDataSigningResponseHandler;
    if (currentHandler == _handleDataSigningResponse) {
      eventManager.setDataSigningResponseHandler(_originalDataSigningHandler);
      print('DataSigningInputScreen - Data signing event handler cleaned up and restored');
    } else {
      print('DataSigningInputScreen - Data signing handler was overwritten, not restoring');
    }

    _handlersRegistered = false; // Mark handlers as not registered
  }

  /// Handles data signing response event
  void _handleDataSigningResponse(AuthenticateUserAndSignData response) {
    print('DataSigningInputScreen - Data signing response received');
    print('  Status Code: ${response.status?.statusCode}');
    print('  Error Code: ${response.error?.shortErrorCode}');

    // Stop loading state
    if (mounted) {
      setState(() => _isLoading = false);
    }

    // Check error first
    if (response.error?.shortErrorCode != 0) {
      // Error occurred
      print('DataSigningInputScreen - Data signing error:');
      print('  Error Code: ${response.error?.shortErrorCode}');
      print('  Error Message: ${response.error?.errorString}');

      if (mounted) {
        final errorMessage = response.error?.errorString ??
                            DataSigningService.getErrorMessage(response.error?.shortErrorCode ?? -1);
        _showErrorDialog('Data signing failed: $errorMessage');
      }
      return;
    }

    // Check status code
    if (response.status?.statusCode != 100) {
      // Status not success
      print('DataSigningInputScreen - Data signing status error:');
      print('  Status Code: ${response.status?.statusCode}');

      if (mounted) {
        _showErrorDialog('Data signing failed with status: ${response.status?.statusCode}');
      }
      return;
    }

    // Success - both error code 0 and status code 100
    print('DataSigningInputScreen - Data signing successful, navigating to result screen');

    // Navigate to results screen with the response data
    if (mounted) {
      context.push('/data-signing-result', extra: response);
    }

    // Call original handler if it exists (callback preservation pattern)
    if (_originalDataSigningHandler != null) {
      _originalDataSigningHandler!(response);
    }
  }

  /// Setup getPassword event handler for challengeMode 12 (data signing step-up auth)
  void _setupGetPasswordEventHandler() {
    final rdnaService = RdnaService.getInstance();
    final eventManager = rdnaService.getEventManager();

    // Preserve existing handler (callback preservation pattern)
    _originalGetPasswordHandler = eventManager.getPasswordHandler;

    // Set our handler that intercepts challengeMode 12
    eventManager.setGetPasswordHandler(_handleGetPassword);

    _handlersRegistered = true; // Mark handlers as registered

    print('DataSigningInputScreen - GetPassword event handler registered');
  }

  /// Cleanup getPassword event handler when screen unmounts
  void _cleanupGetPasswordEventHandler() {
    final rdnaService = RdnaService.getInstance();
    final eventManager = rdnaService.getEventManager();

    // Only restore if current handler is still ours (not overwritten by another screen)
    final currentHandler = eventManager.getPasswordHandler;
    if (currentHandler == _handleGetPassword) {
      eventManager.setGetPasswordHandler(_originalGetPasswordHandler);
      print('DataSigningInputScreen - GetPassword event handler cleaned up and restored');
    } else {
      print('DataSigningInputScreen - GetPassword handler was overwritten, not restoring');
    }
  }

  /// Handles getPassword event (intercepts challengeMode 12 for data signing)
  void _handleGetPassword(RDNAGetPassword data) {
    print('DataSigningInputScreen - GetPassword event received');
    print('  ChallengeMode: ${data.challengeMode}');
    print('  AttemptsLeft: ${data.attemptsLeft}');

    // Check if this is data signing step-up authentication (challengeMode 12)
    if (data.challengeMode == 12) {
      print('DataSigningInputScreen - ChallengeMode 12 detected, showing password modal');

      // Show password challenge modal
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PasswordChallengeModal(
            challengeMode: data.challengeMode ?? 12,
            attemptsLeft: data.attemptsLeft ?? 3,
            onSubmit: (password) async {
              final response = await DataSigningService.submitPassword(password, data.challengeMode ?? 12);

              // Check sync response
              if (response.error?.longErrorCode == 0) {
                // Sync response success - close modal immediately
                if (mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
              } else {
                // Sync error - modal stays open, SDK will trigger getPassword again with decremented attempts
                print('DataSigningInputScreen - Password submission sync error: ${response.error?.errorString}');

                // Show error dialog
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Password Error'),
                      content: Text(response.error?.errorString ?? 'Password submission failed'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            onCancel: () async {
              final response = await DataSigningService.resetState();

              if (mounted) {
                setState(() {
                  _isLoading = false;
                });

                // Check if reset had errors (modal will close itself)
                if (response.error?.longErrorCode != 0) {
                  print('DataSigningInputScreen - Reset state error: ${response.error?.errorString}');
                  // Show error after modal closes
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      _showErrorDialog(response.error?.errorString ?? 'Failed to reset state');
                    }
                  });
                }
              }
            },
            context: DataSigningFormState(
              payload: _payloadController.text,
              selectedAuthLevel: _selectedAuthLevel ?? '',
              selectedAuthenticatorType: _selectedAuthenticatorType ?? '',
              reason: _reasonController.text,
            ),
          ),
        );
      }
    } else {
      // Not data signing, call original handler for other challenge modes
      print('DataSigningInputScreen - ChallengeMode ${data.challengeMode}, delegating to original handler');
      if (_originalGetPasswordHandler != null) {
        _originalGetPasswordHandler!(data);
      }
    }
  }

  /// Handles form submission
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validation
    final validation = DataSigningService.validateSigningInput(
      payload: _payloadController.text,
      authLevel: _selectedAuthLevel ?? '',
      authenticatorType: _selectedAuthenticatorType ?? '',
      reason: _reasonController.text,
    );

    if (!validation.isValid) {
      _showErrorDialog(validation.errors.join('\n'));
      return;
    }

    setState(() => _isLoading = true);

    // Convert dropdown values to numeric values
    final values = DataSigningService.convertDropdownToInts(
      _selectedAuthLevel!,
      _selectedAuthenticatorType!,
    );

    // Create request
    final request = DataSigningRequest(
      payload: _payloadController.text.trim(),
      authLevel: values['authLevel']!,
      authenticatorType: values['authenticatorType']!,
      reason: _reasonController.text.trim(),
    );

    // Initiate data signing
    final response = await DataSigningService.signData(request);

    // Check sync response
    if (response.error?.longErrorCode == 0) {
      // Success - SDK will trigger getPassword event for step-up auth,
      // which will be handled by the provider/event manager
      // Modal will be shown, and on success, will navigate to results screen
    } else {
      // Sync error
      print('DataSigningInputScreen - Sign data sync error: ${response.error?.errorString}');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog(response.error?.errorString ?? 'Data signing failed');
      }
    }
  }

  /// Shows error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Signing'),
        backgroundColor: const Color(0xFF007AFF),
        foregroundColor: Colors.white,
      ),
      drawer: DrawerContent(
        sessionData: widget.sessionData,
        currentRoute: 'dataSigningInputScreen',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 30),

              // Info Section
              _buildInfoSection(),
              const SizedBox(height: 30),

              // Payload Input
              _buildPayloadInput(),
              const SizedBox(height: 24),

              // Auth Level Dropdown
              _buildAuthLevelDropdown(),
              const SizedBox(height: 24),

              // Authenticator Type Dropdown
              _buildAuthenticatorTypeDropdown(),
              const SizedBox(height: 24),

              // Reason Input
              _buildReasonInput(),
              const SizedBox(height: 30),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header
  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          'Data Signing',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Sign your data with cryptographic authentication',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the info section
  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Color(0xFF007AFF), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How it works:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '1. Enter your data payload and select authentication parameters\n'
            '2. Click "Sign Data" to initiate the signing process\n'
            '3. Complete authentication when prompted\n'
            '4. Receive your cryptographically signed data',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the payload input
  Widget _buildPayloadInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Payload *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _payloadController,
          maxLines: 4,
          maxLength: maxPayloadLength,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Enter the data you want to sign...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            counterText: '${_payloadController.text.length}/$maxPayloadLength',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Payload is required';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  /// Builds the auth level dropdown
  Widget _buildAuthLevelDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Authentication Level *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedAuthLevel,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Select authentication level',
          ),
          items: DropdownDataService.getAuthLevelOptions()
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
          onChanged: _isLoading
              ? null
              : (value) {
                  setState(() => _selectedAuthLevel = value);
                },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an authentication level';
            }
            return null;
          },
        ),
        const SizedBox(height: 4),
        const Text(
          'Level 4 is recommended for maximum security',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// Builds the authenticator type dropdown
  Widget _buildAuthenticatorTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Authenticator Type *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedAuthenticatorType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Select authenticator type',
          ),
          items: DropdownDataService.getAuthenticatorTypeOptions()
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
          onChanged: _isLoading
              ? null
              : (value) {
                  setState(() => _selectedAuthenticatorType = value);
                },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an authenticator type';
            }
            return null;
          },
        ),
        const SizedBox(height: 4),
        const Text(
          'Choose the authentication method for signing',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// Builds the reason input
  Widget _buildReasonInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Signing Reason *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _reasonController,
          maxLength: maxReasonLength,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Enter reason for signing',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            counterText: '${_reasonController.text.length}/$maxReasonLength',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Reason is required';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  /// Builds the submit button
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFF007AFF),
        disabledBackgroundColor: const Color(0xFFCCCCCC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      child: _isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Processing...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : const Text(
              'Sign Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    );
  }
}
