// ============================================================================
// File: security_exit_screen.dart
// Description: Security Exit Screen
//
// iOS-compliant exit guidance screen. Displayed when the app needs to be
// closed due to security threats. Follows Apple Human Interface Guidelines
// which discourage programmatic app termination.
//
// Key Features:
// - iOS HIG-compliant exit guidance
// - Instructions for user to manually close app
// - Security threat context
// - Clean, simple UI with clear instructions
// ============================================================================

import 'package:flutter/material.dart';

/// Security Exit Screen
///
/// Displays iOS-compliant exit guidance when app needs to close due to
/// security threats. Instructs user to manually close the app as per
/// Apple Human Interface Guidelines.
class SecurityExitScreen extends StatelessWidget {
  const SecurityExitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false, // Prevent back navigation
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFDC2626), // #dc2626 (red)
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '🚫',
                        style: TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  const Text(
                    'Security Exit',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Subtitle
                  const Text(
                    'Critical Security Threat Detected',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFECACA), // #fecaca (light red)
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Instructions card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'Please Close This App',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937), // #1f2937 (dark gray)
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'For your security, this application must be closed.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280), // #6b7280 (gray)
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Instructions
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6), // #f3f4f6 (light gray)
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'To close this app:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4B5563), // #4b5563 (gray)
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInstruction(
                                '1',
                                'Swipe up from the bottom of the screen and pause in the middle',
                              ),
                              const SizedBox(height: 8),
                              _buildInstruction(
                                '2',
                                'Find this app in the app switcher',
                              ),
                              const SizedBox(height: 8),
                              _buildInstruction(
                                '3',
                                'Swipe up on this app to close it',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Do not open this app again until the security issue has been resolved.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFDC2626), // #dc2626 (red)
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB), // #2563eb (blue)
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563), // #4b5563 (gray)
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
