// ============================================================================
// File: close_button.dart
// Description: Reusable Close Button Component
//
// Transformed from: CloseButton.tsx
// Positioned in top-left corner, triggers resetAuthState to restart flow
// ============================================================================

import 'package:flutter/material.dart';

class CustomCloseButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool disabled;

  const CustomCloseButton({
    super.key,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.black.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '✕',
                style: TextStyle(
                  fontSize: 18,
                  color: disabled
                      ? const Color(0xFF666666).withOpacity(0.5)
                      : const Color(0xFF666666),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
