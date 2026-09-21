import 'dart:convert';
import 'dart:typed_data';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import '../database/app_database.dart';
import 'file_saver/file_saver.dart';

class HybridRestoreResult {
  final bool success;
  final String message;
  final int accountsCount;
  final int transactionsCount;
  final int categoriesCount;

  const HybridRestoreResult({
    required this.success,
    required this.message,
    this.accountsCount = 0,
    this.transactionsCount = 0,
    this.categoriesCount = 0,
  });
}

class HybridBackupService {
  final AppDatabase db;

  HybridBackupService({required this.db});

  /// Exports all tables into a structured Map for portable backup.
  Future<Map<String, dynamic>> exportDataAsJson() async {
    final accounts = await db.select(db.accounts).get();
    final categories = await db.select(db.categories).get();
    final currencies = await db.select(db.currencies).get();
    final fxRates = await db.select(db.fxRates).get();
    final transactions = await db.select(db.transactions).get();
    final budgets = await db.select(db.budgets).get();
    final recurringRules = await db.select(db.recurringRules).get();
    final liabilities = await db.select(db.liabilities).get();
    final insurancePolicies = await db.select(db.insurancePolicies).get();

    final now = DateTime.now();

    return {
      'app': 'MyFinance',
      'version': 1,
      'exported_at': now.toIso8601String(),
      'summary': {
        'accounts': accounts.length,
        'transactions': transactions.length,
        'categories': categories.length,
        'budgets': budgets.length,
        'recurringRules': recurringRules.length,
        'liabilities': liabilities.length,
        'insurancePolicies': insurancePolicies.length,
      },
      'data': {
        'currencies': currencies.map((e) => e.toJson()).toList(),
        'fxRates': fxRates.map((e) => e.toJson()).toList(),
        'accounts': accounts.map((e) => e.toJson()).toList(),
        'categories': categories.map((e) => e.toJson()).toList(),
        'transactions': transactions.map((e) => e.toJson()).toList(),
        'budgets': budgets.map((e) => e.toJson()).toList(),
        'recurringRules': recurringRules.map((e) => e.toJson()).toList(),
        'liabilities': liabilities.map((e) => e.toJson()).toList(),
        'insurancePolicies': insurancePolicies.map((e) => e.toJson()).toList(),
      }
    };
  }

  /// Triggers a cross-platform download or share of the JSON backup file.
  Future<bool> exportBackupFile() async {
    try {
      final dataMap = await exportDataAsJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(dataMap);
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final fileName = 'myfinance_backup_$dateStr.json';

      return await PlatformFileSaver.saveAndShareFile(
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/json',
        title: 'MyFinance Backup ($dateStr)',
      );
    } catch (_) {
      return false;
    }
  }

  /// Restores database records from a JSON backup string.
  Future<HybridRestoreResult> restoreFromJsonString(String jsonString) async {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return const HybridRestoreResult(
          success: false,
          message: 'รูปแบบไฟล์สำรองข้อมูลไม่ถูกต้อง (ต้องเป็น JSON Object)',
        );
      }

      if (decoded['app'] != 'MyFinance' || decoded['data'] is! Map<String, dynamic>) {
        return const HybridRestoreResult(
          success: false,
          message: 'ไฟล์นี้ไม่ใช่ไฟล์สำรองข้อมูลของ MyFinance หรือข้อมูลสูญหาย',
        );
      }

      final data = decoded['data'] as Map<String, dynamic>;

      int accCount = 0;
      int txCount = 0;
      int catCount = 0;

      await db.transaction(() async {
        // 1. Currencies
        if (data['currencies'] is List) {
          for (final item in data['currencies'] as List) {
            if (item is Map<String, dynamic>) {
              await db.into(db.currencies).insertOnConflictUpdate(Currency.fromJson(item));
            }
          }
        }

        // 2. FX Rates
        if (data['fxRates'] is List) {
          for (final item in data['fxRates'] as List) {
            if (item is Map<String, dynamic>) {
              await db.into(db.fxRates).insertOnConflictUpdate(FxRate.fromJson(item));
            }
          }
        }

        // 3. Accounts
        if (data['accounts'] is List) {
          for (final item in data['accounts'] as List) {
            if (item is Map<String, dynamic>) {
              await db.into(db.accounts).insertOnConflictUpdate(Account.fromJson(item));
              accCount++;
            }
          }
        }

        // 4. Categories
        if (data['categories'] is List) {
          for (final item in data['categories'] as List) {
            if (item is Map<String, dynamic>) {
              await db.into(db.categories).insertOnConflictUpdate(Category.fromJson(item));
              catCount++;
            }
          }
        }

        // 5. Transactions
        if (data['transactions'] is List) {
          for (final item in data['transactions'] as List) {
            if (item is Map<String, dynamic>) {
              await db.into(db.transactions).insertOnConflictUpdate(Transaction.fromJson(item));
              txCount++;
            }
          }
        }

        // 6. Budgets
        if (data['budgets'] is List) {
          for (final item in data['budgets'] as List) {
            if (item is Map<String, dynamic>) {
              await db.into(db.budgets).insertOnConflictUpdate(Budget.fromJson(item));
            }
          }
        }

        // 7. Recurring Rules
        if (data['recurringRules'] is List) {
          for (final item in data['recurringRules'] as List) {
            if (item is Map<String, dynamic>) {
              await db.into(db.recurringRules).insertOnConflictUpdate(RecurringRule.fromJson(item));
            }
          }
        }

        // 8. Liabilities
        if (data['liabilities'] is List) {
          for (final item in data['liabilities'] as List) {
            if (item is Map<String, dynamic>) {
              await db.into(db.liabilities).insertOnConflictUpdate(Liability.fromJson(item));
            }
          }
        }

        // 9. Insurance Policies
        if (data['insurancePolicies'] is List) {
          for (final item in data['insurancePolicies'] as List) {
            if (item is Map<String, dynamic>) {
              await db.into(db.insurancePolicies).insertOnConflictUpdate(InsurancePolicy.fromJson(item));
            }
          }
        }
      });

      return HybridRestoreResult(
        success: true,
        message: 'กู้คืนข้อมูลสำเร็จเรียบร้อย',
        accountsCount: accCount,
        transactionsCount: txCount,
        categoriesCount: catCount,
      );
    } catch (e) {
      return HybridRestoreResult(
        success: false,
        message: 'เกิดข้อผิดพลาดในการกู้คืนข้อมูล: $e',
      );
    }
  }

  /// Opens system file picker to select a backup file and restore it.
  Future<HybridRestoreResult> pickAndRestoreBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return const HybridRestoreResult(
          success: false,
          message: 'ยกเลิกการเลือกไฟล์',
        );
      }

      final pickedFile = result.files.first;
      String? jsonContent;

      if (pickedFile.bytes != null) {
        jsonContent = utf8.decode(pickedFile.bytes!);
      }

      if (jsonContent == null || jsonContent.isEmpty) {
        return const HybridRestoreResult(
          success: false,
          message: 'ไม่สามารถอ่านข้อมูลจากไฟล์ที่เลือกได้',
        );
      }

      return await restoreFromJsonString(jsonContent);
    } catch (e) {
      return HybridRestoreResult(
        success: false,
        message: 'เกิดข้อผิดพลาดในการเปิดไฟล์: $e',
      );
    }
  }
}
