import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:decimal/decimal.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(inMemoryConnection());
  });

  tearDown(() async {
    await db.close();
  });

  group('AccountsDao - Real-time Balance & Fee Deduction Tests', () {
    test('Deposit account balance correctly includes income and deducts expense + fee', () async {
      final scb = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.name == 'SCB');

      // 1. Initial Opening Balance (Income): 10,000.00 THB = 1,000,000 satang
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-open-scb',
          transactionType: 'income',
          sourceAccountId: Value(scb.id),
          amountOriginalSatang: 1000000,
          currencyCode: 'THB',
          amountThbSatang: 1000000,
          transactionDate: DateTime(2026, 9, 1),
          createdAt: DateTime(2026, 9, 1),
          updatedAt: DateTime(2026, 9, 1),
        ),
      );

      var balance = await db.accountsDao.getAccountBalanceSatang(scb.id);
      expect(balance, equals(1000000)); // 10,000.00 THB

      // 2. Expense: 1,000.00 THB with 15.00 THB fee (fee = 1,500 satang)
      // As confirmed in Q1, total deducted must be 1,015.00 THB (101,500 satang)!
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-exp-scb',
          transactionType: 'expense',
          sourceAccountId: Value(scb.id),
          amountOriginalSatang: 100000, // 1,000 THB
          currencyCode: 'THB',
          amountThbSatang: 100000,
          feeThbSatang: const Value(1500), // 15 THB fee
          transactionDate: DateTime(2026, 9, 2),
          createdAt: DateTime(2026, 9, 2),
          updatedAt: DateTime(2026, 9, 2),
        ),
      );

      balance = await db.accountsDao.getAccountBalanceSatang(scb.id);
      // 10,000.00 - 1,015.00 = 8,985.00 THB (898,500 satang)
      expect(balance, equals(898500));
    });

    test('Inactive accounts (is_active = false) are excluded from Total Net Worth (Q2)', () async {
      final scb = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.name == 'SCB');
      final ktb = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.name == 'Krungthai');

      // Deposit 10,000 THB in SCB
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-scb-1',
          transactionType: 'income',
          sourceAccountId: Value(scb.id),
          amountOriginalSatang: 1000000,
          currencyCode: 'THB',
          amountThbSatang: 1000000,
          transactionDate: DateTime(2026, 9, 1),
          createdAt: DateTime(2026, 9, 1),
          updatedAt: DateTime(2026, 9, 1),
        ),
      );

      // Deposit 5,000 THB in Krungthai
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-ktb-1',
          transactionType: 'income',
          sourceAccountId: Value(ktb.id),
          amountOriginalSatang: 500000,
          currencyCode: 'THB',
          amountThbSatang: 500000,
          transactionDate: DateTime(2026, 9, 1),
          createdAt: DateTime(2026, 9, 1),
          updatedAt: DateTime(2026, 9, 1),
        ),
      );

      // Both active: Total Net Worth = 15,000 THB
      var netWorth = await db.accountsDao.getTotalNetWorthSatang();
      expect(netWorth, equals(1500000));

      // Deactivate Krungthai account
      await db.accountsDao.deactivateAccount(ktb.id);

      // Krungthai balance is still preserved in history
      final ktbBal = await db.accountsDao.getAccountBalanceSatang(ktb.id);
      expect(ktbBal, equals(500000));

      // But Total Net Worth on Dashboard excludes deactivated account -> only SCB (10,000 THB)
      netWorth = await db.accountsDao.getTotalNetWorthSatang();
      expect(netWorth, equals(1000000));
    });

    test('Can create a new custom account with initial balance', () async {
      final now = DateTime.now();
      const newAccId = 'acc-custom-kbank';

      await db.accountsDao.createAccount(
        AccountsCompanion.insert(
          id: newAccId,
          name: 'กสิกรไทย (K-Bank)',
          accountType: 'bank',
          currencyCode: 'THB',
          isDomestic: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final created = await db.accountsDao.getAccountById(newAccId);
      expect(created, isNotNull);
      expect(created!.name, equals('กสิกรไทย (K-Bank)'));
      expect(created.isActive, isTrue);

      // Record initial opening balance
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-kbank-initial',
          transactionType: 'income',
          sourceAccountId: const Value(newAccId),
          amountOriginalSatang: 2500000, // 25,000 THB
          currencyCode: 'THB',
          amountThbSatang: 2500000,
          transactionDate: now,
          note: const Value('ยอดยกมาเริ่มต้น'),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final balance = await db.accountsDao.getAccountBalanceSatang(newAccId);
      expect(balance, equals(2500000));
    });

    test('USD Account maintains native cents and converts to THB with current FX rate in net worth', () async {
      final now = DateTime.now();
      const usdAccId = 'acc-usd-test';

      // 1. Create USD Account
      await db.accountsDao.createAccount(
        AccountsCompanion.insert(
          id: usdAccId,
          name: 'Charles Schwab (USD)',
          accountType: 'brokerage',
          currencyCode: 'USD',
          isDomestic: false,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 2. Insert FX rate: 35.50 THB/USD
      await db.into(db.fxRates).insert(
        FxRatesCompanion.insert(
          id: 'fx-usd-355',
          baseCurrency: 'USD',
          targetCurrency: 'THB',
          rate: '35.500000',
          effectiveDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 3. Deposit $1,000.00 USD (100,000 cents)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-usd-dep',
          transactionType: 'income',
          sourceAccountId: const Value(usdAccId),
          amountOriginalSatang: 100000, // $1,000.00
          currencyCode: 'USD',
          fxRate: const Value('35.500000'),
          amountThbSatang: 3550000, // 35,500.00 THB
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Native balance in USD cents = 100,000 ($1,000.00)
      final nativeBal = await db.accountsDao.getAccountBalanceSatang(usdAccId);
      expect(nativeBal, equals(100000));

      // Breakdown: native $1,000.00, equivalent 35,500.00 THB (3,550,000 satang)
      final breakdown = await db.accountsDao.getAccountBalanceBreakdown(usdAccId);
      expect(breakdown.nativeBalanceSatang, equals(100000));
      expect(breakdown.thbEquivalentSatang, equals(3550000));
      expect(breakdown.fxRate, equals(Decimal.parse('35.5')));
    });

    test('updateAccountName successfully renames account', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final target = accounts.first;
      final originalName = target.name;

      final updatedCount = await db.accountsDao.updateAccountName(target.id, 'My New Account Name');
      expect(updatedCount, equals(1));

      final updatedAcc = await db.accountsDao.getAccountById(target.id);
      expect(updatedAcc?.name, equals('My New Account Name'));
      expect(updatedAcc?.name, isNot(equals(originalName)));
    });
  });

  group('AccountsDao - setDefaultAccount & Default Ordering Tests', () {
    test('setDefaultAccount ตั้งบัญชีเป็นบัญชีหลักได้ และ reset บัญชีอื่น', () async {
      final allAccounts = await db.accountsDao.getActiveAccounts();
      expect(allAccounts, isNotEmpty);

      final target = allAccounts.first;

      // ตั้งเป็นบัญชีหลัก
      await db.accountsDao.setDefaultAccount(target.id);

      // ตรวจว่า target เป็น isDefault = true
      final updated = await db.accountsDao.getAccountById(target.id);
      expect(updated?.isDefault, isTrue);

      // ตรวจว่าบัญชีอื่นทั้งหมด isDefault = false
      final rest = allAccounts.where((a) => a.id != target.id).toList();
      for (final acc in rest) {
        final a = await db.accountsDao.getAccountById(acc.id);
        expect(a?.isDefault, isFalse,
            reason: 'บัญชี ${acc.name} ควรเป็น isDefault=false');
      }
    });

    test('setDefaultAccount เปลี่ยนบัญชีหลักจากบัญชีหนึ่งไปอีกบัญชีได้ถูกต้อง', () async {
      final allAccounts = await db.accountsDao.getActiveAccounts();
      expect(allAccounts.length, greaterThanOrEqualTo(2));

      final first = allAccounts[0];
      final second = allAccounts[1];

      // ตั้ง first เป็นบัญชีหลักก่อน
      await db.accountsDao.setDefaultAccount(first.id);
      var firstAcc = await db.accountsDao.getAccountById(first.id);
      expect(firstAcc?.isDefault, isTrue);

      // เปลี่ยนไปที่ second
      await db.accountsDao.setDefaultAccount(second.id);

      // second ต้องเป็น true
      final secondAcc = await db.accountsDao.getAccountById(second.id);
      expect(secondAcc?.isDefault, isTrue);

      // first ต้องถูก reset เป็น false
      firstAcc = await db.accountsDao.getAccountById(first.id);
      expect(firstAcc?.isDefault, isFalse,
          reason: 'บัญชีเดิมต้องถูก reset isDefault=false เมื่อตั้งบัญชีใหม่เป็นหลัก');
    });

    test('getActiveAccounts เรียงบัญชีหลักไว้ลำดับแรก', () async {
      final allAccounts = await db.accountsDao.getActiveAccounts();
      expect(allAccounts.length, greaterThanOrEqualTo(2));

      // ตั้งบัญชีสุดท้ายเป็นบัญชีหลัก
      final lastAcc = allAccounts.last;
      await db.accountsDao.setDefaultAccount(lastAcc.id);

      final ordered = await db.accountsDao.getActiveAccounts();

      // บัญชีหลักต้องอยู่ลำดับแรก
      expect(ordered.first.id, equals(lastAcc.id),
          reason: 'บัญชีหลักต้องปรากฏเป็นลำดับแรกใน getActiveAccounts()');
      expect(ordered.first.isDefault, isTrue);

      // บัญชีที่เหลือต้อง isDefault = false
      for (int i = 1; i < ordered.length; i++) {
        expect(ordered[i].isDefault, isFalse);
      }
    });
  });
}
