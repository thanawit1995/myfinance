import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/services/widget_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/vault_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/category_icon_helper.dart';
import '../../categories/presentation/category_form_dialog.dart';
import '../../recurring/domain/recurring_engine.dart';
import '../../import/domain/csv_import_parser.dart';

class QuickAddScreen extends ConsumerStatefulWidget {
  final String? initialType;
  final bool isModal;
  final VoidCallback? onTransactionSaved;

  const QuickAddScreen({
    super.key,
    this.initialType,
    this.isModal = false,
    this.onTransactionSaved,
  });

  @override
  ConsumerState<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends ConsumerState<QuickAddScreen> {
  static const _uuid = Uuid();

  String _transactionType = 'expense'; // 'expense', 'income', 'transfer'
  String _amountString = '0';
  String? _selectedAccountId;
  String? _selectedDestinationAccountId;
  String? _selectedCategoryId;
  String _usdAmountString = '0'; // For cross-currency transfer
  String _note = '';
  String? _tag;
  int _feeThbSatang = 0;
  DateTime _transactionDate = DateTime.now();

  List<Account> _accounts = [];
  List<Category> _currentCategories = [];
  List<Project> _projects = [];

  // Accrued income & Tax classification options
  bool _isAccruedIncome = false;
  String _accruedWorkPeriod = '';
  String _selectedTaxCategory = '40_1';
  bool _userManuallyChangedTax = false;

  Account? get _currentSourceAccount =>
      _accounts.where((a) => a.id == _selectedAccountId).firstOrNull;
  Account? get _currentDestinationAccount =>
      _accounts.where((a) => a.id == _selectedDestinationAccountId).firstOrNull;

  // Additional options: Project and Recurring
  String? _selectedProjectId;
  bool _isRecurring = false;
  String _recurringFrequency = 'monthly';
  int _recurringDayOfMonth = 1;
  int _recurringDayOfWeek = 1;
  bool _recurringAutoPost = true;
  String _recurringWorkPeriodOffset = 'prev_month'; // 'prev_month' or 'same_month'
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _usdController = TextEditingController();

  // Foreign Remittance tracking options
  int _remittanceTaxYearEarned = DateTime.now().year - 1;
  String _remittanceIncomeSourceType = 'capital_gain';

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _usdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _accruedWorkPeriod = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    if (widget.initialType != null) {
      _transactionType = widget.initialType!.toLowerCase();
    }
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final accounts = await ref.read(accountsDaoProvider).getActiveAccounts();
    final categories = await ref.read(categoriesDaoProvider).getActiveCategoriesOrderedByUsage(_transactionType);
    final projects = await ref.read(projectsDaoProvider).getActiveProjects();

    if (mounted) {
      setState(() {
        _accounts = accounts;
        _currentCategories = categories;
        _projects = projects;
        if (accounts.isNotEmpty) {
          _selectedAccountId = accounts.first.id;
          if (accounts.length > 1) {
            _selectedDestinationAccountId = accounts[1].id;
          }
        }
        if (categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
        }
        _inferTaxCategory();
      });
    }
  }

  void _inferTaxCategory([String? newNote, String? newCatId]) {
    if (_transactionType != 'income') return;
    if (_userManuallyChangedTax && newCatId == null) return;
    final noteText = (newNote ?? _noteController.text).trim();
    final catId = newCatId ?? _selectedCategoryId;
    final cat = _currentCategories.where((c) => c.id == catId).firstOrNull;

    // 1. Explicit tax type on category if set
    if (cat?.taxIncomeType != null && cat!.taxIncomeType!.isNotEmpty) {
      _selectedTaxCategory = cat.taxIncomeType!;
      return;
    }

    // 2. Keyword rules for salary, doctor fees, shift, medical practice, non-taxable
    if (cat != null) {
      final name = '${cat.nameTh} ${cat.nameEn}'.toLowerCase();
      if (name.contains('salary') ||
          name.contains('เงินเดือน') ||
          name.contains('ค่าจ้าง') ||
          name.contains('พ.ต.ส.') ||
          name.contains('p4p')) {
        _selectedTaxCategory = '40_1';
        return;
      }
      if (name.contains('เวร') ||
          name.contains('df') ||
          name.contains('doctor fee') ||
          name.contains('ไม่ทำเวช') ||
          name.contains('เบี้ยเลี้ยง') ||
          name.contains('ค่าตอบแทน') ||
          name.contains('ot')) {
        _selectedTaxCategory = '40_2';
        return;
      }
      if (name.contains('แพทย์') ||
          name.contains('วิชาชีพ') ||
          name.contains('คลินิก')) {
        _selectedTaxCategory = '40_6';
        return;
      }
      if (name.contains('top up') ||
          name.contains('โอนเงิน') ||
          name.contains('ยกเว้น') ||
          name.contains('คืนเงิน')) {
        _selectedTaxCategory = 'non_taxable';
        return;
      }
    }

    final combined = '$noteText ${cat?.nameTh ?? ""} ${cat?.nameEn ?? ""}';
    final inferred = CsvImportParser.classifyIncomeTax(
      name: combined,
      date: _transactionDate,
      amountSatang: 100000,
    );
    if (inferred.taxCategory == '40_1' ||
        inferred.taxCategory == '40_2' ||
        inferred.taxCategory == '40_6' ||
        inferred.taxCategory == '40_8' ||
        inferred.taxCategory == 'non_taxable') {
      _selectedTaxCategory = inferred.taxCategory;
    } else {
      _selectedTaxCategory = '40_1';
    }
  }

