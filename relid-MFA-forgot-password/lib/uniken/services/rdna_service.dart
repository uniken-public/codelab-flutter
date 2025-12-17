// ============================================================================
// File: rdna_service.dart
// Description: REL-ID SDK Service
//
// Main service class for interacting with the REL-ID SDK.
// Provides methods for SDK initialization and version retrieval.
// ============================================================================

import 'dart:convert';
import 'package:rdna_client/rdna_client.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../utils/connection_profile_parser.dart';
import 'rdna_event_manager.dart';

/// REL-ID SDK Service
///
/// Main service class for REL-ID SDK operations. Provides a singleton instance
/// for SDK initialization, threat management, and version retrieval.
///
/// ## Key Features
/// - Singleton pattern for consistent SDK access
/// - Integration with RdnaEventManager for event handling
/// - Connection profile loading and parsing
/// - SDK version retrieval
/// - Initialization with connection profile
/// - Mobile Threat Detection (MTD) - takeActionOnThreats API
/// - Multifactor Authentication (MFA) - setUser, setPassword, setActivationCode, setUserConsentForLDA APIs
/// - Authentication Management - resetAuthState, logOff, forgotPassword APIs
/// - Session Management - extendSessionIdleTimeout API
/// - Additional Device Activation - performVerifyAuth, fallbackNewDeviceActivationFlow APIs
/// - Notification Management - getNotifications, updateNotification APIs
class RdnaService {
  static RdnaService? _instance;
  final RdnaClient _rdnaClient;
  final RdnaEventManager _eventManager;

  RdnaService._(this._rdnaClient, this._eventManager);

  /// Gets the singleton instance of RdnaService
  static RdnaService getInstance() {
    if (_instance == null) {
      final rdnaClient = RdnaClient();
      final eventManager = RdnaEventManager.getInstance(rdnaClient);
      _instance = RdnaService._(rdnaClient, eventManager);
    }
    return _instance!;
  }

  /// Cleans up the service and event manager
  void cleanup() {
    print('RdnaService - Cleaning up service');
    _eventManager.cleanup();
  }

  /// Gets the event manager instance for external callback setup
  RdnaEventManager getEventManager() {
    return _eventManager;
  }

  /// Gets the version of the REL-ID SDK
  ///
  /// ## Returns
  /// Future that resolves with the SDK version string
  ///
  /// ## Notes
  /// - Returns the version string from response.response
  /// - Returns 'Unknown' if response is empty
  /// - Throws if there's a network or runtime error
  ///
  /// ## Example
  /// ```dart
  /// try {
  ///   final version = await rdnaService.getSDKVersion();
  ///   print('SDK Version: $version');
  /// } catch (e) {
  ///   print('Failed to get SDK version: $e');
  /// }
  /// ```
  Future<String> getSDKVersion() async {
    print('RdnaService - Requesting SDK version');

    // ✅ Call plugin without redundant try-catch
    final response = await _rdnaClient.getSDKVersion();

    // ✅ Return version directly - caller handles errors
    final version = response.response ?? 'Unknown';
    print('RdnaService - SDK Version: $version');
    return version;
  }

