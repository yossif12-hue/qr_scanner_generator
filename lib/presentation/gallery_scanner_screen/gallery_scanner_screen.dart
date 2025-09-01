import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class GalleryScannerScreen extends StatefulWidget {
  const GalleryScannerScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScannerScreen> createState() => _GalleryScannerScreenState();
}

class _GalleryScannerScreenState extends State<GalleryScannerScreen>
    with TickerProviderStateMixin {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessing = false;
  bool _isDarkTheme = false;
  List<XFile> _recentImages = [];
  bool _isLoadingImages = true;
  String? _errorMessage;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Mock recent images data
  final List<Map<String, dynamic>> _mockRecentImages = [
{ "id": 1,
"url": "https://images.pexels.com/photos/4386321/pexels-photo-4386321.jpeg?auto=compress&cs=tinysrgb&w=800",
"timestamp": DateTime.now().subtract(const Duration(hours: 2)),
"hasQR": true,
},
{ "id": 2,
"url": "https://images.pixabay.com/photo/2020/06/30/10/23/qr-code-5355459_960_720.png",
"timestamp": DateTime.now().subtract(const Duration(days: 1)),
"hasQR": true,
},
{ "id": 3,
"url": "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
"timestamp": DateTime.now().subtract(const Duration(days: 2)),
"hasQR": false,
},
{ "id": 4,
"url": "https://images.pexels.com/photos/4386433/pexels-photo-4386433.jpeg?auto=compress&cs=tinysrgb&w=800",
"timestamp": DateTime.now().subtract(const Duration(days: 3)),
"hasQR": true,
},
{ "id": 5,
"url": "https://images.pixabay.com/photo/2018/05/08/21/29/paypal-3384015_960_720.png",
"timestamp": DateTime.now().subtract(const Duration(days: 4)),
"hasQR": true,
},
{ "id": 6,
"url": "https://images.unsplash.com/photo-1434626881859-194d67b2b86f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
"timestamp": DateTime.now().subtract(const Duration(days: 5)),
"hasQR": false,
},
];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _initializeScreen();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    await _requestPermissions();
    await _loadRecentImages();
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;
    
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          setState(() {
            _errorMessage = "Storage permission is required to access images";
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Permission error occurred";
      });
    }
  }

  Future<void> _loadRecentImages() async {
    setState(() {
      _isLoadingImages = true;
      _errorMessage = null;
    });

    try {
      // Simulate loading recent images
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _isLoadingImages = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingImages = false;
        _errorMessage = "Failed to load recent images";
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        await _processSelectedImage(image);
      }
    } catch (e) {
      _showErrorSnackBar("Failed to select image from gallery");
    }
  }

  Future<void> _processSelectedImage(XFile image) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Simulate QR code detection processing
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock QR detection result
      final hasQRCode = DateTime.now().millisecond % 3 != 0; // 66% chance of finding QR
      
      if (hasQRCode) {
        // Navigate to scan results with mock data
        Navigator.pushNamed(
          context,
          '/scan-results-screen',
          arguments: {
            'result': 'https://example.com/scanned-from-gallery',
            'timestamp': DateTime.now(),
            'source': 'gallery',
          },
        );
      } else {
        setState(() {
          _errorMessage = "No QR code found in the selected image";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to process the selected image";
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processRecentImage(Map<String, dynamic> imageData) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Simulate processing
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final hasQR = imageData['hasQR'] as bool;
      
      if (hasQR) {
        // Navigate to scan results
        Navigator.pushNamed(
          context,
          '/scan-results-screen',
          arguments: {
            'result': 'https://example.com/qr-from-recent-image-${imageData['id']}',
            'timestamp': DateTime.now(),
            'source': 'gallery',
          },
        );
      } else {
        setState(() {
          _errorMessage = "No QR code found in this image";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to process the image";
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkTheme ? AppTheme.darkTheme : AppTheme.lightTheme;
    
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(theme),
                Expanded(
                  child: _isProcessing
                      ? _buildProcessingOverlay(theme)
                      : _buildMainContent(theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              'Select Image',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: _toggleTheme,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: CustomIconWidget(
                iconName: _isDarkTheme ? 'light_mode' : 'dark_mode',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGalleryButton(theme),
          SizedBox(height: 3.h),
          _buildSearchBar(theme),
          SizedBox(height: 3.h),
          _buildRecentImagesSection(theme),
          if (_errorMessage != null) ...[
            SizedBox(height: 2.h),
            _buildErrorMessage(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildGalleryButton(ThemeData theme) {
    return GestureDetector(
      onTap: _pickImageFromGallery,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(3.w),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'photo_library',
              color: Colors.white,
              size: 7.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Browse Gallery',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search images...',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              color: theme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 2.h,
          ),
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildRecentImagesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'history',
              color: theme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Recent Images',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        _isLoadingImages
            ? _buildLoadingGrid(theme)
            : _buildImageGrid(theme),
      ],
    );
  }

  Widget _buildLoadingGrid(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
        childAspectRatio: 1.0,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageGrid(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
        childAspectRatio: 1.0,
      ),
      itemCount: _mockRecentImages.length,
      itemBuilder: (context, index) {
        final imageData = _mockRecentImages[index];
        return _buildImageThumbnail(theme, imageData);
      },
    );
  }

  Widget _buildImageThumbnail(ThemeData theme, Map<String, dynamic> imageData) {
    return GestureDetector(
      onTap: () => _processRecentImage(imageData),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.w),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2.w),
          child: Stack(
            children: [
              CustomImageWidget(
                imageUrl: imageData['url'] as String,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              if (imageData['hasQR'] as bool)
                Positioned(
                  top: 1.w,
                  right: 1.w,
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                    child: CustomIconWidget(
                      iconName: 'qr_code',
                      color: Colors.white,
                      size: 3.w,
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 1.w,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    _formatTimestamp(imageData['timestamp'] as DateTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 8.sp,
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

  Widget _buildErrorMessage(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'error_outline',
            color: AppTheme.error,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.error,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _errorMessage = null;
              });
              _loadRecentImages();
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(1.w),
              ),
              child: CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.error,
                size: 4.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 15.w,
                height: 15.w,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Scanning Image...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Looking for QR codes in the selected image',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}