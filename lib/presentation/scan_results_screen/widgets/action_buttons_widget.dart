import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final String content;
  final String contentType;
  final VoidCallback onShare;
  final VoidCallback onSaveToHistory;

  const ActionButtonsWidget({
    Key? key,
    required this.content,
    required this.contentType,
    required this.onShare,
    required this.onSaveToHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          if (contentType == 'url' || contentType == 'email')
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 2.h),
              child: ElevatedButton.icon(
                onPressed: () => _handlePrimaryAction(),
                icon: CustomIconWidget(
                  iconName: contentType == 'url' ? 'open_in_browser' : 'mail',
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  contentType == 'url' ? 'Open Link' : 'Compose Email',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: contentType == 'url'
                      ? AppTheme.primaryLight
                      : AppTheme.success,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onShare,
                  icon: CustomIconWidget(
                    iconName: 'share',
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  label: Text(
                    'Share',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSaveToHistory,
                  icon: CustomIconWidget(
                    iconName: 'bookmark_add',
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  label: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handlePrimaryAction() async {
    try {
      if (contentType == 'url') {
        final Uri url = Uri.parse(content);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } else if (contentType == 'email') {
        final Uri emailUri = Uri(
          scheme: 'mailto',
          path: content,
        );
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }
}
