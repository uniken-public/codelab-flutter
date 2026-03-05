// ============================================================================
// File: notification_history_screen.dart
// Description: Notification History Screen
//
// Displays historical notifications (completed, expired, or discarded) with
// filtering options. Provides list view, pull-to-refresh, and detail modal.
//
// Transformed from: NotificationHistoryScreen.tsx
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import 'package:intl/intl.dart';
import '../../navigation/app_router.dart';
import '../../../uniken/services/rdna_service.dart';
import '../components/drawer_content.dart';

/// Notification History Screen
///
/// Displays historical notifications with filtering and detail view.
///
/// ## Features
/// - History list with status and action badges
/// - Pull-to-refresh
/// - Detail modal with full notification information
/// - Epoch timestamp to local time conversion
/// - Color-coded status and actions
///
/// ## SDK Integration
/// - Calls: getNotificationHistory() with 9 filter parameters
/// - Events: onGetNotificationsHistory (RDNAStatusGetNotificationHistory)
class NotificationHistoryScreen extends ConsumerStatefulWidget {
  final RDNAUserLoggedIn? userParams;

  const NotificationHistoryScreen({super.key, this.userParams});

  @override
  ConsumerState<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState
    extends ConsumerState<NotificationHistoryScreen> {
  List<RDNANotificationHistory> _historyItems = [];
  bool _loading = false;
  bool _refreshing = false;
  RDNANotificationHistory? _selectedItem;

  @override
  void initState() {
    super.initState();
    // Load history on mount and setup event handler
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotificationHistory();
      _setupEventHandler();
    });
  }

  @override
  void dispose() {
    // Restore original handler on cleanup
    final eventManager = RdnaService.getInstance().getEventManager();
    eventManager.setGetNotificationHistoryHandler(null);
    super.dispose();
  }

  /// Setup event handler for notification history response
  void _setupEventHandler() {
    final eventManager = RdnaService.getInstance().getEventManager();

    eventManager.setGetNotificationHistoryHandler((data) {
      _handleNotificationHistoryResponse(data);
    });
  }

  /// Load notification history from the server
  Future<void> _loadNotificationHistory() async {
    if (_loading) return;

    setState(() {
      _loading = true;
    });

    print('NotificationHistoryScreen - Loading notification history');

    // Call getNotificationHistory API (NO try-catch, check response.error)
    final response = await RdnaService.getInstance().getNotificationHistory(
      recordCount: 10,
      startIndex: 1,
      enterpriseID: '',
      startDate: '',
      endDate: '',
      notificationStatus: '',
      actionPerformed: '',
      keywordSearch: '',
      deviceID: '',
    );

    print('NotificationHistoryScreen - GetNotificationHistory sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Error String: ${response.error?.errorString}');

    // Check sync response error
    if (response.error?.longErrorCode == 0) {
      print('NotificationHistoryScreen - Sync success, waiting for onGetNotificationsHistory event');
      // Event handler will receive async response and update UI
    } else {
      // Sync error - stop loading and show error
      final errorMsg = response.error?.errorString ?? 'Failed to load notification history';
      print('NotificationHistoryScreen - Sync error: $errorMsg');

      setState(() {
        _loading = false;
      });

      if (mounted) {
        _showErrorDialog(errorMsg);
      }
    }
  }

  /// Handle notification history response from the SDK
  void _handleNotificationHistoryResponse(RDNAStatusGetNotificationHistory data) {
    print('NotificationHistoryScreen - Received notification history response');
    setState(() {
      _loading = false;
      _refreshing = false;
    });

    try {
      // First check error.longErrorCode (standard Flutter SDK pattern)
      if (data.error?.longErrorCode == 0) {
        // Success - now check if response data exists
        if (data.pArgs?.response?.responseData?.response != null) {
          final responseData = data.pArgs!.response!.responseData!.response as RDNAGetNotificationHistoryResponse?;

          if (responseData?.history != null) {
            final history = responseData!.history!;
            print('NotificationHistoryScreen - Loaded ${history.length} history items');

            // Sort by update timestamp (most recent first)
            // Note: updateTsEpoch can be 0 (not set), so check for both null and 0
            history.sort((a, b) {
              final aTime = (a.updateTsEpoch != null && a.updateTsEpoch! > 0)
                  ? a.updateTsEpoch!
                  : (a.createTsEpoch ?? 0);
              final bTime = (b.updateTsEpoch != null && b.updateTsEpoch! > 0)
                  ? b.updateTsEpoch!
                  : (b.createTsEpoch ?? 0);
              return bTime.compareTo(aTime);
            });

            setState(() {
              _historyItems = history;
            });
          } else {
            // No history data in response
            setState(() {
              _historyItems = [];
            });
          }
        } else {
          // Response structure is null
          print('NotificationHistoryScreen - Response data is null');
          setState(() {
            _historyItems = [];
          });
        }
      } else {
        // Error occurred
        final errorMsg = data.error?.errorString ?? 'Unknown error occurred';
        print('NotificationHistoryScreen - API error: $errorMsg');
        print('NotificationHistoryScreen - Error code: ${data.error?.longErrorCode}');
        _showErrorDialog(errorMsg);
        setState(() {
          _historyItems = [];
        });
      }
    } catch (error) {
      print('NotificationHistoryScreen - Error parsing response: $error');
      _showErrorDialog('Failed to parse notification history response');
      setState(() {
        _historyItems = [];
      });
    }
  }

  /// Handle pull-to-refresh
  Future<void> _onRefresh() async {
    setState(() {
      _refreshing = true;
    });
    await _loadNotificationHistory();
  }

  /// Format timestamp to user-friendly format
  String _formatTimestamp(int? epoch) {
    try {
      if (epoch == null || epoch == 0) return 'Unknown';

      // Use epoch directly as milliseconds
      final date = DateTime.fromMillisecondsSinceEpoch(epoch);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays <= 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (error) {
      return 'Unknown';
    }
  }

  /// Convert epoch timestamp to local time string
  String _convertEpochToLocal(int? epoch) {
    try {
      if (epoch == null || epoch == 0) return 'Not available';

      // Use epoch directly as milliseconds
      final date = DateTime.fromMillisecondsSinceEpoch(epoch);
      return DateFormat('MMM dd, yyyy hh:mm a').format(date);
    } catch (error) {
      return 'Not available';
    }
  }

  /// Get color for status
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.blue;

    switch (status.toUpperCase()) {
      case 'UPDATED':
      case 'ACCEPTED':
        return const Color(0xFF4CAF50); // Green
      case 'REJECTED':
      case 'DISCARDED':
        return const Color(0xFFF44336); // Red
      case 'EXPIRED':
        return const Color(0xFFFF9800); // Orange
      case 'DISMISSED':
        return const Color(0xFF9E9E9E); // Gray
      default:
        return const Color(0xFF2196F3); // Blue
    }
  }

  /// Get color for action performed
  Color _getActionColor(String? action) {
    if (action == null || action == 'NONE') return const Color(0xFF9E9E9E);

    final lowerAction = action.toLowerCase();
    if (lowerAction.contains('accept') || lowerAction.contains('approve')) {
      return const Color(0xFF4CAF50); // Green
    }
    if (lowerAction.contains('reject') || lowerAction.contains('deny')) {
      return const Color(0xFFF44336); // Red
    }
    return const Color(0xFF2196F3); // Blue
  }

  /// Handle item tap to show details
  void _handleItemPress(RDNANotificationHistory item) {
    setState(() {
      _selectedItem = item;
    });
    _showDetailModal(item);
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show detail modal
  void _showDetailModal(RDNANotificationHistory item) {
    final body = item.body?.isNotEmpty == true ? item.body![0] : null;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F8F8),
                  border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
                ),
                child: const Center(
                  child: Text(
                    'Notification Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),

              // Modal Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject
                      Text(
                        body?.subject ?? 'No Subject',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Message
                      Text(
                        (body?.message ?? 'No message available').replaceAll('\\n', '\n'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF555555),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Status
                      _buildDetailRow(
                        'Status:',
                        item.status ?? 'Unknown',
                        color: _getStatusColor(item.status),
                      ),

                      // Action Performed
                      _buildDetailRow(
                        'Action Performed:',
                        item.actionPerformed ?? 'NONE',
                        color: _getActionColor(item.actionPerformed),
                      ),

                      // Created
                      _buildDetailRow(
                        'Created:',
                        _convertEpochToLocal(item.createTsEpoch),
                      ),

                      // Updated (if available and not 0)
                      if (item.updateTsEpoch != null && item.updateTsEpoch! > 0)
                        _buildDetailRow(
                          'Updated:',
                          _convertEpochToLocal(item.updateTsEpoch),
                        ),

                      // Expiry
                      _buildDetailRow(
                        'Expiry:',
                        _convertEpochToLocal(item.expiryTimestampEpoch),
                      ),

                      // Signing Status (if available)
                      if (item.signingStatus != null && item.signingStatus!.isNotEmpty)
                        _buildDetailRow(
                          'Signing Status:',
                          item.signingStatus!,
                        ),
                    ],
                  ),
                ),
              ),

              // Modal Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F8F8),
                  border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C757D),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build detail row widget
  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color ?? const Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Render individual history item
  Widget _buildHistoryItem(RDNANotificationHistory item) {
    final body = item.body?.isNotEmpty == true ? item.body![0] : null;
    final subject = body?.subject ?? 'No Subject';
    final message = (body?.message ?? 'No message available').replaceAll('\\n', ' ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _handleItemPress(item),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _formatTimestamp(
                      (item.updateTsEpoch != null && item.updateTsEpoch! > 0)
                          ? item.updateTsEpoch
                          : item.createTsEpoch
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // Item Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(item.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.status ?? 'UNKNOWN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Action
                  Row(
                    children: [
                      const Text(
                        'Action: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      Text(
                        item.actionPerformed ?? 'NONE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getActionColor(item.actionPerformed),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: DrawerContent(
        sessionData: widget.userParams,
        currentRoute: 'notificationHistoryScreen',
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        foregroundColor: const Color(0xFF2C3E50),
        title: const Text(
          '📜 Notification History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF007AFF),
        child: _loading && !_refreshing
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading notification history...',
                      style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                    ),
                  ],
                ),
              )
            : _historyItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No notification history found',
                          style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadNotificationHistory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007AFF),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
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
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _historyItems.length,
                    itemBuilder: (context, index) => _buildHistoryItem(_historyItems[index]),
                  ),
      ),
    );
  }
}
