# REL-ID Flutter Codelab: Internationalization

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue.svg)](https://flutter.dev/)
[![REL-ID SDK](https://img.shields.io/badge/REL--ID%20SDK-Latest-green.svg)](https://developer.uniken.com/)
[![Internationalization](https://img.shields.io/badge/i18n-Multi--Language-orange.svg)]()
[![Dynamic Language Switch](https://img.shields.io/badge/Language%20Switch-Runtime-purple.svg)]()
[![Native Localization](https://img.shields.io/badge/Native%20Strings-Android%2FiOS-red.svg)]()

> **Codelab Advanced:** Master internationalization and localization with REL-ID SDK language management and dynamic runtime language switching

This folder contains the source code for the solution demonstrating [REL-ID Internationalization](https://codelab.uniken.com/codelabs/flutter-internationalization/index.html?index=..%2F..index#0) with comprehensive multi-language support, SDK integration, and native platform localization.

## 🌐 What You'll Learn

In this advanced internationalization codelab, you'll master production-ready multi-language patterns:

- ✅ **SDK Language Initialization**: Configure language preference during `initialize()` with `initOptions`
- ✅ **Dynamic Language Switching**: `setSDKLanguage()` API with runtime language updates
- ✅ **Language Response Events**: Handle `onSetLanguageResponse` callback for language changes
- ✅ **Two-Phase Language Loading**: Default languages → SDK languages after initialization
- ✅ **Native Platform Localization**: Android `strings.xml` and iOS `.strings` files for error codes
- ✅ **Riverpod State Management**: StateNotifier pattern for centralized language state management
- ✅ **SharedPreferences Persistence**: Save and restore user language preferences
- ✅ **LTR/RTL Support**: Handle bidirectional text with `RDNALanguageDirection` enum
- ✅ **Native Script Display**: Show languages in their native scripts (हिन्दी, العربية, Español)

## 🎯 Learning Objectives

By completing this Internationalization codelab, you'll be able to:

1. **Implement SDK language initialization** during app startup with proper fallback handling
2. **Build language selector interfaces** with native script display and modal interactions
3. **Handle dynamic language switching** at runtime without app restart
4. **Design two-phase language loading** for optimal user experience during initialization
5. **Create native localization files** for Android and iOS error code mapping
6. **Implement language persistence** with SharedPreferences for preference restoration
7. **Support bidirectional text** with LTR and RTL language configurations
8. **Integrate SDK language events** with application state management patterns
9. **Debug language-related issues** and troubleshoot SDK initialization problems

## 🏗️ Prerequisites

Before starting this codelab, ensure you've completed:

- **[REL-ID MFA Codelab](https://codelab.uniken.com/codelabs/flutter-mfa-activation-login-flow/index.html?index=..%2F..index#0)** - Complete MFA implementation required
- Understanding of Riverpod for state management
- Experience with Flutter modal bottom sheets and navigation
- Knowledge of SharedPreferences for local data persistence
- Familiarity with Dart classes and type definitions
- Basic understanding of internationalization (i18n) concepts
- Experience with Android and iOS native resource files (optional but helpful)

## 📁 Internationalization Project Structure

```
relid-internationalization/
├── 📱 Enhanced Flutter MFA + Internationalization App
│   ├── android/                 # Android-specific configuration
│   │   └── app/src/main/res/
│   │       ├── values/          # 🆕 English localization (default)
│   │       │   ├── strings_mtd.xml      # MTD error codes in English
│   │       │   └── strings_rel_id.xml   # REL-ID error codes in English
│   │       ├── values-es/       # 🆕 Spanish localization
│   │       │   ├── strings_mtd.xml      # MTD error codes in Spanish
│   │       │   └── strings_rel_id.xml   # REL-ID error codes in Spanish
│   │       └── values-hi/       # 🆕 Hindi localization
│   │           ├── strings_mtd.xml      # MTD error codes in Hindi
│   │           └── strings_rel_id.xml   # REL-ID error codes in Hindi
│   ├── ios/                     # iOS-specific configuration
│   │   ├── SharedLocalization/  # 🆕 Shared localization strings
│   │   │   ├── en.lproj/        # English localization
│   │   │   │   ├── MTD.strings         # MTD error codes in English
│   │   │   │   └── RELID.strings       # REL-ID error codes in English
│   │   │   ├── es.lproj/        # Spanish localization
│   │   │   │   ├── MTD.strings         # MTD error codes in Spanish
│   │   │   │   └── RELID.strings       # REL-ID error codes in Spanish
│   │   │   └── hi.lproj/        # Hindi localization
│   │   │       ├── MTD.strings         # MTD error codes in Hindi
│   │   │       └── RELID.strings       # REL-ID error codes in Hindi
│   └── rdna_client/             # REL-ID Flutter Plugin
│
├── 📦 Internationalization Source Architecture
│   └── lib/
│       ├── tutorial/            # 🌐 Internationalization Implementation
│       │   ├── providers/       # 🆕 Language state management
│       │   │   └── language_provider.dart    # Language provider (Riverpod)
│       │   │                                # - currentLanguage state
│       │   │                                # - supportedLanguages array
│       │   │                                # - changeLanguage method
│       │   │                                # - updateFromSDK sync
│       │   ├── types/           # 🆕 Customer language types
│       │   │   └── language.dart             # Language class (separate from SDK)
│       │   │                                # - lang (locale code)
│       │   │                                # - displayText (English name)
│       │   │                                # - nativeName (native script)
│       │   │                                # - direction (0=LTR, 1=RTL)
│       │   ├── utils/           # 🆕 Language utilities
│       │   │   ├── language_config.dart      # Default languages and conversions
│       │   │   │                            # - defaultSupportedLanguages
│       │   │   │                            # - convertSDKLanguageToCustomer()
│       │   │   │                            # - getNativeName()
│       │   │   └── language_storage.dart     # SharedPreferences persistence
│       │   │                                # - save(languageCode)
│       │   │                                # - load() language preference
│       │   ├── navigation/      # Enhanced navigation
│       │   │   └── app_router.dart           # GoRouter with routes
│       │   └── screens/         # Enhanced screens with i18n
│       │       ├── components/  # 🆕 Language UI components
│       │       │   ├── language_selector.dart # Language picker modal
│       │       │   │                        # - Native script display
│       │       │   │                        # - RTL badge indicator
│       │       │   │                        # - Current language checkmark
│       │       │   └── drawer_content.dart   # 🆕 Language change menu item
│       │       └── tutorial/
│       │           └── tutorial_home_screen.dart # 🆕 Language selector integration
│       └── uniken/              # 🛡️ Enhanced REL-ID Integration
│           ├── providers/       # Enhanced providers
│           │   └── sdk_event_provider.dart       # 🆕 Language event handling
│           │                                    # - _handleSetLanguageResponse
│           │                                    # - SDK language sync to Provider
│           ├── services/        # 🆕 Enhanced SDK service layer
│           │   ├── rdna_service.dart             # 🆕 Language APIs
│           │   │                                # - setSDKLanguage(localeCode, direction)
│           │   └── rdna_event_manager.dart       # 🆕 Language event management
│           │                                    # - setSetLanguageResponseHandler()
│           │                                    # - onSetLanguageResponse listener
│
└── 📚 Production Configuration
    ├── lib/main.dart            # 🆕 ProviderScope wrapper
    ├── pubspec.yaml             # Dependencies
    └── analysis_options.yaml
```

## 🚀 Quick Start

### Installation & Setup

```bash
# Navigate to the codelab folder
cd relid-internationalization

# Place the rdna_client plugin
# at root folder of this project (refer to Project Structure above for more info)

# Install dependencies
flutter pub get

# iOS additional setup (required for CocoaPods)
cd ios && pod install && cd ..

# Run the application
flutter run
```

### Verify Internationalization Features

Once the app launches, verify these internationalization capabilities:

1. ✅ Complete MFA flow available (prerequisite from previous codelab)
2. ✅ Language selector accessible from home screen
3. ✅ Language change menu item in drawer navigation
4. ✅ Default languages displayed before SDK initialization
5. ✅ SDK languages synchronized after initialization completes
6. ✅ `setSDKLanguage()` API integration with dynamic language switching
7. ✅ Native script display (English, हिन्दी, Español)
8. ✅ Language preference persisted in SharedPreferences
9. ✅ Error messages mapped from native localization files

## 🌍 REL-ID SDK Language Lifecycle

### Internationalization Behavior by SDK Lifecycle Phase

> **⚠️ Critical**: Understanding the two-phase language lifecycle is essential for correct error handling and user experience.

#### **Phase 1: Language During SDK Initialization**

During initialization, the SDK `initialize()` API with `initOptions` parameter sets the initial language preference:

```dart
final initOptions = RDNAInitOptions(
  internationalizationOptions: RDNAinternationalizationOptions(
    localeCode: 'en-US',  // Full locale code: 'en-US', 'hi-IN', 'es-ES'
    localeName: 'English',
    languageDirection: RDNALanguageDirection.RDNA_LOCALE_LTR,
  ),
);

await rdnaClient.initialize(serverConfig, initOptions);
```

**Key Behaviors:**
- If `localeCode` is provided in `initOptions`, SDK uses that language
- If `localeCode` is NOT provided or invalid, SDK automatically falls back to English
- At this stage, SDK has **NOT yet fetched** localization strings from server
- If initialization error occurs, SDK returns an **error code** (not localized text)
- **Host Flutter app is responsible** for mapping error codes to localized strings

**Error Code Mapping Pattern:**
```
SDK Returns: RDNASyncResponse { error: { longErrorCode: 12345 } }
              ↓
App Looks Up: Android: values-es/strings_rel_id.xml
              iOS: es.lproj/RELID.strings
              ↓
App Displays: "Error de inicialización del SDK" (Spanish localized message)
```

**Where Localization Files Are Used:**
- **Android**: `android/app/src/main/res/values-{language}/strings_*.xml`
- **iOS**: `ios/SharedLocalization/{language}.lproj/*.strings`

These files contain mappings like:
```xml
<!-- strings_rel_id.xml -->
<string name="error_12345">SDK initialization failed</string>
```

#### **Phase 2: Language After Successful Initialization**

After SDK initialization completes successfully, the application can change language **dynamically at runtime** using:

```dart
await rdnaService.setSDKLanguage(
  'es-ES',
  RDNALanguageDirection.RDNA_LOCALE_LTR
);
// Wait for onSetLanguageResponse event
```

**Key Behaviors:**
- Language changes do **NOT require app restart** or re-initialization
- SDK updates all internal UI strings and messages dynamically
- `onSetLanguageResponse` callback indicates success/failure
- SDK provides updated `supportedLanguages` array with available languages
- App synchronizes SDK languages with `LanguageProvider` state

**Language Update Flow:**
```
1. User selects language → calls setSDKLanguage()
                              ↓
2. SDK processes request → validates language availability
                              ↓
3. SDK fires event → onSetLanguageResponse with updated data
                              ↓
4. App updates Provider → languageProvider.updateFromSDK()
                              ↓
5. UI re-renders → all language-dependent components update
```

### Official REL-ID Language API Mapping

| API Method | Lifecycle Phase | Purpose | Documentation |
|------------|----------------|---------|---------------|
| `initialize()` with `initOptions.internationalizationOptions` | **Initialization** | Set initial language preference with fallback | [📖 Init Docs](https://developer.uniken.com/docs/initialize-1) |
| `setSDKLanguage()` | **Post-Initialization** | Change language dynamically at runtime | [📖 Language API Docs](https://developer.uniken.com/docs/internationalization) |
| `onSetLanguageResponse` | **Post-Initialization** | Event callback with updated language data | [📖 Event Docs](https://developer.uniken.com/docs/internationalization) |

> **🎯 Production Recommendation**: Always implement native localization files for initialization error codes, and use SDK events for post-initialization language management.

## 🔑 REL-ID Language Management Operations

### How to Use Language APIs

REL-ID internationalization supports two primary operations:

#### **1. Initialize with Language Preference** - Set Language at Startup
```dart
import 'package:rdna_client/rdna_client.dart';
import 'package:rdna_client/rdna_struct.dart';

// Get current language from user preference (SharedPreferences)
final currentLanguage = ref.read(languageProvider).currentLanguage;

final initOptions = RDNAInitOptions(
  internationalizationOptions: RDNAinternationalizationOptions(
    localeCode: currentLanguage.lang,  // Full locale: 'en-US', 'hi-IN'
    localeName: currentLanguage.displayText,
    languageDirection: getLanguageDirectionEnum(currentLanguage.direction),
  ),
);

await rdnaClient.initialize(serverConfig, initOptions);
// SDK uses English if locale is invalid or missing
```

- **Use Case**: Set user's preferred language on app startup
- **Fallback**: SDK automatically uses English if locale is invalid
- **Error Handling**: Map error codes to localized strings from native files
- **Timing**: Called once during app initialization
- **📖 Official Documentation**: [SDK Initialization API](https://developer.uniken.com/docs/sdk-initialization)

#### **2. Change Language Dynamically** - Runtime Language Switching
```dart
import 'package:rdna_client/rdna_client.dart';
import 'package:rdna_client/rdna_struct.dart';

// User selects Spanish from language selector
final selectedLanguage = Language(
  lang: 'es-ES',
  displayText: 'Spanish',
  nativeName: 'Español',
  direction: 0,
  isRTL: false,
);

// Call setSDKLanguage API
final syncResponse = await rdnaService.setSDKLanguage(
  selectedLanguage.lang,
  getLanguageDirectionEnum(selectedLanguage.direction),
);
// Wait for onSetLanguageResponse event
```

- **Use Case**: Change language after initialization without app restart
- **Event Response**: `onSetLanguageResponse` provides updated language data
- **Success Indicators**: `longErrorCode === 0` in sync response
- **Failure Handling**: Show error dialog if language change fails
- **Provider Update**: Update `LanguageProvider` only on successful event response
- **📖 Official Documentation**: [Set SDK Language API](https://developer.uniken.com/docs/internationalization)

#### **3. Handle Language Response Event** - Process SDK Language Updates
```dart
// Register event handler in SDKEventProvider
void _handleSetLanguageResponse(RDNASetLanguageResponse data) {
  print('SDKEventProvider - Set language response event received');

  // Early error check
  if (data.error?.longErrorCode != 0) {
    showDialog(/* Language Change Failed */);
    return;
  }

  // Update LanguageProvider with SDK's supported languages
  if (data.supportedLanguages != null && data.supportedLanguages!.isNotEmpty) {
    ref.read(languageProvider.notifier).updateFromSDK(
      data.supportedLanguages!,
      data.localeCode ?? 'en',
    );

    showDialog(/* Success: Language changed to ${data.localeName} */);
  }
}

eventManager.setSetLanguageResponseHandler(_handleSetLanguageResponse);
```

- **Use Case**: Process language change results and update UI
- **Response Data**: Includes `supportedLanguages`, `localeCode`, `localeName`, `direction`
- **Error Check**: `longErrorCode !== 0` indicates failure
- **Provider Sync**: Update `LanguageProvider` with SDK's latest language data
- **📖 Official Documentation**: [Language Events API](https://developer.uniken.com/docs/internationalization)

## 🎓 Learning Checkpoints

### Checkpoint 1: SDK Language Lifecycle Understanding
- [ ] I understand the difference between initialization-time and runtime language setting
- [ ] I know why error codes (not text) are returned during initialization
- [ ] I can implement native localization files for Android and iOS
- [ ] I understand when to use `internationalizationOptions` vs `setSDKLanguage()` API
- [ ] I know how SDK falls back to English when locale is invalid

### Checkpoint 2: Two-Phase Language Loading Pattern
- [ ] I can implement default hardcoded languages for pre-initialization state
- [ ] I understand why SDK languages are synchronized after initialization
- [ ] I know how to use `languageProvider.updateFromSDK()` for sync
- [ ] I can handle the transition from default to SDK languages smoothly
- [ ] I understand the purpose of `RDNASupportedLanguage` vs `Language` classes

### Checkpoint 3: Language Selector UI Implementation
- [ ] I can create a modal language selector with native script display
- [ ] I know how to show language names in their native scripts (हिन्दी, العربية)
- [ ] I can implement RTL badge indicators for right-to-left languages
- [ ] I understand how to highlight the currently selected language
- [ ] I can integrate language selector in both home screen and drawer menu

### Checkpoint 4: Dynamic Language Switching
- [ ] I can implement `setSDKLanguage()` API calls with proper parameters
- [ ] I understand the sync+async pattern (API call + event handler)
- [ ] I know how to handle `onSetLanguageResponse` event correctly
- [ ] I can validate success using `longErrorCode`
- [ ] I understand when to update `LanguageProvider` state (success only)

### Checkpoint 5: Language Persistence & State Management
- [ ] I can persist user language preference using SharedPreferences
- [ ] I know how to restore language preference on app startup
- [ ] I understand Riverpod StateNotifier pattern for language state
- [ ] I can implement LanguageProvider for accessing language state
- [ ] I know how to provide ProviderScope at app root level

### Checkpoint 6: Bidirectional Text Support (LTR/RTL)
- [ ] I understand `RDNALanguageDirection` enum values (RDNA_LOCALE_LTR, RDNA_LOCALE_RTL)
- [ ] I know how to pass language direction to `setSDKLanguage()` API
- [ ] I can detect RTL languages and display appropriate UI indicators
- [ ] I understand the difference between `direction` (int) and `isRTL` (bool)
- [ ] I can implement RTL-aware layouts if needed

### Checkpoint 7: Error Handling & Validation
- [ ] I can map SDK error codes to localized strings from native files
- [ ] I know how to handle sync response errors vs event response errors
- [ ] I understand early return pattern (check `longErrorCode` first)
- [ ] I can show user-friendly error dialogs for language change failures
- [ ] I know when to prevent language updates (error cases)

## 🔄 Internationalization User Flow

### Scenario 1: App Startup with Language Preference
1. **App launches** → LanguageProvider initializes with default languages
2. **Load persisted preference** → SharedPreferences retrieves saved language code ('es-ES')
3. **Set current language** → LanguageProvider updates to Spanish
4. **SDK initialization starts** → Use full locale code 'es-ES' from language
5. **Pass to initOptions** → `initialize()` called with `localeCode: 'es-ES'`
6. **SDK initializes** → Uses Spanish for internal messages
7. **Initialization completes** → `onInitialized` event fires
8. **SDK languages received** → Extract `supportedLanguages` from additionalInfo
9. **Sync to Provider** → Call `updateFromSDK()` to replace default languages
10. **UI updates** → All language selectors now show SDK's supported languages

### Scenario 2: Dynamic Language Change from Home Screen
1. **User on home screen** → Sees language selector button with current language
2. **User taps selector** → LanguageSelector modal opens
3. **Modal displays languages** → Shows all `supportedLanguages` with native names
4. **User selects Hindi** → Taps on "हिन्दी (Hindi)" option
5. **Modal closes** → `onSelectLanguage` handler called with Hindi language object
6. **Validation check** → If same language, skip API call
7. **API call initiated** → `setSDKLanguage('hi-IN', RDNA_LOCALE_LTR)` called
8. **Loading state shown** → Button shows loading indicator
9. **Sync response received** → API acknowledges request (doesn't indicate final success)
10. **Wait for event** → `onSetLanguageResponse` event fires
11. **Event validation** → Check `longErrorCode === 0`
12. **Success handling** → Update LanguageProvider, show success SnackBar
13. **UI updates immediately** → All language-dependent text re-renders
14. **Preference saved** → SharedPreferences persists 'hi-IN' for next app launch

### Scenario 3: Language Change from Drawer Menu
1. **User opens drawer** → Drawer menu displays with language menu item
2. **Current language shown** → Menu item shows "🌐 Change Language" with "हिन्दी"
3. **User taps menu item** → LanguageSelector modal opens
4. **User selects Spanish** → Taps "Español (Spanish)"
5. **Loading indicator** → Menu item shows CircularProgressIndicator
6. **API processing** → Same flow as Scenario 2 (steps 7-13)
7. **Provider updated** → Current language changes to Spanish
8. **Menu updates** → Menu item now shows "Español" as current language
9. **Drawer remains open** → User can see updated language immediately

### Scenario 4: Error Handling - Invalid Language Request
1. **User selects language** → Taps language in selector
2. **API call initiated** → `setSDKLanguage()` called with language code
3. **Sync response error** → `longErrorCode !== 0` in sync response
4. **Error dialog displayed** → "Language Change Error: [error message]"
5. **Loading state cleared** → Button returns to normal state
6. **Provider NOT updated** → Language remains unchanged
7. **User can retry** → Opens selector again for new attempt

### Scenario 5: Error Handling - Event Response Failure
1. **User selects language** → Language change initiated
2. **Sync response success** → `longErrorCode === 0` (request accepted)
3. **Event fires** → `onSetLanguageResponse` received
4. **Event error detected** → `longErrorCode !== 0`
5. **Early return triggered** → Handler exits without updating provider
6. **Error dialog shown** → "Language Change Failed: [error details]"
7. **Language unchanged** → LanguageProvider retains previous language
8. **UI remains consistent** → All displays show previous language

### Scenario 6: Initialization Error Code Localization
1. **App starts with Spanish** → User's preference is 'es-ES'
2. **Initialize called** → `initOptions.localeCode = 'es-ES'`
3. **Initialization fails** → SDK returns error code 12345
4. **SDK returns code only** → No localized text available yet
5. **App checks platform** → Android or iOS
6. **Load native file** → Android: `values-es/strings_rel_id.xml`, iOS: `es.lproj/RELID.strings`
7. **Look up error code** → Find string resource for error_12345
8. **Display localized error** → Show Spanish error message to user
9. **Fallback handling** → If no translation exists, show English default

## 💡 Pro Tips

### Language Management Best Practices
1. **Use two-phase loading** - Show default languages immediately, sync SDK languages after init
2. **Separate customer types** - Keep `Language` class separate from `RDNASupportedLanguage`
3. **Persist preferences** - Always save language choice to SharedPreferences
4. **Validate before update** - Only update LanguageProvider on successful event responses
5. **Use full locale codes** - Pass complete locale code ('en-US') for both init and API
6. **Show native scripts** - Display languages in their native writing systems
7. **Handle RTL properly** - Support right-to-left languages with direction indicators
8. **Use plugin classes** - Don't create custom models, use rdna_struct.dart classes

### Error Handling & User Experience
9. **Map error codes** - Implement native localization files for initialization errors
10. **Early return pattern** - Check `longErrorCode !== 0` first, exit immediately on error
11. **Show loading states** - Always display loading indicators during language changes
12. **Provide user feedback** - Show success/error SnackBars for all language operations
13. **Prevent duplicate calls** - Skip API call if selected language equals current language
14. **Clean up handlers** - Reset event handlers when widgets dispose
15. **Fall back gracefully** - Use English as default if language code is invalid
16. **Check mounted state** - Always check `mounted` before using context after async operations

### Provider & State Management
17. **Wrap at app root** - Place ProviderScope above MaterialApp
18. **Use StateNotifier** - Manage language state with StateNotifier pattern
19. **Sync from SDK events** - Update provider from `onSetLanguageResponse` handler
20. **Expose minimal API** - Provider should provide: current, supported, changeLanguage, updateFromSDK

## 🔗 Key Implementation Files

### Phase 1: SDK Initialization with Language Preference

#### Initialize SDK with Language (App Startup)
```dart
// tutorial_home_screen.dart - SDK Initialization with Language
import 'package:rdna_client/rdna_client.dart';
import 'package:rdna_client/rdna_struct.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/language_provider.dart';
import '../../utils/language_config.dart';

class TutorialHomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<TutorialHomeScreen> createState() => _TutorialHomeScreenState();
}

class _TutorialHomeScreenState extends ConsumerState<TutorialHomeScreen> {
  Future<void> _handleInitialize() async {
    final languageState = ref.read(languageProvider);
    final currentLanguage = languageState.currentLanguage;

    print('TutorialHomeScreen - Initializing with language:');
    print('  Locale: ${currentLanguage.lang}');
    print('  Display Text: ${currentLanguage.displayText}');
    print('  Native Name: ${currentLanguage.nativeName}');
    print('  Direction: ${currentLanguage.direction}');

    final languageDirection = getLanguageDirectionEnum(currentLanguage.direction);

    final initOptions = RDNAInitOptions(
      internationalizationOptions: RDNAinternationalizationOptions(
        localeCode: currentLanguage.lang,  // Full locale: 'en-US', 'hi-IN'
        localeName: currentLanguage.displayText,
        languageDirection: languageDirection,
      ),
    );

    final rdnaService = RdnaService.getInstance();
    final syncResponse = await rdnaService.initialize(serverConfig, initOptions);

    if (syncResponse.error?.longErrorCode == 0) {
      print('TutorialHomeScreen - Sync success, waiting for async events...');
    } else {
      // Error codes are returned here, map to native localization files
      _showErrorDialog(syncResponse.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI implementation
    return Scaffold(/* ... */);
  }
}
```

**Key Points:**
- SDK `initialize()` accepts `initOptions` with `internationalizationOptions`
- Use full locale codes ('en-US', 'hi-IN', 'es-ES') not short codes
- If `localeCode` is missing or invalid, SDK falls back to English automatically
- `additionalInfo.supportedLanguage` contains all languages available from server
- `additionalInfo.selectedLanguage` indicates which language SDK is currently using
- Call `updateFromSDK()` to sync SDK languages with app's LanguageProvider

### Phase 2: Dynamic Language Switching

#### setSDKLanguage API Implementation
```dart
// rdna_service.dart - Dynamic Language Change API
import 'package:rdna_client/rdna_client.dart';
import 'package:rdna_client/rdna_struct.dart';

class RdnaService {
  final RdnaClient _rdnaClient = RdnaClient();

  /// Changes the SDK language dynamically after initialization
  ///
  /// This method allows changing the SDK's language preference after initialization has completed.
  /// The SDK will update all internal messages and supported language configurations accordingly.
  /// After successful API call, the SDK triggers an onSetLanguageResponse event with updated language data.
  ///
  /// Response Validation Logic:
  /// 1. Check error.longErrorCode: 0 = success, > 0 = error
  /// 2. An onSetLanguageResponse event will be triggered with updated language configuration
  /// 3. Async events will be handled by event listeners
  ///
  /// @param localeCode The language locale code to set (e.g., 'en-US', 'hi-IN', 'ar-SA')
  /// @param languageDirection Language text direction (RDNA_LOCALE_LTR or RDNA_LOCALE_RTL)
  /// @returns RDNASyncResponse that contains sync response structure
  Future<RDNASyncResponse> setSDKLanguage(
    String localeCode,
    RDNALanguageDirection languageDirection,
  ) async {
    print('RdnaService - Setting SDK language:');
    print('  Locale Code: $localeCode');
    print('  Language Direction: $languageDirection');

    final response = await _rdnaClient.setSDKLanguage(localeCode, languageDirection);

    print('RdnaService - SetSDKLanguage sync response:');
    print('  Long Error Code: ${response.error?.longErrorCode}');
    print('  Short Error Code: ${response.error?.shortErrorCode}');

    return response;
  }
}
```

**API Signature (from rdna_client):**
```dart
RdnaClient.setSDKLanguage(
  String localeCode,                    // Full locale: 'en-US', 'hi-IN', 'es-ES'
  RDNALanguageDirection localeDirection // RDNA_LOCALE_LTR or RDNA_LOCALE_RTL
) → Future<RDNASyncResponse>
```

### Event Handler Implementation

#### onSetLanguageResponse Event Handler
```dart
// rdna_event_manager.dart - Language Event Registration
import 'package:rdna_client/rdna_client.dart';
import 'package:rdna_client/rdna_struct.dart';

class RdnaEventManager {
  final RdnaClient _rdnaClient = RdnaClient();
  Function(RDNASetLanguageResponse)? _setLanguageResponseHandler;

  RdnaEventManager() {
    // Register language response event listener
    _rdnaClient.registerEventListener(
      RdnaClient.EVENT_ON_SET_LANGUAGE_RESPONSE,
      _onSetLanguageResponse,
    );
  }

  /// Handles set language response events
  /// @param response Response from native SDK containing updated language configuration
  void _onSetLanguageResponse(dynamic response) {
    print('RdnaEventManager - Set language response event received');

    if (response is RDNASetLanguageResponse) {
      print('RdnaEventManager - Set language response data:');
      print('  Locale Code: ${response.localeCode}');
      print('  Locale Name: ${response.localeName}');
      print('  Language Direction: ${response.languageDirection}');
      print('  Supported Count: ${response.supportedLanguages?.length ?? 0}');
      print('  Error Code: ${response.error?.longErrorCode}');

      if (_setLanguageResponseHandler != null) {
        _setLanguageResponseHandler!(response);
      }
    }
  }

  /// Sets the callback for set language response events
  void setSetLanguageResponseHandler(Function(RDNASetLanguageResponse)? handler) {
    _setLanguageResponseHandler = handler;
  }

  /// Cleanup all event handlers
  void cleanup() {
    _setLanguageResponseHandler = null;
  }
}
```

**Event Response Structure:**
```dart
class RDNASetLanguageResponse {
  String? localeCode;                      // 'es-ES'
  String? localeName;                      // 'Spanish'
  String? languageDirection;               // 'LTR' or 'RTL'
  List<RDNASupportedLanguage>? supportedLanguages;  // All available languages
  RDNAError? error;                        // { longErrorCode: 0, errorString: '...' }
}
```

### Language Provider Pattern

#### LanguageProvider Implementation (Riverpod StateNotifier)
```dart
// language_provider.dart - Centralized Language State Management
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../types/language.dart';
import '../utils/language_config.dart';
import '../utils/language_storage.dart';

class LanguageState {
  final Language currentLanguage;
  final List<Language> supportedLanguages;
  final bool isLoading;

  LanguageState({
    required this.currentLanguage,
    required this.supportedLanguages,
    this.isLoading = false,
  });

  LanguageState copyWith({
    Language? currentLanguage,
    List<Language>? supportedLanguages,
    bool? isLoading,
  }) {
    return LanguageState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LanguageNotifier extends StateNotifier<LanguageState> {
  LanguageNotifier()
      : super(LanguageState(
          currentLanguage: defaultLanguage,
          supportedLanguages: defaultSupportedLanguages,
          isLoading: true,
        )) {
    _loadPersistedLanguage();
  }

  /// Load persisted language preference on initialization
  Future<void> _loadPersistedLanguage() async {
    try {
      final savedCode = await LanguageStorage.load();

      if (savedCode != null) {
        final language = getLanguageByCode(savedCode, state.supportedLanguages);
        state = state.copyWith(
          currentLanguage: language,
          isLoading: false,
        );
        print('LanguageProvider - Loaded persisted language: ${language.displayText}');
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (error) {
      print('LanguageProvider - Error loading language: $error');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Change language and persist preference
  Future<void> changeLanguage(Language language) async {
    try {
      await LanguageStorage.save(language.lang);
      state = state.copyWith(currentLanguage: language);
      print('LanguageProvider - Language changed to: ${language.displayText}');
    } catch (error) {
      print('LanguageProvider - Error changing language: $error');
      rethrow;
    }
  }

  /// Update supported languages and current language from SDK response
  /// Called after SDK initialization completes
  /// @param sdkLanguages Array of languages from SDK's additionalInfo.supportedLanguage
  /// @param sdkSelectedLanguage Selected language code from SDK's additionalInfo.selectedLanguage
  void updateFromSDK(
    List<RDNASupportedLanguage> sdkLanguages,
    String sdkSelectedLanguage,
  ) {
    try {
      print('LanguageProvider - Updating from SDK:');
      print('  SDK Languages Count: ${sdkLanguages.length}');
      print('  SDK Selected Language: $sdkSelectedLanguage');

      // Convert SDK languages to customer format
      final convertedLanguages = sdkLanguages.map(convertSDKLanguageToCustomer).toList();

      // Update supported languages
      final sdkCurrentLanguage = getLanguageByCode(sdkSelectedLanguage, convertedLanguages);

      state = state.copyWith(
        supportedLanguages: convertedLanguages,
        currentLanguage: sdkCurrentLanguage,
      );

      // Persist SDK's selected language
      LanguageStorage.save(sdkCurrentLanguage.lang).catchError((error) {
        print('LanguageProvider - Failed to persist SDK language: $error');
      });
    } catch (error) {
      print('LanguageProvider - Error updating from SDK: $error');
    }
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>(
  (ref) => LanguageNotifier(),
);
```

**main.dart Integration:**
```dart
// main.dart - Wrap entire app with ProviderScope
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App configuration
    );
  }
}
```

### Language Selector UI Component

#### Language Selector Modal
```dart
// language_selector.dart - Customer-defined Language Picker Modal
import 'package:flutter/material.dart';
import '../../types/language.dart';

/// Customer-defined Language Selector Modal
///
/// This component provides a UI for selecting application language.
/// Displays languages in their native scripts with RTL indicators.
/// Customize the styling and layout to match your app's design system.
class LanguageSelector extends StatelessWidget {
  final Language currentLanguage;
  final List<Language> supportedLanguages;
  final Function(Language) onSelectLanguage;

  const LanguageSelector({
    required this.currentLanguage,
    required this.supportedLanguages,
    required this.onSelectLanguage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: const Column(
              children: [
                Text(
                  'Select Language',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Choose your preferred language',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Language List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: supportedLanguages.length,
              itemBuilder: (context, index) {
                final language = supportedLanguages[index];
                final isSelected = currentLanguage.lang == language.lang;

                return InkWell(
                  onTap: () => onSelectLanguage(language),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF5F9FF) : Colors.white,
                      border: Border(
                        left: isSelected
                            ? const BorderSide(color: Color(0xFF007AFF), width: 4)
                            : BorderSide.none,
                        bottom: const BorderSide(color: Color(0xFFF0F0F0), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Language Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language.nativeName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                language.displayText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // RTL Badge
                        if (language.isRTL) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'RTL',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF57C00),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Selection Checkmark
                        if (isSelected)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFF007AFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '✓',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Show Language Selector Modal
Future<void> showLanguageSelector(
  BuildContext context, {
  required Language currentLanguage,
  required List<Language> supportedLanguages,
  required Function(Language) onSelectLanguage,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (context) => Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: LanguageSelector(
        currentLanguage: currentLanguage,
        supportedLanguages: supportedLanguages,
        onSelectLanguage: onSelectLanguage,
      ),
    ),
  );
}
```

**Visual Output:**
```
┌─────────────────────────────────┐
│ Select Language                 │
│ Choose your preferred language  │
├─────────────────────────────────┤
│ ✓ English                       │
│   English                       │
├─────────────────────────────────┤
│   हिन्दी                         │
│   Hindi                         │
├─────────────────────────────────┤
│   العربية            [RTL]      │
│   Arabic                        │
├─────────────────────────────────┤
│   Español                       │
│   Spanish                       │
└─────────────────────────────────┘
```

### Complete Language Change Flow

#### DrawerContent with Language Change Menu
```dart
// drawer_content.dart - Language Change Menu Integration
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/language_provider.dart';
import '../../utils/language_config.dart';
import '../../../uniken/services/rdna_service.dart';
import 'language_selector.dart';

class DrawerContent extends ConsumerStatefulWidget {
  @override
  ConsumerState<DrawerContent> createState() => _DrawerContentState();
}

class _DrawerContentState extends ConsumerState<DrawerContent> {
  bool _isChangingLanguage = false;

  /// Handles language selection from the language selector modal
  /// Calls setSDKLanguage API and waits for onSetLanguageResponse event
  Future<void> _handleChangeLanguage() async {
    final languageState = ref.read(languageProvider);

    // Capture references before showing modal
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    // Show language selector modal
    showLanguageSelector(
      context,
      currentLanguage: languageState.currentLanguage,
      supportedLanguages: languageState.supportedLanguages,
      onSelectLanguage: (language) async {
        // Close modal
        rootNavigator.pop();

        // Check if the selected language is the same as current
        if (language.lang == languageState.currentLanguage.lang) {
          print('DrawerContent - Same language selected, no API call needed');
          return;
        }

        if (mounted) {
          setState(() {
            _isChangingLanguage = true;
          });
        }

        try {
          print('DrawerContent - Calling setSDKLanguage API: ${language.displayText}');

          final rdnaService = RdnaService.getInstance();
          final response = await rdnaService.setSDKLanguage(
            language.lang,
            getLanguageDirectionEnum(language.direction),
          );

          print('DrawerContent - SetSDKLanguage sync response received');
          print('  Long Error Code: ${response.error?.longErrorCode}');

          if (mounted) {
            setState(() {
              _isChangingLanguage = false;
            });
          }

          if (response.error?.longErrorCode == 0) {
            // Sync success - async event will fire
            print('DrawerContent - SetSDKLanguage sync success');

            // Show success message using captured scaffoldMessenger
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Language changed to ${language.nativeName}'),
                backgroundColor: const Color(0xFF10B981),
                duration: const Duration(seconds: 2),
              ),
            );
          } else {
            // Sync error
            final errorMessage = response.error?.errorString ?? 'Language change failed';
            print('DrawerContent - SetSDKLanguage sync error: $errorMessage');

            if (mounted) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Language Change Error'),
                  content: Text(errorMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          }
        } catch (error) {
          print('DrawerContent - Error changing language: $error');

          if (mounted) {
            setState(() {
              _isChangingLanguage = false;
            });

            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Language Change Error'),
                content: Text('Failed to change language: $error'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageState = ref.watch(languageProvider);

    return ListView(
      children: [
        // Language Change Menu Item
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Change Language'),
          subtitle: Text(languageState.currentLanguage.nativeName),
          trailing: _isChangingLanguage
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _isChangingLanguage ? null : _handleChangeLanguage,
        ),
      ],
    );
  }
}
```

### SDKEventProvider Integration

#### Language Event Handler in Provider
```dart
// sdk_event_provider.dart - Global Language Event Handler
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../../tutorial/providers/language_provider.dart';

class SDKEventProvider extends ConsumerStatefulWidget {
  final Widget child;

  const SDKEventProvider({required this.child, super.key});

  @override
  ConsumerState<SDKEventProvider> createState() => _SDKEventProviderState();
}

class _SDKEventProviderState extends ConsumerState<SDKEventProvider> {
  /// Event handler for language change response
  /// Called when setSDKLanguage API is invoked and SDK responds with updated language configuration
  void _handleSetLanguageResponse(RDNASetLanguageResponse data) {
    print('SDKEventProvider - Set language response received:');
    print('  Locale Code: ${data.localeCode}');
    print('  Locale Name: ${data.localeName}');
    print('  Language Direction: ${data.languageDirection}');
    print('  Supported Count: ${data.supportedLanguages?.length ?? 0}');
    print('  Error Code: ${data.error?.longErrorCode}');

    // Early error check - exit immediately if error exists
    if (data.error?.longErrorCode != 0) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Language Change Failed'),
          content: Text(
            'Failed to change language.\n\n'
            'Error: ${data.error?.errorString}\n'
            'Error Code: ${data.error?.longErrorCode}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Check if language change was successful
    print('SDKEventProvider - Language changed successfully to: ${data.localeName}');

    // Update language provider with SDK's updated language configuration
    if (data.supportedLanguages != null && data.supportedLanguages!.isNotEmpty) {
      print('SDKEventProvider - Updating language provider with new SDK languages');

      ref.read(languageProvider.notifier).updateFromSDK(
            data.supportedLanguages!,
            data.localeCode ?? 'en',
          );
    }
  }

  @override
  void initState() {
    super.initState();

    // Register language event handler
    final eventManager = RdnaService.getInstance().getEventManager();
    eventManager.setSetLanguageResponseHandler(_handleSetLanguageResponse);
  }

  @override
  void dispose() {
    // Cleanup on dispose
    final eventManager = RdnaService.getInstance().getEventManager();
    eventManager.setSetLanguageResponseHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
```

### Type Definitions

#### Customer Language Types
```dart
// language.dart - Customer Language Class (Separate from SDK)
/// Customer Language Class
/// Separate from SDK's RDNASupportedLanguage - optimized for customer UI
class Language {
  final String lang;           // Full locale code: 'en-US', 'hi-IN', 'ar-SA', 'es-ES'
  final String displayText;    // Display name: 'English', 'Hindi', 'Arabic', 'Spanish'
  final String nativeName;     // Native script: 'English', 'हिन्दी', 'العربية', 'Español'
  final int direction;         // 0 = LTR, 1 = RTL (matches SDK enum values)
  final bool isRTL;            // Helper for UI decisions

  Language({
    required this.lang,
    required this.displayText,
    required this.nativeName,
    required this.direction,
    required this.isRTL,
  });
}
```

### Utility Functions

#### Language Configuration Utilities
```dart
// language_config.dart - Language Conversion and Lookup Utilities
import 'package:rdna_client/rdna_struct.dart';
import '../types/language.dart';

/// Default Hardcoded Languages
/// Shown before SDK initialization completes
/// Using full locale codes for consistency with SDK
final List<Language> defaultSupportedLanguages = [
  Language(
    lang: 'en-US',
    displayText: 'English',
    nativeName: 'English',
    direction: 0,
    isRTL: false,
  ),
  Language(
    lang: 'hi-IN',
    displayText: 'Hindi',
    nativeName: 'हिन्दी',
    direction: 0,
    isRTL: false,
  ),
  Language(
    lang: 'es-ES',
    displayText: 'Spanish',
    nativeName: 'Español',
    direction: 0,
    isRTL: false,
  ),
];

final Language defaultLanguage = defaultSupportedLanguages[0]; // English

/// Native Name Lookup Table
/// SDK doesn't provide native names, so we maintain this hardcoded mapping
final Map<String, String> nativeNameLookup = {
  'en': 'English',
  'hi': 'हिन्दी',
  'ar': 'العربية',
  'es': 'Español',
  'fr': 'Français',
};

/// Convert SDK's RDNASupportedLanguage to Customer's Language class
Language convertSDKLanguageToCustomer(RDNASupportedLanguage sdkLang) {
  final directionNum = sdkLang.direction == 'RTL' ? 1 : 0;
  final isRTL = sdkLang.direction == 'RTL';
  final langCode = sdkLang.lang ?? 'en';
  final displayText = sdkLang.displayText ?? 'Unknown';
  final nativeName = getNativeName(langCode, displayText);

  return Language(
    lang: langCode,
    displayText: displayText,
    nativeName: nativeName,
    direction: directionNum,
    isRTL: isRTL,
  );
}

/// Get native name for a language code
String getNativeName(String langCode, String displayText) {
  final baseCode = langCode.split('-')[0];
  return nativeNameLookup[baseCode] ?? displayText;
}

/// Get language by locale code
Language getLanguageByCode(String langCode, List<Language> languages) {
  // Try exact match first
  Language? found = languages.cast<Language?>().firstWhere(
    (lang) => lang?.lang == langCode,
    orElse: () => null,
  );

  // If not found, try matching base code
  if (found == null) {
    final baseCode = langCode.split('-')[0];
    found = languages.cast<Language?>().firstWhere(
      (lang) => lang?.lang.startsWith(baseCode) ?? false,
      orElse: () => null,
    );
  }

  return found ?? defaultLanguage;
}

/// Convert direction integer to RDNALanguageDirection enum
RDNALanguageDirection getLanguageDirectionEnum(int direction) {
  return direction == 1
      ? RDNALanguageDirection.RDNA_LOCALE_RTL
      : RDNALanguageDirection.RDNA_LOCALE_LTR;
}
```

#### Language Persistence Utilities
```dart
// language_storage.dart - SharedPreferences Persistence
import 'package:shared_preferences/shared_preferences.dart';

class LanguageStorage {
  static const String _languageKey = 'app_language_preference';

  /// Save language preference to SharedPreferences
  static Future<void> save(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      print('LanguageStorage - Saved language: $languageCode');
    } catch (error) {
      print('LanguageStorage - Error saving language: $error');
      rethrow;
    }
  }

  /// Load language preference from SharedPreferences
  static Future<String?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      print('LanguageStorage - Loaded language: $languageCode');
      return languageCode;
    } catch (error) {
      print('LanguageStorage - Error loading language: $error');
      return null;
    }
  }

  /// Clear saved language preference
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_languageKey);
      print('LanguageStorage - Cleared language preference');
    } catch (error) {
      print('LanguageStorage - Error clearing language: $error');
      rethrow;
    }
  }
}
```

### Native Localization Files

#### Android Localization (strings.xml)
```xml
<!-- android/app/src/main/res/values/strings_rel_id.xml -->
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- English Error Messages -->
    <string name="error_12345">SDK initialization failed</string>
    <string name="error_67890">Network connection error</string>
    <!-- Add more error code mappings -->
</resources>

<!-- android/app/src/main/res/values-es/strings_rel_id.xml -->
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Spanish Error Messages -->
    <string name="error_12345">Error de inicialización del SDK</string>
    <string name="error_67890">Error de conexión de red</string>
    <!-- Add more error code mappings -->
</resources>

<!-- android/app/src/main/res/values-hi/strings_rel_id.xml -->
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Hindi Error Messages -->
    <string name="error_12345">SDK प्रारंभीकरण विफल</string>
    <string name="error_67890">नेटवर्क कनेक्शन त्रुटि</string>
    <!-- Add more error code mappings -->
</resources>
```

#### iOS Localization (.strings)
```
// ios/SharedLocalization/en.lproj/RELID.strings
/* English Error Messages */
"error_12345" = "SDK initialization failed";
"error_67890" = "Network connection error";

// ios/SharedLocalization/es.lproj/RELID.strings
/* Spanish Error Messages */
"error_12345" = "Error de inicialización del SDK";
"error_67890" = "Error de conexión de red";

// ios/SharedLocalization/hi.lproj/RELID.strings
/* Hindi Error Messages */
"error_12345" = "SDK प्रारंभीकरण विफल";
"error_67890" = "नेटवर्क कनेक्शन त्रुटि";
```

---

## 📚 Related Documentation

### Official REL-ID Internationalization APIs
- **[SDK Initialization API](https://developer.uniken.com/docs/internationalization)** - Complete API reference for SDK initialization with language preferences
- **[Set SDK Language API](https://developer.uniken.com/docs/internationalization)** - Comprehensive guide for dynamic language switching
- **[Language Events API](https://developer.uniken.com/docs/internationalization)** - Event handler documentation for language response events

---

**🌐 Congratulations! You've mastered Internationalization with REL-ID SDK!**

*You're now equipped to implement production-ready multi-language Flutter applications with proper SDK integration, dynamic language switching, and native platform localization. Use this knowledge to create globally accessible experiences that provide users with seamless language management across initialization and runtime, while maintaining proper error handling through native localization files.*
