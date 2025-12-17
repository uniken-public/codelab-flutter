# REL-ID Flutter Codelab: Multi-Factor Authentication & Session Management

[![Flutter](https://img.shields.io/badge/Flutter-3.10.3-blue.svg)](https://flutter.dev/)
[![REL-ID SDK](https://img.shields.io/badge/REL--ID%20SDK-v25.8.1-green.svg)](https://developer.uniken.com/)
[![Dart](https://img.shields.io/badge/Dart-3.10.3-blue.svg)](https://dart.dev/)
[![MFA](https://img.shields.io/badge/MFA-Enabled-orange.svg)]()
[![Session Management](https://img.shields.io/badge/Session-Management-blue.svg)]()

> **Codelab Step 3:** Master Multi-Factor Authentication and Session Management with REL-ID SDK

This folder contains the source code for the complete solution demonstrating REL-ID MFA and Session Management in Flutter.

## 🔐 What You'll Learn

In this comprehensive codelab, you'll master production-ready authentication and session management patterns in Flutter:

### Multi-Factor Authentication (MFA)
- ✅ **User Enrollment Flow**: Complete user registration with cyclical validation
- ✅ **Password Management**: Policy-based password creation and verification
- ✅ **Activation Codes**: Handle activation code generation and validation
- ✅ **Local Device Authentication (LDA)**: Biometric and device consent management

### Session Management
- ✅ **Session Timeout Handling**: Hard timeouts and idle timeout warnings with modal UI
- ✅ **Session Extension**: User-initiated session extension capabilities with API integration
- ✅ **Background/Foreground Tracking**: Accurate timer management across app states
- ✅ **Modal UI Components**: Session timeout dialogs with countdown timers and user controls
- ✅ **Session State Management**: Global session state with Riverpod StateNotifier
- ✅ **Automatic Navigation**: Seamless navigation to home screen on session expiration

### Architecture Patterns
- ✅ **Event-Driven Architecture**: SDK callback management with Dart type safety
- ✅ **Riverpod State Management**: Global session state providers with StateNotifier
- ✅ **Future + Event Callback Patterns**: Hybrid async/sync SDK integration
- ✅ **Reusable Widgets**: Consistent UI patterns and navigation flows

## 🎯 Learning Objectives

By completing this comprehensive authentication and session management codelab, you'll be able to:

### Multi-Factor Authentication
1. **Implement cyclical user validation** with getUser/setUser event patterns
2. **Build password management systems** with dynamic policy validation
3. **Handle activation code workflows** with retry logic and verification
4. **Create LDA consent flows** with platform-specific biometric detection

### Session Management
5. **Implement session timeout systems** with hard and idle timeout handling
6. **Build session extension capabilities** with user-friendly modal interfaces and API integration
7. **Handle background/foreground transitions** with accurate timer management using WidgetsBindingObserver
8. **Create session timeout dialogs** with countdown timers and extension controls
9. **Manage session state globally** using Riverpod StateNotifier patterns
10. **Implement automatic navigation** on session expiration with proper cleanup

### Architecture & Best Practices
11. **Design event-driven architectures** with centralized callback management
12. **Create Riverpod state management** for global session features
13. **Debug sync flows** with Future + Event callback patterns
14. **Build production-ready applications** with comprehensive session handling and error management

## 🏗️ Prerequisites

Before starting this codelab, ensure you've completed:

- **REL-ID MFA Integration Codelab (Flutter)** - Foundation concepts required
- Understanding of Flutter navigation and state management
- Experience with multi-screen application flows and dialog components
- Knowledge of authentication and session management principles
- Familiarity with event-driven programming patterns
- Understanding of Dart async patterns and callback handling
- Experience with Riverpod for state management

## 📁 MFA & Session Management Application Structure

```
relid-MFA-session-management/
├── 📱 Complete Flutter MFA & Session App
│   ├── android/                 # Android-specific configuration
│   ├── ios/                     # iOS-specific configuration
│   └── rdna_client/            # REL-ID Flutter Plugin
│
├── 📦 MFA & Session Architecture
│   └── lib/
│       ├── tutorial/            # Complete tutorial flow
│       │   ├── navigation/      # GoRouter navigation
│       │   │   └── app_router.dart      # Main navigation configuration
│       │   └── screens/         # All application screens
│       │       ├── components/  # Reusable UI widgets
│       │       │   ├── custom_button.dart
│       │       │   ├── custom_input.dart
│       │       │   └── status_banner.dart
│       │       ├── mfa/         # 🔐 MFA-specific screens
│       │       │   ├── check_user_screen.dart       # Cyclical user validation
│       │       │   ├── set_password_screen.dart     # Password with policy validation
│       │       │   └── user_lda_consent_screen.dart # Biometric consent management
│       │       └── tutorial/    # Base tutorial screens
│       │
│       └── uniken/              # 🛡️ REL-ID Integration
│           ├── providers/       # 🎯 State Management
│           │   ├── session_provider.dart    # ⏱️ Session Management (KEY FEATURE)
│           │   │                        # - StateNotifier for session state
│           │   │                        # - Hard timeout management
│           │   │                        # - Idle timeout warnings
│           │   │                        # - Session extension API
│           │   │                        # - Background/foreground tracking
│           │   └── sdk_event_provider.dart  # Event coordination
│           ├── components/      # Session UI components
│           │   └── modals/
│           │       └── session_modal.dart   # Session timeout dialog with countdown
│           │                        # - ConsumerStatefulWidget pattern
│           │                        # - Countdown timer display
│           │                        # - Session extension controls
│           │                        # - Auto-navigation on expiry
│           ├── services/        # 🔧 Core SDK services
│           │   ├── rdna_service.dart        # REL-ID SDK API integration
│           │   │                        # - extendSessionIdleTimeout() API
│           │   └── rdna_event_manager.dart  # Centralized event management
│           │                            # - onSessionTimeout events
│           │                            # - onSessionTimeOutNotification
│           │                            # - onSessionExtensionResponse
│           └── utils/           # Helper utilities
│               ├── connection_profile_parser.dart
│               └── password_policy_utils.dart
│
├── 📚 Configuration & Setup
│   ├── main.dart               # Root with SessionProvider integration
│   ├── pubspec.yaml           # Flutter dependencies
│   ├── CLAUDE.md              # Complete architecture documentation
│   └── lib/uniken/cp/
│       └── agent_info.json    # Connection profile configuration
```

## 🚀 Quick Start

### Installation & Setup

```bash
# Navigate to the codelab folder
cd relid-MFA-session-management

# Place the rdna_client plugin
# at root folder of this project (refer to Project Structure above for more info)

# Install dependencies
flutter pub get

# Run the application
flutter run
# or for specific platforms
flutter run -d android
flutter run -d ios
```

## 🎓 Learning Checkpoints

### Checkpoint 1: Multi-Factor Authentication Mastery
- [ ] I understand cyclical user validation with getUser/setUser event flow
- [ ] I can implement password creation with dynamic policy parsing and validation
- [ ] I can handle activation code workflows with retry logic
- [ ] I can create LDA consent flows with platform-specific biometric detection
- [ ] I understand the Future + Event callback pattern for SDK integration

### Checkpoint 2: Session Management Implementation (KEY FOCUS)
- [ ] I can implement hard session timeout handling with mandatory navigation to home for SDK re-initialization
- [ ] I can create idle session timeout warnings with extension capabilities
- [ ] I can build SessionProvider (StateNotifier) for global session state management
- [ ] I can implement SessionModal with countdown timers and extension controls
- [ ] I understand background/foreground timer accuracy with WidgetsBindingObserver and AppLifecycleState
- [ ] I can integrate `extendSessionIdleTimeout()` API with proper error handling
- [ ] I can handle session extension responses with success/failure feedback
- [ ] I can prevent modal dismissal with PopScope (canPop: false) on Android
- [ ] I can implement automatic navigation cleanup on session expiration

### Checkpoint 3: Event-Driven Architecture
- [ ] I can design centralized event management with RdnaEventManager
- [ ] I can implement callback preservation patterns for multiple consumers
- [ ] I can handle session-specific events: onSessionTimeout, onSessionTimeOutNotification, onSessionExtensionResponse
- [ ] I can create Riverpod-based state management for session features
- [ ] I can debug async session flows with comprehensive error handling

### Checkpoint 4: Production MFA & Session Applications
- [ ] I can integrate MFA and Session Management features cohesively
- [ ] I can implement Dart type safety for all session events and responses
- [ ] I can create reusable session UI widgets and patterns
- [ ] I can build production-ready applications with comprehensive session handling

## Event-Driven Architecture with Session Management Focus

This application demonstrates advanced REL-ID SDK integration with emphasis on Session Management:

### Core Architecture Components

#### 🛠️ Service Layer
- **`rdna_service.dart`**: Singleton service managing REL-ID SDK APIs
  - MFA APIs: `setUser()`, `setPassword()`, `setUserConsentForLDA()`, `resetAuthState()`
  - **Session APIs**: `extendSessionIdleTimeout()` for session extension with API response handling

- **`rdna_event_manager.dart`**: Centralized event management with Dart type safety
  - Handles all SDK callbacks with proper type definitions
  - **Session Event Handlers**: `onSessionTimeout`, `onSessionTimeOutNotification`, `onSessionExtensionResponse`
  - Implements callback preservation patterns for multiple consumers
  - Provides centralized error handling and event coordination

#### 🎯 Riverpod-Based Session Management
- **`SessionProvider`**: Global session timeout management (KEY COMPONENT)
  - **StateNotifier pattern** for reactive session state
  - **Hard session timeouts** with mandatory navigation to home screen
  - **Idle timeout warnings** with user-friendly modal interfaces
  - **Session extension capabilities** with API integration and success/failure handling
  - **Background/foreground timer accuracy** with WidgetsBindingObserver
  - **Modal state management** with countdown timers and user controls
  - **Automatic cleanup** on session expiration with navigation coordination

#### 🔄 Key Session Management Patterns

**Session Extension API Integration**
```dart
// Session extension with proper error handling
Future<void> handleExtendSession() async {
    final response =  await _rdnaService.extendSessionIdleTimeout();
    if (response.error?.longErrorCode != 0) {
      //show error
    }
```

**Session Event Management**
```dart
// Handle session timeout events
_eventManager.setSessionTimeoutHandler((String message) {
  // Hard timeout - navigate to home immediately
  _showSessionTimeout(message);
});

_eventManager.setSessionTimeoutNotificationHandler((dynamic data) {
  // Idle timeout warning - show extension option
  _showSessionTimeoutNotification(data);
});

_eventManager.setSessionExtensionResponseHandler((dynamic response) {
  // Handle extension success/failure
  if (_checkExtensionSuccess(response)) {
    hideSessionModal();
  } else {
    showExtensionError();
  }
});
```

**Riverpod State Management**
```dart
// Global session provider
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final rdnaService = RdnaService.getInstance();
  final eventManager = rdnaService.getEventManager();
  return SessionNotifier(rdnaService, eventManager);
});

// Consuming in widgets
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);

    return Stack(
      children: [
        // Main app content
        child,
        // Global Session Modal
        if (sessionState.isSessionModalVisible)
          const SessionModal(),
      ],
    );
  }
}
```

## 📚 Advanced Resources

- **REL-ID MFA Documentation**: [Multi-Factor Authentication Guide](https://developer.uniken.com/docs/challenges)
- **REL-ID Session Management**: [Session Timeout Implementation Guide](https://developer.uniken.com/docs/creating-a-new-session)
- **Flutter Navigation**: [GoRouter Patterns](https://pub.dev/packages/go_router)
- **Riverpod State Management**: [StateNotifier Best Practices](https://riverpod.dev/docs/concepts/providers)
- **Dialog Implementation**: [Flutter Dialog Best Practices](https://api.flutter.dev/flutter/material/Dialog-class.html)
- **App Lifecycle**: [WidgetsBindingObserver Guide](https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html)

## 💡 Pro Tips

### Multi-Factor Authentication
1. **Test cyclical validation flows** - Users may need multiple attempts for username/password validation
2. **Parse password policies dynamically** - Extract password policy from SDK challenge data
3. **Handle platform-specific biometrics** - Map authentication types correctly (Touch ID, Face ID, Fingerprint)
4. **Provide real-time validation feedback** - Show password policy compliance and form validation errors

### Session Management (KEY FOCUS)
5. **Distinguish session timeout types** - Hard timeouts vs idle timeout warnings require different UI patterns and user actions
6. **Implement accurate background timers** - Track time correctly when app goes to background/foreground using WidgetsBindingObserver
7. **Handle session extension gracefully** - Provide clear feedback for `extendSessionIdleTimeout()` success/failure with user-friendly messages
8. **Prevent modal dismissal** - Use PopScope with `canPop: false` to prevent hardware back button dismissal on Android
9. **Manage session state globally** - Use StateNotifierProvider to coordinate session state across the entire app
10. **Implement countdown timers accurately** - Show remaining time with proper formatting and real-time updates using Timer.periodic
11. **Handle session extension API properly** - Include loading states, error handling, and retry mechanisms
12. **Navigate automatically on timeout** - Ensure clean navigation to home screen when session expires using GoRouter
13. **Test session scenarios thoroughly** - Test hard timeouts, idle warnings, extensions, and background/foreground transitions

### Architecture & Development
14. **Preserve existing callbacks** - Use callback preservation patterns when adding new session event handlers
15. **Leverage Dart type safety** - Use comprehensive type definitions for all session events and responses
16. **Test on real devices** - Session timing and app state transitions behave differently on physical devices
17. **Debug session flows systematically** - Use centralized event management for easier session debugging
18. **Consider accessibility** - Ensure session timeout dialogs work with screen readers and provide adequate time for users with disabilities
19. **Implement proper error boundaries** - Handle session-related errors gracefully without crashing the app
20. **Test edge cases** - Handle scenarios like network failures during session extension, rapid background/foreground switches

---

**🔐 Congratulations! You've mastered Multi-Factor Authentication and Session Management with REL-ID SDK in Flutter!**

*You're now equipped to build production-ready Flutter applications with comprehensive MFA flows and sophisticated session management. Use this knowledge to create secure, user-friendly applications that provide excellent authentication experiences while maintaining user sessions intelligently.*
