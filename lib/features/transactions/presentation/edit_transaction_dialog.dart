import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/transactions_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/services/widget_service.dart';
import '../../../../core/theme/vault_theme.dart';
import '../../../../core/widgets/category_icon_helper.dart';
import '../../categories/presentation/category_picker_sheet.dart';

class EditTransactionDialog extends ConsumerStatefulWidget {
  final Transaction transaction;

  const EditTransactionDialog({super.key, required this.transaction});

  static Future<bool?> show(BuildContext context, Transaction transaction) {
    return showDialog<bool>(
      context: context,
      builder: (context) => EditTransactionDialog(transaction: transaction),
    );
  }

  @override
  ConsumerState<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends ConsumerState<EditTransactionDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _sourceAmountController;
  late TextEditingController _destinationAmountController;
  late TextEditingController _noteController;
  late TextEditingController _tagController;
  late TextEditingController _feeController;
  late TextEditingController _whtController;

  late String _transactionType;
  late String? _selectedAccountId;
  late String? _selectedDestinationAccountId;
  late String? _selectedCategoryId;
  late String? _selectedTaxCategory;
  late DateTime _transactionDate;
  String? _workPeriod;
  bool _isCleared = true;

  List<String> _systemTags = [];
  List<Account> _accounts = [];
  bool _loadingAccounts = true;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _transactionType = tx.transactionType;
    _selectedAccountId = tx.sourceAccountId ?? tx.destinationAccountId;
    _selectedDestinationAccountId = tx.destinationAccountId ?? tx.sourceAccountId;
    _selectedCategoryId = tx.categoryId;
    _selectedTaxCategory = tx.taxCategory;
    _transactionDate = tx.transactionDate;
    _workPeriod = tx.workPeriod;
    _isCleared = tx.isCleared;

    // Filter system tags from user-editable tag input so user doesn't accidentally delete internal keys
    final rawTag = tx.tag ?? '';
    final allTags = rawTag.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    final userTags = <String>[];
    _systemTags = [];
    for (final t in allTags) {
      if (t.startsWith('project:') ||
          t.startsWith('policy:') ||
          t.startsWith('deduction:') ||
          t.startsWith('investment_buy:') ||
          t.startsWith('investment_sell:') ||
          t.startsWith('investment_income:') ||
          t.startsWith('recurring_auto') ||
          t.startsWith('historical_settle') ||
          t.startsWith('debt_payment:') ||
          t.startsWith('รายได้ ') ||
          t.startsWith('รายได้รอบ ')) {
        if (!t.startsWith('รายได้ ') && !t.startsWith('รายได้รอบ ')) {
          _systemTags.add(t);
        }
      } else {
        userTags.add(t);
      }
    }
    _tagController = TextEditingController(text: userTags.join(', '));
    _noteController = TextEditingController(text: tx.note ?? '');

