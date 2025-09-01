import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CameraControlsWidget extends StatelessWidget {
  final VoidCallback? onFlipCamera;
  final VoidCallback? onOpenGallery;
  final VoidCallback? onOpenGenerator;
  final bool isFlashOn;
  final VoidCallback? onToggleFlash;

  const CameraControlsWidget({
    Key? key,
    this.onFlipCamera,
    this.onOpenGallery,
    this.onOpenGenerator,
    this.isFlashOn = false,
    this.onToggleFlash,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            onTap: onToggleFlash,
            icon: isFlashOn ? 'flash_on' : 'flash_off',
            label: isFlashOn ? 'Flash On' : 'Flash Off',
          ),
          _buildControlButton(
            onTap: onFlipCamera,
            icon: 'flip_camera_android',
            label: 'Flip Camera',
          ),
          _buildControlButton(
            onTap: onOpenGallery,
            icon: 'photo_library',
            label: 'Gallery',
          ),
          _buildControlButton(
            onTap: onOpenGenerator,
            icon: 'qr_code',
            label: 'Generate',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onTap,
    required String icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 15.w,
        height: 15.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: Colors.white,
              size: 6.w,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
