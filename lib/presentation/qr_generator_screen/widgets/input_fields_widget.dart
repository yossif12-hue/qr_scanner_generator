import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class InputFieldsWidget extends StatelessWidget {
  final String contentType;
  final TextEditingController textController;
  final TextEditingController urlController;
  final TextEditingController emailController;
  final TextEditingController subjectController;
  final TextEditingController bodyController;
  final String? textError;
  final String? urlError;
  final String? emailError;

  const InputFieldsWidget({
    super.key,
    required this.contentType,
    required this.textController,
    required this.urlController,
    required this.emailController,
    required this.subjectController,
    required this.bodyController,
    this.textError,
    this.urlError,
    this.emailError,
  });

  @override
  Widget build(BuildContext context) {
    switch (contentType) {
      case 'text':
        return _buildTextInput(context);
      case 'url':
        return _buildUrlInput(context);
      case 'email':
        return _buildEmailInputs(context);
      default:
        return _buildTextInput(context);
    }
  }

  Widget _buildTextInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Text',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: textController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Type your text here...',
            errorText: textError,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'text_fields',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }

  Widget _buildUrlInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter URL',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: urlController,
          decoration: InputDecoration(
            hintText: 'https://example.com',
            errorText: urlError,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'link',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildEmailInputs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Details',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Recipient Email',
            hintText: 'recipient@example.com',
            errorText: emailError,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'email',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: subjectController,
          decoration: InputDecoration(
            labelText: 'Subject (Optional)',
            hintText: 'Email subject',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'subject',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: bodyController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Message (Optional)',
            hintText: 'Email message body',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'message',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}
