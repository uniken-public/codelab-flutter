// ============================================================================
// File: progress_helper.dart
// Description: Progress Helper Utilities
//
// Transformed from: src/uniken/utils/progressHelper.ts
// Original: progressHelper.ts
//
// Simple utility functions for handling progress messages.
// Extracted from reference implementation for reusability.
// ============================================================================

import 'package:rdna_client/rdna_struct.dart';

/// Progress Message Helper - Extracted from reference implementation
///
/// Formats progress data into user-friendly messages for display during
/// REL-ID SDK initialization.
///
/// ## Parameters
/// - [data]: Progress status data from the SDK
///
/// ## Returns
/// Formatted progress message string
///
/// ## Example
/// ```dart
/// final progressData = RDNAInitProgressStatus(...);
/// final message = getProgressMessage(progressData);
/// print(message); // "RDNA initialization started..."
/// ```
String getProgressMessage(RDNAInitProgressStatus data) {
  final systemStatus = data.systemThreatCheckStatus ?? '';
  final appStatus = data.appThreatCheckStatus ?? '';
  final networkStatus = data.networkThreatCheckStatus ?? '';
  final initStatus = data.initializeStatus ?? '';

  // Helper function to get user-friendly status text
  String getStatusText(String status) {
    switch (status) {
      case 'STARTED':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'NOT_STARTED':
        return 'Pending';
      case 'NOT_APPLICABLE':
        return 'Not Required';
      case 'INIT_FAILED':
        return 'Failed';
      default:
        return status;
    }
  }

  // Check for any failed statuses first
  if (initStatus == 'INIT_FAILED') {
    return 'Initialization failed - Please check logs';
  }

  // Primary status based on initializeStatus
  String primaryMessage;
  switch (initStatus) {
    case 'STARTED':
      primaryMessage = 'RDNA initialization started...';
      break;
    case 'COMPLETED':
      primaryMessage = 'RDNA initialization completed!';
      break;
    case 'NOT_STARTED':
      primaryMessage = 'Waiting to start initialization...';
      break;
    case 'NOT_APPLICABLE':
      primaryMessage = 'Initialization not required';
      break;
    default:
      primaryMessage = 'Initialization: ${getStatusText(initStatus)}';
  }

  // Build detailed status for threat checks
  final List<String> threatChecks = [];

  if (systemStatus.isNotEmpty && systemStatus != 'NOT_APPLICABLE') {
    threatChecks.add('System Threat Checks: ${getStatusText(systemStatus)}');
  }

  if (appStatus.isNotEmpty && appStatus != 'NOT_APPLICABLE') {
    threatChecks.add('App Threat Checks: ${getStatusText(appStatus)}');
  }

  if (networkStatus.isNotEmpty && networkStatus != 'NOT_APPLICABLE') {
    threatChecks.add('Network Threat Checks: ${getStatusText(networkStatus)}');
  }

  // Combine primary message with threat check details
  if (threatChecks.isNotEmpty) {
    return '$primaryMessage\n${threatChecks.join(' • ')}';
  }

  return primaryMessage;
}
