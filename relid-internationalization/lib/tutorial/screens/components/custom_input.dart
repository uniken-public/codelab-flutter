// ============================================================================
// File: custom_input.dart
// Description: Reusable Input Component
//
// Transformed from React Native Input component
// Matches exact RN styling with error states
// ============================================================================

import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  final String label;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final String? error;
  final VoidCallback? onSubmitted;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;

  const CustomInput({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.placeholder,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.error,
    this.onSubmitted,
    this.suffixIcon,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(CustomInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2c3e50), // Title color from RN
          ),
        ),
        const SizedBox(height: 8),

        // Text Field
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted != null ? (_) => widget.onSubmitted!() : null,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction ?? TextInputAction.done,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: const TextStyle(
              color: Color(0xFF95a5a6),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16), // 16px padding from RN
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), // 8px radius from RN
              borderSide: BorderSide(
                color: widget.error != null
                    ? const Color(0xFFe74c3c) // Error red from RN
                    : const Color(0xFFdddddd), // Border color from RN
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.error != null
                    ? const Color(0xFFe74c3c)
                    : const Color(0xFFdddddd),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.error != null
                    ? const Color(0xFFe74c3c)
                    : const Color(0xFF3498db), // Primary blue from RN
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFe74c3c),
                width: 1,
              ),
            ),
            suffixIcon: widget.suffixIcon,
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF2c3e50),
          ),
        ),

        // Error message
        if (widget.error != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.error!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFe74c3c), // Error red from RN
            ),
          ),
        ],
      ],
    );
  }
}
