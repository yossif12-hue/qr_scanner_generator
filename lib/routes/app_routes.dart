import 'package:flutter/material.dart';
import '../presentation/scan_results_screen/scan_results_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/qr_scanner_screen/qr_scanner_screen.dart';
import '../presentation/qr_generator_screen/qr_generator_screen.dart';
import '../presentation/gallery_scanner_screen/gallery_scanner_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String scanResults = '/scan-results-screen';
  static const String splash = '/splash-screen';
  static const String settings = '/settings-screen';
  static const String qrScanner = '/qr-scanner-screen';
  static const String qrGenerator = '/qr-generator-screen';
  static const String galleryScanner = '/gallery-scanner-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    scanResults: (context) => const ScanResultsScreen(),
    splash: (context) => const SplashScreen(),
    settings: (context) => const SettingsScreen(),
    qrScanner: (context) => const QrScannerScreen(),
    qrGenerator: (context) => const QrGeneratorScreen(),
    galleryScanner: (context) => const GalleryScannerScreen(),
    // TODO: Add your other routes here
  };
}
