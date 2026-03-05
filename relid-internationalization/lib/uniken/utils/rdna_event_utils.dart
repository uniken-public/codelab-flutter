// ============================================================================
// File: rdna_event_utils.dart
// Description: REL-ID Event Utilities
//
// Transformed from: rdnaEvents.ts - RDNAEventUtils
// Provides helper methods for checking errors and extracting messages from SDK events
// ============================================================================

import 'package:rdna_client/rdna_struct.dart';

/// REL-ID Event Utilities
///
/// Helper methods for error checking and message extraction from SDK events
class RDNAEventUtils {
  /// Check if an RDNA event has API-level errors
  ///
  /// ## Parameters
  /// - [error]: Error object from SDK event
  ///
  /// ## Returns
  /// true if has API errors (longErrorCode != 0), false otherwise
  static bool hasApiError(RDNAError? error) {
    return error != null && error.longErrorCode != null && error.longErrorCode != 0;
  }

  /// Check if an RDNA event has status-level errors
  ///
  /// ## Parameters
  /// - [status]: Status object from challengeResponse
  ///
  /// ## Returns
  /// true if has status errors (statusCode != 100), false otherwise
  ///
  /// ## Status Codes
  /// - 100: Success
  /// - 101: User not found / validation failed
  /// - 106: Invalid activation code
  /// - 153: Attempts exhausted
  /// - etc.
  static bool hasStatusError(RDNARequestStatus? status) {
    return status != null && status.statusCode != null && status.statusCode != 100;
  }

  /// Get the primary error message from an RDNA event
  ///
  /// Checks both API-level errors and status-level errors,
  /// returning the most relevant error message.
  ///
  /// ## Parameters
  /// - [error]: Error object from SDK event
  /// - [status]: Status object from challengeResponse
  ///
  /// ## Returns
  /// The most relevant error message
  static String getErrorMessage(RDNAError? error, RDNARequestStatus? status) {
    // API errors take precedence
    if (hasApiError(error)) {
      return error!.errorString ?? 'Unknown API error occurred';
    }

    // Status errors
    if (hasStatusError(status)) {
      return status!.statusMessage ?? 'Operation failed with status ${status.statusCode}';
    }

    return 'Unknown error occurred';
  }

  /// Check if challengeInfo contains a specific key
  ///
  /// ## Parameters
  /// - [challengeInfo]: List of challenge info key-value pairs
  /// - [key]: The key to search for
  ///
  /// ## Returns
  /// true if key exists, false otherwise
  static bool hasChallengeKey(List<RDNAChallengeInfo>? challengeInfo, String key) {
    if (challengeInfo == null) return false;

    return challengeInfo.any((item) => item.key == key);
  }

  /// Get a challenge value from challengeInfo by key
  ///
  /// ## Parameters
  /// - [challengeInfo]: List of challenge info key-value pairs
  /// - [key]: The key to search for
  ///
  /// ## Returns
  /// The value for the given key, or null if not found
  static String? getChallengeValue(List<RDNAChallengeInfo>? challengeInfo, String key) {
    if (challengeInfo == null) return null;

    try {
      final item = challengeInfo.firstWhere((item) => item.key == key);
      return item.value;
    } catch (e) {
      return null;
    }
  }
}
