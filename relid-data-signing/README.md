# REL-ID Flutter Codelab: Cryptographic Data Signing

[![Flutter](https://img.shields.io/badge/Flutter-3.10.3-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0-blue.svg)](https://dart.dev/)
[![REL-ID SDK](https://img.shields.io/badge/REL--ID%20SDK-Latest-green.svg)](https://developer.uniken.com/)
[![Data Signing](https://img.shields.io/badge/Data%20Signing-Enabled-orange.svg)]()
[![Biometric Auth](https://img.shields.io/badge/Biometric%20Auth-Level%204-purple.svg)]()
[![Step-up Authentication](https://img.shields.io/badge/Step--up%20Auth-Password%20Challenge-red.svg)]()

> **Codelab Advanced:** Master cryptographic data signing with REL-ID SDK authentication levels

This folder contains the source code for the solution demonstrating [REL-ID Data Signing](https://codelab.uniken.com/codelabs/flutter-data-signing-flow/index.html?index=..%2F..index#3) using secure cryptographic authentication with multi-level biometric and password verification.

## 🔐 What You'll Learn

In this advanced data signing codelab, you'll master production-ready cryptographic signing patterns:

- ✅ **Data Signing API Integration**: `authenticateUserAndSignData()` API with authentication level handling
- ✅ **Authentication Level Mastery**: Understanding supported levels (0, 1, 4) and their security implications
- ✅ **Authenticator Type Selection**: NONE and IDV Server Biometric type implementations
- ✅ **Step-Up Authentication Flow**: Password challenges for Level 4 biometric verification
- ✅ **State Management**: `resetAuthenticateUserAndSignDataState()` for proper cleanup
- ✅ **Event-Driven Architecture**: Handle `onAuthenticateUserAndSignData` callbacks
- ✅ **Cryptographic Result Handling**: Signature verification and display patterns

## 🎯 Learning Objectives

By completing this Data Signing codelab, you'll be able to:

1. **Implement secure data signing workflows** with proper authentication level selection
2. **Handle multi-level authentication** from basic re-auth to step-up biometric verification
3. **Build cryptographic signing interfaces** with real-time validation and user feedback
4. **Create seamless authentication flows** with password challenges and biometric prompts
5. **Design secure state management** with proper cleanup and reset patterns
6. **Integrate data signing functionality** with existing MFA authentication workflows
7. **Debug authentication flows** and troubleshoot signing-related security issues

## 🏗️ Prerequisites

Before starting this codelab, ensure you've completed:

- **[REL-ID MFA Codelab](https://codelab.uniken.com/codelabs/flutter-mfa-activation-login-flow/index.html?index=..%2F..index#0)** - Complete MFA implementation required
- Understanding of authentication levels and biometric verification
- Experience with Flutter form handling and secure input management
- Knowledge of REL-ID SDK event-driven architecture patterns
- Familiarity with cryptographic concepts and digital signatures
- Basic understanding of authentication state management and cleanup

## 📁 Data Signing Project Structure

```
relid-data-signing/
├── 📱 Flutter MFA + Data Signing App
│   ├── android/                 # Android-specific configuration
│   ├── ios/                     # iOS-specific configuration
│   └── rdna_client/             # REL-ID Flutter Plugin (symlinked)
│
├── 📦 Data Signing Source Architecture
│   └── lib/
│       ├── tutorial/            # Data Signing Implementation
│       │   ├── navigation/      # Enhanced navigation with data signing support
│       │   │   └── app_router.dart              # GoRouter + Data Signing routes
│       │   ├── screens/         # Data Signing Screens
│       │   │   ├── components/  # Enhanced UI components
│       │   │   │   ├── button.dart                  # Loading and disabled states
│       │   │   │   ├── input.dart                   # Secure input with validation
│       │   │   │   ├── status_banner.dart           # Success and error displays
│       │   │   │   └── ...                          # Other reusable components
│       │   │   └── data_signing/ # 🔐 Data Signing Flow
│       │   │       ├── data_signing_input_screen.dart    # 🆕 Main signing interface
│       │   │       ├── data_signing_result_screen.dart   # 🆕 Signature results display
│       │   │       ├── data_signing_service.dart         # 🆕 Service layer
│       │   │       │                                    # - signData() wrapper
│       │   │       │                                    # - submitPassword() for step-up
│       │   │       │                                    # - resetState() cleanup
│       │   │       │                                    # - validateSigningInput()
│       │   │       │                                    # - formatSigningResultForDisplay()
│       │   │       ├── dropdown_data_service.dart        # 🆕 Dropdown data
│       │   │       │                                    # - getAuthLevelOptions()
│       │   │       │                                    # - getAuthenticatorTypeOptions()
│       │   │       │                                    # - convertAuthLevelToInt()
│       │   │       │                                    # - convertAuthenticatorTypeToInt()
│       │   │       ├── data_signing_types.dart           # 🆕 Type definitions
│       │   │       │                                    # - DataSigningRequest class
│       │   │       │                                    # - DataSigningResponse class
│       │   │       │                                    # - DataSigningFormState class
│       │   │       │                                    # - PasswordModalState class
│       │   │       └── components/                       # Signing-specific components
│       │   │           └── password_challenge_modal.dart      # Step-up auth modal (Cordova-style)
│       └── uniken/              # 🛡️ Enhanced REL-ID Integration
│           ├── providers/       # Enhanced providers
│           │   └── sdk_event_provider.dart        # Complete data signing event handling
│           │                                     # - onAuthenticateUserAndSignData handler
│           │                                     # - getPassword step-up handler
│           │                                     # - State management integration
│           ├── services/        # 🆕 Enhanced SDK service layer
│           │   ├── rdna_service.dart             # Added data signing APIs
│           │   │                                # - authenticateUserAndSignData()
│           │   │                                # - resetAuthenticateUserAndSignDataState()
│           │   │                                # - setPassword() for step-up
│           │   └── rdna_event_manager.dart      # Complete event management
│           │                                   # - onAuthenticateUserAndSignData handler
│           │                                   # - getPassword handler
│           ├── cp/              # Connection profile
│           │   └── agent_info.json             # REL-ID connection configuration
│           └── utils/           # Helper utilities
│               ├── connection_profile_parser.dart  # Profile configuration
│               └── progress_helper.dart            # State management helpers
│
└── 📚 Production Configuration
    ├── pubspec.yaml             # Dependencies
    ├── analysis_options.yaml    # Linter configuration
```

## 🚀 Quick Start

### Installation & Setup

```bash
# Navigate to the codelab folder
cd relid-data-signing

# Symlink or copy the rdna_client plugin
# The plugin should be located at the project root
ln -s /path/to/rdna_client rdna_client

# Install dependencies
flutter pub get

# iOS additional setup (optional - for iOS-specific configuration)
cd ios && pod install && cd ..

# Run the application
flutter run
# or for specific platform
flutter run -d android
flutter run -d ios
```

### Verify Data Signing Features

Once the app launches, verify these data signing capabilities:

1. ✅ Complete MFA flow available (prerequisite from previous codelab)
2. ✅ Data Signing input screen with authentication level selection
3. ✅ `authenticateUserAndSignData()` API integration with proper error handling
4. ✅ Step-up authentication flow with password challenge modal
5. ✅ Cryptographic signature generation and result display
6. ✅ State cleanup via `resetAuthenticateUserAndSignDataState()` API

## 🔑 REL-ID Authentication Level & Type Mapping

### Official REL-ID Data Signing Authentication Mapping

> **⚠️ Critical**: Not all authentication level and type combinations are supported for data signing. Only the combinations listed below are valid - all others will cause SDK errors.

| Auth Level | Authenticator Type | Supported Authentication | Description |
|---------------|----------------------|-------------------------|-------------|
| `NONE` (0) | `NONE` (0) | No Authentication | No authentication required - **NOT RECOMMENDED for production** |
| `RDNA_AUTH_LEVEL_1` (1) | `NONE` (0) | Device biometric, Device passcode, or Password | Priority: Device biometric → Device passcode → Password |
| `RDNA_AUTH_LEVEL_2` (2) | **NOT SUPPORTED** | ❌ **SDK will error out** | Level 2 is not supported for data signing |
| `RDNA_AUTH_LEVEL_3` (3) | **NOT SUPPORTED** | ❌ **SDK will error out** | Level 3 is not supported for data signing |
| `RDNA_AUTH_LEVEL_4` (4) | `RDNA_IDV_SERVER_BIOMETRIC` (1) | IDV Server Biometric | **Maximum security** - Any other authenticator type will cause SDK error |

> **🎯 Production Recommendation**: Use `RDNA_AUTH_LEVEL_4` with `RDNA_IDV_SERVER_BIOMETRIC` for all production data signing operations requiring maximum security.

### How to Use AuthLevel and AuthenticatorType

REL-ID data signing supports three authentication modes:

#### **1. No Authentication (Level 0)** - Testing Only
```dart
authLevel: 0,  // NONE
authenticatorType: 0  // NONE
```
- **Use Case**: Testing environments only
- **Security**: No authentication required
- **⚠️ Warning**: Never use in production applications

#### **2. Re-Authentication (Level 1)** - Standard Documents
```dart
authLevel: 1,  // RDNA_AUTH_LEVEL_1
authenticatorType: 0  // NONE
```
- **Use Case**: Standard document signing with flexible authentication
- **Security**: User logs in the same way they logged into the app
- **Authenticator Priority**: Device biometric → Device passcode → Password
- **Behavior**: REL-ID automatically selects best available authenticator

#### **3. Step-up Authentication (Level 4)** - High-Value Transactions
```dart
authLevel: 4,  // RDNA_AUTH_LEVEL_4
authenticatorType: 1  // RDNA_IDV_SERVER_BIOMETRIC
```
- **Use Case**: High-value transactions, sensitive documents, compliance requirements
- **Security**: Maximum security with server-side biometric verification
- **Requirement**: Must use `RDNA_IDV_SERVER_BIOMETRIC` - other types will cause errors
- **Behavior**: Forces strong biometric authentication regardless of user's enrolled authenticators

## 🎓 Learning Checkpoints

### Checkpoint 1: Authentication Level & Type Understanding
- [ ] I understand the 3 supported authentication levels for data signing (0, 1, 4)
- [ ] I know why levels 2 and 3 are NOT SUPPORTED and will cause SDK errors
- [ ] I can correctly pair authentication levels with their required authenticator types
- [ ] I understand the security implications of each authentication level
- [ ] I can choose appropriate levels based on document sensitivity and compliance needs

### Checkpoint 2: Data Signing API Integration
- [ ] I can implement `authenticateUserAndSignData()` API with proper parameter handling
- [ ] I understand the sync response pattern and error handling requirements
- [ ] I know how to handle the `onAuthenticateUserAndSignData` callback event
- [ ] I can implement proper input validation for payload, reason, and authentication parameters
- [ ] I understand the cryptographic signature response format and data structure

### Checkpoint 3: Step-Up Authentication Flow
- [ ] I can handle `getPassword` events triggered during Level 4 signing
- [ ] I understand when and why password challenges are presented to users
- [ ] I can implement password challenge modals with proper security considerations
- [ ] I know how to handle authentication failures and retry logic during step-up flows
- [ ] I can debug step-up authentication issues and identify failure points

### Checkpoint 4: State Management & Reset Patterns
- [ ] I can implement `resetAuthenticateUserAndSignDataState()` API for proper cleanup
- [ ] I understand when to call reset API (cancellation, errors, completion)
- [ ] I know how to manage form state and modal visibility during signing flows
- [ ] I can handle state transitions between input, authentication, and result screens
- [ ] I can implement proper error recovery with state cleanup and user guidance

### Checkpoint 5: Production Security & Error Handling
- [ ] I understand security best practices for data signing implementations
- [ ] I can implement comprehensive error handling for authentication and signing failures
- [ ] I know how to handle unsupported authentication combinations gracefully
- [ ] I can optimize user experience with clear status messaging and loading indicators
- [ ] I understand compliance and audit requirements for cryptographic data signing

## 🔄 Data Signing User Flow

### Scenario 1: Standard Data Signing with Level 1 (Re-Authentication)
1. **User enters DataSigningInputScreen** → Selects Level 1 authentication
2. **User fills payload and reason** → Enters document data and signing purpose
3. **User taps "Sign Data"** → `authenticateUserAndSignData()` API called with Level 1
4. **Authentication prompt appears** → Device biometric/passcode/password (automatic selection)
5. **User completes authentication** → SDK processes biometric/credential verification
6. **Signing completed** → SDK triggers `onAuthenticateUserAndSignData` event
7. **Results displayed** → Navigation to DataSigningResultScreen with signature
8. **User reviews signature** → Cryptographic signature, ID, and metadata displayed
9. **User taps "Sign Another Document"** → `resetAuthenticateUserAndSignDataState()` called
10. **Clean state achieved** → Return to input screen for new signing operation

### Scenario 2: High-Security Signing with Level 4 (Step-up Biometric)
1. **User enters DataSigningInputScreen** → Selects Level 4 authentication
2. **User fills high-value payload** → Enters sensitive document data and compliance reason
3. **User taps "Sign Data"** → `authenticateUserAndSignData()` API called with Level 4 + IDV Server Biometric
4. **Step-up authentication initiated** → SDK triggers `getPassword` event for password challenge
5. **Password challenge modal appears** → User prompted for password before biometric
6. **User enters password** → `setPassword()` API called for step-up verification
7. **Biometric prompt triggered** → Server-side biometric authentication required
8. **User completes biometric** → Fingerprint/Face ID verification with maximum security
9. **Signing completed** → SDK triggers `onAuthenticateUserAndSignData` event
10. **Secure results displayed** → High-security signature with audit trail information

### Scenario 3: Password Step-up Challenge During Level 4 Signing
1. **User initiates Level 4 signing** → High-security document signing request
2. **Step-up challenge required** → SDK determines additional authentication needed
3. **Password modal displayed** → User sees authentication options and attempts remaining
4. **User enters correct password** → Password verified for step-up authorization
5. **Biometric authentication proceeds** → Server-side biometric verification initiated
6. **Authentication successful** → Maximum security verification completed
7. **Document signed cryptographically** → Secure signature generation with audit trail
8. **Results with security indicators** → Signature display with security level confirmation

### Scenario 4: Error Handling (Unsupported Combinations, Network Issues)
1. **User selects invalid combination** → e.g., Level 2 or Level 4 with wrong authenticator type
2. **Validation error displayed** → Clear message about unsupported authentication combination
3. **User corrects selection** → Guided to valid Level 1 or Level 4 + IDV Server Biometric
4. **Network error during signing** → Connection failure during authentication or signing
5. **Error dialog with retry option** → User informed of failure with option to retry
6. **State cleanup on error** → `resetAuthenticateUserAndSignDataState()` called automatically
7. **User retry or cancel** → Option to retry with same parameters or cancel operation
8. **Graceful recovery** → Return to clean input state for new attempt

## 💡 Pro Tips

### Data Signing Implementation Best Practices
1. **Validate authentication combinations** - Always check Level + Authenticator Type compatibility before API calls
2. **Handle step-up authentication gracefully** - Use Cordova-style modal with attempts counter and error display
3. **Implement proper state cleanup** - Always call `resetAuthenticateUserAndSignDataState()` on errors/cancellation
4. **Secure sensitive data display** - Never log or expose signing payloads or passwords in production
5. **Optimize for user experience** - Use Flutter's CircularProgressIndicator and clear loading states
6. **Test all authentication paths** - Verify Level 1 flexible auth and Level 4 step-up flows on both iOS and Android
7. **Handle network failures** - Implement retry logic with proper error messages
8. **Follow security guidelines** - Use Level 4 for high-value transactions and compliance scenarios

### Security & Compliance
9. **Audit signing operations** - Log signing attempts and results for security monitoring
10. **Enforce document classification** - Match authentication levels to document sensitivity
11. **Validate signature integrity** - Verify cryptographic signatures before displaying results
12. **Implement rate limiting awareness** - Handle authentication attempt limits gracefully with color-coded counters

### Flutter-Specific Best Practices
13. **Use StatefulWidget for modals** - Password challenge modal uses StatefulWidget with TextEditingController
14. **Leverage FocusNode for UX** - Auto-focus password input after modal displays
15. **Handle keyboard properly** - Use `onSubmitted` callback for Enter key submission
16. **Clean up controllers** - Always dispose TextEditingController and FocusNode in dispose()
17. **Use copyWith for state updates** - Immutable state updates with DataSigningFormState.copyWith()
18. **Implement Clipboard API** - Use Flutter's Clipboard.setData() for copy-to-clipboard functionality

## 🔗 Key Implementation Files

### Core Data Signing API Implementation
```dart
// rdna_service.dart - Data Signing API
Future<RDNASyncResponse> authenticateUserAndSignData(
  String payload,
  int authLevel,
  int authenticatorType,
  String reason
) async {
  final response = await _rdnaClient.authenticateUserAndSignData(
    payload,
    authLevel,
    authenticatorType,
    reason
  );

  // Log sync response (no exceptions thrown)
  if (response.error?.longErrorCode == 0) {
    print('Data signing initiated successfully');
  } else {
    print('Data signing error: ${response.error?.errorString}');
  }

  return response; // Caller checks error
}

Future<RDNASyncResponse> resetAuthenticateUserAndSignDataState() async {
  final response = await _rdnaClient.resetAuthenticateUserAndSignDataState();

  // Log sync response (no exceptions thrown)
  if (response.error?.longErrorCode == 0) {
    print('State reset successfully');
  } else {
    print('State reset error: ${response.error?.errorString}');
  }

  return response; // Caller checks error
}
```

### Authentication Level Selection Logic
```dart
// data_signing_input_screen.dart - Authentication Level Validation
bool validateAuthenticationCombination(
  String authLevel,
  String authenticatorType
) {
  // Only supported combinations for data signing
  final validCombinations = [
    {'level': 'NONE (0)', 'type': 'NONE (0)'},
    {'level': 'RDNA_AUTH_LEVEL_1 (1)', 'type': 'NONE (0)'},
    {'level': 'RDNA_AUTH_LEVEL_4 (4)', 'type': 'RDNA_IDV_SERVER_BIOMETRIC (1)'},
  ];

  return validCombinations.any((combo) =>
    combo['level'] == authLevel && combo['type'] == authenticatorType
  );
}

Future<void> handleSubmit() async {
  if (!validateAuthenticationCombination(selectedAuthLevel, selectedAuthenticatorType)) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Combination'),
        content: const Text('This authentication level and type combination is not supported for data signing.'),
      ),
    );
    return;
  }

  await submitDataSigning();
}
```

### Event Chain Flow Implementation
```dart
// Event flow: authenticateUserAndSignData() → getPassword → onAuthenticateUserAndSignData

// 1. Initial data signing call
Future<void> handleDataSigning() async {
  final values = DataSigningService.convertDropdownToInts(
    selectedAuthLevel,
    selectedAuthenticatorType,
  );

  final request = DataSigningRequest(
    payload: payloadController.text,
    authLevel: values['authLevel']!,
    authenticatorType: values['authenticatorType']!,
    reason: reasonController.text,
  );

  await DataSigningService.signData(request);
  // SDK may trigger getPassword for Level 4
}

// 2. Handle step-up authentication (Level 4 only)
void handlePasswordChallenge(RDNAGetPassword challengeData) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PasswordChallengeModal(
      challengeMode: challengeData.challengeMode ?? 0,
      attemptsLeft: challengeData.attemptsLeft ?? 3,
      onSubmit: (password) async {
        await DataSigningService.submitPassword(password, challengeData.challengeMode ?? 0);
      },
      onCancel: () async {
        await DataSigningService.resetState();
      },
    ),
  );
}

// 3. Handle final signing result
void handleSigningResult(AuthenticateUserAndSignData response) {
  // Check error first
  if (response.error?.shortErrorCode != 0) {
    // Error occurred
    DataSigningService.resetState();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signing Failed'),
        content: Text(response.error?.errorString ?? 'Unknown error'),
      ),
    );
    return;
  }

  // Check status code
  if (response.status?.statusCode != 100) {
    // Status not success
    DataSigningService.resetState();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signing Failed'),
        content: Text('Failed with status: ${response.status?.statusCode}'),
      ),
    );
    return;
  }

  // Success - both error = 0 and status = 100
  final displayData = DataSigningService.formatSigningResultForDisplay(response);
  context.push('/data-signing-result', extra: response);
}
```

### Cordova-Style Password Challenge Modal (Flutter)
```dart
// password_challenge_modal.dart - Step-up Authentication Modal
class PasswordChallengeModal extends StatefulWidget {
  final int challengeMode;
  final int attemptsLeft;
  final Future<void> Function(String password) onSubmit;
  final Future<void> Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header with lock icon
            _buildHeader(),

            // Attempts counter with color coding (green/orange/red)
            if (attemptsLeft <= 3) _buildAttemptsCounter(),

            // Error message display
            if (errorMessage.isNotEmpty) _buildErrorMessage(),

            // Password input with visibility toggle
            _buildPasswordInput(),

            // Submit and Cancel buttons
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  // Auto-focus password input
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      passwordFocusNode.requestFocus();
    });
  }
}
```

---

**🔐 Congratulations! You've mastered Cryptographic Data Signing with REL-ID SDK!**

*You're now equipped to implement secure, production-ready data signing workflows with multi-level authentication using Flutter. Use this knowledge to create robust signing experiences that provide maximum security while maintaining excellent user experience during document authorization and high-value transaction scenarios.*
