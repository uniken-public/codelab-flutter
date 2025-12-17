// ============================================================================
// File: device_management_screen.dart
// Description: Device Management Screen
//
// Displays all registered devices for the current user with pull-to-refresh functionality.
// Features cooling period banner, current device highlighting, and navigation to device details.
//
// Transformed from: DeviceManagementScreen.tsx
//
// Key Features:
// - Auto-load devices on screen mount
// - Pull-to-refresh functionality
// - Cooling period banner with countdown timer
// - Current device highlighting
// - Device list with friendly UI
// - Tap device to view details
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../../../uniken/services/rdna_service.dart';
import '../components/drawer_content.dart';

/// Device Management Screen
///
/// Displays all registered devices for the current user with pull-to-refresh functionality.
/// Features cooling period banner, current device highlighting, and navigation to device details.
class DeviceManagementScreen extends ConsumerStatefulWidget {
  final String? userID;
  final RDNAUserLoggedIn? sessionData;

  const DeviceManagementScreen({
    super.key,
    this.userID,
    this.sessionData,
  });

  @override
  ConsumerState<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends ConsumerState<DeviceManagementScreen> {
  final RdnaService _rdnaService = RdnaService.getInstance();

  List<RDNADeviceDetails> _devices = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  int? _coolingPeriodEndTimestamp;
  String _coolingPeriodMessage = '';
  bool _isCoolingPeriodActive = false;

  @override
  void initState() {
    super.initState();
    print('DeviceManagementScreen - Screen initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDevices();
    });
  }

  @override
  void dispose() {
    print('DeviceManagementScreen - Screen disposed, cleaning up event handlers');
    // Reset handler to prevent memory leaks
    _rdnaService.getEventManager().setGetRegisteredDeviceDetailsHandler(null);
    super.dispose();
  }

