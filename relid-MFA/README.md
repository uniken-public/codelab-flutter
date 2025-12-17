# REL-ID Flutter Codelab: Multi-Factor Authentication

[![Flutter](https://img.shields.io/badge/Flutter-3.38.4-blue.svg)](https://flutter.dev/)
[![REL-ID SDK](https://img.shields.io/badge/REL--ID%20SDK-rdna__client-green.svg)](https://developer.uniken.com/)
[![Dart](https://img.shields.io/badge/Dart-3.10.3-blue.svg)](https://dart.dev/)
[![MFA](https://img.shields.io/badge/MFA-Enabled-orange.svg)]()

> **Codelab Step 3:** Master Multi-Factor Authentication implementation with REL-ID SDK in Flutter

This folder contains the Flutter solution for the REL-ID MFA codelab, demonstrating production-ready authentication patterns.

## 🔐 What You'll Learn

In this advanced codelab, you'll master production-ready Multi-Factor Authentication patterns in Flutter:

- ✅ **User Enrollment Flow**: Complete user registration and setup process with Flutter widgets
- ✅ **Password Management**: Secure password creation and verification with reactive forms
- ✅ **Activation Codes**: Handle activation code generation and validation with state management
- ✅ **User Consent Management**: Implement privacy and consent workflows with Flutter dialogs
- ✅ **Dashboard Navigation**: Multi-screen navigation with GoRouter patterns
- ✅ **Authentication Flows**: End-to-end MFA verification processes with Riverpod state
- ✅ **Reusable Components**: Extract common UI patterns for maintainable Flutter code

## 🎯 Learning Objectives

By completing this MFA codelab, you'll be able to:

1. **Implement complete user enrollment** with secure registration flows using Flutter forms
2. **Build password management systems** with verification patterns and Flutter TextField widgets
3. **Handle activation code workflows** for user verification with reactive state
4. **Create consent management flows** for privacy compliance using Flutter dialogs
5. **Implement GoRouter navigation** for multi-screen MFA applications
6. **Create reusable Flutter widgets** for consistent styling and behavior
7. **Debug and troubleshoot MFA flows** effectively with Flutter DevTools

## 🏗️ Prerequisites

Before starting this codelab, ensure you've completed:

- **[REL-ID Basic Integration Codelab](https://codelab.uniken.com/codelabs/flutter-relid-initialization-flow/index.html)** - Foundation concepts required
- Understanding of Flutter navigation (GoRouter) and form handling
- Experience with multi-screen application flows
- Knowledge of authentication and security principles
- Familiarity with Riverpod state management

## 📁 MFA Project Structure

```
relid-MFA/
├── 📱 Complete Flutter MFA App
│   ├── android/                 # Android-specific configuration
│   ├── ios/                     # iOS-specific configuration
│   └── rdna_client/             # REL-ID Flutter Plugin
│
├── 📦 MFA Source Architecture
│   └── lib/
│       ├── tutorial/            # MFA tutorial flow
│       │   ├── navigation/      # GoRouter configuration
│       │   │   └── app_router.dart
│       │   └── screens/         # MFA screens
│       │       ├── components/  # Shared Flutter widgets (CustomButton, CustomInput, StatusBanner)
│       │       ├── mfa/         # 🆕 MFA-specific screens
│       │       │   ├── activation_code_screen.dart
│       │       │   ├── check_user_screen.dart      # User input & setUser API
│       │       │   ├── dashboard_screen.dart
│       │       │   ├── set_password_screen.dart
│       │       │   ├── user_lda_consent_screen.dart
│       │       │   └── verify_password_screen.dart
│       │       └── tutorial/    # Base tutorial screens
│       └── uniken/              # REL-ID Integration + MTD
│           ├── providers/       # Riverpod providers
│           │   ├── sdk_event_provider.dart
│           │   └── mtd_threat_provider.dart
│           ├── services/        # SDK service layer
│           │   ├── rdna_service.dart
│           │   └── rdna_event_manager.dart
│           ├── components/      # Shared Flutter widgets
│           └── utils/           # Helper utilities
│               ├── connection_profile_parser.dart
│               └── progress_helper.dart
│
└── 📚 Production Configuration
    ├── pubspec.yaml             # Flutter dependencies
    └── analysis_options.yaml    # Dart analyzer config
```

## 🚀 Quick Start

### Installation & Setup

```bash
# Navigate to the codelab folder
cd relid-MFA

# Place the rdna_client plugin
# at root folder of this project (refer to Project Structure above)

# Get dependencies
flutter pub get

# Run the application
flutter run
# or for specific platform:
flutter run -d ios
flutter run -d android
```

### Development Commands

```bash
# Install dependencies
flutter pub get

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Analyze code
flutter analyze

# Clean build
flutter clean && flutter pub get
```

## 🎓 Learning Checkpoints

### Checkpoint 1: MFA Flow Mastery
- [ ] I understand the complete user enrollment process with Flutter forms
- [ ] I can implement password creation and verification with TextField widgets
- [ ] I know how to handle activation codes with Flutter state management
- [ ] I can create user consent workflows with Flutter dialogs
- [ ] I understand the CheckUserScreen for user input and setUser API integration with Riverpod

### Checkpoint 2: Navigation & UX
- [ ] I can implement GoRouter navigation patterns for MFA flows
- [ ] I understand multi-screen MFA flows with Flutter navigation
- [ ] I can create intuitive user experiences with Material Design
- [ ] I can handle form validation and errors with Flutter form state

### Checkpoint 3: Security & Production
- [ ] I know MFA security best practices for Flutter applications
- [ ] I can implement secure password handling with Flutter TextField obscureText
- [ ] I understand privacy and consent management with Flutter state
- [ ] I can debug complex MFA workflows using Flutter DevTools
- [ ] I can create reusable Flutter widgets for consistent security patterns

## 🔑 Key Flutter Patterns Used

### Service Layer Pattern
```dart
// Singleton service for SDK operations
final rdnaService = RdnaService.getInstance();
await rdnaService.setUser(username);
await rdnaService.setPassword(password, RDNAChallengeOpMode.RDNA_CHALLENGE_OP_SET);
```

### Event-Driven Architecture
```dart
// Centralized event handling with callbacks
eventManager.setGetUserHandler((data) {
  // Navigate to CheckUserScreen
  appRouter.goNamed('checkUserScreen', extra: data);
});
```

### State Management with Riverpod
```dart
class CheckUserScreen extends ConsumerStatefulWidget {
  // Widget with local state + provider access
}
```

### Type-Safe Navigation
```dart
// GoRouter with type-safe parameter passing
appRouter.goNamed('setPasswordScreen', extra: passwordData);
```

## 📚 Advanced Resources

- **REL-ID MFA Documentation**: [Multi-Factor Authentication Guide](https://developer.uniken.com/docs/mfa)
- **GoRouter Documentation**: [Flutter Navigation Patterns](https://pub.dev/packages/go_router)
- **Riverpod State Management**: [Flutter State Management](https://riverpod.dev/)

## 💡 Pro Tips

1. **Test complete user flows** - Verify the entire enrollment to verification process on real devices
2. **Implement progressive disclosure** - Don't overwhelm users with too many steps at once in your Flutter UI
3. **Handle network failures gracefully** - MFA flows depend on server communication; use Flutter error widgets
4. **Provide clear feedback** - Users need to understand each step; use SnackBars and StatusBanners effectively
5. **Test on real devices** - Biometric features (Touch ID, Face ID) require physical iOS/Android devices
6. **Consider accessibility** - Ensure MFA flows work with screen readers using Flutter Semantics widgets
7. **Use Flutter DevTools** - Debug navigation and state flow with Flutter's powerful debugging tools
8. **Leverage Hot Reload** - Rapidly iterate on UI and validation logic during development

---

**🔐 Congratulations! You've mastered Multi-Factor Authentication with REL-ID SDK in Flutter!**

*You're now equipped to integrate REL-ID MFA module into Flutter applications with comprehensive authentication flows. Use this knowledge to build secure, user-friendly authentication experiences with Flutter's reactive framework.*
