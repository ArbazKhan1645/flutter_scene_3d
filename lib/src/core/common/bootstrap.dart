import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional bootstrap function to initialize services and handle errors.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // Preserve splash screen until initialization is complete on supported builds.
  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  // Add more initializations here (e.g., Firebase, Local Database, Logging)
  
  // Pre-load fonts for instant UI rendering
  unawaited(GoogleFonts.pendingFonts());
  
  FlutterError.onError = (details) {
    debugPrint('Flutter Error: ${details.exceptionAsString()}');
    debugPrint('Stack trace: ${details.stack}');
  };

  runApp(
    ProviderScope(
      child: await builder(),
    ),
  );

  // Remove splash screen after the app is ready on supported builds.
  if (!kIsWeb) {
    FlutterNativeSplash.remove();
  }
}
