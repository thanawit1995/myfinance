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
  bool _isAccrued = false;
  String _workPeriodMode = 'prev_month';
  String? _taxCategory;

  List<Account> _accounts = [];
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final item = widget.ruleToEdit;
    final rawNote = item?.note ?? '';
    _isAccrued = rawNote.contains('[accrued]');
    if (rawNote.contains('[work_period:prev_month]')) {
      _workPeriodMode = 'prev_month';
    } else if (rawNote.contains('[work_period:same_month]')) {
      _workPeriodMode = 'same_month';
    } else {
      _workPeriodMode = _isAccrued ? 'prev_month' : 'same_month';
    }
    final taxMatch = RegExp(r'\[tax_cat:([^\]]+)\]').firstMatch(rawNote);
    if (taxMatch != null) {
      _taxCategory = taxMatch.group(1);
    }
    final cleanNote = rawNote
        .replaceAll('[accrued]', '')
        .replaceAll(RegExp(r'\[work_period:[^\]]+\]'), '')
        .replaceAll(RegExp(r'\[tax_cat:[^\]]+\]'), '')
        .trim();
    _noteController = TextEditingController(text: cleanNote);

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

    String noteText = _noteController.text.trim();
    if (_transactionType == 'income') {
      if (_isAccrued) {
        noteText = '$noteText [accrued]'.trim();
      }
      if (_workPeriodMode == 'prev_month') {
        noteText = '$noteText [work_period:prev_month]'.trim();
      } else if (_workPeriodMode == 'same_month') {
        noteText = '$noteText [work_period:same_month]'.trim();
      }
      if (_taxCategory != null && _taxCategory!.isNotEmpty) {
        noteText = '$noteText [tax_cat:$_taxCategory]'.trim();
      }
    }
    final finalNote = noteText.isEmpty ? null : noteText;

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
          note: drift.Value(finalNote),
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
          note: drift.Value(finalNote),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      DropdownButtonFormField<String>(
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
                      const SizedBox(height: 12),
                      TextFormField(
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
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
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
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _intervalController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: isThai ? 'ความถี่ทุกๆ (จำนวนรอบ)' : 'Interval (Cycle)',
                          hintText: '1',
                          suffixText: isThai ? 'รอบ' : 'cycle(s)',
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || int.tryParse(v.trim()) == null || int.parse(v.trim()) <= 0)
                            ? (isThai ? 'ต้องมากกว่าหรือเท่ากับ 1' : '>= 1')
                            : null,
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
                      DropdownButtonFormField<String?>(
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
                      if (_transactionType == 'transfer') ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String?>(
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
                      ],
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
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _pickNextRunDate,
                              icon: const Icon(Icons.event, size: 16),
                              label: Text(
                                '${isThai ? "รอบถัดไป: " : "Next: "}${DateFormat('dd/MM/yyyy').format(_nextRunDate)}',
                                style: const TextStyle(fontSize: 11.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _pickEndDate,
                              icon: const Icon(Icons.stop_circle_outlined, size: 16),
                              label: Text(
                                _endDate != null
                                    ? '${isThai ? "สิ้นสุด: " : "End: "}${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                                    : (isThai ? 'ไม่มีวันสิ้นสุด' : 'No End Date'),
                                style: const TextStyle(fontSize: 11.5),
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
                      if (_transactionType == 'income') ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.amber.withValues(alpha: 0.12) : Colors.amber.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.amber.shade700 : Colors.amber.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.pending_actions_rounded, size: 18, color: isDark ? Colors.amber.shade300 : Colors.amber.shade800),
                                  const SizedBox(width: 8),
                                  Text(
                                    isThai ? 'การตั้งค่ารายรับค้างรับ & ภาษี' : 'Accrued Income & Tax Settings',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: Text(
                                  isThai ? 'บันทึกเป็นรายรับค้างรับ (Accrued)' : 'Record as Accrued Income',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  isThai
                                      ? 'ระบบจะตั้งเป็นเงินค้างรับไว้ก่อน (ยังไม่นับยอดเงินเข้าบัญชีจริง จนกว่าจะกดเคลียร์ยอดเงินเข้า)'
                                      : 'Recorded as uncleared accrued income until cleared',
                                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                                ),
                                value: _isAccrued,
                                onChanged: (val) => setState(() => _isAccrued = val),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _workPeriodMode,
                                decoration: InputDecoration(
                                  labelText: isThai ? 'รอบเดือนทำงาน (Work Period)' : 'Work Period',
                                  isDense: true,
                                  border: const OutlineInputBorder(),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 'prev_month',
                                    child: Text(isThai ? 'เดือนก่อนหน้า (N-1) เช่น เงินเดือน/P4P' : 'Previous Month (N-1)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'same_month',
                                    child: Text(isThai ? 'เดือนเดียวกัน (N)' : 'Same Month (N)'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _workPeriodMode = val);
                                },
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String?>(
                                initialValue: _taxCategory,
                                decoration: InputDecoration(
                                  labelText: isThai ? 'ประเภทเงินได้พึงประเมิน (ภาษี)' : 'Tax Category',
                                  isDense: true,
                                  border: const OutlineInputBorder(),
                                ),
                                items: [
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(isThai ? '-- ไม่ระบุภาษี / เงินได้ทั่วไป --' : '-- General / None --'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: '40_1',
                                    child: Text(isThai ? '40(1) เงินเดือน / โบนัส / ค่าจ้างประจำ' : '40(1) Salary / Bonus'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: '40_2',
                                    child: Text(isThai ? '40(2) ค่าจ้างทั่วไป / เบี้ยเลี้ยง / ฟรีแลนซ์' : '40(2) Freelance / Allowance'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: '40_4',
                                    child: Text(isThai ? '40(4) ดอกเบี้ย / เงินปันผล' : '40(4) Dividend / Interest'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'exempt',
                                    child: Text(isThai ? 'เงินได้ที่ได้รับยกเว้นภาษี' : 'Tax Exempt'),
                                  ),
                                ],
                                onChanged: (val) => setState(() => _taxCategory = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          isThai ? 'บันทึกอัตโนมัติ (Auto-Post)' : 'Auto-Post',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _autoPost
                              ? (isThai
                                  ? 'ระบบจะสร้างรายการลงบัญชีให้ทันทีเมื่อถึงกำหนดรอบ'
                                  : 'Automatically create transaction on due date')
                              : (isThai
                                  ? 'ระบบจะรอให้คุณกดยืนยันการทำรายการด้วยตนเองก่อนบันทึก'
                                  : 'Requires manual confirmation before posting'),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
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
