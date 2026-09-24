import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/platform_workaround/sqlite_workaround.dart';
import 'core/theme/app_theme_style.dart';
import 'core/theme/lumi_theme.dart';
import 'core/theme/vault_theme.dart';
import 'core/services/web_theme_helper/web_theme_helper.dart';
import 'core/widgets/main_shell.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for phones
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Catch synchronous Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  // Catch asynchronous errors in the root isolate so the app does not crash instantly
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Global unhandled error: $error\n$stack');
    return true; // Handled
  };

  // Workaround for older Android versions to load sqlite3 cleanly (no-op on Web)
  await applySqliteWorkaround();

  runApp(
    const ProviderScope(
      child: MyFinanceApp(),
    ),
  );
}

class MyFinanceApp extends StatefulWidget {
  const MyFinanceApp({super.key});

  @override
  State<MyFinanceApp> createState() => _MyFinanceAppState();
}

class _MyFinanceAppState extends State<MyFinanceApp> {
  Locale _locale = const Locale('th');
  ThemeMode _themeMode = ThemeMode.system;
  AppThemeStyle _themeStyle = AppThemeStyle.vault;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language');
    final themeStr = prefs.getString('app_theme_mode');
    final styleStr = prefs.getString('app_theme_style');

    if (mounted) {
      setState(() {
        if (lang != null && (lang == 'en' || lang == 'th')) {
          _locale = Locale(lang);
        }
        if (themeStr != null) {
          if (themeStr == 'light') {
            _themeMode = ThemeMode.light;
          } else if (themeStr == 'dark') {
            _themeMode = ThemeMode.dark;
          } else {
            _themeMode = ThemeMode.system;
          }
        }
        if (styleStr == 'lumi') {
          _themeStyle = AppThemeStyle.lumi;
        } else {
          _themeStyle = AppThemeStyle.vault;
        }
      });
    }
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('app_language', locale.languageCode);
    });
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('app_theme_mode', mode.name);
    });
  }

  void _setThemeStyle(AppThemeStyle style) {
    setState(() {
      _themeStyle = style;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('app_theme_style', style.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLumi = _themeStyle == AppThemeStyle.lumi;

    return MaterialApp(
      title: 'OURS',
      debugShowCheckedModeBanner: false,
      theme: isLumi ? LumiTheme.lightTheme : VaultTheme.lightTheme,
      darkTheme: isLumi ? LumiTheme.darkTheme : VaultTheme.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('th'),
        Locale('en'),
      ],
      home: MainShell(
        currentLocale: _locale,
        onLocaleChanged: _setLocale,
        currentThemeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
        currentThemeStyle: _themeStyle,
        onThemeStyleChanged: _setThemeStyle,
      ),
      builder: (context, child) {
        final theme = Theme.of(context);
        updateSystemThemeColor(
          theme.scaffoldBackgroundColor,
          isDark: theme.brightness == Brightness.dark,
        );
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

