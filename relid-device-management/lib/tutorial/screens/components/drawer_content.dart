// ============================================================================
// File: drawer_content.dart
// Description: Centralized Drawer Content Component
//
// Transformed from: DrawerContent.tsx
// Provides reusable drawer menu with user info and logout functionality
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../../../uniken/services/rdna_service.dart';
import '../../../uniken/providers/sdk_event_provider.dart';
import '../lda_toggling/lda_toggling_screen.dart';

/// Drawer Content Component
///
/// Centralized drawer menu that can be reused across multiple screens.
/// Handles user display and logout functionality.
///
/// ## Parameters
/// - sessionData: User session data containing userId and other info
/// - currentRoute: Name of the current screen (to highlight active menu item)
class DrawerContent extends ConsumerStatefulWidget {
  final RDNAUserLoggedIn? sessionData;
  final String? currentRoute;

  const DrawerContent({
    super.key,
    this.sessionData,
    this.currentRoute,
  });

  @override
  ConsumerState<DrawerContent> createState() => _DrawerContentState();
}

class _DrawerContentState extends ConsumerState<DrawerContent> {
  bool _isLoggingOut = false;
  bool _isInitiatingUpdate = false;

  /// Handle logout button press
  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Off'),
        content: const Text('Are you sure you want to log off?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE74C3C),
            ),
            child: const Text('Log Off'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    await _performLogout();
  }

  /// Perform the actual logout operation
  Future<void> _performLogout() async {
    final userId = widget.sessionData?.userId;
    if (userId == null) {
      print('DrawerContent - No userId available for logout');
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    print('DrawerContent - Initiating logOff for user: $userId');
    final rdnaService = RdnaService.getInstance();
    final syncResponse = await rdnaService.logOff(userId);

    print('DrawerContent - LogOff sync response received');
    print('  Long Error Code: ${syncResponse.error?.longErrorCode}');
    print('  Short Error Code: ${syncResponse.error?.shortErrorCode}');
    print('  Error String: ${syncResponse.error?.errorString}');

    if (syncResponse.error?.longErrorCode == 0) {
      print('DrawerContent - LogOff successful, waiting for onUserLoggedOff event');
      // SDK will trigger onUserLoggedOff event and then getUser event
      // Navigation will be handled by SDK event provider
    } else {
      // Handle sync error response
      final errorMessage = syncResponse.error?.errorString ?? 'Logout failed';
      print('DrawerContent - LogOff error: $errorMessage');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  /// Handle update password menu item tap
  Future<void> _handleUpdatePassword() async {
    setState(() {
      _isInitiatingUpdate = true;
    });

    try {
      print('DrawerContent - Initiating update flow for Password credential');
      final rdnaService = RdnaService.getInstance();
      final response = await rdnaService.initiateUpdateFlowForCredential('Password');

      print('DrawerContent - InitiateUpdateFlowForCredential response:');
      print('  Long Error Code: ${response.error?.longErrorCode}');

      if (response.error?.longErrorCode == 0) {
        print('DrawerContent - Update flow initiated successfully, waiting for getPassword event with challengeMode 2');
        // SDK will trigger getPassword event with challengeMode 2
        // SDKEventProvider will handle navigation to UpdatePasswordScreen
      } else {
        final errorMessage = response.error?.errorString ?? 'Failed to initiate update flow';
        print('DrawerContent - Update flow error: $errorMessage');
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Update Password Error'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (error) {
      print('DrawerContent - Update flow exception: $error');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update Password Error'),
            content: Text('Failed to initiate update flow: $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitiatingUpdate = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userID = widget.sessionData?.userId ?? 'Unknown User';

    // Watch available credentials to show/hide Update Password menu
    final availableCredentials = ref.watch(availableCredentialsProvider);
    final isPasswordUpdateAvailable = availableCredentials.contains('Password');

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFF3498DB), // #3498db
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            width: double.infinity,
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      userID.length >= 2
                          ? userID.substring(0, 2).toUpperCase()
                          : userID.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Username
                Text(
                  userID,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20),
              children: [
                _buildMenuItem(
                  context: context,
                  icon: '🏠',
                  title: 'Dashboard',
                  routeName: 'dashboardScreen',
                  isActive: widget.currentRoute == 'dashboardScreen',
                ),
                _buildMenuItem(
                  context: context,
                  icon: '🔔',
                  title: 'Get Notifications',
                  routeName: 'getNotificationsScreen',
                  isActive: widget.currentRoute == 'getNotificationsScreen',
                ),
                _buildMenuItem(
                  context: context,
                  icon: '📜',
                  title: 'Notification History',
                  routeName: 'notificationHistoryScreen',
                  isActive: widget.currentRoute == 'notificationHistoryScreen',
                ),
                _buildMenuItem(
                  context: context,
                  icon: '🔐',
                  title: 'Data Signing',
                  routeName: 'dataSigningInputScreen',
                  isActive: widget.currentRoute == 'dataSigningInputScreen',
                ),
                _buildDeviceManagementMenuItem(),
                _buildLDATogglingMenuItem(),

                // Conditional Update Password menu item
                if (isPasswordUpdateAvailable)
                  _buildUpdatePasswordMenuItem(),
              ],
            ),
          ),

          // Logout Button
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: InkWell(
              onTap: _isLoggingOut ? null : _handleLogout,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                child: _isLoggingOut
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFE74C3C),
                          ),
                        ),
                      )
                    : const Text(
                        '🚪 Log Off',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFE74C3C), // #e74c3c
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Device Management menu item
  Widget _buildDeviceManagementMenuItem() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      tileColor: widget.currentRoute == 'deviceManagementScreen' ? const Color(0xFFF0F0F0) : null,
      title: Text(
        '📱 Device Management',
        style: TextStyle(
          fontSize: 16,
          color: const Color(0xFF333333),
          fontWeight: widget.currentRoute == 'deviceManagementScreen' ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (widget.currentRoute != 'deviceManagementScreen') {
          // Navigate to Device Management screen with sessionData
          if (widget.sessionData != null) {
            context.goNamed('deviceManagementScreen', extra: widget.sessionData);
          }
        }
      },
    );
  }

