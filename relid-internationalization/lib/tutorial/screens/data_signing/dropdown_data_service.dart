// ============================================================================
// File: dropdown_data_service.dart
// Description: Dropdown Data Service
//
// Handles dropdown data and numeric conversion for Data Signing feature.
// Provides a clean interface for UI components to work with SDK numeric values.
//
// Transformed from: React Native DropdownDataService.ts
//
// Key Features:
// - Auth level and authenticator type dropdown options
// - Display string to numeric value conversion
// - Numeric value to display string conversion
// - Validation of dropdown selections
// ============================================================================

import 'data_signing_types.dart';

/// Service class for managing dropdown data and numeric conversions
///
/// Provides a clean interface for UI components to work with SDK numeric values.
/// All methods are static for easy access without instantiation.
class DropdownDataService {
  // Private constructor to prevent instantiation
  DropdownDataService._();

  // =============================================================================
  // DROPDOWN OPTIONS
  // =============================================================================

  /// Get all available authentication level options for dropdown
  ///
  /// ## Returns
  /// List of auth level display strings
  ///
  /// ## Example
  /// ```dart
  /// final options = DropdownDataService.getAuthLevelOptions();
  /// // Returns: ["NONE (0)", "RDNA_AUTH_LEVEL_1 (1)", ...]
  /// ```
  static List<String> getAuthLevelOptions() {
    return authLevelOptions;
  }

  /// Get all available authenticator type options for dropdown
  ///
  /// ## Returns
  /// List of authenticator type display strings
  ///
  /// ## Example
  /// ```dart
  /// final options = DropdownDataService.getAuthenticatorTypeOptions();
  /// // Returns: ["NONE (0)", "RDNA_IDV_SERVER_BIOMETRIC (1)", ...]
  /// ```
  static List<String> getAuthenticatorTypeOptions() {
    return authenticatorTypeOptions;
  }

  // =============================================================================
  // CONVERSION: DISPLAY STRING → NUMERIC VALUE
  // =============================================================================

  /// Convert human-readable auth level string to SDK numeric value
  ///
  /// Maps dropdown display values to numeric constants used by the SDK.
  ///
  /// ## Parameters
  /// - [displayValue]: The string value from dropdown (e.g., "RDNA_AUTH_LEVEL_4 (4)")
  ///
  /// ## Returns
  /// Corresponding numeric value (0-4)
  ///
  /// ## Example
  /// ```dart
  /// final authLevel = DropdownDataService.convertAuthLevelToInt("RDNA_AUTH_LEVEL_4 (4)");
  /// // Returns: 4
  /// ```
  static int convertAuthLevelToInt(String displayValue) {
    switch (displayValue) {
      case "NONE (0)":
        return 0;
      case "RDNA_AUTH_LEVEL_1 (1)":
        return 1;
      case "RDNA_AUTH_LEVEL_2 (2)":
        return 2;
      case "RDNA_AUTH_LEVEL_3 (3)":
        return 3;
      case "RDNA_AUTH_LEVEL_4 (4)":
        return 4;
      default:
        print('DropdownDataService - Unknown auth level: $displayValue, defaulting to 0');
        return 0;
    }
  }

  /// Convert human-readable authenticator type string to SDK numeric value
  ///
  /// Maps dropdown display values to numeric constants used by the SDK.
  ///
  /// ## Parameters
  /// - [displayValue]: The string value from dropdown (e.g., "RDNA_IDV_SERVER_BIOMETRIC (1)")
  ///
  /// ## Returns
  /// Corresponding numeric value (0-3)
  ///
  /// ## Example
  /// ```dart
  /// final authType = DropdownDataService.convertAuthenticatorTypeToInt("RDNA_AUTH_PASS (2)");
  /// // Returns: 2
  /// ```
  static int convertAuthenticatorTypeToInt(String displayValue) {
    switch (displayValue) {
      case "NONE (0)":
        return 0;
      case "RDNA_IDV_SERVER_BIOMETRIC (1)":
        return 1;
      case "RDNA_AUTH_PASS (2)":
        return 2;
      case "RDNA_AUTH_LDA (3)":
        return 3;
      default:
        print('DropdownDataService - Unknown authenticator type: $displayValue, defaulting to 0');
        return 0;
    }
  }

  // =============================================================================
  // CONVERSION: NUMERIC VALUE → DISPLAY STRING
  // =============================================================================

  /// Convert numeric auth level value back to display string (for reverse lookup)
  ///
  /// Useful for displaying current selections or debugging.
  ///
  /// ## Parameters
  /// - [numericValue]: Numeric auth level (0-4)
  ///
  /// ## Returns
  /// Human-readable string for display
  ///
  /// ## Example
  /// ```dart
  /// final display = DropdownDataService.convertAuthLevelIntToDisplay(4);
  /// // Returns: "RDNA_AUTH_LEVEL_4 (4)"
  /// ```
  static String convertAuthLevelIntToDisplay(int numericValue) {
    switch (numericValue) {
      case 0:
        return "NONE (0)";
      case 1:
        return "RDNA_AUTH_LEVEL_1 (1)";
      case 2:
        return "RDNA_AUTH_LEVEL_2 (2)";
      case 3:
        return "RDNA_AUTH_LEVEL_3 (3)";
      case 4:
        return "RDNA_AUTH_LEVEL_4 (4)";
      default:
        return "NONE (0)";
    }
  }

  /// Convert numeric authenticator type value back to display string (for reverse lookup)
  ///
  /// Useful for displaying current selections or debugging.
  ///
  /// ## Parameters
  /// - [numericValue]: Numeric authenticator type (0-3)
  ///
  /// ## Returns
  /// Human-readable string for display
  ///
  /// ## Example
  /// ```dart
  /// final display = DropdownDataService.convertAuthenticatorTypeIntToDisplay(1);
  /// // Returns: "RDNA_IDV_SERVER_BIOMETRIC (1)"
  /// ```
  static String convertAuthenticatorTypeIntToDisplay(int numericValue) {
    switch (numericValue) {
      case 0:
        return "NONE (0)";
      case 1:
        return "RDNA_IDV_SERVER_BIOMETRIC (1)";
      case 2:
        return "RDNA_AUTH_PASS (2)";
      case 3:
        return "RDNA_AUTH_LDA (3)";
      default:
        return "NONE (0)";
    }
  }

  // =============================================================================
  // VALIDATION
  // =============================================================================

  /// Validate if a display value is a valid auth level option
  ///
  /// ## Parameters
  /// - [displayValue]: String to validate
  ///
  /// ## Returns
  /// true if valid, false otherwise
  ///
  /// ## Example
  /// ```dart
  /// final isValid = DropdownDataService.isValidAuthLevel("RDNA_AUTH_LEVEL_4 (4)");
  /// // Returns: true
  /// ```
  static bool isValidAuthLevel(String displayValue) {
    return authLevelOptions.contains(displayValue);
  }

  /// Validate if a display value is a valid authenticator type option
  ///
  /// ## Parameters
  /// - [displayValue]: String to validate
  ///
  /// ## Returns
  /// true if valid, false otherwise
  ///
  /// ## Example
  /// ```dart
  /// final isValid = DropdownDataService.isValidAuthenticatorType("RDNA_AUTH_PASS (2)");
  /// // Returns: true
  /// ```
  static bool isValidAuthenticatorType(String displayValue) {
    return authenticatorTypeOptions.contains(displayValue);
  }
}
