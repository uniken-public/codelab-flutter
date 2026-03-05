// ============================================================================
// File: language_storage.dart
// Description: Language Persistence Storage Utility
//
// Transformed from: relid-codelab-react-native/relid-internationalization/src/tutorial/utils/languageStorage.ts
// Original: languageStorage.ts
//
// Uses SharedPreferences for persistent language storage
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';

/// Language Storage Key
const String _languageKey = 'tutorial_app_language';

/// Language Storage Utility
///
/// Provides persistent storage for user's selected language preference.
/// Uses SharedPreferences for platform-independent storage.
///
/// ## Methods
/// - [save]: Save language code to persistent storage
/// - [load]: Load previously saved language code
/// - [clear]: Clear saved language preference
class LanguageStorage {
  /// Save selected language code to persistent storage
  ///
  /// ## Parameters
  /// - [languageCode]: Full locale code (e.g., 'en-US', 'hi-IN', 'ar-SA')
  ///
  /// ## Throws
  /// - Exception if storage fails
  ///
  /// ## Example
  /// ```dart
  /// await LanguageStorage.save('hi-IN');
  /// ```
  static Future<void> save(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      print('Language saved to storage: $languageCode');
    } catch (error) {
      print('Failed to save language: $error');
      rethrow;
    }
  }

  /// Load previously saved language code
  ///
  /// ## Returns
  /// - Language code string if previously saved
  /// - `null` if no language preference exists
  ///
  /// ## Example
  /// ```dart
  /// final savedLanguage = await LanguageStorage.load();
  /// if (savedLanguage != null) {
  ///   print('Previously saved language: $savedLanguage');
  /// }
  /// ```
  static Future<String?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_languageKey);
      print('Language loaded from storage: $code');
      return code;
    } catch (error) {
      print('Failed to load language: $error');
      return null;
    }
  }

  /// Clear saved language preference
  ///
  /// Removes the stored language preference from persistent storage.
  ///
  /// ## Example
  /// ```dart
  /// await LanguageStorage.clear();
  /// ```
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_languageKey);
      print('Language preference cleared');
    } catch (error) {
      print('Failed to clear language: $error');
    }
  }
}
