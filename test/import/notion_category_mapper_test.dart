import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/features/import/domain/notion_category_mapper.dart';

void main() {
  group('NotionCategoryMapper Tests', () {
    test('maps standard Notion expenses correctly', () {
      expect(NotionCategoryMapper.toAppCategoryNameEn('eating'), 'Food & Dining');
      expect(NotionCategoryMapper.toAppCategoryNameEn('Eating'), 'Food & Dining');
      expect(NotionCategoryMapper.toAppCategoryNameEn('Transportation'), 'Transportation');
      expect(NotionCategoryMapper.toAppCategoryNameEn('Health & Fitness'), 'Healthcare');
      expect(NotionCategoryMapper.toAppCategoryNameEn('Home'), 'Housing');
      expect(NotionCategoryMapper.toAppCategoryNameEn('Entertainment'), 'Entertainment');
    });

    test('maps custom confirmed categories: Lover -> Gifts and Cat -> Yuzu', () {
      expect(NotionCategoryMapper.toAppCategoryNameEn('Lover'), 'Gifts');
      expect(NotionCategoryMapper.toAppCategoryNameEn('lover'), 'Gifts');
      expect(NotionCategoryMapper.toAppCategoryNameEn('Cat'), 'Yuzu');
      expect(NotionCategoryMapper.toAppCategoryNameEn('cat'), 'Yuzu');
    });

    test('maps Notion income categories correctly', () {
      expect(NotionCategoryMapper.toAppCategoryNameEn('Salary'), 'Salary');
      expect(NotionCategoryMapper.toAppCategoryNameEn('Top up'), 'Other Income');
      expect(NotionCategoryMapper.toAppCategoryNameEn('topup'), 'Other Income');
      expect(NotionCategoryMapper.toAppCategoryNameEn('On duty'), 'Freelance / Shift');
    });

    test('returns null for unknown categories', () {
      expect(NotionCategoryMapper.toAppCategoryNameEn('Unknown XYZ'), isNull);
      expect(NotionCategoryMapper.toAppCategoryNameEn(''), isNull);
    });
  });
}
