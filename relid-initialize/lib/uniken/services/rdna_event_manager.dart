// ============================================================================
// File: rdna_event_manager.dart
// Description: REL-ID SDK Event Manager
//
// Transformed from: src/uniken/services/rdnaEventManager.ts
// Original: rdnaEventManager.ts
//
// Manages all REL-ID SDK events in a centralized, type-safe manner.
// Provides a singleton pattern for consistent event handling across the application.
//
// Supported Events:
// - onInitializeProgress: SDK initialization progress updates
// - onInitializeError: SDK initialization error handling
// - onInitialized: Successful SDK initialization with session data
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

    print('RdnaEventManager - Cleanup completed');
  }
}
