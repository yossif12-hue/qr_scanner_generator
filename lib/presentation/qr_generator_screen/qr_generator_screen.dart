import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart'; // Add this import for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/content_type_selector_widget.dart';
import './widgets/input_fields_widget.dart';
import './widgets/qr_preview_widget.dart';
import './widgets/size_slider_widget.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  String _selectedContentType = 'text';
  double _qrSize = 512.0;

  // Controllers for different input types
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  // Error states
  String? _textError;
  String? _urlError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_validateInput);
    _urlController.addListener(_validateInput);
    _emailController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _textError = null;
      _urlError = null;
      _emailError = null;

      switch (_selectedContentType) {
        case 'text':
          if (_textController.text.trim().isEmpty) {
            _textError = 'Please enter some text';
          }
          break;
        case 'url':
          final url = _urlController.text.trim();
          if (url.isEmpty) {
            _urlError = 'Please enter a URL';
          } else if (!_isValidUrl(url)) {
            _urlError = 'Please enter a valid URL (e.g., https://example.com)';
          }
          break;
        case 'email':
          final email = _emailController.text.trim();
          if (email.isEmpty) {
            _emailError = 'Please enter an email address';
          } else if (!_isValidEmail(email)) {
            _emailError = 'Please enter a valid email address';
          }
          break;
      }
    });
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _generateQrData() {
    switch (_selectedContentType) {
      case 'text':
        return _textController.text.trim();
      case 'url':
        return _urlController.text.trim();
      case 'email':
        final email = _emailController.text.trim();
        final subject = _subjectController.text.trim();
        final body = _bodyController.text.trim();

        String emailData = 'mailto:$email';
        List<String> params = [];

        if (subject.isNotEmpty) {
          params.add('subject=${Uri.encodeComponent(subject)}');
        }
        if (body.isNotEmpty) {
          params.add('body=${Uri.encodeComponent(body)}');
        }

        if (params.isNotEmpty) {
          emailData += '?${params.join('&')}';
        }

        return emailData;
      default:
        return '';
    }
  }

  bool _canGenerateQr() {
    final data = _generateQrData();
    return data.isNotEmpty &&
        _textError == null &&
        _urlError == null &&
        _emailError == null;
  }

  Future<Uint8List> _generateQrImage() async {
    final qrValidationResult = QrValidator.validate(
      data: _generateQrData(),
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );

    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCode,
        color: Colors.black,
        emptyColor: Colors.white,
        gapless: false,
      );

      final picData = await painter.toImageData(_qrSize);
      return picData!.buffer.asUint8List();
    } else {
      throw Exception('Failed to generate QR code');
    }
  }

  Future<void> _downloadQrCode() async {
    if (!_canGenerateQr()) return;

    try {
      final imageBytes = await _generateQrImage();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'qr_code_$timestamp.png';

      if (kIsWeb) {
        // Web download
        final blob = html.Blob([imageBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);

        Fluttertoast.showToast(
          msg: "QR code downloaded successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        // Mobile download
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(imageBytes);

        Fluttertoast.showToast(
          msg: "QR code saved to: ${file.path}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to download QR code",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _shareQrCode() async {
    if (!_canGenerateQr()) return;

    try {
      final data = _generateQrData();
      await Clipboard.setData(ClipboardData(text: data));

      Fluttertoast.showToast(
        msg: "QR code data copied to clipboard",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to copy QR code data",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _clearAllFields() {
    setState(() {
      _textController.clear();
      _urlController.clear();
      _emailController.clear();
      _subjectController.clear();
      _bodyController.clear();
      _textError = null;
      _urlError = null;
      _emailError = null;
      _selectedContentType = 'text';
      _qrSize = 512.0;
    });

    Fluttertoast.showToast(
      msg: "All fields cleared",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onContentTypeChanged(String type) {
    setState(() {
      _selectedContentType = type;
      _textError = null;
      _urlError = null;
      _emailError = null;
    });
    _validateInput();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'QR Generator',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Theme.of(context).appBarTheme.iconTheme?.color ??
                Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: Theme.of(context).appBarTheme.iconTheme?.color ??
                  Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () => Navigator.pushNamed(context, '/settings-screen'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Text(
                'Create Custom QR Codes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Generate QR codes for text, URLs, and email addresses with customizable size options.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              SizedBox(height: 3.h),

              // Content type selector
              ContentTypeSelectorWidget(
                selectedType: _selectedContentType,
                onTypeChanged: _onContentTypeChanged,
              ),
              SizedBox(height: 3.h),

              // Input fields
              Card(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: InputFieldsWidget(
                    contentType: _selectedContentType,
                    textController: _textController,
                    urlController: _urlController,
                    emailController: _emailController,
                    subjectController: _subjectController,
                    bodyController: _bodyController,
                    textError: _textError,
                    urlError: _urlError,
                    emailError: _emailError,
                  ),
                ),
              ),
              SizedBox(height: 3.h),

              // QR code preview
              QrPreviewWidget(
                data: _canGenerateQr() ? _generateQrData() : '',
                size: _qrSize,
              ),
              SizedBox(height: 3.h),

              // Size slider
              SizeSliderWidget(
                currentSize: _qrSize,
                onSizeChanged: (value) {
                  setState(() {
                    _qrSize = value;
                  });
                },
              ),
              SizedBox(height: 4.h),

              // Action buttons
              ActionButtonsWidget(
                canGenerate: _canGenerateQr(),
                onDownload: _downloadQrCode,
                onShare: _shareQrCode,
                onClear: _clearAllFields,
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}