import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/image_cropper_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _customMascotPathPrefKey = 'custom_lumi_mascot_path';
const String _customMascotBase64PrefKey = 'custom_lumi_mascot_base64';

final customMascotProvider = StateNotifierProvider<CustomMascotNotifier, String?>((ref) {
  return CustomMascotNotifier();
});

class CustomMascotNotifier extends StateNotifier<String?> {
  CustomMascotNotifier() : super(null) {
    _loadMascot();
  }

  Future<void> _loadMascot() async {
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      state = prefs.getString(_customMascotBase64PrefKey);
    } else {
      final path = prefs.getString(_customMascotPathPrefKey);
      if (path != null && File(path).existsSync()) {
        state = path;
      } else {
        // Fallback to base64 if available
        state = prefs.getString(_customMascotBase64PrefKey);
      }
    }
  }

  Future<bool> pickAndSaveMascot(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return false;

      final file = result.files.first;
      final rawBytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (rawBytes == null) return false;

      if (!context.mounted) return false;
      final isThai = Localizations.localeOf(context).languageCode == 'th';
      // Crop with mascot character aspect ratio (~0.9)
      final croppedBytes = await ImageCropperDialog.show(
        context,
        imageBytes: rawBytes,
        aspectRatio: 0.9,
        title: isThai ? 'ครอบตัดรูปมาสคอต Lumi' : 'Crop Lumi Mascot',
      );

      if (croppedBytes == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final b64 = base64Encode(croppedBytes);
      await prefs.setString(_customMascotBase64PrefKey, b64);
      state = b64;
      return true;
    } catch (_) {}
    return false;
  }

  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customMascotPathPrefKey);
    await prefs.remove(_customMascotBase64PrefKey);
    state = null;
  }
}

const String customCardBgBase64PrefKey = 'custom_lumi_card_bg_base64';

final customCardBgProvider = StateNotifierProvider<CustomCardBgNotifier, String?>((ref) {
  return CustomCardBgNotifier();
});

class CustomCardBgNotifier extends StateNotifier<String?> {
  CustomCardBgNotifier() : super(null) {
    _loadBg();
  }

  Future<void> _loadBg() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(customCardBgBase64PrefKey);
  }

  Future<bool> pickAndSaveBackground(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return false;

      final file = result.files.first;
      final rawBytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (rawBytes == null) return false;

      if (!context.mounted) return false;
      final isThai = Localizations.localeOf(context).languageCode == 'th';
      // Crop with Budget Hero Card aspect ratio (~16:9 or ~2.1:1)
      final croppedBytes = await ImageCropperDialog.show(
        context,
        imageBytes: rawBytes,
        aspectRatio: 2.1,
        title: isThai ? 'ครอบตัดรูปพื้นหลังการ์ด Lumi' : 'Crop Lumi Card Background',
      );

      if (croppedBytes == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final b64 = base64Encode(croppedBytes);
      await prefs.setString(customCardBgBase64PrefKey, b64);
      state = b64;
      return true;
    } catch (_) {}
    return false;
  }

  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(customCardBgBase64PrefKey);
    state = null;
  }
}

/// Widget that displays the fixed Lumi mascot avatar (small icon)
class LumiMascotAvatar extends StatelessWidget {
  final double size;

  const LumiMascotAvatar({
    super.key,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5C9D).withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFFFD1E3), width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/lumi_cat_crisp.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Icon(
            Icons.favorite_rounded,
            color: Color(0xFFFF5C9D),
            size: 24,
          ),
        ),
      ),
    );
  }
}
