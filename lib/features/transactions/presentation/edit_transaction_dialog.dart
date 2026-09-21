import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/services/widget_service.dart';

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
    final feeSatang = (feeDouble * 100).round();

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('แก้ไขรายการ'),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'ลบรายการนี้',
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
                // 1. Transaction Type
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'expense', label: Text('รายจ่าย')),
                    ButtonSegment(value: 'income', label: Text('รายรับ')),
                    ButtonSegment(value: 'transfer', label: Text('โอนเงิน')),
                  ],
                  selected: {_transactionType},
                  onSelectionChanged: (newVal) async {
                    setState(() => _transactionType = newVal.first);
                    if (_transactionType != 'transfer') {
                      final cats = await ref.read(categoriesDaoProvider).getActiveCategories(_transactionType);
                      if (cats.isNotEmpty && mounted) {
                        setState(() => _selectedCategoryId = cats.first.id);
                      }
                    }
                  },
                ),
                const SizedBox(height: 14),

                // 2. Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
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
                const SizedBox(height: 14),

                // 3. Category (if not transfer)
                if (_transactionType != 'transfer') ...[
                  FutureBuilder<List<Category>>(
                    future: ref.read(categoriesDaoProvider).getActiveCategories(_transactionType),
                    builder: (context, snapshot) {
                      final categories = snapshot.data ?? [];
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'หมวดหมู่', border: OutlineInputBorder()),
                        initialValue: categories.any((c) => c.id == _selectedCategoryId) ? _selectedCategoryId : null,
                        items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nameTh))).toList(),
                        onChanged: (val) => setState(() => _selectedCategoryId = val),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                ],

                // Tax Category & WHT (if Income)
                if (_transactionType == 'income') ...[
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'ประเภทภาษีเงินได้บุคคลธรรมดา (ภ.ง.ด.)', border: OutlineInputBorder()),
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
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _whtController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'ภาษีหัก ณ ที่จ่าย (WHT) (บาท)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
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
                            decoration: const InputDecoration(labelText: 'จากบัญชีต้นทาง', border: OutlineInputBorder()),
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
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            key: ValueKey('dest_$effectiveDestId'),
                            decoration: const InputDecoration(labelText: 'ไปยังบัญชีปลายทาง', border: OutlineInputBorder()),
                            initialValue: effectiveDestId,
                            items: destAccounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (${a.currencyCode})'))).toList(),
                            onChanged: (val) => setState(() => _selectedDestinationAccountId = val),
                          ),
                        ],
                      );
                    } else {
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'บัญชี', border: OutlineInputBorder()),
                        initialValue: accounts.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : null,
                        items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (${a.currencyCode})'))).toList(),
                        onChanged: (val) => setState(() => _selectedAccountId = val),
                      );
                    }
                  },
                ),
                const SizedBox(height: 14),

                // 5. Date Picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(DateFormat('d MMMM yyyy, HH:mm', 'th').format(_transactionDate)),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 10),

                // 6. Fee
                TextFormField(
                  controller: _feeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'ค่าธรรมเนียม (บาท)',
                    hintText: '0.00',
                    prefixText: '฿ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),

                // 7. Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'บันทึกช่วยจำ (Note)',
                    hintText: 'เช่น ข้าวเที่ยง, เติมน้ำมัน',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),

                // 8. Tag
                TextFormField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    labelText: 'ป้ายกำกับ (Tag)',
                    hintText: 'เช่น เที่ยวญี่ปุ่น, เบิกได้',
                    border: OutlineInputBorder(),
                  ),
                ),
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
