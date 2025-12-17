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

// Session Management Callbacks
typedef RDNASessionTimeoutCallback = void Function(String);
typedef RDNASessionTimeoutNotificationCallback = void Function(SessionResponse);
typedef RDNASessionExtensionResponseCallback = void Function(SessionResponse);

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

  // Session Management Handlers
  RDNASessionTimeoutCallback? _sessionTimeoutHandler;
  RDNASessionTimeoutNotificationCallback? _sessionTimeoutNotificationHandler;
  RDNASessionExtensionResponseCallback? _sessionExtensionResponseHandler;

  RdnaEventManager._(this._rdnaClient) {
    _registerEventListeners();
  }

  /// Gets the singleton instance of RdnaEventManager
  static RdnaEventManager getInstance(RdnaClient rdnaClient) {
    _instance ??= RdnaEventManager._(rdnaClient);
    return _instance!;
  }

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

  /// Sets the handler for credentials available for update events
  void setCredentialsAvailableForUpdateHandler(RDNACredentialsAvailableForUpdateCallback? callback) {
    _credentialsAvailableForUpdateHandler = callback;
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

    print('RdnaEventManager - Cleanup completed');
  }
}
