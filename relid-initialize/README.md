# REL-ID Flutter Codelab: Basic SDK Integration

[![Flutter](https://img.shields.io/badge/Flutter-3.38.4-blue.svg)](https://flutter.dev/)
[![REL-ID SDK](https://img.shields.io/badge/REL--ID%20SDK-v25.06.03-green.svg)](https://developer.uniken.com/)
[![Dart](https://img.shields.io/badge/Dart-3.10.3-blue.svg)](https://dart.dev/)

> **Codelab Step 1:** Learn the fundamentals of REL-ID SDK integration in Flutter applications

This folder contains the source code for the solution of the [REL-ID Initialize](https://codelab.uniken.com/codelabs/flutter-relid-initialization-flow/index.html?index=..%2F..index#0)

## 📚 What You'll Learn

In this foundational codelab, you'll master the essential concepts of REL-ID SDK integration:

- ✅ **Core SDK Initialization**: Understand the REL-ID SDK lifecycle
- ✅ **Event-Driven Architecture**: Handle SDK callbacks and responses
- ✅ **Connection Profile Management**: Configure SDK with proper credentials
- ✅ **Error Handling Patterns**: Implement robust error management
- ✅ **Dart Type Safety**: Type-safe SDK interactions
- ✅ **Flutter Platform Channels**: Native module communication patterns

## 🎯 Learning Objectives

By the end of this codelab, you'll be able to:

1. **Initialize REL-ID SDK** in a Flutter application
2. **Handle SDK events** using event-driven architecture
3. **Parse connection profiles** for SDK configuration
4. **Implement navigation flows** based on SDK responses
5. **Debug common initialization issues** effectively

## 📁 Project Structure

```
relid-initialize/
├── 📱 Flutter App Configuration
│   ├── android/                 # Android-specific configuration
│   ├── ios/                     # iOS-specific configuration
│   └── rdna_client/            # REL-ID Native Plugin
│
├── 📦 Source Code
│   └── lib/
│       ├── tutorial/            # Tutorial screens and navigation
│       │   ├── navigation/      # GoRouter setup
│       │   └── screens/         # Home, Success, Error screens
│       └── uniken/              # REL-ID SDK integration
│           ├── providers/       # Riverpod providers
│           ├── services/        # Core SDK service layer
│           ├── cp/              # Connection profile
│           └── utils/           # Helper utilities
│
└── 📚 Configuration Files
    ├── pubspec.yaml            # Dependencies and assets
    ├── analysis_options.yaml   # Dart analyzer configuration
    └── README.md               # This file
```

## 🚀 Quick Start

### Prerequisites

Before starting this codelab, ensure you have:

- **Flutter SDK 3.38+** installed
- **Flutter development environment** set up
- **Android Studio** or **Xcode** for device testing
- **rdna_client** plugin and **REL-ID connection profile** from your Uniken administrator


### Installation

```bash
# Navigate to the codelab folder
cd relid-initialize

# Place the rdna_client plugin
# at root folder of this project (refer to Project Structure above for more info)

# Install dependencies
flutter pub get

# Run the application
flutter run
```

## 🎓 Learning Checkpoints

### Checkpoint 1: Basic Understanding
- [ ] I understand REL-ID SDK initialization flow
- [ ] I can explain the event-driven architecture
- [ ] I know how to handle SDK callbacks

### Checkpoint 2: Implementation Skills
- [ ] I can integrate REL-ID SDK in a new Flutter app
- [ ] I can implement proper error handling
- [ ] I can create type-safe SDK interactions

### Checkpoint 3: Advanced Concepts
- [ ] I understand connection profile management
- [ ] I can debug common SDK issues
- [ ] I can implement custom progress tracking

## 📚 Additional Resources

- **REL-ID Developer Documentation**: [https://developer.uniken.com/](https://developer.uniken.com/)
- **Flutter Guide**: [https://flutter.dev/docs/get-started](https://flutter.dev/docs/get-started)
- **Dart Language Tour**: [https://dart.dev/guides/language/language-tour](https://dart.dev/guides/language/language-tour)

## 💡 Pro Tips

1. **Always handle both success and error callbacks** - REL-ID SDK is asynchronous
2. **Use Dart's type safety** for better developer experience and error prevention
3. **Test on real devices** - SDK behavior can differ between simulator and device
4. **Keep connection profiles secure** - Never commit credentials to version control
5. **Enable debug logging during development** - Helps troubleshoot initialization issues

---

**Ready to build secure Flutter apps with REL-ID? Let's start coding! 🚀**

*This codelab provides hands-on experience with REL-ID SDK fundamentals. Master these concepts before advancing to Mobile Threat Detection features.*
