import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';

class RecurringRuleDialog extends ConsumerStatefulWidget {
  final RecurringRule? ruleToEdit;

  const RecurringRuleDialog({super.key, this.ruleToEdit});

  static Future<bool?> show(BuildContext context, {RecurringRule? rule}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => RecurringRuleDialog(ruleToEdit: rule),
    );
  }

  @override
  ConsumerState<RecurringRuleDialog> createState() => _RecurringRuleDialogState();
}

class _RecurringRuleDialogState extends ConsumerState<RecurringRuleDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _intervalController;
  late TextEditingController _dayOfMonthController;
  late TextEditingController _noteController;

  String _transactionType = 'expense';
  String _frequency = 'monthly';
  String? _sourceAccountId;
  String? _destinationAccountId;
  String? _categoryId;
  DateTime _nextRunDate = DateTime.now();
  DateTime? _endDate;
  bool _autoPost = true;

  List<Account> _accounts = [];
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final item = widget.ruleToEdit;
    _titleController = TextEditingController(text: item?.title ?? '');
    _amountController = TextEditingController(
      text: item != null ? (item.amountSatang / 100).toStringAsFixed(2) : '',
    );
    _intervalController = TextEditingController(
      text: item != null ? item.intervalUnits.toString() : '1',
    );
    _dayOfMonthController = TextEditingController(
      text: item?.dayOfMonth != null ? item!.dayOfMonth.toString() : DateTime.now().day.toString(),
    );
    _noteController = TextEditingController(text: item?.note ?? '');

    _transactionType = item?.transactionType ?? 'expense';
    _frequency = item?.frequency ?? 'monthly';
    _sourceAccountId = item?.sourceAccountId;
    _destinationAccountId = item?.destinationAccountId;
    _categoryId = item?.categoryId;
    _nextRunDate = item?.nextRunDate ?? DateTime.now();
    _endDate = item?.endDate;
    _autoPost = item?.autoPost ?? true;

    _loadDependencies();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _intervalController.dispose();
    _dayOfMonthController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadDependencies() async {
    final accs = await ref.read(accountsDaoProvider).getActiveAccounts();
    final cats = await ref.read(categoriesDaoProvider).getActiveCategories(_transactionType == 'transfer' ? null : _transactionType);

    if (mounted) {
      setState(() {
        _accounts = accs;
        _categories = cats;
        if (_sourceAccountId == null && accs.isNotEmpty) {
          _sourceAccountId = accs.first.id;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _onTransactionTypeChanged(String newType) async {
    setState(() {
      _transactionType = newType;
      _categoryId = null;
    });
    if (newType != 'transfer') {
      final cats = await ref.read(categoriesDaoProvider).getActiveCategories(newType);
      if (mounted) {
        setState(() {
          _categories = cats;
        });
      }
    }
  }

  Future<void> _pickNextRunDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextRunDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() => _nextRunDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _nextRunDate.add(const Duration(days: 365)),
      firstDate: _nextRunDate,
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _save(bool isThai) async {
    if (!_formKey.currentState!.validate()) return;
    if (_sourceAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isThai ? 'กรุณาเลือกบัญชี' : 'Please select an account')),
      );
      return;
    }

    final dao = ref.read(recurringTransactionsDaoProvider);
    final amountBaht = double.tryParse(_amountController.text.trim()) ?? 0;
    final amountSatang = (amountBaht * 100).round();
    final intervalUnits = int.tryParse(_intervalController.text.trim()) ?? 1;
    final dayOfMonth = int.tryParse(_dayOfMonthController.text.trim());

    if (widget.ruleToEdit == null) {
      // Create new
      await dao.createRule(
        RecurringRulesCompanion.insert(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          transactionType: _transactionType,
          amountSatang: amountSatang,
          currencyCode: 'THB',
          frequency: _frequency,
          intervalUnits: drift.Value(intervalUnits),
          dayOfMonth: drift.Value(dayOfMonth),
          endDate: drift.Value(_endDate),
          nextRunDate: _nextRunDate,
          autoPost: drift.Value(_autoPost),
          sourceAccountId: _sourceAccountId!,
          destinationAccountId: drift.Value(_transactionType == 'transfer' ? _destinationAccountId : null),
          categoryId: drift.Value(_categoryId),
          note: drift.Value(_noteController.text.trim().isEmpty ? null : _noteController.text.trim()),
          isActive: const drift.Value(true),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } else {
      // Update existing
      await dao.updateRule(
        RecurringRulesCompanion(
          id: drift.Value(widget.ruleToEdit!.id),
          title: drift.Value(_titleController.text.trim()),
          transactionType: drift.Value(_transactionType),
          amountSatang: drift.Value(amountSatang),
          frequency: drift.Value(_frequency),
          intervalUnits: drift.Value(intervalUnits),
          dayOfMonth: drift.Value(dayOfMonth),
          endDate: drift.Value(_endDate),
          nextRunDate: drift.Value(_nextRunDate),
          autoPost: drift.Value(_autoPost),
          sourceAccountId: drift.Value(_sourceAccountId!),
          destinationAccountId: drift.Value(_transactionType == 'transfer' ? _destinationAccountId : null),
          categoryId: drift.Value(_categoryId),
          note: drift.Value(_noteController.text.trim().isEmpty ? null : _noteController.text.trim()),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.ruleToEdit != null;
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    final freqLabels = {
      'daily': isThai ? 'รายวัน (Daily)' : 'Daily',
      'weekly': isThai ? 'รายสัปดาห์ (Weekly)' : 'Weekly',
      'monthly': isThai ? 'รายเดือน (Monthly)' : 'Monthly',
      'yearly': isThai ? 'รายปี (Yearly)' : 'Yearly',
    };

    return AlertDialog(
      title: Text(isEditing
          ? (isThai ? 'แก้ไขรายการอัตโนมัติ' : 'Edit Recurring Rule')
          : (isThai ? 'สร้างรายการอัตโนมัติใหม่' : 'New Recurring Rule')),
      content: _isLoading
          ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
          : SizedBox(
              width: 500,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: isThai ? 'ชื่อรายการ *' : 'Rule Title *',
                          hintText: isThai
                              ? 'เช่น ค่าเช่าห้อง, เงินเดือน, ค่าสมาชิก'
                              : 'e.g. Rent, Salary, Netflix subscription',
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? (isThai ? 'กรุณาระบุชื่อ' : 'Title is required')
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _transactionType,
                              decoration: InputDecoration(
                                labelText: isThai ? 'ประเภทรายการ' : 'Type',
                                isDense: true,
                                border: const OutlineInputBorder(),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'expense',
                                  child: Text(isThai ? 'รายจ่าย (Expense)' : 'Expense'),
                                ),
                                DropdownMenuItem(
                                  value: 'income',
                                  child: Text(isThai ? 'รายรับ (Income)' : 'Income'),
                                ),
                                DropdownMenuItem(
                                  value: 'transfer',
                                  child: Text(isThai ? 'โอนเงิน (Transfer)' : 'Transfer'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) _onTransactionTypeChanged(val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                              decoration: InputDecoration(
                                labelText: isThai ? 'จำนวนเงิน (บาท) *' : 'Amount (THB) *',
                                hintText: '0.00',
                                suffixText: '฿',
                                isDense: true,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return isThai ? 'กรุณาระบุจำนวนเงิน' : 'Amount required';
                                }
                                if (double.tryParse(v.trim()) == null) {
                                  return isThai ? 'ตัวเลขไม่ถูกต้อง' : 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _frequency,
                              decoration: InputDecoration(
                                labelText: isThai ? 'ความถี่รอบรายการ' : 'Frequency',
                                isDense: true,
                                border: const OutlineInputBorder(),
                              ),
                              items: freqLabels.entries
                                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _frequency = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 130,
                            child: TextFormField(
                              controller: _intervalController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: isThai ? 'ทุกๆ (รอบ)' : 'Interval',
                                hintText: '1',
                                suffixText: isThai ? 'รอบ' : 'cycle(s)',
                                isDense: true,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || int.tryParse(v.trim()) == null || int.parse(v.trim()) <= 0)
                                  ? '>= 1'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      if (_frequency == 'monthly' || _frequency == 'yearly') ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dayOfMonthController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: InputDecoration(
                            labelText: isThai ? 'วันที่ทำรายการของเดือน (1-31)' : 'Day of Month (1-31)',
                            hintText: isThai
                                ? 'เช่น 1, 25, 31 (ระบบจะปัดวันสิ้นเดือนให้อัตโนมัติ)'
                                : 'e.g. 1, 25, 31 (auto-adjusted for month-end)',
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              final d = int.tryParse(v.trim());
                              if (d == null || d < 1 || d > 31) {
                                return isThai ? 'วันที่ต้องอยู่ระหว่าง 1-31' : 'Must be between 1-31';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              initialValue: _sourceAccountId,
                              decoration: InputDecoration(
                                labelText: _transactionType == 'income'
                                    ? (isThai ? 'เข้าบัญชี' : 'To Account')
                                    : (isThai ? 'จากบัญชี' : 'From Account'),
                                isDense: true,
                                border: const OutlineInputBorder(),
                              ),
                              items: _accounts
                                  .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                                  .toList(),
                              onChanged: (val) => setState(() => _sourceAccountId = val),
                            ),
                          ),
                          if (_transactionType == 'transfer') ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                initialValue: _destinationAccountId,
                                decoration: InputDecoration(
                                  labelText: isThai ? 'ไปยังบัญชี' : 'To Account',
                                  isDense: true,
                                  border: const OutlineInputBorder(),
                                ),
                                items: _accounts
                                    .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                                    .toList(),
                                onChanged: (val) => setState(() => _destinationAccountId = val),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (_transactionType != 'transfer') ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String?>(
                          initialValue: _categoryId,
                          decoration: InputDecoration(
                            labelText: isThai ? 'หมวดหมู่ (Category)' : 'Category',
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(isThai ? '-- ไม่ระบุหมวดหมู่ --' : '-- No Category --'),
                            ),
                            ..._categories.map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(isThai ? c.nameTh : c.nameEn),
                                )),
                          ],
                          onChanged: (val) => setState(() => _categoryId = val),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _pickNextRunDate,
                              icon: const Icon(Icons.event, size: 18),
                              label: Text(
                                '${isThai ? "รอบถัดไป: " : "Next: "}${DateFormat('dd/MM/yyyy').format(_nextRunDate)}',
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _pickEndDate,
                              icon: const Icon(Icons.stop_circle_outlined, size: 18),
                              label: Text(
                                _endDate != null
                                    ? '${isThai ? "สิ้นสุด: " : "End: "}${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                                    : (isThai ? 'ไม่มีวันสิ้นสุด' : 'No End Date'),
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (_endDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() => _endDate = null),
                              tooltip: isThai ? 'ล้างวันสิ้นสุด' : 'Clear end date',
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(isThai ? 'บันทึกอัตโนมัติ (Auto-Post)' : 'Auto-Post'),
                        subtitle: Text(
                          _autoPost
                              ? (isThai
                                  ? 'ระบบจะสร้างรายการลงบัญชีให้ทันทีเมื่อถึงกำหนดรอบ'
                                  : 'Automatically create transaction on due date')
                              : (isThai
                                  ? 'ระบบจะรอให้คุณกดยืนยันการทำรายการด้วยตนเองก่อนบันทึก'
                                  : 'Requires manual confirmation before posting'),
                          style: const TextStyle(fontSize: 11.5),
                        ),
                        value: _autoPost,
                        onChanged: (val) => setState(() => _autoPost = val),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: isThai ? 'บันทึกช่วยจำเพิ่มเติม' : 'Note (Optional)',
                          isDense: true,
                          border: const OutlineInputBorder(),
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
          child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : () => _save(isThai),
          child: Text(isEditing
              ? (isThai ? 'บันทึกการแก้ไข' : 'Save Changes')
              : (isThai ? 'สร้างรายการอัตโนมัติ' : 'Create Rule')),
        ),
      ],
    );
  }
}
