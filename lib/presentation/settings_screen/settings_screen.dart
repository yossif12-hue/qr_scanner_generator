import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/about_section_widget.dart';
import './widgets/language_setting_widget.dart';
import './widgets/qr_defaults_widget.dart';
import './widgets/reset_defaults_widget.dart';
import './widgets/theme_setting_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _currentLanguage = 'en';
  double _qrSize = 256.0;
  String _defaultContentType = 'text';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isDarkMode = prefs.getBool('isDarkMode') ?? false;
        _currentLanguage = prefs.getString('language') ?? 'en';
        _qrSize = prefs.getDouble('qrSize') ?? 256.0;
        _defaultContentType = prefs.getString('defaultContentType') ?? 'text';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setString('language', _currentLanguage);
      await prefs.setDouble('qrSize', _qrSize);
      await prefs.setString('defaultContentType', _defaultContentType);
    } catch (e) {
      // Handle error silently
    }
  }

  void _onThemeChanged(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
    _saveSettings();

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDark ? 'Dark theme enabled' : 'Light theme enabled',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onLanguageChanged(String language) {
    setState(() {
      _currentLanguage = language;
    });
    _saveSettings();

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          language == 'ar'
              ? 'تم تغيير اللغة إلى العربية'
              : 'Language changed to English',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onQrSizeChanged(double size) {
    setState(() {
      _qrSize = size;
    });
    _saveSettings();
  }

  void _onContentTypeChanged(String contentType) {
    setState(() {
      _defaultContentType = contentType;
    });
    _saveSettings();
  }

  void _onResetDefaults() {
    setState(() {
      _isDarkMode = false;
      _currentLanguage = 'en';
      _qrSize = 256.0;
      _defaultContentType = 'text';
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _currentLanguage == 'ar' ? 'الإعدادات' : 'Settings',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: _currentLanguage == 'ar' ? 'arrow_forward' : 'arrow_back',
            color: Theme.of(context).appBarTheme.foregroundColor ??
                Theme.of(context).colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : Directionality(
              textDirection: _currentLanguage == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),

                    // Header Section
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1),
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomIconWidget(
                              iconName: 'settings',
                              color: Theme.of(context).colorScheme.primary,
                              size: 8.w,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentLanguage == 'ar'
                                      ? 'تخصيص التطبيق'
                                      : 'Customize Your App',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  _currentLanguage == 'ar'
                                      ? 'قم بتخصيص الإعدادات حسب تفضيلاتك'
                                      : 'Personalize settings to match your preferences',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Theme Settings
                    ThemeSettingWidget(
                      isDarkMode: _isDarkMode,
                      onThemeChanged: _onThemeChanged,
                    ),

                    // Language Settings
                    LanguageSettingWidget(
                      currentLanguage: _currentLanguage,
                      onLanguageChanged: _onLanguageChanged,
                    ),

                    // QR Generator Defaults
                    QrDefaultsWidget(
                      qrSize: _qrSize,
                      defaultContentType: _defaultContentType,
                      onSizeChanged: _onQrSizeChanged,
                      onContentTypeChanged: _onContentTypeChanged,
                    ),

                    // About Section
                    AboutSectionWidget(),

                    // Reset Defaults
                    ResetDefaultsWidget(
                      onResetDefaults: _onResetDefaults,
                    ),

                    SizedBox(height: 4.h),

                    // Footer
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.all(3.w),
                      child: Column(
                        children: [
                          Divider(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            _currentLanguage == 'ar'
                                ? 'تم التحديث في 1 سبتمبر 2025'
                                : 'Last updated: September 1, 2025',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
    );
  }
}