  /// Build LDA Toggling menu item
  Widget _buildLDATogglingMenuItem() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      tileColor: widget.currentRoute == 'ldaTogglingScreen' ? const Color(0xFFF0F0F0) : null,
      title: Text(
        '🔐 LDA Toggling',
        style: TextStyle(
          fontSize: 16,
          color: const Color(0xFF333333),
          fontWeight: widget.currentRoute == 'ldaTogglingScreen' ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (widget.currentRoute != 'ldaTogglingScreen') {
          // Navigate to LDA toggling screen with session parameters
          final sessionData = widget.sessionData;
          if (sessionData != null) {
            final params = LDATogglingScreenParams(
              userID: sessionData.userId ?? '',
              sessionID: sessionData.challengeResponse?.session?.sessionId ?? '',
              sessionType: sessionData.challengeResponse?.session?.sessionType ?? 0,
              jwtToken: sessionData.challengeResponse?.additionalInfo?.jwtJsonTokenInfo ?? '',
              loginTime: null, // Not available in RDNAUserLoggedIn
              userRole: sessionData.challengeResponse?.additionalInfo?.idvUserRole,
              currentWorkFlow: sessionData.challengeResponse?.additionalInfo?.currentWorkFlow,
            );
            context.goNamed('ldaTogglingScreen', extra: params);
          }
        }
      },
    );
  }

  /// Build Update Password menu item with loading state
  Widget _buildUpdatePasswordMenuItem() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      title: Row(
        children: [
          Expanded(
            child: Text(
              '🔑 Update Password',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF333333),
                fontWeight: widget.currentRoute == 'updatePasswordScreen' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (_isInitiatingUpdate)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
              ),
            ),
        ],
      ),
      tileColor: widget.currentRoute == 'updatePasswordScreen' ? const Color(0xFFF0F0F0) : null,
      onTap: _isInitiatingUpdate ? null : () async {
        Navigator.pop(context); // Close drawer
        await _handleUpdatePassword();
      },
    );
  }

  /// Build a menu item
  Widget _buildMenuItem({
    required BuildContext context,
    required String icon,
    required String title,
    required String routeName,
    bool isActive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      tileColor: isActive ? const Color(0xFFF0F0F0) : null,
      title: Text(
        '$icon $title',
        style: TextStyle(
          fontSize: 16,
          color: const Color(0xFF333333),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (!isActive) {
          context.goNamed(routeName, extra: widget.sessionData);
        }
      },
    );
  }
}
