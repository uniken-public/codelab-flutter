# REL-ID Flutter Codelab: Mobile Threat Detection

[![Flutter](https://img.shields.io/badge/Flutter-3.38.4-blue.svg)](https://flutter.dev/)
[![REL-ID SDK](https://img.shields.io/badge/REL--ID%20SDK-v25.06.03-green.svg)](https://developer.uniken.com/)
[![Dart](https://img.shields.io/badge/Dart-3.10%2B-blue.svg)](https://dart.dev/)
[![Security](https://img.shields.io/badge/Security-MTD%20Enabled-red.svg)](https://developer.uniken.com/docs/mobile-threat-detection)

> **Codelab Step 2:** Master advanced Mobile Threat Detection implementation with REL-ID SDK

This folder contains the source code for the solution of the [REL-ID MTD](https://codelab.uniken.com/codelabs/flutter-mtd-flow/index.html?index=..%2F..index#0)

## 🛡️ What You'll Learn

In this advanced codelab, you'll master production-ready Mobile Threat Detection patterns:

- ✅ **Mobile Threat Detection (MTD)**: Real-time threat detection and response
- ✅ **User Consent Flows**: Handle non-critical threats with user interaction
- ✅ **Terminating Threats**: Manage critical security threats automatically
- ✅ **Platform-Specific Exits**: iOS HIG-compliant and Android native exit patterns
- ✅ **Advanced State Management**: Riverpod StateNotifier-based threat handling
- ✅ **Production Security Patterns**: Enterprise-grade threat response

## 🎯 Learning Objectives

By completing this advanced codelab, you'll be able to:

1. **Implement comprehensive MTD** with user consent and terminating threat flows
2. **Create platform-specific security exits** following platform guidelines
3. **Build sophisticated threat modals** with proper UX patterns
4. **Handle complex threat state management** using Riverpod StateNotifier
5. **Implement production-ready security policies** for enterprise applications
6. **Debug and troubleshoot MTD issues** effectively

## 🏗️ Prerequisites

Before starting this codelab, ensure you've completed:

- **[REL-ID Basic Integration Codelab](https://codelab.uniken.com/codelabs/flutter-relid-initialization-flow/index.html?index=..%2F..index#0)** - Foundation concepts required
- Understanding of Riverpod state management and advanced Flutter patterns
- Experience with Flutter navigation (GoRouter) and modal dialogs
- Knowledge of mobile security principles

## 📁 Advanced Project Structure

```
relid-MTD/
├── 📱 Complete Flutter Application
│   ├── android/                 # Auto-generated Android configuration
│   ├── ios/                     # Auto-generated iOS configuration
│   ├── pubspec.yaml             # Dependencies including rdna_client
│   └── lib/                     # Main source code
│
├── 📦 Advanced Source Architecture
│   └── lib/
│       ├── main.dart            # App entry with MTD integration
│       ├── tutorial/            # Enhanced tutorial flow
│       │   ├── navigation/      # GoRouter navigation setup
│       │   └── screens/         # Home, Success, Error, SecurityExit
│       └── uniken/              # Production REL-ID Integration
│           ├── providers/       # 🆕 Riverpod state management
│           │   └── mtd_threat_provider.dart  # Global threat management
│           ├── components/      # 🆕 Reusable threat UI components
│           │   └── threat_detection_modal.dart
│           ├── services/        # Production SDK service layer
│           ├── utils/           # Advanced helper utilities
│           └── cp/              # Connection profile configuration
│
└── 📚 Production Configuration
    ├── pubspec.yaml             # Flutter dependencies & rdna_client plugin
    ├── analysis_options.yaml   # Dart static analysis config
```

## 🚀 Quick Start

### Installation & Setup

```bash
# Navigate to the codelab folder
cd relid-MTD

# Install dependencies (handles iOS/Android automatically)
flutter pub get

# Run the application (works for both iOS and Android)
flutter run

# Or specify a specific device
flutter run -d <device-id>

# List available devices
flutter devices
```

## 🎓 Learning Checkpoints

### Checkpoint 1: MTD Architecture Mastery
- [ ] I understand the MTD threat detection lifecycle
- [ ] I can implement user consent vs terminating threat flows
- [ ] I know how to prevent duplicate threat dialogs
- [ ] I can create platform-specific security exits

### Checkpoint 2: Production Implementation
- [ ] I can implement enterprise-grade threat policies
- [ ] I understand proper threat state management
- [ ] I can optimize threat detection performance
- [ ] I can handle edge cases and error scenarios

### Checkpoint 3: Security Expertise
- [ ] I know mobile security best practices
- [ ] I can implement secure error handling
- [ ] I understand threat severity classification
- [ ] I can debug complex MTD issues

## 📚 Advanced Resources

- **REL-ID MTD Documentation**: [Mobile Threat Detection Guide](https://developer.uniken.com/docs/mobile-threat-detection)
- **Riverpod Documentation**: [State Management Guide](https://riverpod.dev/)
- **Flutter Security**: [Security Best Practices](https://flutter.dev/docs/deployment/security)

## 💡Pro Tips

1. **Always test MTD on real devices** - Simulators may not trigger actual threats
2. **Use Flutter DevTools** - Monitor state changes and debug threat flows effectively
3. **Implement graceful degradation** - Handle MTD failures without breaking app
4. **Use threat whitelisting carefully** - Balance security with user experience
5. **Monitor threat patterns** - Look for unusual threat frequency or types
6. **Keep threat policies updated** - Security landscape evolves rapidly
7. **Run flutter analyze regularly** - Catch potential issues early

---

**🛡️ Congratulations! You've mastered advanced Mobile Threat Detection with REL-ID SDK!**

*You're now equipped to integrate REL-ID MTD module into applications with comprehensive threat protection. Use this knowledge to protect your users and their data in production environments.*
