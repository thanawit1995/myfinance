import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';

class LiabilityFormDialog extends ConsumerStatefulWidget {
  final Liability? liabilityToEdit;

  const LiabilityFormDialog({super.key, this.liabilityToEdit});

  static Future<bool?> show(BuildContext context, {Liability? liability}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => LiabilityFormDialog(liabilityToEdit: liability),
    );
  }

  @override
  ConsumerState<LiabilityFormDialog> createState() => _LiabilityFormDialogState();
}

class _LiabilityFormDialogState extends ConsumerState<LiabilityFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _principalController;
  late TextEditingController _monthlyPaymentController;
  late TextEditingController _interestRateController;
  late TextEditingController _noteController;

  String _liabilityType = 'personal_loan';
  bool _isShortTerm = false;
  String? _linkedAccountId;

  List<Account> _availableAccounts = [];
  bool _isLoading = true;

  Map<String, String> _getTypeLabels(bool isThai) => {
    'credit_card': isThai ? 'บัตรเครดิต' : 'Credit Card',
    'personal_loan': isThai ? 'สินเชื่อส่วนบุคคล' : 'Personal Loan',
    'mortgage': isThai ? 'สินเชื่อบ้าน/ที่อยู่อาศัย' : 'Mortgage / Housing Loan',
    'auto_loan': isThai ? 'สินเชื่อรถยนต์' : 'Auto / Car Loan',
    'other': isThai ? 'หนี้สินอื่นๆ' : 'Other Debt',
  };

  @override
  void initState() {
    super.initState();
    final item = widget.liabilityToEdit;
    _nameController = TextEditingController(text: item?.name ?? '');
    _principalController = TextEditingController(
      text: item != null ? (item.remainingPrincipalSatang / 100).toStringAsFixed(2) : '',
    );
    _monthlyPaymentController = TextEditingController(
      text: item != null ? (item.monthlyPaymentSatang / 100).toStringAsFixed(2) : '',
    );
    _interestRateController = TextEditingController(
      text: item?.interestRatePercent ?? '',
    );
    _noteController = TextEditingController(text: item?.note ?? '');

    _liabilityType = item?.liabilityType ?? 'personal_loan';
    _isShortTerm = item?.isShortTerm ?? false;
    _linkedAccountId = item?.linkedAccountId;

    _loadAccounts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _principalController.dispose();
    _monthlyPaymentController.dispose();
    _interestRateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    final accs = await ref.read(accountsDaoProvider).getActiveAccounts();
    if (mounted) {
      setState(() {
        _availableAccounts = accs;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final dao = ref.read(liabilitiesDaoProvider);
    final principalBaht = double.tryParse(_principalController.text.trim()) ?? 0;
    final monthlyPaymentBaht = double.tryParse(_monthlyPaymentController.text.trim()) ?? 0;
    final interestRateStr = _interestRateController.text.trim().isEmpty ? '0.0' : _interestRateController.text.trim();

    final principalSatang = (principalBaht * 100).round();
    final monthlyPaymentSatang = (monthlyPaymentBaht * 100).round();

    if (widget.liabilityToEdit == null) {
      // Create new
      await dao.createLiability(
        LiabilitiesCompanion.insert(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          liabilityType: _liabilityType,
          remainingPrincipalSatang: principalSatang,
          monthlyPaymentSatang: monthlyPaymentSatang,
          interestRatePercent: interestRateStr,
          isShortTerm: _isShortTerm,
          linkedAccountId: drift.Value(_linkedAccountId),
          note: drift.Value(_noteController.text.trim().isEmpty ? null : _noteController.text.trim()),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } else {
      // Update existing
      await dao.updateLiability(
        LiabilitiesCompanion(
          id: drift.Value(widget.liabilityToEdit!.id),
          name: drift.Value(_nameController.text.trim()),
          liabilityType: drift.Value(_liabilityType),
          remainingPrincipalSatang: drift.Value(principalSatang),
          monthlyPaymentSatang: drift.Value(monthlyPaymentSatang),
          interestRatePercent: drift.Value(interestRateStr),
          isShortTerm: drift.Value(_isShortTerm),
          linkedAccountId: drift.Value(_linkedAccountId),
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
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final isEditing = widget.liabilityToEdit != null;
    final typeLabels = _getTypeLabels(isThai);

    return AlertDialog(
      title: Text(isEditing
          ? (isThai ? 'แก้ไขรายการหนี้สิน' : 'Edit Debt')
          : (isThai ? 'เพิ่มรายการหนี้สินใหม่' : 'Add New Debt')),
      content: _isLoading
          ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
          : SizedBox(
              width: 480,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: isThai ? 'ชื่อหนี้สิน / สถาบันการเงิน *' : 'Debt Name / Institution *',
                          hintText: isThai ? 'เช่น สินเชื่อบ้าน ธอส, บัตรเครดิต KBank' : 'e.g. Home Loan, Credit Card',
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? (isThai ? 'กรุณาระบุชื่อ' : 'Please enter name')
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _liabilityType,
                        decoration: InputDecoration(
                          labelText: isThai ? 'ประเภทหนี้สิน' : 'Debt Type',
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        items: typeLabels.entries
                            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _liabilityType = val;
                              if (val == 'credit_card') {
                                _isShortTerm = true;
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        initialValue: _linkedAccountId,
                        decoration: InputDecoration(
                          labelText: isThai ? 'เชื่อมโยงกับบัญชีในแอป (ทางเลือก)' : 'Link with App Account (Optional)',
                          hintText: isThai ? 'เลือกเพื่อดึงยอดคงค้างอัตโนมัติ' : 'Select to pull live balance automatically',
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(isThai ? '-- ไม่เชื่อมโยง (กรอกยอดเอง) --' : '-- Not Linked (Manual) --'),
                          ),
                          ..._availableAccounts.map(
                            (a) => DropdownMenuItem<String?>(
                              value: a.id,
                              child: Text('${a.name} (${a.accountType})'),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _linkedAccountId = val;
                          });
                        },
                      ),
                      if (_linkedAccountId != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  isThai
                                      ? 'ระบบจะดึงยอดหนี้คงค้างจริงจากบัญชีนี้อัตโนมัติ เพื่อป้องกันการนับหนี้ซ้อน'
                                      : 'The system pulls live debt balance from this account to avoid double counting.',
                                  style: TextStyle(fontSize: 11.5, color: Colors.blue.shade800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _principalController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        decoration: InputDecoration(
                          labelText: _linkedAccountId != null
                              ? (isThai ? 'เงินต้นเริ่มต้น (บาท)' : 'Initial Principal (THB)')
                              : (isThai ? 'ยอดหนี้คงเหลือ (บาท) *' : 'Remaining Principal (THB) *'),
                          hintText: '0.00',
                          suffixText: isThai ? 'บาท' : 'THB',
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return isThai ? 'กรุณาระบุจำนวนเงิน' : 'Please specify amount';
                          }
                          if (double.tryParse(v.trim()) == null) {
                            return isThai ? 'ตัวเลขไม่ถูกต้อง' : 'Invalid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _monthlyPaymentController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                              decoration: InputDecoration(
                                labelText: isThai ? 'ค่างวดต่อเดือน (บาท) *' : 'Monthly Payment (THB) *',
                                hintText: '0.00',
                                suffixText: isThai ? 'บาท' : 'THB',
                                isDense: true,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return isThai ? 'กรุณาระบุ' : 'Required';
                                }
                                if (double.tryParse(v.trim()) == null) {
                                  return isThai ? 'ตัวเลขไม่ถูกต้อง' : 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _interestRateController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                              decoration: InputDecoration(
                                labelText: isThai ? 'อัตราดอกเบี้ย (%)' : 'Interest Rate (%)',
                                hintText: 'เช่น 5.5',
                                suffixText: isThai ? '% ต่อปี' : '% p.a.',
                                isDense: true,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(isThai ? 'หนี้สินระยะสั้น (ไม่เกิน 1 ปี)' : 'Short-term Debt (<= 1 year)'),
                        subtitle: Text(isThai ? 'ใช้ในการคำนวณอัตราส่วนสภาพคล่องพื้นฐาน' : 'Used for basic liquidity ratio calculation'),
                        value: _isShortTerm,
                        onChanged: (val) => setState(() => _isShortTerm = val),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: isThai ? 'บันทึกเพิ่มเติม (ถ้ามี)' : 'Notes (optional)',
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
          onPressed: _isLoading ? null : _save,
          child: Text(isEditing
              ? (isThai ? 'บันทึกการแก้ไข' : 'Save Changes')
              : (isThai ? 'เพิ่มหนี้สิน' : 'Add Debt')),
        ),
      ],
    );
  }
}
