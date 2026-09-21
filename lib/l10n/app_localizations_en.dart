// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OURS';

  @override
  String get home => 'Home';

  @override
  String get money => 'Money';

  @override
  String get invest => 'Invest';

  @override
  String get plan => 'Plan';

  @override
  String get more => 'More';

  @override
  String get add => 'Add';

  @override
  String get trade => 'Buy / Sell';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get quickAdd => 'Quick Add';

  @override
  String get quickAddKeypad => 'Quick Add (3 taps)';

  @override
  String get portfolio => 'Portfolio';

  @override
  String get accounts => 'Accounts';

  @override
  String get budget => 'Budget';

  @override
  String get investments => 'Investments';

  @override
  String get tax => 'Tax';

  @override
  String get financialHealth => 'Financial Health';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get thai => 'ไทย';

  @override
  String get english => 'English';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageAndAppearance => 'Language & Appearance';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeStyle => 'Design Style';

  @override
  String get themeStyleVault => 'VAULT (Quiet Luxury)';

  @override
  String get themeStyleLumi => 'Lumi (Sunny Bloom Pastel)';

  @override
  String get security => 'Security & PIN';

  @override
  String get pinProtection => 'PIN Protection';

  @override
  String get pinLockToggle => 'Lock App with PIN';

  @override
  String get pinLockSubtitle => 'Require PIN or biometrics to open the app';

  @override
  String get pinDisabled => 'Disabled (open app directly without PIN)';

  @override
  String get pinCode => '6-digit PIN Code';

  @override
  String get pinConfigured => 'PIN configured';

  @override
  String get pinNotConfigured => 'PIN not configured';

  @override
  String get changePin => 'Change PIN';

  @override
  String get setupPin => 'Setup PIN';

  @override
  String get sessionTimeout => 'Session Unlock Timeout';

  @override
  String get biometrics => 'Biometrics (Fingerprint / Face)';

  @override
  String get biometricsSubtitle => 'Use biometric unlock alongside PIN';

  @override
  String get biometricsNotSupported =>
      'Biometrics sensor not supported on this device';

  @override
  String get backup => 'Data Backup';

  @override
  String get personalCloudBackup => 'Personal Cloud & Backup';

  @override
  String get backupToJson => 'Backup to JSON';

  @override
  String get backupToJsonSubtitle =>
      'Export personal backup file to save to Google Drive or device storage';

  @override
  String get restoreFromJson => 'Restore Backup';

  @override
  String get restoreFromJsonSubtitle =>
      'Select a backup file (.json) to import and restore';

  @override
  String get exportRawDb => 'Export Raw Database (.db)';

  @override
  String get exportRawDbSubtitle =>
      'Backup SQLite database file locally or share';

  @override
  String get exportDatabase => 'Export Database Backup (.db)';

  @override
  String get trashBin => 'Trash Bin & Recovery';

  @override
  String get trashBinSubtitle =>
      'View deleted accounts, restore, or permanently remove (30 days)';

  @override
  String get recurringTransactions => 'Recurring Rules';

  @override
  String get recurringRulesDesc =>
      'Set automated recurring rules and view 30-day cash forecast';

  @override
  String get taxAndRemittance => 'Tax & Foreign Remittance';

  @override
  String get taxPlanning => 'Tax Planning (P.N.D. 90/91)';

  @override
  String get taxPlanningDesc =>
      'Progressive tax brackets, deductions, and dividend analysis';

  @override
  String get foreignRemittance => 'Foreign Remittance Tracking';

  @override
  String get foreignRemittanceDesc =>
      '180-day rule, Revenue orders 161/162, principal vs gain';

  @override
  String get financialPlanning => 'Financial Planning & Automation';

  @override
  String get financialHealthDesc =>
      'Evaluate 8 metrics, end-of-month run-rate, and recommendations';

  @override
  String get liabilitiesInsurance => 'Debts & Insurance Policies';

  @override
  String get liabilitiesInsuranceDesc =>
      'Manage debt obligations, interest rates, and coverage';

  @override
  String get categoriesManage => 'Manage Categories';

  @override
  String get categoriesManageDesc =>
      'Create categories, customize icons, and organize';

  @override
  String get financialReports => 'Financial Reports';

  @override
  String get financialReportsDesc =>
      'Monthly/annual summaries, cash flow, balance sheet, export Excel & PDF';

  @override
  String get cloudSyncTitle => 'Cloud & Data Import';

  @override
  String get importWizard => 'Import Data (Notion CSV)';

  @override
  String get importWizardSubtitle =>
      'Parse relations, detect duplicates, and rollback in 1 click';

  @override
  String get googleDriveSync => 'Google Drive Sync';

  @override
  String get googleDriveSyncSubtitle =>
      'Backup and sync via your private Google Drive safely';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get transfer => 'Transfer';

  @override
  String get fromAccount => 'From Account';

  @override
  String get toAccount => 'To Account';

  @override
  String get selectAccount => 'Select Account';

  @override
  String get category => 'Category';

  @override
  String get amount => 'Amount';

  @override
  String get note => 'Note';

  @override
  String get save => 'Save';

  @override
  String get duplicateLast => 'Duplicate Last';

  @override
  String get usdAmountDestination => 'Destination Amount (USD)';

  @override
  String get remainingBudget => 'Remaining Budget This Month';

  @override
  String get netWorth => 'Net Worth';

  @override
  String get monthlyIncome => 'This Month\'s Income';

  @override
  String get netSavings => 'Net Savings';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get incomeExpenseTrends => 'Income & Expense Trends (6 Months)';

  @override
  String get availableToSpend => 'Available to spend this month';

  @override
  String get budgetRemaining => 'of monthly budget remaining';

  @override
  String get viewAll => 'View all';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get holdings => 'Holdings';

  @override
  String get realizedPnl => 'Realized P&L';

  @override
  String get history => 'Trade History';

  @override
  String get projects => 'Projects';

  @override
  String get cashAndBank => 'Cash & Bank';

  @override
  String get creditCards => 'Credit Cards';

  @override
  String get foreignCurrency => 'Foreign Currency';

  @override
  String get morningGreeting => 'Good morning ☀️';

  @override
  String get afternoonGreeting => 'Good afternoon 🌤️';

  @override
  String get eveningGreeting => 'Good evening 🌙';

  @override
  String get addExpense => '+ Add Expense';

  @override
  String get addIncome => '+ Add Income';

  @override
  String get monthlyOverview => 'Monthly Overview';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get creditCardDebt => 'Credit Card Debt';

  @override
  String get currentBillingCycle => 'Current Cycle';

  @override
  String get billedCycle => 'Billed Balance';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get confirmRestoreTitle => 'Confirm Data Restore';

  @override
  String get confirmRestoreContent =>
      'Restoring will import accounts and transactions from the backup file (.json) into this device. Do you wish to proceed?';

  @override
  String restoreSuccess(int accounts, int transactions) {
    return 'Data restored successfully: $accounts accounts, $transactions transactions';
  }

  @override
  String get exportSuccess =>
      'Backup exported successfully! You can save it to your private Google Drive.';

  @override
  String get appVersionFooter => 'OURS v1.0.0\nOur money, our journey.';

  @override
  String get masterBudget => 'MASTER BUDGET';

  @override
  String get availableToSpendLumi => 'Available to spend 🌸';

  @override
  String get availableToSpendVault => 'Available to spend';

  @override
  String daysRemainingInCycle(int days) {
    return '$days days left in cycle';
  }

  @override
  String fromBudget(String amount) {
    return 'of $amount budget';
  }

  @override
  String ofTotalMonthlyBudget(int percent) {
    return '$percent% of monthly budget remaining';
  }

  @override
  String get usedSoFar => 'Spent so far';

  @override
  String get fromTotalBudget => 'From total budget';

  @override
  String get spendingProgress => 'Spending progress';

  @override
  String percentUsed(int percent) {
    return 'Used $percent%';
  }

  @override
  String get noBudgetSet => 'No budget set this month';

  @override
  String get setBudgetAction => 'Set Budget';

  @override
  String get financialOverview => 'Financial Overview';

  @override
  String get viewMonthlyReport => 'Monthly Report';

  @override
  String get netWorthDesc => 'Net Worth (Assets - Liabilities)';

  @override
  String get monthIncome => 'Income';

  @override
  String get monthExpense => 'Expense';

  @override
  String get cashFlow => 'Cash Flow';

  @override
  String get creditCardSummary => 'Credit Cards';

  @override
  String get creditCardNoDebt => 'No balance due. Awesome! 🎉';

  @override
  String get creditCardPending => 'Pending cycle balance';

  @override
  String get noTransactionsThisMonth => 'No transactions this month';

  @override
  String get noTransactionsDesc =>
      'Start tracking by recording your first transaction';

  @override
  String get addFirstTransaction => 'Add First Transaction';

  @override
  String get searchTransactions => 'Search transactions';

  @override
  String get settingsAndSecurity => 'Settings & Security';

  @override
  String savingsRateStatus(int percent) {
    return 'Savings rate this month is $percent%';
  }

  @override
  String creditCardDueWarning(String amount) {
    return 'Credit card cycle closing soon. Pending: $amount';
  }

  @override
  String get budgetLowWarning =>
      'Monthly budget is below 20%. Please spend with caution.';

  @override
  String dailySpendRecommendation(String amount) {
    return 'Recommended daily spend: $amount until month end';
  }

  @override
  String get budgetAndProjects => 'Budget & Projects';

  @override
  String get budgetTab => 'Budget';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get expenseCategories => 'Expense Categories';

  @override
  String get incomeCategories => 'Income Categories';

  @override
  String get addNewCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get hideCategory => 'Hide Category';

  @override
  String get restoreCategory => 'Restore';

  @override
  String get defaultBadge => 'Default';

  @override
  String get monthlyBudgetTab => 'Monthly Budget';

  @override
  String get specialProjectsTab => 'Special Projects';

  @override
  String get summaryBudgetNonRollover =>
      'Monthly Budget Summary 🌸 (Non-Rollover)';

  @override
  String get budgetByCategory => 'Budget by Category';

  @override
  String get tapItemToEdit => 'Tap item to edit';

  @override
  String get budgetStatusNormal => 'Normal';

  @override
  String get budgetStatusExceeded => 'Over Budget!';

  @override
  String get budgetStatusWarning => 'Near Limit (≥ 80%)';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get confirmDeleteBudget => 'Confirm Delete Budget';

  @override
  String get leftBudget => 'Left';

  @override
  String get totalBudgetLabel => 'Total Budget';

  @override
  String get spentLabel => 'Spent';

  @override
  String get budgetLabel => 'Budget';

  @override
  String get tagline => 'Our money, our journey.';
}
