# REL-ID Flutter Codelab: Notification History Management

[![Flutter](https://img.shields.io/badge/Flutter-3.38.4-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.10.3-blue.svg)](https://dart.dev/)
[![REL-ID SDK](https://img.shields.io/badge/REL--ID%20SDK-v25.8.1-green.svg)](https://developer.uniken.com/)
[![Notification History](https://img.shields.io/badge/Feature-Notification%20History-purple.svg)]()

> **Codelab Advanced:** Master notification history retrieval, display, and filtering with REL-ID SDK in Flutter

This folder contains the source code for the solution demonstrating [REL-ID Notification History Management](https://codelab.uniken.com/codelabs/flutter-notification-history/index.html?index=..%2F..index#0) using Flutter architecture with comprehensive historical tracking, filtering, and status management.

## 🔐 What You'll Learn

In this notification history management codelab, you'll master production-ready notification history patterns:

- ✅ **History Retrieval**: `getNotificationHistory()` API with 9 filter parameters for flexible querying
- ✅ **Historical Display**: ListView with sorted notifications by timestamp and color-coded status badges
- ✅ **Status Tracking**: Visual indicators (UPDATED, EXPIRED, DISCARDED, DISMISSED) with color coding
- ✅ **Detail Modal**: Full notification view with complete metadata and timestamps
- ✅ **Epoch Conversion**: Automatic epoch timestamp to local time conversion for user-friendly display
- ✅ **Auto-Loading**: Notifications history loaded automatically on screen mount
- ✅ **Pull-to-Refresh**: RefreshIndicator for manual refresh functionality
- ✅ **Empty State Handling**: User-friendly messages when no history available
- ✅ **Error Handling**: Two-layer error checking (error.longErrorCode and response validation)
- ✅ **Drawer Integration**: Accessible via "📜 Notification History" menu item

## 🎯 Learning Objectives

By completing this Notification History codelab, you'll be able to:

### Notification History Management
1. **Implement history retrieval** with `getNotificationHistory()` API and 9 filter parameters
2. **Handle onGetNotificationsHistory event** with two-layer error checking pattern
3. **Display historical data** with ListView.builder, sorted by epoch timestamp, status badges, and color coding
4. **Build detail modal** using showDialog() for viewing complete notification information
5. **Convert epoch timestamps** to local time for user-friendly display
6. **Implement auto-loading** pattern with initState() on screen mount
7. **Handle empty states** and error scenarios gracefully
8. **Manage event handlers** with cleanup in dispose() to prevent accumulation

### Flutter Development
9. **Build ListView screens** with RefreshIndicator and optimized rendering
10. **Implement dialog overlays** with proper state management
11. **Manage event handlers** with dispose() cleanup to prevent memory leaks
12. **Use plugin data classes** for SDK integration with type safety
13. **Handle navigation parameters** through GoRouter extra parameter
14. **Debug Flutter applications** with proper logging and error handling

## 🏗️ Prerequisites

Before starting this codelab, ensure you've completed:

- **[REL-ID Flutter MFA Codelab](https://codelab.uniken.com/codelabs/flutter-mfa-activation-login-flow/index.html?index=..%2F..index#0)** - Complete MFA implementation required
- **[REL-ID Flutter Additional Device Activation Flow With Notifications Codelab](https://codelab.uniken.com/codelabs/flutter-mfa-additional-device-activation-flow/index.html?index=..%2F..index#0)** - Notification retrieval and display
- Understanding of Flutter ListView and RefreshIndicator patterns
- Experience with Flutter StatefulWidget lifecycle (initState, dispose)
- Knowledge of REL-ID SDK event-driven architecture
- Familiarity with plugin data classes from rdna_struct.dart
- Basic understanding of notification systems and historical data display

## 📁 Notification History Project Structure

```
relid-notification-history/
├── 📱 Flutter Notification History App
│   ├── android/                 # Android-specific configuration
│   ├── ios/                     # iOS-specific configuration
│   └── rdna_client/             # REL-ID Flutter Plugin
│
├── 📦 Notification History Source Architecture
│   └── lib/
│       ├── tutorial/            # Notification History Implementation
│       │   ├── navigation/      # Enhanced navigation
│       │   │   └── app_router.dart              # GoRouter with history route
│       │   └── screens/         # Notification History Screens
│       │       ├── components/  # Reusable UI components
│       │       │   ├── custom_button.dart           # Loading states
│       │       │   ├── status_banner.dart           # Error displays
│       │       │   ├── drawer_content.dart          # Drawer menu with history item
│       │       │   └── ...                          # Other reusable components
│       │       ├── notification/ # 🆕 Notification History Management
│       │       │   ├── get_notifications_screen.dart    # Notification retrieval
│       │       │   └── notification_history_screen.dart # 🆕 Historical notifications
│       │       │                                        # - Auto-loads history
│       │       │                                        # - Detail modal (showDialog)
│       │       │                                        # - Status badges (color-coded)
│       │       │                                        # - Epoch to local time
│       │       │                                        # - RefreshIndicator
│       │       └── mfa/         # MFA screens
│       │           ├── dashboard_screen.dart        # Dashboard with drawer
│       │           ├── check_user_screen.dart       # User validation
│       │           └── ...                          # Other MFA screens
│       └── uniken/              # 🛡️ REL-ID Integration
│           ├── providers/       # Enhanced providers
│           │   └── sdk_event_provider.dart      # Event handling
│           │                                   # - onGetNotificationsHistory
│           │                                   # - onGetNotifications
│           ├── services/        # 🆕 Enhanced SDK service layer
│           │   ├── rdna_service.dart           # Notification APIs
│           │   │                              # - getNotifications(params)
│           │   │                              # - getNotificationHistory(filters)
│           │   └── rdna_event_manager.dart     # Complete event management
│           │                                  # - setGetNotificationHistoryHandler()
│           │                                  # - setGetNotificationsHandler()
│           └── utils/           # Helper utilities
│               └── connection_profile_parser.dart  # Profile configuration
│
└── 📚 Production Configuration
    ├── pubspec.yaml             # Flutter dependencies
    ├── analysis_options.yaml    # Linting configuration
```

## 🚀 Quick Start

### Installation & Setup

```bash
# Navigate to the codelab folder
cd relid-notification-history

# Place the rdna_client plugin at root folder of this project
# (symlink or copy from FlutterReferenceApp/rdna_client)

# Install dependencies
flutter pub get

# Run the application
flutter run
# or for specific device
flutter run -d <device_id>
```

### Verify Notification History Features

Once the app launches, verify these notification history capabilities:

**Notification History Retrieval**:

1. ✅ Complete MFA flow and log in to dashboard
2. ✅ Navigate to "📜 Notification History" from drawer menu
3. ✅ `getNotificationHistory()` called automatically on screen mount (initState)
4. ✅ Historical notifications displayed in ListView (sorted by epoch timestamp, latest first)
5. ✅ Status badges visible with color coding:
   - Green: UPDATED, ACCEPTED
   - Red: REJECTED, DISCARDED
   - Orange: EXPIRED
   - Gray: DISMISSED
   - Blue: Other statuses

**Detail Modal & Timestamps**:

6. ✅ Tap notification item → Detail modal displays (showDialog)
7. ✅ Modal shows complete notification info:
   - Subject and message
   - Status and action performed
   - Created timestamp (converted to local time)
   - Updated timestamp (converted to local time, if available)
   - Expiry timestamp (converted to local time)
   - Signing status (if available)
8. ✅ Epoch timestamps automatically converted to local time
9. ✅ Tap "Close" button → Modal closes

**Pull-to-Refresh & Error Handling**:

10. ✅ Pull down on history list → RefreshIndicator displays
11. ✅ History reloads with latest data from server
12. ✅ When no history available → "No notification history found" message with retry button
13. ✅ Tap retry button → History reloads
14. ✅ API errors display user-friendly error messages from server
15. ✅ Response errors show error.errorString from SDK

**Event Handler Management**:

16. ✅ Open Notification History for the first time → Handler registered in initState
17. ✅ Navigate away → dispose() called, handler removed
18. ✅ Open Notification History again → New handler registered (no accumulation)
19. ✅ Response handled only once (not multiple times)

## 🎓 Learning Checkpoints

### Checkpoint 1: Notification History Basics
- [ ] I understand how `getNotificationHistory()` retrieves historical notifications
- [ ] I can implement filtered history retrieval with 9 parameters (recordCount, startIndex, enterpriseID, dates, status, action, keyword, deviceID)
- [ ] I know how to handle `onGetNotificationsHistory` event with two-layer error checking
- [ ] I can display historical notifications with ListView.builder sorted by epoch timestamp

### Checkpoint 2: Status Display & Color Coding
- [ ] I understand different notification statuses (UPDATED, EXPIRED, DISCARDED, DISMISSED)
- [ ] I can implement color-coding for different statuses using Flutter Colors
- [ ] I know how to display status badges with Container and BoxDecoration
- [ ] I can display action performed with color-coding based on action type

### Checkpoint 3: Detail Modal & Timestamps
- [ ] I can build detail modal using showDialog() for viewing complete notification information
- [ ] I understand how to convert epoch timestamps to local DateTime
- [ ] I know how to handle epoch in milliseconds using DateTime.fromMillisecondsSinceEpoch()
- [ ] I can display multiple timestamp fields (created, updated, expiry)

### Checkpoint 4: Auto-Loading & Pull-to-Refresh
- [ ] I understand auto-loading pattern with initState() on screen mount
- [ ] I can implement RefreshIndicator with ListView for pull-to-refresh
- [ ] I know how to handle empty states with user-friendly messages
- [ ] I can implement two-layer error checking (error.longErrorCode and response validation)

### Checkpoint 5: Event Handler Management
- [ ] I understand event handler accumulation prevention with dispose() cleanup
- [ ] I know when to call dispose() (Flutter lifecycle method)
- [ ] I can remove event handlers when screen is disposed
- [ ] I understand why handler cleanup is critical for StatefulWidgets

### Checkpoint 6: Flutter Development
- [ ] I understand ListView.builder optimization with itemBuilder
- [ ] I know how to implement dialog overlays with showDialog()
- [ ] I can implement navigation with GoRouter and extra parameter passing
- [ ] I understand plugin data class integration from rdna_struct.dart
- [ ] I can maintain session parameters across screen navigation

## 🔄 Notification History User Flows

### Scenario 1: Viewing Notification History
1. **User in Dashboard** → Opens drawer menu (tap ☰)
2. **User taps "📜 Notification History"** → context.goNamed('notificationHistoryScreen', extra: sessionData)
3. **NotificationHistoryScreen builds** → initState() called
4. **Register event handler** → setGetNotificationHistoryHandler() registered
5. **Auto-load history** → getNotificationHistory() called with default parameters
6. **SDK returns sync response** → Check response.error?.longErrorCode == 0
7. **SDK fires async event** → onGetNotificationsHistory event triggered
8. **Event handler called** → _handleNotificationHistoryResponse()
9. **Two-layer error checking** → Check error.longErrorCode, then validate response data
10. **History displayed** → ListView.builder with sorted items, status badges (color-coded)
11. **User taps history item** → Detail modal displays using showDialog()
12. **Modal shows details** → Complete notification info with epoch timestamps converted to local time
13. **User closes modal** → Navigator.pop(context), returns to history list

### Scenario 2: Pull-to-Refresh
1. **User in Notification History** → Sees current history list
2. **User pulls down** → RefreshIndicator displays
3. **onRefresh called** → _onRefresh() sets refreshing = true
4. **API called** → getNotificationHistory() with same parameters
5. **History updated** → ListView rebuilds with latest data
6. **Refresh indicator hidden** → setState sets refreshing = false

### Scenario 3: Empty Notification History
1. **NotificationHistoryScreen builds** → Auto-calls getNotificationHistory() in initState
2. **SDK returns empty array** → history.length == 0
3. **Empty state displayed** → "No notification history found" message with ElevatedButton retry
4. **User taps retry** → getNotificationHistory() called again

### Scenario 4: Returning to Notification History (Proper Cleanup)
1. **User visits Notification History** → Handler registered in initState()
2. **User navigates away** → dispose() executes, handler set to null
3. **User returns to Notification History** → New handler registered (old one removed)
4. **Response received** → Handler called only ONCE (no multiple calls)

### Scenario 5: Error Handling
1. **API error occurs** → response.error?.longErrorCode != 0
2. **Sync error check** → Display response.error?.errorString immediately
3. **OR async event error** → data.error?.longErrorCode != 0
4. **Layer 1 check triggers** → Display data.error?.errorString
5. **Error state displayed** → User-friendly error message with retry button

**Important Notes**:

- **Filter Parameters**: 9 parameters available (recordCount, startIndex, enterpriseID, startDate, endDate, notificationStatus, actionPerformed, keywordSearch, deviceID)
- **Epoch Conversion**: All epoch timestamps (milliseconds) automatically converted to local time using DateTime.fromMillisecondsSinceEpoch()
- **Handler Cleanup**: Call setGetNotificationHistoryHandler(null) in dispose() to prevent handler accumulation
- **Two-Layer Error Checking**: Always check error.longErrorCode first, then validate response?.responseData
- **Status Color Coding**: Green (success), Red (rejected), Orange (expired), Gray (dismissed), Blue (other)
- **No Try-Catch**: Flutter plugin returns RDNASyncResponse with error field, not exceptions

## 🔄 Notification History Filter Parameters

The `getNotificationHistory()` API supports 9 filter parameters for flexible querying:

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `recordCount` | int | Number of records to retrieve | 10 |
| `startIndex` | int | Starting index for pagination | 1 |
| `enterpriseID` | String | Filter by enterprise ID | '' (empty for all) |
| `startDate` | String | Filter from this date | '' (empty for all) |
| `endDate` | String | Filter until this date | '' (empty for all) |
| `notificationStatus` | String | Filter by status | 'UPDATED', 'EXPIRED', etc. |
| `actionPerformed` | String | Filter by action | 'APPROVE', 'REJECT', etc. |
| `keywordSearch` | String | Search by keyword | '' (empty for all) |
| `deviceID` | String | Filter by device ID | '' (empty for all) |

**Default Parameters for Basic Retrieval**:
```dart
await rdnaService.getNotificationHistory(
  recordCount: 10,    // Get 10 most recent
  startIndex: 1,      // Start from first record
  enterpriseID: '',   // All enterprises
  startDate: '',      // No start date filter
  endDate: '',        // No end date filter
  notificationStatus: '',  // All statuses
  actionPerformed: '', // All actions
  keywordSearch: '',  // No keyword filter
  deviceID: '',       // All devices
);
```

## 🎨 Status Badge Color Coding

Notification history uses color-coded status badges for visual clarity:

| Status | Color | Hex Code | Meaning |
|--------|-------|----------|---------|
| UPDATED, ACCEPTED | Green | #4CAF50 | Successfully processed |
| REJECTED, DISCARDED | Red | #F44336 | Declined or discarded |
| EXPIRED | Orange | #FF9800 | Expired before action |
| DISMISSED | Gray | #9E9E9E | User dismissed |
| Other statuses | Blue | #2196F3 | Default color |

## 🕐 Epoch Timestamp Conversion

All notification timestamps are returned as epoch timestamps (milliseconds) and are converted to local time:

**Epoch Timestamp Format**:
- Format: `1765792619000` (milliseconds since Unix epoch)
- Example: `1765792619000` = Dec 15, 2025 9:56:59 AM

**Conversion Logic**:
1. Get epoch value from plugin data class (createTsEpoch, updateTsEpoch, expiryTimestampEpoch)
2. Convert to DateTime: `DateTime.fromMillisecondsSinceEpoch(epoch)`
3. Format to local string: `DateFormat('MMM dd, yyyy hh:mm a').format(date)`

**Example Conversion**:
```dart
// Epoch: 1765792619000 (milliseconds)
final date = DateTime.fromMillisecondsSinceEpoch(1765792619000);
// Result: 2025-12-15 09:56:59 (local timezone)

// Formatted: "Dec 15, 2025 09:56 AM"
final formatted = DateFormat('MMM dd, yyyy hh:mm a').format(date);
```

**Relative Time Display**:
- Today: "Today"
- Yesterday: "Yesterday"
- Last 7 days: "3 days ago"
- Older: "Dec 15, 2025"

## ⚠️ Two-Layer Error Checking Pattern

All notification history responses use two-layer error checking:

**Layer 1 - Sync Response Error** (`response.error?.longErrorCode`):
```dart
final response = await rdnaService.getNotificationHistory(...);

if (response.error?.longErrorCode == 0) {
  print('Sync success, waiting for async event');
} else {
  // Display sync error immediately
  final errorMsg = response.error?.errorString ?? 'Failed to load';
  showErrorDialog(errorMsg);
}
```

**Layer 2 - Async Event Error** (`data.error?.longErrorCode`):
```dart
void _handleNotificationHistoryResponse(RDNAStatusGetNotificationHistory data) {
  if (data.error?.longErrorCode == 0) {
    // Success - check if response data exists
    if (data.pArgs?.response?.responseData?.response != null) {
      final responseData = data.pArgs!.response!.responseData!.response
          as RDNAGetNotificationHistoryResponse?;
      // Process history...
    }
  } else {
    // Display async error
    final errorMsg = data.error?.errorString ?? 'Unknown error';
    showErrorDialog(errorMsg);
  }
}
```

## 🔧 Event Handler Cleanup

To prevent event handler accumulation when visiting the screen multiple times:

**Pattern**:
```dart
class _NotificationHistoryScreenState extends ConsumerState<NotificationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Register handler after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupEventHandler();
    });
  }

  void _setupEventHandler() {
    final eventManager = RdnaService.getInstance().getEventManager();
    eventManager.setGetNotificationHistoryHandler((data) {
      _handleNotificationHistoryResponse(data);
    });
  }

  @override
  void dispose() {
    // Remove handler to prevent accumulation
    final eventManager = RdnaService.getInstance().getEventManager();
    eventManager.setGetNotificationHistoryHandler(null);
    super.dispose();
  }
}
```

**Why This Matters**:
- Without cleanup: Handlers accumulate on each visit (1st visit = 1 handler, 2nd visit = 2 handlers, 3rd visit = 3 handlers)
- With cleanup: Always exactly 1 handler active
- Response processed only once (no duplicate "Loaded 10 history items" logs)

## 🎓 Learning Checkpoints Summary

Use this checklist to verify your implementation:

**Core Features**:
- [ ] Notification history retrieval with `getNotificationHistory()` API
- [ ] Auto-loading pattern on screen mount with initState()
- [ ] ListView.builder display sorted by epoch timestamp (newest first)
- [ ] Status badges with color coding using Container and BoxDecoration
- [ ] Detail modal with showDialog() showing complete notification info
- [ ] Epoch timestamp conversion to local time using DateTime and DateFormat
- [ ] RefreshIndicator for pull-to-refresh functionality

**Error Handling**:
- [ ] Layer 1: Sync response error checking (response.error?.longErrorCode)
- [ ] Layer 2: Async event error checking (data.error?.longErrorCode)
- [ ] Empty state handling with retry button
- [ ] User-friendly error messages from error.errorString

**Event Management**:
- [ ] Event handler registration in initState()
- [ ] Event handler cleanup in dispose() (prevents accumulation)
- [ ] Handler set to null on dispose
- [ ] No handler preservation needed (unique event)

**Flutter Patterns**:
- [ ] ListView.builder optimization with itemBuilder
- [ ] RefreshIndicator integration with onRefresh callback
- [ ] Dialog modal management with showDialog()
- [ ] GoRouter navigation with extra parameter
- [ ] Plugin data class usage from rdna_struct.dart (RDNANotificationHistory)

## 📚 Advanced Resources

- **REL-ID Notifications API**: [Notifications API Guide](https://developer.uniken.com/docs/notification-management)
- **REL-ID SDK Documentation**: [REL-ID SDK Reference](https://developer.uniken.com/docs/rel-id-sdk)
- **Flutter ListView**: [ListView Performance](https://docs.flutter.dev/cookbook/lists/long-lists)
- **Flutter Dialogs**: [Dialog Widget](https://api.flutter.dev/flutter/material/Dialog-class.html)
- **Flutter Lifecycle**: [StatefulWidget Lifecycle](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html)

## 💡 Pro Tips

### Notification History Implementation
1. **Auto-load history** - Call `getNotificationHistory()` in initState() with addPostFrameCallback
2. **Sort by epoch timestamp** - Display newest history items first using epoch comparison
3. **Color-code status** - Use Color(0xFFHEXCODE) for visual indicators
4. **Convert epoch timestamps** - Use DateTime.fromMillisecondsSinceEpoch() for local time
5. **Handle empty states** - Show user-friendly messages when history.length == 0
6. **Use named parameters** - Make API calls readable with named parameters

### Error Handling Best Practices
7. **Two-layer checking** - Always check response.error?.longErrorCode (sync) then data.error?.longErrorCode (async)
8. **Show server messages** - Display error.errorString from SDK
9. **Log error codes** - Include longErrorCode in print statements for debugging
10. **Handle null safely** - Use ?. operators for safe null access

### Event Handler Management
11. **Cleanup in dispose()** - Always set handler to null in dispose() method
12. **Remove old handlers** - Clear handler before widget is disposed
13. **No preservation needed** - NotificationHistory event is unique to this screen
14. **Test multiple visits** - Ensure handler doesn't accumulate on repeated navigation

### Flutter Development
15. **Optimize ListView** - Use ListView.builder with itemCount and itemBuilder
16. **RefreshIndicator UX** - Provide visual feedback during refresh operations
17. **Pass session params** - Always pass RDNAUserLoggedIn through GoRouter extra
18. **Use plugin classes** - Leverage rdna_struct.dart data classes for type safety
19. **Test on device** - Some features only work on real devices
20. **Use Dart DevTools** - Debug widget state and performance effectively

---

**📜 Congratulations! You've mastered Notification History Management in Flutter!**

*You're now equipped to implement production-ready notification history features with:*

- **Historical Tracking**: Complete notification history with filtering capabilities
- **Visual Status Indicators**: Color-coded badges for quick status recognition
- **Detail Views**: Comprehensive notification metadata display using Flutter dialogs
- **Epoch Conversion**: User-friendly local timestamp display with DateTime
- **Error Handling**: Two-layer error checking with SDK error messages
- **Event Management**: Proper handler cleanup with dispose() to prevent accumulation
- **Pull-to-Refresh**: Real-time synchronization with RefreshIndicator

*Use this knowledge to create user-friendly notification history experiences in Flutter applications that provide complete audit trails and historical insights!*
