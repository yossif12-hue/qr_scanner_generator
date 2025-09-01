import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ResetDefaultsWidget extends StatelessWidget {
  final VoidCallback onResetDefaults;

  const ResetDefaultsWidget({
    Key? key,
    required this.onResetDefaults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: OutlinedButton(
        onPressed: () => _showResetConfirmationDialog(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.0,
          ),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'restore',
              color: Theme.of(context).colorScheme.error,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Reset to Defaults',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: Theme.of(context).colorScheme.error,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Reset Settings',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onResetDefaults();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Settings reset to defaults'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}