  String _formatWorkPeriodShort(String period, bool isThai) {
    final parts = period.split('-');
    if (parts.length == 2) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year != null && month != null && month >= 1 && month <= 12) {
        const thaiShortMonths = [
          'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
          'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
        ];
        const enShortMonths = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final shortYear = isThai ? (year + 543) % 100 : year % 100;
        return isThai
            ? '${thaiShortMonths[month - 1]} $shortYear'
            : '${enShortMonths[month - 1]} \'$shortYear';
      }
    }
    return period;
  }

  String _formatWorkPeriodDisplay(String period, bool isThai) {
    final parts = period.split('-');
    if (parts.length == 2) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year != null && month != null && month >= 1 && month <= 12) {
        const thaiMonths = [
          'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
          'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
        ];
        const enMonths = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        return isThai
            ? '${thaiMonths[month - 1]} $year (${year + 543})'
            : '${enMonths[month - 1]} $year';
      }
    }
    return period;
  }

  Future<void> _duplicateLastTransaction() async {
    final last = await ref.read(transactionsDaoProvider).getLastTransaction();
    if (last == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ยังไม่มีรายการล่าสุดในระบบ')),
        );
      }
      return;
    }

    setState(() {
      _transactionType = last.transactionType;
      _amountString = (last.amountOriginalSatang / 100.0).toStringAsFixed(2);
      if (_amountString.endsWith('.00')) {
        _amountString = _amountString.substring(0, _amountString.length - 3);
      }
      _amountController.text = _amountString;
      _selectedAccountId = last.sourceAccountId;
      _selectedDestinationAccountId = last.destinationAccountId;
      _selectedCategoryId = last.categoryId;
      _note = last.note ?? '';
      _noteController.text = _note;
      _tag = last.tag;
      _feeThbSatang = last.feeThbSatang;
      _transactionDate = DateTime.now();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('คัดลอกข้อมูลจากรายการล่าสุดเรียบร้อยแล้ว')),
      );
    }
  }

  Future<void> _submitTransaction() async {
    final rawAmountText = _amountController.text.trim();
    final effectiveAmountStr = rawAmountText.isNotEmpty ? rawAmountText : _amountString;
    final parsedAmount = double.tryParse(effectiveAmountStr) ?? 0.0;
    if (parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาระบุจำนวนเงินที่มากกว่า 0')),
      );
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกบัญชี')),
      );
      return;
    }

    final amountSatang = (parsedAmount * 100).round();
    final now = DateTime.now();

    final sourceAccount = await ref.read(accountsDaoProvider).getAccountById(_selectedAccountId!);
    if (sourceAccount == null) return;

    String currencyCode = sourceAccount.currencyCode;
    int amountOriginalSatang = amountSatang;
    int amountThbSatang = amountSatang;
    String fxRate = '1.000000';

    // Transfer logic
    if (_transactionType == 'transfer' && _selectedDestinationAccountId != null) {
      final destAccount = await ref.read(accountsDaoProvider).getAccountById(_selectedDestinationAccountId!);
      if (destAccount != null) {
        final srcCurrency = sourceAccount.currencyCode;
        final dstCurrency = destAccount.currencyCode;

        if (srcCurrency != dstCurrency) {
          final secondaryAmount = double.tryParse(_usdAmountString) ?? 0.0;
          if (secondaryAmount <= 0) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('กรุณาระบุจำนวนเงินปลายทาง ($dstCurrency)')),
              );
            }
            return;
          }

          if (srcCurrency == 'THB' && dstCurrency == 'USD') {
            // THB -> USD: parsedAmount is THB, secondaryAmount is USD
            currencyCode = 'USD';
            amountOriginalSatang = (secondaryAmount * 100).round(); // USD cents
            amountThbSatang = amountSatang; // THB satang from keypad
            final calculatedRate = parsedAmount / secondaryAmount;
            fxRate = calculatedRate.toStringAsFixed(6);
          } else if (srcCurrency == 'USD' && dstCurrency == 'THB') {
            // USD -> THB: parsedAmount is USD, secondaryAmount is THB (bringing money back to Thailand)
            currencyCode = 'USD';
            amountOriginalSatang = amountSatang; // USD cents from keypad
            amountThbSatang = (secondaryAmount * 100).round(); // THB satang from card
            final calculatedRate = secondaryAmount / parsedAmount;
            fxRate = calculatedRate.toStringAsFixed(6);
          } else {
            // Generic foreign currency exchange
            currencyCode = dstCurrency != 'THB' ? dstCurrency : srcCurrency;
            amountOriginalSatang = (secondaryAmount * 100).round();
            amountThbSatang = amountSatang;
            final calculatedRate = parsedAmount / secondaryAmount;
            fxRate = calculatedRate.toStringAsFixed(6);
          }
        } else if (srcCurrency == 'USD' && dstCurrency == 'USD') {
          // USD -> USD transfer
          currencyCode = 'USD';
          amountOriginalSatang = amountSatang;
          final latestRate = await ref.read(accountsDaoProvider).getLatestUsdFxRate();
          amountThbSatang = (Decimal.fromInt(amountSatang) * latestRate).round().toBigInt().toInt();
          fxRate = latestRate.toString();
        }
      }
    } else if (_transactionType != 'transfer' && sourceAccount.currencyCode == 'USD') {
      // Expense or income directly from a USD account
      currencyCode = 'USD';
      amountOriginalSatang = amountSatang;
      final latestRate = await ref.read(accountsDaoProvider).getLatestUsdFxRate();
      amountThbSatang = (Decimal.fromInt(amountSatang) * latestRate).round().toBigInt().toInt();
      fxRate = latestRate.toString();
    }

    _note = _noteController.text.trim();

    // Effective tag with optional project association & auto-deduction tags
    String? effectiveTag = _tag;
    if (_selectedProjectId != null) {
      final pTag = 'project:$_selectedProjectId';
      effectiveTag = (effectiveTag != null && effectiveTag.isNotEmpty) ? '$effectiveTag,$pTag' : pTag;
    }

    if (_transactionType == 'expense') {
      final cat = _selectedCategoryId != null
          ? _currentCategories.where((c) => c.id == _selectedCategoryId).firstOrNull
          : null;
      final catName = '${cat?.nameTh ?? ""} ${cat?.nameEn ?? ""}'.toLowerCase();
      final noteLower = _note.toLowerCase();

      final tagsList = <String>[];
      if (effectiveTag != null && effectiveTag.isNotEmpty) {
        tagsList.addAll(effectiveTag.split(',').map((t) => t.trim()));
      }

      if (catName.contains('กบข') || catName.contains('gpf') || noteLower.contains('กบข') || noteLower.contains('gpf')) {
        if (!tagsList.any((t) => t.contains('deduction:gpf'))) {
          tagsList.add('deduction:gpf');
        }
      }

      if (noteLower.contains('ประกันออมทรัพย์') || (catName.contains('ประกัน') && noteLower.contains('ออมทรัพย์'))) {
        if (!tagsList.any((t) => t.contains('deduction:life_insurance'))) {
          tagsList.add('deduction:life_insurance');
        }
      }

      effectiveTag = tagsList.isNotEmpty ? tagsList.join(',') : null;
    }

    String? taxCat;
    int whtSatang = 0;
    if (_transactionType == 'income') {
      taxCat = _selectedTaxCategory;
      if (taxCat == 'non_taxable') {
        whtSatang = 0;
      } else if (taxCat == '40_1') {
        final cat = _selectedCategoryId != null
            ? _currentCategories.where((c) => c.id == _selectedCategoryId).firstOrNull
            : null;
        final catName = '${cat?.nameTh ?? ""} ${cat?.nameEn ?? ""}'.toLowerCase();
        final noteLower = _note.toLowerCase();
        final isJuly2026OrLater = _transactionDate.year > 2026 ||
            (_transactionDate.year == 2026 && _transactionDate.month >= 7);

        if ((catName.contains('p4p') || catName.contains('พ.ต.ส.') || catName.contains('พตส') ||
             noteLower.contains('p4p') || noteLower.contains('พ.ต.ส.') || noteLower.contains('พตส')) &&
            isJuly2026OrLater) {
          whtSatang = (amountThbSatang * 5) ~/ 100;
        }
      }
    }

    final isAccrued = _transactionType == 'income' && _isAccruedIncome;

    final newTx = TransactionsCompanion.insert(
      id: _uuid.v4(),
      transactionType: _transactionType,
      sourceAccountId: Value(_selectedAccountId),
      destinationAccountId: _transactionType == 'transfer' ? Value(_selectedDestinationAccountId) : const Value(null),
      categoryId: _transactionType != 'transfer' ? Value(_selectedCategoryId) : const Value(null),
      amountOriginalSatang: amountOriginalSatang,
      currencyCode: currencyCode,
      fxRate: Value(fxRate),
      amountThbSatang: amountThbSatang,
      feeThbSatang: Value(_feeThbSatang),
      taxCategory: Value(taxCat),
      withholdingTaxSatang: Value(whtSatang),
      tag: Value(effectiveTag),
      transactionDate: _transactionDate,
      workPeriod: Value(isAccrued ? _accruedWorkPeriod : null),
      expectedAmountSatang: Value(isAccrued ? amountThbSatang : null),
      isCleared: Value(!isAccrued),
      note: Value(_note.isEmpty ? null : _note),
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(transactionsDaoProvider).insertTransaction(newTx);

    // If this is an offshore -> domestic transfer, sync remittance with custom options
    if (_transactionType == 'transfer') {
      final insertedTx = await ref.read(transactionsDaoProvider).getTransactionById(newTx.id.value);
      if (insertedTx != null) {
        await ref.read(remittancesDaoProvider).syncFromTransferTransaction(
          insertedTx,
          taxYearEarned: _remittanceTaxYearEarned,
          incomeSourceType: _remittanceIncomeSourceType,
        );
      }
    }

    // If recurring is checked, create recurring rule
    if (_isRecurring) {
      final nextRunDate = RecurringEngine.computeNextRunDate(
        frequency: _recurringFrequency,
        intervalUnits: 1,
        dayOfMonth: _recurringDayOfMonth,
        fromDate: _transactionDate,
      );

      final title = _note.isNotEmpty
          ? _note
          : 'รายการ${_formatType(_transactionType)}ประจำ (${Money(amountThbSatang).format(symbol: '฿')})';

      String? ruleNote = _note.isNotEmpty ? _note : null;
      if (_transactionType == 'income') {
        final metaTags = [
          '[work_period:$_recurringWorkPeriodOffset]',
          '[tax_cat:$_selectedTaxCategory]',
          if (_isAccruedIncome) '[accrued]',
        ].join(' ');
        ruleNote = ruleNote != null ? '$ruleNote $metaTags' : metaTags;
      }

      await ref.read(recurringTransactionsDaoProvider).createRule(
        RecurringRulesCompanion.insert(
          id: _uuid.v4(),
          title: title,
          transactionType: _transactionType,
          sourceAccountId: _selectedAccountId!,
          destinationAccountId: _transactionType == 'transfer' ? Value(_selectedDestinationAccountId) : const Value(null),
          categoryId: _transactionType != 'transfer' ? Value(_selectedCategoryId) : const Value(null),
          amountSatang: amountSatang,
          currencyCode: currencyCode,
          frequency: _recurringFrequency,
          intervalUnits: const Value(1),
          dayOfMonth: Value(_recurringFrequency == 'monthly' ? _recurringDayOfMonth : null),
          nextRunDate: nextRunDate,
          autoPost: Value(_recurringAutoPost),
          isActive: const Value(true),
          note: Value(ruleNote),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    // Update Widget
    _updateWidget();

    if (mounted) {
      final isThai = Localizations.localeOf(context).languageCode == 'th';
      final srcAcc = _currentSourceAccount;
      final srcCurrency = srcAcc?.currencyCode ?? 'THB';
      final srcSymbol = srcCurrency == 'USD' ? '\$' : (srcCurrency == 'THB' ? '฿' : '$srcCurrency ');
      final recurringMsg = _isRecurring ? (isThai ? ' และตั้งรายการประจำแล้ว' : ' and recurring schedule set') : '';
      final accruedMsg = isAccrued ? (isThai ? ' (บันทึกเป็นรายได้ค้างรับรอบ ${_formatWorkPeriodDisplay(_accruedWorkPeriod, isThai)})' : ' (Accrued income for $_accruedWorkPeriod)') : '';
      final typeText = _formatType(_transactionType, isThai);
      final successMsg = isThai
          ? 'บันทึกรายการ $typeText $srcSymbol$_amountString สำเร็จ$recurringMsg$accruedMsg'
          : 'Successfully saved $typeText $srcSymbol$_amountString$recurringMsg$accruedMsg';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMsg),
          backgroundColor: VaultTheme.positive(context),
          action: SnackBarAction(
            label: isThai ? 'บันทึกรายการเดิมอีกครั้ง' : 'Duplicate Last',
            textColor: Colors.white,
            onPressed: _duplicateLastTransaction,
          ),
        ),
      );

      widget.onTransactionSaved?.call();
      if (widget.isModal && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        // Reset amount and additional options
        setState(() {
          _amountString = '0';
          _amountController.clear();
          _usdAmountString = '0';
          _note = '';
          _noteController.clear();
          _tag = null;
          _feeThbSatang = 0;
          _selectedProjectId = null;
          _isRecurring = false;
          _isAccruedIncome = false;
          _recurringWorkPeriodOffset = 'prev_month';
          _userManuallyChangedTax = false;
        });
      }
    }
  }

  Future<void> _updateWidget() async {
    final now = DateTime.now();
    final budgets = await ref.read(budgetsDaoProvider).getBudgetStatusForMonth(now.year, now.month);
    int totalBudget = 0;
    int totalSpent = 0;

    for (final b in budgets) {
      totalBudget += b.limitSatang;
      totalSpent += b.spentSatang;
    }

    final remaining = (totalBudget - totalSpent).clamp(0, totalBudget);
    final monthNames = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    final monthName = '${monthNames[now.month - 1]} ${now.year}';

    await WidgetService.updateWidgetData(
      remainingSatang: remaining,
      spentSatang: totalSpent,
      budgetSatang: totalBudget,
      monthName: monthName,
    );
  }

  String _formatType(String type, [bool isThai = true]) {
    switch (type) {
      case 'expense':
        return isThai ? 'รายจ่าย' : 'Expense';
      case 'income':
        return isThai ? 'รายรับ' : 'Income';
      case 'transfer':
        return isThai ? 'โอนเงิน' : 'Transfer';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    final amountBgColor = isDark
        ? const Color(0xFF1E293B)
        : (_transactionType == 'expense'
            ? const Color(0xFFFEF2F2)
            : (_transactionType == 'income' ? const Color(0xFFECFDF5) : const Color(0xFFEEF2FF)));
    final amountBorderColor = isDark
        ? const Color(0xFF334155)
        : (_transactionType == 'expense'
            ? const Color(0xFFFECACA)
            : (_transactionType == 'income' ? const Color(0xFFA7F3D0) : const Color(0xFFC7D2FE)));
    final amountTextColor = _transactionType == 'expense'
        ? AppTheme.expenseColor(context)
        : (_transactionType == 'income' ? AppTheme.incomeColor(context) : AppTheme.transferColor(context));

    final srcAcc = _currentSourceAccount;
    final srcCurrency = srcAcc?.currencyCode ?? 'THB';
    final srcSymbol = srcCurrency == 'USD' ? '\$ ' : (srcCurrency == 'THB' ? '฿ ' : '$srcCurrency ');

    return Scaffold(
      appBar: AppBar(
        leading: widget.isModal
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(l10n?.quickAddKeypad ?? (isThai ? 'บันทึกด่วน' : 'Quick Add')),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.history, size: 18),
            label: Text(l10n?.duplicateLast ?? (isThai ? 'ทำซ้ำล่าสุด' : 'Repeat Last')),
            onPressed: _duplicateLastTransaction,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // 1. Transaction Type Segmented Buttons
            SizedBox(
              height: 38,
              width: double.infinity,
              child: SegmentedButton<String>(
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                segments: [
                  ButtonSegment(value: 'expense', label: Text(l10n?.expense ?? (isThai ? 'รายจ่าย' : 'Expense'), style: const TextStyle(fontSize: 13)), icon: const Icon(Icons.remove_circle_outline, size: 16)),
                  ButtonSegment(value: 'income', label: Text(l10n?.income ?? (isThai ? 'รายรับ' : 'Income'), style: const TextStyle(fontSize: 13)), icon: const Icon(Icons.add_circle_outline, size: 16)),
                  ButtonSegment(value: 'transfer', label: Text(l10n?.transfer ?? (isThai ? 'โอนเงิน' : 'Transfer'), style: const TextStyle(fontSize: 13)), icon: const Icon(Icons.swap_horiz, size: 16)),
                ],
                selected: {_transactionType},
                onSelectionChanged: (newVal) async {
                  final newType = newVal.first;
                  final cats = await ref.read(categoriesDaoProvider).getActiveCategoriesOrderedByUsage(newType);
                  if (mounted) {
                    setState(() {
                      _transactionType = newType;
                      _currentCategories = cats;
                      _selectedCategoryId = cats.isNotEmpty ? cats.first.id : null;
                      _userManuallyChangedTax = false;
                      _inferTaxCategory();
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // 2. Big Amount Display (Interactive Modern Native Numeric Input)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: amountBgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: amountBorderColor, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_transactionType == 'transfer')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        isThai ? 'จำนวนเงินที่โอนออก ($srcCurrency)' : 'Transfer Out Amount ($srcCurrency)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    )
                  else if (srcCurrency != 'THB')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        isThai ? 'สกุลเงิน $srcCurrency' : 'Currency: $srcCurrency',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        srcSymbol.trim(),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: amountTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 80, maxWidth: 260),
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: amountTextColor,
                            ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: amountTextColor.withValues(alpha: 0.35),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) {
                              setState(() {
                                _amountString = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. Category & Account & Note Fields based on Type
            if (_transactionType == 'transfer') ...[
              _buildTransferAccountsRow(theme, isThai),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: isThai ? 'ชื่อรายการ / บันทึกย่อ' : 'Title / Note',
                  hintText: isThai ? 'บันทึกช่วยจำ' : 'Note',
                  prefixIcon: const Icon(Icons.edit_note_outlined, size: 20),
                  prefixIconConstraints: const BoxConstraints(minWidth: 36),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                ),
              ),
              const SizedBox(height: 12),
              _buildCrossCurrencyTransferCard(theme),
              _buildRemittanceSection(theme),
            ] else ...[
              // Expense & Income: Category Dropdown (with + Add New inside)
              _buildCategoryDropdown(theme, isThai),
              const SizedBox(height: 12),
              // Row: Note (flex 3) + Account (flex 2)
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: isThai ? 'ชื่อรายการ / บันทึก' : 'Title / Note',
                        hintText: isThai ? 'เช่น เงินเดือน, กาแฟ' : 'e.g. Salary, Coffee',
                        prefixIcon: const Icon(Icons.edit_note_outlined, size: 20),
                        prefixIconConstraints: const BoxConstraints(minWidth: 36),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      ),
                      onChanged: (val) {
                        if (_transactionType == 'income') {
                          setState(() {
                            _inferTaxCategory(val, _selectedCategoryId);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _buildAccountDropdownCompact(theme, isThai),
                  ),
                ],
              ),
              if (_transactionType == 'income') ...[
                const SizedBox(height: 12),
                // Income: Row: Tax Dropdown (flex 3) + Compact Accrued Button (flex 2)
                _buildIncomeTaxAndAccruedRow(theme, isThai),
              ],
              const SizedBox(height: 12),
            ],

            // 4. Additional Options (Project, Recurring)
            _buildAdditionalOptions(theme),
            const SizedBox(height: 16),

            // 5. Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _transactionType == 'expense'
                      ? Colors.red.shade700
                      : (_transactionType == 'income' ? Colors.green.shade700 : Colors.blue.shade700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check, size: 20),
                label: Text(
                  isThai ? 'บันทึกรายการ' : 'Save Transaction',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _submitTransaction,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme, bool isThai) {
    final validSelectedId = _currentCategories.any((c) => c.id == _selectedCategoryId)
        ? _selectedCategoryId
        : (_currentCategories.isNotEmpty ? _currentCategories.first.id : null);

    return DropdownButtonFormField<String>(
      key: ValueKey('cat_dropdown_${_transactionType}_$validSelectedId'),
      decoration: InputDecoration(
        labelText: isThai ? 'หมวดหมู่ (Category)' : 'Category',
        prefixIcon: const Icon(Icons.category_outlined, size: 20),
        prefixIconConstraints: const BoxConstraints(minWidth: 36),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      initialValue: validSelectedId,
      isExpanded: true,
      menuMaxHeight: 280,
      items: [
        ..._currentCategories.map((cat) {
          final displayName = isThai
              ? cat.nameTh
              : (cat.nameEn.trim().isNotEmpty ? cat.nameEn : cat.nameTh);
          return DropdownMenuItem<String>(
            value: cat.id,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CategoryIconHelper.getIcon(cat.icon), size: 18),
                const SizedBox(width: 8),
                Flexible(child: Text(displayName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
              ],
            ),
          );
        }),
        DropdownMenuItem<String>(
          value: '__ADD_NEW__',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                isThai ? '+ เพิ่มหมวดหมู่ใหม่...' : '+ Add New Category...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
      onChanged: (val) async {
        if (val == '__ADD_NEW__') {
          final newCat = await CategoryFormDialog.show(
            context,
            initialType: _transactionType,
          );
          if (newCat != null && mounted) {
            final updatedCats = await ref.read(categoriesDaoProvider).getActiveCategoriesOrderedByUsage(_transactionType);
            setState(() {
              _currentCategories = updatedCats;
              _selectedCategoryId = newCat.id;
              _userManuallyChangedTax = false;
              if (_transactionType == 'income') {
                _inferTaxCategory(_noteController.text, newCat.id);
              }
            });
          } else {
            setState(() {});
          }
        } else if (val != null) {
          setState(() {
            _selectedCategoryId = val;
            _userManuallyChangedTax = false;
            if (_transactionType == 'income') {
              _inferTaxCategory(_noteController.text, val);
            }
          });
        }
      },
    );
  }

  Widget _buildAccountDropdownCompact(ThemeData theme, bool isThai) {
    final validAccountId = _accounts.any((a) => a.id == _selectedAccountId)
        ? _selectedAccountId
        : (_accounts.isNotEmpty ? _accounts.first.id : null);

    return DropdownButtonFormField<String>(
      key: ValueKey('account_compact_$validAccountId'),
      initialValue: validAccountId,
      isExpanded: true,
      menuMaxHeight: 250,
      decoration: InputDecoration(
        labelText: isThai ? 'บัญชี' : 'Account',
        prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
        prefixIconConstraints: const BoxConstraints(minWidth: 32),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      ),
      items: _accounts.map((a) => DropdownMenuItem(
        value: a.id,
        child: Text(
          '${a.name} (${a.currencyCode})',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
      )).toList(),
      onChanged: (val) => setState(() => _selectedAccountId = val),
    );
  }

  Widget _buildTransferAccountsRow(ThemeData theme, bool isThai) {
    final destAccounts = _accounts.where((a) => a.id != _selectedAccountId).toList();
    final effectiveDestId = destAccounts.any((a) => a.id == _selectedDestinationAccountId)
        ? _selectedDestinationAccountId
        : (destAccounts.isNotEmpty ? destAccounts.first.id : null);

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            key: ValueKey('transfer_src_$_selectedAccountId'),
            initialValue: _selectedAccountId,
            isExpanded: true,
            menuMaxHeight: 250,
            decoration: InputDecoration(
              labelText: isThai ? 'จากบัญชี' : 'From',
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            ),
            items: _accounts.map((a) => DropdownMenuItem(
              value: a.id,
              child: Text('${a.name} (${a.currencyCode})', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
            )).toList(),
            onChanged: (val) {
              setState(() {
                _selectedAccountId = val;
                if (_selectedDestinationAccountId == val) {
                  final remaining = _accounts.where((a) => a.id != val).toList();
                  _selectedDestinationAccountId = remaining.isNotEmpty ? remaining.first.id : null;
                }
              });
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.arrow_forward, size: 18),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            key: ValueKey('transfer_dest_$effectiveDestId'),
            initialValue: effectiveDestId,
            isExpanded: true,
            menuMaxHeight: 250,
            decoration: InputDecoration(
              labelText: isThai ? 'ไปยังบัญชี' : 'To',
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            ),
            items: destAccounts.map((a) => DropdownMenuItem(
              value: a.id,
              child: Text('${a.name} (${a.currencyCode})', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
            )).toList(),
            onChanged: (val) => setState(() => _selectedDestinationAccountId = val),
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeTaxAndAccruedRow(ThemeData theme, bool isThai) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            key: ValueKey('tax_cat_$_selectedTaxCategory'),
            initialValue: _selectedTaxCategory,
            isExpanded: true,
            menuMaxHeight: 250,
            decoration: InputDecoration(
              labelText: isThai ? 'ประเภทภาษี' : 'Tax Type',
              prefixIcon: const Icon(Icons.receipt_long_outlined, size: 18),
              prefixIconConstraints: const BoxConstraints(minWidth: 32),
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            ),
            items: [
              DropdownMenuItem(
                value: '40_1',
                child: Text(isThai ? '40(1) เงินเดือน / พ.ต.ส.' : '40(1) Salary', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
              ),
              DropdownMenuItem(
                value: '40_2',
                child: Text(isThai ? '40(2) ค่าเวร / เบี้ยเลี้ยง' : '40(2) Shift/DF', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
              ),
              DropdownMenuItem(
                value: '40_6',
                child: Text(isThai ? '40(6) วิชาชีพแพทย์' : '40(6) Medical', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
              ),
              DropdownMenuItem(
                value: '40_8',
                child: Text(isThai ? '40(8) อื่นๆ' : '40(8) Other', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
              ),
              DropdownMenuItem(
                value: 'non_taxable',
                child: Text(isThai ? 'ยกเว้นภาษี' : 'Non-taxable', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedTaxCategory = val;
                  _userManuallyChangedTax = true;
                });
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: _buildCompactAccruedButton(theme, isThai),
        ),
      ],
    );
  }

  Widget _buildCompactAccruedButton(ThemeData theme, bool isThai) {
    if (!_isAccruedIncome) {
      return SizedBox(
        height: 46,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          icon: const Icon(Icons.schedule, size: 16),
          label: Text(
            isThai ? 'ค้างรับ/ตกเบิก' : 'Accrued',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5),
          ),
          onPressed: () {
            setState(() {
              _isAccruedIncome = true;
              _recurringWorkPeriodOffset = 'prev_month';
            });
          },
        ),
      );
    }

    final displayText = _formatWorkPeriodShort(_accruedWorkPeriod, isThai);

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        border: Border.all(color: theme.colorScheme.primary, width: 1.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () async {
                final parts = _accruedWorkPeriod.split('-');
                final curYear = parts.length == 2 ? int.tryParse(parts[0]) ?? DateTime.now().year : DateTime.now().year;
                final curMonth = parts.length == 2 ? int.tryParse(parts[1]) ?? DateTime.now().month : DateTime.now().month;
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(curYear, curMonth),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _accruedWorkPeriod = '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
                  });
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hourglass_top, size: 13, color: theme.colorScheme.primary),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      displayText,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, size: 14, color: theme.colorScheme.primary),
                ],
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _isAccruedIncome = false;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close, size: 15, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions(ThemeData theme) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Icon(
          Icons.tune,
          size: 18,
          color: (_isRecurring || _selectedProjectId != null)
              ? theme.colorScheme.primary
              : null,
        ),
        title: Text(
          isThai ? 'ตัวเลือกเพิ่มเติม (โครงการ, รายการประจำ)' : 'Additional Options (Project, Recurring)',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: (_isRecurring || _selectedProjectId != null) ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: (_isRecurring || _selectedProjectId != null)
            ? Text(
                '${_selectedProjectId != null ? (isThai ? "มีโครงการ " : "Project linked ") : ""}${_isRecurring ? (isThai ? "(รายการประจำ)" : "(Recurring)") : ""}',
                style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
              )
            : null,
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          // Project Selector (Header separated above dropdown so popup overlay never obscures the title!)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isThai ? 'โครงการพิเศษ (Special Project)' : 'Special Project',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String?>(
                isExpanded: true,
                menuMaxHeight: 220,
                decoration: InputDecoration(
                  hintText: isThai ? 'เลือกโครงการ (หรือไม่ระบุ)' : 'Select Project (or none)',
                  prefixIcon: const Icon(Icons.folder_special_outlined, size: 18),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                initialValue: _selectedProjectId,
                items: [
                  DropdownMenuItem(value: null, child: Text(isThai ? 'ไม่ระบุโครงการ' : 'No Project', style: const TextStyle(fontSize: 13))),
                  ..._projects.map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                      )),
                ],
                onChanged: (val) => setState(() => _selectedProjectId = val),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Recurring Options Box
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  dense: true,
                  title: Text(isThai ? 'ตั้งเป็นรายการประจำ (Recurring)' : 'Recurring Transaction', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(isThai ? 'บันทึกซ้ำอัตโนมัติตามรอบที่กำหนด' : 'Repeat transaction on schedule', style: const TextStyle(fontSize: 11)),
                  value: _isRecurring,
                  onChanged: (val) => setState(() => _isRecurring = val ?? false),
                ),
                if (_isRecurring) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          menuMaxHeight: 200,
                          decoration: InputDecoration(
                            labelText: isThai ? 'ความถี่ (Frequency)' : 'Frequency',
                            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          initialValue: _recurringFrequency,
                          items: [
                            DropdownMenuItem(value: 'daily', child: Text(isThai ? 'ทุกวัน (Daily)' : 'Daily', style: const TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'weekly', child: Text(isThai ? 'ทุกสัปดาห์ (Weekly)' : 'Weekly', style: const TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'monthly', child: Text(isThai ? 'ทุกเดือน (Monthly)' : 'Monthly', style: const TextStyle(fontSize: 12))),
                          ],
                          onChanged: (val) => setState(() => _recurringFrequency = val ?? 'monthly'),
                        ),
                        const SizedBox(height: 8),
                        if (_recurringFrequency == 'monthly')
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            menuMaxHeight: 200,
                            decoration: InputDecoration(
                              labelText: isThai ? 'ทุกวันที่ของเดือน' : 'Day of Month',
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            initialValue: _recurringDayOfMonth,
                            items: List.generate(31, (i) => i + 1)
                                .map((day) => DropdownMenuItem(value: day, child: Text(isThai ? 'วันที่ $day ของทุกเดือน' : 'Day $day of month', style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (val) => setState(() => _recurringDayOfMonth = val ?? 1),
                          ),
                        if (_recurringFrequency == 'weekly')
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            menuMaxHeight: 200,
                            decoration: InputDecoration(
                              labelText: isThai ? 'ทุกวันในสัปดาห์' : 'Day of Week',
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            initialValue: _recurringDayOfWeek,
                            items: [
                              DropdownMenuItem(value: 1, child: Text(isThai ? 'วันจันทร์' : 'Monday', style: const TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 2, child: Text(isThai ? 'วันอังคาร' : 'Tuesday', style: const TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 3, child: Text(isThai ? 'วันพุธ' : 'Wednesday', style: const TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 4, child: Text(isThai ? 'วันพฤหัสบดี' : 'Thursday', style: const TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 5, child: Text(isThai ? 'วันศุกร์' : 'Friday', style: const TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 6, child: Text(isThai ? 'วันเสาร์' : 'Saturday', style: const TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 7, child: Text(isThai ? 'วันอาทิตย์' : 'Sunday', style: const TextStyle(fontSize: 12))),
                            ],
                            onChanged: (val) => setState(() => _recurringDayOfWeek = val ?? 1),
                          ),
                        if (_transactionType == 'income') ...[
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            menuMaxHeight: 200,
                            decoration: InputDecoration(
                              labelText: isThai ? 'รอบเดือนทำงาน (Work Period)' : 'Work Period Reference',
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            initialValue: _recurringWorkPeriodOffset,
                            items: [
                              DropdownMenuItem(
                                value: 'prev_month',
                                child: Text(
                                  isThai ? 'เดือนก่อนหน้า (N - 1) เช่น ค่าเวร, ค่าตอบแทนพิเศษ' : 'Previous Month (N - 1)',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'same_month',
                                child: Text(
                                  isThai ? 'เดือนเดียวกัน (เดือนปัจจุบัน) เช่น เงินเดือน' : 'Same Month (Current Month)',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _recurringWorkPeriodOffset = val);
                              }
                            },
                          ),
                        ],
                        const SizedBox(height: 6),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(isThai ? 'บันทึกรายการอัตโนมัติ (Auto-post)' : 'Auto-post Transaction', style: const TextStyle(fontSize: 12)),
                          subtitle: Text(isThai ? 'บันทึกเข้าบัญชีทันทีเมื่อถึงกำหนด' : 'Post automatically on due date', style: const TextStyle(fontSize: 10.5)),
                          value: _recurringAutoPost,
                          onChanged: (val) => setState(() => _recurringAutoPost = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrossCurrencyTransferCard(ThemeData theme) {
    return FutureBuilder<List<Account>>(
      future: ref.read(accountsDaoProvider).getActiveAccounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        final accounts = snapshot.data!;
        _accounts = accounts;
        final srcAcc = _currentSourceAccount;
        final dstAcc = _currentDestinationAccount;

        final dstCurrency = dstAcc?.currencyCode ?? 'THB';
        final srcCurrency = srcAcc?.currencyCode ?? 'THB';

        // Show only if cross-currency
        if (srcCurrency == dstCurrency) {
          return const SizedBox.shrink();
        }

        final isThai = Localizations.localeOf(context).languageCode == 'th';
        final isDark = theme.brightness == Brightness.dark;
        final parsedSrc = double.tryParse(_amountString) ?? 0.0;
        final parsedDst = double.tryParse(_usdAmountString) ?? 0.0;
        String fxHint = '';
        if (parsedSrc > 0 && parsedDst > 0) {
          if (srcCurrency == 'THB' && dstCurrency == 'USD') {
            final rate = parsedSrc / parsedDst; // THB / USD
            fxHint = isThai ? 'อัตราแลกเปลี่ยนโดยประมาณ: 1 USD ≈ ${rate.toStringAsFixed(2)} THB' : 'Approx. Exchange Rate: 1 USD ≈ ${rate.toStringAsFixed(2)} THB';
          } else if (srcCurrency == 'USD' && dstCurrency == 'THB') {
            final rate = parsedDst / parsedSrc; // THB / USD
            fxHint = isThai ? 'อัตราแลกเปลี่ยนโดยประมาณ: 1 USD ≈ ${rate.toStringAsFixed(2)} THB' : 'Approx. Exchange Rate: 1 USD ≈ ${rate.toStringAsFixed(2)} THB';
          } else {
            final rate = parsedSrc / parsedDst;
            fxHint = isThai ? 'อัตราแลกเปลี่ยนโดยประมาณ: 1 $dstCurrency ≈ ${rate.toStringAsFixed(2)} $srcCurrency' : 'Approx. Exchange Rate: 1 $dstCurrency ≈ ${rate.toStringAsFixed(2)} $srcCurrency';
          }
        }

        final cardTitle = dstCurrency == 'THB'
            ? (isThai ? 'ยอดเงินบาทปลายทางที่ได้รับ (THB)' : 'Destination Amount Received (THB)')
            : (isThai ? 'ยอดเงินปลายทาง ($dstCurrency)' : 'Destination Amount ($dstCurrency)');
        final prefixSymbol = dstCurrency == 'USD' ? '\$ ' : (dstCurrency == 'THB' ? '฿ ' : '$dstCurrency ');

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFF818CF8).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE0E7FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.currency_exchange,
                      size: 18,
                      color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4338CA),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cardTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF312E81),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFC7D2FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dstCurrency,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF3730A3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _usdController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Text(
                      prefixSymbol,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4338CA),
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFC7D2FE),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFC7D2FE),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4338CA),
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _usdAmountString = val;
                  });
                },
              ),
              if (fxHint.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  fxHint,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRemittanceSection(ThemeData theme) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        ref.read(accountsDaoProvider).getActiveAccounts(),
        ref.read(remittancesDaoProvider).getRemainingForeignPrincipalSatang(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final accounts = snapshot.data![0] as List<Account>;
        final remainingPrincipalSatang = snapshot.data![1] as int;

        Account? src;
        Account? dst;
        for (final a in accounts) {
          if (a.id == _selectedAccountId) src = a;
          if (a.id == _selectedDestinationAccountId) dst = a;
        }

        final isOffshoreToDomestic = src != null && dst != null && (!src.isDomestic && dst.isDomestic);

        if (!isOffshoreToDomestic) {
          return const SizedBox.shrink();
        }

        final isThai = Localizations.localeOf(context).languageCode == 'th';
        final currentAmount = double.tryParse(_amountString) ?? 0.0;
        final secondaryAmount = double.tryParse(_usdAmountString) ?? 0.0;
        final currentAmountThbSatang = src.currencyCode != 'THB'
            ? (secondaryAmount > 0 ? (secondaryAmount * 100).round() : (currentAmount * 35.0 * 100).round())
            : (currentAmount * 100).round();

        final isWithinPrincipal = remainingPrincipalSatang >= currentAmountThbSatang;
        final currentYear = DateTime.now().year;
        final yearList = List.generate(currentYear - 2020 + 1, (i) => currentYear - i);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flight_land, color: isDark ? const Color(0xFF818CF8) : Colors.blue.shade800, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isThai ? 'ตรวจพบ: นำเงินต่างประเทศเข้าไทย (Foreign Remittance)' : 'Detected: Foreign Remittance into Thailand',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF8FAFC) : Colors.blue.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Remaining Principal FIFO display
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isThai ? 'เงินต้นลงทุนต่างประเทศคงเหลือ:' : 'Remaining Foreign Principal:',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.black87,
                          ),
                        ),
                        Text(
                          Money(remainingPrincipalSatang).format(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF818CF8) : Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isWithinPrincipal
                          ? (isThai
                              ? '✓ อยู่ในวงเงินต้น — ตัดเงินต้นเดิมตาม FIFO อัตโนมัติ (ได้รับยกเว้นภาษี)'
                              : '✓ Within principal limit — deducts original principal via FIFO (Tax Exempt)')
                          : (isThai
                              ? '⚠️ ยอดโอนเกินเงินต้นคงเหลือ — ส่วนเกินจะถือเป็นกำไรตามเกณฑ์ FIFO'
                              : '⚠️ Transfer exceeds remaining principal — excess is treated as assessable gain via FIFO'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isWithinPrincipal
                            ? (isDark ? const Color(0xFF34D399) : Colors.green.shade800)
                            : (isDark ? const Color(0xFFFB923C) : Colors.deepOrange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: isThai ? 'ปีที่เกิดเงินได้ (กรณีเป็นกำไร)' : 'Tax Year Earned (if gain)',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      initialValue: _remittanceTaxYearEarned > currentYear ? currentYear : _remittanceTaxYearEarned,
                      items: yearList.map((yr) => DropdownMenuItem(
                        value: yr,
                        child: Text(isThai ? 'ปี $yr (พ.ศ. ${yr + 543})' : 'Year $yr (B.E. ${yr + 543})'),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _remittanceTaxYearEarned = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: isThai ? 'ประเภทเงินได้' : 'Income Type',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      initialValue: _remittanceIncomeSourceType,
                      items: [
                        DropdownMenuItem(value: 'capital_gain', child: Text(isThai ? 'กำไรลงทุน' : 'Capital Gain')),
                        DropdownMenuItem(value: 'dividend', child: Text(isThai ? 'เงินปันผล' : 'Dividend')),
                        DropdownMenuItem(value: 'salary', child: Text(isThai ? 'เงินเดือน' : 'Salary')),
                        DropdownMenuItem(value: 'savings_principal', child: Text(isThai ? 'เงินเก็บ' : 'Savings Principal')),
                        DropdownMenuItem(value: 'other', child: Text(isThai ? 'อื่นๆ' : 'Other')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _remittanceIncomeSourceType = val);
                      },
                    ),
                  ),
                ],
              ),
              if (_remittanceTaxYearEarned < 2024)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    isThai
                        ? '✓ ได้รับยกเว้นภาษีตามคำสั่ง ป.162/2566 (เงินได้เกิดก่อน 1 ม.ค. 2024)'
                        : '✓ Tax exempt per Paw.162/2566 (earned before Jan 1, 2024)',
                    style: TextStyle(fontSize: 11, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

