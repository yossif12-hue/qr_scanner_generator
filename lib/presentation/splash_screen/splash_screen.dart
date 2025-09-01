import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate app initialization tasks
      await Future.wait([
        _loadUserPreferences(),
        _initializeCameraPermissions(),
        _prepareQRCodeLibraries(),
        _checkDeviceCapabilities(),
      ]);

      setState(() {
        _isInitialized = true;
      });

      // Wait for animation to complete before navigating
      await Future.delayed(const Duration(milliseconds: 2500));

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/qr-scanner-screen');
      }
    } catch (e) {
      // Handle initialization errors gracefully
      setState(() {
        _isInitialized = true;
      });

      await Future.delayed(const Duration(milliseconds: 2500));

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/qr-scanner-screen');
      }
    }
  }

  Future<void> _loadUserPreferences() async {
    // Simulate loading theme and language preferences
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _initializeCameraPermissions() async {
    // Simulate checking camera permissions status
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _prepareQRCodeLibraries() async {
    // Simulate preparing QR code scanning libraries
    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<void> _checkDeviceCapabilities() async {
    // Simulate checking device capabilities
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    const Color(0xFF0b1020),
                    const Color(0xFF121a36),
                  ]
                : [
                    const Color(0xFFf6f7fb),
                    const Color(0xFFe8ecff),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildLogoSection(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              _buildLoadingSection(),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'qr_code_scanner',
              color: Colors.white,
              size: 12.w,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'QR Scanner',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Scan & Generate QR Codes',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 8.w,
          height: 8.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryLight,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            _isInitialized ? 'Ready!' : 'Initializing...',
            key: ValueKey(_isInitialized),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}
