// ============================================================================
// File: rdna_service.dart
// Description: REL-ID SDK Service
//
// Transformed from: src/uniken/services/rdnaService.ts
// Original: rdnaService.ts
//
// Main service class for interacting with the REL-ID SDK.
// Provides methods for SDK initialization and version retrieval.
// ============================================================================

import 'package:rdna_client/rdna_client.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../utils/connection_profile_parser.dart';
import 'rdna_event_manager.dart';

/// REL-ID SDK Service
///
/// Main service class for REL-ID SDK operations. Provides a singleton instance
/// for SDK initialization and version management.
///
/// ## Key Features
/// - Singleton pattern for consistent SDK access
/// - Integration with RdnaEventManager for event handling
/// - Connection profile loading and parsing
/// - SDK version retrieval
/// - Initialization with connection profile
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
  /// ## Parameters
  /// - `initOptions`: Optional configuration for SDK initialization.
  ///   If not provided, default values are used:
  ///   - Language: Empty (SDK defaults to 'en'), LTR direction
  ///   - Permissions: Location required but not mandatory
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
  /// // Basic initialization
  /// final syncResponse = await rdnaService.initialize();
  ///
  /// // Advanced initialization with custom configuration
  /// final syncResponse = await rdnaService.initialize(
  ///   RDNAInitOptions(
  ///     internationalizationOptions: RDNAinternationalizationOptions(
  ///       localeCode: 'ar',
  ///       localeName: 'Arabic',
  ///       languageDirection: 1  // RTL
  ///     ),
  ///     permissionOptions: RDNAPermissionOptions(
  ///       isLocationPermissionRequired: true,
  ///       isLocationPermissionMandatory: false
  ///     )
  ///   )
  /// );
  ///
  /// if (syncResponse.error?.longErrorCode == 0) {
  ///   print('Sync success, waiting for async events');
  /// } else {
  ///   print('Sync error: ${syncResponse.error?.errorString}');
  /// }
  /// ```
  Future<RDNASyncResponse> initialize([RDNAInitOptions? initOptions]) async {
    final profile = await loadAgentInfo();
    print('RdnaService - Loaded connection profile:');
    print('  Host: ${profile.host}');
    print('  Port: ${profile.port}');
    print('  RelId: ${profile.relId.substring(0, 10)}...');

    print('RdnaService - Starting initialization');

    // If no initOptions provided, use default values
    // Default configuration:
    // - Language: Empty (SDK defaults to 'en'), LTR direction
    // - Permissions: Location required but not mandatory
    // - Telemetry: Disabled (disableTrace: 1)
    final defaultInitOptions = RDNAInitOptions(
      internationalizationOptions: RDNAinternationalizationOptions(
        localeCode: '',           // Empty string - SDK will default to 'en'
        localeName: '',
        languageDirection: 0      // 0 = LTR (Left-to-Right)
      ),
      permissionOptions: RDNAPermissionOptions(
        isLocationPermissionRequired: true,    // Location permission is requested
        isLocationPermissionMandatory: false   // But SDK can work without it
      ),
      otelConfig: RDNAOtelConfig(
        otelHTTPEndpointURL: '',
        enableEncoding: '',
        disableTrace: 1,                       // Tracing disabled by default
        otelTraceFlushTimeout: 0
      ),
    );

    // Use provided options or defaults
    final finalInitOptions = initOptions ?? defaultInitOptions;

    print('RdnaService - InitOptions: ${finalInitOptions.toJson()}');

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
      finalInitOptions, // initOptions: Advanced SDK configuration (optional)
    );

    print('RdnaService - Initialize sync response received');
    print('RdnaService - Sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    // ✅ Return response directly - caller decides what to do
    return response;
  }
}
