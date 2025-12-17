// ============================================================================
// File: rdna_event_manager.dart
// Description: REL-ID SDK Event Manager
//
// Manages all REL-ID SDK events in a centralized, type-safe manner.
// Provides a singleton pattern for consistent event handling across the application.
//
// Supported Events:
// - onInitializeProgress: SDK initialization progress updates
// - onInitializeError: SDK initialization error handling
// - onInitialized: Successful SDK initialization with session data
// - onUserConsentThreats: Non-terminating threats requiring user consent
// - onTerminateWithThreats: Critical threats requiring app termination
// - getUser: User input requests for MFA
// - getActivationCode: Activation code input requests
// - getUserConsentForLDA: LDA consent requests
// - getPassword: Password input requests
// - onUserLoggedIn: User login success
// - onUserLoggedOff: User logout confirmation
// - onCredentialsAvailableForUpdate: Credential update availability
// - onSessionTimeout: Hard session timeout (mandatory)
// - onSessionTimeOutNotification: Idle session timeout warning
// - onSessionExtensionResponse: Session extension result
// - addNewDeviceOptions: Additional device activation via REL-ID Verify
// - onGetNotifications: Notification retrieval response
// - onUpdateNotification: Notification update response
// - onAuthenticateUserAndSignData: Data signing response with signature
//
// Key Features:
// - Singleton pattern for global event management
// - Type-safe callback handling with Dart types
// - Automatic event listener registration and cleanup
// - Single event handler per type for simplicity
// - Comprehensive error handling and logging
// ============================================================================

import 'package:eventify/eventify.dart';
import 'package:rdna_client/rdna_client.dart';
import 'package:rdna_client/rdna_struct.dart';

/// Type definitions for event callbacks
typedef RDNAInitializeProgressCallback = void Function(RDNAInitProgressStatus);
typedef RDNAInitializeErrorCallback = void Function(RDNAInitializeError);
typedef RDNAInitializeSuccessCallback = void Function(RDNAInitialized);
typedef RDNAUserConsentThreatsCallback = void Function(List<RDNAThreat>);
typedef RDNATerminateWithThreatsCallback = void Function(List<RDNAThreat>);
typedef RDNAGetUserCallback = void Function(RDNAGetUser);
typedef RDNAGetActivationCodeCallback = void Function(RDNAActivationCode);
typedef RDNAGetUserConsentForLDACallback = void Function(GetUserConsentForLDAData);
typedef RDNAGetPasswordCallback = void Function(RDNAGetPassword);
typedef RDNAUserLoggedInCallback = void Function(RDNAUserLoggedIn);
typedef RDNAUserLoggedOffCallback = void Function(RDNAUserLogOff);
typedef RDNACredentialsAvailableForUpdateCallback = void Function(RDNACredentialsAvailableForUpdate);
typedef RDNAUpdateCredentialResponseCallback = void Function(RDNAUpdateCredentialResponse);

// Session Management Callbacks
typedef RDNASessionTimeoutCallback = void Function(String);
typedef RDNASessionTimeoutNotificationCallback = void Function(SessionResponse);
typedef RDNASessionExtensionResponseCallback = void Function(SessionResponse);

// Additional Device Activation Callbacks
typedef RDNAAddNewDeviceOptionsCallback = void Function(RDNAAddNewDeviceOptions);

// Notification Management Callbacks
typedef RDNAGetNotificationsCallback = void Function(RDNAStatusGetNotifications);
typedef RDNAGetNotificationHistoryCallback = void Function(RDNAStatusGetNotificationHistory);
typedef RDNAUpdateNotificationCallback = void Function(RDNAStatusUpdateNotification);

// LDA Management Callbacks
typedef RDNADeviceAuthManagementStatusCallback = void Function(RDNADeviceAuthManagementStatus);

// Data Signing Callbacks
typedef RDNADataSigningResponseCallback = void Function(AuthenticateUserAndSignData);

// Device Management Callbacks
typedef RDNAGetRegisteredDeviceDetailsCallback = void Function(RDNAStatusGetRegisteredDeviceDetails);
typedef RDNAUpdateDeviceDetailsCallback = void Function(RDNAStatusUpdateDeviceDetails);

