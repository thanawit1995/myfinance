// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/services.dart';

void updateSystemThemeColor(Color color, {required bool isDark}) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: color,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: color,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ),
  );

  final r = ((color.r * 255).round() & 0xff).toRadixString(16).padLeft(2, '0');
  final g = ((color.g * 255).round() & 0xff).toRadixString(16).padLeft(2, '0');
  final b = ((color.b * 255).round() & 0xff).toRadixString(16).padLeft(2, '0');
  final hex = '#$r$g$b';

  try {
    final existingMetas = html.document.head?.querySelectorAll('meta[name="theme-color"]');
    if (existingMetas != null && existingMetas.isNotEmpty) {
      for (final m in existingMetas) {
        m.remove();
      }
    }
    final meta = html.MetaElement()
      ..name = 'theme-color'
      ..content = hex;
    html.document.head?.append(meta);

    if (html.document.body != null) {
      html.document.body!.style.backgroundColor = hex;
    }
  } catch (_) {}
}
