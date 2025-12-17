// ============================================================================
// File: lda_toggling_screen.dart
// Description: LDA Toggling Screen
//
// Displays authentication capabilities retrieved from the REL-ID SDK with the following features:
// - Automatically loads authentication details on screen mount
// - Displays authentication types in a list with toggle switches
// - Allows users to enable/disable authentication types
// - Handles challengeModes 5, 14, 15, 16 via LDAToggleAuthDialog
// - Shows empty state when no LDA is available
//
// Key Features:
// - Automatic getDeviceAuthenticationDetails API call on screen load (returns data in sync callback)
// - Real-time event handling for onDeviceAuthManagementStatus (async event for LDA toggling)
// - Toggle switches for enabling/disabling authentication types
// - Authentication type name mapping for user-friendly display
// - Error handling and loading states
//
// Callback Pattern:
// - getDeviceAuthenticationDetails: Sync callback only (no async event)
// - manageDeviceAuthenticationModes: Triggers challengeMode 5/14/15/16 → LDAToggleAuthDialog
// - onDeviceAuthManagementStatus: Final result after auth complete
//
// Transformed from: Cordova LDATogglingScreen.js
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../../../uniken/services/rdna_service.dart';
import '../../../uniken/services/rdna_event_manager.dart';
import '../components/drawer_content.dart';
import 'lda_toggle_auth_dialog.dart';

/// Authentication Type Mapping
/// Maps authenticationType number to human-readable name
/// Based on RDNALDACapabilities enum mapping
const Map<int, String> authTypeNames = {
  0: 'None',
  1: 'Biometric Authentication', // RDNA_LDA_FINGERPRINT
  2: 'Face ID', // RDNA_LDA_FACE
  3: 'Pattern Authentication', // RDNA_LDA_PATTERN
  4: 'Biometric Authentication', // RDNA_LDA_SSKB_PASSWORD
  9: 'Biometric Authentication', // RDNA_DEVICE_LDA
};

/// LDA Toggling Screen - Route Parameters
class LDATogglingScreenParams {
  final String userID;
  final String sessionID;
  final int sessionType;
  final String jwtToken;
  final String? loginTime;
  final String? userRole;
  final String? currentWorkFlow;

  LDATogglingScreenParams({
    required this.userID,
    required this.sessionID,
    required this.sessionType,
    required this.jwtToken,
    this.loginTime,
    this.userRole,
    this.currentWorkFlow,
  });
}

/// LDA Toggling Screen
///
/// Displays authentication capabilities with toggle switches.
/// Uses LDAToggleAuthDialog for authentication challenges (challengeModes 5, 14, 15, 16).
class LDATogglingScreen extends ConsumerStatefulWidget {
  final LDATogglingScreenParams params;

  const LDATogglingScreen({
    super.key,
    required this.params,
  });

  @override
  ConsumerState<LDATogglingScreen> createState() => _LDATogglingScreenState();
}

class _LDATogglingScreenState extends ConsumerState<LDATogglingScreen> {
  bool _isLoading = true;
  List<RDNADeviceAuthenticationDetails> _authCapabilities = [];
  String? _error;
  int? _processingAuthType;

  // Preserved original handlers for callback preservation pattern
  RDNAGetPasswordCallback? _originalPasswordHandler;
  RDNAGetUserConsentForLDACallback? _originalConsentHandler;

  // Session data for drawer (converted from params)
  RDNAUserLoggedIn? _sessionData;

  @override
  void initState() {
    super.initState();

    // Create minimal session data for drawer from params
    _sessionData = RDNAUserLoggedIn(
      userId: widget.params.userID,
      challengeResponse: RDNAChallengeResponse(
        session: RDNASession(
          sessionId: widget.params.sessionID,
          sessionType: widget.params.sessionType,
        ),
        additionalInfo: RDNAAdditionalInfo(
          jwtJsonTokenInfo: widget.params.jwtToken,
          idvUserRole: widget.params.userRole,
          currentWorkFlow: widget.params.currentWorkFlow,
        ),
        status: null,
        challengeInfo: null,
      ),
      error: null,
    );

    _loadAuthenticationDetails();

    // Set up event handlers using Callback Preservation Pattern
    final eventManager = RdnaService.getInstance().getEventManager();

    // Preserve original handlers before setting new ones
    _originalPasswordHandler = eventManager.getPasswordHandler;
    _originalConsentHandler = eventManager.getUserConsentForLDAHandler;

    print('LDATogglingScreen - Preserved original handlers:');
    print('  Password handler: ${_originalPasswordHandler != null ? "exists" : "null"}');
    print('  Consent handler: ${_originalConsentHandler != null ? "exists" : "null"}');

    // Set up custom handlers for LDA toggling challengeModes
    eventManager.setDeviceAuthManagementStatusHandler(_handleAuthManagementStatusReceived);
    eventManager.setGetPasswordHandler(_handleGetPasswordForLDAToggling);
    eventManager.setGetUserConsentForLDAHandler(_handleGetUserConsentForLDAToggling);

    print('LDATogglingScreen - Event handlers registered with callback preservation');
  }