/// REL-ID SDK Event Manager
///
/// Manages all REL-ID SDK events in a centralized, type-safe manner.
/// Provides a singleton pattern for consistent event handling across the application.
class RdnaEventManager {
  static RdnaEventManager? _instance;
  final RdnaClient _rdnaClient;
  final List<Listener?> _listeners = [];

  // Composite event handlers (can handle multiple concerns)
  RDNAInitializeProgressCallback? _initializeProgressHandler;
  RDNAInitializeErrorCallback? _initializeErrorHandler;
  RDNAInitializeSuccessCallback? _initializedHandler;
  RDNAUserConsentThreatsCallback? _userConsentThreatsHandler;
  RDNATerminateWithThreatsCallback? _terminateWithThreatsHandler;
  RDNAGetUserCallback? _getUserHandler;
  RDNAGetActivationCodeCallback? _getActivationCodeHandler;
  RDNAGetUserConsentForLDACallback? _getUserConsentForLDAHandler;
  RDNAGetPasswordCallback? _getPasswordHandler;
  RDNAUserLoggedInCallback? _onUserLoggedInHandler;
  RDNAUserLoggedOffCallback? _onUserLoggedOffHandler;
  RDNACredentialsAvailableForUpdateCallback? _credentialsAvailableForUpdateHandler;
  RDNAUpdateCredentialResponseCallback? _updateCredentialResponseHandler;

  // Session Management Handlers
  RDNASessionTimeoutCallback? _sessionTimeoutHandler;
  RDNASessionTimeoutNotificationCallback? _sessionTimeoutNotificationHandler;
  RDNASessionExtensionResponseCallback? _sessionExtensionResponseHandler;

  // Additional Device Activation Handlers
  RDNAAddNewDeviceOptionsCallback? _addNewDeviceOptionsHandler;

  // Notification Management Handlers
  RDNAGetNotificationsCallback? _getNotificationsHandler;
  RDNAGetNotificationHistoryCallback? _getNotificationHistoryHandler;
  RDNAUpdateNotificationCallback? _updateNotificationHandler;

  // LDA Management Handlers
  RDNADeviceAuthManagementStatusCallback? _deviceAuthManagementStatusHandler;

  // Data Signing Handlers
  RDNADataSigningResponseCallback? _dataSigningResponseHandler;

  // Device Management Handlers
  RDNAGetRegisteredDeviceDetailsCallback? _getRegisteredDeviceDetailsHandler;
  RDNAUpdateDeviceDetailsCallback? _updateDeviceDetailsHandler;

  RdnaEventManager._(this._rdnaClient) {
    _registerEventListeners();
  }

  /// Gets the singleton instance of RdnaEventManager
  static RdnaEventManager getInstance(RdnaClient rdnaClient) {
    _instance ??= RdnaEventManager._(rdnaClient);
    return _instance!;
  }

  /// Gets the current getPassword handler (for callback preservation pattern)
  RDNAGetPasswordCallback? get getPasswordHandler => _getPasswordHandler;

  /// Gets the current getUserConsentForLDA handler (for callback preservation pattern)
  RDNAGetUserConsentForLDACallback? get getUserConsentForLDAHandler => _getUserConsentForLDAHandler;

  /// Gets the current data signing response handler (for callback preservation pattern)
  RDNADataSigningResponseCallback? get getDataSigningResponseHandler => _dataSigningResponseHandler;

  /// Gets the current get registered device details handler (for callback preservation pattern)
  RDNAGetRegisteredDeviceDetailsCallback? get getGetRegisteredDeviceDetailsHandler => _getRegisteredDeviceDetailsHandler;

  /// Gets the current update device details handler (for callback preservation pattern)
  RDNAUpdateDeviceDetailsCallback? get getUpdateDeviceDetailsHandler => _updateDeviceDetailsHandler;

