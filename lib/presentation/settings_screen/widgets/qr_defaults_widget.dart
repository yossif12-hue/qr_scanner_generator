import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class QrDefaultsWidget extends StatelessWidget {
  final double qrSize;
  final String defaultContentType;
  final Function(double) onSizeChanged;
  final Function(String) onContentTypeChanged;

  const QrDefaultsWidget({
    Key? key,
    required this.qrSize,
    required this.defaultContentType,
    required this.onSizeChanged,
    required this.onContentTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> contentTypes = [
      {'value': 'text', 'label': 'Text', 'icon': 'text_fields'},
      {'value': 'url', 'label': 'URL', 'icon': 'link'},
      {'value': 'email', 'label': 'Email', 'icon': 'email'},
    ];

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'qr_code',
                  color: Theme.of(context).colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'QR Generator Defaults',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // QR Size Slider
            Text(
              'Default QR Size',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Text(
                  '128px',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Expanded(
                  child: Slider(
                    value: qrSize,
                    min: 128,
                    max: 1024,
                    divisions: 7,
                    label: '${qrSize.round()}px',
                    onChanged: onSizeChanged,
                  ),
                ),
                Text(
                  '1024px',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Text(
              'Current: ${qrSize.round()}px',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),

            SizedBox(height: 3.h),

            // Content Type Selection
            Text(
              'Default Content Type',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(height: 1.h),

            ...contentTypes
                .map((type) => Container(
                      margin: EdgeInsets.only(bottom: 1.h),
                      child: RadioListTile<String>(
                        value: type['value'],
                        groupValue: defaultContentType,
                        onChanged: (value) =>
                            value != null ? onContentTypeChanged(value) : null,
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: type['icon'],
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 5.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              type['label'],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
