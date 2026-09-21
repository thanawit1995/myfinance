import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';

class AddAccountDialog extends ConsumerStatefulWidget {
  const AddAccountDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const AddAccountDialog(),
    );
  }

  @override
  ConsumerState<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends ConsumerState<AddAccountDialog> {
  static const _uuid = Uuid();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '0');
  final _closingDayController = TextEditingController(text: '23');
  final _dueDayController = TextEditingController(text: '10');
  final _creditLimitController = TextEditingController(text: '');

  String _accountType = 'bank'; // bank, fcd, offshore, credit_card, cash
  String _currencyCode = 'THB'; // THB, USD
  bool _isDomestic = true;

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    _closingDayController.dispose();
    _dueDayController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  void _onTypeChanged(String? type) {
    if (type == null) return;
    setState(() {
      _accountType = type;
      if (type == 'fcd') {
        _currencyCode = 'USD';
        _isDomestic = true;
      } else if (type == 'offshore') {
        _currencyCode = 'USD';
        _isDomestic = false;
      } else if (type == 'credit_card') {
        _currencyCode = 'THB';
        _isDomestic = true;
      } else {
        _currencyCode = 'THB';
        _isDomestic = true;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final now = DateTime.now();
    final accountId = _uuid.v4();

    int? closingDay;
    int? dueDay;
    int? creditLimitSatang;

    if (_accountType == 'credit_card') {
      closingDay = int.tryParse(_closingDayController.text.trim()) ?? 23;
      dueDay = int.tryParse(_dueDayController.text.trim()) ?? 10;
      final limitDouble = double.tryParse(_creditLimitController.text.trim());
      if (limitDouble != null && limitDouble > 0) {
        creditLimitSatang = (limitDouble * 100).round();
      }
    }

    final newAccount = AccountsCompanion.insert(
      id: accountId,
      name: name,
      accountType: _accountType,
      currencyCode: _currencyCode,
      isDomestic: _isDomestic,
      closingDay: Value(closingDay),
      dueDay: Value(dueDay),
      creditLimitSatang: Value(creditLimitSatang),
      isActive: const Value(true),
      createdAt: now,
      updatedAt: now,
    );

    final accDao = ref.read(accountsDaoProvider);
    await accDao.createAccount(newAccount);

    // Initial Balance (if any)
    final initialBalance = double.tryParse(_initialBalanceController.text.trim()) ?? 0.0;
    if (initialBalance > 0 && _accountType != 'credit_card') {
      final txDao = ref.read(transactionsDaoProvider);
      final satang = (initialBalance * 100).round();

      // Find an income category
      final categories = await ref.read(categoriesDaoProvider).getActiveCategories('income');
      final catId = categories.isNotEmpty ? categories.first.id : null;

      final initialTx = TransactionsCompanion.insert(
        id: _uuid.v4(),
        transactionType: 'income',
        sourceAccountId: Value(accountId),
        categoryId: Value(catId),
        amountOriginalSatang: satang,
        currencyCode: _currencyCode,
        fxRate: const Value('1.000000'),
        amountThbSatang: satang, // Assuming 1:1 if THB, or base rate
        transactionDate: now,
        note: const Value('ยอดยกมาเริ่มต้น'),
        createdAt: now,
        updatedAt: now,
      );
      await txDao.insertTransaction(initialTx);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('สร้างบัญชี "$name" เรียบร้อยแล้ว')),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreditCard = _accountType == 'credit_card';

    return AlertDialog(
      title: const Text('เพิ่มบัญชีใหม่'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อบัญชี *',
                    hintText: 'เช่น กสิกรไทย, K-eSavings, บัตร KTC',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'กรุณากรอกชื่อบัญชี';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Account Type Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'ประเภทบัญชี *',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _accountType,
                  items: const [
                    DropdownMenuItem(value: 'bank', child: Text('บัญชีเงินฝากธนาคาร (Bank)')),
                    DropdownMenuItem(value: 'fcd', child: Text('บัญชีเงินตราต่างประเทศในไทย (FCD)')),
                    DropdownMenuItem(value: 'offshore', child: Text('บัญชีต่างประเทศ (Offshore)')),
                    DropdownMenuItem(value: 'credit_card', child: Text('บัตรเครดิต (Credit Card)')),
                    DropdownMenuItem(value: 'cash', child: Text('เงินสด (Cash)')),
                  ],
                  onChanged: _onTypeChanged,
                ),
                const SizedBox(height: 14),

                // Currency Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'สกุลเงิน *',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _currencyCode,
                  items: const [
                    DropdownMenuItem(value: 'THB', child: Text('THB - บาทไทย (฿)')),
                    DropdownMenuItem(value: 'USD', child: Text('USD - ดอลลาร์สหรัฐ (\$)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _currencyCode = val);
                    }
                  },
                ),
                const SizedBox(height: 14),

                // Initial Balance (if not credit card)
                if (!isCreditCard) ...[
                  TextFormField(
                    controller: _initialBalanceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'ยอดยกมาเริ่มต้น',
                      hintText: '0.00',
                      prefixText: _currencyCode == 'USD' ? r'$ ' : '฿ ',
                      border: const OutlineInputBorder(),
                      helperText: 'ระบบจะลงบันทึกเป็นยอดยกมาเริ่มต้นให้ทันที',
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Credit Card specific fields
                if (isCreditCard) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _closingDayController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'วันตัดรอบบิล (1-31)',
                            hintText: '23',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) {
                            final day = int.tryParse(val ?? '');
                            if (day == null || day < 1 || day > 31) {
                              return 'ใส่วันที่ 1-31';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _dueDayController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'วันครบกำหนดชำระ',
                            hintText: '10',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _creditLimitController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'วงเงินบัตรเครดิต (บาท)',
                      hintText: 'เช่น 50000',
                      prefixText: '฿ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
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
          child: const Text('บันทึกบัญชี'),
        ),
      ],
    );
  }
}
