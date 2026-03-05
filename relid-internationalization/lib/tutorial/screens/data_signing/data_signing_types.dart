// ============================================================================
// File: data_signing_types.dart
// Description: Data Signing Types and Models
//
// Comprehensive Dart type definitions for the Data Signing feature.
// Transformed from: React Native DataSigningTypes.ts
//
// Key Features:
// - Dropdown option models for auth level and authenticator type
// - Data signing request/response models
// - UI state models (form and password modal)
// - Result display models
// - Validation constants and error codes
// ============================================================================

// =============================================================================
// DROPDOWN MODELS
// =============================================================================

/// Dropdown option model for UI dropdowns
class DropdownOption {
  final String value;

  DropdownOption({required this.value});
}

/// Auth level dropdown data
class AuthLevelDropdownData {
  final List<DropdownOption> authLevelOptions;

  AuthLevelDropdownData({required this.authLevelOptions});
}

/// Authenticator type dropdown data
class AuthenticatorTypeDropdownData {
  final List<DropdownOption> authenticatorTypeOptions;

  AuthenticatorTypeDropdownData({required this.authenticatorTypeOptions});
}

// =============================================================================
// DATA SIGNING REQUEST/RESPONSE MODELS
// =============================================================================

/// Data signing request model
class DataSigningRequest {
  final String payload;
  final int authLevel;
  final int authenticatorType;
  final String reason;

  DataSigningRequest({
    required this.payload,
    required this.authLevel,
    required this.authenticatorType,
    required this.reason,
  });
}

/// Data signing response model (internal format with status and error)
class DataSigningResponse {
  final String? dataPayload;
  final int? dataPayloadLength;
  final String? reason;
  final String? payloadSignature;
  final String? dataSignatureID;
  final int? authLevel;
  final int? authenticationType;

  DataSigningResponse({
    this.dataPayload,
    this.dataPayloadLength,
    this.reason,
    this.payloadSignature,
    this.dataSignatureID,
    this.authLevel,
    this.authenticationType,
  });
}

// =============================================================================
// UI STATE MODELS
// =============================================================================

/// Data signing form state
class DataSigningFormState {
  final String payload;
  final String selectedAuthLevel;
  final String selectedAuthenticatorType;
  final String reason;
  final bool isLoading;

  DataSigningFormState({
    this.payload = '',
    this.selectedAuthLevel = '',
    this.selectedAuthenticatorType = '',
    this.reason = '',
    this.isLoading = false,
  });

  /// Creates a copy with updated fields
  DataSigningFormState copyWith({
    String? payload,
    String? selectedAuthLevel,
    String? selectedAuthenticatorType,
    String? reason,
    bool? isLoading,
  }) {
    return DataSigningFormState(
      payload: payload ?? this.payload,
      selectedAuthLevel: selectedAuthLevel ?? this.selectedAuthLevel,
      selectedAuthenticatorType: selectedAuthenticatorType ?? this.selectedAuthenticatorType,
      reason: reason ?? this.reason,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Password modal state for step-up authentication
class PasswordModalState {
  final bool isVisible;
  final String password;
  final int challengeMode;
  final int attemptsLeft;
  final String errorMessage;
  final bool isSubmitting;
  final DataSigningFormState? context; // Context information (payload, authLevel, etc.)

  PasswordModalState({
    this.isVisible = false,
    this.password = '',
    this.challengeMode = 0,
    this.attemptsLeft = 3,
    this.errorMessage = '',
    this.isSubmitting = false,
    this.context,
  });

  /// Creates a copy with updated fields
  PasswordModalState copyWith({
    bool? isVisible,
    String? password,
    int? challengeMode,
    int? attemptsLeft,
    String? errorMessage,
    bool? isSubmitting,
    DataSigningFormState? context,
  }) {
    return PasswordModalState(
      isVisible: isVisible ?? this.isVisible,
      password: password ?? this.password,
      challengeMode: challengeMode ?? this.challengeMode,
      attemptsLeft: attemptsLeft ?? this.attemptsLeft,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      context: context ?? this.context,
    );
  }

  /// Gets attempts color based on remaining attempts
  /// 1 attempt = red, 2 attempts = orange, 3+ = green
  int get attemptsColor {
    if (attemptsLeft == 1) return 0xFFDC2626; // Red
    if (attemptsLeft == 2) return 0xFFF59E0B; // Orange
    return 0xFF10B981; // Green
  }
}

// =============================================================================
// RESULT DISPLAY MODEL (excludes status and error)
// =============================================================================

/// Data signing result display model (for UI display only)
class DataSigningResultDisplay {
  final String authLevel;
  final String authenticationType;
  final String dataPayloadLength;
  final String dataPayload;
  final String payloadSignature;
  final String dataSignatureID;
  final String reason;

  DataSigningResultDisplay({
    required this.authLevel,
    required this.authenticationType,
    required this.dataPayloadLength,
    required this.dataPayload,
    required this.payloadSignature,
    required this.dataSignatureID,
    required this.reason,
  });
}

/// Result info item for results screen display
class ResultInfoItem {
  final String name;
  final String value;

  ResultInfoItem({
    required this.name,
    required this.value,
  });
}

// =============================================================================
// VALIDATION RESULT MODEL
// =============================================================================

/// Validation result model
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final String? error; // Single error message (for convenience)

  ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.error,
  });

  ValidationResult.valid() : isValid = true, errors = [], error = null;

  ValidationResult.invalid(String errorMessage)
      : isValid = false,
        errors = [errorMessage],
        error = errorMessage;

  ValidationResult.invalidMultiple(List<String> errorMessages)
      : isValid = false,
        errors = errorMessages,
        error = errorMessages.isNotEmpty ? errorMessages.first : null;
}

// =============================================================================
// CONSTANTS
// =============================================================================

/// Auth level dropdown options
const List<String> authLevelOptions = [
  "NONE (0)",
  "RDNA_AUTH_LEVEL_1 (1)",
  "RDNA_AUTH_LEVEL_2 (2)",
  "RDNA_AUTH_LEVEL_3 (3)",
  "RDNA_AUTH_LEVEL_4 (4)",
];

/// Authenticator type dropdown options
const List<String> authenticatorTypeOptions = [
  "NONE (0)",
  "RDNA_IDV_SERVER_BIOMETRIC (1)",
  "RDNA_AUTH_PASS (2)",
  "RDNA_AUTH_LDA (3)",
];

// =============================================================================
// VALIDATION CONSTANTS
// =============================================================================

/// Maximum payload length
const int maxPayloadLength = 500;

/// Maximum reason length
const int maxReasonLength = 100;

// =============================================================================
// ERROR CODES
// =============================================================================

/// Data signing error codes
class DataSigningErrorCodes {
  static const int success = 0;
  static const int authenticationNotSupported = 214;
  static const int authenticationFailed = 102;
  static const int userCancelled = 153;
  static const int networkError = 500;
}
