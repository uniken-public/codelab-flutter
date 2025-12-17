// ============================================================================
// File: get_notifications_screen.dart
// Description: Get Notifications Screen
//
// Displays notifications retrieved from the REL-ID SDK with the following features:
// - Automatically loads notifications on screen mount
// - Displays notifications in a sorted list (latest first)
// - Shows empty state when no notifications are available
// - Provides notification selection with action UI
// - Handles both notification present and empty response formats
//
// Key Features:
// - Automatic getNotifications API call on screen load
// - Real-time event handling for onGetNotifications
// - Notification list with sorting and selection
// - Action modal for notification actions (Approve/Reject)
// - Error handling and loading states
//
// Transformed from: React Native GetNotificationsScreen.tsx
// ============================================================================

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../../../uniken/providers/sdk_event_provider.dart';
import '../components/drawer_content.dart';

/// Get Notifications Screen
///
/// Displays and manages REL-ID SDK notifications.
/// Used on PRIMARY device to approve new device activation requests.
///
/// ## Route Parameters (session data)
/// - userID: User identifier
/// - sessionID: Current session ID
/// - jwtToken: JWT authentication token
///
/// ## Flow
/// 1. Screen loads → Auto-calls getNotifications()
/// 2. SDK triggers onGetNotifications event → Display list
/// 3. User taps notification → Show action modal
/// 4. User selects action (Approve/Reject) → Call updateNotification()
/// 5. SDK triggers onUpdateNotification → Refresh list
class GetNotificationsScreen extends ConsumerStatefulWidget {
  final RDNAUserLoggedIn? sessionData;

  const GetNotificationsScreen({
    super.key,
    this.sessionData,
  });

  @override
  ConsumerState<GetNotificationsScreen> createState() =>
      _GetNotificationsScreenState();
}

