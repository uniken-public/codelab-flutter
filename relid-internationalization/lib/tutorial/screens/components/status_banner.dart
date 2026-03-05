// ============================================================================
// File: status_banner.dart
// Description: Reusable Status Banner Component
//
// Transformed from React Native StatusBanner component
// Matches exact RN styling for success/error states
// ============================================================================

import 'package:flutter/material.dart';

enum StatusBannerType { success, error }

class StatusBanner extends StatelessWidget {
  final StatusBannerType type;
  final String message;

  const StatusBanner({
    super.key,
    required this.type,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = type == StatusBannerType.success;

    return Container(
      padding: const EdgeInsets.all(16), // 16px padding from RN
      margin: const EdgeInsets.only(bottom: 20), // 20px margin from RN
      decoration: BoxDecoration(
        color: isSuccess
            ? const Color(0xFFf0f8f0) // Success background from RN
            : const Color(0xFFfff0f0), // Error background from RN
        borderRadius: BorderRadius.circular(8), // 8px radius from RN
        border: Border(
          left: BorderSide(
            color: isSuccess
                ? const Color(0xFF27ae60) // Success green from RN
                : const Color(0xFFe74c3c), // Error red from RN
            width: 4,
          ),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSuccess
              ? const Color(0xFF27ae60)
              : const Color(0xFFe74c3c),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
