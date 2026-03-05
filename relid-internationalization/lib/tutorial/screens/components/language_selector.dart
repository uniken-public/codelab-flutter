// ============================================================================
// File: language_selector.dart
// Description: Customer-defined Language Selector Modal
//
// Transformed from: relid-codelab-react-native/relid-internationalization/src/tutorial/screens/components/LanguageSelector.tsx
// Original: LanguageSelector.tsx
//
// Provides UI for selecting application language.
// Customize the styling and layout to match your app's design system.
// ============================================================================

import 'package:flutter/material.dart';
import '../../types/language.dart';

/// Language Selector Modal
///
/// Bottom sheet modal for selecting application language.
/// Displays native names, RTL badges, and selection indicators.
///
/// ## Parameters
/// - [currentLanguage]: Currently selected language
/// - [supportedLanguages]: List of available languages
/// - [onSelectLanguage]: Callback when language is selected
class LanguageSelector extends StatelessWidget {
  final Language currentLanguage;
  final List<Language> supportedLanguages;
  final Function(Language) onSelectLanguage;

  const LanguageSelector({
    super.key,
    required this.currentLanguage,
    required this.supportedLanguages,
    required this.onSelectLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose your preferred language',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),

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
                            ? const BorderSide(
                                color: Color(0xFF007AFF),
                                width: 4,
                              )
                            : BorderSide.none,
                        bottom: const BorderSide(
                          color: Color(0xFFF0F0F0),
                          width: 1,
                        ),
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
                              const SizedBox(height: 2),
                              Text(
                                language.displayText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Metadata (RTL Badge + Checkmark)
                        Row(
                          children: [
                            // RTL Badge
                            if (language.isRTL) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Close Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF0F0F0),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Show Language Selector Modal
///
/// Helper function to display the language selector as a bottom sheet modal.
///
/// ## Parameters
/// - [context]: Build context
/// - [currentLanguage]: Currently selected language
/// - [supportedLanguages]: List of available languages
/// - [onSelectLanguage]: Callback when language is selected
///
/// ## Example
/// ```dart
/// showLanguageSelector(
///   context,
///   currentLanguage: languageState.currentLanguage,
///   supportedLanguages: languageState.supportedLanguages,
///   onSelectLanguage: (language) async {
///     await ref.read(languageProvider.notifier).changeLanguage(language);
///     Navigator.of(context).pop();
///   },
/// );
/// ```
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
    useRootNavigator: true, // Show above drawer and other overlays
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