  /// Registers native event listeners for all SDK events
  void _registerEventListeners() {
    print('RdnaEventManager - Registering native event listeners');

    _listeners.add(
      _rdnaClient.on(RdnaClient.onInitializeProgress, _onInitializeProgress),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.onInitializeError, _onInitializeError),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.onInitialized, _onInitialized),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.onUserConsentThreats, _onUserConsentThreats),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.onTerminateWithThreats, _onTerminateWithThreats),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.getUser, _onGetUser),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.getActivationCode, _onGetActivationCode),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.getUserConsentForLDA, _onGetUserConsentForLDA),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.getPassword, _onGetPassword),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.onUserLoggedIn, _onUserLoggedIn),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.onUserLoggedOff, _onUserLoggedOff),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.onCredentialsAvailableForUpdate, _onCredentialsAvailableForUpdate),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.onUpdateCredentialResponse, _onUpdateCredentialResponse),
    );

    // Session Management Event Listeners
    _listeners.add(
      _rdnaClient.on(RdnaClient.onSessionTimeout, _onSessionTimeout),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.onSessionTimeOutNotification, _onSessionTimeOutNotification),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.onSessionExtensionResponse, _onSessionExtensionResponse),
    );

    // Additional Device Activation Event Listeners
    _listeners.add(
      _rdnaClient.on(RdnaClient.addNewDeviceOptions, _onAddNewDeviceOptions),
    );

    // Notification Management Event Listeners
    _listeners.add(
      _rdnaClient.on(RdnaClient.onGetNotifications, _onGetNotifications),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.onGetNotificationsHistory, _onGetNotificationHistory),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.onUpdateNotification, _onUpdateNotification),
    );

    // LDA Management Event Listeners
    _listeners.add(
      _rdnaClient.on(RdnaClient.onDeviceAuthManagementStatus, _onDeviceAuthManagementStatus),
    );

    // Data Signing Event Listeners
    _listeners.add(
      _rdnaClient.on(RdnaClient.onAuthenticateUserAndSignData, _onAuthenticateUserAndSignData),
    );

    // Device Management Event Listeners
    _listeners.add(
      _rdnaClient.on(RdnaClient.onGetRegistredDeviceDetails, _onGetRegistredDeviceDetails),
    );
    _listeners.add(
      _rdnaClient.on(RdnaClient.onUpdateDeviceDetails, _onUpdateDeviceDetails),
    );

    print('RdnaEventManager - Native event listeners registered');
  }

  /// Handles SDK initialization progress events
  ///
  /// ## Parameters
  /// - [progressData]: Progress status data from the SDK
  void _onInitializeProgress(dynamic progressData) {
    print('RdnaEventManager - Initialize progress event received');

    final data = progressData as RDNAInitProgressStatus;
    print('RdnaEventManager - Progress: ${data.initializeStatus}');

    if (_initializeProgressHandler != null) {
      _initializeProgressHandler!(data);
    }
  }

  /// Handles SDK initialization error events
  ///
  /// ## Parameters
  /// - [errorData]: Error data from the SDK containing error details
  void _onInitializeError(dynamic errorData) {
    print('RdnaEventManager - Initialize error event received');

    final data = errorData as RDNAInitializeError;
    print('RdnaEventManager - Initialize error: ${data.errorString}');

    if (_initializeErrorHandler != null) {
      _initializeErrorHandler!(data);
    }
  }

  /// Handles SDK initialization success events
  ///
  /// ## Parameters
  /// - [initializedData]: Initialization data from the SDK containing session info
  void _onInitialized(dynamic initializedData) {
    print('RdnaEventManager - Initialize success event received');

    final data = initializedData as RDNAInitialized;
    print('RdnaEventManager - Successfully initialized, Session ID: ${data.session?.sessionId}');

    if (_initializedHandler != null) {
      _initializedHandler!(data);
    }
  }

  /// Handles security threat events requiring user consent
  ///
  /// Called when SDK detects non-critical threats that the user can choose
  /// to proceed with or exit the application.
  ///
  /// ## Parameters
  /// - [threatsData]: List of threat objects from the SDK
  void _onUserConsentThreats(dynamic threatsData) {
    print('RdnaEventManager - User consent threats event received');

    final threats = threatsData as List<RDNAThreat>;
    print('RdnaEventManager - Consent threats detected: ${threats.length}');

    if (_userConsentThreatsHandler != null) {
      _userConsentThreatsHandler!(threats);
    }
  }

  /// Handles critical security threat events requiring app termination
  ///
  /// Called when SDK detects critical threats that require the application
  /// to be terminated for security reasons.
  ///
  /// ## Parameters
  /// - [threatsData]: List of threat objects from the SDK
  void _onTerminateWithThreats(dynamic threatsData) {
    print('RdnaEventManager - Terminate with threats event received');

    final threats = threatsData as List<RDNAThreat>;
    print('RdnaEventManager - Critical threats detected, terminating: ${threats.length}');

    if (_terminateWithThreatsHandler != null) {
      _terminateWithThreatsHandler!(threats);
    }
  }

  /// Handles user input request events for MFA authentication
  ///
  /// ## Parameters
  /// - [userData]: User data from the SDK
  void _onGetUser(dynamic userData) {
    print('RdnaEventManager - Get user event received');

    final data = userData as RDNAGetUser;
    print('RdnaEventManager - Get user status: ${data.challengeResponse?.status?.statusCode}');

    if (_getUserHandler != null) {
      _getUserHandler!(data);
    }
  }

  /// Handles activation code request events for MFA authentication
  ///
  /// ## Parameters
  /// - [activationCodeData]: Activation code data from the SDK
  void _onGetActivationCode(dynamic activationCodeData) {
    print('RdnaEventManager - Get activation code event received');

    final data = activationCodeData as RDNAActivationCode;
    print('RdnaEventManager - Get activation code status: ${data.challengeResponse?.status?.statusCode}');
    print('RdnaEventManager - UserID: ${data.userId}, AttemptsLeft: ${data.attemptsLeft}');

    if (_getActivationCodeHandler != null) {
      _getActivationCodeHandler!(data);
    }
  }

  /// Handles user consent for LDA request events
  ///
  /// ## Parameters
  /// - [ldaConsentData]: LDA consent data from the SDK
  void _onGetUserConsentForLDA(dynamic ldaConsentData) {
    print('RdnaEventManager - Get user consent for LDA event received');

    final data = ldaConsentData as GetUserConsentForLDAData;
    print('RdnaEventManager - UserID: ${data.userID}, ChallengeMode: ${data.challengeMode}, AuthType: ${data.authenticationType}');

    if (_getUserConsentForLDAHandler != null) {
      _getUserConsentForLDAHandler!(data);
    }
  }

  /// Handles password request events for MFA authentication
  ///
  /// ## Parameters
  /// - [passwordData]: Password data from the SDK
  void _onGetPassword(dynamic passwordData) {
    print('RdnaEventManager - Get password event received');

    final data = passwordData as RDNAGetPassword;
    print('RdnaEventManager - Get password status: ${data.challengeResponse?.status?.statusCode}');
    print('RdnaEventManager - UserID: ${data.userId}, ChallengeMode: ${data.challengeMode}, AttemptsLeft: ${data.attemptsLeft}');

    if (_getPasswordHandler != null) {
      _getPasswordHandler!(data);
    }
  }

  /// Handles user logged in events indicating successful authentication
  ///
  /// ## Parameters
  /// - [loggedInData]: User login data from the SDK
  void _onUserLoggedIn(dynamic loggedInData) {
    print('RdnaEventManager - User logged in event received');

    final data = loggedInData as RDNAUserLoggedIn;
    print('RdnaEventManager - User logged in: ${data.userId}');
    print('RdnaEventManager - Session ID: ${data.challengeResponse?.session?.sessionId}');

    if (_onUserLoggedInHandler != null) {
      _onUserLoggedInHandler!(data);
    }
  }

  /// Handles user logged off events indicating successful logout
  ///
  /// ## Parameters
  /// - [loggedOffData]: User logout data from the SDK
  void _onUserLoggedOff(dynamic loggedOffData) {
    print('RdnaEventManager - User logged off event received');

    final data = loggedOffData as RDNAUserLogOff;
    print('RdnaEventManager - Status Code: ${data.challengeResponse?.status?.statusCode}');
    print('RdnaEventManager - Error Code: ${data.error?.longErrorCode}');

    if (_onUserLoggedOffHandler != null) {
      _onUserLoggedOffHandler!(data);
    }
  }

  /// Handles credentials available for update events
  ///
  /// ## Parameters
  /// - [credentialsData]: Credentials update data from the SDK
  void _onCredentialsAvailableForUpdate(dynamic credentialsData) {
    print('RdnaEventManager - Credentials available for update event received');

    final data = credentialsData as RDNACredentialsAvailableForUpdate;
    print('RdnaEventManager - Available options: ${data.options}');

    if (_credentialsAvailableForUpdateHandler != null) {
      _credentialsAvailableForUpdateHandler!(data);
    }
  }

  /// Handles update credential response events
  ///
  /// This event is triggered after updatePassword() API call with challengeMode = 2.
  /// It provides the update status for the credential update operation.
  ///
  /// ## Parameters
  /// - [updateData]: Update credential response data from the SDK (RDNAUpdateCredentialResponse)
  void _onUpdateCredentialResponse(dynamic updateData) {
    print('RdnaEventManager - Update credential response event received');

    // Cast to RDNAUpdateCredentialResponse
    final response = updateData as RDNAUpdateCredentialResponse;
    print('RdnaEventManager - Update credential response:');
    print('  userId: ${response.userId}');
    print('  credType: ${response.credType}');
    print('  statusCode: ${response.status?.statusCode}');
    print('  statusMessage: ${response.status?.statusMessage}');

    if (_updateCredentialResponseHandler != null) {
      _updateCredentialResponseHandler!(response);
    }
  }

  /// Sets event handlers for SDK events. Only one handler per event type.

  /// Sets the handler for initialization progress events
  void setInitializeProgressHandler(RDNAInitializeProgressCallback? callback) {
    _initializeProgressHandler = callback;
  }

  /// Sets the handler for initialization error events
  void setInitializeErrorHandler(RDNAInitializeErrorCallback? callback) {
    _initializeErrorHandler = callback;
  }

  /// Sets the handler for initialization success events
  void setInitializedHandler(RDNAInitializeSuccessCallback? callback) {
    _initializedHandler = callback;
  }

  /// Sets the handler for user consent threats events
  void setUserConsentThreatsHandler(RDNAUserConsentThreatsCallback? callback) {
    _userConsentThreatsHandler = callback;
  }

  /// Sets the handler for terminate with threats events
  void setTerminateWithThreatsHandler(RDNATerminateWithThreatsCallback? callback) {
    _terminateWithThreatsHandler = callback;
  }

  /// Sets the handler for get user events
  void setGetUserHandler(RDNAGetUserCallback? callback) {
    _getUserHandler = callback;
  }

  /// Sets the handler for get activation code events
  void setGetActivationCodeHandler(RDNAGetActivationCodeCallback? callback) {
    _getActivationCodeHandler = callback;
  }

  /// Sets the handler for get user consent for LDA events
  void setGetUserConsentForLDAHandler(RDNAGetUserConsentForLDACallback? callback) {
    _getUserConsentForLDAHandler = callback;
  }

  /// Sets the handler for get password events
  void setGetPasswordHandler(RDNAGetPasswordCallback? callback) {
    _getPasswordHandler = callback;
  }

  /// Sets the handler for user logged in events
  void setOnUserLoggedInHandler(RDNAUserLoggedInCallback? callback) {
    _onUserLoggedInHandler = callback;
  }

  /// Sets the handler for user logged off events
  void setOnUserLoggedOffHandler(RDNAUserLoggedOffCallback? callback) {
    _onUserLoggedOffHandler = callback;
  }

  // Session Management Event Handlers

  /// Handles session timeout events for mandatory sessions
  ///
  /// ## Parameters
  /// - [sessionData]: Raw session timeout data from the SDK (string message)
  void _onSessionTimeout(dynamic sessionData) {
    print('RdnaEventManager - Session timeout event received');
    print('RdnaEventManager - Session data: $sessionData');

    // The session timeout data is a plain string message
    final message = sessionData as String;
    print('RdnaEventManager - Session timeout message: $message');

    if (_sessionTimeoutHandler != null) {
      _sessionTimeoutHandler!(message);
    }
  }

  /// Handles session timeout notification events for idle sessions
  ///
  /// ## Parameters
  /// - [notificationData]: Session timeout notification data from the SDK (SessionResponse)
  void _onSessionTimeOutNotification(dynamic notificationData) {
    print('RdnaEventManager - Session timeout notification event received');

    // Cast to SessionResponse
    final sessionResponse = notificationData as SessionResponse;
    print('RdnaEventManager - Notification data: ${sessionResponse.userID}, TimeLeft: ${sessionResponse.timeLeftInSeconds}s');

    if (_sessionTimeoutNotificationHandler != null) {
      _sessionTimeoutNotificationHandler!(sessionResponse);
    }
  }

  /// Handles session extension response events
  ///
  /// ## Parameters
  /// - [extensionData]: Session extension response data from the SDK (SessionResponse)
  void _onSessionExtensionResponse(dynamic extensionData) {
    print('RdnaEventManager - Session extension response event received');

    // Cast to SessionResponse
    final sessionResponse = extensionData as SessionResponse;
    print('RdnaEventManager - Extension data: ${sessionResponse.userID}, TimeLeft: ${sessionResponse.timeLeftInSeconds}s, Message: ${sessionResponse.message}');

    if (_sessionExtensionResponseHandler != null) {
      _sessionExtensionResponseHandler!(sessionResponse);
    }
  }

  /// Handles add new device options events (REL-ID Verify)
  ///
  /// This event is triggered when the SDK requires additional device activation
  /// via REL-ID Verify. It provides device options and challenge information.
  ///
  /// ## Parameters
  /// - [addNewDeviceData]: Additional device options data from the SDK (RDNAAddNewDeviceOptions)
  void _onAddNewDeviceOptions(dynamic addNewDeviceData) {
    print('RdnaEventManager - Add new device options event received');

    // Cast to RDNAAddNewDeviceOptions
    final deviceOptions = addNewDeviceData as RDNAAddNewDeviceOptions;
    print('RdnaEventManager - Add new device options data:');
    print('  UserID: ${deviceOptions.userId}');
    print('  Device Options Count: ${deviceOptions.newDeviceOptions?.length ?? 0}');
    print('  Challenge Info Count: ${deviceOptions.challengeInfo?.length ?? 0}');

    if (_addNewDeviceOptionsHandler != null) {
      _addNewDeviceOptionsHandler!(deviceOptions);
    }
  }

  /// Handles notification retrieval response events
  ///
  /// This event is triggered after getNotifications() API call.
  /// It provides the list of notifications for the user.
  ///
  /// ## Parameters
  /// - [notificationData]: Notification retrieval response from the SDK (RDNAStatusGetNotifications)
  void _onGetNotifications(dynamic notificationData) {
    print('RdnaEventManager - Get notifications event received');

    // Cast to RDNAStatusGetNotifications and pass full status object to handler
    final statusData = notificationData as RDNAStatusGetNotifications;

    if (_getNotificationsHandler != null) {
      _getNotificationsHandler!(statusData);
    }
  }

  /// Handles notification history response events
  ///
  /// This event is triggered after getNotificationHistory() API call.
  /// It provides historical notifications with filtering results.
  ///
  /// ## Parameters
  /// - [historyData]: Notification history response from the SDK (RDNAStatusGetNotificationHistory)
  void _onGetNotificationHistory(dynamic historyData) {
    print('RdnaEventManager - Get notification history event received');

    // Cast to RDNAStatusGetNotificationHistory and pass full status object to handler
    final statusData = historyData as RDNAStatusGetNotificationHistory;

    if (_getNotificationHistoryHandler != null) {
      _getNotificationHistoryHandler!(statusData);
    }
  }

  /// Handles notification update response events
  ///
  /// This event is triggered after updateNotification() API call.
  /// It provides the update status for the notification action.
  ///
  /// ## Parameters
  /// - [updateData]: Notification update response from the SDK (RDNAStatusUpdateNotification)
  void _onUpdateNotification(dynamic updateData) {
    print('RdnaEventManager - Update notification event received');

    // Cast to RDNAStatusUpdateNotification and pass full status object to handler
    final statusData = updateData as RDNAStatusUpdateNotification;

    if (_updateNotificationHandler != null) {
      _updateNotificationHandler!(statusData);
    }
  }

  /// Handles device auth management status event
  ///
  /// This event is triggered after manageDeviceAuthenticationModes() API call.
  /// It provides the management status for the LDA enable/disable operation.
  ///
  /// ## Parameters
  /// - [authManagementData]: Device auth management status data from the SDK
  void _onDeviceAuthManagementStatus(dynamic authManagementData) {
    print('RdnaEventManager - Device auth management status event received');

    // Cast to RDNADeviceAuthManagementStatus and pass full status object to handler
    final statusData = authManagementData as RDNADeviceAuthManagementStatus;

    print('RdnaEventManager - Device auth management status data:');
    print('  User ID: ${statusData.userId}');
    print('  OpMode: ${statusData.opMode}');
    print('  LDA Type: ${statusData.ldaType}');
    print('  Status Code: ${statusData.status?.statusCode}');
    print('  Error Code: ${statusData.error?.longErrorCode}');

    if (_deviceAuthManagementStatusHandler != null) {
      _deviceAuthManagementStatusHandler!(statusData);
    }
  }

  // Data Signing Event Handlers

  /// Handles data signing response events containing the cryptographically signed payload
  ///
  /// ## Parameters
  /// - [signingData]: Data signing response from the SDK with signature data
  void _onAuthenticateUserAndSignData(dynamic signingData) {
    print('RdnaEventManager - Data signing response event received');

    // Cast to AuthenticateUserAndSignData and pass to handler
    final responseData = signingData as AuthenticateUserAndSignData;

    print('RdnaEventManager - Data signing completed:');
    print('  Auth Level: ${responseData.authLevel}');
    print('  Authentication Type: ${responseData.authenticationType}');
    print('  Payload Length: ${responseData.dataPayloadLength}');
    print('  Signature ID Length: ${responseData.dataSignatureID?.length ?? 0}');
    print('  Status Code: ${responseData.status?.statusCode}');
    print('  Error Code: ${responseData.error?.shortErrorCode}');

    if (_dataSigningResponseHandler != null) {
      _dataSigningResponseHandler!(responseData);
    }
  }

  // Device Management Event Handlers

  /// Handles registered device details response events
  ///
  /// This event is triggered after getRegisteredDeviceDetails() API call.
  /// It provides the list of registered devices for the user.
  ///
  /// ## Parameters
  /// - [deviceDetailsData]: Device details response from the SDK (RDNAStatusGetRegisteredDeviceDetails)
  void _onGetRegistredDeviceDetails(dynamic deviceDetailsData) {
    print('RdnaEventManager - Get registered device details event received');

    // Cast to RDNAStatusGetRegisteredDeviceDetails and pass to handler
    final statusData = deviceDetailsData as RDNAStatusGetRegisteredDeviceDetails;

    print('RdnaEventManager - Get registered device details data:');
    print('  Error Code: ${statusData.errCode}');
    final deviceResponse = statusData.pArgs?.response?.responseData?.response is RDNAGetRegisteredDeviceDetailsResponse
        ? statusData.pArgs?.response?.responseData?.response as RDNAGetRegisteredDeviceDetailsResponse
        : null;
    print('  Device Count: ${deviceResponse?.device?.length ?? 0}');
    print('  Status Code: ${statusData.pArgs?.response?.statusCode}');
    print('  Status Msg: ${statusData.pArgs?.response?.statusMsg}');

    if (_getRegisteredDeviceDetailsHandler != null) {
      _getRegisteredDeviceDetailsHandler!(statusData);
    }
  }

  /// Handles update device details response events (rename/delete)
  ///
  /// This event is triggered after updateDeviceDetails() API call.
  /// It provides the update status for the device rename or delete operation.
  ///
  /// ## Parameters
  /// - [updateDeviceData]: Device update response from the SDK (RDNAStatusUpdateDeviceDetails)
  void _onUpdateDeviceDetails(dynamic updateDeviceData) {
    print('RdnaEventManager - Update device details event received');

    // Cast to RDNAStatusUpdateDeviceDetails and pass to handler
    final statusData = updateDeviceData as RDNAStatusUpdateDeviceDetails;

    print('RdnaEventManager - Update device details data:');
    print('  Error Code: ${statusData.errCode}');
    print('  Status Code: ${statusData.pArgs?.response?.statusCode}');
    print('  Status Msg: ${statusData.pArgs?.response?.statusMsg}');

    if (_updateDeviceDetailsHandler != null) {
      _updateDeviceDetailsHandler!(statusData);
    }
  }

  /// Sets the handler for credentials available for update events
  void setCredentialsAvailableForUpdateHandler(RDNACredentialsAvailableForUpdateCallback? callback) {
    _credentialsAvailableForUpdateHandler = callback;
  }

  /// Sets the handler for update credential response events
  void setUpdateCredentialResponseHandler(RDNAUpdateCredentialResponseCallback? callback) {
    _updateCredentialResponseHandler = callback;
  }

  // Session Management Handler Setters

  /// Sets the handler for session timeout events (hard timeout)
  void setSessionTimeoutHandler(RDNASessionTimeoutCallback? callback) {
    _sessionTimeoutHandler = callback;
  }

  /// Sets the handler for session timeout notification events (idle timeout warning)
  void setSessionTimeoutNotificationHandler(RDNASessionTimeoutNotificationCallback? callback) {
    _sessionTimeoutNotificationHandler = callback;
  }

  /// Sets the handler for session extension response events
  void setSessionExtensionResponseHandler(RDNASessionExtensionResponseCallback? callback) {
    _sessionExtensionResponseHandler = callback;
  }

  // Additional Device Activation Handler Setters

  /// Sets the handler for add new device options events (REL-ID Verify)
  void setAddNewDeviceOptionsHandler(RDNAAddNewDeviceOptionsCallback? callback) {
    _addNewDeviceOptionsHandler = callback;
  }

  // Notification Management Handler Setters

  /// Sets the handler for get notifications events
  void setGetNotificationsHandler(RDNAGetNotificationsCallback? callback) {
    _getNotificationsHandler = callback;
  }

  /// Sets the handler for notification history events
  void setGetNotificationHistoryHandler(RDNAGetNotificationHistoryCallback? callback) {
    _getNotificationHistoryHandler = callback;
  }

  /// Sets the handler for update notification events
  void setUpdateNotificationHandler(RDNAUpdateNotificationCallback? callback) {
    _updateNotificationHandler = callback;
  }

  // LDA Management Handler Setters

  /// Sets the handler for device auth management status events
  void setDeviceAuthManagementStatusHandler(RDNADeviceAuthManagementStatusCallback? callback) {
    _deviceAuthManagementStatusHandler = callback;
  }

  // Data Signing Handler Setters

  /// Sets the handler for data signing response events
  void setDataSigningResponseHandler(RDNADataSigningResponseCallback? callback) {
    _dataSigningResponseHandler = callback;
  }

  // Device Management Handler Setters

  /// Sets the handler for get registered device details events
  void setGetRegisteredDeviceDetailsHandler(RDNAGetRegisteredDeviceDetailsCallback? callback) {
    _getRegisteredDeviceDetailsHandler = callback;
  }

  /// Sets the handler for update device details events
  void setUpdateDeviceDetailsHandler(RDNAUpdateDeviceDetailsCallback? callback) {
    _updateDeviceDetailsHandler = callback;
  }

  /// Cleans up all event listeners and handlers
  void cleanup() {
    print('RdnaEventManager - Cleaning up event listeners and handlers');

    // Remove native event listeners
    for (final listener in _listeners) {
      if (listener != null) {
        _rdnaClient.off(listener);
      }
    }
    _listeners.clear();

    // Clear all event handlers
    _initializeProgressHandler = null;
    _initializeErrorHandler = null;
    _initializedHandler = null;
    _userConsentThreatsHandler = null;
    _terminateWithThreatsHandler = null;
    _getUserHandler = null;
    _getActivationCodeHandler = null;
    _getUserConsentForLDAHandler = null;
    _getPasswordHandler = null;
    _onUserLoggedInHandler = null;
    _onUserLoggedOffHandler = null;
    _credentialsAvailableForUpdateHandler = null;

    // Clear session management handlers
    _sessionTimeoutHandler = null;
    _sessionTimeoutNotificationHandler = null;
    _sessionExtensionResponseHandler = null;

    // Clear additional device activation handlers
    _addNewDeviceOptionsHandler = null;

    // Clear notification management handlers
    _getNotificationsHandler = null;
    _updateNotificationHandler = null;

    // Clear LDA management handlers
    _deviceAuthManagementStatusHandler = null;

    // Clear data signing handlers
    _dataSigningResponseHandler = null;

    // Clear device management handlers
    _getRegisteredDeviceDetailsHandler = null;
    _updateDeviceDetailsHandler = null;

    print('RdnaEventManager - Cleanup completed');
  }
}