  /// Fetches registered device details from the SDK
  Future<void> _loadDevices() async {
    if (widget.userID == null || widget.userID!.isEmpty) {
      print('DeviceManagementScreen - No userID available');
      if (mounted) {
        _showError('User ID is required to load devices');
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
      return;
    }

    print('DeviceManagementScreen - Loading devices for user: ${widget.userID}');
    if (!_isRefreshing) {
      setState(() => _isLoading = true);
    }

    try {
      // Set up event handler for device details response
      final eventManager = _rdnaService.getEventManager();
      bool handlerCalled = false;

      // Set callback for this screen
      eventManager.setGetRegisteredDeviceDetailsHandler((RDNAStatusGetRegisteredDeviceDetails data) {
        if (handlerCalled) return; // Prevent double handling
        handlerCalled = true;

        print('DeviceManagementScreen - Received device details event');

        // Extract and parse device data
        final parsedResponse = data.pArgs?.response?.responseData?.response;
        final deviceResponse = parsedResponse is RDNAGetRegisteredDeviceDetailsResponse ? parsedResponse : null;
        final deviceList = deviceResponse?.device ?? [];

        print('DeviceManagementScreen - Device count: ${deviceList.length}');
        print('DeviceManagementScreen - Status code: ${data.pArgs?.response?.statusCode}');

        // Check for errors using data.errCode (sync error check, no try-catch)
        if (data.error?.longErrorCode != 0) {
          print('DeviceManagementScreen - API error: ${data.error?.longErrorCode}');
          if (mounted) {
            _showError(data.error?.errorString  ?? 'Failed to load devices. Please try again.');
            setState(() {
              _isLoading = false;
              _isRefreshing = false;
            });
          }
          return;
        }

        // Extract additional data
        final coolingPeriodEnd = deviceResponse?.deviceManagementCoolingPeriodEndTimestamp;
        final statusCode = data.pArgs?.response?.statusCode ?? 0;
        final statusMsg = data.pArgs?.response?.statusMsg ?? '';

        print('DeviceManagementScreen - Device list: $deviceList');
        print('DeviceManagementScreen - Cooling period end: $coolingPeriodEnd');

        if (mounted) {
          setState(() {
            _devices = deviceList;
            _coolingPeriodEndTimestamp = coolingPeriodEnd;
            _coolingPeriodMessage = statusMsg;
            _isCoolingPeriodActive = statusCode == 146;
            _isLoading = false;
            _isRefreshing = false;
          });
        }

        print('DeviceManagementScreen - Devices loaded successfully');
      });

      // Call the API with userID (check sync error, no try-catch)
      final response = await _rdnaService.getRegisteredDeviceDetails(widget.userID!);

      // Check sync response error
      if (response.error?.longErrorCode != 0) {
        print('DeviceManagementScreen - API call failed: ${response.error?.errorString}');
        if (mounted) {
          _showError(response.error?.errorString ?? 'Failed to load devices');
          setState(() {
            _isLoading = false;
            _isRefreshing = false;
          });
        }
      }
    } catch (error) {
      print('DeviceManagementScreen - Unexpected error: $error');
      if (mounted) {
        _showError('Failed to load devices. Please try again.');
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  /// Handles pull-to-refresh action
  Future<void> _onRefresh() async {
    print('DeviceManagementScreen - Pull to refresh triggered');
    setState(() => _isRefreshing = true);
    await _loadDevices();
  }

  /// Handles device item tap
  void _handleDeviceTap(RDNADeviceDetails device) async {
    print('DeviceManagementScreen - Device tapped: ${device.devUuid}');

    // Navigate to DeviceDetailScreen and wait for result
    final result = await context.push('/device-detail', extra: {
      'device': device,
      'userID': widget.userID,
      'isCoolingPeriodActive': _isCoolingPeriodActive,
      'coolingPeriodEndTimestamp': _coolingPeriodEndTimestamp,
      'coolingPeriodMessage': _coolingPeriodMessage,
    });

    // Reload devices when returning from detail screen (in case of rename/delete)
    if (result == true || result == 'refresh') {
      print('DeviceManagementScreen - Reloading devices after detail screen return');
      _loadDevices();
    }
  }

  /// Formats timestamp to readable date string
  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM d, y, hh:mm a').format(date);
  }

  /// Shows error message
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Renders individual device item
  Widget _renderDeviceItem(RDNADeviceDetails device) {
    final isCurrentDevice = device.currentDevice ?? false;
    final isActive = device.status == 'ACTIVE';

    return GestureDetector(
      onTap: () => _handleDeviceTap(device),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isCurrentDevice ? const Color(0xFFF1F8F4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentDevice ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
            width: isCurrentDevice ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Device Badge
              if (isCurrentDevice)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Current Device',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Device Name
              Padding(
                padding: EdgeInsets.only(right: isCurrentDevice ? 100 : 0),
                child: Text(
                  device.devName ?? 'Unknown Device',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),

              // Device Status
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    device.status ?? 'UNKNOWN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Device Details
              _buildDetailRow('Last Accessed:', _formatDate(device.lastAccessedTsEpoch ?? 0)),
              const SizedBox(height: 6),
              _buildDetailRow('Created:', _formatDate(device.createdTsEpoch ?? 0)),
              const SizedBox(height: 12),

              // Tap Indicator
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tap for details →',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF007AFF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds detail row
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7F8C8D),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Renders cooling period banner
  Widget? _renderCoolingPeriodBanner() {
    if (!_isCoolingPeriodActive) {
      return null;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Color(0xFFFF9800), width: 4),
        ),
      ),
      child: Row(
        children: [
          const Text(
            '⏳',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cooling Period Active',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF856404),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _coolingPeriodMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF856404),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: DrawerContent(
        sessionData: widget.sessionData,
        currentRoute: 'deviceManagementScreen',
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
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
            );
          },
        ),
        title: const Text(
          'Device Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
      ),
      body: Column(
        children: [
          // Cooling Period Banner
          if (_renderCoolingPeriodBanner() != null)
            _renderCoolingPeriodBanner()!,

          // Main Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF007AFF),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading devices...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: const Color(0xFF007AFF),
                    child: _devices.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 60),
                              child: Text(
                                'No devices found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _devices.length,
                            itemBuilder: (context, index) {
                              return _renderDeviceItem(_devices[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
