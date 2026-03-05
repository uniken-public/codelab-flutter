// ============================================================================
// File: data_signing_result_screen.dart
// Description: Data Signing Result Screen
//
// Displays the results of data signing operation with signature details.
// Includes copy-to-clipboard functionality for all values.
//
// Transformed from: React Native DataSigningResultScreen.tsx
//
// Features:
// - Success header with icon
// - Result items with copy buttons
// - Expandable signature display
// - Sign another document button
// - Security information section
// - Full value viewing in dialogs
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'data_signing_service.dart';
import 'data_signing_types.dart';
import 'package:rdna_client/rdna_struct.dart';

/// Data Signing Result Screen
///
/// Displays the cryptographically signed data with all metadata.
/// Allows users to copy values and sign another document.
class DataSigningResultScreen extends ConsumerStatefulWidget {
  final AuthenticateUserAndSignData resultData;

  const DataSigningResultScreen({
    Key? key,
    required this.resultData,
  }) : super(key: key);

  @override
  ConsumerState<DataSigningResultScreen> createState() => _DataSigningResultScreenState();
}

class _DataSigningResultScreenState extends ConsumerState<DataSigningResultScreen> {
  String? _copiedField;

  /// Handles copy to clipboard
  Future<void> _handleCopyToClipboard(String value, String fieldName) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));

      setState(() => _copiedField = fieldName);

      // Reset copied state after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _copiedField = null);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fieldName copied to clipboard'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      print('DataSigningResultScreen - Failed to copy to clipboard: $error');
      if (mounted) {
        _showErrorDialog('Failed to copy to clipboard');
      }
    }
  }

  /// Handles sign another button
  Future<void> _handleSignAnother() async {
    print('DataSigningResultScreen - Sign another button pressed');

    final response = await DataSigningService.resetState();

    if (mounted) {
      // Check if reset had errors
      if (response.error?.longErrorCode != 0) {
        print('DataSigningResultScreen - Reset state error: ${response.error?.errorString}');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Error'),
            content: Text(response.error?.errorString ?? 'Failed to reset state'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  context.pop(); // Go back anyway
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Success - go back to input screen
        context.pop();
      }
    }
  }

  /// Shows error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shows full value in dialog
  void _showFullValueDialog(String title, String value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: SelectableText(
            value,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format result for display
    final displayData = DataSigningService.formatSigningResultForDisplay(widget.resultData);
    final resultItems = DataSigningService.convertToResultInfoItems(displayData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signing Results'),
        backgroundColor: const Color(0xFF007AFF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success Header
            _buildSuccessHeader(),
            const SizedBox(height: 32),

            // Results Section
            _buildResultsSection(resultItems),
            const SizedBox(height: 32),

            // Actions Section
            _buildActionsSection(),
            const SizedBox(height: 24),

            // Security Info
            _buildSecurityInfo(),
          ],
        ),
      ),
    );
  }

  /// Builds the success header
  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E8),
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Center(
            child: Text(
              '✅',
              style: TextStyle(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Data Signing Successful!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Your data has been cryptographically signed',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the results section
  Widget _buildResultsSection(List<ResultInfoItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Signing Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'All values below have been cryptographically verified',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 20),
        ...items.map((item) => _buildResultItem(item)).toList(),
      ],
    );
  }

  /// Builds a single result item
  Widget _buildResultItem(ResultInfoItem item) {
    final isSignature = item.name == 'Payload Signature';
    final isLongValue = item.value.length > 50;
    final displayValue = isLongValue && !isSignature
        ? '${item.value.substring(0, 50)}...'
        : item.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with label and copy button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
              if (item.value != 'N/A')
                OutlinedButton.icon(
                  onPressed: () => _handleCopyToClipboard(item.value, item.name),
                  icon: Icon(
                    _copiedField == item.name ? Icons.check : Icons.copy,
                    size: 14,
                  ),
                  label: Text(
                    _copiedField == item.name ? 'Copied' : 'Copy',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: const BorderSide(color: Color(0xFF007AFF)),
                    foregroundColor: const Color(0xFF007AFF),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Value container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSignature ? const Color(0xFFFFF5E6) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: isSignature
                  ? const Border(left: BorderSide(color: Color(0xFFFF9500), width: 4))
                  : null,
            ),
            child: SelectableText(
              displayValue,
              style: TextStyle(
                fontSize: isSignature ? 12 : 16,
                color: const Color(0xFF1A1A1A),
                fontFamily: isSignature ? 'monospace' : null,
                height: 1.4,
              ),
            ),
          ),

          // Expand button for long values
          if (isLongValue || isSignature) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showFullValueDialog(item.name, item.value),
              child: Text(
                isSignature ? 'View Complete Signature' : 'View Full Value',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF007AFF),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the actions section
  Widget _buildActionsSection() {
    return ElevatedButton(
      onPressed: _handleSignAnother,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFF007AFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      child: const Text(
        '🔐 Sign Another Document',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Builds the security info section
  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF007AFF), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🛡️ Security Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Your signature is cryptographically secure and tamper-proof\n'
            '• The signature ID uniquely identifies this signing operation\n'
            '• Data integrity is mathematically guaranteed\n'
            '• This signature can be verified independently',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
