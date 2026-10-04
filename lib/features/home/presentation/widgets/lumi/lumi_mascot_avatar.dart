import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<bool> pickAndSaveMascot() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return false;

      final file = result.files.first;
      final prefs = await SharedPreferences.getInstance();

      if (kIsWeb || file.path == null) {
        if (file.bytes != null) {
          final b64 = base64Encode(file.bytes!);
          await prefs.setString(_customMascotBase64PrefKey, b64);
          state = b64;
          return true;
        }
      } else {
        final path = file.path!;
        await prefs.setString(_customMascotPathPrefKey, path);
        if (file.bytes != null) {
          // Store base64 fallback
          await prefs.setString(_customMascotBase64PrefKey, base64Encode(file.bytes!));
        }
        state = path;
        return true;
      }
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

/// Widget that displays the Lumi mascot avatar with custom upload support
class LumiMascotAvatar extends ConsumerWidget {
  final double size;
  final bool enableUploadOnTap;

  const LumiMascotAvatar({
    super.key,
    this.size = 44,
    this.enableUploadOnTap = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customData = ref.watch(customMascotProvider);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    Widget imageWidget;
    if (customData != null && customData.isNotEmpty) {
      if (!kIsWeb && !customData.startsWith('data:') && File(customData).existsSync()) {
        imageWidget = Image.file(
          File(customData),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildDefaultAssetImage(),
        );
      } else {
        try {
          final bytes = base64Decode(customData);
          imageWidget = Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildDefaultAssetImage(),
          );
        } catch (_) {
          imageWidget = _buildDefaultAssetImage();
        }
      }
    } else {
      imageWidget = _buildDefaultAssetImage();
    }

    final avatarCircle = Container(
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
      child: ClipOval(child: imageWidget),
    );

    if (!enableUploadOnTap) return avatarCircle;

    return InkWell(
      onTap: () => _showMascotDialog(context, ref, isThai, customData != null),
      borderRadius: BorderRadius.circular(size),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatarCircle,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                color: Color(0xFFFF5C9D),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 11,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAssetImage() {
    return Image.asset(
      'assets/images/lumi_cat_crisp.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Icon(
        Icons.pets_rounded,
        color: Color(0xFFFF5C9D),
        size: 22,
      ),
    );
  }

  void _showMascotDialog(BuildContext context, WidgetRef ref, bool isThai, bool hasCustom) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      isThai ? 'ปรับแต่งรูปมาสคอต Lumi 🌸' : 'Customize Lumi Mascot 🌸',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFFF5C9D)),
                title: Text(isThai ? 'อัปโหลดรูปภาพใหม่จากเครื่อง' : 'Upload photo from device'),
                subtitle: Text(isThai ? 'เลือกภาพแมว สัตว์เลี้ยง หรือรูปที่คุณชอบ' : 'Choose a pet or custom photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await ref.read(customMascotProvider.notifier).pickAndSaveMascot();
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isThai ? 'เปลี่ยนรูปมาสคอต Lumi สำเร็จ ✨' : 'Lumi mascot updated ✨')),
                    );
                  }
                },
              ),
              if (hasCustom)
                ListTile(
                  leading: const Icon(Icons.restore, color: Colors.orange),
                  title: Text(isThai ? 'รีเซ็ตกลับเป็นรูปน้องแมว Lumi ดั้งเดิม' : 'Reset to default Lumi mascot'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref.read(customMascotProvider.notifier).resetToDefault();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isThai ? 'รีเซ็ตเป็นรูปมาสคอตดั้งเดิมแล้ว' : 'Reset to original mascot')),
                      );
                    }
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
