# REL-ID Flutter Codelab: Password Expiry Management

[![Flutter](https://img.shields.io/badge/Flutter-3.10.3-blue.svg)](https://flutter.dev/)
[![REL-ID SDK](https://img.shields.io/badge/REL--ID%20SDK-v25.8.1-green.svg)](https://developer.uniken.com/)
[![Dart](https://img.shields.io/badge/Dart-3.10.3-blue.svg)](https://dart.dev/)
[![Password Expiry](https://img.shields.io/badge/Password%20Expiry-Enabled-orange.svg)]()
[![Challenge Mode 4](https://img.shields.io/badge/Challenge%20Mode-4-purple.svg)]()

> **Codelab Advanced:** Master Password Expiry workflows with REL-ID SDK updatePassword API

This folder contains the source code for the solution demonstrating [REL-ID Password Expiry Management](https://codelab.uniken.com/codelabs/flutter-password-expiry-flow/index.html?index=..%2F..index#0) using secure expired password update flows with password reuse detection.

## 🔐 What You'll Learn

In this advanced password expiry codelab, you'll master production-ready expired password update patterns:

- ✅ **Password Expiry Detection**: Handle `challengeMode = 4` (RDNA_OP_UPDATE_ON_EXPIRY) when password expires during login
- ✅ **UpdatePassword API Integration**: `updatePassword(current, new, RDNAChallengeOpMode.RDNA_OP_UPDATE_ON_EXPIRY)` API implementation
- ✅ **Three-Field Password Input**: Current password, new password, and confirm password validation
- ✅ **Password Policy Validation**: Extract and enforce `RELID_PASSWORD_POLICY` requirements
- ✅ **Password Reuse Detection**: Handle statusCode 164 errors with automatic field clearing
- ✅ **Automatic Login**: Seamless `onUserLoggedIn` event handling after successful password update
- ✅ **Event-Driven Architecture**: Handle password expiry event chain with proper error recovery

## 🎯 Learning Objectives

By completing this Password Expiry Management codelab, you'll be able to:

1. **Detect password expiry scenarios** and handle `RDNAChallengeOpMode.RDNA_OP_UPDATE_ON_EXPIRY` routing
2. **Implement updatePassword API** with current and new password validation
3. **Build expired password update flows** with automatic field clearing on errors
4. **Handle password reuse detection** with statusCode 164 error management
5. **Extract password policies** from `RELID_PASSWORD_POLICY` challenge data
6. **Create three-field password forms** with comprehensive validation rules
7. **Debug password expiry flows** and troubleshoot policy validation issues

## 🏗️ Prerequisites

Before starting this codelab, ensure you've completed:

- **[REL-ID MFA Flutter Codelab](https://codelab.uniken.com/codelabs/flutter-mfa-activation-login-flow/index.html?index=..%2F..index#0)** - Complete MFA implementation required
- Understanding of password verification flows and challenge modes
- Experience with Flutter form handling and multi-field validation
- Knowledge of REL-ID SDK event-driven architecture patterns
- Familiarity with password policy parsing and validation
- Basic understanding of authentication state management and error handling

## 📁 Password Expiry Management Project Structure

```
relid-MFA-password-expiry/
├── 📱 Enhanced Flutter MFA + Password Expiry App
│   ├── android/                 # Android-specific configuration
│   ├── ios/                     # iOS-specific configuration
│   └── rdna_client/             # REL-ID Flutter Plugin
│
├── 📦 Password Expiry Source Architecture
│   └── lib/
│       ├── tutorial/            # Enhanced MFA + Password Expiry flow
│       │   ├── navigation/      # Enhanced navigation with password expiry support
│       │   │   └── app_router.dart          # GoRouter navigation + UpdateExpiryPasswordScreen
│       │   └── screens/         # Enhanced screens with password expiry
│       │       ├── components/  # Enhanced UI components
│       │       │   ├── custom_button.dart           # Loading and disabled states
│       │       │   ├── custom_input.dart            # Password input with masking
│       │       │   ├── status_banner.dart           # Error and warning displays
│       │       │   └── ...                          # Other reusable components
│       │       ├── mfa/         # 🔐 MFA screens + Password Expiry
│       │       │   ├── update_expiry_password_screen.dart  # 🆕 Expired password update (challengeMode 4)
│       │       │   ├── verify_password_screen.dart  # Password verification with forgot password
│       │       │   ├── set_password_screen.dart     # Password creation with policy validation
│       │       │   ├── check_user_screen.dart       # Enhanced user validation
│       │       │   ├── dashboard_screen.dart        # Enhanced dashboard
│       │       │   └── ...                          # Other MFA screens
│       │       ├── notification/ # Notification Management System
│       │       │   ├── get_notifications_screen.dart # Server notification management
│       │       │   └── index.dart                    # Notification exports
│       │       └── tutorial/    # Base tutorial screens
│       └── uniken/              # 🛡️ Enhanced REL-ID Integration
│           ├── providers/       # Enhanced providers
│           │   └── sdk_event_provider.dart          # Complete event handling
│           ├── services/        # 🆕 Enhanced SDK service layer
│           │   ├── rdna_service.dart                # Added updatePassword API
│           │   │                                   # - updatePassword(current, new, mode)
│           │   │                                   # - setPassword() for creation
│           │   │                                   # - forgotPassword() for reset
│           │   └── rdna_event_manager.dart         # Complete event management
│           │                                       # - getPassword handler (challengeMode 4)
│           │                                       # - onUserLoggedIn handler
│           ├── utils/           # Helper utilities
│           │   ├── connection_profile_parser.dart  # Profile configuration
│           │   └── password_policy_utils.dart      # Password validation
│           └── cp/              # Connection Profile
│               └── agent_info.json                 # SDK configuration
│
└── 📚 Production Configuration
    ├── pubspec.yaml             # Dependencies
    ├── analysis_options.yaml    # Linting rules
    └── README.md               # This file
```

## 🚀 Quick Start

### Installation & Setup

```bash
# Navigate to the codelab folder
cd relid-MFA-password-expiry

# Place the rdna_client plugin folder at root folder of this project

# Install dependencies
flutter pub get

# Run the application
flutter run
# or for specific platform
flutter run -d android
flutter run -d ios
```

### Verify Password Expiry Features

Once the app launches, verify these password expiry capabilities:

1. ✅ Complete MFA flow available (prerequisite from previous codelab)
2. ✅ Login with expired password triggers `getPassword` event with `challengeMode = 4`
3. ✅ UpdateExpiryPasswordScreen displays three password fields (current, new, confirm)
4. ✅ Password policy extracted from `RELID_PASSWORD_POLICY` and displayed
5. ✅ Password reuse detection (statusCode 164) with automatic field clearing
6. ✅ `updatePassword()` API integration with comprehensive validation
7. ✅ Automatic login via `onUserLoggedIn` event after successful password update

## 🎓 Learning Checkpoints

### Checkpoint 1: Password Expiry Detection
- [ ] I understand how SDK triggers `getPassword` with `challengeMode = 4` for expired passwords
- [ ] I can route challengeMode 4 to UpdateExpiryPasswordScreen in SDKEventProvider
- [ ] I know how to extract statusMessage from response data (e.g., statusCode 118)
- [ ] I can handle loading states and error scenarios during password expiry detection
- [ ] I understand the security implications of password expiry workflows

### Checkpoint 2: UpdatePassword API Implementation
- [ ] I can implement `updatePassword(current, new, RDNAChallengeOpMode.RDNA_OP_UPDATE_ON_EXPIRY)` with proper sync response handling
- [ ] I understand three-field validation (current, new, confirm passwords)
- [ ] I can extract `RELID_PASSWORD_POLICY` from challenge data and parse policy requirements
- [ ] I know how to validate new password differs from current password
- [ ] I can handle loading states during password update operations

### Checkpoint 3: Password Reuse Detection
- [ ] I understand statusCode 164 indicates password reuse error
- [ ] I can implement automatic TextEditingController clearing when errors occur
- [ ] I know how to display user-friendly error messages for password reuse
- [ ] I can handle both API errors and status errors with field clearing
- [ ] I understand server-configured password history limits

### Checkpoint 4: Password Policy Validation
- [ ] I can parse RELID_PASSWORD_POLICY JSON from challenge data
- [ ] I understand password policy fields (minL, maxL, minDg, minUc, minLc, minSc, etc.)
- [ ] I can display user-friendly policy requirements to users using Flutter widgets
- [ ] I know how to handle UserIDcheck as boolean or string "true"
- [ ] I can debug policy validation issues and policy parsing errors

### Checkpoint 5: Production Password Expiry Management
- [ ] I understand security best practices for password expiry implementations
- [ ] I can implement comprehensive error handling for password update failures
- [ ] I know how to optimize user experience with clear policy messaging
- [ ] I can handle automatic login via `onUserLoggedIn` after successful update
- [ ] I understand compliance and audit requirements for password expiry workflows

## 🔄 Password Expiry User Flow

### Scenario 1: Standard Password Expiry Flow
1. **User enters credentials** → Login with `challengeMode = 0` (password verification)
2. **Password expired** → Server detects expired password (statusCode 118)
3. **SDK triggers getPassword** → `challengeMode = 4` (RDNA_OP_UPDATE_ON_EXPIRY)
4. **Navigation to UpdateExpiryPasswordScreen** → Three password fields displayed
5. **Password policy displayed** → Extracted from `RELID_PASSWORD_POLICY` challenge data
6. **User enters passwords** → Current, new, and confirm password inputs
7. **Validation checks** → New password differs from current, passwords match, policy compliance
8. **Password updated** → `updatePassword(current, new, RDNAChallengeOpMode.RDNA_OP_UPDATE_ON_EXPIRY)` API called
9. **Automatic login** → SDK triggers `onUserLoggedIn` event
10. **User reaches dashboard** → Password expiry flow completed successfully

### Scenario 2: Password Reuse Detection
1. **User enters UpdateExpiryPasswordScreen** → Three password fields displayed
2. **User enters previous password** → Password that was used recently
3. **Password update attempted** → `updatePassword()` API called
4. **Password reuse detected** → Server returns statusCode 164
5. **SDK re-triggers getPassword** → `challengeMode = 4` with error statusCode 164
6. **Error displayed with field clearing** → "Please enter a new password as your entered password has been used by you previously. You are not allowed to use last N passwords."
7. **All fields cleared automatically** → Current, new, and confirm password TextEditingControllers reset
8. **User enters different password** → Must select password not in history
9. **Password updated successfully** → `updatePassword()` API succeeds
10. **Automatic login** → SDK triggers `onUserLoggedIn` event

### Scenario 3: Password Policy Violation
1. **User enters UpdateExpiryPasswordScreen** → Password policy requirements displayed
2. **User enters weak password** → Password doesn't meet policy requirements
3. **Password update attempted** → `updatePassword()` API called
4. **Policy validation fails** → Server returns error with policy violation details
5. **Error displayed** → Specific policy requirement not met shown to user
6. **Fields cleared** → All password fields reset for retry
7. **User enters compliant password** → Password meeting all policy requirements
8. **Password updated successfully** → `updatePassword()` API succeeds

## 📚 Advanced Resources

- **REL-ID Password Expiry Documentation**: [Password Expiry API Guide](https://developer.uniken.com/docs/password-expiry)
- **REL-ID Challenge Modes**: [Understanding Challenge Modes](https://developer.uniken.com/docs/challenge-modes)
- **Flutter Form Handling**: [Secure Form Implementation](https://docs.flutter.dev/cookbook/forms)

## 💡 Pro Tips

### Password Expiry Implementation Best Practices
1. **Detect challengeMode 4** - Route `RDNAChallengeOpMode.RDNA_OP_UPDATE_ON_EXPIRY` from `getPassword` event to UpdateExpiryPasswordScreen
2. **Extract password policy** - Always extract `RELID_PASSWORD_POLICY` from challenge data using RDNAEventUtils
3. **Clear fields on errors** - Implement automatic TextEditingController clearing for both API and status errors
4. **Handle password reuse** - Detect statusCode 164 and provide clear user guidance
5. **Validate password differences** - Ensure new password differs from current password
6. **Display policy requirements** - Show parsed policy requirements using Flutter Container widgets before input
7. **Three-field validation** - Validate current, new, and confirm passwords with proper error messages
8. **Handle loading states** - Show CircularProgressIndicator during password update operations
9. **Secure sensitive operations** - Never log or expose passwords in console or error messages
10. **Test edge cases** - Password reuse, policy violations, network failures, expired sessions

### Integration & Development
11. **Preserve existing MFA flows** - Password expiry should enhance, not disrupt existing authentication
12. **Use proper Dart types** - Leverage `RDNASyncResponse` and `RDNAGetPassword` for type safety
13. **Implement comprehensive logging** - Log flow progress for debugging without exposing passwords
14. **Test with various policies** - Ensure password update works with different password policy configurations
15. **Monitor user experience metrics** - Track password expiry success rates and policy compliance
16. **Use ConsumerStatefulWidget** - Combine Riverpod state management with local widget state for complex forms
17. **Implement FocusNode management** - Provide smooth keyboard navigation between password fields
18. **Use TextEditingController** - Properly manage and dispose text field controllers

### Security & Compliance
19. **Enforce password policies** - Always validate passwords against server-provided policy requirements
20. **Handle password history** - Respect server-configured password history limits (e.g., last 5 passwords)
21. **Audit password changes** - Log password expiry and update events for security monitoring
22. **Ensure secure transmission** - All password communications should use secure channels
23. **Test security scenarios** - Verify password expiry security under various attack scenarios
24. **Use obscureText properly** - Implement password visibility toggles with proper state management
25. **Validate on blur and submit** - Provide real-time feedback without compromising security

## 🔗 Key Implementation Files

### Core Password Expiry Implementation
```dart
// rdna_service.dart - UpdatePassword API
Future<RDNASyncResponse> updatePassword(
  String currentPassword,
  String newPassword,
  RDNAChallengeOpMode challengeMode
) async {
  print('RdnaService - Updating expired password (challengeMode: $challengeMode)');

  final response = await _rdnaClient.updatePassword(
    currentPassword,
    newPassword,
    challengeMode
  );

  print('RdnaService - UpdatePassword sync response received');
  print('  Long Error Code: ${response.error?.longErrorCode}');

  return response;
}
```

```dart
// sdk_event_provider.dart - ChallengeMode 4 Routing
void _handleGetPassword(RDNAGetPassword data) {
  if (data.challengeMode == 0) {
    // Mode 0: Verify existing password (login)
    appRouter.goNamed('verifyPasswordScreen', extra: data);
  } else if (data.challengeMode == 4) {
    // Mode 4: Update expired password (password expiry flow)
    print('SDKEventProvider - Routing to UpdateExpiryPasswordScreen (challengeMode 4)');
    appRouter.goNamed('updateExpiryPasswordScreen', extra: data);
  } else {
    // Mode 1 or other: Set new password
    appRouter.goNamed('setPasswordScreen', extra: data);
  }
}
```

### Password Policy Extraction
```dart
// update_expiry_password_screen.dart - Password Policy Extraction
void _processEventData() {
  if (widget.eventData == null) return;

  final responseData = widget.eventData!;

  // Extract password policy from challenge data
  final policyJsonString = RDNAEventUtils.getChallengeValue(
    responseData.challengeResponse?.challengeInfo,
    'RELID_PASSWORD_POLICY',
  );
  if (policyJsonString != null) {
    final policyMessage = parseAndGeneratePolicyMessage(policyJsonString);
    setState(() {
      _passwordPolicyMessage = policyMessage;
    });
  }

  // Handle errors with automatic field clearing
  if (RDNAEventUtils.hasStatusError(responseData.challengeResponse?.status)) {
    final errorMessage = RDNAEventUtils.getErrorMessage(
      responseData.error,
      responseData.challengeResponse?.status
    );
    setState(() {
      _error = errorMessage;
      _isSubmitting = false; // Stop loading spinner
    });
    _clearPasswordFields();
  }
}
```

### Flutter-Specific Password Input
```dart
// Three password fields with visibility toggles and keyboard navigation
CustomInput(
  label: 'Current Password',
  value: _currentPasswordController.text,
  onChanged: _onCurrentPasswordChanged,
  placeholder: 'Enter current password',
  obscureText: _obscureCurrentPassword,
  enabled: !_isSubmitting,
  focusNode: _currentPasswordFocusNode,
  textInputAction: TextInputAction.next,
  onSubmitted: () => _newPasswordFocusNode.requestFocus(),
  suffixIcon: IconButton(
    icon: Icon(
      _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
      color: const Color(0xFF7f8c8d),
    ),
    onPressed: () {
      setState(() {
        _obscureCurrentPassword = !_obscureCurrentPassword;
      });
    },
  ),
)
```

---

**🔐 Congratulations! You've mastered Password Expiry Management with REL-ID SDK in Flutter!**

*You're now equipped to implement secure, user-friendly expired password update workflows with password reuse detection. Use this knowledge to create seamless password expiry experiences that enhance security while providing excellent user convenience during password expiration scenarios.*