  @override
  void dispose() {
    // Clean up event handlers and restore preserved handlers
    final eventManager = RdnaService.getInstance().getEventManager();
    eventManager.setDeviceAuthManagementStatusHandler(null);

    // Only restore handlers if current handlers are still ours (not overwritten by another screen)
    final currentPasswordHandler = eventManager.getPasswordHandler;
    if (currentPasswordHandler == _handleGetPasswordForLDAToggling) {
      eventManager.setGetPasswordHandler(_originalPasswordHandler);
      print('LDATogglingScreen - Password handler cleaned up and restored');
    } else {
      print('LDATogglingScreen - Password handler was overwritten by another screen, not restoring');
    }

    final currentConsentHandler = eventManager.getUserConsentForLDAHandler;
    if (currentConsentHandler == _handleGetUserConsentForLDAToggling) {
      eventManager.setGetUserConsentForLDAHandler(_originalConsentHandler);
      print('LDATogglingScreen - Consent handler cleaned up and restored');
    } else {
      print('LDATogglingScreen - Consent handler was overwritten by another screen, not restoring');
    }

    super.dispose();
  }

  /// Load authentication details from the SDK
  /// Data is returned directly in the sync callback, no async event
  Future<void> _loadAuthenticationDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    print('LDATogglingScreen - Calling getDeviceAuthenticationDetails API');
    final response = await RdnaService.getInstance().getDeviceAuthenticationDetails();
    print('LDATogglingScreen - getDeviceAuthenticationDetails API call successful');

    // Check for errors (Flutter pattern - no try-catch)
    if (response.error?.longErrorCode != 0) {
      final errorMessage = response.error?.errorString ?? 'Failed to load authentication details';
      print('LDATogglingScreen - Authentication details error:');
      print('  Long Error Code: ${response.error?.longErrorCode}');
      print('  Short Error Code: ${response.error?.shortErrorCode}');
      print('  Error String: ${response.error?.errorString}');

      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
      return;
    }

    // Success path
    final capabilities = response.authenticationCapabilities ?? [];
    print('LDATogglingScreen - Received capabilities: ${capabilities.length}');

    // Log each capability for debugging
    for (var i = 0; i < capabilities.length; i++) {
      final cap = capabilities[i];
      print('LDATogglingScreen - Capability[$i]:');
      print('  authenticationType: ${cap.authenticationType}');
      print('  isConfigured: ${cap.isConfigured}');
      print('  isConfigured type: ${cap.isConfigured.runtimeType}');
      print('  isConfigured == true: ${cap.isConfigured == true}');
      print('  isConfigured == false: ${cap.isConfigured == false}');
    }

