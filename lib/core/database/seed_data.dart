import 'package:drift/drift.dart';
import 'app_database.dart';

class SeedData {
  static Future<void> insertSeedData(AppDatabase db) async {
    final now = DateTime.now();

    // 1. Currencies
    await db.into(db.currencies).insert(
      CurrenciesCompanion.insert(
        code: 'THB',
        name: 'Thai Baht',
        symbol: '฿',
        isBase: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await db.into(db.currencies).insert(
      CurrenciesCompanion.insert(
        code: 'USD',
        name: 'US Dollar',
        symbol: r'$',
        isBase: const Value(false),
        createdAt: now,
        updatedAt: now,
      ),
      mode: InsertMode.insertOrIgnore,
    );

    // 2. 6 Accounts
    final accounts = [
      AccountsCompanion.insert(
        id: '00000000-0000-4000-8000-000000000001',
        name: 'SCB',
        accountType: 'bank',
        currencyCode: 'THB',
        isDomestic: true,
        createdAt: now,
        updatedAt: now,
      ),
      AccountsCompanion.insert(
        id: '00000000-0000-4000-8000-000000000002',
        name: 'Krungthai',
        accountType: 'bank',
        currencyCode: 'THB',
        isDomestic: true,
        createdAt: now,
        updatedAt: now,
      ),
      AccountsCompanion.insert(
        id: '00000000-0000-4000-8000-000000000003',
        name: 'Dime! Save',
        accountType: 'bank',
        currencyCode: 'THB',
        isDomestic: true,
        createdAt: now,
        updatedAt: now,
      ),
      AccountsCompanion.insert(
        id: '00000000-0000-4000-8000-000000000004',
        name: 'Dime! FCD',
        accountType: 'fcd',
        currencyCode: 'USD',
        isDomestic: true,
        createdAt: now,
        updatedAt: now,
      ),
      AccountsCompanion.insert(
        id: '00000000-0000-4000-8000-000000000005',
        name: 'Dime! USD',
        accountType: 'offshore',
        currencyCode: 'USD',
        isDomestic: false,
        createdAt: now,
        updatedAt: now,
      ),
      AccountsCompanion.insert(
        id: '00000000-0000-4000-8000-000000000006',
        name: 'บัตรเครดิต',
        accountType: 'credit_card',
        currencyCode: 'THB',
        isDomestic: true,
        closingDay: const Value(23),
        dueDay: const Value(10),
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final acc in accounts) {
      await db.into(db.accounts).insert(acc, mode: InsertMode.insertOrIgnore);
    }

    // 3. Categories (System standard)
    final categories = [
      // Incomes
      CategoriesCompanion.insert(
        id: 'cat-inc-0000-4000-8000-000000000001',
        nameTh: 'เงินเดือน',
        nameEn: 'Salary',
        categoryType: 'income',
        taxIncomeType: const Value('40_1'),
        icon: const Value('work'),
        color: const Value('0xFF4CAF50'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-inc-0000-4000-8000-000000000002',
        nameTh: 'รับจ้าง / ค่าอยู่เวร',
        nameEn: 'Freelance / Shift',
        categoryType: 'income',
        taxIncomeType: const Value('40_2'),
        icon: const Value('assignment'),
        color: const Value('0xFF8BC34A'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-inc-0000-4000-8000-000000000003',
        nameTh: 'ดอกเบี้ยและเงินปันผล',
        nameEn: 'Interest & Dividends',
        categoryType: 'income',
        taxIncomeType: const Value('40_4'),
        icon: const Value('account_balance'),
        color: const Value('0xFF009688'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-inc-0000-4000-8000-000000000004',
        nameTh: 'ธุรกิจ / ขายของ',
        nameEn: 'Business / Sales',
        categoryType: 'income',
        taxIncomeType: const Value('40_8'),
        icon: const Value('storefront'),
        color: const Value('0xFFFF9800'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-inc-0000-4000-8000-000000000005',
        nameTh: 'รายรับอื่นๆ',
        nameEn: 'Other Income',
        categoryType: 'income',
        icon: const Value('attach_money'),
        color: const Value('0xFF607D8B'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),

      // Expenses
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000001',
        nameTh: 'อาหารและเครื่องดื่ม',
        nameEn: 'Food & Dining',
        categoryType: 'expense',
        icon: const Value('restaurant'),
        color: const Value('0xFFF44336'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000002',
        nameTh: 'ที่อยู่อาศัย',
        nameEn: 'Housing',
        categoryType: 'expense',
        icon: const Value('home'),
        color: const Value('0xFF9C27B0'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000003',
        nameTh: 'การเดินทาง',
        nameEn: 'Transportation',
        categoryType: 'expense',
        icon: const Value('directions_car'),
        color: const Value('0xFF3F51B5'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000004',
        nameTh: 'สาธารณูปโภค',
        nameEn: 'Utilities',
        categoryType: 'expense',
        icon: const Value('bolt'),
        color: const Value('0xFF00BCD4'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000005',
        nameTh: 'สุขภาพและรักษาพยาบาล',
        nameEn: 'Healthcare',
        categoryType: 'expense',
        icon: const Value('medical_services'),
        color: const Value('0xFFE91E63'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000006',
        nameTh: 'ช้อปปิ้ง',
        nameEn: 'Shopping',
        categoryType: 'expense',
        icon: const Value('shopping_bag'),
        color: const Value('0xFFFF5722'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000007',
        nameTh: 'บันเทิงและการพักผ่อน',
        nameEn: 'Entertainment',
        categoryType: 'expense',
        icon: const Value('movie'),
        color: const Value('0xFF673AB7'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000008',
        nameTh: 'การศึกษาและพัฒนาตนเอง',
        nameEn: 'Education',
        categoryType: 'expense',
        icon: const Value('school'),
        color: const Value('0xFF2196F3'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000009',
        nameTh: 'ค่าธรรมเนียมและการเงิน',
        nameEn: 'Financial Fees',
        categoryType: 'expense',
        icon: const Value('receipt_long'),
        color: const Value('0xFF795548'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000010',
        nameTh: 'ค่าใช้จ่ายอื่นๆ',
        nameEn: 'Other Expense',
        categoryType: 'expense',
        icon: const Value('more_horiz'),
        color: const Value('0xFF9E9E9E'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),

      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000011',
        nameTh: 'ของขวัญ / ของฝาก',
        nameEn: 'Gifts',
        categoryType: 'expense',
        icon: const Value('card_giftcard'),
        color: const Value('0xFFEC407A'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000012',
        nameTh: 'ยูซุ',
        nameEn: 'Yuzu',
        categoryType: 'expense',
        icon: const Value('pets'),
        color: const Value('0xFFFF7043'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000013',
        nameTh: 'ท่องเที่ยว',
        nameEn: 'Travel',
        categoryType: 'expense',
        icon: const Value('flight_takeoff'),
        color: const Value('0xFF00ACC1'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),

      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000014',
        nameTh: 'เงินสะสม กบข.',
        nameEn: 'GPF Pension Fund',
        categoryType: 'expense',
        icon: const Value('account_balance'),
        color: const Value('0xFF4CAF50'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000015',
        nameTh: 'เบี้ยประกันชีวิตและออมทรัพย์',
        nameEn: 'Life & Savings Insurance',
        categoryType: 'expense',
        icon: const Value('health_and_safety'),
        color: const Value('0xFF009688'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),

      // Transfer
      CategoriesCompanion.insert(
        id: 'cat-trf-0000-4000-8000-000000000001',
        nameTh: 'โอนเงินระหว่างบัญชี',
        nameEn: 'Account Transfer',
        categoryType: 'transfer',
        icon: const Value('swap_horiz'),
        color: const Value('0xFF607D8B'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final cat in categories) {
      await db.into(db.categories).insert(cat, mode: InsertMode.insertOrIgnore);
    }

    // 4. Financial Health Metrics (8 default metrics)
    final healthMetrics = [
      FinancialHealthSettingsCompanion.insert(
        id: 'hlth-0000-4000-8000-000000000001',
        metricCode: 'liquidity',
        targetOperator: '>',
        targetValue: '1',
        createdAt: now,
        updatedAt: now,
      ),
      FinancialHealthSettingsCompanion.insert(
        id: 'hlth-0000-4000-8000-000000000002',
        metricCode: 'emergency_fund',
        targetOperator: '>=',
        targetValue: '6',
        createdAt: now,
        updatedAt: now,
      ),
      FinancialHealthSettingsCompanion.insert(
        id: 'hlth-0000-4000-8000-000000000003',
        metricCode: 'debt_burden',
        targetOperator: '<',
        targetValue: '0.5',
        createdAt: now,
        updatedAt: now,
      ),
      FinancialHealthSettingsCompanion.insert(
        id: 'hlth-0000-4000-8000-000000000004',
        metricCode: 'debt_service',
        targetOperator: '<',
        targetValue: '0.4',
        createdAt: now,
        updatedAt: now,
      ),
      FinancialHealthSettingsCompanion.insert(
        id: 'hlth-0000-4000-8000-000000000005',
        metricCode: 'solvency',
        targetOperator: '>',
        targetValue: '0',
        userParam1Satang: const Value(0),
        createdAt: now,
        updatedAt: now,
      ),
      FinancialHealthSettingsCompanion.insert(
        id: 'hlth-0000-4000-8000-000000000006',
        metricCode: 'health_coverage',
        targetOperator: '>',
        targetValue: '0',
        userParam2Satang: const Value(0),
        createdAt: now,
        updatedAt: now,
      ),
      FinancialHealthSettingsCompanion.insert(
        id: 'hlth-0000-4000-8000-000000000007',
        metricCode: 'savings_rate',
        targetOperator: '>',
        targetValue: '0.1',
        createdAt: now,
        updatedAt: now,
      ),
      FinancialHealthSettingsCompanion.insert(
        id: 'hlth-0000-4000-8000-000000000008',
        metricCode: 'investment_ratio',
        targetOperator: '>',
        targetValue: '0.5',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final metric in healthMetrics) {
      await db.into(db.financialHealthSettings).insert(metric, mode: InsertMode.insertOrIgnore);
    }
  }

  static Future<void> insertTaxRulesSeedData(AppDatabase db) async {
    final now = DateTime.now();

    const defaultBracketsJson = '''
[
  {"minSatang": 0, "maxSatang": 15000000, "ratePercent": "0.0"},
  {"minSatang": 15000001, "maxSatang": 30000000, "ratePercent": "5.0"},
  {"minSatang": 30000001, "maxSatang": 50000000, "ratePercent": "10.0"},
  {"minSatang": 50000001, "maxSatang": 75000000, "ratePercent": "15.0"},
  {"minSatang": 75000001, "maxSatang": 100000000, "ratePercent": "20.0"},
  {"minSatang": 100000001, "maxSatang": 200000000, "ratePercent": "25.0"},
  {"minSatang": 200000001, "maxSatang": 500000000, "ratePercent": "30.0"},
  {"minSatang": 50000001, "maxSatang": null, "ratePercent": "35.0"}
]
''';

    const defaultDeductionsJson = '''
{
  "socialSecurityMaxSatang": 900000,
  "lifeInsuranceMaxSatang": 10000000,
  "healthInsuranceMaxSatang": 2500000,
  "lifeAndHealthInsuranceCombinedMaxSatang": 10000000,
  "pensionLifeInsuranceMaxSatang": 20000000,
  "pensionLifeRatePercent": "15.0",
  "providentFundRatePercent": "15.0",
  "providentFundMaxSatang": 50000000,
  "rmfRatePercent": "30.0",
  "rmfMaxSatang": 50000000,
  "ssfRatePercent": "30.0",
  "ssfMaxSatang": 20000000,
  "thaiEsgRatePercent": "30.0",
  "thaiEsgMaxSatang": 30000000,
  "retirementGroupCombinedMaxSatang": 50000000,
  "homeLoanInterestMaxSatang": 10000000,
  "generalDonationMaxRatePercent": "10.0",
  "educationDonationMultiplier": 2,
  "educationDonationMaxRatePercent": "10.0"
}
''';

    const defaultForeignRemittanceRuleJson = '''
{
  "residencyDaysThreshold": 180,
  "pre2024ExemptEnabled": true,
  "principalExemptEnabled": true,
  "effectiveStartDate": "2024-01-01"
}
''';

    for (final year in [2025, 2026]) {
      await db.into(db.taxRules).insert(
        TaxRulesCompanion.insert(
          id: 'tax-rule-$year-default',
          taxYear: year,
          bracketsJson: defaultBracketsJson.trim(),
          personalAllowanceSatang: const Value(6000000),
          spouseAllowanceSatang: const Value(6000000),
          childAllowanceSatang: const Value(3000000),
          expenseRatePercent: const Value('50.0'),
          expenseMaxSatang: const Value(10000000),
          flatExpense406MedicalPercent: const Value('60.0'),
          flatExpense408Percent: const Value('60.0'),
          deductionLimitsJson: defaultDeductionsJson.trim(),
          foreignRemittanceRuleJson: defaultForeignRemittanceRuleJson.trim(),
          isActive: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );

      await db.into(db.taxResidencyRecords).insert(
        TaxResidencyRecordsCompanion.insert(
          id: 'tax-residency-$year-default',
          taxYear: year,
          daysInThailand: const Value(365),
          note: const Value('ค่าเริ่มต้น (อยู่ในไทยตลอดทั้งปี)'),
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }
}
