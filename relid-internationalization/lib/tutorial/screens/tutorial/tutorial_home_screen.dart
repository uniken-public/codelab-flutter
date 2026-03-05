// ============================================================================
// File: tutorial_home_screen.dart
// Description: Tutorial Home Screen
//
// Main tutorial screen that displays SDK information and provides an
// initialization button. Handles progress updates and navigation to
// success or error screens based on initialization results.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rdna_client/rdna_struct.dart';
import '../../../uniken/services/rdna_service.dart';
import '../../../uniken/utils/progress_helper.dart';
import '../../providers/language_provider.dart';
import '../../utils/language_config.dart';
import '../components/language_selector.dart';

/// Tutorial Home Screen
///
/// Main tutorial screen that provides SDK information and initialization controls.
/// Displays real-time progress updates during SDK initialization.
class TutorialHomeScreen extends ConsumerStatefulWidget {
  const TutorialHomeScreen({super.key});

  @override
  ConsumerState<TutorialHomeScreen> createState() => _TutorialHomeScreenState();
}

class _TutorialHomeScreenState extends ConsumerState<TutorialHomeScreen> {
  String _sdkVersion = 'Loading...';
  bool _isInitializing = false;
  String _progressMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSDKVersion();
    _setupEventHandlers();
  }

  @override
  void dispose() {
    // Cleanup - reset handlers
    final rdnaService = RdnaService.getInstance();
    final eventManager = rdnaService.getEventManager();
    eventManager.setInitializeProgressHandler(null);
    eventManager.setInitializeErrorHandler(null);
    super.dispose();
  }

  /// Load SDK version on screen init
  Future<void> _loadSDKVersion() async {
    try {
      final rdnaService = RdnaService.getInstance();
      // ✅ Call without extra error handling - service returns 'Unknown' for empty response
      final version = await rdnaService.getSDKVersion();

      if (mounted) {
        setState(() {
          _sdkVersion = version;
        });
      }
    } catch (error) {
      // ✅ Only catch runtime errors (network, parsing, etc)
      print('TutorialHomeScreen - Failed to load SDK version: $error');

      if (mounted) {
        setState(() {
          _sdkVersion = 'Unknown';
        });
      }
    }
  }

  void _setupEventHandlers() {
    final rdnaService = RdnaService.getInstance();
    final eventManager = rdnaService.getEventManager();

    // Register error handler directly in TutorialHomeScreen
    eventManager.setInitializeErrorHandler((RDNAInitializeError errorData) {
      print('TutorialHomeScreen - Received initialize error: ${errorData.errorString}');

      // Update local state
      setState(() {
        _isInitializing = false;
        _progressMessage = '';
      });

      // Navigate to error screen with the error details
      if (mounted) {
        context.goNamed('tutorialErrorScreen', extra: errorData);
      }
    });
  }

  Future<void> _handleInitializePress() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
      _progressMessage = 'Starting RDNA initialization...';
    });

    print('TutorialHomeScreen - User clicked Initialize - Starting RDNA...');

    // ========================================
    // CONFIGURE SDK INITIALIZATION OPTIONS
    // ========================================
    // Customers: Customize this section based on your application requirements
    // If you don't provide initOptions, the SDK will use default values

    // OPTION 1: Use default configuration (recommended for most apps)
    // Simply call: rdnaService.initialize()
    // This uses: localeCode='en', languageDirection=LTR, location required but not mandatory

    // OPTION 2: Customize configuration for your app needs
    // Example scenarios:

    // Scenario A: Arabic/RTL language support
    // const language = 'ar';  // Get from your i18n library (e.g., Intl, device settings)
    // const languageDirection = ['ar', 'he', 'fa', 'ur'].contains(language) ? 1 : 0;

    // Scenario B: Get language from language provider
    // SDK accepts both full locale codes ('en-US', 'hi-IN') and short codes ('en', 'hi')
    final languageState = ref.read(languageProvider);
    final currentLanguage = languageState.currentLanguage;
    final languageCode = currentLanguage.lang;  // Full locale: 'en-US', 'hi-IN', 'ar-SA'
    final languageDirection = currentLanguage.direction;  // 0 = LTR, 1 = RTL

    print('TutorialHomeScreen - Initializing with language:');
    print('  Locale: $languageCode');                      // 'en-US', 'hi-IN', 'ar-SA'
    print('  Display Text: ${currentLanguage.displayText}'); // 'English', 'Hindi', 'Arabic'
    print('  Native Name: ${currentLanguage.nativeName}');  // 'English', 'हिन्दी', 'العربية'
    print('  Direction: $languageDirection');              // 0 = LTR, 1 = RTL
    print('  Is RTL: ${currentLanguage.isRTL}');

    // Scenario C: Location permission configuration
    // Set based on your app's requirements for location-based risk analysis
    const requireLocationPermission = true;   // Does your app need location for fraud detection?
    const locationIsMandatory = false;        // If false, SDK works with limited functionality without location

    // Scenario D: OpenTelemetry (OTel) configuration
    // Enable only if your organization uses OpenTelemetry for distributed tracing
    const enableTelemetry = false;  // Set to true for enterprise monitoring and observability

    // Build the initOptions configuration object
    final initOptions = RDNAInitOptions(
      internationalizationOptions: RDNAinternationalizationOptions(
        localeCode: languageCode,            // Full locale code: 'en-US', 'hi-IN', 'ar-SA', etc.
        localeName: currentLanguage.displayText, // Display name: 'English', 'Hindi', 'Arabic'
        languageDirection: languageDirection // 0 = LTR, 1 = RTL
      ),
      permissionOptions: RDNAPermissionOptions(
        isLocationPermissionRequired: requireLocationPermission,
        isLocationPermissionMandatory: locationIsMandatory
      ),
      otelConfig: RDNAOtelConfig(
        otelHTTPEndpointURL: enableTelemetry ? 'https://your-otel-collector.example.com' : '',
        enableEncoding: '',
        disableTrace: enableTelemetry ? 0 : 1,  // 0 = enabled, 1 = disabled
        otelTraceFlushTimeout: 0
      ),
    );

    print('TutorialHomeScreen - Initializing with custom options: ${initOptions.toJson()}');

    // Register progress handler directly with the event manager
    final rdnaService = RdnaService.getInstance();
    final eventManager = rdnaService.getEventManager();

    eventManager.setInitializeProgressHandler((RDNAInitProgressStatus data) {
      print('TutorialHomeScreen - Progress update: ${data.initializeStatus}');
      final message = getProgressMessage(data);
      if (mounted) {
        setState(() {
          _progressMessage = message;
        });
      }
    });

    // Call rdnaService.initialize() with custom configuration
    // Pass initOptions to customize SDK behavior
    // Or call without parameters: rdnaService.initialize() to use defaults
    final syncResponse = await rdnaService.initialize(initOptions);

    print('TutorialHomeScreen - RDNA initialization sync response received');
    print('TutorialHomeScreen - Sync response:');
    print('  Long Error Code: ${syncResponse.error!.longErrorCode}');
    print('  Short Error Code: ${syncResponse.error!.shortErrorCode}');

    // ✅ Check sync response - error is always present, check longErrorCode
    if (syncResponse.error!.longErrorCode != 0) {
      // Sync error - show dialog immediately
      print('TutorialHomeScreen - Sync error: ${syncResponse.error!.errorString}');

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _progressMessage = '';
        });

        _showErrorDialog(syncResponse.error!);
      }
    } else {
      // Sync success (longErrorCode == 0) - async events will handle next steps
      print('TutorialHomeScreen - Sync success, waiting for async events...');
    }
  }

  /// Show sync error dialog
  void _showErrorDialog(RDNAError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Failed'),
        content: Text(
          '${error.errorString}\n\n'
          'Error Codes:\n'
          'Long: ${error.longErrorCode}\n'
          'Short: ${error.shortErrorCode}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show language selector modal
  void _showLanguageSelector() {
    final languageState = ref.read(languageProvider);

    showLanguageSelector(
      context,
      currentLanguage: languageState.currentLanguage,
      supportedLanguages: languageState.supportedLanguages,
      onSelectLanguage: (language) async {
        try {
          // Update language in provider (persists to SharedPreferences)
          await ref.read(languageProvider.notifier).changeLanguage(language);
          print('TutorialHomeScreen - Language changed successfully to: ${language.displayText}');

          // Close modal
          if (mounted) {
            Navigator.of(context).pop();
          }
        } catch (error) {
          print('TutorialHomeScreen - Error changing language: $error');
        }
      },
    );
  }

  /// Build language configuration card
  Widget _buildLanguageCard() {
    final languageState = ref.watch(languageProvider);
    final currentLanguage = languageState.currentLanguage;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Language Configuration',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),

          // Language Button
          InkWell(
            onTap: _isInitializing ? null : _showLanguageSelector,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isInitializing ? const Color(0xFFF3F4F6) : Colors.white,
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Globe Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Text(
                        '🌐',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Language Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Language',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentLanguage.nativeName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // RTL Badge (if applicable)
                  if (currentLanguage.isRTL) ...[
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

                  // Arrow Icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: _isInitializing ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),

          // Hint Text
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: Color(0xFFF59E0B), width: 3),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Select language before initializing the SDK. The SDK will use this language for all interactions.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF92400E),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                color: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(
                  children: [
                    const Text(
                      'REL-ID Integration Tutorial',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Learn react-native-rdna-client plugin Integration',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFBFDBFE),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // SDK Info Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SDK Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('SDK Version:', _sdkVersion),
                    const SizedBox(height: 12),
                    _buildInfoRow('Platform:', 'Flutter'),
                  ],
                ),
              ),

              // Language Configuration Card
              _buildLanguageCard(),

              // Tutorial Steps
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tutorial Steps',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStep(1, 'Click "Initialize" to start the initialization'),
                    const SizedBox(height: 16),
                    _buildStep(2, 'Watch the initialization progress'),
                    const SizedBox(height: 16),
                    _buildStep(3, 'View the result on completion'),
                  ],
                ),
              ),

              // Initialize Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _isInitializing ? null : _handleInitializePress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    disabledBackgroundColor: const Color(0xFF9CA3AF),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: _isInitializing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Initializing...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Initialize',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              // Progress Message
              if (_isInitializing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(
                        left: BorderSide(color: Color(0xFF2563EB), width: 4),
                      ),
                    ),
                    child: Text(
                      _progressMessage.isNotEmpty
                          ? _progressMessage
                          : 'RDNA initialization in progress...',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1E40AF),
                        fontWeight: FontWeight.w500,
                        height: 1.375,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'This tutorial demonstrates react-native-rdna-client plugin initialization with real-time progress tracking',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.43,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildStep(int number, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFF2563EB),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }
}
