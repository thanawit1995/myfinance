import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/services/widget_service.dart';
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

  late TextEditingController _amountController;
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

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _transactionType = tx.transactionType;
    _selectedAccountId = tx.sourceAccountId;
    _selectedDestinationAccountId = tx.destinationAccountId;
    _selectedCategoryId = tx.categoryId;
    _selectedTaxCategory = tx.taxCategory;
    _transactionDate = tx.transactionDate;

    final amountDouble = tx.amountOriginalSatang / 100.0;
    _amountController = TextEditingController(
      text: amountDouble.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), ''),
    );
    _noteController = TextEditingController(text: tx.note ?? '');
    _tagController = TextEditingController(text: tx.tag ?? '');
    final feeDouble = tx.feeThbSatang / 100.0;
    _feeController = TextEditingController(
      text: feeDouble > 0 ? feeDouble.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '') : '',
    );
    final whtDouble = tx.withholdingTaxSatang / 100.0;
    _whtController = TextEditingController(
      text: whtDouble > 0 ? whtDouble.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '') : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amountDouble = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amountDouble <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาระบุจำนวนเงินที่มากกว่า 0')),
      );
      return;
    }

    final satang = (amountDouble * 100).round();
    final feeDouble = double.tryParse(_feeController.text.trim()) ?? 0.0;
    final feeSatang = _transactionType == 'transfer' ? (feeDouble * 100).round() : 0;

    final sourceAccount = _selectedAccountId != null
        ? await ref.read(accountsDaoProvider).getAccountById(_selectedAccountId!)
        : null;

    final currency = sourceAccount?.currencyCode ?? widget.transaction.currencyCode;
    final note = _noteController.text.trim();
    final tag = _tagController.text.trim();

    final whtDouble = double.tryParse(_whtController.text.trim()) ?? 0.0;
    final whtSatang = (whtDouble * 100).round();

    final fxDecimal = Decimal.tryParse(widget.transaction.fxRate) ?? Decimal.one;
    final thbSatang = currency == 'THB'
        ? satang
        : (Decimal.fromInt(satang) * fxDecimal).round().toBigInt().toInt();

    final updatedTx = TransactionsCompanion(
      id: Value(widget.transaction.id),
      transactionType: Value(_transactionType),
      sourceAccountId: Value(_selectedAccountId),
      destinationAccountId: _transactionType == 'transfer' ? Value(_selectedDestinationAccountId) : const Value(null),
      categoryId: _transactionType != 'transfer' ? Value(_selectedCategoryId) : const Value(null),
      amountOriginalSatang: Value(satang),
      currencyCode: Value(currency),
      amountThbSatang: Value(thbSatang),
      feeThbSatang: Value(feeSatang),
      taxCategory: Value(_transactionType == 'income' ? _selectedTaxCategory : null),
      withholdingTaxSatang: Value(_transactionType == 'income' ? whtSatang : 0),
      tag: Value(tag.isEmpty ? null : tag),
      note: Value(note.isEmpty ? null : note),
      transactionDate: Value(_transactionDate),
      workPeriod: Value(_transactionType == 'income' ? widget.transaction.workPeriod : null),
      expectedAmountSatang: Value(_transactionType == 'income' ? widget.transaction.expectedAmountSatang : null),
      isCleared: Value(_transactionType == 'income' ? widget.transaction.isCleared : true),
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
        width: 440,
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

                // 2. Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    labelText: 'จำนวนเงิน *',
                    prefixText: widget.transaction.currencyCode == 'USD' ? r'$ ' : '฿ ',
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

                // 3. Category / Destination Account
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
                            setState(() => _selectedCategoryId = chosen.id);
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
                ],

                // 4. Account Selector
                FutureBuilder<List<Account>>(
                  future: ref.read(accountsDaoProvider).getActiveAccounts(),
                  builder: (context, snapshot) {
                    final accounts = snapshot.data ?? [];
                    if (_transactionType == 'transfer') {
                      final destAccounts = accounts.where((a) => a.id != _selectedAccountId).toList();
                      final effectiveDestId = destAccounts.any((a) => a.id == _selectedDestinationAccountId)
                          ? _selectedDestinationAccountId
                          : (destAccounts.isNotEmpty ? destAccounts.first.id : null);

                      return Column(
                        children: [
                          DropdownButtonFormField<String>(
                            key: ValueKey('dest_$effectiveDestId'),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              labelText: 'ไปยังบัญชีปลายทาง',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: effectiveDestId,
                            items: destAccounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (${a.currencyCode})'))).toList(),
                            onChanged: (val) => setState(() => _selectedDestinationAccountId = val),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              labelText: 'จากบัญชีต้นทาง',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: accounts.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : null,
                            items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (${a.currencyCode})'))).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedAccountId = val;
                                if (_selectedDestinationAccountId == val) {
                                  final remaining = accounts.where((a) => a.id != val).toList();
                                  _selectedDestinationAccountId = remaining.isNotEmpty ? remaining.first.id : null;
                                }
                              });
                            },
                          ),
                        ],
                      );
                    } else {
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          labelText: 'บัญชี',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: accounts.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : null,
                        items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (${a.currencyCode})'))).toList(),
                        onChanged: (val) => setState(() => _selectedAccountId = val),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),

                // 5. Date & Time Picker
                _buildDatePicker(theme),
                const SizedBox(height: 8),

                // Income-specific fields: Tax Category, WHT & Fee in a compact row
                if (_transactionType == 'income') ...[
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
