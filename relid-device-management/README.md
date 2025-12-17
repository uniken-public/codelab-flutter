# REL-ID Flutter Codelab: Device Management

[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-blue.svg)](https://flutter.dev/)
[![REL-ID SDK](https://img.shields.io/badge/REL--ID%20SDK-Latest-green.svg)](https://developer.uniken.com/)
[![Device Management](https://img.shields.io/badge/Device%20Management-Enabled-orange.svg)]()
[![Real-time Sync](https://img.shields.io/badge/Real--time%20Sync-Pull%20to%20Refresh-purple.svg)]()
[![Cooling Period](https://img.shields.io/badge/Cooling%20Period-Server%20Enforced-red.svg)]()

> **Codelab Advanced:** Master multi-device management with REL-ID SDK server synchronization and cooling period enforcement

This folder contains the source code for the solution demonstrating [REL-ID Device Management](https://codelab.uniken.com/codelabs/flutter-device-management-flow/index.html?index=..%2F..index#0) with comprehensive device lifecycle management, real-time synchronization, and server-enforced cooling periods.

## 🔐 What You'll Learn

In this advanced device management codelab, you'll master production-ready device management patterns:

- ✅ **Device Listing API**: `getRegisteredDeviceDetails()` with cooling period detection
- ✅ **Device Update Operations**: Rename and delete with `updateDeviceDetails()` API
- ✅ **Cooling Period Management**: Server-enforced cooling periods between operations
- ✅ **Current Device Protection**: Preventing accidental deletion of active device
- ✅ **Sync+Async Pattern**: Understanding two-phase response architecture
- ✅ **Event-Driven Architecture**: Handle `onGetRegistredDeviceDetails` and `onUpdateDeviceDetails` callbacks
- ✅ **Error Handling**: API errors and status code validation
- ✅ **Real-time Synchronization**: Pull-to-refresh and automatic device list updates

## 🎯 Learning Objectives

By completing this Device Management codelab, you'll be able to:

1. **Implement device listing workflows** with proper cooling period detection and handling
2. **Build device management interfaces** with rename and delete operations
3. **Handle server-enforced cooling periods** with visual warnings and action disabling
4. **Protect current device** from accidental deletion with validation checks
5. **Design sync+async patterns** with proper event handler management
6. **Implement error handling** for comprehensive error detection
7. **Create real-time sync experiences** with pull-to-refresh functionality
8. **Debug device management flows** and troubleshoot operation-related issues

## 🏗️ Prerequisites

Before starting this codelab, ensure you've completed:

- **[REL-ID MFA Codelab](https://codelab.uniken.com/codelabs/flutter-mfa-activation-login-flow/index.html?index=..%2F..index#0)** - Complete MFA implementation required
- Understanding of REL-ID SDK event-driven architecture patterns
- Experience with Flutter state management (Riverpod)
- Knowledge of Dart asynchronous programming (async/await, Future)
- Familiarity with Flutter navigation (GoRouter)
- Basic understanding of server-client synchronization patterns

## 📁 Device Management Project Structure

```
relid-device-management/
├── 📱 Enhanced Flutter MFA + Device Management App
│   ├── android/                 # Android-specific configuration
│   ├── ios/                     # iOS-specific configuration
│   └── rdna_client/            # REL-ID Flutter Plugin
│
├── 📦 Device Management Source Architecture
│   └── lib/
│       ├── tutorial/            # Device Management Implementation
│       │   ├── navigation/      # Enhanced navigation with device management
│       │   │   └── app_router.dart        # GoRouter with device screens
│       │   ├── screens/         # Device Management Screens
│       │   │   ├── components/  # Reusable UI components
│       │   │   │   ├── close_button.dart          # Custom close button
│       │   │   │   └── drawer_content.dart        # Drawer with device mgmt
│       │   │   └── device_management/ # 🔐 Device Management Flow
│       │   │       ├── device_management_screen.dart   # 🆕 Device list with pull-to-refresh
│       │   │       ├── device_detail_screen.dart       # 🆕 Device details & actions
│       │   │       └── rename_device_dialog.dart       # 🆕 Rename modal dialog
│       └── uniken/              # 🛡️ Enhanced REL-ID Integration
│           ├── services/        # 🆕 Enhanced SDK service layer
│           │   ├── rdna_service.dart                # Added device management APIs
│           │   │                                   # - getRegisteredDeviceDetails()
│           │   │                                   # - updateDeviceDetails()
│           │   └── rdna_event_manager.dart         # Complete event management
│           │                                      # - setGetRegisteredDeviceDetailsHandler()
│           │                                      # - setUpdateDeviceDetailsHandler()
│
└── 📚 Production Configuration
    ├── pubspec.yaml             # Dependencies
    ├── analysis_options.yaml    # Linting rules
```

## 🚀 Quick Start

### Installation & Setup

```bash
# Navigate to the codelab folder
cd relid-device-management

# Place the rdna_client plugin folder
# at root folder of this project (refer to Project Structure above for more info)

# Install dependencies
flutter pub get

# iOS additional setup (required for CocoaPods)
cd ios && pod install && cd ..

# Run the application
flutter run
# or for specific device
flutter run -d <device-id>
```

### Verify Device Management Features

Once the app launches, verify these device management capabilities:

1. ✅ Complete MFA flow available (prerequisite from previous codelab)
2. ✅ Device Management screen accessible from drawer navigation
3. ✅ `getRegisteredDeviceDetails()` API integration with device list display
4. ✅ Pull-to-refresh functionality for real-time device synchronization
5. ✅ Cooling period banner when server cooling period is active
6. ✅ Device detail screen with rename and delete operations
7. ✅ `updateDeviceDetails()` API integration with proper error handling
8. ✅ Current device protection preventing accidental deletion

## 🔑 REL-ID Device Management Operation Types

### Official REL-ID Device Management API Mapping

> **⚠️ Critical**: Device management operations follow a sync+async pattern. Always register event handlers BEFORE calling APIs.

| API Method | Operation Type | Event Handler | Description | Documentation |
|------------|---------------|---------------|-------------|---------------|
| `getRegisteredDeviceDetails()` | **List Devices** | `onGetRegistredDeviceDetails` | Fetches all user devices with cooling period info | [📖 API Docs](https://developer.uniken.com/docs/get-registered-devices) |
| `updateDeviceDetails()` | **Rename Device** (operationType: 0) | `onUpdateDeviceDetails` | Updates device name with server validation | [📖 API Docs](https://developer.uniken.com/docs/update-device-details) |
| `updateDeviceDetails()` | **Delete Device** (operationType: 1) | `onUpdateDeviceDetails` | Removes non-current device from account | [📖 API Docs](https://developer.uniken.com/docs/update-device-details) |

> **🎯 Production Recommendation**: Always implement proper error handling (API errors and status codes) for robust device management.

### How to Use Device Management APIs

REL-ID device management supports three primary operations:

#### **1. List Devices** - View All Registered Devices
```dart
final userID = 'john.doe';
await rdnaService.getRegisteredDeviceDetails(userID);
// Wait for onGetRegistredDeviceDetails event
```
- **Use Case**: Display all devices registered to user account
- **Returns**: Device list with cooling period information
- **Status Code 100**: Success with device data
- **Status Code 146**: Cooling period active - disable all operations
- **📖 Official Documentation**: [Get Registered Devices API](https://developer.uniken.com/docs/get-registered-devices)

#### **2. Rename Device** - Update Device Display Name
```dart
final operationType = 0; // Rename operation
await rdnaService.updateDeviceDetails(
  userID,
  device,
  'My iPhone 14 Pro',
  operationType
);
// Wait for onUpdateDeviceDetails event
```
- **Use Case**: User-friendly device name customization
- **Validation**: Cannot rename during cooling period
- **Server Response**: StatusCode 100 (success) or 146 (cooling period)
- **📖 Official Documentation**: [Update Device Details API](https://developer.uniken.com/docs/update-device-details)

#### **3. Delete Device** - Remove Device from Account
```dart
final operationType = 1; // Delete operation
await rdnaService.updateDeviceDetails(
  userID,
  device,
  '', // Empty string for delete
  operationType
);
// Wait for onUpdateDeviceDetails event
```
- **Use Case**: Remove lost or unused devices
- **Protection**: Cannot delete current device (currentDevice: true)
- **Validation**: Cannot delete during cooling period
- **Confirmation**: Always show destructive action confirmation dialog
- **📖 Official Documentation**: [Update Device Details API](https://developer.uniken.com/docs/update-device-details)

## 🎓 Learning Checkpoints

### Checkpoint 1: Sync+Async Pattern Understanding
- [ ] I understand the two-phase response pattern (sync acknowledgment + async event)
- [ ] I know why event handlers must be registered BEFORE API calls
- [ ] I can implement proper handler cleanup to avoid memory leaks
- [ ] I understand when to use screen-level vs global event handlers
- [ ] I can debug issues related to missing or incorrectly timed event handlers

### Checkpoint 2: Device Listing & Synchronization
- [ ] I can implement `getRegisteredDeviceDetails()` API with proper error handling
- [ ] I understand how to parse device list from `onGetRegistredDeviceDetails` event
- [ ] I know how to detect cooling period from StatusCode 146
- [ ] I can implement pull-to-refresh for real-time device synchronization
- [ ] I understand the device object structure (devUuid, devName, currentDevice, status)

### Checkpoint 3: Device Update Operations
- [ ] I can implement device rename with `updateDeviceDetails()` operationType 0
- [ ] I can implement device deletion with `updateDeviceDetails()` operationType 1
- [ ] I understand the JSON payload structure required by the SDK
- [ ] I know how to handle update responses in `onUpdateDeviceDetails` event
- [ ] I can differentiate between rename and delete operation responses

### Checkpoint 4: Cooling Period Management
- [ ] I understand what cooling periods are and why they exist
- [ ] I can detect cooling period from `deviceManagementCoolingPeriodEndTimestamp`
- [ ] I know how to disable UI actions when StatusCode is 146
- [ ] I can display visual warnings when cooling period is active
- [ ] I understand how to handle cooling period errors in update operations

### Checkpoint 5: Error Handling
- [ ] I can implement API-level error detection (longErrorCode !== 0)
- [ ] I can implement status code validation (StatusCode 100, 146, etc.)
- [ ] I understand when each error layer catches different failure scenarios
- [ ] I can provide user-friendly error messages for all error types

### Checkpoint 6: Current Device Protection
- [ ] I understand why current device deletion must be prevented
- [ ] I can identify current device using `currentDevice: true` flag
- [ ] I know how to disable delete button for current device
- [ ] I can display appropriate UI indicators for current device (badge, etc.)
- [ ] I understand the security implications of current device protection

## 🔄 Device Management User Flow

### Scenario 1: Standard Device Listing with Real-time Sync
1. **User navigates to Device Management** → From drawer navigation menu
2. **API call initiated** → `getRegisteredDeviceDetails(userID)` called automatically
3. **Loading indicator displayed** → User sees loading state during API call
4. **Device list received** → `onGetRegistredDeviceDetails` event provides device array
5. **Cooling period check** → StatusCode 146 detection and banner display
6. **Device list rendered** → ListView displays all devices with metadata
7. **Current device highlighted** → Badge indicator for current device
8. **User pulls to refresh** → Manual refresh triggers new API call
9. **List updates** → Latest device data synchronized from server
10. **User taps device** → Navigate to DeviceDetailScreen for actions

### Scenario 2: Device Rename Operation
1. **User taps device card** → Navigate to DeviceDetailScreen
2. **User taps "Rename Device"** → Opens RenameDeviceDialog modal
3. **Current name pre-filled** → TextField shows existing device name
4. **User enters new name** → Real-time validation as user types
5. **User taps "Rename"** → `updateDeviceDetails(userID, device, newName, 0)` called
6. **Loading state shown** → Dialog shows loading indicator
7. **Update response received** → `onUpdateDeviceDetails` event with StatusCode 100
8. **Success confirmation** → SnackBar displays "Device renamed successfully"
9. **UI updates immediately** → Device name updates in detail screen
10. **User returns to list** → Navigate back, device list auto-refreshes

### Scenario 3: Device Deletion with Protection
1. **User navigates to device detail** → Taps non-current device
2. **Delete button enabled** → Button active only for non-current devices
3. **User taps "Remove Device"** → Destructive action confirmation dialog appears
4. **Confirmation dialog shown** → "Are you sure? This cannot be undone."
5. **User confirms deletion** → `updateDeviceDetails(userID, device, '', 1)` called
6. **Delete processing** → Loading indicator replaces button
7. **Delete response received** → `onUpdateDeviceDetails` event with StatusCode 100
8. **Success confirmation** → AlertDialog with "Device deleted successfully"
9. **Navigation back** → Automatic return to device list
10. **Device list refreshed** → Deleted device no longer appears in list

### Scenario 4: Cooling Period Enforcement
1. **User performs operation** → Rename or delete device
2. **Server applies cooling period** → 30-minute cooldown starts
3. **User returns to device list** → Pull-to-refresh or automatic load
4. **API returns StatusCode 146** → Cooling period detected
5. **Warning banner displayed** → "Device management in cooling period. Please try again later."
6. **All actions disabled** → Rename and delete buttons grayed out
7. **User attempts operation** → Validation prevents API call
8. **Error message shown** → "Actions disabled during cooling period"
9. **Cooling period expires** → After configured time (e.g., 30 minutes)
10. **Operations re-enabled** → Next API call returns StatusCode 100, actions enabled

### Scenario 5: Error Handling (Network Failures, Current Device Protection)
1. **User attempts delete current device** → Taps delete on device with currentDevice: true
2. **Validation catches attempt** → Client-side check prevents API call
3. **Error alert displayed** → "Cannot delete the current device"
4. **User attempts network operation** → Rename/delete with no network
5. **Network error occurs** → Error in sync response handling
6. **Error handler catches** → Proper error handling displays message
7. **User-friendly error shown** → "Failed to complete operation. Please check connection."
8. **User retries operation** → Taps retry button
9. **Network restored** → Operation succeeds on retry
10. **Success confirmation** → Operation completes successfully

## 💡 Pro Tips

### Device Management Implementation Best Practices
1. **Register handlers before API calls** - Event handlers must be set before calling SDK APIs
2. **Implement proper error handling** - Check API errors and status codes
3. **Protect current device** - Never allow deletion of device with currentDevice: true
4. **Enforce cooling periods** - Disable all operations when StatusCode is 146
5. **Use pull-to-refresh** - Provide manual refresh for real-time synchronization
6. **Show loading states** - Always provide visual feedback during API operations
7. **Confirm destructive actions** - Use AlertDialog for delete operations
8. **Clean up handlers** - Reset event handlers in dispose() to prevent memory leaks

### Security & User Experience
9. **Validate before API calls** - Check cooling period and current device before operations
10. **Display cooling period warnings** - Show prominent banner when StatusCode 146
11. **Highlight current device** - Use badges or indicators for current device visibility
12. **Auto-refresh after operations** - Reload device list after successful rename/delete
13. **Handle cleanup on dispose** - Reset event handlers in dispose() lifecycle
14. **Provide timestamp context** - Display "Last accessed" and "Created" timestamps
15. **Optimize list rendering** - Use ListView.builder for performance

## 🔗 Key Implementation Files

### Core Device Listing API Implementation
```dart
// rdna_service.dart - Device Listing API
Future<RDNASyncResponse> getRegisteredDeviceDetails(String userId) async {
  print('RdnaService - Getting registered device details for user: $userId');

  final response = await _rdnaClient.getRegisteredDeviceDetails(userId);

  print('  Sync Response:');
  print('  Long Error Code: ${response.error?.longErrorCode}');
  print('  Error String: ${response.error?.errorString}');

  return response;
}
```

### Device Update API Implementation
```dart
// rdna_service.dart - Device Update API (Rename/Delete)
Future<RDNASyncResponse> updateDeviceDetails(
  String userId,
  RDNADeviceDetails device,
  String newDevName,
  int operationType
) async {
  final operation = operationType == 0 ? 'rename' : 'delete';
  print('RdnaService - Updating device details ($operation) for user: $userId');

  // SDK expects JSON string payload with complete device object
  // Status field: "Update" for rename, "Delete" for delete
  final status = operationType == 0 ? 'Update' : 'Delete';

  final payload = jsonEncode({
    'device': [{
      'devUUID': device.devUuid,
      'devName': newDevName,
      'status': status,
      'lastAccessedTs': device.lastAccessedTs,
      'lastAccessedTsEpoch': device.lastAccessedTsEpoch,
      'createdTs': device.createdTs,
      'createdTsEpoch': device.createdTsEpoch,
      'appUuid': device.appUuid,
      'currentDevice': device.currentDevice,
      'devBind': device.devBind
    }]
  });

  print('RdnaService - JSON payload: $payload');

  final response = await _rdnaClient.updateDeviceDetails(userId, payload);

  print('  Sync Response:');
  print('  Long Error Code: ${response.error?.longErrorCode}');

  return response;
}
```

**Example Payload for Rename Operation:**
```json
{
  "device": [{
    "devUUID": "I6RT38G3M7K4JKBXW81FUEM2VYWQFQB3JSMQU0ZV7MZ84UMQR",
    "devName": "iOS-iPhone-iPhone 12 Mini-Updated",
    "status": "Update",
    "lastAccessedTs": "2025-10-09T11:39:49UTC",
    "lastAccessedTsEpoch": 1760009989000,
    "createdTs": "2025-10-09T11:38:34UTC",
    "createdTsEpoch": 1760009914000,
    "appUuid": "6b72172f-3e51-4ea9-b217-2f3e51aea9c3",
    "currentDevice": true,
    "devBind": 0
  }]
}
```

**Example Payload for Delete Operation:**
```json
{
  "device": [{
    "devUUID": "I6RT38G3M7K4JKBXW81FUEM2VYWQFQB3JSMQU0ZV7MZ84UMQR",
    "devName": "",
    "status": "Delete",
    "lastAccessedTs": "2025-10-09T11:39:49UTC",
    "lastAccessedTsEpoch": 1760009989000,
    "createdTs": "2025-10-09T11:38:34UTC",
    "createdTsEpoch": 1760009914000,
    "appUuid": "6b72172f-3e51-4ea9-b217-2f3e51aea9c3",
    "currentDevice": false,
    "devBind": 0
  }]
}
```

### Event Handler Setup with Cleanup
```dart
// device_management_screen.dart - Proper Event Handler Setup with Cleanup
Future<void> _loadDevices() async {
  final eventManager = _rdnaService.getEventManager();
  bool handlerCalled = false;

  // Set callback for this screen
  eventManager.setGetRegisteredDeviceDetailsHandler((data) {
    if (handlerCalled) return; // Prevent double handling
    handlerCalled = true;

    // Extract and parse device data
    final parsedResponse = data.pArgs?.response?.responseData?.response;
    final deviceResponse = parsedResponse is RDNAGetRegisteredDeviceDetailsResponse
        ? parsedResponse
        : null;
    final deviceList = deviceResponse?.device ?? [];

    // Check for errors
    if (data.error?.longErrorCode != 0) {
      if (mounted) {
        _showError(data.error?.errorString ?? 'Failed to load devices');
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
      return;
    }

    // Extract cooling period data
    final coolingPeriodEnd = deviceResponse?.deviceManagementCoolingPeriodEndTimestamp;
    final statusCode = data.pArgs?.response?.statusCode ?? 0;

    if (mounted) {
      setState(() {
        _devices = deviceList;
        _coolingPeriodEndTimestamp = coolingPeriodEnd;
        _isCoolingPeriodActive = statusCode == 146;
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  });

  // Call the API
  final response = await _rdnaService.getRegisteredDeviceDetails(widget.userID!);

  // Check sync response error
  if (response.error?.longErrorCode != 0) {
    if (mounted) {
      _showError(response.error?.errorString ?? 'Failed to load devices');
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }
}

@override
void dispose() {
  print('DeviceManagementScreen - Screen disposed, cleaning up event handlers');
  // Reset handler to prevent memory leaks
  _rdnaService.getEventManager().setGetRegisteredDeviceDetailsHandler(null);
  super.dispose();
}
```


### Error Handling Implementation
```dart
// device_detail_screen.dart - Complete Error Handling
Future<void> _handleRenameDevice(String newName) async {
  setState(() => _isRenaming = true);

  final eventManager = _rdnaService.getEventManager();
  bool handlerCalled = false;

  eventManager.setUpdateDeviceDetailsHandler((data) {
    if (handlerCalled) return;
    handlerCalled = true;

    // Check API error
    if (data.error?.longErrorCode != 0) {
      if (mounted) {
        _showError('Failed to rename device. Please try again.');
        setState(() => _isRenaming = false);
      }
      return;
    }

    // Check status code
    final statusCode = data.pArgs?.response?.statusCode ?? 0;
    final statusMsg = data.pArgs?.response?.statusMsg ?? '';

    if (statusCode == 100) {
      if (mounted) {
        setState(() {
          _currentDeviceName = newName;
          _isRenaming = false;
        });
        _showSuccess('Device renamed successfully');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        });
      }
    } else if (statusCode == 146) {
      if (mounted) {
        _showError('Device management is in cooling period');
        setState(() => _isRenaming = false);
      }
    } else {
      if (mounted) {
        _showError(statusMsg.isNotEmpty ? statusMsg : 'Failed to rename device');
        setState(() => _isRenaming = false);
      }
    }
  });

  // Call API
  final response = await _rdnaService.updateDeviceDetails(
    widget.userID!,
    widget.device,
    newName,
    0,
  );

  // Check sync response error
  if (response.error?.longErrorCode != 0) {
    if (mounted) {
      _showError(response.error?.errorString ?? 'Failed to rename device');
      setState(() => _isRenaming = false);
    }
  }
}
```

### Cooling Period Detection & UI
```dart
// device_management_screen.dart - Cooling Period Banner
if (_isCoolingPeriodActive)
  Container(
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
        const Text('⏳', style: TextStyle(fontSize: 24)),
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
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),

// device_detail_screen.dart - Disabled Actions During Cooling Period
ElevatedButton(
  onPressed: widget.isCoolingPeriodActive ? null : () => _showRenameDialog(),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF007AFF),
    disabledBackgroundColor: Colors.grey,
  ),
  child: const Text('✏️ Rename Device'),
)
```

### Current Device Protection
```dart
// device_detail_screen.dart - Protect Current Device from Deletion
final isCurrentDevice = widget.device.currentDevice ?? false;

if (!isCurrentDevice)
  ElevatedButton(
    onPressed: widget.isCoolingPeriodActive ? null : _handleDeleteDevice,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      disabledBackgroundColor: Colors.grey,
    ),
    child: const Text('🗑️ Remove Device'),
  ),

void _handleDeleteDevice() {
  if (widget.device.currentDevice ?? false) {
    _showError('Cannot delete the current device');
    return;
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Device'),
      content: Text(
        'Are you sure you want to delete "${_currentDeviceName}"? '
        'This action cannot be undone.'
      ),
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
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
```

---

## 📚 Related Documentation

### Official REL-ID Device Management APIs
- **[Get Registered Devices API](https://developer.uniken.com/docs/get-registered-devices)** - Complete API reference for fetching device lists with cooling period information
- **[Update Device Details API](https://developer.uniken.com/docs/update-device-details)** - Comprehensive guide for rename and delete operations with JSON payload structure

### REL-ID Developer Resources
- **[REL-ID Developer Portal](https://developer.uniken.com/)** - Main developer documentation hub

### Flutter Resources
- **[Flutter Documentation](https://flutter.dev/docs)** - Official Flutter setup and development guides
- **[GoRouter Documentation](https://pub.dev/packages/go_router)** - Navigation library documentation for Flutter apps
- **[Riverpod Documentation](https://riverpod.dev/)** - State management library reference
- **[Dart Language Tour](https://dart.dev/guides/language/language-tour)** - Dart language reference and best practices

---

**🔐 Congratulations! You've mastered Device Management with REL-ID SDK!**

*You're now equipped to implement secure, production-ready device management workflows with proper synchronization, cooling period enforcement, and error handling. Use this knowledge to create robust device management experiences that provide users with complete control over their registered devices while maintaining security through server-enforced cooling periods and current device protection.*
