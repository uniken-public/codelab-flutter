// ============================================================================
// File: rename_device_dialog.dart
// Description: Rename Device Dialog
//
// Modal dialog for renaming a device with input validation.
//
// Transformed from: RenameDeviceDialog.tsx
// ============================================================================

import 'package:flutter/material.dart';

/// Rename Device Dialog
///
/// Modal dialog for renaming a device with input validation.
class RenameDeviceDialog extends StatefulWidget {
  final String currentName;

  const RenameDeviceDialog({
    super.key,
    required this.currentName,
  });

  @override
  State<RenameDeviceDialog> createState() => _RenameDeviceDialogState();
}

class _RenameDeviceDialogState extends State<RenameDeviceDialog> {
  late TextEditingController _controller;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final trimmedName = _controller.text.trim();

    if (trimmedName.isEmpty) {
      setState(() => _error = 'Device name cannot be empty');
      return;
    }

    if (trimmedName == widget.currentName) {
      setState(() => _error = 'New name must be different from current name');
      return;
    }

    if (trimmedName.length < 3) {
      setState(() => _error = 'Device name must be at least 3 characters');
      return;
    }

    if (trimmedName.length > 50) {
      setState(() => _error = 'Device name must be less than 50 characters');
      return;
    }

    Navigator.of(context).pop(trimmedName);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Rename Device',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 20),

            // Current Name
            const Text(
              'Current Name:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.currentName,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // New Name Input
            const Text(
              'New Name:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 50,
              decoration: InputDecoration(
                hintText: 'Enter new device name',
                hintStyle: const TextStyle(color: Color(0xFF999999)),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _error.isEmpty ? const Color(0xFFE0E0E0) : Colors.red,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _error.isEmpty ? const Color(0xFF007AFF) : Colors.red,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                counterText: '',
              ),
              onChanged: (value) {
                if (_error.isNotEmpty) {
                  setState(() => _error = '');
                }
              },
              onSubmitted: (_) => _handleSubmit(),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _error,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Rename',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