    setState(() {
      _authCapabilities = capabilities;
      _isLoading = false;
    });
  }

  /// Handle auth management status received from onDeviceAuthManagementStatus event
  void _handleAuthManagementStatusReceived(RDNADeviceAuthManagementStatus data) {
    print('LDATogglingScreen - Received auth management status event');
    print('LDATogglingScreen - Status data:');
    print('  userID: ${data.userId}');
    print('  opMode: ${data.opMode}');
    print('  ldaType: ${data.ldaType}');
    print('  statusCode: ${data.status?.statusCode}');
    print('  errorCode: ${data.error?.longErrorCode}');
    print('  errorString: ${data.error?.errorString}');

    setState(() {
      _processingAuthType = null;
    });

    // Check for errors
    if (data.error?.longErrorCode != 0) {
      final errorCode = data.error?.longErrorCode ?? 0;
      final errorMessage = data.error?.errorString ?? 'Failed to update authentication mode';

      print('LDATogglingScreen - Auth management status error code: $errorCode');

      // Error code 217: User cancelled LDA consent - silently refresh, no error dialog
      if (errorCode == 217) {
        print('LDATogglingScreen - User cancelled LDA consent (error 217), refreshing without error dialog');
        _loadAuthenticationDetails();
        return;
      }

      // Other errors: show error dialog
      print('LDATogglingScreen - Auth management status error: ${data.error}');
      _showResultDialog(
        'Update Failed',
        errorMessage,
        isSuccess: false,
      );
      return;
    }

    // Check status
    if (data.status?.statusCode == 100) {
      final opMode = data.opMode == 1 ? 'enabled' : 'disabled';
      final authTypeName = authTypeNames[data.ldaType] ?? 'Authentication Type ${data.ldaType}';

      print('LDATogglingScreen - Auth management status success: ${data.status?.statusMessage}');

      _showResultDialog(
        'Success',
        '$authTypeName has been $opMode successfully.',
        isSuccess: true,
      );
    } else {
      final statusMessage = data.status?.statusMessage ?? 'Unknown error occurred';
      print('LDATogglingScreen - Auth management status error: $statusMessage');

      _showResultDialog(
        'Update Failed',
        statusMessage,
        isSuccess: false,
      );
    }
  }

  /// Show result dialog and refresh on OK
  void _showResultDialog(String title, String message, {required bool isSuccess}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Refresh authentication details to get updated status
              _loadAuthenticationDetails();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Handle toggle switch change
  Future<void> _handleToggleChange(RDNADeviceAuthenticationDetails capability, bool newValue) async {
    final authTypeName = authTypeNames[capability.authenticationType] ?? 'Authentication Type ${capability.authenticationType}';

    print('LDATogglingScreen - Toggle change: authenticationType=${capability.authenticationType}, authTypeName=$authTypeName, currentValue=${capability.isConfigured}, newValue=$newValue');

    if (_processingAuthType != null) {
      print('LDATogglingScreen - Another operation is in progress, ignoring toggle');
      return;
    }

    setState(() {
      _processingAuthType = capability.authenticationType;
    });

    print('LDATogglingScreen - Calling manageDeviceAuthenticationModes API');

    // Convert int to RDNALDACapabilities enum
    final ldaCapability = RDNALDACapabilities.values[capability.authenticationType ?? 0];

    final response = await RdnaService.getInstance().manageDeviceAuthenticationModes(newValue, ldaCapability);

    print('LDATogglingScreen - manageDeviceAuthenticationModes API response received');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');
    print('  Error String: ${response.error?.errorString}');

    // Check for errors (Flutter pattern - no try-catch)
    if (response.error?.longErrorCode != 0) {
      final errorMessage = response.error?.errorString ?? 'Failed to update authentication mode';
      print('LDATogglingScreen - manageDeviceAuthenticationModes API error: $errorMessage');

      setState(() {
        _processingAuthType = null;
      });

      _showResultDialog(
        'Update Failed',
        errorMessage,
        isSuccess: false,
      );
      return;
    }

    // Success path
    print('LDATogglingScreen - manageDeviceAuthenticationModes API call successful');
    // SDK will trigger getPassword (challengeMode 5/14/15) or getUserConsentForLDA (challengeMode 16)
    // LDAToggleAuthDialog will be shown by this screen's event handlers
    // Response will be handled by _handleAuthManagementStatusReceived
  }

  /// Handle getPassword events for LDA toggling (challengeModes 5, 14, 15)
  void _handleGetPasswordForLDAToggling(RDNAGetPassword data) {
    print('LDATogglingScreen - Get password event received');
    print('  ChallengeMode: ${data.challengeMode}, AttemptsLeft: ${data.attemptsLeft}');

    // Only handle LDA toggling password modes (5, 14, 15)
    if (data.challengeMode == 5 || data.challengeMode == 14 || data.challengeMode == 15) {
      print('LDATogglingScreen - Handling challengeMode ${data.challengeMode} for LDA toggling');

      // Show dialog with onCancelled callback
      LDAToggleAuthDialog.show(
        context,
        challengeMode: data.challengeMode ?? 5,
        userID: data.userId ?? '',
        attemptsLeft: data.attemptsLeft ?? 3,
        passwordData: data,
        onCancelled: () {
          print('LDATogglingScreen - Dialog cancelled, resetting processing state');
          resetProcessingState();
        },
      );
    } else {
      // Other challengeModes: call preserved original handler
      print('LDATogglingScreen - Non-LDA toggling challengeMode ${data.challengeMode}, calling original handler');
      if (_originalPasswordHandler != null) {
        _originalPasswordHandler!(data);
      }
    }
  }

  /// Handle getUserConsentForLDA events for LDA toggling (challengeMode 16)
  void _handleGetUserConsentForLDAToggling(GetUserConsentForLDAData data) {
    print('LDATogglingScreen - Get user consent for LDA event received');
    print('  ChallengeMode: ${data.challengeMode}, AuthType: ${data.authenticationType}');

    // Only handle LDA toggling consent mode (16)
    if (data.challengeMode == 16) {
      print('LDATogglingScreen - Handling challengeMode 16 for LDA toggling consent');

      // Show dialog with onCancelled callback
      LDAToggleAuthDialog.show(
        context,
        challengeMode: data.challengeMode ?? 16,
        userID: data.userID ?? '',
        attemptsLeft: 1,
        consentData: data,
        onCancelled: () {
          print('LDATogglingScreen - Consent dialog cancelled, resetting processing state');
          resetProcessingState();
        },
      );
    } else {
      // Other challengeModes: call preserved original handler
      print('LDATogglingScreen - Non-LDA toggling challengeMode ${data.challengeMode}, calling original handler');
      if (_originalConsentHandler != null) {
        _originalConsentHandler!(data);
      }
    }
  }

  /// Reset processing state (called by dialog after cancel)
  void resetProcessingState() {
    print('LDATogglingScreen - Resetting processing state');
    if (mounted) {
      setState(() {
        _processingAuthType = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.menu, color: Color(0xFF2C3E50)),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'LDA Toggling',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.refresh, color: Color(0xFF2C3E50), size: 20),
            ),
            onPressed: _loadAuthenticationDetails,
          ),
        ],
      ),
      drawer: DrawerContent(
        sessionData: _sessionData,
        currentRoute: 'ldaTogglingScreen',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF3498DB)),
            SizedBox(height: 16),
            Text(
              'Loading authentication details...',
              style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: const TextStyle(fontSize: 16, color: Color(0xFFE74C3C)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAuthenticationDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_authCapabilities.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _authCapabilities.length + 1, // +1 for footer
      itemBuilder: (context, index) {
        if (index == _authCapabilities.length) {
          return _buildFooterInfo();
        }
        return _buildAuthCapabilityItem(_authCapabilities[index]);
      },
    );
  }

  Widget _buildAuthCapabilityItem(RDNADeviceAuthenticationDetails capability) {
    final authTypeName = authTypeNames[capability.authenticationType] ?? 'Authentication Type ${capability.authenticationType}';
    final isEnabled = capability.isConfigured == true;
    final isProcessing = _processingAuthType == capability.authenticationType;

    print('LDATogglingScreen - Building item for authType: ${capability.authenticationType}');
    print('  Raw isConfigured value: ${capability.isConfigured}');
    print('  Computed isEnabled: $isEnabled');
    print('  authTypeName: $authTypeName');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authTypeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Type ID: ${capability.authenticationType}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEnabled ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isEnabled ? const Color(0xFF27AE60) : const Color(0xFF95A5A6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 50,
            child: isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF3498DB),
                    ),
                  )
                : Builder(
                    builder: (context) {
                      print('LDATogglingScreen - Switch widget value for authType ${capability.authenticationType}: $isEnabled');
                      return Switch(
                        value: isEnabled,
                        onChanged: _processingAuthType != null
                            ? null
                            : (newValue) {
                                print('LDATogglingScreen - Switch toggled: $isEnabled → $newValue');
                                _handleToggleChange(capability, newValue);
                              },
                        activeColor: const Color(0xFF3498DB),
                        inactiveThumbColor: const Color(0xFFF4F3F4),
                        inactiveTrackColor: const Color(0xFFCCCCCC),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🔐',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'No LDA Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No Local Device Authentication (LDA) capabilities are available for this device.',
              style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAuthenticationDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                '🔄 Refresh',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: const Color(0xFF2196F3), width: 4),
        ),
      ),
      child: const Text(
        'When biometric has been set up, you will be able to login into the application via configured authentication mode.',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF1565C0),
          height: 1.4,
        ),
      ),
    );
  }
}
