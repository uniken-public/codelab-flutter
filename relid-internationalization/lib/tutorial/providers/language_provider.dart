// ============================================================================
// File: language_provider.dart
// Description: Language State Management Provider
//
// Transformed from: relid-codelab-react-native/relid-internationalization/src/tutorial/context/LanguageContext.tsx
// Original: LanguageContext.tsx
//
// Uses Riverpod for state management with persistent storage support
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../types/language.dart';
import '../utils/language_config.dart';
import '../utils/language_storage.dart';

/// Language Provider State
///
/// Manages current language, supported languages, and loading state.
class LanguageState {
  final Language currentLanguage;
  final List<Language> supportedLanguages;
  final bool isLoading;

  LanguageState({
    required this.currentLanguage,
    required this.supportedLanguages,
    required this.isLoading,
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

/// Language Provider Notifier
///
/// Manages language state and provides methods for language operations:
/// - [loadPersistedLanguage]: Load saved language preference on initialization
/// - [changeLanguage]: Change current language and persist preference
/// - [updateFromSDK]: Update languages from SDK initialization response
class LanguageNotifier extends StateNotifier<LanguageState> {
  LanguageNotifier()
      : super(LanguageState(
          currentLanguage: defaultLanguage,
          supportedLanguages: defaultSupportedLanguages,
          isLoading: true,
        )) {
    loadPersistedLanguage();
  }

  /// Load persisted language on initialization
  ///
  /// Reads previously saved language preference from SharedPreferences.
  /// If found, updates current language. Otherwise, uses default (English).
  Future<void> loadPersistedLanguage() async {
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
        print('LanguageProvider - No persisted language, using default: ${defaultLanguage.displayText}');
      }
    } catch (error) {
      print('LanguageProvider - Error loading language: $error');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Change language and persist preference
  ///
  /// Updates current language and saves preference to persistent storage.
  ///
  /// ## Parameters
  /// - [language]: New language to set
  ///
  /// ## Throws
  /// - Exception if storage fails
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
  ///
  /// Called after SDK initialization completes to update language list
  /// from server configuration.
  ///
  /// ## Parameters
  /// - [sdkLanguages]: Array of languages from SDK's additionalInfo.supportedLanguage
  /// - [sdkSelectedLanguage]: Selected language code from SDK's additionalInfo.selectedLanguage
  void updateFromSDK(List<RDNASupportedLanguage> sdkLanguages, String sdkSelectedLanguage) {
    try {
      print('LanguageProvider - Updating from SDK:');
      print('  SDK Languages Count: ${sdkLanguages.length}');
      print('  SDK Selected Language: $sdkSelectedLanguage');

      // Convert SDK languages to customer format
      final convertedLanguages = sdkLanguages.map(convertSDKLanguageToCustomer).toList();

      // Update supported languages
      print('LanguageProvider - Updated supported languages: ${convertedLanguages.map((l) => l.lang).toList()}');

      // Update current language based on SDK's selected language
      final sdkCurrentLanguage = getLanguageByCode(sdkSelectedLanguage, convertedLanguages);
      print('LanguageProvider - SDK selected language: ${sdkCurrentLanguage.displayText}');

      // Update state
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

/// Language Provider
///
/// Global provider for language state management.
///
/// ## Usage
/// ```dart
/// // Read language state
/// final languageState = ref.watch(languageProvider);
/// final currentLanguage = languageState.currentLanguage;
/// final supportedLanguages = languageState.supportedLanguages;
///
/// // Change language
/// ref.read(languageProvider.notifier).changeLanguage(newLanguage);
///
/// // Update from SDK
/// ref.read(languageProvider.notifier).updateFromSDK(sdkLanguages, sdkSelectedLang);
/// ```
final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>((ref) {
  return LanguageNotifier();
});
