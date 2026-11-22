import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Web implementation: reads real CSS env(safe-area-inset-*) via the DOM detector element,
/// with automatic iOS device fallback so bezel-less iPhones never receive 0 padding.
double getWebSafeAreaBottom() {
  try {
    final el = web.document.getElementById('safe-area-detector');
    if (el != null) {
      final style = web.window.getComputedStyle(el);
      final pb = style.paddingBottom;
      if (pb.isNotEmpty) {
        final parsed = double.tryParse(pb.replaceAll('px', '').trim());
        if (parsed != null && parsed > 0) {
          return parsed;
        }
      }
    }
  } catch (_) {}

  // Fallback for iOS web browsers / PWAs where env(safe-area-inset-bottom) might lag or report 0
  if (kIsWeb && _isIosWeb()) {
    return 34.0;
  }

  return 0.0;
}

double getWebSafeAreaTop() {
  try {
    final el = web.document.getElementById('safe-area-detector');
    if (el != null) {
      final style = web.window.getComputedStyle(el);
      final pt = style.paddingTop;
      if (pt.isNotEmpty) {
        final parsed = double.tryParse(pt.replaceAll('px', '').trim());
        if (parsed != null && parsed > 0) {
          return parsed;
        }
      }
    }
  } catch (_) {}

  // Fallback for iOS web browsers / PWAs with notch or Dynamic Island
  if (kIsWeb && _isIosWeb()) {
    return 47.0;
  }

  return 0.0;
}

bool _isIosWeb() {
  try {
    final ua = web.window.navigator.userAgent.toLowerCase();
    final isIosDevice = ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod');
    final isMacTouch = ua.contains('macintosh') && (web.window.navigator.maxTouchPoints > 1);
    return isIosDevice || isMacTouch;
  } catch (_) {
    return false;
  }
}
