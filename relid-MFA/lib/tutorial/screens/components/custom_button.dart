// ============================================================================
// File: custom_button.dart
// Description: Reusable Button Component
//
// Transformed from React Native Button component
// Matches exact RN styling: #3498db primary, #bdc3c7 disabled
// ============================================================================

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPress;
  final bool loading;
  final bool disabled;

  const CustomButton({
    super.key,
    required this.title,
    this.onPress,
    this.loading = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (disabled || loading) ? null : onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3498db), // Primary blue from RN
          disabledBackgroundColor: const Color(0xFFbdc3c7), // Disabled gray from RN
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // 8px radius from RN
          ),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
