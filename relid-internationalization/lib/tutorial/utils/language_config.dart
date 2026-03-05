// ============================================================================
// File: language_config.dart
// Description: Language Configuration and Conversion Utilities
//
// Transformed from: relid-codelab-react-native/relid-internationalization/src/tutorial/utils/languageConfig.ts
// Original: languageConfig.ts
//
// Provides default languages, native name mappings, and SDK conversion utilities
// ============================================================================

import 'package:rdna_client/rdna_struct.dart';
import '../types/language.dart';

/// Default Hardcoded Languages
///
/// Shown before SDK initialization completes.
/// Using full locale codes for consistency with SDK.
///
/// ## Supported Languages
/// - English (en-US) - LTR
/// - Hindi (hi-IN) - LTR
/// - Arabic (ar-SA) - RTL
/// - Spanish (es-ES) - LTR
/// - French (fr-FR) - LTR
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
    lang: 'ar-SA',
    displayText: 'Arabic',
    nativeName: 'العربية',
    direction: 1,
    isRTL: true,
  ),
  Language(
    lang: 'es-ES',
    displayText: 'Spanish',
    nativeName: 'Español',
    direction: 0,
    isRTL: false,
  ),
  Language(
    lang: 'fr-FR',
    displayText: 'French',
    nativeName: 'Français',
    direction: 0,
    isRTL: false,
  ),
];

/// Default Language
///
/// English is the default language before SDK initialization.
final Language defaultLanguage = defaultSupportedLanguages[0];

/// Native Name Lookup Table
///
/// SDK doesn't provide native names, so we maintain this hardcoded mapping.
/// Maps language code prefix to native script name.
///
/// ## Examples
/// - 'en' → 'English'
/// - 'hi' → 'हिन्दी'
/// - 'ar' → 'العربية'
final Map<String, String> nativeNameLookup = {
  'en': 'English',
  'hi': 'हिन्दी',
  'ar': 'العربية',
  'es': 'Español',
  'fr': 'Français',
  'de': 'Deutsch',
  'it': 'Italiano',
  'pt': 'Português',
  'ru': 'Русский',
  'zh': '中文',
  'ja': '日本語',
  'ko': '한국어',
};

/// Get native name for a language code
///
/// Extracts base language code and looks up native name.
///
/// ## Parameters
/// - [langCode]: Full locale code (e.g., 'en-US', 'hi-IN')
/// - [displayText]: Fallback display text if native name not found
///
/// ## Returns
/// Native name or [displayText] as fallback
///
/// ## Example
/// ```dart
/// final nativeName = getNativeName('hi-IN', 'Hindi');
/// // Returns: 'हिन्दी'
/// ```
String getNativeName(String langCode, String displayText) {
  final baseCode = langCode.split('-')[0]; // 'en-US' → 'en'
  return nativeNameLookup[baseCode] ?? displayText;
}

/// Convert SDK's RDNASupportedLanguage to Customer's Language interface
///
/// Maps SDK response format to customer UI format with native names.
///
/// ## Parameters
/// - [sdkLang]: SDK language object from plugin
///
/// ## Returns
/// Customer [Language] object optimized for UI display
///
/// ## Example
/// ```dart
/// final sdkLang = RDNASupportedLanguage(
///   lang: 'hi-IN',
///   displayText: 'Hindi',
///   direction: 'LTR',
/// );
/// final customerLang = convertSDKLanguageToCustomer(sdkLang);
/// // customerLang.nativeName = 'हिन्दी'
/// ```
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

/// Get language by locale code
///
/// Searches for language by exact match or base code match.
///
/// ## Parameters
/// - [langCode]: Full locale code (e.g., 'en-US') or base code (e.g., 'en')
/// - [languages]: Language array to search in
///
/// ## Returns
/// Matching [Language] or [defaultLanguage] if not found
///
/// ## Example
/// ```dart
/// final language = getLanguageByCode('hi-IN', supportedLanguages);
/// // Returns Hindi language object
///
/// final language2 = getLanguageByCode('hi', supportedLanguages);
/// // Also returns Hindi (matches base code)
/// ```
Language getLanguageByCode(String langCode, List<Language> languages) {
  // Try exact match first
  Language? found = languages.cast<Language?>().firstWhere(
    (lang) => lang?.lang == langCode,
    orElse: () => null,
  );

  // If not found, try matching base code (e.g., 'en' matches 'en-US')
  if (found == null) {
    final baseCode = langCode.split('-')[0];
    found = languages.cast<Language?>().firstWhere(
      (lang) => lang?.lang.startsWith(baseCode) ?? false,
      orElse: () => null,
    );
  }

  return found ?? defaultLanguage;
}

/// Extract short language code for SDK initOptions
///
/// SDK initOptions expects short codes like 'en', 'hi', 'ar'.
///
/// ## Parameters
/// - [fullLocale]: Full locale code (e.g., 'en-US')
///
/// ## Returns
/// Short language code (e.g., 'en')
///
/// ## Example
/// ```dart
/// final shortCode = getShortLanguageCode('en-US');
/// // Returns: 'en'
/// ```
String getShortLanguageCode(String fullLocale) {
  return fullLocale.split('-')[0];
}

/// Convert direction integer to RDNALanguageDirection enum
///
/// Converts the direction field from Language class (0 or 1) to the
/// RDNALanguageDirection enum required by the plugin API.
///
/// ## Parameters
/// - [direction]: Direction integer (0 = LTR, 1 = RTL)
///
/// ## Returns
/// RDNALanguageDirection enum value
///
/// ## Example
/// ```dart
/// final enumDirection = getLanguageDirectionEnum(1);
/// // Returns: RDNALanguageDirection.RDNA_LOCALE_RTL
/// ```
RDNALanguageDirection getLanguageDirectionEnum(int direction) {
  return direction == 1
      ? RDNALanguageDirection.RDNA_LOCALE_RTL
      : RDNALanguageDirection.RDNA_LOCALE_LTR;
}
