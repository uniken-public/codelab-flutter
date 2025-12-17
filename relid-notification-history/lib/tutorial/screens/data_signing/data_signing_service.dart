// ============================================================================
// File: data_signing_service.dart
// Description: Data Signing Service
//
// High-level service that orchestrates data signing operations.
// Combines RdnaService and DropdownDataService for complete functionality.
//
// Transformed from: React Native DataSigningService.ts
//
// Key Features:
// - Data signing orchestration (signData, submitPassword, resetState)
// - Dropdown value conversion
// - Input validation (signing input and password)
// - Result formatting for display
// - Error message mapping
// ============================================================================

import '../../../uniken/services/rdna_service.dart';
import 'dropdown_data_service.dart';
import 'data_signing_types.dart';
import 'package:rdna_client/rdna_struct.dart';
import 'package:rdna_client/rdna_client.dart';

/// High-level service for data signing operations
///
/// Provides a clean interface for UI components to interact with the
/// data signing functionality, combining low-level SDK calls with
/// business logic and validation.
class DataSigningService {
  // Private constructor to prevent instantiation
  DataSigningService._();

  /// Get RdnaService singleton instance
  static RdnaService get rdnaService => RdnaService.getInstance();

  // =============================================================================
  // DATA SIGNING OPERATIONS
  // =============================================================================

  /// Initiates data signing with proper numeric conversion
  ///
  /// This method initiates the data signing flow by calling the SDK's
  /// authenticateUserAndSignData API. The SDK will trigger getPassword
  /// for step-up authentication if required, and eventually trigger
  /// onAuthenticateUserAndSignData with the signed data.
  ///
  /// ## Parameters
  /// - [request]: Data signing request with numeric values
  ///
  /// ## Returns
  /// Future<RDNASyncResponse> with error field to check success/failure
  ///
  /// ## Events Triggered
  /// - `getPassword`: May trigger for step-up authentication
  /// - `onAuthenticateUserAndSignData`: Final signing response
  ///
  /// ## Example
  /// ```dart
  /// final request = DataSigningRequest(
  ///   payload: 'Transaction data',
  ///   authLevel: 4,
  ///   authenticatorType: 0,
  ///   reason: 'Approve transaction'
  /// );
  /// final response = await DataSigningService.signData(request);
  /// if (response.error?.longErrorCode == 0) {
  ///   // Success
  /// }
  /// ```
  static Future<RDNASyncResponse> signData(DataSigningRequest request) async {
    print('DataSigningService - Starting data signing process');

    final response = await rdnaService.authenticateUserAndSignData(
      request.payload,
      request.authLevel,
      request.authenticatorType,
      request.reason,
    );

    if (response.error?.longErrorCode == 0) {
      print('DataSigningService - Data signing initiated successfully');
    } else {
      print('DataSigningService - Data signing sync error: ${response.error?.errorString}');
    }

    return response;
  }

  /// Submits password for step-up authentication during data signing
  ///
  /// This method is called when the SDK triggers getPassword event
  /// during the data signing flow. It submits the user's password
  /// for verification.
  ///
  /// ## Parameters
  /// - [password]: User's password
  /// - [challengeMode]: Challenge mode from getPassword callback
  ///
  /// ## Returns
  /// Future<RDNASyncResponse> with error field to check success/failure
  ///
  /// ## Example
  /// ```dart
  /// final response = await DataSigningService.submitPassword('userPassword', 12);
  /// if (response.error?.longErrorCode == 0) {
  ///   // Success
  /// }
  /// ```
  static Future<RDNASyncResponse> submitPassword(String password, int challengeMode) async {
    print('DataSigningService - Submitting password for data signing (challengeMode: $challengeMode)');

    // Convert int challengeMode to RDNAChallengeOpMode enum
    // For data signing, we use RDNA_OP_STEP_UP_AUTH_AND_SIGN_DATA (index 12)
    final challengeModeEnum = RDNAChallengeOpMode.values[challengeMode];

    final response = await rdnaService.setPassword(password, challengeModeEnum);

    if (response.error?.longErrorCode == 0) {
      print('DataSigningService - Password submitted successfully');
    } else {
      print('DataSigningService - Password submission sync error: ${response.error?.errorString}');
    }

    return response;
  }

