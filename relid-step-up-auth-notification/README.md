# REL-ID Flutter Codelab: Step-Up Authentication with Notifications

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev/)
[![REL-ID SDK](https://img.shields.io/badge/REL--ID%20SDK-v25.8.1-green.svg)](https://developer.uniken.com/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![Step-Up Auth](https://img.shields.io/badge/Step--Up%20Auth-Enabled-blue.svg)]()
[![Challenge Mode 3](https://img.shields.io/badge/Challenge%20Mode-3-purple.svg)]()

> **Codelab Advanced:** Master Step-Up Authentication for notification actions with REL-ID SDK

This folder contains the source code for the solution demonstrating [REL-ID Step-Up Authentication](https://developer.uniken.com/docs/stepup-authentication-for-actions) using secure re-authentication flows for sensitive notification actions with password and LDA verification.

## 🔐 What You'll Learn

In this advanced step-up authentication codelab, you'll master production-ready notification action authentication patterns:

**Step-Up Authentication Features:**
- ✅ **Step-Up Authentication Flow**: `updateNotification()` → SDK checks if action requires authentication → User authenticates via password or LDA
- ✅ **Password Authentication**: SDK triggers `getPassword` event with `challengeMode = 3` (RDNA_OP_AUTHORIZE_NOTIFICATION)
- ✅ **LDA Authentication**: SDK handles biometric authentication internally, no `getPassword` event
- ✅ **Notification Actions**: `getNotifications()` and `updateNotification()` APIs
- ✅ **Password Dialog UI**: Modal dialog with attempts counter and error handling
- ✅ **Event-Driven Flow**: `updateNotification()` → `getPassword` (if password required) → `onUpdateNotification` event
- ✅ **Error Handling**: Critical status codes (110, 153) and error code (131) with alerts before logout
- ✅ **Auto-Field Clearing**: Clear password field when authentication fails and retry triggers
- ✅ **Callback Preservation**: Chain event handlers for different challenge modes
- ✅ **Success Flow**: Alert confirmation with navigation to dashboard

## 🎯 Learning Objectives

By completing this Step-Up Authentication codelab, you'll be able to:

**Step-Up Authentication Objectives:**
1. **Implement notification retrieval** with `getNotifications()` API and auto-loading
2. **Handle notification actions** using `updateNotification()` API with action parameters
3. **Manage step-up authentication** for password (challengeMode 3) and LDA verification
4. **Build password dialog UI** with modal, attempts counter, and error display using Flutter widgets
5. **Handle keyboard overlap** with SingleChildScrollView and proper padding
6. **Clear password fields** automatically when authentication fails and retry triggers
7. **Preserve event callbacks** to chain handlers for different challenge modes
8. **Handle critical status codes** with statusCode 110, 153 alerts before SDK logout
9. **Handle LDA cancellation** with error code 131 and allow user retry
10. **Debug step-up auth flows** and troubleshoot callback preservation issues

## 🔑 Step-Up Authentication Logic

**Important**: Step-up authentication requires the user to be logged in. The authentication method used for step-up depends on how the user logged in and what authentication methods are enrolled for the app.

### Authentication Enrollment During Activation

During initial activation, users can enroll using:
- **Password only**
- **LDA (Local Device Authentication)** only - Biometric authentication (Face ID, Touch ID, Fingerprint, etc.)
- **Both Password and LDA**

Once enrolled, users can log in using either LDA or password, depending on what has been set up.

### Step-Up Authentication Flow Logic

The SDK automatically determines which authentication method to use for step-up authentication based on:
1. **How the user logged in** (Password or LDA)
2. **What authentication methods are enrolled** for the app

| Login Method | Enrolled Methods | Step-Up Authentication Method | Notes |
|--------------|------------------|-------------------------------|-------|
| Password | Password only | **Password** | SDK triggers `getPassword` with challengeMode 3 |
| LDA | LDA only | **LDA** | SDK handles biometric internally, no `getPassword` event |
| Password | Both Password & LDA | **Password** | SDK triggers `getPassword` with challengeMode 3 |
| LDA | Both Password & LDA | **LDA** (with Password fallback) | SDK attempts LDA first. If user cancels LDA, SDK directly triggers `getPassword` (no error) |

**Key Behaviors**:

- When user logs in with **Password** → Step-up uses **Password** (even if LDA is enrolled)
- When user logs in with **LDA** → Step-up uses **LDA** (with automatic Password fallback on cancellation)
- **LDA Cancellation Fallback**:
  - If **Password is enrolled**: SDK directly triggers `getPassword` event (no error, seamless fallback)
  - If **Password is NOT enrolled**: Error code 131 returned in `onUpdateNotification` event (user can retry LDA)

## 🏗️ Prerequisites

Before starting this codelab, ensure you've completed:

- **[REL-ID MFA Codelab](https://codelab.uniken.com/codelabs/flutter-mfa-activation-login-flow/index.html?index=..%2F..index#0)** - Complete MFA implementation required
- **[REL-ID Additional Device Activation Flow With Notifications Codelab](https://codelab.uniken.com/codelabs/flutter-mfa-additional-device-activation-flow/index.html?index=..%2F..index#0)** - Notification retrieval and display
- Understanding of Flutter modal dialogs and keyboard handling
- Experience with event-driven architectures and callback preservation patterns
- Knowledge of REL-ID SDK authentication challenge modes
- Familiarity with biometric authentication and LDA concepts
- Basic understanding of security best practices for re-authentication flows
- Understanding of Flutter state management with Riverpod

## 📁 Step-Up Authentication Project Structure

```
relid-step-up-auth-notification/
├── 📱 Flutter Notification + Step-Up Auth App
│   ├── android/                 # Android-specific configuration
│   ├── ios/                     # iOS-specific configuration
│   └── rdna_client/             # REL-ID Flutter Plugin
│
├── 📦 Step-Up Authentication Source Architecture
│   └── lib/
│       ├── tutorial/            # Enhanced Notification + Step-Up Auth flows
│       │   ├── navigation/      # Enhanced navigation
│       │   │   └── app_router.dart           # GoRouter configuration
│       │   └── screens/         # Enhanced screens with step-up auth
│       │       ├── components/  # Enhanced UI components
│       │       │   ├── drawer_content.dart          # Drawer with notifications menu
│       │       │   └── ...                          # Other reusable components
│       │       ├── notification/ # 🆕 Notification + Step-Up Auth Management
│       │       │   ├── get_notifications_screen.dart # 🆕 Notification actions with step-up auth
│       │       │   └── index.dart                    # Notification exports
│       │       ├── mfa/         # 🔐 MFA screens
│       │       │   ├── dashboard_screen.dart        # Dashboard
│       │       │   ├── check_user_screen.dart       # User validation
│       │       │   └── ...                          # Other MFA screens
│       │       └── tutorial/    # Base tutorial screens
│       └── uniken/              # 🛡️ Enhanced REL-ID Integration
│           ├── components/      # 🆕 Enhanced UI components
│           │   └── modals/      # 🆕 Modal components
│           │       ├── step_up_password_dialog.dart  # 🆕 Password dialog for step-up auth
│           │       └── session_modal.dart            # Session timeout modal
│           ├── providers/       # Enhanced providers
│           │   └── sdk_event_provider.dart          # Complete event handling
│           │                                        # - onGetNotifications
│           │                                        # - onUpdateNotification
│           ├── services/        # 🆕 Enhanced SDK service layer
│           │   ├── rdna_service.dart                # Enhanced notification APIs
│           │   │                                    # - getNotifications(params)
│           │   │                                    # - updateNotification(uuid, action)
│           │   │                                    # - setPassword(password, 3)
│           │   └── rdna_event_manager.dart          # Complete event management
│           │                                        # - getPassword handler (challengeMode 3)
│           │                                        # - onGetNotifications handler
│           │                                        # - onUpdateNotification handler
│           └── utils/           # Helper utilities
│
└── 📚 Production Configuration
    ├── pubspec.yaml             # Dependencies
    └── STEP_UP_AUTH_IMPLEMENTATION.md  # Comprehensive implementation guide
```

## 🚀 Quick Start

### Installation & Setup

```bash
# Navigate to the codelab folder
cd relid-step-up-auth-notification

# Place the rdna_client plugin at root folder of this project
# (refer to Project Structure above for more info)

# Install dependencies
flutter pub get

# Run the application
flutter run
```

### Verify Step-Up Authentication Features

Once the app launches, verify these step-up authentication capabilities:

**Basic Step-Up Authentication Flow (Password Login)**:

1. ✅ Complete MFA flow with password and successful login to dashboard
2. ✅ Navigate to "🔔 Get Notifications" from drawer menu
3. ✅ `getNotifications()` called automatically on screen load
4. ✅ Notifications displayed with action buttons
5. ✅ Tap action button to trigger `updateNotification()` API
6. ✅ SDK triggers `getPassword` event with `challengeMode = 3` (step-up auth)
7. ✅ StepUpPasswordDialog displays with notification title, attempts counter
8. ✅ Enter incorrect password → error displays, password field clears, attempts decrease
9. ✅ Enter correct password → `onUpdateNotification` event with success
10. ✅ Success alert displayed → Navigate to dashboard

**Step-Up Authentication Flow (LDA Login)**:

11. ✅ Login with LDA (biometric) → Navigate to notifications screen
12. ✅ Tap action button → SDK triggers LDA prompt (no `getPassword` event)
13. ✅ Complete LDA → `onUpdateNotification` with success
14. ✅ Cancel LDA (if both Password & LDA enrolled) → SDK falls back to password dialog

**Error Handling**:

15. ✅ Critical status codes (110, 153) show alert before SDK logout
16. ✅ LDA cancellation triggers password fallback when both methods enrolled
17. ✅ Password field clears when `getPassword` triggers again after error

## 🎓 Learning Checkpoints

### Checkpoint 1: Step-Up Authentication - Notification Actions
- [ ] I understand how `getNotifications()` retrieves notifications from REL-ID server
- [ ] I can implement `updateNotification(uuid, action)` to process user actions
- [ ] I know when SDK triggers `getPassword` with `challengeMode = 3` for step-up auth
- [ ] I can differentiate between LDA (biometric) and password step-up auth
- [ ] I understand the difference between initial authentication and step-up re-authentication
- [ ] I understand how login method (Password vs LDA) determines step-up authentication method
- [ ] I know the LDA cancellation fallback behavior (Password via `getPassword`)

### Checkpoint 2: Step-Up Authentication - Password Dialog UI
- [ ] I can implement Flutter Dialog with password input and visibility toggle
- [ ] I understand how to display attempts counter with color-coding using Flutter
- [ ] I know how to show notification title/context in the dialog
- [ ] I can implement loading states during password verification
- [ ] I understand how to use PopScope to prevent dialog dismissal during submission

### Checkpoint 3: Step-Up Authentication - Event Callback Preservation
- [ ] I can preserve existing event callbacks when setting screen-level handlers
- [ ] I understand how to chain handlers for different challenge modes
- [ ] I know how to handle `challengeMode = 3` in screen vs other modes globally
- [ ] I can implement proper cleanup with initState/dispose lifecycle
- [ ] I understand why screen-level handler is better than global handler for challengeMode 3

### Checkpoint 4: Step-Up Authentication - Error Handling
- [ ] I can handle critical status codes (statusCode 110, 153) with alerts before logout
- [ ] I understand LDA cancellation (error code 131) and retry flow
- [ ] I know how to automatically clear password fields on retry
- [ ] I can display user-friendly error messages from SDK responses
- [ ] I understand when to show error vs when to trigger logout

### Checkpoint 5: Production Step-Up Authentication
- [ ] I understand security best practices for step-up authentication
- [ ] I can implement comprehensive error handling for authentication failures
- [ ] I know how to optimize user experience with clear messaging
- [ ] I understand compliance and audit requirements for re-authentication flows
- [ ] I can debug step-up auth issues with event callback preservation

## 🔄 Step-Up Authentication User Flows

### Scenario 1: Standard Step-Up Authentication Flow (Password)
1. **User in GetNotificationsScreen** → Notifications loaded from server
2. **User selects notification action** → Tap "View Actions" button
3. **Action modal displayed** → Radio button selection for action options
4. **User selects action and submits** → `updateNotification(uuid, action)` called
5. **SDK requires step-up auth** → `getPassword` event triggered with `challengeMode = 3`
6. **Action modal closes** → `_showActionModal = false` set
7. **StepUpPasswordDialog displays** → Password input with notification title, attempts counter
8. **User enters password** → `setPassword(password, 3)` called
9. **SDK verifies password** → `onUpdateNotification` event triggered with success
10. **Success alert displayed** → User sees confirmation message
11. **Navigation to dashboard** → Alert "OK" button navigates to dashboard
12. **Notifications refreshed** → `_loadNotifications()` called to refresh list

### Scenario 2: Step-Up Authentication with Wrong Password
1. **StepUpPasswordDialog displayed** → User sees password input with attempts counter
2. **User enters wrong password** → `setPassword(wrongPassword, 3)` called
3. **SDK verification fails** → `getPassword` event triggered again with error
4. **Error message displayed** → Error shown in dialog (red background)
5. **Password field cleared** → `didUpdateWidget` clears password automatically
6. **Attempts decremented** → Attempts counter updates (e.g., "2 attempts remaining")
7. **User retries** → Repeat steps 2-6 until correct password or attempts exhausted

### Scenario 3: Step-Up Authentication - Attempts Exhausted (Critical Error)
1. **User in StepUpPasswordDialog** → Final attempt remaining
2. **User enters wrong password** → Last attempt used
3. **SDK returns critical error** → `onUpdateNotification` with statusCode 153 (attempts exhausted)
4. **Alert displayed BEFORE logout** → "Authentication Failed" alert with status message
5. **User acknowledges alert** → Tap "OK" button
6. **SDK triggers logout** → `onUserLoggedOff` event handled by SDKEventProvider
7. **Navigation to home** → User returns to login screen

### Scenario 4: Step-Up Authentication with LDA (Biometric)
1. **User logged in with LDA** → User previously authenticated using biometric
2. **User selects notification action** → `updateNotification(uuid, action)` called
3. **SDK triggers LDA prompt** → Biometric authentication prompt (e.g., Face ID, Fingerprint)
4. **User authenticates with biometric** → SDK verifies internally
5. **Success** → `onUpdateNotification` event with success, navigate to dashboard

### Scenario 4a: Step-Up Authentication - LDA Cancelled with Password Fallback (Both Enrolled)
1. **User logged in with LDA** → User previously authenticated using biometric (both Password & LDA enrolled)
2. **User selects notification action** → `updateNotification(uuid, action)` called
3. **SDK triggers LDA prompt** → Biometric authentication prompt displayed
4. **User cancels LDA** → User dismisses biometric prompt
5. **SDK falls back to password** → SDK directly triggers `getPassword` event with `challengeMode = 3` (no error, no `onUpdateNotification`)
6. **StepUpPasswordDialog displays** → Password input shown as fallback
7. **User enters password** → `setPassword(password, 3)` called
8. **Success** → `onUpdateNotification` event with success, navigate to dashboard

### Scenario 4b: Step-Up Authentication - LDA Cancelled without Password Fallback (LDA Only)
1. **User logged in with LDA** → User previously authenticated using biometric (LDA only enrolled, no Password)
2. **User selects notification action** → `updateNotification(uuid, action)` called
3. **SDK triggers LDA prompt** → Biometric authentication prompt displayed
4. **User cancels LDA** → User dismisses biometric prompt
5. **SDK returns error** → `onUpdateNotification` event with error code 131
6. **Error alert displayed** → "Authentication Cancelled" alert shown
7. **User can retry** → Action modal remains open, user can tap action again to retry LDA

**Important Notes - Step-Up Authentication Event Chain**:

- **challengeMode = 3**: Indicates `RDNA_OP_AUTHORIZE_NOTIFICATION` - password required for notification action
- **Authentication Method Selection**: SDK automatically chooses password or LDA based on login method and enrolled credentials
- **LDA Fallback**: When user logs in with LDA and cancels biometric, SDK automatically falls back to password via `getPassword`
- **Callback Preservation**: Screen-level handler for mode 3, global handler for other modes
- **Error Codes**:
  - `statusCode 100`: Success - action completed
  - `statusCode 110`: Password expired - show alert BEFORE SDK logout
  - `statusCode 153`: Attempts exhausted - show alert BEFORE SDK logout
  - `error code 131`: LDA cancelled and Password NOT enrolled - Allow user to retry LDA
- **Auto-Clear Password**: When `getPassword` triggers again after error, password field clears via `didUpdateWidget`

## 🏗️ Architecture Deep Dive: Why Screen-Level Handler for ChallengeMode 3?

### Design Decision: Screen-Level vs Global Handler

The implementation handles `getPassword` with `challengeMode = 3` at the **screen level** (GetNotificationsScreen) rather than globally. This is a deliberate architectural choice with significant benefits:

#### ✅ Screen-Level Handler Approach (Current Implementation)

```dart
// get_notifications_screen.dart
void _handleGetPasswordStepUp(RDNAGetPassword data) {
  // Only handle challengeMode 3 (step-up auth)
  if (data.challengeMode != 3) {
    if (_originalGetPasswordHandler != null) {
      _originalGetPasswordHandler!(data);
    }
    return;
  }

  // Screen has direct access to notification context
  setState(() {
    _showStepUpAuth = true;
  });
}
```

**Advantages**:
1. **Context Access**: Direct access to notification data (title, message, action) already loaded in screen
2. **Modal Management**: Easy to manage modal stack (close action modal → open password dialog)
3. **State Locality**: All step-up auth state lives where it's used, no prop drilling
4. **UI Flow**: Modal overlay maintains screen context, better UX
5. **Lifecycle Management**: Handler active only when screen mounted, automatic cleanup
6. **Callback Preservation**: Chains with global handler, doesn't break other challenge modes

#### ❌ Global Handler Approach (Alternative - Not Recommended)

```dart
// sdk_event_provider.dart
void _handleGetPassword(RDNAGetPassword data) {
  if (data.challengeMode == 3) {
    // Problems:
    // - Notification context not available here
    // - Need complex state management to pass data
    // - Navigation to new screen breaks UX
    context.go('/stepUpAuth', extra: {'???' });
  }
}
```

**Disadvantages**:
1. **No Context Access**: Notification data not available in global provider
2. **Complex State Management**: Need Riverpod global state to pass notification data
3. **Navigation Overhead**: Navigate to new screen instead of modal overlay
4. **Poor UX**: User loses context of which notification they're acting on
5. **Tight Coupling**: Hard to reuse pattern for other step-up auth scenarios
6. **Maintenance Burden**: Flow scattered across multiple files

### Architecture Comparison Table

| Aspect | Screen-Level Handler (✅ Current) | Global Handler (❌ Alternative) |
|--------|-----------------------------------|--------------------------------|
| **Context Access** | Direct access to notification data | Need state management layer |
| **UI Pattern** | Modal dialog on same screen | Navigate to new screen |
| **Modal Management** | Simple (close one, open another) | Complex (cross-screen modals) |
| **Code Locality** | All related code in one place | Scattered across multiple files |
| **Maintenance** | Easy to understand and modify | Hard to trace flow |
| **Cleanup** | Automatic on dispose | Manual cleanup needed |
| **Reusability** | Pattern reusable for other screens | Tightly coupled to specific flow |
| **State Management** | Local State fields, no globals | Need global state (Riverpod providers) |

### Key Takeaway

**Screen-level handlers are the recommended pattern when:**
- Handler needs access to screen-specific context/data
- UI pattern uses modal dialogs rather than navigation
- State is specific to the screen and doesn't need global access
- Handler should only be active when screen is mounted

**Global handlers are appropriate when:**
- Handler needs to work across all screens
- Navigation to dedicated screen is the desired UX
- State needs to be shared globally
- Handler should always be active regardless of current screen

For step-up authentication with notifications, the screen-level approach is superior because it maintains context, simplifies state management, and provides better UX.

## 📚 Advanced Resources

- **REL-ID Step-Up Authentication Documentation**: [Step-Up Authentication Guide](https://developer.uniken.com/docs/stepup-authentication-for-actions)
- **REL-ID Notifications API**: [Notifications API Guide](https://developer.uniken.com/docs/notification-management)
- **REL-ID Challenge Modes**: [Understanding Challenge Modes](https://developer.uniken.com/docs/challenge-modes)
- **Flutter Dialog**: [Dialog Widget](https://api.flutter.dev/flutter/material/Dialog-class.html)
- **Flutter TextField**: [TextField Widget](https://api.flutter.dev/flutter/material/TextField-class.html)

## 💡 Pro Tips

### Step-Up Authentication Implementation Best Practices
1. **Preserve event callbacks** - Chain handlers using callback preservation pattern
2. **Close action modal first** - Hide action modal before showing password dialog
3. **Clear password on error** - Use `didUpdateWidget` to clear password when error changes
4. **Handle keyboard overlap** - Use SingleChildScrollView with proper padding
5. **Show critical alerts** - Display alert BEFORE SDK triggers logout (110, 153)
6. **Handle LDA cancellation** - Allow retry when user cancels biometric (131)
7. **Display notification context** - Show notification title in password dialog
8. **Color-code attempts** - Visual feedback for remaining attempts (green→orange→red)
9. **Disable during submission** - Prevent double-submit with loading states
10. **Use PopScope** - Prevent hardware back button dismiss during submission

### Integration & Development
11. **Auto-load notifications** - Call `getNotifications()` on screen mount
12. **Proper Dart types** - Leverage `RDNAGetPassword`, `RDNAStatusUpdateNotification`
13. **Implement comprehensive logging** - Log flow progress without exposing passwords
14. **Test with various actions** - Ensure step-up auth works with different notification actions
15. **Monitor authentication metrics** - Track step-up auth success rates
16. **Auto-focus password field** - Focus password input when dialog appears
17. **Test LDA and password** - Verify both authentication methods work
18. **Validate action selection** - Ensure action is selected before submission
19. **Refresh notifications** - Reload notifications after successful action
20. **Use ConsumerStatefulWidget** - For screens that need both Riverpod and local state

### Security & Compliance
21. **Enforce step-up auth** - Never bypass step-up authentication requirements
22. **Secure password handling** - Never log or expose passwords
23. **Audit notification actions** - Log notification actions for security monitoring
24. **Handle session timeouts** - Ensure step-up auth respects session timeouts
25. **Test security scenarios** - Verify step-up auth under various attack scenarios
26. **Clear sensitive data** - Clear password field on dispose and error
27. **Respect attempts limits** - Honor server-configured attempt limits
28. **Handle LDA fallback** - Implement password fallback when user cancels biometric (both enrolled)
29. **Test all enrollment scenarios** - Verify password-only, LDA-only, and both enrolled scenarios
30. **Respect user login method** - Step-up auth should match how user logged in (password or LDA)

## 🔗 Key Implementation Files

```dart
// rdna_service.dart - Notification APIs
Future<RDNASyncResponse> getNotifications({
  int offset = 0,
  int noOfNotifications = 10,
}) async {
  final response = await _rdnaClient.getNotifications(
    offset,
    noOfNotifications,
  );
  return response;
}

Future<RDNASyncResponse> updateNotification(
  String notificationUuid,
  String action,
) async {
  final syncResponse = await _rdnaClient.updateNotification(
    notificationUuid,
    action,
  );
  return syncResponse;
}
```

```dart
// get_notifications_screen.dart - Callback Preservation Pattern
void _handleGetPasswordStepUp(RDNAGetPassword data) {
  print('GetNotificationsScreen - getPassword event:');
  print('  Challenge Mode: ${data.challengeMode}');
  print('  Attempts Left: ${data.attemptsLeft}');
  print('  Status Code: ${data.challengeResponse?.status?.statusCode}');

  // Only handle challengeMode 3 (step-up auth)
  if (data.challengeMode != 3) {
    print('GetNotificationsScreen - Not challengeMode 3, passing to original handler');
    if (_originalGetPasswordHandler != null) {
      _originalGetPasswordHandler!(data);
    }
    return;
  }

  // Hide action modal to show step-up modal on top
  setState(() {
    _showActionModal = false;
    _stepUpAttemptsLeft = data.attemptsLeft ?? 3;
    _stepUpSubmitting = false;
  });

  // Check for errors
  final statusCode = data.challengeResponse?.status?.statusCode;
  final statusMessage = data.challengeResponse?.status?.statusMessage;

  if (statusCode != null && statusCode != 100) {
    setState(() {
      _stepUpErrorMessage = statusMessage ?? 'Authentication failed. Please try again.';
    });
  } else {
    setState(() {
      _stepUpErrorMessage = '';
    });
  }

  setState(() {
    _showStepUpAuth = true;
  });
}

// Set handler with preservation
void _setupEventHandlers() {
  final rdnaService = ref.read(rdnaServiceProvider);
  final eventManager = rdnaService.getEventManager();

  eventManager.setGetNotificationsHandler(_handleNotificationsReceived);
  eventManager.setUpdateNotificationHandler(_handleUpdateNotificationReceived);

  // Preserve original getPassword handler and chain it
  _originalGetPasswordHandler = eventManager.getPasswordHandler;

  eventManager.setGetPasswordHandler((RDNAGetPassword data) {
    _handleGetPasswordStepUp(data);
  });
}
```

```dart
// get_notifications_screen.dart - Error Handling
void _handleUpdateNotificationReceived(RDNAStatusUpdateNotification data) {
  setState(() {
    _actionLoading = false;
    _stepUpSubmitting = false;
  });

  // Check for LDA cancelled (error code 131)
  if (data.error != null && data.error?.longErrorCode == 131) {
    setState(() {
      _showStepUpAuth = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Cancelled'),
        content: const Text('Local device authentication was cancelled. Please try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  final responseData = data.pArgs?.response;
  final statusCode = responseData?.statusCode;

  if (statusCode == 100) {
    // Success
    setState(() {
      _showStepUpAuth = false;
      _showActionModal = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification updated successfully'),
        backgroundColor: Colors.green,
      ),
    );

    _loadNotifications();
  } else if (statusCode == 110 || statusCode == 153) {
    // Critical errors - show alert BEFORE SDK logout
    setState(() {
      _showStepUpAuth = false;
      _showActionModal = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Failed'),
        content: Text(responseData?.statusMsg ?? 'Unknown error'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              print('Waiting for SDK to trigger logout flow');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

```dart
// step_up_password_dialog.dart - Auto-Clear Password on Error
@override
void didUpdateWidget(StepUpPasswordDialog oldWidget) {
  super.didUpdateWidget(oldWidget);

  // Clear password when modal becomes visible or when error changes
  if (widget.visible && !oldWidget.visible) {
    _passwordController.clear();
    _showPassword = false;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _passwordFocusNode.requestFocus();
      }
    });
  }

  // Clear password field when error message changes (wrong password)
  if (widget.errorMessage != null && widget.errorMessage != oldWidget.errorMessage) {
    _passwordController.clear();
  }
}

// PopScope for back button handling
PopScope(
  canPop: !widget.isSubmitting,
  onPopInvokedWithResult: (didPop, result) {
    if (!didPop && !widget.isSubmitting) {
      widget.onCancel();
    }
  },
  child: Dialog(
    // ... dialog content
  ),
)
```

---

**🔐 Congratulations! You've mastered Step-Up Authentication with REL-ID SDK in Flutter!**

*You're now equipped to implement secure step-up authentication flows with:*

- **Notification Action Security**: Re-authentication for sensitive notification actions
- **Password and LDA Support**: Both password and biometric authentication methods
- **Callback Preservation**: Proper event handler chaining for different challenge modes
- **Error Handling**: Critical error alerts before SDK logout
- **User Experience**: Auto-clear password fields, keyboard management, attempts counter
- **Flutter Best Practices**: StatefulWidget with proper lifecycle management, Riverpod integration

*Use this knowledge to create secure, user-friendly step-up authentication experiences that protect sensitive operations while maintaining excellent usability!*
