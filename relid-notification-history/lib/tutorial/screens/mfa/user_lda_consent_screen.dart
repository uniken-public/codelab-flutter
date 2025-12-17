// ============================================================================
// File: user_lda_consent_screen.dart
// Description: User LDA Consent Screen for Biometric Authentication
//
// Transformed from: UserLDAConsentScreen.tsx
// Handles local device authentication consent (biometric/device auth)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../../../uniken/services/rdna_service.dart';
import '../components/custom_button.dart';
import '../components/close_button.dart';

class UserLDAConsentScreen extends ConsumerStatefulWidget {
  final GetUserConsentForLDAData? eventData;

  const UserLDAConsentScreen({
    super.key,
    this.eventData,
  });

  @override
  ConsumerState<UserLDAConsentScreen> createState() =>
      _UserLDAConsentScreenState();
}

class _UserLDAConsentScreenState extends ConsumerState<UserLDAConsentScreen> {
  bool _isSubmitting = false;
  String? _authenticationTypeName;
  int? _challengeMode;
  int? _authenticationType;

  @override
  void initState() {
    super.initState();
    _processEventData();
  }

  void _processEventData() {
    if (widget.eventData == null) return;

    final data = widget.eventData!;

    print('UserLDAConsentScreen - Processing event data');
    print('  UserID: ${data.userID}');
    print('  ChallengeMode: ${data.challengeMode}');
    print('  AuthenticationType: ${data.authenticationType}');

    setState(() {
      _challengeMode = data.challengeMode;
      _authenticationType = data.authenticationType;
      _authenticationTypeName = _getAuthenticationTypeName(data.authenticationType);
    });
  }

  String _getAuthenticationTypeName(int? authType) {
    if (authType == null) return 'Biometric Authentication';

    // Map authentication types (similar to RN version)
    switch (authType) {
      case 1:
        return 'Fingerprint';
      case 2:
        return 'Face Recognition';
      case 3:
        return 'Device Passcode';
      case 4:
        return 'Pattern Lock';
      default:
        return 'Biometric Authentication';
    }
  }

  Future<void> _handleConsent(bool isEnroll) async {
    setState(() {
      _isSubmitting = true;
    });

    final rdnaService = RdnaService.getInstance();
    final response = await rdnaService.setUserConsentForLDA(
      isEnroll,
      _challengeMode ?? 1,
      _authenticationType ?? 1,
    );

    print('UserLDAConsentScreen - SetUserConsentForLDA sync response received');
    print('  Long Error Code: ${response.error?.longErrorCode}');

    if (response.error?.longErrorCode == 0) {
      print('UserLDAConsentScreen - LDA consent set successfully, waiting for async events');
      // SDK will handle navigation after consent is processed
    } else {
      // Handle sync error response
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.errorString ?? 'Failed to set consent'),
            backgroundColor: const Color(0xFFe74c3c),
          ),
        );
      }
    }
  }

  Future<void> _handleClose() async {
    print('UserLDAConsentScreen - Calling resetAuthState');
    final rdnaService = RdnaService.getInstance();
    final response = await rdnaService.resetAuthState();

    if (response.error?.longErrorCode == 0) {
      print('UserLDAConsentScreen - ResetAuthState successful');
    } else {
      print('UserLDAConsentScreen - ResetAuthState error: ${response.error?.errorString}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFe8f4f8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fingerprint,
                  size: 64,
                  color: Color(0xFF3498db),
                ),
              ),
              const SizedBox(height: 30),

              // Title
              const Text(
                'Local Device Authentication',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                _authenticationTypeName != null
                    ? 'Grant permission for $_authenticationTypeName'
                    : 'Grant permission for device authentication',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7f8c8d),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFecf0f1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Enable biometric authentication for faster and more secure access to your account.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7f8c8d),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Authentication Type: ${_authenticationTypeName ?? "Unknown"}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Approve Button
              CustomButton(
                title: _isSubmitting ? 'Processing...' : 'Approve',
                onPress: () => _handleConsent(true),
                loading: _isSubmitting,
                disabled: _isSubmitting,
              ),
              const SizedBox(height: 12),

              // Reject Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => _handleConsent(false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFe74c3c),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Reject',
                    style: TextStyle(
                      color: Color(0xFFe74c3c),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
