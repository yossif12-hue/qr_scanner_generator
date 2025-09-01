import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ContentDisplayWidget extends StatelessWidget {
  final String content;
  final String contentType;
  final VoidCallback onCopy;

  const ContentDisplayWidget({
    Key? key,
    required this.content,
    required this.contentType,
    required this.onCopy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildContentTypeIcon(),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  _getContentTypeLabel(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: SelectableText(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    height: 1.4,
                  ),
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: content));
                onCopy();
                HapticFeedback.lightImpact();
              },
              icon: CustomIconWidget(
                iconName: 'content_copy',
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                'Copy to Clipboard',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTypeIcon() {
    String iconName;
    Color iconColor;

    switch (contentType) {
      case 'url':
        iconName = 'link';
        iconColor = AppTheme.primaryLight;
        break;
      case 'email':
        iconName = 'email';
        iconColor = AppTheme.success;
        break;
      default:
        iconName = 'text_fields';
        iconColor = AppTheme.textSecondary;
    }

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomIconWidget(
        iconName: iconName,
        color: iconColor,
        size: 24,
      ),
    );
  }

  String _getContentTypeLabel() {
    switch (contentType) {
      case 'url':
        return 'Website Link';
      case 'email':
        return 'Email Address';
      default:
        return 'Text Content';
    }
  }
}
