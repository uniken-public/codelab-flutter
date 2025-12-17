// ============================================================================
// File: tutorial_error_screen.dart
// Description: Tutorial Error Screen
//
// Transformed from: src/tutorial/screens/tutorial/TutorialErrorScreen.tsx
// Original: TutorialErrorScreen.tsx
//
// Error screen displayed when SDK initialization fails.
// Shows error details and troubleshooting steps.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:rdna_client/rdna_struct.dart';

/// Tutorial Error Screen
///
/// Displays error information when REL-ID SDK initialization fails.
/// Shows error codes and provides troubleshooting guidance.
class TutorialErrorScreen extends StatelessWidget {
  final RDNAInitializeError error;

  const TutorialErrorScreen({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                color: const Color(0xFFDC2626),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: const Column(
                  children: [
                    Text(
                      'Initialization Failed',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Error Details',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFECACA),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Error Summary Card
              _buildCard(
                borderColor: const Color(0xFFDC2626),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ERROR',
                            style: TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'react-native-rdna-client Initialization Error',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        error.errorString ?? 'An unknown error occurred',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F1D1D),
                          height: 1.43,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Error Codes Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error Codes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCodeRow('Short Error Code:', error.shortErrorCode),
                    const SizedBox(height: 12),
                    _buildCodeRow('Long Error Code:', error.longErrorCode),
                  ],
                ),
              ),

              // Troubleshooting Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Troubleshooting Steps',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTroubleshootingStep('Check your network connection'),
                    const SizedBox(height: 12),
                    _buildTroubleshootingStep('Verify the connection profile configuration'),
                    const SizedBox(height: 12),
                    _buildTroubleshootingStep('Ensure the react-native-rdna-client server is accessible'),
                    const SizedBox(height: 12),
                    _buildTroubleshootingStep('Try restarting the application'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({Widget? child, Color? borderColor}) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null
            ? Border(left: BorderSide(color: borderColor, width: 4))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCodeRow(String label, int? code) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${code ?? "N/A"}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTroubleshootingStep(String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF2563EB),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }
}
