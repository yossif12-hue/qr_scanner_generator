import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ActionButtonsWidget extends StatelessWidget {
  final bool canGenerate;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onClear;

  const ActionButtonsWidget({
    super.key,
    required this.canGenerate,
    required this.onDownload,
    required this.onShare,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canGenerate ? onDownload : null,
                icon: CustomIconWidget(
                  iconName: 'download',
                  color: canGenerate
                      ? Colors.white
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.38),
                  size: 20,
                ),
                label: Text('Download'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canGenerate ? onShare : null,
                icon: CustomIconWidget(
                  iconName: 'share',
                  color: canGenerate
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.38),
                  size: 20,
                ),
                label: Text('Share'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: onClear,
            icon: CustomIconWidget(
              iconName: 'clear',
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
            label: Text(
              'Clear All',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
