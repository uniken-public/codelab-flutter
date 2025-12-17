// ============================================================================
// File: verify_auth_screen.dart
// Description: Verify Auth Screen
//
// This screen is specifically designed for handling new device activation via REL-ID Verify.
// It automatically initiates the REL-ID Verify process and provides fallback options.
//
// Key Features:
// - Automatically calls performVerifyAuth(true) when screen loads
// - Shows processing status and user information
// - Provides fallback activation flow when device is not handy
// - Real-time error handling and loading states
// - No manual approve/reject buttons - verification is automatic
//
// Transformed from: React Native VerifyAuthScreen.tsx
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../../../uniken/providers/sdk_event_provider.dart';
import '../components/close_button.dart';
import '../components/status_banner.dart';

/// Verify Auth Screen
///
/// Handles new device activation via REL-ID Verify.
/// Auto-calls performVerifyAuth(true) when loaded.
///
/// ## Route Parameters (via extra)
/// - RDNAAddNewDeviceOptions: Device activation data from SDK
///
/// ## Flow
/// 1. Screen loads with device activation data
/// 2. Auto-calls performVerifyAuth(true)
/// 3. REL-ID Verify sends notifications to registered devices
/// 4. User can trigger fallback if devices not available
class VerifyAuthScreen extends ConsumerStatefulWidget {
  final RDNAAddNewDeviceOptions deviceOptions;

  const VerifyAuthScreen({
    super.key,
    required this.deviceOptions,
  });

  @override
  ConsumerState<VerifyAuthScreen> createState() => _VerifyAuthScreenState();
}

class _VerifyAuthScreenState extends ConsumerState<VerifyAuthScreen> {
  bool _isProcessing = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    // Automatically call performVerifyAuth(true) when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleVerifyAuth(true);
    });
  }

  /// Handle close button - direct resetAuthState call
  Future<void> _handleClose() async {
    print('VerifyAuthScreen - Calling resetAuthState');
    final rdnaService = ref.read(rdnaServiceProvider);
    final response = await rdnaService.resetAuthState();

    if (response.error?.longErrorCode == 0) {
      print('VerifyAuthScreen - ResetAuthState successful');
    } else {
      print('VerifyAuthScreen - ResetAuthState error: ${response.error?.errorString}');
    }
  }

  /// Handle REL-ID Verify authentication
  Future<void> _handleVerifyAuth(bool proceed) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _error = '';
    });

    print('VerifyAuthScreen - Performing verify auth: $proceed');
    final rdnaService = ref.read(rdnaServiceProvider);
    final syncResponse = await rdnaService.performVerifyAuth(proceed);

    print('VerifyAuthScreen - PerformVerifyAuth sync response received');
    print('  Long Error Code: ${syncResponse.error?.longErrorCode}');
    print('  Short Error Code: ${syncResponse.error?.shortErrorCode}');
    print('  Error String: ${syncResponse.error?.errorString}');

    if (syncResponse.error?.longErrorCode == 0) {
      // Success
      if (proceed) {
        print('VerifyAuthScreen - REL-ID Verify notification has been sent to registered devices');
      }
      setState(() {
        _isProcessing = false;
      });
    } else {
      // Error
      final errorMessage = syncResponse.error?.errorString ?? 'Failed to perform verify auth';
      setState(() {
        _error = errorMessage;
        _isProcessing = false;
      });
    }
  }

  /// Handle fallback new device activation flow
  Future<void> _handleFallbackFlow() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _error = '';
    });

    print('VerifyAuthScreen - Initiating fallback new device activation flow');
    final rdnaService = ref.read(rdnaServiceProvider);
    final syncResponse = await rdnaService.fallbackNewDeviceActivationFlow();

    print('VerifyAuthScreen - FallbackNewDeviceActivationFlow sync response received');
    print('  Long Error Code: ${syncResponse.error?.longErrorCode}');
    print('  Short Error Code: ${syncResponse.error?.shortErrorCode}');
    print('  Error String: ${syncResponse.error?.errorString}');

    if (syncResponse.error?.longErrorCode == 0) {
      // Success
      print('VerifyAuthScreen - Alternative device activation process has been initiated');
      setState(() {
        _isProcessing = false;
      });
    } else {
      // Error
      final errorMessage = syncResponse.error?.errorString ?? 'Failed to initiate fallback flow';
      setState(() {
        _error = errorMessage;
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // #f8f9fa
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20), // paddingTop: 80 equivalent (60 + 20)
                child: Column(
                  children: [
                    // Title
                    const Text(
                      'Additional Device Activation',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50), // #2c3e50
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Activate this device for user: ${widget.deviceOptions.userId ?? ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7F8C8D), // #7f8c8d
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Error Display
                    if (_error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: StatusBanner(
                          type: StatusBannerType.error,
                          message: _error,
                        ),
                      ),

                    // Processing Status
                    if (_isProcessing)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(8),
                            border: const Border(
                              left: BorderSide(color: Color(0xFF2196F3), width: 4),
                            ),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Processing device activation...',
                                style: TextStyle(color: Color(0xFF1565C0)),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Activation Information
                    // Processing Message
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD), // #e3f2fd
                        borderRadius: BorderRadius.circular(12),
                        border: const Border(
                          left: BorderSide(
                            color: Color(0xFF2196F3), // #2196f3
                            width: 4,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REL-ID Verify Authentication',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2), // #1976d2
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'REL-ID Verify notification has been sent to your registered devices. Please approve it to activate this device.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1565C0), // #1565c0
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Fallback Option
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5), // #f5f5f5
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0), // #e0e0e0
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          const Text(
                            'Device Not Handy?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50), // #2c3e50
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'If you don\'t have access to your registered devices, you can use an alternative activation method.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F8C8D), // #7f8c8d
                              height: 1.43, // lineHeight: 20 / fontSize: 14
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _isProcessing ? null : _handleFallbackFlow,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                side: const BorderSide(color: Color(0xFF3498DB)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isProcessing
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Activate using fallback method',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF3498DB),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Close Button - positioned at top-left
            CustomCloseButton(
              onPressed: _handleClose,
              disabled: _isProcessing,
            ),
          ],
        ),
      ),
    );
  }
}
