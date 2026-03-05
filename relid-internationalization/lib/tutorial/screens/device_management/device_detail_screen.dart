// ============================================================================
// File: device_detail_screen.dart
// Description: Device Detail Screen
//
// Displays detailed information about a selected device.
// Shows device metadata, status, and action buttons (rename/delete).
//
// Transformed from: DeviceDetailScreen.tsx
//
// Key Features:
// - Complete device information display
// - Current device indicator
// - Status display
// - Cooling period awareness
// - Action buttons (disabled during cooling period)
// - Rename device dialog
// - Delete device confirmation
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../../../uniken/services/rdna_service.dart';
import 'rename_device_dialog.dart';

/// Device Detail Screen
///
/// Displays detailed information about a selected device.
/// Shows device metadata, status, and action buttons (rename/delete).
class DeviceDetailScreen extends StatefulWidget {
  final RDNADeviceDetails device;
  final String? userID;
  final bool isCoolingPeriodActive;
  final int? coolingPeriodEndTimestamp;
  final String coolingPeriodMessage;

  const DeviceDetailScreen({
    super.key,
    required this.device,
    required this.userID,
    required this.isCoolingPeriodActive,
    this.coolingPeriodEndTimestamp,
    required this.coolingPeriodMessage,
  });

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  final RdnaService _rdnaService = RdnaService.getInstance();

  bool _isRenaming = false;
  bool _isDeleting = false;
  late String _currentDeviceName;

  @override
  void initState() {
    super.initState();
    _currentDeviceName = widget.device.devName ?? '';
  }

  @override
  void dispose() {
    print('DeviceDetailScreen - Component disposing, cleaning up event handlers');
    // Reset handler to prevent memory leaks
    _rdnaService.getEventManager().setUpdateDeviceDetailsHandler(null);
    super.dispose();
  }

  /// Unified method to handle device update operations (rename/delete)
  Future<void> _updateDevice({
    required String newName,
    required int operationType, // 0 = rename, 1 = delete
  }) async {
    final isRename = operationType == 0;
    final operation = isRename ? 'rename' : 'delete';

    if (isRename) {
      setState(() => _isRenaming = true);
    } else {
      setState(() => _isDeleting = true);
    }

    try {
      print('DeviceDetailScreen - $operation device: ${widget.device.devUuid}');

      final eventManager = _rdnaService.getEventManager();
      bool handlerCalled = false;

      // Set callback for this operation
      eventManager.setUpdateDeviceDetailsHandler((RDNAStatusUpdateDeviceDetails data) {
        if (handlerCalled) return; // Prevent double handling
        handlerCalled = true;

        print('DeviceDetailScreen - Received update device details event');

        // Check sync error (no try-catch)
        if (data.error?.longErrorCode != 0) {
          print('DeviceDetailScreen - $operation error: ${data.error?.longErrorCode}');
          if (mounted) {
            _showError(data.error?.errorString ?? 'Failed to $operation device. Please try again.');
            setState(() {
              if (isRename) {
                _isRenaming = false;
              } else {
                _isDeleting = false;
              }
            });
          }
          return;
        }

        final statusCode = data.pArgs?.response?.statusCode ?? 0;
        final statusMsg = data.pArgs?.response?.statusMsg ?? '';

        if (statusCode == 100) {
          print('DeviceDetailScreen - $operation successful');
          if (mounted) {
            if (isRename) {
              // Rename success
              setState(() {
                _currentDeviceName = newName;
                _isRenaming = false;
              });
              _showSuccess('Device renamed successfully');

              // Navigate back to device list after success
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  Navigator.of(context).pop(true); // Return true to trigger refresh
                }
              });
            } else {
              // Delete success
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Success'),
                    content: const Text('Device deleted successfully'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(true); // Go back to device list with refresh signal
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
              setState(() => _isDeleting = false);
            }
          }
        } else if (statusCode == 146) {
          if (mounted) {
            _showError('Device management is currently in cooling period. Please try again later.');
            setState(() {
              if (isRename) {
                _isRenaming = false;
              } else {
                _isDeleting = false;
              }
            });
          }
        } else {
          if (mounted) {
            _showError(statusMsg.isNotEmpty ? statusMsg : 'Failed to $operation device');
            setState(() {
              if (isRename) {
                _isRenaming = false;
              } else {
                _isDeleting = false;
              }
            });
          }
        }
      });

      // Call the API (check sync error, no try-catch)
      final response = await _rdnaService.updateDeviceDetails(
        widget.userID!,
        widget.device,
        newName,
        operationType,
      );