  /// Resets data signing state (cleanup)
  ///
  /// This method clears any cached authentication state from the
  /// data signing flow. Should be called after completing data signing
  /// or when cancelling the flow.
  ///
  /// ## Returns
  /// Future<RDNASyncResponse> with error field to check success/failure
  ///
  /// ## Example
  /// ```dart
  /// final response = await DataSigningService.resetState();
  /// if (response.error?.longErrorCode == 0) {
  ///   // Success
  /// }
  /// ```
  static Future<RDNASyncResponse> resetState() async {
    print('DataSigningService - Resetting data signing state');

    final response = await rdnaService.resetAuthenticateUserAndSignDataState();

    if (response.error?.longErrorCode == 0) {
      print('DataSigningService - State reset successfully');
    } else {
      print('DataSigningService - State reset sync error: ${response.error?.errorString}');
    }

    return response;
  }

  // =============================================================================
  // DROPDOWN CONVERSION
  // =============================================================================

  /// Convert dropdown display values to SDK numeric values for API call
  ///
  /// ## Parameters
  /// - [authLevelDisplay]: Display value from auth level dropdown
  /// - [authenticatorTypeDisplay]: Display value from authenticator type dropdown
  ///
  /// ## Returns
  /// Map with numeric authLevel and authenticatorType values
  ///
  /// ## Example
  /// ```dart
  /// final values = DataSigningService.convertDropdownToInts(
  ///   "RDNA_AUTH_LEVEL_4 (4)",
  ///   "RDNA_AUTH_PASS (2)"
  /// );
  /// // Returns: {authLevel: 4, authenticatorType: 2}
  /// ```
  static Map<String, int> convertDropdownToInts(
    String authLevelDisplay,
    String authenticatorTypeDisplay,
  ) {
    return {
      'authLevel': DropdownDataService.convertAuthLevelToInt(authLevelDisplay),
      'authenticatorType': DropdownDataService.convertAuthenticatorTypeToInt(authenticatorTypeDisplay),
    };
  }

  // =============================================================================
  // VALIDATION
  // =============================================================================

