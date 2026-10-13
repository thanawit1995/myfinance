import 'package:flutter/material.dart';
import '../theme/vault_theme.dart';
import 'category_icon_helper.dart';

/// Helper for vibrant category colors and squircle icon badges.
///
/// Ensures every category has an eye-catching, distinct color with
/// appropriate contrast in both Light and Dark modes.
class CategoryColorHelper {
  // 16 curated high-contrast, modern vibrant colors matching design system
  static const List<Color> palette = [
    Color(0xFFFF6B6B), // 0: Warm Coral Orange (Food, Dining)
    Color(0xFFFF9F43), // 1: Amber Orange (Housing, Property, Business)
    Color(0xFFFECA57), // 2: Golden Yellow (Investment, Gold, Dividends)
    Color(0xFF10AC84), // 3: Mint Emerald (Salary, Regular Income)
    Color(0xFF1DD1A1), // 4: Jade Green (Freelance, Bonus, Savings)
    Color(0xFF00D2D3), // 5: Turquoise Teal (Utilities, Bills, Water, Electric)
    Color(0xFF2E86DE), // 6: Electric Blue (Transport, Fuel, Travel)
    Color(0xFF54A0FF), // 7: Indigo Blue (Tech, Subscriptions, Fees)
    Color(0xFF5F27CD), // 8: Vivid Purple (Entertainment, Games)
    Color(0xFF9B59B6), // 9: Violet Pink (Shopping, Goods, Fashion)
    Color(0xFFFF6B8B), // 10: Bubblegum Rose (Gifts, Cosmetics, Beauty)
    Color(0xFFEE5253), // 11: Crimson Rose (Health, Hospital, Pharmacy)
    Color(0xFFA0522D), // 12: Warm Cocoa (Pets, Animals)
    Color(0xFF34495E), // 13: Slate Navy (Education, Books)
    Color(0xFF27AE60), // 14: Forest Sage (Charity, Pension, GPF)
    Color(0xFFE056FD), // 15: Sunset Magenta (Lifestyle, Cafe, Misc)
  ];