      // Check sync response error
      if (response.error?.longErrorCode != 0) {
        print('DeviceDetailScreen - $operation API call failed: ${response.error?.errorString}');
        if (mounted) {
          _showError(response.error?.errorString ?? 'Failed to $operation device');
          setState(() {
            if (isRename) {
              _isRenaming = false;
            } else {
              _isDeleting = false;
            }
          });
        }
      }
    } catch (error) {
      print('DeviceDetailScreen - $operation unexpected error: $error');
      if (mounted) {
        _showError('Failed to $operation device. Please try again.');
        setState(() {
          if (isRename) {
            _isRenaming = false;
          } else {
            _isDeleting = false;
          }
        });
      }
    }
  }

  /// Formats timestamp to readable date string
  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('EEE, MMMM d, y, hh:mm:ss a').format(date);
  }

  /// Formats timestamp to relative time (e.g., "2 hours ago")
  String _formatRelativeTime(int timestamp) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - timestamp;
    final seconds = (diff / 1000).floor();
    final minutes = (seconds / 60).floor();
    final hours = (minutes / 60).floor();
    final days = (hours / 24).floor();

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} ago';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} ago';
    } else if (minutes > 0) {
      return '$minutes minute${minutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Renders info row
  Widget _renderInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 13 : 15,
              color: highlight ? const Color(0xFF007AFF) : const Color(0xFF2C3E50),
              fontWeight: FontWeight.w500,
              fontStyle: highlight ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Handles rename device action
  Future<void> _handleRenameDevice(String newName) async {
    await _updateDevice(newName: newName, operationType: 0);
  }

  /// Handles delete device action
  void _handleDeleteDevice() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Device'),
          content: Text('Are you sure you want to delete "$_currentDeviceName"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performDeleteDevice();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDeleteDevice() async {
    await _updateDevice(newName: '', operationType: 1);
  }

  /// Shows success message
  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final isCurrentDevice = widget.device.currentDevice ?? false;
    final isActive = widget.device.status == 'ACTIVE';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '←',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Device Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Device Banner
            if (isCurrentDevice)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(
                    left: BorderSide(color: Color(0xFF4CAF50), width: 4),
                  ),
                ),
                child: const Row(
                  children: [
                    Text('📱', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is your current device',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Device Name Card
            Container(
              margin: EdgeInsets.fromLTRB(16, isCurrentDevice ? 8 : 16, 16, 8),
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
                  const Text(
                    'DEVICE INFORMATION',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7F8C8D),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentDeviceName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.device.status ?? 'UNKNOWN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Device Details Card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                  const Text(
                    'DETAILS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7F8C8D),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _renderInfoRow('Device UUID', widget.device.devUuid ?? 'N/A'),
                  _renderInfoRow('Last Accessed', _formatDate(widget.device.lastAccessedTsEpoch ?? 0)),
                  _renderInfoRow('Last Accessed (Relative)', _formatRelativeTime(widget.device.lastAccessedTsEpoch ?? 0), highlight: true),
                  const Divider(height: 24, color: Color(0xFFE0E0E0)),
                  _renderInfoRow('Created', _formatDate(widget.device.createdTsEpoch ?? 0)),
                ],
              ),
            ),

            // Cooling Period Warning
            if (widget.isCoolingPeriodActive)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                    const Text('⚠️', style: TextStyle(fontSize: 24)),
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
                            widget.coolingPeriodMessage,
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
              ),

            // Actions Card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                  const Text(
                    'ACTIONS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7F8C8D),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rename Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (widget.isCoolingPeriodActive || _isRenaming || _isDeleting)
                          ? null
                          : () async {
                              final newName = await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) {
                                  return RenameDeviceDialog(
                                    currentName: _currentDeviceName,
                                  );
                                },
                              );

                              if (newName != null && newName.isNotEmpty && newName != _currentDeviceName) {
                                _handleRenameDevice(newName);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isCoolingPeriodActive ? const Color(0xFFE0E0E0) : const Color(0xFF007AFF),
                        disabledBackgroundColor: const Color(0xFFE0E0E0),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isRenaming
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Rename Device',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Delete Button
                  if (!isCurrentDevice)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (widget.isCoolingPeriodActive || _isRenaming || _isDeleting)
                            ? null
                            : _handleDeleteDevice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.isCoolingPeriodActive ? const Color(0xFFE0E0E0) : const Color(0xFFF44336),
                          disabledBackgroundColor: const Color(0xFFE0E0E0),
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isDeleting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Delete Device',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),

            // Info Message
            if (!isCurrentDevice)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'You can rename any device. Only non-current devices can be deleted.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1976D2),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

}
