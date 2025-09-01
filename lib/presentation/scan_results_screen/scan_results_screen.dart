import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/content_display_widget.dart';
import './widgets/scan_result_header_widget.dart';

class ScanResultsScreen extends StatefulWidget {
  const ScanResultsScreen({Key? key}) : super(key: key);

  @override
  State<ScanResultsScreen> createState() => _ScanResultsScreenState();
}

class _ScanResultsScreenState extends State<ScanResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  String _scannedContent = '';
  String _contentType = 'text';

  // Mock scan results data
  final List<Map<String, dynamic>> _mockScanResults = [
    {
      "id": 1,
      "content": "https://www.flutter.dev",
      "type": "url",
      "timestamp": "2025-09-01 11:35:22",
      "description": "Flutter Official Website"
    },
    {
      "id": 2,
      "content": "contact@example.com",
      "type": "email",
      "timestamp": "2025-09-01 11:30:15",
      "description": "Contact Email Address"
    },
    {
      "id": 3,
      "content":
          "Welcome to our QR Scanner app! This is a sample text content that demonstrates how the app handles plain text QR codes.",
      "type": "text",
      "timestamp": "2025-09-01 11:25:08",
      "description": "Sample Text Content"
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadMockData();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _loadMockData() {
    // Simulate receiving scan result data
    final mockResult = _mockScanResults.first;
    setState(() {
      _scannedContent = mockResult['content'] as String;
      _contentType = mockResult['type'] as String;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              ScanResultHeaderWidget(
                onClose: _handleClose,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 2.h),
                      _scannedContent.isNotEmpty
                          ? ContentDisplayWidget(
                              content: _scannedContent,
                              contentType: _contentType,
                              onCopy: _handleCopySuccess,
                            )
                          : _buildErrorState(),
                      ActionButtonsWidget(
                        content: _scannedContent,
                        contentType: _contentType,
                        onShare: _handleShare,
                        onSaveToHistory: _handleSaveToHistory,
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'error_outline',
            color: AppTheme.error,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'Invalid QR Code',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'The scanned QR code contains malformed or unreadable content.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleScanAnother,
            icon: CustomIconWidget(
              iconName: 'qr_code_scanner',
              color: Colors.white,
              size: 24,
            ),
            label: Text(
              'Scan Another',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLight,
              padding: EdgeInsets.symmetric(vertical: 2.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  void _handleCopySuccess() {
    Fluttertoast.showToast(
      msg: "Content copied to clipboard",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.success,
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }

  void _handleShare() async {
    try {
      await Share.share(
        _scannedContent,
        subject: 'QR Code Content',
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Unable to share content",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.error,
        textColor: Colors.white,
        fontSize: 14.sp,
      );
    }
  }

  void _handleSaveToHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> history = prefs.getStringList('scan_history') ?? [];

      final scanData = {
        'content': _scannedContent,
        'type': _contentType,
        'timestamp': DateTime.now().toIso8601String(),
      };

      history.insert(0, scanData.toString());

      // Keep only last 50 scans
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }

      await prefs.setStringList('scan_history', history);

      Fluttertoast.showToast(
        msg: "Saved to history",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.success,
        textColor: Colors.white,
        fontSize: 14.sp,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Unable to save to history",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.error,
        textColor: Colors.white,
        fontSize: 14.sp,
      );
    }
  }

  void _handleScanAnother() {
    Navigator.pushReplacementNamed(context, '/qr-scanner-screen');
  }

  String _detectContentType(String content) {
    // URL detection
    if (content.startsWith('http://') ||
        content.startsWith('https://') ||
        content.startsWith('www.')) {
      return 'url';
    }

    // Email detection
    if (RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(content)) {
      return 'email';
    }

    return 'text';
  }
}
