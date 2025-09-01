import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TopControlsWidget extends StatelessWidget {
  final bool isDarkTheme;
  final VoidCallback? onThemeToggle;
  final String currentLanguage;
  final VoidCallback? onLanguageToggle;

  const TopControlsWidget({
    Key? key,
    this.isDarkTheme = false,
    this.onThemeToggle,
    this.currentLanguage = 'EN',
    this.onLanguageToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 2.h,
        left: 6.w,
        right: 6.w,
        bottom: 2.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildControlButton(
            onTap: onThemeToggle,
            icon: isDarkTheme ? 'light_mode' : 'dark_mode',
            tooltip:
                isDarkTheme ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
          Text(
            'QR Scanner',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          _buildLanguageButton(),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onTap,
    required String icon,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: Colors.white,
              size: 6.w,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton() {
    return Tooltip(
      message:
          currentLanguage == 'EN' ? 'Switch to Arabic' : 'Switch to English',
      child: GestureDetector(
        onTap: onLanguageToggle,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'language',
                color: Colors.white,
                size: 5.w,
              ),
              SizedBox(width: 1.w),
              Text(
                currentLanguage,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