  /// Parses a color string (e.g. '0xFFFF6B6B' or '#FF6B6B') or falls back to
  /// a stable, deterministic color based on category name or icon.
  static Color getColor(
    String? colorStr, {
    String? categoryName,
    String? iconName,
  }) {
    if (colorStr != null && colorStr.isNotEmpty) {
      try {
        final clean = colorStr.replaceAll('#', '').trim();
        if (clean.startsWith('0x') || clean.startsWith('0X')) {
          return Color(int.parse(clean));
        } else if (clean.length == 6) {
          return Color(int.parse('0xFF$clean'));
        } else if (clean.length == 8) {
          return Color(int.parse('0x$clean'));
        }
      } catch (_) {
        // Fallback below
      }
    }

    // Keyword matching for familiar defaults
    final combined = '${categoryName ?? ''} ${iconName ?? ''}'.toLowerCase();
    if (combined.contains('อาหาร') ||
        combined.contains('food') ||
        combined.contains('dining') ||
        combined.contains('restaurant') ||
        combined.contains('cafe') ||
        combined.contains('ramen') ||
        combined.contains('fastfood')) {
      return palette[0]; // Warm Coral Orange
    }
    if (combined.contains('ที่อยู่อาศัย') ||
        combined.contains('บ้าน') ||
        combined.contains('home') ||
        combined.contains('housing') ||
        combined.contains('rent')) {
      return palette[1]; // Amber Orange
    }
    if (combined.contains('ลงทุน') ||
        combined.contains('invest') ||
        combined.contains('gold') ||
        combined.contains('ทอง') ||
        combined.contains('stock') ||
        combined.contains('dividend') ||
        combined.contains('ดอกเบี้ย')) {
      return palette[2]; // Golden Yellow
    }
    if (combined.contains('เงินเดือน') ||
        combined.contains('salary') ||
        combined.contains('รายได้') ||
        combined.contains('income')) {
      return palette[3]; // Mint Emerald
    }
    if (combined.contains('รับจ้าง') ||
        combined.contains('เวร') ||
        combined.contains('freelance') ||
        combined.contains('shift')) {
      return palette[4]; // Jade Green
    }
    if (combined.contains('สาธารณูปโภค') ||
        combined.contains('บิล') ||
        combined.contains('utility') ||
        combined.contains('utilities') ||
        combined.contains('ไฟ') ||
        combined.contains('น้ำ') ||
        combined.contains('bolt') ||
        combined.contains('water')) {
      return palette[5]; // Turquoise Teal
    }
    if (combined.contains('เดิน') ||
        combined.contains('รถ') ||
        combined.contains('transport') ||
        combined.contains('travel') ||
        combined.contains('car') ||
        combined.contains('bus') ||
        combined.contains('taxi') ||
        combined.contains('gas') ||
        combined.contains('flight')) {
      return palette[6]; // Electric Blue
    }
    if (combined.contains('บันเทิง') ||
        combined.contains('entertainment') ||
        combined.contains('movie') ||
        combined.contains('game')) {
      return palette[8]; // Vivid Purple
    }
    if (combined.contains('ช้อป') ||
        combined.contains('shopping') ||
        combined.contains('bag') ||
        combined.contains('cart') ||
        combined.contains('เสื้อผ้า')) {
      return palette[9]; // Violet Pink
    }
    if (combined.contains('ของขวัญ') ||
        combined.contains('gift') ||
        combined.contains('ความงาม') ||
        combined.contains('beauty')) {
      return palette[10]; // Bubblegum Rose
    }
    if (combined.contains('สุขภาพ') ||
        combined.contains('ยา') ||
        combined.contains('health') ||
        combined.contains('medical') ||
        combined.contains('hospital')) {
      return palette[11]; // Crimson Rose
    }
    if (combined.contains('สัตว์') ||
        combined.contains('pet') ||
        combined.contains('ยูซุ') ||
        combined.contains('yuzu')) {
      return palette[12]; // Warm Cocoa
    }
    if (combined.contains('เรียน') ||
        combined.contains('ศึกษา') ||
        combined.contains('education') ||
        combined.contains('school')) {
      return palette[13]; // Slate Navy
    }
    if (combined.contains('กบข') ||
        combined.contains('gpf') ||
        combined.contains('pension') ||
        combined.contains('บริจาค') ||
        combined.contains('charity')) {
      return palette[14]; // Forest Sage
    }

    // Stable deterministic fallback from string hash
    final hashSource = categoryName ?? iconName ?? 'category';
    final index = hashSource.hashCode.abs() % palette.length;
    return palette[index];
  }

  /// Converts a Color into a storage string '0xAARRGGBB'
  static String toHex(Color color) {
    return '0x${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// Builds a modern Squircle badge with clean card tile surface,
  /// vibrant colored ambient glow shadow, subtle border, and vibrant icon glyph.
  /// Matches the multi-colored component design system.
  static Widget buildCategorySquircleBadge(
    BuildContext context, {
    required String? icon,
    required Color color,
    double size = 40,
    double iconSize = 20,
    bool isInactive = false,
  }) {
    final isDark = VaultTheme.isDark(context);
    final isLumi = VaultTheme.isLumi(context);
    final badgeColor = isInactive ? Colors.grey : color;

    final tileColor = isInactive
        ? (isDark ? const Color(0xFF28282B) : const Color(0xFFF3F4F6))
        : (isDark
            ? (isLumi ? const Color(0xFF2A1E2B) : const Color(0xFF202024))
            : Colors.white);

    final glowShadow = isInactive
        ? null
        : BoxShadow(
            color: badgeColor.withValues(alpha: isDark ? 0.38 : 0.26),
            blurRadius: size * 0.28,
            offset: const Offset(0, 3),
            spreadRadius: 0.5,
          );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(
          color: isInactive
              ? Colors.transparent
              : badgeColor.withValues(alpha: isDark ? 0.35 : 0.20),
          width: 1.0,
        ),
        boxShadow: glowShadow != null ? [glowShadow] : null,
      ),
      alignment: Alignment.center,
      child: CategoryIconHelper.buildIconWidget(
        icon,
        size: iconSize,
        color: badgeColor,
      ),
    );
  }
}
