import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/services/sqlite_reader/sqlite_backup_data.dart';
import 'package:myfinance/core/services/backup_inspect/backup_inspection_result.dart';

void main() {
  group('Backup & Restore Data Model Integrity Tests', () {
    test('SqliteBackupData holds all required tables including projects, recurring, budgets, and category order', () {
      final data = SqliteBackupData(
        accountsCount: 3,
        transactionsCount: 15,
        categories: [
          {'id': 'cat-1', 'name_th': 'อาหาร', 'sort_order': 0},
          {'id': 'cat-2', 'name_th': 'เดินทาง', 'sort_order': 1},
        ],
        budgets: [
          {'id': 'b-1', 'category_id': 'cat-1', 'limit_satang': 500000},
        ],
        recurringRules: [
          {'id': 'r-1', 'title': 'ค่าเน็ต', 'amount_satang': 59900},
        ],
        projects: [
          {'id': 'p-1', 'name': 'งานวิจัย A'},
        ],
        creditCardInstallments: [
          {'id': 'inst-1', 'total_months': 10},
        ],
      );

      expect(data.accountsCount, equals(3));
      expect(data.transactionsCount, equals(15));
      expect(data.categories.length, equals(2));
      expect(data.categories.first['sort_order'], equals(0));
      expect(data.categories.last['sort_order'], equals(1));
      expect(data.budgets.length, equals(1));
      expect(data.budgets.first['limit_satang'], equals(500000));
      expect(data.recurringRules.length, equals(1));
      expect(data.recurringRules.first['title'], equals('ค่าเน็ต'));
      expect(data.projects.length, equals(1));
      expect(data.projects.first['name'], equals('งานวิจัย A'));
      expect(data.creditCardInstallments.length, equals(1));
    });

    test('BackupInspectionResult accurately reflects projects and recurring rules count', () {
      const result = BackupInspectionResult(
        isValid: true,
        totalAccounts: 2,
        totalTransactions: 50,
        totalCategories: 10,
        totalBudgets: 4,
        totalRecurringRules: 3,
        totalProjects: 2,
        fileName: 'myfinance_backup.db',
      );

      expect(result.isValid, isTrue);
      expect(result.totalAccounts, equals(2));
      expect(result.totalTransactions, equals(50));
      expect(result.totalBudgets, equals(4));
      expect(result.totalRecurringRules, equals(3));
      expect(result.totalProjects, equals(2));
    });
  });
}
