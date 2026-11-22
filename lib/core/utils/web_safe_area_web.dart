import 'package:web/web.dart' as web;

/// Web implementation: reads real CSS env(safe-area-inset-*) via the DOM detector element
double getWebSafeAreaBottom() {
  try {
    final el = web.document.getElementById('safe-area-detector');
    if (el != null) {
      final style = web.window.getComputedStyle(el);
      final pb = style.paddingBottom;
      if (pb.isNotEmpty) {
        return double.tryParse(pb.replaceAll('px', '').trim()) ?? 0.0;
      }
    }
  } catch (_) {}
  return 0.0;
}

double getWebSafeAreaTop() {
  try {
    final el = web.document.getElementById('safe-area-detector');
    if (el != null) {
      final style = web.window.getComputedStyle(el);
      final pt = style.paddingTop;
      if (pt.isNotEmpty) {
        return double.tryParse(pt.replaceAll('px', '').trim()) ?? 0.0;
      }
    }
  } catch (_) {}
  return 0.0;
}
