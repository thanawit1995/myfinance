import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/widgets/category_color_helper.dart';

void main() {
  group('CategoryColorHelper Tests', () {
    test('Palettes contains 16 distinct vibrant colors', () {
      expect(CategoryColorHelper.palette.length, 16);
      final uniqueColors = CategoryColorHelper.palette.toSet();
      expect(uniqueColors.length, 16);
    });

    test('Parses valid hex color string properly', () {
      final color = CategoryColorHelper.getColor('0xFFFF6B6B');
      expect(color.toARGB32(), const Color(0xFFFF6B6B).toARGB32());

      final colorHash = CategoryColorHelper.getColor('#3498DB');
      expect(colorHash.toARGB32(), const Color(0xFF3498DB).toARGB32());
    });

    test('Matches category keywords to distinct colors', () {
      final foodColor = CategoryColorHelper.getColor(null, categoryName: 'อาหารและเครื่องดื่ม');
      expect(foodColor, CategoryColorHelper.palette[0]); // Coral

      final transportColor = CategoryColorHelper.getColor(null, categoryName: 'การเดินทาง');
      expect(transportColor, CategoryColorHelper.palette[6]); // Electric Sky

      final utilitiesColor = CategoryColorHelper.getColor(null, categoryName: 'สาธารณูปโภค ค่าไฟ');
      expect(utilitiesColor, CategoryColorHelper.palette[5]); // Turquoise

      final shoppingColor = CategoryColorHelper.getColor(null, categoryName: 'ช้อปปิ้ง เสื้อผ้า');
      expect(shoppingColor, CategoryColorHelper.palette[9]); // Violet Orchid
    });

    test('Converts Color to Hex string reversibly', () {
      const original = Color(0xFF10AC84);
      final hex = CategoryColorHelper.toHex(original);
      expect(hex, '0xFF10AC84');
      final parsed = CategoryColorHelper.getColor(hex);
      expect(parsed.toARGB32(), original.toARGB32());
    });

    test('Deterministic fallback for unknown category names', () {
      final colorA1 = CategoryColorHelper.getColor(null, categoryName: 'ของเล่นแมวแปลกๆ');
      final colorA2 = CategoryColorHelper.getColor(null, categoryName: 'ของเล่นแมวแปลกๆ');
      expect(colorA1, colorA2);
    });
  });
}
