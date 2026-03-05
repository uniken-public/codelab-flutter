// ============================================================================
// File: threat_detection_modal.dart
// Description: Mobile Threat Detection Modal Component
//
//
// Modal dialog for displaying detected security threats with user action options.
// Supports two modes: consent mode (proceed/exit) and terminate mode (exit only).
//
// Key Features:
// - Threat list display with severity indicators
// - Category icons and color-coded severity badges
// - Consent mode: Proceed Anyway + Exit Application buttons
// - Terminate mode: Exit Application button only
// - Processing states with loading indicators
// - Exact color matching with React Native version
// ============================================================================

import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'package:rdna_client/rdna_struct.dart';

/// Threat Detection Modal
///
/// Displays detected security threats in a modal dialog with appropriate
/// actions based on the threat severity (consent vs terminate).
class ThreatDetectionModal extends StatelessWidget {
  final bool visible;
  final List<RDNAThreat> threats;
  final bool isConsentMode;
  final bool isProcessing;
  final bool processingExit;
  final VoidCallback? onProceed;
  final VoidCallback onExit;

  const ThreatDetectionModal({
    super.key,
    required this.visible,
    required this.threats,
    required this.isConsentMode,
    this.isProcessing = false,
    this.processingExit = false,
    this.onProceed,
    required this.onExit,
  });

  /// Get severity color based on threat severity level
  /// EXACT colors from React Native version
  Color _getThreatSeverityColor(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFDC2626); // #dc2626 (red)
      case 'MEDIUM':
        return const Color(0xFFF59E0B); // #f59e0b (orange)
      case 'LOW':
        return const Color(0xFF10B981); // #10b981 (green)
      default:
        return const Color(0xFF6B7280); // #6b7280 (gray)
    }
  }

  /// Get category icon emoji based on threat category
  String _getThreatCategoryIcon(String? category) {
    switch (category?.toUpperCase()) {
      case 'SYSTEM':
        return '🛡️';
      case 'NETWORK':
        return '🌐';
      case 'APP':
        return '📱';
      default:
        return '⚠️';
    }
  }

  /// Renders a single threat item
  Widget _buildThreatItem(RDNAThreat threat) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // #fef2f2 (light red background)
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(
            color: Color(0xFFDC2626), // #dc2626 (red left border)
            width: 4,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Threat header
          Row(
            children: [
              // Category icon
              Text(
                _getThreatCategoryIcon(threat.threatCategory),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              // Threat name and category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      threat.threatName ?? 'Unknown Threat',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937), // #1f2937 (dark gray)
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (threat.threatCategory ?? 'UNKNOWN').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280), // #6b7280 (gray)
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Severity badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getThreatSeverityColor(threat.threatSeverity),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  (threat.threatSeverity ?? 'UNKNOWN').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Threat message
          Text(
            threat.threatMsg ?? 'No message available',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F1D1D), // #7f1d1d (dark red)
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return PopScope(
      canPop: false, // Prevent dismissal with back button
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626), // #dc2626 (red)
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      isConsentMode
                          ? '⚠️ Security Threats Detected'
                          : '🚫 Security Threat - Action Required',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isConsentMode
                          ? 'Review the detected threats and choose how to proceed'
                          : 'Critical security threats detected. Application must exit for safety.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFECACA), // #fecaca (light red)
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Threats list
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detected Threats (${threats.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937), // #1f2937 (dark gray)
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...threats.map((threat) => _buildThreatItem(threat)),
                    ],
                  ),
                ),
              ),
              // Action buttons
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFF3F4F6), // #f3f4f6 (light gray)
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Proceed button (consent mode only)
                    if (isConsentMode && onProceed != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isProcessing ? null : onProceed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B), // #f59e0b (orange)
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: isProcessing && !processingExit
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
                                    SizedBox(width: 8),
                                    Text(
                                      'Processing...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Proceed Anyway',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Exit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : onExit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626), // #dc2626 (red)
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: isProcessing && processingExit
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
                                  SizedBox(width: 8),
                                  Text(
                                    'Processing Exit...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Exit Application',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
