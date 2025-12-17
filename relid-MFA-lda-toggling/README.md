# REL-ID Flutter Codelab: LDA Toggling Management

[![Flutter](https://img.shields.io/badge/Flutter-3.10.3-blue.svg)](https://flutter.dev/)
[![REL-ID SDK](https://img.shields.io/badge/REL--ID%20SDK-v25.8.1-green.svg)](https://developer.uniken.com/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![LDA Toggling](https://img.shields.io/badge/LDA%20Toggling-Enabled-orange.svg)]()
[![Authentication Modes](https://img.shields.io/badge/Authentication%20Modes-Password%2FLDA-purple.svg)]()

> **Codelab Advanced:** Master LDA Toggling workflows with REL-ID SDK for seamless authentication mode switching

This Flutter codelab demonstrates [REL-ID LDA Toggling Management](https://codelab.uniken.com/codelabs/flutter-lda-toggling/index.html?index=..%2F..index#0) using secure authentication mode switching between password and Local Device Authentication (LDA).

## 🔐 What You'll Learn

In this advanced LDA toggling codelab, you'll master production-ready authentication mode switching patterns:

- ✅ **Device Authentication Detection**: `getDeviceAuthenticationDetails()` API to retrieve supported LDA types
- ✅ **Interactive Toggle Interface**: Material Design switches for enabling/disabling authentication methods
- ✅ **Authentication Mode Management**: `manageDeviceAuthenticationModes()` API for toggling LDA
- ✅ **Event-Driven Status Updates**: Handle `onDeviceAuthManagementStatus` for real-time feedback
- ✅ **Challenge Mode Routing**: Manage password verification (modes 5, 14, 15) and consent flows (mode 16)
- ✅ **Two-Way Switching**: Enable switching from Password to LDA and LDA to Password
- ✅ **Unified Dialog Pattern**: Single `LDAToggleAuthDialog` handling all authentication challenges

## 🎯 Learning Objectives

By completing this LDA Toggling Management codelab, you'll be able to:

1. **Implement LDA toggling workflows** with device authentication capability detection
2. **Build interactive toggle interfaces** using Flutter Switch widgets with real-time status updates
3. **Handle authentication mode switching** from password to LDA and vice versa
4. **Create unified dialog components** that handle multiple challenge modes (5, 14, 15, 16)
5. **Design event-driven LDA management** with proper SDK event handling
6. **Integrate LDA toggling functionality** with existing MFA authentication workflows
7. **Debug LDA toggling flows** and troubleshoot authentication mode switching issues

## 🏗️ Prerequisites

Before starting this codelab, ensure you've completed:

- **[REL-ID MFA Codelab](https://codelab.uniken.com/codelabs/flutter-mfa-activation-login-flow/index.html?index=..%2F..index#0)** - Complete MFA implementation required
- **[REL-ID Forgot Password Codelab](https://codelab.uniken.com/codelabs/flutter-forgot-password-flow/index.html?index=..%2F..index#0)** - Understanding of challenge modes and revalidation flows
- Understanding of password verification and LDA consent flows
- Experience with Flutter widgets and state management (Riverpod)
- Knowledge of REL-ID SDK event-driven architecture patterns
- Familiarity with biometric authentication on mobile devices
- Basic understanding of authentication mode switching concepts

## 📁 LDA Toggling Management Project Structure

```
relid-MFA-lda-toggling/
├── 📱 Enhanced Flutter MFA + LDA Toggling App
│   ├── android/                 # Android-specific configuration
│   ├── ios/                     # iOS-specific configuration
│   └── rdna_client/            # REL-ID Flutter Plugin
│
├── 📦 LDA Toggling Source Architecture
│   └── lib/
│       ├── tutorial/            # Enhanced MFA + LDA Toggling flow
│       │   ├── navigation/      # Enhanced navigation with LDA toggling support
│       │   │   └── app_router.dart           # GoRouter configuration with LDA route
│       │   └── screens/         # Enhanced screens with LDA toggling
│       │       ├── components/  # Enhanced UI components
│       │       │   ├── drawer_content.dart        # Drawer with LDA Toggling menu
│       │       │   ├── status_banner.dart         # Error and warning displays
│       │       │   └── ...                        # Other reusable components
│       │       ├── lda_toggling/ # 🆕 LDA Toggling Management (EXCLUSIVE ownership)
│       │       │   ├── lda_toggling_screen.dart   # 🆕 Main screen with Callback Preservation Pattern
│       │       │   │                              #    - Intercepts modes 5, 14, 15, 16 EXCLUSIVELY
│       │       │   │                              #    - Shows LDAToggleAuthDialog with onCancelled callback
│       │       │   │                              #    - Restores SDKEventProvider handlers on dispose
│       │       │   ├── lda_toggle_auth_dialog.dart # 🆕 Unified dialog for modes 5,14,15,16
│       │       │   └── index.dart                 # Exports
│       │       ├── mfa/         # 🔐 MFA screens (separate from LDA toggling)
│       │       │   ├── verify_password_screen.dart  # Regular MFA password verification
│       │       │   ├── set_password_screen.dart     # Regular MFA password creation
│       │       │   ├── user_lda_consent_screen.dart # Regular MFA LDA consent
│       │       │   ├── check_user_screen.dart       # User validation
│       │       │   ├── dashboard_screen.dart        # Enhanced dashboard
│       │       │   └── ...                          # Other MFA screens
│       │       ├── notification/ # Notification Management System
│       │       │   └── get_notifications_screen.dart # Server notification management
│       │       └── tutorial/    # Base tutorial screens
│       └── uniken/              # 🛡️ Enhanced REL-ID Integration
│           ├── providers/       # Enhanced providers
│           │   └── sdk_event_provider.dart        # Global event handling for regular MFA only
│           │                                      # Does NOT handle modes 5,14,15,16 (LDA screen owns these)
│           ├── services/        # 🆕 Enhanced SDK service layer
│           │   ├── rdna_service.dart              # Added LDA toggling APIs:
│           │   │                                  # - getDeviceAuthenticationDetails()
│           │   │                                  # - manageDeviceAuthenticationModes()
│           │   └── rdna_event_manager.dart        # Complete event management:
│           │                                      # - onDeviceAuthManagementStatus handler
│           ├── utils/           # Helper utilities
│           │   ├── connection_profile_parser.dart # Profile configuration
│           │   └── password_policy_utils.dart     # Password validation
│           └── cp/              # Connection profile
│               └── agent_info.json                # Server configuration
│
└── 📚 Production Configuration
    ├── pubspec.yaml             # Dependencies
    ├── analysis_options.yaml
```

## 🚀 Quick Start

### Installation & Setup

```bash
# Navigate to the codelab folder
cd relid-MFA-lda-toggling

# Place the rdna_client plugin at root folder of this project
# (refer to Project Structure above for more info)

# Install dependencies
flutter pub get

# Run the application
flutter run
# or
flutter run -d ios
# or
flutter run -d android
```

### Verify LDA Toggling Features

Once the app launches, verify these LDA toggling capabilities:

1. ✅ Complete MFA flow available (prerequisite from previous codelab)
2. ✅ LDA Toggling screen accessible from drawer navigation (🔐 menu item)
3. ✅ `getDeviceAuthenticationDetails()` API retrieves available LDA types
4. ✅ Interactive toggle switches for enabling/disabling authentication methods
5. ✅ `manageDeviceAuthenticationModes()` API integration with proper error handling
6. ✅ Unified dialog for authentication challenges (challengeModes 5, 14, 15, 16)
7. ✅ Password verification flow (modes 5, 15) for authentication changes
8. ✅ Password creation flow (mode 14) for disabling LDA
9. ✅ LDA consent flow (mode 16) for enabling biometric authentication
10. ✅ Real-time status updates via `onDeviceAuthManagementStatus` event

## 🎓 Learning Checkpoints

### Checkpoint 1: Device Authentication Detection
- [ ] I understand how to retrieve device authentication capabilities using `getDeviceAuthenticationDetails()`
- [ ] I can parse authentication capability data (`RDNADeviceAuthenticationDetails`)
- [ ] I know the different authentication type mappings (1=Fingerprint, 2=Face ID, 9=Device LDA)
- [ ] I can handle devices with no LDA capabilities available
- [ ] I understand when to display LDA toggling UI based on available capabilities

### Checkpoint 2: Authentication Mode Management
- [ ] I can implement `manageDeviceAuthenticationModes()` API with RDNALDACapabilities enum
- [ ] I understand the sync callback and async event pattern for this API
- [ ] I know how to handle loading states during authentication mode switching
- [ ] I can implement Flutter Switch widgets with proper enabled/disabled state management
- [ ] I understand error handling for authentication mode management failures

### Checkpoint 3: Challenge Mode Routing for LDA Toggling
- [ ] I understand **NEW challenge modes** specific to LDA toggling (5, 14, 15, 16)
- [ ] I can intercept these modes in SDKEventProvider to show unified dialog
- [ ] I know the difference between regular MFA modes (0, 1, 2, 4) and LDA toggling modes (5, 14, 15, 16)
- [ ] I can implement `LDAToggleAuthDialog` with dynamic UI based on challenge mode
- [ ] I understand when to show dialog vs full-screen navigation

### Checkpoint 4: Unified Dialog Implementation
- [ ] I can create a single dialog component handling multiple challenge modes
- [ ] I understand password verification UI (modes 5, 15) - single password field
- [ ] I can implement password creation UI (mode 14) - two password fields with policy
- [ ] I know how to build LDA consent UI (mode 16) - approve/reject buttons
- [ ] I can handle attempts counter with color coding (green → orange → red)

### Checkpoint 5: Event-Driven Status Updates
- [ ] I can implement `onDeviceAuthManagementStatus` event handler
- [ ] I understand the status data structure (`RDNADeviceAuthManagementStatus`)
- [ ] I know how to differentiate between enable (OpMode=1) and disable (OpMode=0) operations
- [ ] I can display appropriate success/error messages based on status updates
- [ ] I understand when to refresh authentication details after status updates

### Checkpoint 6: Complete LDA Toggling Flow
- [ ] I can implement the complete Password to LDA flow:
  - Toggle ON → Password Verification (mode 5) → User Consent (mode 16) → Status Update → Biometric Enabled
- [ ] I can implement the complete LDA to Password flow:
  - Toggle OFF → Password Verification (mode 15) → Set Password (mode 14) → Status Update → Password Enabled
- [ ] I understand edge cases (network failures, user cancellation, device capability changes)
- [ ] I can implement comprehensive error handling for all toggling scenarios
- [ ] I can test LDA toggling with various device configurations

### Checkpoint 7: Production LDA Toggling Management
- [ ] I understand security best practices for authentication mode switching
- [ ] I can implement user-friendly Material Design UI with clear status indicators
- [ ] I know how to optimize performance with minimal API calls and efficient state management
- [ ] I can handle production deployment considerations for LDA toggling features
- [ ] I understand accessibility requirements for toggle interfaces

## 🔄 LDA Toggling User Flow

### Scenario 1: Enable Biometric Authentication (Password → LDA)
1. **User opens LDA Toggling screen** → `getDeviceAuthenticationDetails()` API called
2. **Available LDA types displayed** → ListView shows authentication capabilities with Switch widgets
3. **User toggles authentication ON** → `manageDeviceAuthenticationModes(true, authType)` API called
4. **Password verification initiated** → SDK triggers `getPassword` event with `challengeMode = 5`
5. **Dialog displayed** → `LDAToggleAuthDialog` shows password verification UI
6. **User enters current password** → Dialog remains open until verification
7. **Password verified successfully** → Dialog stays open (may trigger consent next)
8. **LDA consent required** → SDK triggers `getUserConsentForLDA` event with `challengeMode = 16`
9. **Dialog UI updates** → Shows LDA consent interface (Approve/Reject buttons)
10. **User approves biometric setup** → `setUserConsentForLDA(true, 16, authType)` API called
11. **Status update received** → SDK triggers `onDeviceAuthManagementStatus` event with `opMode = 1`
12. **Success message displayed** → Alert: "Biometric Authentication has been enabled successfully"
13. **Dialog closed** → Returns to LDA Toggling screen
14. **Authentication details refreshed** → Switch widget shows enabled state
15. **User can now login with biometric** → LDA toggling completed successfully

### Scenario 2: Disable Biometric Authentication (LDA → Password)
1. **User opens LDA Toggling screen** → `getDeviceAuthenticationDetails()` API called
2. **Enabled LDA types displayed** → List shows configured authentication (switch in ON state)
3. **User toggles authentication OFF** → `manageDeviceAuthenticationModes(false, authType)` API called
4. **Password verification initiated** → SDK triggers `getPassword` event with `challengeMode = 15`
5. **Dialog displayed** → `LDAToggleAuthDialog` shows password verification UI
6. **User enters current password** → Dialog verifies password
7. **Password verified successfully** → Dialog stays open (password creation next)
8. **Password creation required** → SDK triggers `getPassword` event with `challengeMode = 14`
9. **Dialog UI updates** → Shows password creation interface (two fields + policy)
10. **User creates new password** → Enters password meeting policy requirements
11. **Password policy validation** → Password matches confirmation and meets policy
12. **New password set** → `setPassword(password, challengeMode 14)` API called
13. **Status update received** → SDK triggers `onDeviceAuthManagementStatus` event with `opMode = 0`
14. **Success message displayed** → Alert: "Biometric Authentication has been disabled successfully"
15. **Dialog closed** → Returns to LDA Toggling screen
16. **Authentication details refreshed** → Switch widget shows disabled state
17. **User can now login with password** → LDA toggling completed successfully

### Scenario 3: No LDA Available
1. **User opens LDA Toggling screen** → `getDeviceAuthenticationDetails()` API called
2. **No authentication capabilities returned** → Empty list or no LDA enrolled on device
3. **Empty state displayed** → "No Local Device Authentication (LDA) capabilities are available"
4. **Refresh option available** → User can retry checking device capabilities
5. **Guidance provided** → Message suggests enrolling biometrics in device settings

## 📚 Advanced Resources

- **REL-ID LDA Toggling Documentation**: [LDA Toggling Guide](https://developer.uniken.com/docs/lda-toggling)
- **REL-ID getDeviceAuthenticationDetails API**: [Device Authentication Details](https://developer.uniken.com/docs/getdeviceauthenticationdetails)
- **REL-ID manageDeviceAuthenticationModes API**: [Manage Authentication Modes](https://developer.uniken.com/docs/managedeviceauthenticationmodes)
- **REL-ID onDeviceAuthManagementStatus Event**: [Auth Management Status](https://developer.uniken.com/docs/ondeviceauthmanagementstatus)
- **Flutter Switch Widget**: [Toggle Implementation](https://api.flutter.dev/flutter/material/Switch-class.html)
- **Flutter Dialogs**: [Dialog Patterns](https://api.flutter.dev/flutter/material/Dialog-class.html)

## 💡 Pro Tips

### LDA Toggling Implementation Best Practices
1. **Check device capabilities first** - Always call `getDeviceAuthenticationDetails()` before showing toggle interface
2. **Use unified dialog pattern** - Single `LDAToggleAuthDialog` handling modes 5, 14, 15, 16 simplifies maintenance
3. **Handle authentication type mappings** - Map numeric auth types to user-friendly names using `authTypeNames` map
4. **Provide clear user feedback** - Display loading states and success/error messages during toggling
5. **Implement proper error handling** - Handle errors gracefully with alerts and retry options
6. **Test challenge mode routing** - Ensure all challenge modes (5, 14, 15, 16) route correctly to dialog
7. **Optimize toggle interactions** - Use `_processingAuthType` state to prevent multiple simultaneous operations
8. **Preserve existing authentication** - Ensure toggling doesn't disrupt current user sessions
9. **Design intuitive UI** - Use Material Design Switch widgets with visible enabled/disabled states
10. **Handle edge cases** - Device capability changes, biometric removal, network interruptions

### Flutter-Specific Best Practices
11. **Use plugin enums correctly** - Convert int to `RDNALDACapabilities` enum: `RDNALDACapabilities.values[authType]`
12. **Convert challenge modes to enums** - Use `RDNAChallengeOpMode.values[challengeMode]` for setPassword()
13. **Handle null safety** - Use `??` operators and null checks for all SDK response fields
14. **Implement proper lifecycle** - Register event handlers in `initState()`, cleanup in `dispose()`
15. **Use ConsumerStatefulWidget** - For screens needing both Riverpod and local state
16. **Use Callback Preservation Pattern** - Preserve original handlers before overriding, restore on dispose
17. **NO try-catch for API calls** - Check `response.error?.longErrorCode` instead (Flutter plugin pattern)
18. **Auto-close dialogs on success** - Use `Navigator.of(context).pop()` after successful operations
19. **Pass onCancelled callback** - Reset processing state when dialog cancelled to stop spinners
20. **Test on real devices** - Verify with actual biometric hardware, not just simulators

### Security & Compliance
21. **Validate authentication state** - Always verify authentication changes on server side
22. **Implement secure revalidation** - Require password verification or consent for mode changes
23. **Audit authentication changes** - Log LDA toggling events for security monitoring
24. **Handle challenge modes securely** - Ensure proper routing for verification flows (modes 5, 14, 15, 16)
25. **Test security scenarios** - Verify toggling behavior under attack scenarios and unauthorized access attempts
26. **Follow platform guidelines** - Adhere to iOS and Android biometric authentication best practices
27. **Respect user privacy** - Never store or log biometric data, only authentication preferences
28. **Implement timeout handling** - Handle cases where users abandon revalidation flows
29. **Validate device integrity** - Ensure authentication mode changes occur on trusted devices
30. **Support graceful degradation** - Allow users to continue with alternate authentication if toggling fails

## 🔗 Key Implementation Files

### Core LDA Toggling Implementation

```dart
// rdna_service.dart - Device Authentication Details API
Future<RDNADeviceAuthenticationDetailsSyncResponse> getDeviceAuthenticationDetails() async {
  print('RdnaService - Getting device authentication details');

  final response = await _rdnaClient.getDeviceAuthenticationDetails();

  print('RdnaService - GetDeviceAuthenticationDetails sync response received');
  print('  Long Error Code: ${response.error?.longErrorCode}');
  print('  Authentication Capabilities: ${response.authenticationCapabilities?.length ?? 0}');

  return response;
}

// rdna_service.dart - Manage Authentication Modes API
Future<RDNASyncResponse> manageDeviceAuthenticationModes(
  bool isEnabled,
  RDNALDACapabilities authType
) async {
  print('RdnaService - Managing device authentication modes: isEnabled=$isEnabled, authType=$authType');

  final response = await _rdnaClient.manageDeviceAuthenticationModes(isEnabled, authType);

  print('RdnaService - ManageDeviceAuthenticationModes sync response received');
  print('  Long Error Code: ${response.error?.longErrorCode}');

  return response;
}
```

```dart
// rdna_event_manager.dart - Device Auth Management Status Event Handler
void _onDeviceAuthManagementStatus(dynamic authManagementData) {
  print('RdnaEventManager - Device auth management status event received');

  final statusData = authManagementData as RDNADeviceAuthManagementStatus;

  print('RdnaEventManager - Device auth management status data:');
  print('  User ID: ${statusData.userId}');
  print('  OpMode: ${statusData.opMode}');
  print('  LDA Type: ${statusData.ldaType}');
  print('  Status Code: ${statusData.status?.statusCode}');

  if (_deviceAuthManagementStatusHandler != null) {
    _deviceAuthManagementStatusHandler!(statusData);
  }
}
```

```dart
// lda_toggling_screen.dart - Callback Preservation Pattern
// LDATogglingScreen EXCLUSIVELY handles challenge modes 5, 14, 15, 16

@override
void initState() {
  super.initState();

  final eventManager = RdnaService.getInstance().getEventManager();

  // 1. Preserve SDKEventProvider's original handlers
  _originalPasswordHandler = eventManager.getPasswordHandler;
  _originalConsentHandler = eventManager.getUserConsentForLDAHandler;

  // 2. Set custom handlers for LDA toggling modes
  eventManager.setGetPasswordHandler(_handleGetPasswordForLDAToggling);
  eventManager.setGetUserConsentForLDAHandler(_handleGetUserConsentForLDAToggling);
}

// Custom handler for password events (modes 5, 14, 15)
void _handleGetPasswordForLDAToggling(RDNAGetPassword data) {
  if (data.challengeMode == 5 || data.challengeMode == 14 || data.challengeMode == 15) {
    print('LDATogglingScreen - Handling challengeMode ${data.challengeMode}');
    LDAToggleAuthDialog.show(
      context,
      challengeMode: data.challengeMode ?? 5,
      userID: data.userId ?? '',
      attemptsLeft: data.attemptsLeft ?? 3,
      passwordData: data,
      onCancelled: () {
        resetProcessingState();  // ← Stops spinner on cancel
      },
    );
  } else {
    // Pass other modes to original handler (SDKEventProvider)
    _originalPasswordHandler?.call(data);
  }
}

// Custom handler for consent events (mode 16)
void _handleGetUserConsentForLDAToggling(GetUserConsentForLDAData data) {
  if (data.challengeMode == 16) {
    print('LDATogglingScreen - Handling challengeMode 16 (LDA consent)');
    LDAToggleAuthDialog.show(
      context,
      challengeMode: data.challengeMode ?? 16,
      userID: data.userID ?? '',
      attemptsLeft: 1,
      consentData: data,
      onCancelled: () {
        resetProcessingState();  // ← Stops spinner on cancel
      },
    );
  } else {
    // Pass other modes to original handler (SDKEventProvider)
    _originalConsentHandler?.call(data);
  }
}

@override
void dispose() {
  final eventManager = RdnaService.getInstance().getEventManager();

  // 3. Restore original handlers
  eventManager.setGetPasswordHandler(_originalPasswordHandler);
  eventManager.setGetUserConsentForLDAHandler(_originalConsentHandler);

  super.dispose();
}
```

```dart
// sdk_event_provider.dart - Regular MFA Only (NO modes 5, 14, 15, 16)
// SDKEventProvider does NOT handle LDA toggling modes

void _handleGetPassword(RDNAGetPassword data) {
  print('SDKEventProvider - Get password event received');

  // Note: Modes 5, 14, 15 are handled by LDATogglingScreen exclusively
  // Only handle regular MFA modes here

  if (data.challengeMode == 0) {
    appRouter.goNamed('verifyPasswordScreen', extra: data);
  } else if (data.challengeMode == 2) {
    appRouter.goNamed('updatePasswordScreen', extra: {...});
  } else if (data.challengeMode == 4) {
    appRouter.goNamed('updateExpiryPasswordScreen', extra: data);
  } else {
    appRouter.goNamed('setPasswordScreen', extra: data);
  }
}

void _handleGetUserConsentForLDA(GetUserConsentForLDAData data) {
  print('SDKEventProvider - Get user consent for LDA event received');

  // Note: Mode 16 is handled by LDATogglingScreen exclusively
  // Navigate to full screen for regular MFA consent

  appRouter.goNamed('userLDAConsentScreen', extra: data);
}
```

## 🔑 NEW Challenge Modes for LDA Toggling

This codelab introduces **4 NEW challenge modes** specifically for LDA toggling workflows:

| Challenge Mode | Purpose | UI Type | Authentication |
|---------------|---------|---------|----------------|
| **5** | Password Verification | Dialog (single field) | Verify password to disable LDA |
| **14** | Password Creation | Dialog (two fields + policy) | Set password after disabling LDA |
| **15** | Password Verification | Dialog (single field) | Verify password to disable LDA (alt) |
| **16** | LDA Consent | Dialog (approve/reject) | Enable biometric authentication |

**Key Design Decision:** These modes use a **unified dialog** (`LDAToggleAuthDialog`) instead of full-screen navigation, keeping users in context of LDA toggling workflow.

## 🛠️ Challenge Mode Comparison

### Regular MFA Challenge Modes (Full-Screen Navigation)
- **Mode 0**: Password verification for login → `VerifyPasswordScreen`
- **Mode 1**: Password creation for registration → `SetPasswordScreen`
- **Mode 2**: User-initiated password update → `UpdatePasswordScreen`
- **Mode 4**: Expired password update → `UpdateExpiryPasswordScreen`

### LDA Toggling Challenge Modes (Dialog - Screen-Level Handling)
- **Mode 5**: Password verify to disable LDA → `LDAToggleAuthDialog` (via LDATogglingScreen)
- **Mode 14**: Password create after disabling LDA → `LDAToggleAuthDialog` (via LDATogglingScreen)
- **Mode 15**: Password verify to disable LDA (alt) → `LDAToggleAuthDialog` (via LDATogglingScreen)
- **Mode 16**: LDA consent to enable biometric → `LDAToggleAuthDialog` (via LDATogglingScreen)

**Important:** Modes 5, 14, 15, 16 are EXCLUSIVELY handled by LDATogglingScreen using Callback Preservation Pattern. SDKEventProvider does NOT handle these modes.

## 📊 Authentication Type Mappings

```dart
const Map<int, String> authTypeNames = {
  0: 'None',
  1: 'Biometric Authentication',  // RDNA_LDA_FINGERPRINT
  2: 'Face ID',                    // RDNA_LDA_FACE
  3: 'Pattern Authentication',     // RDNA_LDA_PATTERN
  4: 'Biometric Authentication',   // RDNA_LDA_SSKB_PASSWORD
  9: 'Biometric Authentication',   // RDNA_DEVICE_LDA
};
```

## 🎨 UI Components

### LDATogglingScreen Widget
- **Type**: `ConsumerStatefulWidget` (needs Riverpod + local state)
- **Purpose**: Display authentication capabilities with toggle switches
- **Features**:
  - Auto-load capabilities on mount
  - ListView with authentication items
  - Switch widgets for toggling
  - Loading and error states
  - Empty state when no LDA available
  - Drawer navigation support
  - Refresh button in AppBar

### LDAToggleAuthDialog Widget
- **Type**: `StatefulWidget` (modal dialog)
- **Purpose**: Unified dialog for all LDA toggling authentication challenges
- **Modes**:
  - **Password Mode** (5, 15): Single password field with attempts counter
  - **Password Create Mode** (14): Two password fields with policy display
  - **Consent Mode** (16): Auth type info with approve/reject buttons
- **Features**:
  - Dynamic UI based on challenge mode
  - Password visibility toggles
  - Error message display
  - Loading states
  - Auto-focus on inputs
  - Cancel button (sends rejection for mode 16)

## 🧪 Testing Scenarios

### Test Case 1: Enable LDA (First Time)
- **Given**: User has password-only authentication
- **When**: User toggles biometric ON
- **Then**:
  - Password verification dialog appears (mode 5)
  - After password → LDA consent dialog appears (mode 16)
  - After approval → "Biometric Authentication has been enabled"
  - Toggle shows enabled state

### Test Case 2: Disable LDA
- **Given**: User has LDA enabled
- **When**: User toggles biometric OFF
- **Then**:
  - Password verification dialog appears (mode 15)
  - After password → Password creation dialog appears (mode 14)
  - After creation → "Biometric Authentication has been disabled"
  - Toggle shows disabled state

### Test Case 3: Cancel During LDA Enable
- **Given**: Password verification dialog displayed (mode 5)
- **When**: User clicks Cancel button
- **Then**:
  - Dialog closes
  - Toggle returns to previous state
  - No authentication mode change occurs

### Test Case 4: Wrong Password During Toggle
- **Given**: User enters wrong password in dialog (mode 5 or 15)
- **When**: Password verification fails
- **Then**:
  - Error message displayed
  - Attempts counter decremented
  - Dialog stays open for retry
  - After max attempts → Session terminates

## 🐛 Common Issues & Solutions

### Issue 1: Dialog doesn't show for challenge modes 5, 14, 15, 16
**Solution**: Verify LDATogglingScreen's event handlers are set up correctly in `initState()`. Ensure `_handleGetPasswordForLDAToggling` and `_handleGetUserConsentForLDAToggling` are registered. These modes are handled EXCLUSIVELY by the screen, NOT by SDKEventProvider.

### Issue 2: Spinner keeps showing after dialog cancelled
**Solution**: Ensure `onCancelled` callback is passed to `LDAToggleAuthDialog.show()` and it calls `resetProcessingState()` to clear `_processingAuthType`.

### Issue 3: "Undefined name 'RDNAChallengeOpMode'" error
**Solution**: Import `package:rdna_client/rdna_struct.dart` and convert int to enum: `RDNAChallengeOpMode.values[challengeMode]`

### Issue 4: Toggle switch doesn't update after successful operation
**Solution**: Ensure `_handleAuthManagementStatusReceived` calls `_loadAuthenticationDetails()` to refresh capabilities.

### Issue 5: Drawer menu button doesn't open drawer
**Solution**: Add `drawer: DrawerContent(sessionData: _sessionData, currentRoute: 'ldaTogglingScreen')` to Scaffold and wrap menu IconButton in `Builder` widget.

### Issue 6: Dialog stacking (multiple dialogs open)
**Solution**: Close dialog after successful submission with `Navigator.of(context).pop()` before next dialog appears.

### Issue 7: Error 217 shown when user cancels consent
**Solution**: Handle error code 217 specially in `_handleAuthManagementStatusReceived` - silently refresh without showing error dialog.

---


**🎉 Congratulations!** You've successfully implemented LDA Toggling Management in Flutter using NEW challenge modes (5, 14, 15, 16) with a unified dialog pattern!