  /// Validates form input before submission
  ///
  /// Validates all required fields for data signing: payload, auth level,
  /// authenticator type, and reason.
  ///
  /// ## Parameters
  /// - [payload]: Data payload to validate
  /// - [authLevel]: Selected auth level display string
  /// - [authenticatorType]: Selected authenticator type display string
  /// - [reason]: Signing reason
  ///
  /// ## Returns
  /// ValidationResult with isValid flag and list of errors
  ///
  /// ## Example
  /// ```dart
  /// final result = DataSigningService.validateSigningInput(
  ///   payload: 'data',
  ///   authLevel: 'RDNA_AUTH_LEVEL_4 (4)',
  ///   authenticatorType: 'RDNA_AUTH_PASS (2)',
  ///   reason: 'Test'
  /// );
  /// if (!result.isValid) {
  ///   print('Errors: ${result.errors}');
  /// }
  /// ```
  static ValidationResult validateSigningInput({
    required String payload,
    required String authLevel,
    required String authenticatorType,
    required String reason,
  }) {
    final List<String> errors = [];

    // Validate payload
    if (payload.trim().isEmpty) {
      errors.add('Payload is required');
    } else if (payload.length > maxPayloadLength) {
      errors.add('Payload must be less than $maxPayloadLength characters');
    }

    // Validate auth level
    if (authLevel.isEmpty || !DropdownDataService.isValidAuthLevel(authLevel)) {
      errors.add('Please select a valid authentication level');
    }

    // Validate authenticator type
    if (authenticatorType.isEmpty || !DropdownDataService.isValidAuthenticatorType(authenticatorType)) {
      errors.add('Please select a valid authenticator type');
    }

    // Validate reason
    if (reason.trim().isEmpty) {
      errors.add('Reason is required');
    } else if (reason.length > maxReasonLength) {
      errors.add('Reason must be less than $maxReasonLength characters');
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalidMultiple(errors);
  }

  /// Validates password input
  ///
  /// Simple validation to ensure password is not empty.
  ///
  /// ## Parameters
  /// - [password]: Password to validate
  ///
  /// ## Returns
  /// ValidationResult with isValid flag and error message if invalid
  ///
  /// ## Example
  /// ```dart
  /// final result = DataSigningService.validatePassword('');
  /// if (!result.isValid) {
  ///   print('Error: ${result.error}');
  /// }
  /// ```
  static ValidationResult validatePassword(String password) {
    if (password.trim().isEmpty) {
      return ValidationResult.invalid('Password is required');
    }

    return ValidationResult.valid();
  }

  // =============================================================================
  // RESULT FORMATTING
  // =============================================================================

  /// Converts raw data signing response to display format
  ///
  /// Excludes status and error fields as per requirements.
  /// Converts all numeric values to strings for display.
  ///
  /// ## Parameters
  /// - [response]: Raw response from onAuthenticateUserAndSignData event
  ///
  /// ## Returns
  /// Formatted data for UI display (DataSigningResultDisplay)
  ///
  /// ## Example
  /// ```dart
  /// final displayData = DataSigningService.formatSigningResultForDisplay(response);
  /// ```
  static DataSigningResultDisplay formatSigningResultForDisplay(
    AuthenticateUserAndSignData response,
  ) {
    return DataSigningResultDisplay(
      authLevel: response.authLevel?.toString() ?? 'N/A',
      authenticationType: response.authenticationType?.toString() ?? 'N/A',
      dataPayloadLength: response.dataPayloadLength?.toString() ?? 'N/A',
      dataPayload: response.dataPayload ?? 'N/A',
      payloadSignature: response.payloadSignature ?? 'N/A',
      dataSignatureID: response.dataSignatureID ?? 'N/A',
      reason: response.reason ?? 'N/A',
    );
  }

  /// Converts display format to info items for results screen
  ///
  /// Creates a list of name-value pairs for rendering in the results UI.
  /// Order matches the priority of information (signature first).
  ///
  /// ## Parameters
  /// - [displayData]: Formatted display data
  ///
  /// ## Returns
  /// List of ResultInfoItem for UI rendering
  ///
  /// ## Example
  /// ```dart
  /// final items = DataSigningService.convertToResultInfoItems(displayData);
  /// for (var item in items) {
  ///   print('${item.name}: ${item.value}');
  /// }
  /// ```
  static List<ResultInfoItem> convertToResultInfoItems(
    DataSigningResultDisplay displayData,
  ) {
    return [
      ResultInfoItem(name: 'Payload Signature', value: displayData.payloadSignature),
      ResultInfoItem(name: 'Data Signature ID', value: displayData.dataSignatureID),
      ResultInfoItem(name: 'Reason', value: displayData.reason),
      ResultInfoItem(name: 'Data Payload', value: displayData.dataPayload),
      ResultInfoItem(name: 'Auth Level', value: displayData.authLevel),
      ResultInfoItem(name: 'Authentication Type', value: displayData.authenticationType),
      ResultInfoItem(name: 'Data Payload Length', value: displayData.dataPayloadLength),
    ];
  }

  // =============================================================================
  // ERROR HANDLING
  // =============================================================================

  /// Gets user-friendly error message for error codes
  ///
  /// Maps SDK error codes to human-readable messages for display.
  ///
  /// ## Parameters
  /// - [errorCode]: Error code from SDK
  ///
  /// ## Returns
  /// Human-readable error message
  ///
  /// ## Example
  /// ```dart
  /// final message = DataSigningService.getErrorMessage(214);
  /// // Returns: "Authentication method not supported..."
  /// ```
  static String getErrorMessage(int errorCode) {
    switch (errorCode) {
      case DataSigningErrorCodes.success:
        return 'Success';
      case DataSigningErrorCodes.authenticationNotSupported:
        return 'Authentication method not supported. Please try a different authentication type.';
      case DataSigningErrorCodes.authenticationFailed:
        return 'Authentication failed. Please check your credentials and try again.';
      case DataSigningErrorCodes.userCancelled:
        return 'Operation cancelled by user.';
      default:
        return 'Operation failed with error code: $errorCode';
    }
  }
}
