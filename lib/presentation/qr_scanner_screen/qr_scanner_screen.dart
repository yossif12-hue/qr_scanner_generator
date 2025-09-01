import 'dart:async'; // Add this import for StreamController
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/camera_controls_widget.dart';
import './widgets/scan_result_bottom_sheet.dart';
import './widgets/scanning_overlay_widget.dart';
import './widgets/top_controls_widget.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // Camera related variables
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isScanning = false;
  bool _hasPermission = false;

  // UI state variables
  bool _isDarkTheme = false;
  String _currentLanguage = 'EN';
  String? _scannedData;

  // QR Scanner specific variables
  bool _isAiScannerActive = false;
  StreamController<BarcodeCapture>? _scanController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPreferences();
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _scanController?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_hasPermission) {
        _initializeCamera();
      }
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _currentLanguage = prefs.getString('currentLanguage') ?? 'EN';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    await prefs.setString('currentLanguage', _currentLanguage);
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) {
      // Web browsers handle camera permissions automatically
      return true;
    }

    var status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      status = await Permission.camera.request();
      return status.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }

    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isCameraInitialized = false;
      });

      // Request camera permission first
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        setState(() {
          _hasPermission = false;
        });
        return;
      }

      setState(() {
        _hasPermission = true;
      });

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showNoCameraDialog();
        return;
      }

      // Select camera based on platform
      if (kIsWeb) {
        // For web, prefer front camera
        _selectedCameraIndex = _cameras.indexWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
        if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;
      } else {
        // For mobile, prefer back camera for better QR scanning
        _selectedCameraIndex = _cameras.indexWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
        );
        if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;
      }

      // Initialize camera controller with higher resolution for better QR detection
      _cameraController = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Apply enhanced platform-specific settings for QR scanning
      await _applyEnhancedCameraSettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        _showCameraErrorDialog();
      }
    }
  }

  Future<void> _applyEnhancedCameraSettings() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      // Enhanced focus settings for better QR detection
      await _cameraController!.setFocusMode(FocusMode.auto);

      // Enable focus point for center scanning
      if (!kIsWeb) {
        try {
          // Set focus point to center for better QR detection
          await _cameraController!.setFocusPoint(const Offset(0.5, 0.5));

          // Set exposure point to center as well
          await _cameraController!.setExposurePoint(const Offset(0.5, 0.5));

          // Set flash mode
          await _cameraController!.setFlashMode(FlashMode.off);

          // Enable exposure compensation for better scanning in various lighting
          await _cameraController!.setExposureMode(ExposureMode.auto);
        } catch (e) {
          debugPrint('Enhanced camera settings error: $e');
        }
      }
    } catch (e) {
      debugPrint('Error applying enhanced camera settings: $e');
    }
  }

  Future<void> _startRealQrScanning() async {
    if (_isScanning || _isAiScannerActive) return;

    try {
      setState(() {
        _isScanning = true;
        _isAiScannerActive = true;
      });

      // Use AI Barcode Scanner for actual QR detection
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AiBarcodeScanner(
            onDetect: (BarcodeCapture capture) {
              final String? scannedValue = capture.barcodes.isNotEmpty
                  ? capture.barcodes.first.displayValue
                  : null;

              if (scannedValue != null && scannedValue.isNotEmpty) {
                setState(() {
                  _scannedData = scannedValue;
                  _isScanning = false;
                  _isAiScannerActive = false;
                });

                // Provide haptic feedback
                HapticFeedback.mediumImpact();

                Navigator.of(context).pop();
                _showScanResult();
              }
            },
            onDispose: () {
              setState(() {
                _isScanning = false;
                _isAiScannerActive = false;
              });
            },
            validator: (capture) {
              // Validate QR code format and provide feedback
              return capture.barcodes.isNotEmpty;
            },
            canPop: true,
            overlayBuilder: (context, constraints, overlay) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: [
                    // Scanner overlay
                    overlay,

                    // Custom scanning UI overlay
                    Positioned.fill(
                      child: Container(
                        decoration: ShapeDecoration(
                          shape: QrScannerOverlayShape(
                            borderColor: AppTheme.primaryLight,
                            borderRadius: 20,
                            borderLength: 40,
                            borderWidth: 8,
                            cutOutSize: MediaQuery.of(context).size.width * 0.7,
                          ),
                        ),
                      ),
                    ),

                    // Top bar with controls
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Container(
                          padding: EdgeInsets.all(2.h),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isScanning = false;
                                    _isAiScannerActive = false;
                                  });
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 6.w,
                                ),
                              ),
                              const Spacer(),
                              if (!kIsWeb)
                                IconButton(
                                  onPressed: _toggleFlashInScanner,
                                  icon: Icon(
                                    _isFlashOn
                                        ? Icons.flash_on
                                        : Icons.flash_off,
                                    color: _isFlashOn
                                        ? AppTheme.primaryLight
                                        : Colors.white,
                                    size: 6.w,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom instructions
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(179),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _currentLanguage == 'AR'
                                      ? 'ضع رمز الاستجابة السريعة داخل الإطار'
                                      : 'Position QR code within the frame',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Reset scanning state if user canceled
      if (result == null) {
        setState(() {
          _isScanning = false;
          _isAiScannerActive = false;
        });
      }
    } catch (e) {
      debugPrint('QR scanning error: $e');
      setState(() {
        _isScanning = false;
        _isAiScannerActive = false;
      });

      Fluttertoast.showToast(
        msg: _currentLanguage == 'AR'
            ? 'خطأ في مسح رمز الاستجابة السريعة'
            : 'QR scanning error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _toggleFlashInScanner() async {
    if (kIsWeb) return;

    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isCameraInitialized = false;
    });

    await _cameraController?.dispose();

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;

    _cameraController = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      await _applyEnhancedCameraSettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isFlashOn = false; // Reset flash when switching cameras
        });
      }
    } catch (e) {
      debugPrint('Camera flip error: $e');
      _showCameraErrorDialog();
    }
  }

  Future<void> _toggleFlash() async {
    if (kIsWeb) {
      Fluttertoast.showToast(
        msg: 'Flash not supported on web',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });

      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('Flash toggle error: $e');
      setState(() {
        _isFlashOn = false;
      });
      Fluttertoast.showToast(
        msg: 'Flash not available on this camera',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _showScanResult() {
    if (_scannedData == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScanResultBottomSheet(
        scannedData: _scannedData!,
        onClose: () => Navigator.of(context).pop(),
        onCopy: () {
          Clipboard.setData(ClipboardData(text: _scannedData!));
          Fluttertoast.showToast(
            msg: _currentLanguage == 'AR'
                ? 'تم نسخ النص إلى الحافظة'
                : 'Copied to clipboard',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
        onShare: () {
          // Implement share functionality
          Fluttertoast.showToast(
            msg: 'Share functionality would open here',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
        onOpenUrl: () {
          // Implement URL/email opening
          Fluttertoast.showToast(
            msg: 'Opening URL/Email...',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
      ),
    );
  }

  Future<void> _openGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        Navigator.pushNamed(context, '/gallery-scanner-screen');
      }
    } catch (e) {
      debugPrint('Gallery picker error: $e');
      Fluttertoast.showToast(
        msg: 'Failed to open gallery',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _openGenerator() {
    Navigator.pushNamed(context, '/qr-generator-screen');
  }

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
    _savePreferences();
  }

  void _toggleLanguage() {
    setState(() {
      _currentLanguage = _currentLanguage == 'EN' ? 'AR' : 'EN';
    });
    _savePreferences();
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_currentLanguage == 'AR'
            ? 'صلاحية الكاميرا مطلوبة'
            : 'Camera Permission Required'),
        content: Text(
          _currentLanguage == 'AR'
              ? 'يحتاج هذا التطبيق إلى الوصول للكاميرا لمسح رموز QR. يرجى منح إذن الكاميرا في الإعدادات.'
              : 'This app needs camera access to scan QR codes. Please grant camera permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_currentLanguage == 'AR' ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(
                _currentLanguage == 'AR' ? 'فتح الإعدادات' : 'Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showNoCameraDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            _currentLanguage == 'AR' ? 'لا توجد كاميرا' : 'No Camera Found'),
        content: Text(_currentLanguage == 'AR'
            ? 'لا توجد كاميرا متاحة على هذا الجهاز.'
            : 'No camera is available on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_currentLanguage == 'AR' ? 'موافق' : 'OK'),
          ),
        ],
      ),
    );
  }

  void _showCameraErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(_currentLanguage == 'AR' ? 'خطأ في الكاميرا' : 'Camera Error'),
        content: Text(_currentLanguage == 'AR'
            ? 'فشل في تهيئة الكاميرا. يرجى المحاولة مرة أخرى.'
            : 'Failed to initialize camera. Please try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_currentLanguage == 'AR' ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeCamera();
            },
            child: Text(_currentLanguage == 'AR' ? 'إعادة المحاولة' : 'Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Enhanced camera preview with better aspect ratio handling
          if (_hasPermission &&
              _isCameraInitialized &&
              _cameraController != null)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize!.height,
                  height: _cameraController!.value.previewSize!.width,
                  child: GestureDetector(
                    onTap: _startRealQrScanning,
                    onDoubleTap: () async {
                      // Double tap to focus at the center
                      try {
                        await _cameraController!
                            .setFocusPoint(const Offset(0.5, 0.5));
                        await _cameraController!
                            .setExposurePoint(const Offset(0.5, 0.5));
                      } catch (e) {
                        debugPrint('Focus adjustment error: $e');
                      }
                    },
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
            )
          else
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_hasPermission) ...[
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white54,
                          size: 15.w,
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          _currentLanguage == 'AR'
                              ? 'صلاحية الكاميرا مطلوبة'
                              : 'Camera Permission Required',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        ElevatedButton(
                          onPressed: _initializeCamera,
                          child: Text(_currentLanguage == 'AR'
                              ? 'منح الصلاحية'
                              : 'Grant Permission'),
                        ),
                      ] else ...[
                        CircularProgressIndicator(
                          color: AppTheme.primaryLight,
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          _currentLanguage == 'AR'
                              ? 'جاري تهيئة الكاميرا...'
                              : 'Initializing Camera...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          // Top controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopControlsWidget(
              isDarkTheme: _isDarkTheme,
              onThemeToggle: _toggleTheme,
              currentLanguage: _currentLanguage,
              onLanguageToggle: _toggleLanguage,
            ),
          ),

          // Enhanced scanning overlay with better visual feedback
          if (_hasPermission && _isCameraInitialized)
            Positioned.fill(
              child: ScanningOverlayWidget(
                isScanning: _isScanning,
                instructionText: _currentLanguage == 'AR'
                    ? 'اضغط على الشاشة لبدء المسح'
                    : 'Tap screen to start scanning',
              ),
            ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CameraControlsWidget(
              onFlipCamera: _flipCamera,
              onOpenGallery: _openGallery,
              onOpenGenerator: _openGenerator,
              isFlashOn: _isFlashOn,
              onToggleFlash: _toggleFlash,
            ),
          ),

          // Enhanced scan action button
          if (_hasPermission && _isCameraInitialized && !_isScanning)
            Positioned(
              bottom: 25.h,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _startRealQrScanning,
                      child: Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryLight.withAlpha(77),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 8.w,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(153),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentLanguage == 'AR'
                            ? 'اضغط لبدء المسح'
                            : 'Tap to scan QR code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Scanning indicator
          if (_isScanning)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(77),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.primaryLight,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _currentLanguage == 'AR'
                            ? 'جاري البحث عن رمز الاستجابة السريعة...'
                            : 'Scanning for QR code...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom QR Scanner Overlay Shape
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(
            rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final mBorderRadius = borderRadius > 0 ? borderRadius : 0;
    final mCutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(
      rect.left + (width - mCutOutSize) / 2 + borderOffset,
      rect.top + (height - mCutOutSize) / 2 + borderOffset,
      mCutOutSize - borderOffset * 2,
      mCutOutSize - borderOffset * 2,
    );

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(mBorderRadius.toDouble()),
        ),
        boxPaint..blendMode = BlendMode.clear,
      )
      ..restore();

    // Draw corner borders
    final path = Path()
      ..moveTo(cutOutRect.left - borderOffset, cutOutRect.top + borderLength)
      ..quadraticBezierTo(
          cutOutRect.left - borderOffset,
          cutOutRect.top - borderOffset,
          cutOutRect.left + borderLength,
          cutOutRect.top - borderOffset)
      ..moveTo(cutOutRect.right - borderLength, cutOutRect.top - borderOffset)
      ..quadraticBezierTo(
          cutOutRect.right + borderOffset,
          cutOutRect.top - borderOffset,
          cutOutRect.right + borderOffset,
          cutOutRect.top + borderLength)
      ..moveTo(
          cutOutRect.right + borderOffset, cutOutRect.bottom - borderLength)
      ..quadraticBezierTo(
          cutOutRect.right + borderOffset,
          cutOutRect.bottom + borderOffset,
          cutOutRect.right - borderLength,
          cutOutRect.bottom + borderOffset)
      ..moveTo(cutOutRect.left + borderLength, cutOutRect.bottom + borderOffset)
      ..quadraticBezierTo(
          cutOutRect.left - borderOffset,
          cutOutRect.bottom + borderOffset,
          cutOutRect.left - borderOffset,
          cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}