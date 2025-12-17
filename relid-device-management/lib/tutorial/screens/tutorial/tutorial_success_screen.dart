// ============================================================================
// File: tutorial_success_screen.dart
// Description: Tutorial Success Screen
//
// Success screen displayed after successful SDK initialization.
// Shows session details and next steps information.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:rdna_client/rdna_struct.dart';

/// Tutorial Success Screen
///
/// Displays success information after successful REL-ID SDK initialization.
/// Shows session details including session ID, type, and status information.
class TutorialSuccessScreen extends StatelessWidget {
  final RDNAInitialized data;

  const TutorialSuccessScreen({
    super.key,
    required this.data,
  });

  String _getSessionTypeDescription(int? type) {
    if (type == null) return 'Unknown';

    const sessionTypes = {
      0: 'App Session',
      1: 'User Session',
    };

    return sessionTypes[type] ?? 'Session Type $type';
  }

  String _formatSessionId(String? sessionId) {
    if (sessionId == null || sessionId.isEmpty) return '';

    // Format session ID for better readability
    if (sessionId.length > 16) {
      return '${sessionId.substring(0, 8)}-${sessionId.substring(8, 16)}-${sessionId.substring(16, 24)}...';
    }
    return sessionId;
  }

  @override
  Widget build(BuildContext context) {
    final sessionTypeDescription = _getSessionTypeDescription(data.session?.sessionType);
    final formattedSessionId = _formatSessionId(data.session?.sessionId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                color: const Color(0xFF16A34A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: const Column(
                  children: [
                    Text(
                      'Initialization Success!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'react-native-rdna-client Ready',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFBBF7D0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Success Summary Card
              _buildCard(
                borderColor: const Color(0xFF16A34A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SUCCESS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'react-native-rdna-client plugin initialized successfully',
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
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'The react-native-rdna-client has been successfully initialized and is ready to use for secure authentication and communication.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF166534),
                          height: 1.43,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Session Details Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Status Code:',
                      Text(
                        '${data.status?.statusCode ?? "N/A"}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF166534),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Session Type:',
                      Text(
                        sessionTypeDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Session ID:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              formattedSessionId,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                                fontFamily: 'monospace',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Next Steps Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What\'s Next?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildNextStep('✓', 'react-native-rdna-client is now ready for secure operations'),
                    const SizedBox(height: 16),
                    _buildNextStep('🔐', 'You can now perform authenticated API calls'),
                    const SizedBox(height: 16),
                    _buildNextStep('🚀', 'Use the session for secure communication'),
                    const SizedBox(height: 16),
                    _buildNextStep('📱', 'Continue with your application flow'),
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

  Widget _buildInfoRow(String label, Widget value) {
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
        value,
      ],
    );
  }

  Widget _buildNextStep(String icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 16),
            ),
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
