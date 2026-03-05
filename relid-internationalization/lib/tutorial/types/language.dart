// ============================================================================
// File: language.dart
// Description: Customer Language Interface
//
// Transformed from: relid-codelab-react-native/relid-internationalization/src/tutorial/types/language.ts
// Original: language.ts
//
// Separate from SDK's RDNASupportedLanguage - optimized for customer UI
// ============================================================================

/// Customer Language Interface
///
/// Optimized for customer UI display and navigation.
/// Separate from SDK's RDNASupportedLanguage to provide better UX control.
///
/// ## Fields
/// - [lang]: Full locale code (e.g., 'en-US', 'hi-IN', 'ar-SA', 'es-ES', 'fr-FR')
/// - [displayText]: Display name in English (e.g., 'English', 'Hindi', 'Arabic')
/// - [nativeName]: Native script name (e.g., 'English', 'हिन्दी', 'العربية')
/// - [direction]: Text direction (0 = LTR, 1 = RTL) - matches SDK initOptions
/// - [isRTL]: Helper flag for UI decisions
class Language {
  final String lang;
  final String displayText;
  final String nativeName;
  final int direction;
  final bool isRTL;

  Language({
    required this.lang,
    required this.displayText,
    required this.nativeName,
    required this.direction,
    required this.isRTL,
  });

  /// Creates a Language from JSON map
  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      lang: json['lang'] as String,
      displayText: json['displayText'] as String,
      nativeName: json['nativeName'] as String,
      direction: json['direction'] as int,
      isRTL: json['isRTL'] as bool,
    );
  }

  /// Converts Language to JSON map
  Map<String, dynamic> toJson() {
    return {
      'lang': lang,
      'displayText': displayText,
      'nativeName': nativeName,
      'direction': direction,
      'isRTL': isRTL,
    };
  }

  /// Creates a copy of this Language with optional field overrides
  Language copyWith({
    String? lang,
    String? displayText,
    String? nativeName,
    int? direction,
    bool? isRTL,
  }) {
    return Language(
      lang: lang ?? this.lang,
      displayText: displayText ?? this.displayText,
      nativeName: nativeName ?? this.nativeName,
      direction: direction ?? this.direction,
      isRTL: isRTL ?? this.isRTL,
    );
  }

  @override
  String toString() {
    return 'Language(lang: $lang, displayText: $displayText, nativeName: $nativeName, direction: $direction, isRTL: $isRTL)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Language && other.lang == lang;
  }

  @override
  int get hashCode => lang.hashCode;
}
