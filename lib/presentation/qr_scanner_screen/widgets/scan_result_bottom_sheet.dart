import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScanResultBottomSheet extends StatelessWidget {
  final String scannedData;
  final VoidCallback? onClose;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onOpenUrl;

  const ScanResultBottomSheet({
    Key? key,
    required this.scannedData,
    this.onClose,
    this.onCopy,
    this.onShare,
    this.onOpenUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isUrl = _isValidUrl(scannedData);
    final bool isEmail = _isValidEmail(scannedData);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: 70.h,
        minHeight: 30.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scan Result',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),

          // Content type indicator
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color:
                  _getContentTypeColor(isUrl, isEmail).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    _getContentTypeColor(isUrl, isEmail).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: _getContentTypeIcon(isUrl, isEmail),
                  color: _getContentTypeColor(isUrl, isEmail),
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  _getContentTypeLabel(isUrl, isEmail),
                  style: TextStyle(
                    color: _getContentTypeColor(isUrl, isEmail),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Scanned data display
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  scannedData,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        height: 1.5,
                      ),
                ),
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Action buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: scannedData));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          if (onCopy != null) onCopy!();
                        },
                        icon: 'content_copy',
                        label: 'Copy',
                        color: AppTheme.primaryLight,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        onTap: onShare,
                        icon: 'share',
                        label: 'Share',
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ),
                if (isUrl || isEmail) ...[
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionButton(
                      context: context,
                      onTap: onOpenUrl,
                      icon: isUrl ? 'open_in_new' : 'email',
                      label: isUrl ? 'Open URL' : 'Send Email',
                      color: AppTheme.primaryLight,
                      isPrimary: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required VoidCallback? onTap,
    required String icon,
    required String label,
    required Color color,
    bool isPrimary = false,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? color : color.withValues(alpha: 0.1),
        foregroundColor: isPrimary ? Colors.white : color,
        elevation: isPrimary ? 2 : 0,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side:
              isPrimary ? BorderSide.none : BorderSide(color: color, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: isPrimary ? Colors.white : color,
            size: 5.w,
          ),
          SizedBox(width: 2.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidUrl(String text) {
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(text);
  }

  bool _isValidEmail(String text) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(text);
  }

  Color _getContentTypeColor(bool isUrl, bool isEmail) {
    if (isUrl) return AppTheme.primaryLight;
    if (isEmail) return AppTheme.success;
    return AppTheme.textSecondary;
  }

  String _getContentTypeIcon(bool isUrl, bool isEmail) {
    if (isUrl) return 'link';
    if (isEmail) return 'email';
    return 'text_fields';
  }

  String _getContentTypeLabel(bool isUrl, bool isEmail) {
    if (isUrl) return 'Website URL';
    if (isEmail) return 'Email Address';
    return 'Text Content';
  }
}
