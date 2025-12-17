// ============================================================================
// File: main.dart
// Description: Main Application Entry Point
//
// Transformed from: App.tsx
// Original: React Native App.tsx
//
// Main entry point for the Flutter REL-ID integration tutorial application.
// Wraps the app with SDKEventProviderWidget for global event handling,
// similar to React Native's Context Provider pattern.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tutorial/navigation/app_router.dart';
import 'uniken/providers/sdk_event_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Main Application Widget
///
/// Sets up the application with:
/// - Riverpod for state management
/// - SDKEventProviderWidget for global SDK event handling
/// - GoRouter for navigation
///
/// Similar to React Native structure:
/// ```jsx
/// <SDKEventProvider>
///   <NavigationContainer>
///     <YourApp />
///   </NavigationContainer>
/// </SDKEventProvider>
/// ```
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SDKEventProviderWidget(
      child: MaterialApp.router(
        title: 'REL-ID Integration Tutorial',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
