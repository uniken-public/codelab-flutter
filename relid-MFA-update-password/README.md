# REL-ID Flutter Codelab: Password Update Management

[![Flutter](https://img.shields.io/badge/Flutter-3.38.4-blue.svg)](https://flutter.dev/)
[![REL-ID SDK](https://img.shields.io/badge/REL--ID%20SDK-v25.06.03-green.svg)](https://developer.uniken.com/)
[![Dart](https://img.shields.io/badge/Dart-3.10.3-blue.svg)](https://dart.dev/)
[![Password Update](https://img.shields.io/badge/Password%20Update-Enabled-blue.svg)]()
[![Challenge Mode 2](https://img.shields.io/badge/Challenge%20Mode-2-purple.svg)]()

> **Codelab Advanced:** Master user-initiated Password Update workflows with REL-ID SDK

This folder contains the source code for the solution demonstrating [REL-ID Password Update Management](https://codelab.uniken.com/codelabs/flutter-update-password-flow/index.html?index=..%2F..index#0) using secure user-initiated password update flows with credential availability checking, policy validation, and screen-level event handling.

## 🔐 What You'll Learn

In this advanced password update codelab, you'll master production-ready user-initiated password update patterns:

- ✅ **User-Initiated Updates**: Handle `challengeMode = 2` for dashboard password updates
- ✅ **Credential Availability Check**: `getAllChallenges()` and `initiateUpdateFlowForCredential()` APIs
- ✅ **Drawer Navigation Integration**: Conditional menu item based on credential availability
- ✅ **Screen-Level Event Handling**: `onUpdateCredentialResponse` with proper cleanup
- ✅ **SDK Event Chain**: `onUpdateCredentialResponse` status codes 100/110/153 trigger `onUserLoggedOff` → `getUser` events
- ✅ **Three-Field Password Input**: Current password, new password, and confirm password validation
- ✅ **Password Policy Validation**: Extract and enforce `RELID_PASSWORD_POLICY` requirements
- ✅ **State Management with Riverpod**: Provider-based state management for credential availability
- ✅ **Error Handling**: Comprehensive error checking with RDNASyncResponse validation
- ✅ **Critical Error Management**: Handle statusCode 110, 153, 190 with logout flows

## 🎯 Learning Objectives

By completing this Password Update codelab, you'll be able to:

1. **Implement credential availability checking** with `getAllChallenges()` API after login
2. **Initiate update flows** using `initiateUpdateFlowForCredential('Password')` API
3. **Handle screen-level events** with `onUpdateCredentialResponse` and proper dispose cleanup
4. **Build user-initiated update UI** with drawer navigation and conditional menu items
5. **Manage session persistence** without automatic login after password update
6. **Implement security best practices** with stateful widget lifecycle management
7. **Extract password policies** from `RELID_PASSWORD_POLICY` challenge data
8. **Create three-field password forms** with comprehensive validation rules
9. **Handle critical errors** with statusCode 110, 153, 190 logout scenarios
10. **Debug password update flows** and troubleshoot credential availability issues

## 🏗️ Prerequisites

Before starting this codelab, ensure you've completed:

- **[REL-ID MFA Codelab](https://codelab.uniken.com/codelabs/flutter-mfa-activation-login-flow/index.html?index=..%2F..index#0)** - Complete MFA implementation required
- Understanding of Flutter drawer navigation and conditional widget rendering
- Experience with Flutter form handling and multi-field validation
- Knowledge of REL-ID SDK event-driven architecture patterns
- Familiarity with password policy parsing and validation
- Basic understanding of authentication state management and error handling
- Understanding of Flutter widget lifecycle (`initState`, `dispose`, `setState`)

## 📁 Password Update Project Structure

```
relid-MFA-update-password/
├── 📱 Flutter MFA + Password Update App
│   ├── android/                 # Android-specific configuration
│   ├── ios/                     # iOS-specific configuration
│   └── rdna_client/             # REL-ID Flutter Plugin
│
├── 📦 Password Update Source Architecture
│   └── lib/
│       ├── tutorial/            # Enhanced MFA + Password Update flows
│       │   ├── navigation/      # Enhanced navigation with password update
│       │   │   └── app_router.dart          # GoRouter configuration with update route
│       │   └── screens/         # Enhanced screens with password update
│       │       ├── components/  # Enhanced UI components
│       │       │   ├── custom_button.dart           # Loading and disabled states
│       │       │   ├── custom_input.dart            # Password input with obscureText
│       │       │   ├── status_banner.dart           # Error and warning displays
│       │       │   ├── drawer_content.dart          # Drawer with conditional menu
│       │       │   └── ...                          # Other reusable components
│       │       ├── updatePassword/ # 🆕 Password Update Management
│       │       │   └── update_password_screen.dart  # 🆕 User-initiated update (challengeMode 2)
│       │       ├── mfa/         # 🔐 MFA screens
│       │       │   ├── dashboard_screen.dart        # Dashboard
│       │       │   ├── check_user_screen.dart       # User validation
│       │       │   └── ...                          # Other MFA screens
│       │       └── tutorial/    # Base tutorial screens
│       └── uniken/              # 🛡️ Enhanced REL-ID Integration
│           ├── providers/       # Enhanced providers with Riverpod
│           │   └── sdk_event_provider.dart          # Complete event handling
│           │                                        # - onCredentialsAvailableForUpdate
│           │                                        # - onUpdateCredentialResponse (fallback)
│           ├── services/        # 🆕 Enhanced SDK service layer
│           │   ├── rdna_service.dart                # Enhanced password update APIs
│           │   │                                    # - updatePassword(current, new, mode)
│           │   │                                    # - getAllChallenges(username)
│           │   │                                    # - initiateUpdateFlowForCredential(type)
│           │   └── rdna_event_manager.dart          # Complete event management
│           │                                        # - getPassword handler (challengeMode 2)
│           │                                        # - onUpdateCredentialResponse handler
│           │                                        # - onCredentialsAvailableForUpdate handler
│           └── utils/           # Helper utilities
│               ├── connection_profile_parser.dart  # Profile configuration
│               └── password_policy_utils.dart      # Password validation
│
└── 📚 Production Configuration
    ├── pubspec.yaml             # Dependencies
    └── analysis_options.yaml    # Linting rules
```

## 🚀 Quick Start

### Installation & Setup

```bash
# Navigate to the codelab folder
cd relid-MFA-update-password

# Ensure rdna_client plugin is in place
# (should be at root folder of this project - refer to Project Structure above)

# Install dependencies
flutter pub get

# Run the application
flutter run
# or for specific platform
flutter run -d android
flutter run -d ios
```

### Verify Password Update Features

Once the app launches, verify these password update capabilities:

1. ✅ Complete MFA flow and successful login to dashboard
2. ✅ `getAllChallenges()` called automatically after login
3. ✅ "🔑 Update Password" menu item appears in drawer navigation
4. ✅ Tapping menu item calls `initiateUpdateFlowForCredential('Password')`
5. ✅ UpdatePasswordScreen displays with three password fields (current, new, confirm)
6. ✅ Password policy extracted from `PASSWORD_POLICY_BKP` and displayed
7. ✅ Attempts counter displays remaining attempts
8. ✅ `updatePassword(current, new, RDNAChallengeOpMode.RDNA_OP_UPDATE_CREDENTIALS)` API integration
9. ✅ `onUpdateCredentialResponse` event handled within screen
10. ✅ Success navigates to dashboard (no automatic login)
11. ✅ Proper widget lifecycle management with `dispose()` cleanup
12. ✅ Error handling checks `response.error?.longErrorCode`

## 🎓 Learning Checkpoints

### Checkpoint 1: Password Update - Credential Availability
- [ ] I understand how `getAllChallenges()` checks for available credential updates after login
- [ ] I can implement `initiateUpdateFlowForCredential('Password')` to trigger update flow
- [ ] I know how to handle `onCredentialsAvailableForUpdate` event with options array
- [ ] I can create conditional menu items based on credential availability
- [ ] I understand the difference between credential update (mode 2) and password expiry (mode 4)

### Checkpoint 2: Password Update - Screen-Level Event Handling
- [ ] I can implement screen-level `onUpdateCredentialResponse` event handler
- [ ] I understand proper cleanup with `dispose()` method
- [ ] I know how to handle success (statusCode 0/100) vs error responses
- [ ] I can implement critical error handling (statusCode 110, 153, 190)
- [ ] I understand why screen-level handlers are used instead of global handlers

### Checkpoint 3: Password Update - User Experience
- [ ] I can implement drawer navigation integration for password update
- [ ] I know how to manage stateful widget lifecycle for password fields
- [ ] I understand the security benefits of proper state management
- [ ] I can display attempts counter and password policy requirements
- [ ] I know how to maintain user session (no automatic login) after update

### Checkpoint 4: UpdatePassword API Implementation
- [ ] I can implement `updatePassword(current, new, RDNAChallengeOpMode.RDNA_OP_UPDATE_CREDENTIALS)` API
- [ ] I understand three-field validation (current, new, confirm passwords)
- [ ] I can extract password policy from challenge data (`PASSWORD_POLICY_BKP`)
- [ ] I know how to validate new password differs from current password
- [ ] I can handle loading states during password update operations

### Checkpoint 5: Password Policy Validation
- [ ] I can parse password policy JSON from challenge data
- [ ] I understand password policy fields (minL, maxL, minDg, minUc, minLc, minSc, etc.)
- [ ] I can display user-friendly policy requirements to users
- [ ] I know how to handle UserIDcheck as boolean or string "true"
- [ ] I can debug policy validation issues and policy parsing errors

### Checkpoint 6: Production Password Update
- [ ] I understand security best practices for password update implementations
- [ ] I can implement comprehensive error handling for password update failures
- [ ] I know how to optimize user experience with clear policy messaging
- [ ] I understand user stays logged in after successful password update (no automatic login)
- [ ] I understand compliance and audit requirements for password update workflows

## 🔄 Password Update User Flows

### Scenario 1: Standard Password Update Flow
1. **User logs in successfully** → Reaches dashboard after MFA completion
2. **getAllChallenges() called** → Automatic check for available credential updates
3. **onCredentialsAvailableForUpdate triggered** → Options array includes "Password"
4. **Drawer menu shows "🔑 Update Password"** → Conditional menu item appears
5. **User taps Update Password** → `initiateUpdateFlowForCredential('Password')` called
6. **SDK triggers getPassword** → `challengeMode = 2` (RDNA_OP_UPDATE_CREDENTIALS)
7. **Navigation to UpdatePasswordScreen** → Drawer navigation with three password fields
8. **Password policy displayed** → Extracted from `RELID_PASSWORD_POLICY` challenge data
9. **User enters passwords** → Current, new, and confirm password inputs
10. **Validation checks** → New password differs from current, passwords match, policy compliance
11. **Password updated** → `updatePassword(current, new, RDNAChallengeOpMode.RDNA_OP_UPDATE_CREDENTIALS)` API called
12. **onUpdateCredentialResponse** → Screen-level handler processes success response (statusCode 100)
13. **SDK event chain triggered** → `onUpdateCredentialResponse` with statusCode 100 causes SDK to trigger `onUserLoggedOff` → `getUser` events
14. **User navigates to dashboard** → Navigate back to dashboard after success alert
15. **Widget lifecycle** → Event handlers properly cleaned up in `dispose()`

### Scenario 2: Password Update with Critical Error
1. **User in UpdatePasswordScreen** → Three password fields displayed
2. **User enters passwords** → Attempts to update password
3. **Password update attempted** → `updatePassword(current, new, mode)` API called
4. **Critical error occurs** → `onUpdateCredentialResponse` receives statusCode 153 (Attempts exhausted)
5. **onUpdateCredentialResponse handler** → Detects critical error (110, 153, 190)
6. **Error displayed with field clearing** → All password fields reset via `setState()`
7. **SDK event chain triggered** → `onUpdateCredentialResponse` with statusCode 153 causes SDK to trigger `onUserLoggedOff` → `getUser` events
8. **onUserLoggedOff event** → Handled by SDKEventProvider
9. **getUser event** → Handled by SDKEventProvider
10. **Navigation to home** → User returns to login screen via GoRouter

**Important Note - SDK Event Chain & Status Codes**:

The `onUpdateCredentialResponse` event returns specific status codes that trigger automatic SDK event chains. When this event receives status codes 100, 110, or 153, the SDK automatically triggers `onUserLoggedOff` → `getUser` event chain:

- **statusCode 100**: Password updated successfully - SDK triggers event chain after success
- **statusCode 110**: Password has expired while updating password - SDK triggers event chain leading to logout
- **statusCode 153**: Attempts exhausted - SDK triggers event chain leading to logout

**Important**: These status codes (100, 110, 153) are specific to `onUpdateCredentialResponse` event only and do not apply to other SDK events. This automatic event chain is part of the REL-ID SDK's credential update flow and ensures proper session management after password update operations.

## 📚 Advanced Resources

- **REL-ID Password Update Documentation**: [Update Credentials API Guide](https://developer.uniken.com/docs/update-credentials)
- **REL-ID Challenge Modes**: [Understanding Challenge Modes](https://developer.uniken.com/docs/challenge-modes)
- **Flutter Navigation**: [GoRouter Documentation](https://pub.dev/packages/go_router)
- **Flutter State Management**: [Riverpod Guide](https://riverpod.dev/)

## 💡 Pro Tips

### Password Update Implementation Best Practices
1. **Check credential availability** - Call `getAllChallenges()` after login to check available updates
2. **Conditional menu display** - Show "Update Password" only when `onCredentialsAvailableForUpdate` includes "Password"
3. **Screen-level event handlers** - Use screen-level `onUpdateCredentialResponse` with `dispose()` cleanup
4. **Widget lifecycle management** - Clear password fields and dispose handlers properly
5. **No automatic login** - User stays logged in after update
6. **Handle critical errors** - Detect statusCode 110, 153, 190 for logout scenarios
7. **Drawer integration** - Place UpdatePasswordScreen in drawer navigation via GoRouter
8. **Loading state management** - Handle loading state for `initiateUpdateFlowForCredential`
9. **Error checking** - Use `response.error?.longErrorCode == 0` pattern (no try-catch)
10. **Test drawer navigation** - Ensure proper parameter passing via GoRouter extra

### Integration & Development
11. **Preserve existing MFA flows** - Password update should enhance, not disrupt existing authentication
12. **Use plugin data classes** - Leverage `RDNASyncResponse`, `RDNAGetPassword`, `RDNAUpdateCredentialResponse`
13. **Implement comprehensive logging** - Log flow progress for debugging without exposing passwords
14. **Test with various policies** - Ensure password update works with different password policy configurations
15. **Monitor user experience metrics** - Track password update success rates and policy compliance
16. **Extract password policy** - Always extract `RELID_PASSWORD_POLICY` from challenge data
17. **Clear fields on errors** - Implement automatic field clearing via `setState()`
18. **Validate password differences** - Ensure new password differs from current password
19. **Display policy requirements** - Show parsed policy requirements to users before input
20. **Three-field validation** - Validate current, new, and confirm passwords with proper error messages

### Security & Compliance
21. **Enforce password policies** - Always validate passwords against server-provided policy requirements
22. **Handle password history** - Respect server-configured password history limits
23. **Audit password changes** - Log password update events for security monitoring
24. **Ensure secure transmission** - All password communications should use secure channels
25. **Test security scenarios** - Verify password update security under various attack scenarios
26. **Clear sensitive data** - Implement proper widget disposal and state clearing
27. **Secure sensitive operations** - Never log or expose passwords in console or error messages
28. **Handle loading states** - Show clear loading indicators during password update operations

## 🔗 Key Implementation Files

```dart
// rdna_service.dart - Credential Update APIs
Future<RDNASyncResponse> getAllChallenges(String username) async {
  print('RdnaService - Getting all available challenges for user: $username');

  final response = await _rdnaClient.getAllChallenges(username);

  print('RdnaService - Sync response:');
  print('  Long Error Code: ${response.error?.longErrorCode}');

  return response;
}

Future<RDNASyncResponse> initiateUpdateFlowForCredential(String credentialType) async {
  print('RdnaService - Initiating update flow for credential: $credentialType');

  final response = await _rdnaClient.initiateUpdateFlowForCredential(credentialType);

  print('RdnaService - Sync response:');
  print('  Long Error Code: ${response.error?.longErrorCode}');

  return response;
}
```

```dart
// sdk_event_provider.dart - Automatic getAllChallenges after login
void _handleUserLoggedIn(RDNAUserLoggedIn data) async {
  // Navigate to dashboard
  context.go('/dashboard', extra: data);

  // Call getAllChallenges after login
  try {
    await _rdnaService.getAllChallenges(data.userId ?? '');
  } catch (error) {
    print('SDKEventProvider - getAllChallenges failed: $error');
  }
}

// Handle challengeMode 2 for password update
void _handleGetPassword(RDNAGetPassword data) {
  if (data.challengeMode == RDNAChallengeOpMode.RDNA_OP_UPDATE_CREDENTIALS.index) {
    context.go('/update-password', extra: {
      'eventData': data,
      'responseData': data,
    });
  }
}
```

```dart
// drawer_content.dart - Conditional menu item
final isPasswordUpdateAvailable = ref.watch(availableCredentialsProvider)
    .contains('Password');

if (isPasswordUpdateAvailable)
  ListTile(
    leading: Icon(Icons.lock_outline),
    title: Text('🔑 Update Password'),
    onTap: () async {
      setState(() => _isInitiatingUpdate = true);
      try {
        await rdnaService.initiateUpdateFlowForCredential('Password');
      } catch (error) {
        showDialog(/* error dialog */);
      } finally {
        setState(() => _isInitiatingUpdate = false);
      }
    },
  ),
```

```dart
// update_password_screen.dart - Screen-level event handler
@override
void initState() {
  super.initState();
  _setupEventHandlers();
}

void _setupEventHandlers() {
  final eventManager = _rdnaService.getEventManager();

  eventManager.setUpdateCredentialResponseHandler((data) {
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    final statusCode = data.status?.statusCode ?? -1;

    // IMPORTANT: onUpdateCredentialResponse event with statusCode 100, 110, or 153
    // causes the SDK to automatically trigger onUserLoggedOff → getUser event chain
    // These status codes are specific to onUpdateCredentialResponse event only:
    // - 100: Password updated successfully
    // - 110: Password has expired while updating password
    // - 153: Attempts exhausted

    if (statusCode == 100 || statusCode == 0) {
      // statusCode 100 = Password updated successfully
      _showSuccessDialog(data.status?.statusMessage ?? 'Password updated');
      // SDK will trigger onUserLoggedOff → getUser after this
    } else if (statusCode == 110 || statusCode == 153) {
      // statusCode 110/153 = Password expired/Attempts exhausted
      _resetInputs();
      setState(() => _error = data.status?.statusMessage ?? 'Update failed');
      // SDK will trigger onUserLoggedOff → getUser, leading to logout
    } else {
      _resetInputs();
      setState(() => _error = data.status?.statusMessage ?? 'Update failed');
    }
  });
}

@override
void dispose() {
  // Cleanup event handler
  _rdnaService.getEventManager().setUpdateCredentialResponseHandler(null);
  super.dispose();
}
```

---

**🔐 Congratulations! You've mastered Password Update Management with REL-ID SDK!**

*You're now equipped to implement user-initiated password update flows with:*

- **Credential Availability Checking**: Automatic checking after login with `getAllChallenges()`
- **Conditional Menu Display**: Show update option only when available
- **Screen-Level Event Handling**: Proper `onUpdateCredentialResponse` handling with cleanup
- **Security Best Practices**: Proper widget lifecycle and state management
- **Seamless User Experience**: User stays logged in after successful password update

*Use this knowledge to create secure, user-friendly password update experiences that empower users to proactively manage their account security!*