class _GetNotificationsScreenState
    extends ConsumerState<GetNotificationsScreen> {
  bool _isLoading = true;
  List<RDNANotification> _notifications = [];
  RDNANotification? _selectedNotification;
  bool _showActionModal = false;
  String? _error;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _setupEventHandlers();
    _loadNotifications();
  }

  @override
  void dispose() {
    _cleanupEventHandlers();
    super.dispose();
  }

  /// Set up event handlers for notification events
  void _setupEventHandlers() {
    final rdnaService = ref.read(rdnaServiceProvider);
    final eventManager = rdnaService.getEventManager();

    eventManager.setGetNotificationsHandler(_handleNotificationsReceived);
    eventManager.setUpdateNotificationHandler(_handleUpdateNotificationReceived);
  }

  /// Cleanup event handlers
  void _cleanupEventHandlers() {
    final rdnaService = ref.read(rdnaServiceProvider);
    final eventManager = rdnaService.getEventManager();

    eventManager.setGetNotificationsHandler(null);
    eventManager.setUpdateNotificationHandler(null);
  }

  /// Load notifications from the SDK
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    print('GetNotificationsScreen - Calling getNotifications API');
    final rdnaService = ref.read(rdnaServiceProvider);
    final syncResponse = await rdnaService.getNotifications();

    print('GetNotificationsScreen - GetNotifications sync response received');
    print('  Long Error Code: ${syncResponse.error?.longErrorCode}');

    if (syncResponse.error?.longErrorCode == 0) {
      // Success - event will trigger _handleNotificationsReceived
      print('GetNotificationsScreen - getNotifications API call successful');
    } else {
      // Error
      final errorMessage = syncResponse.error?.errorString ?? 'Failed to load notifications';
      print('GetNotificationsScreen - getNotifications error: $errorMessage');
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  /// Handle notifications received from onGetNotifications event
  void _handleNotificationsReceived(RDNAStatusGetNotifications data) {
    print('GetNotificationsScreen - Received notifications event');

    // Check for errors first
    if (data.error != null && data.error?.longErrorCode != 0) {
      final errorMessage = data.error?.errorString ?? 'Failed to load notifications';
      print('GetNotificationsScreen - Notifications error:');
      print('  Error Code: ${data.error?.longErrorCode}');
      print('  Error: ${data.error?.errorString}');

      setState(() {
        _error = errorMessage;
        _isLoading = false;
        _notifications = [];
      });
      return;
    }

    // Check status code
    final statusCode = data.pArgs?.response?.statusCode;
    if (statusCode != null && statusCode != 100) {
      final statusMessage = data.pArgs?.response?.statusMsg ?? 'Unknown status error';
      print('GetNotificationsScreen - Notifications status error:');
      print('  Status Code: $statusCode');
      print('  Status Message: $statusMessage');

      setState(() {
        _error = statusMessage;
        _isLoading = false;
        _notifications = [];
      });
      return;
    }

    // Extract notifications from response
    final response = data.pArgs?.response?.responseData?.response;
    if (response is RDNAGetNotificationsResponse) {
      final notificationList = response.notifications ?? [];
      print('GetNotificationsScreen - Received ${notificationList.length} notifications');

      setState(() {
        _notifications = notificationList;
        _isLoading = false;
        _error = null;
      });
    } else {
      print('GetNotificationsScreen - Unknown response format');
      setState(() {
        _notifications = [];
        _isLoading = false;
        _error = 'Unknown response format';
      });
    }
  }

  /// Handle update notification response from onUpdateNotification event
  void _handleUpdateNotificationReceived(RDNAStatusUpdateNotification data) {
    print('GetNotificationsScreen - Received update notification event');

    setState(() {
      _actionLoading = false;
    });

    // Check for errors first
    if (data.error != null && data.error?.longErrorCode != 0)  {
      final errorMessage = data.error?.errorString ?? 'Failed to update notification';
      print('GetNotificationsScreen - Update notification error:');
      print('  Error Code: ${data.error?.longErrorCode}');
      print('  Error: ${data.error?.errorString}');
      print('  Status Code: ${data.pArgs?.response?.statusCode}');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update Failed'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () =>  Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Check response status code
    final responseData = data.pArgs?.response;
    final statusCode = responseData?.statusCode;

    if (statusCode == 100) {
      // Success
      final response = responseData?.responseData?.response;
      if (response is RDNAUpdateNotificationResponse) {
        final notificationUuid = response.notificationUuid;
        final message = response.message ?? responseData?.statusMsg ?? 'Notification updated successfully';

        print('GetNotificationsScreen - Update notification success:');
        print('  Notification UUID: $notificationUuid');
        print('  Message: $message');

        setState(() {
          _showActionModal = false;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Reload notifications
        _loadNotifications();
      }
    } else {
      // Status error
      final statusMessage = responseData?.statusMsg ?? 'Unknown error occurred';
      print('GetNotificationsScreen - Update notification status error:');
      print('  Status Code: $statusCode');
      print('  Status Message: $statusMessage');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update Failed'),
            content: Text(statusMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the error dialog
                  setState(() {
                    _showActionModal = false;
                  });
                  _loadNotifications();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Sort notifications by timestamp (latest first)
  List<RDNANotification> get _sortedNotifications {
    final sorted = List<RDNANotification>.from(_notifications);
    sorted.sort((a, b) => (b.createTsEpoch ?? 0).compareTo(a.createTsEpoch ?? 0));
    return sorted;
  }

  /// Format epoch timestamp to match React Native's toLocaleString() format
  /// Input: Epoch time in milliseconds (int)
  /// Output: "12/11/2025, 5:30:00 PM"
  String _formatTimestamp(int? epochTime) {
    if (epochTime == null || epochTime == 0) return 'N/A';

    try {
      // Convert epoch milliseconds to DateTime
      final dateTime = DateTime.fromMillisecondsSinceEpoch(epochTime).toLocal();

      // Format to match JavaScript's toLocaleString()
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      final year = dateTime.year;

      // Convert to 12-hour format
      final hour = dateTime.hour == 0
          ? 12
          : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final second = dateTime.second.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';

      return '$month/$day/$year, $hour:$minute:$second $period';
    } catch (e) {
      print('Error formatting timestamp: $e');
      return 'Invalid Date';
    }
  }

  /// Handle notification selection
  void _handleNotificationSelect(RDNANotification notification) {
    setState(() {
      _selectedNotification = notification;
      _showActionModal = true;
    });
  }

  /// Handle action selection
  Future<void> _handleActionPress(RDNAExpectedResponse action) async {
    if (_actionLoading || _selectedNotification == null) {
      return;
    }

    print('GetNotificationsScreen - Action pressed: ${action.action} for notification: ${_selectedNotification!.notificationUuid}');

    setState(() {
      _actionLoading = true;
    });

    print('GetNotificationsScreen - Calling updateNotification API');
    final rdnaService = ref.read(rdnaServiceProvider);
    final syncResponse = await rdnaService.updateNotification(
      _selectedNotification!.notificationUuid ?? '',
      action.action ?? '',
    );

    print('GetNotificationsScreen - UpdateNotification sync response received');
    print('  Long Error Code: ${syncResponse.error?.longErrorCode}');

    if (syncResponse.error?.longErrorCode == 0) {
      // Success - event will trigger _handleUpdateNotificationReceived
      print('GetNotificationsScreen - UpdateNotification API call successful');
    } else {
      // Error
      final errorMessage = syncResponse.error?.errorString ?? 'Failed to process action';
      print('GetNotificationsScreen - UpdateNotification error: $errorMessage');
      setState(() {
        _actionLoading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update Failed'),
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
  }

  /// Build main body
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF3498DB)),
            SizedBox(height: 16),
            Text(
              'Loading notifications...',
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
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFE74C3C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_sortedNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sortedNotifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationItem(_sortedNotifications[index]);
      },
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📭', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You don\'t have any notifications at the moment.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7F8C8D),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '🔄 Refresh',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build notification item
  Widget _buildNotificationItem(RDNANotification notification) {
    final body = notification.body?.isNotEmpty == true ? notification.body!.first : null;
    final subject = body?.subject ?? 'No Subject';
    final message = body?.message ?? 'No Message';
    final actionCount = notification.actions?.length ?? 0;
    final actionPerformed = notification.actionPerformed ?? 'Pending';

    return InkWell(
      onTap: () => _handleNotificationSelect(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTimestamp(notification.createTsEpoch),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF34495E),
                height: 1.43,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$actionCount action${actionCount != 1 ? 's' : ''} available',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3498DB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  actionPerformed,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF95A5A6),
                  ),
                ),
              ],
            ),

            // Expiry timestamp
            if (notification.expiryTimestampEpoch != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Expires: ${_formatTimestamp(notification.expiryTimestampEpoch)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFE67E22),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build action modal
  Widget _buildActionModal() {
    if (!_showActionModal || _selectedNotification == null) {
      return const SizedBox.shrink();
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      alignment: Alignment.bottomCenter,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          color: Colors.white.withOpacity(0.1), // Light overlay
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notification Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _showActionModal = false),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          '✕',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2C3E50),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Modal Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification Details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedNotification!.body?.isNotEmpty == true
                                ? _selectedNotification!.body!.first.subject ?? 'No Subject'
                                : 'No Subject',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedNotification!.body?.isNotEmpty == true
                                ? _selectedNotification!.body!.first.message ?? 'No Message'
                                : 'No Message',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF34495E),
                              height: 1.43,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Created: ${_formatTimestamp(_selectedNotification!.createTsEpoch)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                          if (_selectedNotification!.expiryTimestampEpoch != null)
                            Text(
                              'Expires: ${_formatTimestamp(_selectedNotification!.expiryTimestampEpoch)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${_selectedNotification!.notificationUuid ?? ''}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF95A5A6),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    const SizedBox(height: 24),
                    ..._buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
        ),
      ),
    );
  }

  /// Build action buttons
  List<Widget> _buildActionButtons() {
    if (_selectedNotification?.actions == null) {
      return [];
    }

    return _selectedNotification!.actions!.map((action) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _actionLoading ? null : () => _handleActionPress(action),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3498DB),
            disabledBackgroundColor: const Color(0xFF95A5A6).withOpacity(0.6),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _actionLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  action.label ?? action.action ?? 'Action',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            leading: Builder(
              builder: (context) => IconButton(
                icon: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Center(
                    child: Text(
                      '☰',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF2C3E50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: const Text(
              'Notifications',
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
                  child: const Center(
                    child: Text('🔄', style: TextStyle(fontSize: 18)),
                  ),
                ),
                onPressed: _loadNotifications,
              ),
            ],
          ),
          drawer: DrawerContent(
            sessionData: widget.sessionData,
            currentRoute: 'getNotificationsScreen',
          ),
          body: _buildBody(),
        ),

        // Action Modal Overlay
        if (_showActionModal) _buildActionModal(),
      ],
    );
  }
}