    final amountDouble = tx.amountOriginalSatang / 100.0;
    _sourceAmountController = TextEditingController(
      text: amountDouble.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), ''),
    );
    _destinationAmountController = TextEditingController();

    final feeDouble = tx.feeThbSatang / 100.0;
    _feeController = TextEditingController(
      text: feeDouble > 0 ? feeDouble.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '') : '',
    );
    final whtDouble = tx.withholdingTaxSatang / 100.0;
    _whtController = TextEditingController(
      text: whtDouble > 0 ? whtDouble.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '') : '',
    );

    _sourceAmountController.addListener(() => setState(() {}));
    _destinationAmountController.addListener(() => setState(() {}));

    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accs = await ref.read(accountsDaoProvider).getActiveAccounts();
    if (!mounted) return;
    setState(() {
      _accounts = accs;
      _loadingAccounts = false;

      final tx = widget.transaction;
      if (tx.transactionType == 'transfer') {
        final src = accs.where((a) => a.id == _selectedAccountId).firstOrNull;
        final dst = accs.where((a) => a.id == _selectedDestinationAccountId).firstOrNull;
        if (src?.currencyCode == 'THB' && dst?.currencyCode == 'USD') {
          _sourceAmountController.text = (tx.amountThbSatang / 100.0).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
          _destinationAmountController.text = (tx.amountOriginalSatang / 100.0).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
        } else if (src?.currencyCode == 'USD' && dst?.currencyCode == 'THB') {
          _sourceAmountController.text = (tx.amountOriginalSatang / 100.0).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
          _destinationAmountController.text = (tx.amountThbSatang / 100.0).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
        } else {
          _sourceAmountController.text = (tx.amountOriginalSatang / 100.0).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
          _destinationAmountController.text = (tx.amountOriginalSatang / 100.0).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
        }
      }
    });
  }

  @override
  void dispose() {
    _sourceAmountController.dispose();
    _destinationAmountController.dispose();
    _noteController.dispose();
    _tagController.dispose();
    _feeController.dispose();
    _whtController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_transactionDate),
      );
      if (!mounted) return;
      setState(() {
        if (time != null) {
          _transactionDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        } else {
          _transactionDate = picked;
        }
      });
    }
  }

  Future<void> _pickWorkPeriod() async {
    final now = DateTime.now();
    int curYear = now.year;
    int curMonth = now.month;
    if (_workPeriod != null && _workPeriod!.contains('-')) {
      final parts = _workPeriod!.split('-');
      curYear = int.tryParse(parts[0]) ?? now.year;
      curMonth = int.tryParse(parts[1]) ?? now.month;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(curYear, curMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'เลือกรอบเดือนของรายได้ (Work Period)',
    );

    if (picked != null && mounted) {
      setState(() {
        _workPeriod = '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
      });
    }
  }

  String _getCalculatedFxRateText(String srcCurrency, String dstCurrency) {
    final src = double.tryParse(_sourceAmountController.text.trim()) ?? 0.0;
    final dst = double.tryParse(_destinationAmountController.text.trim()) ?? 0.0;
    if (src <= 0 || dst <= 0) return '';
    if (srcCurrency == 'THB' && dstCurrency == 'USD') {
      final rate = src / dst;
      return '1 USD ≈ ${rate.toStringAsFixed(4)} THB';
    } else if (srcCurrency == 'USD' && dstCurrency == 'THB') {
      final rate = dst / src;
      return '1 USD ≈ ${rate.toStringAsFixed(4)} THB';
    } else {
      final rate = src / dst;
      return '1 $dstCurrency ≈ ${rate.toStringAsFixed(4)} $srcCurrency';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final srcAccount = _accounts.where((a) => a.id == _selectedAccountId).firstOrNull;
    final dstAccount = _transactionType == 'transfer'
        ? _accounts.where((a) => a.id == _selectedDestinationAccountId).firstOrNull
        : null;

    final srcCurrency = srcAccount?.currencyCode ?? widget.transaction.currencyCode;
    final dstCurrency = dstAccount?.currencyCode ?? srcCurrency;

    int amountOriginalSatang;
    int amountThbSatang;
    String currencyCode;
    String fxRate;

    if (_transactionType == 'transfer' && srcCurrency != dstCurrency) {
      final srcDouble = double.tryParse(_sourceAmountController.text.trim()) ?? 0.0;
      final dstDouble = double.tryParse(_destinationAmountController.text.trim()) ?? 0.0;
      if (srcDouble <= 0 || dstDouble <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาระบุจำนวนเงินทั้งต้นทางและปลายทางให้มากกว่า 0')),
        );
        return;
      }

      if (srcCurrency == 'THB' && dstCurrency == 'USD') {
        currencyCode = 'USD';
        amountOriginalSatang = (dstDouble * 100).round();
        amountThbSatang = (srcDouble * 100).round();
        final calculatedRate = srcDouble / dstDouble;
        fxRate = Decimal.parse(calculatedRate.toStringAsFixed(6)).toString();
      } else if (srcCurrency == 'USD' && dstCurrency == 'THB') {
        currencyCode = 'USD';
        amountOriginalSatang = (srcDouble * 100).round();
        amountThbSatang = (dstDouble * 100).round();
        final calculatedRate = dstDouble / srcDouble;
        fxRate = Decimal.parse(calculatedRate.toStringAsFixed(6)).toString();
      } else {
        currencyCode = dstCurrency != 'THB' ? dstCurrency : srcCurrency;
        amountOriginalSatang = (dstDouble * 100).round();
        amountThbSatang = (srcDouble * 100).round();
        final calculatedRate = srcDouble / dstDouble;
        fxRate = Decimal.parse(calculatedRate.toStringAsFixed(6)).toString();
      }
    } else {
      final amountDouble = double.tryParse(_sourceAmountController.text.trim()) ?? 0.0;
      if (amountDouble <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาระบุจำนวนเงินที่มากกว่า 0')),
        );
        return;
      }
      amountOriginalSatang = (amountDouble * 100).round();
      currencyCode = srcCurrency;
      if (currencyCode == 'THB') {
        amountThbSatang = amountOriginalSatang;
        fxRate = '1.000000';
      } else {
        fxRate = widget.transaction.fxRate;
        final fxDecimal = Decimal.tryParse(fxRate) ?? Decimal.one;
        amountThbSatang = (Decimal.fromInt(amountOriginalSatang) * fxDecimal).round().toBigInt().toInt();
      }
    }

    final feeDouble = double.tryParse(_feeController.text.trim()) ?? 0.0;
    final feeSatang = _transactionType == 'transfer' ? (feeDouble * 100).round() : 0;

    final note = _noteController.text.trim();
    final userEnteredTags = _tagController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final combinedTags = <String>[...userEnteredTags];

    // If income has workPeriod, format period tag
    if (_transactionType == 'income' && _workPeriod != null && _workPeriod!.trim().isNotEmpty) {
      final periodTag = TransactionsDao.formatPeriodToTag(_workPeriod!);
      if (!combinedTags.contains(periodTag)) {
        combinedTags.add(periodTag);
      }
    }

    // Preserve system tags
    for (final st in _systemTags) {
      if (!combinedTags.contains(st)) {
        combinedTags.add(st);
      }
    }

    final finalTag = combinedTags.isEmpty ? null : combinedTags.join(', ');

    final whtDouble = double.tryParse(_whtController.text.trim()) ?? 0.0;
    final whtSatang = (whtDouble * 100).round();

    final resolvedAccountId = _selectedAccountId ?? widget.transaction.sourceAccountId ?? widget.transaction.destinationAccountId;

    final updatedTx = TransactionsCompanion(
      id: Value(widget.transaction.id),
      transactionType: Value(_transactionType),
      sourceAccountId: Value(resolvedAccountId),
      destinationAccountId: _transactionType == 'transfer' ? Value(_selectedDestinationAccountId) : Value(resolvedAccountId),
      categoryId: _transactionType != 'transfer' ? Value(_selectedCategoryId) : const Value(null),
      amountOriginalSatang: Value(amountOriginalSatang),
      currencyCode: Value(currencyCode),
      amountThbSatang: Value(amountThbSatang),
      fxRate: Value(fxRate),
      feeThbSatang: Value(feeSatang),
      taxCategory: Value(_transactionType == 'income' ? _selectedTaxCategory : null),
      withholdingTaxSatang: Value(_transactionType == 'income' ? whtSatang : 0),
      tag: Value(finalTag),
      note: Value(note.isEmpty ? null : note),
      transactionDate: Value(_transactionDate),
      workPeriod: Value(_transactionType == 'income' ? _workPeriod : null),
      expectedAmountSatang: Value(_transactionType == 'income' ? widget.transaction.expectedAmountSatang : null),
      isCleared: Value(_transactionType == 'income' ? _isCleared : true),
      updatedAt: Value(DateTime.now()),
    );

    final success = await ref.read(transactionsDaoProvider).updateTransaction(updatedTx);

    // If investment transaction, recalculate FIFO
    final oldTag = widget.transaction.tag;
    if (oldTag != null) {
      if (oldTag.startsWith('investment_buy:')) {
        final assetId = oldTag.substring('investment_buy:'.length);
        await ref.read(investmentsDaoProvider).recalculateFifoForAsset(assetId);
      } else if (oldTag.startsWith('investment_sell:')) {
        final assetId = oldTag.substring('investment_sell:'.length);
        await ref.read(investmentsDaoProvider).recalculateFifoForAsset(assetId);
      }
    }

    // Update Widget
    _updateWidget();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกการแก้ไขรายการเรียบร้อยแล้ว')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาดในการแก้ไขรายการ')),
        );
      }
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบรายการ'),
        content: const Text('คุณต้องการลบรายการนี้ใช่หรือไม่? (จะบันทึกลง Audit Log)'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ลบรายการ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(transactionsDaoProvider).softDeleteTransaction(widget.transaction.id);

      // If investment transaction, soft-delete lot and recalculate FIFO
      await ref.read(investmentsDaoProvider).handleInvestmentTransactionDeleted(
        widget.transaction.id,
        widget.transaction.tag,
      );

      _updateWidget();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบรายการเรียบร้อยแล้ว')),
        );
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _updateWidget() async {
    try {
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
    } catch (_) {}
  }

  Widget _buildTypeBadge(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    if (_transactionType == 'expense') {
      color = Colors.red;
      label = 'รายจ่าย';
      icon = Icons.arrow_upward;
    } else if (_transactionType == 'income') {
      color = Colors.green;
      label = 'รายรับ';
      icon = Icons.arrow_downward;
    } else {
      color = Colors.blue;
      label = 'โอนเงิน';
      icon = Icons.swap_horiz;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          labelText: 'วันที่และเวลา',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.edit_calendar, size: 18),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              DateFormat('d MMMM yyyy, HH:mm', 'th').format(_transactionDate),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loadingAccounts) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final srcAcc = _accounts.where((a) => a.id == _selectedAccountId).firstOrNull;
    final dstAcc = _accounts.where((a) => a.id == _selectedDestinationAccountId).firstOrNull;
    final isCrossCurrencyTransfer = _transactionType == 'transfer' &&
        srcAcc != null &&
        dstAcc != null &&
        srcAcc.currencyCode != dstAcc.currencyCode;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('แก้ไขรายการ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              _buildTypeBadge(context),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'ลบรายการนี้',
            visualDensity: VisualDensity.compact,
            onPressed: _delete,
          ),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Transaction Title / Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    labelText: 'ชื่อ transaction / บันทึก',
                    hintText: 'เช่น ข้าวเที่ยง, เงินเดือน, เติมน้ำมัน',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),

                // 2. Transfer Accounts Dropdowns (Placed above Amount for transfers so dual-currency reacts)
                if (_transactionType == 'transfer') ...[
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      labelText: 'จากบัญชีต้นทาง',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _accounts.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : null,
                    items: _accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (${a.currencyCode})'))).toList(),
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
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      labelText: 'ไปยังบัญชีปลายทาง',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _accounts.any((a) => a.id == _selectedDestinationAccountId) ? _selectedDestinationAccountId : null,
                    items: _accounts.where((a) => a.id != _selectedAccountId).map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (${a.currencyCode})'))).toList(),
                    onChanged: (val) => setState(() => _selectedDestinationAccountId = val),
                  ),
                  const SizedBox(height: 8),
                ],

                // 3. Amount Field(s)
                if (isCrossCurrencyTransfer) ...[
                  // Dual currency amount inputs
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _sourceAmountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            labelText: 'เงินต้นทาง (${srcAcc.currencyCode}) *',
                            prefixText: srcAcc.currencyCode == 'USD' ? r'$ ' : '฿ ',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'กรุณาระบุ';
                            final d = double.tryParse(val.trim());
                            if (d == null || d <= 0) return '> 0';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _destinationAmountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            labelText: 'เงินปลายทาง (${dstAcc.currencyCode}) *',
                            prefixText: dstAcc.currencyCode == 'USD' ? r'$ ' : '฿ ',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'กรุณาระบุ';
                            final d = double.tryParse(val.trim());
                            if (d == null || d <= 0) return '> 0';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_getCalculatedFxRateText(srcAcc.currencyCode, dstAcc.currencyCode).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '💱 เรตคำนวณ: ${_getCalculatedFxRateText(srcAcc.currencyCode, dstAcc.currencyCode)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ] else ...[
                  // Single Amount field
                  TextFormField(
                    controller: _sourceAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      labelText: 'จำนวนเงิน *',
                      prefixText: (srcAcc?.currencyCode ?? widget.transaction.currencyCode) == 'USD' ? r'$ ' : '฿ ',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'กรุณากรอกจำนวนเงิน';
                      final d = double.tryParse(val.trim());
                      if (d == null || d <= 0) return 'จำนวนเงินต้องมากกว่า 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                ],

                // 4. Category (Non-transfer)
                if (_transactionType != 'transfer') ...[
                  FutureBuilder<List<Category>>(
                    future: ref.read(categoriesDaoProvider).getActiveCategories(_transactionType),
                    builder: (context, snapshot) {
                      final categories = snapshot.data ?? [];
                      final selectedCat = categories.where((c) => c.id == _selectedCategoryId).firstOrNull;
                      final name = selectedCat?.nameTh ?? 'เลือกหมวดหมู่';

                      return InkWell(
                        onTap: () async {
                          final chosen = await CategoryPickerSheet.show(
                            context,
                            categoryType: _transactionType,
                            selectedCategoryId: _selectedCategoryId,
                          );
                          if (chosen != null && mounted) {
                            setState(() {
                              _selectedCategoryId = chosen.id;
                              if (_transactionType == 'income') {
                                if (chosen.taxIncomeType != null && chosen.taxIncomeType!.isNotEmpty) {
                                  if (chosen.taxIncomeType == '40_4') {
                                    _selectedTaxCategory = '40_4_interest';
                                  } else {
                                    _selectedTaxCategory = chosen.taxIncomeType;
                                  }
                                } else {
                                  final catName = '${chosen.nameTh} ${chosen.nameEn}'.toLowerCase();
                                  if (catName.contains('รับจ้าง') || catName.contains('เวร') || catName.contains('เงินเดือน')) {
                                    _selectedTaxCategory = '40_1';
                                  } else if (catName.contains('ดอกเบี้ย') || catName.contains('ปันผล')) {
                                    _selectedTaxCategory = '40_4_interest';
                                  } else if (catName.contains('รายรับอื่นๆ')) {
                                    _selectedTaxCategory = 'non_taxable';
                                  }
                                }
                              }
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            labelText: 'หมวดหมู่',
                            prefixIcon: selectedCat != null
                                ? Icon(CategoryIconHelper.getIcon(selectedCat.icon), size: 18)
                                : const Icon(Icons.category_outlined, size: 18),
                            prefixIconConstraints: const BoxConstraints(minWidth: 36),
                            suffixIcon: const Icon(Icons.chevron_right_rounded, size: 18),
                            border: const OutlineInputBorder(),
                          ),
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Account Selector for Non-transfer
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      labelText: 'บัญชี',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _accounts.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : null,
                    items: _accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (${a.currencyCode})'))).toList(),
                    onChanged: (val) => setState(() => _selectedAccountId = val),
                  ),
                  const SizedBox(height: 8),
                ],

                // 5. Date & Time Picker
                _buildDatePicker(theme),
                const SizedBox(height: 8),

                // 6. Income-specific Section: Accrued status, Work Period, Tax & WHT
                if (_transactionType == 'income') ...[
                  // Accrued Received / Pending Status Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isCleared
                          ? VaultTheme.positive(context).withValues(alpha: 0.08)
                          : Colors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isCleared
                            ? VaultTheme.positive(context).withValues(alpha: 0.3)
                            : Colors.amber.shade700,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isCleared ? Icons.check_circle : Icons.pending_actions,
                          size: 20,
                          color: _isCleared ? VaultTheme.positive(context) : Colors.amber.shade800,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isCleared ? 'สถานะ: ได้รับเงินแล้ว (Cleared)' : 'สถานะ: ค้างรับ (ยังไม่ได้รับเงินจริง)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _isCleared ? VaultTheme.positive(context) : Colors.amber.shade900,
                                ),
                              ),
                              if (!_isCleared)
                                const Text(
                                  'เงินยังไม่เข้าบัญชีจริงจนกว่าจะกดรับเงิน',
                                  style: TextStyle(fontSize: 11, color: Colors.black54),
                                ),
                            ],
                          ),
                        ),
                        if (!_isCleared)
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: VaultTheme.positive(context),
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            onPressed: () {
                              setState(() {
                                _isCleared = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('เปลี่ยนสถานะเป็น "รับเงินแล้ว" (กดบันทึกการแก้ไขเพื่อยืนยัน)')),
                              );
                            },
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('รับแล้ว', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          )
                        else
                          TextButton(
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            onPressed: () {
                              setState(() {
                                _isCleared = false;
                              });
                            },
                            child: const Text('เปลี่ยนเป็นค้างรับ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Accrued Work Period Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 20, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('รอบเดือนของรายได้ (Work Period)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text(
                                _workPeriod != null && _workPeriod!.trim().isNotEmpty
                                    ? TransactionsDao.formatPeriodToTag(_workPeriod!)
                                    : 'ไม่ได้ระบุรอบเดือน (นับตามวันทำรายการ)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _workPeriod != null && _workPeriod!.trim().isNotEmpty
                                      ? theme.colorScheme.primary
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_workPeriod != null && _workPeriod!.trim().isNotEmpty) ...[
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Colors.red),
                            tooltip: 'ล้างรอบเดือน',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => setState(() => _workPeriod = null),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_calendar, size: 18),
                            tooltip: 'เปลี่ยนรอบเดือน',
                            visualDensity: VisualDensity.compact,
                            onPressed: _pickWorkPeriod,
                          ),
                        ] else ...[
                          FilledButton.tonal(
                            style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                            onPressed: _pickWorkPeriod,
                            child: const Text('ระบุรอบเดือน', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      labelText: 'ประเภทภาษีเงินได้บุคคลธรรมดา (ภ.ง.ด.)',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedTaxCategory,
                    items: const [
                      DropdownMenuItem(value: '40_1', child: Text('40(1) เงินเดือน / โบนัส')),
                      DropdownMenuItem(value: '40_2', child: Text('40(2) ค่าจ้าง / ฟรีแลนซ์')),
                      DropdownMenuItem(value: '40_4_interest', child: Text('40(4)(ก) ดอกเบี้ยเงินฝาก')),
                      DropdownMenuItem(value: '40_4_dividend_th', child: Text('40(4)(ข) เงินปันผลหุ้นไทย')),
                      DropdownMenuItem(value: '40_4_dividend_foreign', child: Text('40(4) เงินปันผลต่างประเทศ')),
                      DropdownMenuItem(value: '40_4_crypto', child: Text('40(4) กำไรคริปโตเคอร์เรนซี')),
                      DropdownMenuItem(value: '40_6_medical', child: Text('40(6) วิชาชีพแพทย์/การประกอบโรคศิลปะ')),
                      DropdownMenuItem(value: '40_8', child: Text('40(8) ธุรกิจ / การพาณิชย์ / อื่นๆ')),
                      DropdownMenuItem(value: 'non_taxable', child: Text('ไม่เข้าข่ายเสียภาษี (ยกเว้น)')),
                    ],
                    onChanged: (val) => setState(() => _selectedTaxCategory = val),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _whtController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      labelText: 'ภาษีหัก ณ ที่จ่าย (WHT)',
                      prefixText: '฿ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      labelText: 'ป้ายกำกับ (Tag)',
                      hintText: 'เช่น เที่ยวญี่ปุ่น, เบิกได้',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ] else if (_transactionType == 'expense') ...[
                  // Expense: Tag only (Fee removed)
                  TextFormField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      labelText: 'ป้ายกำกับ (Tag)',
                      hintText: 'เช่น เที่ยวญี่ปุ่น, เบิกได้',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ] else ...[
                  // Transfer: Tag & Fee in a compact row
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _tagController,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            labelText: 'ป้ายกำกับ (Tag)',
                            hintText: 'เช่น เที่ยวญี่ปุ่น, เบิกได้',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _feeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            labelText: 'ค่าธรรมเนียม',
                            prefixText: '฿ ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('บันทึกการแก้ไข'),
        ),
      ],
    );
  }
}