  /// Initializes the REL-ID SDK
  ///
  /// Loads the connection profile from assets, extracts connection details,
  /// and initializes the SDK with the required parameters.
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (may have error or success)
  ///
  /// ## Events Triggered
  /// - `onInitializeProgress`: Progress updates during initialization
  /// - `onInitialized`: Successful initialization with session data
  /// - `onInitializeError`: Initialization error with error details
  ///
  /// ## Notes
  /// - Check response.error?.longErrorCode to determine sync success
  /// - Async events (onInitialized, onInitializeError) fire regardless
  /// - Throws only on actual runtime errors (network, parsing, etc)
  ///
  /// ## Example
  /// ```dart
  /// final syncResponse = await rdnaService.initialize();
  ///
  /// if (syncResponse.error?.longErrorCode == 0) {
  ///   print('Sync success, waiting for async events');
  /// } else {
  ///   print('Sync error: ${syncResponse.error?.errorString}');
  /// }
  /// ```
  Future<RDNASyncResponse> initialize() async {
    final profile = await loadAgentInfo();
    print('RdnaService - Loaded connection profile:');
    print('  Host: ${profile.host}');
    print('  Port: ${profile.port}');
    print('  RelId: ${profile.relId.substring(0, 10)}...');

    print('RdnaService - Starting initialization');

    // ✅ Call plugin without redundant try-catch
    final response = await _rdnaClient.initialize(
      profile.relId, // agentInfo: The REL-ID encrypted string, part of connection profile
      profile.host, // gatewayHost: Hostname or IP of the gateway server
      profile.port, // gatewayPort: Port number for gateway server communication
      '', // cipherSpecs: Encryption format string (e.g., "AES/256/CFB/NoPadding:SHA-256")
      '', // cipherSalt: Cryptographic salt for additional security (recommended: package name)
      null, // proxySettings: Proxy configuration (optional)
      null, // rdnaSSLCertificate: SSL certificate configuration (optional)
      RDNALoggingLevel.RDNA_NO_LOGS, // logLevel: Logging level (use RDNA_NO_LOGS in production)
    );

    print('RdnaService - Initialize sync response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    // ✅ Return response directly - caller decides what to do
    return response;
  }

  /// Takes action on detected security threats
  ///
  /// Sends the user's threat action decision (proceed or exit) back to the SDK.
  /// The SDK will process the decision and may trigger additional events based
  /// on the user's choice.
  ///
  /// ## Parameters
  /// - [threatList]: List of threat objects with user decisions set
  ///   - Each threat should have `shouldProceedWithThreats` set (true/false)
  ///   - Each threat should have `rememberActionForSession` set (typically true)
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (may have error or success)
  ///
  /// ## Events Triggered
  /// - If user chose to exit (shouldProceedWithThreats = false):
  ///   - `onTerminateWithThreats`: Triggered after sync response
  /// - If user chose to proceed (shouldProceedWithThreats = true):
  ///   - SDK continues initialization flow normally
  ///
  /// ## Notes
  /// - Check response.error?.longErrorCode to determine sync success
  /// - Convert threat reasons from List to comma-separated string if needed
  /// - Throws only on actual runtime errors (network, parsing, etc)
  ///
  /// ## Example
  /// ```dart
  /// // User chose to proceed despite threats
  /// final modifiedThreats = threats.map((threat) => RDNAThreat(
  ///   ...threat,
  ///   shouldProceedWithThreats: true,
  ///   rememberActionForSession: true,
  /// )).toList();
  ///
  /// final response = await rdnaService.takeActionOnThreats(modifiedThreats);
  /// if (response.error?.longErrorCode == 0) {
  ///   print('Action taken successfully');
  /// }
  /// ```
  Future<RDNASyncResponse> takeActionOnThreats(List<RDNAThreat> threatList) async {
    print('RdnaService - Taking action on ${threatList.length} threats');

    // ✅ Call plugin without redundant try-catch
    final response = await _rdnaClient.takeActionOnThreats(threatList);

    print('RdnaService - Take action on threats response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    // ✅ Return response directly - caller decides what to do
    return response;
  }

  /// Sets user for MFA User Activation Flow
  ///
  /// Submits the username for user validation during the MFA flow.
  /// Validates the user identity and prepares for subsequent authentication steps.
  ///
  /// ## Parameters
  /// - [username]: The username to validate
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (may have error or success)
  ///
  /// ## Events Triggered
  /// - `getUser`: May be re-triggered if validation fails (cyclical flow)
  /// - `getActivationCode`: If activation code is required
  /// - `getPassword`: If password input is required
  /// - `getUserConsentForLDA`: If LDA consent is required
  ///
  /// ## Response Validation Logic
  /// 1. Check error.longErrorCode: 0 = success, > 0 = error
  /// 2. Async events will be handled by event listeners for getUser, etc.
  ///
  /// ## Example
  /// ```dart
  /// final response = await rdnaService.setUser('john.doe');
  /// if (response.error?.longErrorCode == 0) {
  ///   print('SetUser sync success, waiting for async events');
  /// }
  /// ```
  Future<RDNASyncResponse> setUser(String username) async {
    print('RdnaService - Setting user for MFA flow: $username');

    final response = await _rdnaClient.setUser(username);

    print('RdnaService - SetUser sync response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    return response;
  }

  /// Sets activation code for MFA User Activation Flow
  ///
  /// Submits the activation code for user validation during the MFA flow.
  /// Processes the OTP/activation code and validates the user identity.
  ///
  /// ## Parameters
  /// - [activationCode]: The activation code to validate
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (may have error or success)
  ///
  /// ## Events Triggered
  /// - `getActivationCode`: May be re-triggered if validation fails
  /// - `getPassword`: If password input is required after successful validation
  /// - `getUserConsentForLDA`: If LDA consent is required
  ///
  /// ## Response Validation Logic
  /// 1. Check error.longErrorCode: 0 = success, > 0 = error
  /// 2. Async events will be handled by event listeners for getActivationCode, etc.
  ///
  /// ## Example
  /// ```dart
  /// final response = await rdnaService.setActivationCode('123456');
  /// if (response.error?.longErrorCode == 0) {
  ///   print('SetActivationCode sync success, waiting for async events');
  /// }
  /// ```
  Future<RDNASyncResponse> setActivationCode(String activationCode) async {
    print('RdnaService - Setting activation code for MFA flow: $activationCode');

    final response = await _rdnaClient.setActivationCode(activationCode);

    print('RdnaService - SetActivationCode sync response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    return response;
  }

  /// Sets user consent for LDA (Local Device Authentication)
  ///
  /// Submits the user's consent for LDA enrollment during authentication flows.
  /// Processes the user's decision and the authentication parameters from getUserConsentForLDA event.
  ///
  /// ## Parameters
  /// - [isEnrollLDA]: User consent decision (true = approve, false = reject)
  /// - [challengeMode]: Challenge mode from getUserConsentForLDA event
  /// - [authenticationType]: Authentication type from getUserConsentForLDA event
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (may have error or success)
  ///
  /// ## Events Triggered
  /// - Subsequent authentication steps based on user consent
  /// - `getPassword`: If password input is required after consent
  /// - `onUserLoggedIn`: If authentication completes successfully
  ///
  /// ## Response Validation Logic
  /// 1. Check error.longErrorCode: 0 = success, > 0 = error
  /// 2. Async events will be handled by event listeners for subsequent authentication steps
  ///
  /// ## Example
  /// ```dart
  /// final response = await rdnaService.setUserConsentForLDA(true, 1, 2);
  /// if (response.error?.longErrorCode == 0) {
  ///   print('SetUserConsentForLDA sync success, waiting for async events');
  /// }
  /// ```
  Future<RDNASyncResponse> setUserConsentForLDA(
      bool isEnrollLDA, int challengeMode, int authenticationType) async {
    print('RdnaService - Setting user consent for LDA:');
    print('  isEnrollLDA: $isEnrollLDA');
    print('  challengeMode: $challengeMode');
    print('  authenticationType: $authenticationType');

    final response = await _rdnaClient.setUserConsentForLDA(
        isEnrollLDA, challengeMode, authenticationType);

    print('RdnaService - SetUserConsentForLDA sync response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    return response;
  }

  /// Resends activation code for MFA User Activation Flow
  ///
  /// Requests a new activation code (OTP) to be sent to the user via email or SMS.
  /// Used when the user hasn't received their original activation code and needs a resend.
  /// Calling this method triggers a new getActivationCode event with updated information.
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (may have error or success)
  ///
  /// ## Events Triggered
  /// - `getActivationCode`: New event will be triggered with fresh OTP information
  ///
  /// ## Response Validation Logic
  /// 1. Check error.longErrorCode: 0 = success, > 0 = error
  /// 2. A new getActivationCode event will be triggered with fresh OTP information
  /// 3. Async events will be handled by event listeners for getActivationCode, etc.
  ///
  /// ## Example
  /// ```dart
  /// final response = await rdnaService.resendActivationCode();
  /// if (response.error?.longErrorCode == 0) {
  ///   print('ResendActivationCode sync success, waiting for new getActivationCode event');
  /// }
  /// ```
  Future<RDNASyncResponse> resendActivationCode() async {
    print('RdnaService - Requesting resend of activation code');

    final response = await _rdnaClient.resendActivationCode();

    print('RdnaService - ResendActivationCode sync response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    return response;
  }

  /// Sets password for MFA User Authentication Flow
  ///
  /// Submits the user's password for authentication during the MFA flow.
  /// Processes the password and validates it against the challenge requirements.
  ///
  /// ## Parameters
  /// - [password]: The password to validate
  /// - [challengeMode]: Challenge mode from getPassword event
  ///   - 0: Verify existing password (login)
  ///   - 1: Set new password (registration)
  ///   - 2: Update password (user-initiated)
  ///   - 3: Step-up authentication (notification action)
  ///   - 4: Update expired password
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (may have error or success)
  ///
  /// ## Events Triggered
  /// - `getPassword`: May be re-triggered if validation fails
  /// - `onUserLoggedIn`: If authentication completes successfully
  /// - `getUserConsentForLDA`: If LDA consent is required
  ///
  /// ## Response Validation Logic
  /// 1. Check error.longErrorCode: 0 = success, > 0 = error
  /// 2. Async events will be handled by event listeners for subsequent authentication steps
  ///
  /// ## Example
  /// ```dart
  /// final response = await rdnaService.setPassword('mySecurePassword', RDNAChallengeOpMode.RDNA_OP_SET_PWD);
  /// if (response.error?.longErrorCode == 0) {
  ///   print('SetPassword sync success, waiting for async events');
  /// }
  /// ```
  Future<RDNASyncResponse> setPassword(
      String password, RDNAChallengeOpMode challengeMode) async {
    print('RdnaService - Setting password for MFA flow (challengeMode: $challengeMode)');

    final response = await _rdnaClient.setPassword(password, challengeMode);

    print('RdnaService - SetPassword sync response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    return response;
  }

  /// Resets authentication state and returns to initial flow
  ///
  /// Resets the current authentication flow and clears any stored state.
  /// After successful reset, the SDK will trigger a new getUser event to restart the flow.
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (may have error or success)
  ///
  /// ## Events Triggered
  /// - `getUser`: New event will be triggered to restart the authentication flow
  ///
  /// ## Response Validation Logic
  /// 1. Check error.longErrorCode: 0 = success, > 0 = error
  /// 2. A new getUser event will be triggered to restart the authentication flow
  /// 3. Async events will be handled by event listeners
  ///
  /// ## Example
  /// ```dart
  /// final response = await rdnaService.resetAuthState();
  /// if (response.error?.longErrorCode == 0) {
  ///   print('ResetAuthState sync success, waiting for new getUser event');
  /// }
  /// ```
  Future<RDNASyncResponse> resetAuthState() async {
    print('RdnaService - Resetting authentication state');

    final response = await _rdnaClient.resetAuthState();

    print('RdnaService - ResetAuthState sync response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    return response;
  }

  /// Initiates forgot password flow for password reset
  ///
  /// Initiates the forgot password flow when challengeMode == 0 and ENABLE_FORGOT_PASSWORD is true.
  /// Triggers a verification challenge followed by password reset process.
  /// Can only be used on an active device and requires user verification.
  ///
  /// ## Parameters
  /// - [userId]: Optional user ID for the forgot password flow (platform-specific)
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (may have error or success)
  ///
  /// ## Events Triggered
  /// - `getActivationCode`: Verification challenge (e.g., OTP, email code)
  /// - `getPassword`: New password input after verification
  /// - `getUserConsentForLDA`: LDA consent if configured
  /// - `onUserLoggedIn`: Automatic login after successful password reset
  ///
  /// ## Workflow
  /// 1. User initiates forgot password
  /// 2. SDK triggers verification challenge (e.g., activation code, email OTP)
  /// 3. User completes challenge
  /// 4. SDK validates challenge
  /// 5. User sets new password
  /// 6. SDK logs user in automatically
  ///
  /// ## Response Validation Logic
  /// 1. Check error.longErrorCode: 0 = success, > 0 = error
  /// 2. Success typically navigates to home screen
  /// 3. Error Code 170 = Feature not supported
  /// 4. Async events will be handled by event listeners
  ///
  /// ## Example
  /// ```dart
  /// final response = await rdnaService.forgotPassword('john.doe');
  /// if (response.error?.longErrorCode == 0) {
  ///   print('ForgotPassword sync success, starting verification challenge');
  /// } else if (response.error?.longErrorCode == 170) {
  ///   print('Forgot password feature not supported');
  /// }
  /// ```
  Future<RDNASyncResponse> forgotPassword([String? userId]) async {
    print('RdnaService - Initiating forgot password flow for userId: ${userId ?? "current user"}');

    final response = await _rdnaClient.forgotPassword(userId);

    print('RdnaService - ForgotPassword sync response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    return response;
  }

  /// Logs off the user and terminates their authenticated session
  ///
  /// Securely terminates the user's authenticated session.
  /// After successful logoff, the SDK will trigger an onUserLoggedOff event followed by getUser event.
  ///
  /// ## Parameters
  /// - [userID]: The unique user identifier for the user to log off
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (may have error or success)
  ///
  /// ## Events Triggered
  /// - `onUserLoggedOff`: Triggered to confirm successful logout
  /// - `getUser`: Triggered to restart the authentication flow
  ///
  /// ## Response Validation Logic
  /// 1. Check error.longErrorCode: 0 = success, > 0 = error
  /// 2. An onUserLoggedOff event will be triggered to confirm successful logout
  /// 3. A getUser event will be triggered to restart the authentication flow
  /// 4. Async events will be handled by event listeners
  ///
  /// ## Example
  /// ```dart
  /// final response = await rdnaService.logOff('john.doe');
  /// if (response.error?.longErrorCode == 0) {
  ///   print('LogOff sync success, waiting for onUserLoggedOff event');
  /// }
  /// ```
  Future<RDNASyncResponse> logOff(String userID) async {
    print('RdnaService - Logging off user: $userID');

    final response = await _rdnaClient.logOff(userID);

    print('RdnaService - LogOff sync response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    return response;
  }

  /// Extends the idle session timeout
  ///
  /// Extends the current idle session timeout when the session is eligible for extension.
  /// Should be called in response to onSessionTimeOutNotification events when sessionCanBeExtended = 1.
  /// After calling this method, the SDK will trigger an onSessionExtensionResponse event with the result.
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (check error.longErrorCode for immediate feedback)
  ///
  /// ## Events Triggered
  /// - `onSessionExtensionResponse`: Triggered after API call (may be used for additional handling)
  ///
  /// ## Response Validation Logic
  /// 1. Check error.longErrorCode: 0 = success, > 0 = error
  /// 2. Async event may fire but can be ignored (sync response is sufficient)
  ///
  /// ## Example
  /// ```dart
  /// final response = await rdnaService.extendSessionIdleTimeout();
  /// if (response.error?.longErrorCode == 0) {
  ///   print('Extension successful');
  /// }
  /// ```
  Future<RDNASyncResponse> extendSessionIdleTimeout() async {
    print('RdnaService - Extending session idle timeout');

    final responseString = await _rdnaClient.extendSessionIdleTimeout();
    print('RdnaService - ExtendSessionIdleTimeout response received: $responseString');

    // Parse JSON response to extract error
    Map<String, dynamic> responseMap;
    if (responseString is String) {
      responseMap = json.decode(responseString) as Map<String, dynamic>;
    } else {
      responseMap = responseString as Map<String, dynamic>;
    }

    // Parse nested error JSON string
    RDNAError? error;
    if (responseMap.containsKey('error') && responseMap['error'] is String) {
      final errorJson = responseMap['error'] as String;
      final errorMap = json.decode(errorJson) as Map<String, dynamic>;
      error = RDNAError.fromJson(errorMap);
    } else {
      error = RDNAError(longErrorCode: 0, shortErrorCode: 0, errorString: 'Success');
    }

    final response = RDNASyncResponse(
      error: error,
      response: responseMap['response'],
    );

    print('RdnaService - ExtendSessionIdleTimeout sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    return response;
  }

  /// Performs verify authentication for new device activation
  ///
  /// Processes the user's decision on new device activation via REL-ID Verify.
  /// When called with true, it sends verification notifications to registered devices.
  /// When called with false, it cancels the verification process.
  ///
  /// ## Parameters
  /// - [verifyAuthStatus]: User's decision (true = proceed with verification, false = cancel)
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (may have error or success)
  ///
  /// ## Events Triggered
  /// - Async events will be handled by event listeners for subsequent steps
  /// - Success typically leads to LDA consent or password flow
  ///
  /// ## Response Validation Logic
  /// 1. Check error.longErrorCode: 0 = success, > 0 = error
  /// 2. Async events will be handled by event listeners
  ///
  /// ## Example
  /// ```dart
  /// final response = await rdnaService.performVerifyAuth(true);
  /// if (response.error?.longErrorCode == 0) {
  ///   print('PerformVerifyAuth sync success, verification notifications sent');
  /// }
  /// ```
  Future<RDNASyncResponse> performVerifyAuth(bool verifyAuthStatus) async {
    print('RdnaService - Performing verify auth with status: $verifyAuthStatus');

    final response = await _rdnaClient.performVerifyAuth(verifyAuthStatus);

    print('RdnaService - PerformVerifyAuth sync response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    return response;
  }

  /// Initiates fallback new device activation flow
  ///
  /// Provides an alternative device activation method when REL-ID Verify
  /// is not available, fails, or expires. It initiates a server-configured fallback
  /// challenge flow, typically triggering a getActivationCode event.
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (may have error or success)
  ///
  /// ## Events Triggered
  /// - `getActivationCode`: Typically triggers for alternative verification
  /// - Async events will be handled by event listeners
  ///
  /// ## Response Validation Logic
  /// 1. Check error.longErrorCode: 0 = success, > 0 = error
  /// 2. Typically triggers getActivationCode event for alternative verification
  /// 3. Async events will be handled by event listeners
  ///
  /// ## Example
  /// ```dart
  /// final response = await rdnaService.fallbackNewDeviceActivationFlow();
  /// if (response.error?.longErrorCode == 0) {
  ///   print('FallbackNewDeviceActivationFlow sync success, waiting for async events');
  /// }
  /// ```
  Future<RDNASyncResponse> fallbackNewDeviceActivationFlow() async {
    print('RdnaService - Initiating fallback new device activation flow');

    final response = await _rdnaClient.fallbackNewDeviceActivationFlow();

    print('RdnaService - FallbackNewDeviceActivationFlow sync response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    return response;
  }

  /// Gets notifications from the REL-ID SDK server
  ///
  /// Fetches notifications for the current user. It follows the sync+async pattern:
  /// the method returns a sync response, then triggers an onGetNotifications event with notification data.
  ///
  /// ## Parameters
  /// - [recordCount]: Number of records to fetch (0 = all active notifications)
  /// - [startIndex]: Index to begin fetching from (must be >= 1)
  /// - [startDate]: Optional start date filter (format: YYYY-MM-DD)
  /// - [endDate]: Optional end date filter (format: YYYY-MM-DD)
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (may have error or success)
  ///
  /// ## Events Triggered
  /// - `onGetNotifications`: Triggered with notification data
  /// - Async events will be handled by event listeners
  ///
  /// ## Response Validation Logic
  /// 1. Check error.longErrorCode: 0 = success, > 0 = error
  /// 2. An onGetNotifications event will be triggered with notification data
  /// 3. Async events will be handled by event listeners
  ///
  /// ## Example
  /// ```dart
  /// final response = await rdnaService.getNotifications(0, 1);
  /// if (response.error?.longErrorCode == 0) {
  ///   print('GetNotifications sync success, waiting for onGetNotifications event');
  /// }
  /// ```
  Future<RDNASyncResponse> getNotifications({
    int recordCount = 0,
    String enterpriseID = '',
    int startIndex = 1,
    String startDate = '',
    String endDate = '',
  }) async {
    print('RdnaService - Fetching notifications');
    print('  recordCount: $recordCount, startIndex: $startIndex');

    final response = await _rdnaClient.getNotifications(
      recordCount,
      enterpriseID,
      startIndex,
      startDate,
      endDate,
    );

    print('RdnaService - GetNotifications sync response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    return response;
  }

  /// Updates a notification with user's action response
  ///
  /// Submits the user's response to a notification action.
  /// After successful API call, the SDK will trigger an onUpdateNotification event with update status.
  ///
  /// ## Parameters
  /// - [notificationId]: The notification UUID to update
  /// - [response]: The action response value selected by user
  ///
  /// ## Returns
  /// RDNASyncResponse containing sync response (may have error or success)
  ///
  /// ## Events Triggered
  /// - `onUpdateNotification`: Triggered with update status
  /// - Async events will be handled by event listeners
  ///
  /// ## Response Validation Logic
  /// 1. Check error.longErrorCode: 0 = success, > 0 = error
  /// 2. An onUpdateNotification event will be triggered with update status
  /// 3. Async events will be handled by event listeners
  ///
  /// ## Example
  /// ```dart
  /// final response = await rdnaService.updateNotification('notification-uuid', 'Approve');
  /// if (response.error?.longErrorCode == 0) {
  ///   print('UpdateNotification sync success, waiting for onUpdateNotification event');
  /// }
  /// ```
  Future<RDNASyncResponse> updateNotification(
      String notificationId, String response) async {
    print('RdnaService - Updating notification: $notificationId with response: $response');

    final syncResponse = await _rdnaClient.updateNotification(
      notificationId,
      response,
    );

    print('RdnaService - UpdateNotification sync response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${syncResponse.error?.longErrorCode}');
    print('  Short Error Code: ${syncResponse.error?.shortErrorCode}');

    return syncResponse;
  }
}
