import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

class TaxRulesEditDialog extends ConsumerStatefulWidget {
  final int taxYear;
  final TaxRule? existingRule;
  final VoidCallback onSaved;

  const TaxRulesEditDialog({
    super.key,
    required this.taxYear,
    this.existingRule,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required int taxYear,
    TaxRule? existingRule,
    required VoidCallback onSaved,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TaxRulesEditDialog(
        taxYear: taxYear,
        existingRule: existingRule,
        onSaved: onSaved,
      ),
    );
  }

  @override
  ConsumerState<TaxRulesEditDialog> createState() => _TaxRulesEditDialogState();
}

class _TaxRulesEditDialogState extends ConsumerState<TaxRulesEditDialog> {
  late TextEditingController _personalCtrl;
  late TextEditingController _spouseCtrl;
  late TextEditingController _childCtrl;
  late TextEditingController _expenseRateCtrl;
  late TextEditingController _expenseMaxCtrl;
  late TextEditingController _medical406Ctrl;
  late TextEditingController _flat408Ctrl;
  late TextEditingController _socialSecurityCtrl;
  late TextEditingController _lifeInsuranceCtrl;
  late TextEditingController _healthInsuranceCtrl;
  late TextEditingController _thaiEsgCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final rule = widget.existingRule;

    final personalSatang = rule?.personalAllowanceSatang ?? 6000000;
    final spouseSatang = rule?.spouseAllowanceSatang ?? 6000000;
    final childSatang = rule?.childAllowanceSatang ?? 3000000;
    final expRate = rule?.expenseRatePercent ?? '50.0';
    final expMaxSatang = rule?.expenseMaxSatang ?? 10000000;
    final med406 = rule?.flatExpense406MedicalPercent ?? '60.0';
    final flat408 = rule?.flatExpense408Percent ?? '60.0';

    Map<String, dynamic> limits = {};
    if (rule != null && rule.deductionLimitsJson.isNotEmpty) {
      try {
        limits = jsonDecode(rule.deductionLimitsJson) as Map<String, dynamic>;
      } catch (_) {}
    }

    final ssSatang = (limits['socialSecurityMaxSatang'] as num?)?.toInt() ?? 900000;
    final lifeSatang = (limits['lifeInsuranceMaxSatang'] as num?)?.toInt() ?? 10000000;
    final healthSatang = (limits['healthInsuranceMaxSatang'] as num?)?.toInt() ?? 2500000;
    final thaiEsgSatang = (limits['thaiEsgMaxSatang'] as num?)?.toInt() ?? 30000000;

    _personalCtrl = TextEditingController(text: (personalSatang ~/ 100).toString());
    _spouseCtrl = TextEditingController(text: (spouseSatang ~/ 100).toString());
    _childCtrl = TextEditingController(text: (childSatang ~/ 100).toString());
    _expenseRateCtrl = TextEditingController(text: expRate);
    _expenseMaxCtrl = TextEditingController(text: (expMaxSatang ~/ 100).toString());
    _medical406Ctrl = TextEditingController(text: med406);
    _flat408Ctrl = TextEditingController(text: flat408);
    _socialSecurityCtrl = TextEditingController(text: (ssSatang ~/ 100).toString());
    _lifeInsuranceCtrl = TextEditingController(text: (lifeSatang ~/ 100).toString());
    _healthInsuranceCtrl = TextEditingController(text: (healthSatang ~/ 100).toString());
    _thaiEsgCtrl = TextEditingController(text: (thaiEsgSatang ~/ 100).toString());
  }

  @override
  void dispose() {
    _personalCtrl.dispose();
    _spouseCtrl.dispose();
    _childCtrl.dispose();
    _expenseRateCtrl.dispose();
    _expenseMaxCtrl.dispose();
    _medical406Ctrl.dispose();
    _flat408Ctrl.dispose();
    _socialSecurityCtrl.dispose();
    _lifeInsuranceCtrl.dispose();
    _healthInsuranceCtrl.dispose();
    _thaiEsgCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final personalSatang = (int.tryParse(_personalCtrl.text.replaceAll(',', '')) ?? 60000) * 100;
      final spouseSatang = (int.tryParse(_spouseCtrl.text.replaceAll(',', '')) ?? 60000) * 100;
      final childSatang = (int.tryParse(_childCtrl.text.replaceAll(',', '')) ?? 30000) * 100;
      final expRate = double.tryParse(_expenseRateCtrl.text) ?? 50.0;
      final expMaxSatang = (int.tryParse(_expenseMaxCtrl.text.replaceAll(',', '')) ?? 100000) * 100;
      final med406 = double.tryParse(_medical406Ctrl.text) ?? 60.0;
      final flat408 = double.tryParse(_flat408Ctrl.text) ?? 60.0;

      final ssSatang = (int.tryParse(_socialSecurityCtrl.text.replaceAll(',', '')) ?? 9000) * 100;
      final lifeSatang = (int.tryParse(_lifeInsuranceCtrl.text.replaceAll(',', '')) ?? 100000) * 100;
      final healthSatang = (int.tryParse(_healthInsuranceCtrl.text.replaceAll(',', '')) ?? 25000) * 100;
      final thaiEsgSatang = (int.tryParse(_thaiEsgCtrl.text.replaceAll(',', '')) ?? 300000) * 100;

      final limits = {
        'socialSecurityMaxSatang': ssSatang,
        'lifeInsuranceMaxSatang': lifeSatang,
        'healthInsuranceMaxSatang': healthSatang,
        'lifeAndHealthInsuranceCombinedMaxSatang': 10000000,
        'thaiEsgMaxSatang': thaiEsgSatang,
        'rmfMaxSatang': 50000000,
        'ssfMaxSatang': 20000000,
        'providentFundMaxSatang': 50000000,
        'retirementGroupCombinedMaxSatang': 50000000,
        'homeLoanInterestMaxSatang': 10000000,
      };

      final defaultBrackets = widget.existingRule?.bracketsJson ?? '''[
  {"minSatang": 0, "maxSatang": 15000000, "ratePercent": 0.0},
  {"minSatang": 15000001, "maxSatang": 30000000, "ratePercent": 5.0},
  {"minSatang": 30000001, "maxSatang": 50000000, "ratePercent": 10.0},
  {"minSatang": 50000001, "maxSatang": 75000000, "ratePercent": 15.0},
  {"minSatang": 75000001, "maxSatang": 100000000, "ratePercent": 20.0},
  {"minSatang": 100000001, "maxSatang": 200000000, "ratePercent": 25.0},
  {"minSatang": 200000001, "maxSatang": 500000000, "ratePercent": 30.0},
  {"minSatang": 500000001, "maxSatang": null, "ratePercent": 35.0}
]''';

      final foreignRule = widget.existingRule?.foreignRemittanceRuleJson ?? '''{
  "residencyDaysThreshold": 180,
  "pre2024ExemptEnabled": true,
  "principalExemptEnabled": true
}''';

      final now = DateTime.now();
      final companion = TaxRulesCompanion(
        id: drift.Value(widget.existingRule?.id ?? 'tax-rule-${widget.taxYear}-custom'),
        taxYear: drift.Value(widget.taxYear),
        bracketsJson: drift.Value(defaultBrackets.trim()),
        personalAllowanceSatang: drift.Value(personalSatang),
        spouseAllowanceSatang: drift.Value(spouseSatang),
        childAllowanceSatang: drift.Value(childSatang),
        expenseRatePercent: drift.Value(expRate.toStringAsFixed(1)),
        expenseMaxSatang: drift.Value(expMaxSatang),
        flatExpense406MedicalPercent: drift.Value(med406.toStringAsFixed(1)),
        flatExpense408Percent: drift.Value(flat408.toStringAsFixed(1)),
        deductionLimitsJson: drift.Value(jsonEncode(limits)),
        foreignRemittanceRuleJson: drift.Value(foreignRule.trim()),
        isActive: const drift.Value(true),
        createdAt: drift.Value(widget.existingRule?.createdAt ?? now),
        updatedAt: drift.Value(now),
      );

      await ref.read(taxDaoProvider).insertOrUpdateTaxRule(companion);
      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึก: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.tune, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text('แก้ไขกฎและเพดานลดหย่อน ปีภาษี ${widget.taxYear}')),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.brown),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'คุณสามารถปรับเปลี่ยนกฎภาษีและเพดานลดหย่อนได้ตามประกาศล่าสุดของกรมสรรพากร โดยไม่ต้องแก้โค้ดโปรแกรม',
                        style: TextStyle(fontSize: 12, color: Colors.brown),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _buildHeader('ค่าลดหย่อนส่วนบุคคลและครอบครัว (บาท)'),
              _buildNumberField('ลดหย่อนส่วนตัว', _personalCtrl),
              _buildNumberField('ลดหย่อนคู่สมรส (ไม่มีเงินได้)', _spouseCtrl),
              _buildNumberField('ลดหย่อนบุตร (ต่อคน)', _childCtrl),

              const SizedBox(height: 16),
              _buildHeader('การหักค่าใช้จ่ายตามมาตรา 40'),
              Row(
                children: [
                  Expanded(child: _buildNumberField('อัตรา 40(1)+(2) (%)', _expenseRateCtrl, isPercent: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildNumberField('เพดาน 40(1)+(2) (บาท)', _expenseMaxCtrl)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildNumberField('40(6) แพทย์เวชกรรม (%)', _medical406Ctrl, isPercent: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildNumberField('40(8) เหมาทั่วไป (%)', _flat408Ctrl, isPercent: true)),
                ],
              ),

              const SizedBox(height: 16),
              _buildHeader('เพดานค่าลดหย่อนกองทุนและประกัน (บาท)'),
              _buildNumberField('ประกันสังคม (สูงสุด/ปี)', _socialSecurityCtrl),
              _buildNumberField('ประกันชีวิตทั่วไป (สูงสุด/ปี)', _lifeInsuranceCtrl),
              _buildNumberField('ประกันสุขภาพตนเอง (สูงสุด/ปี)', _healthInsuranceCtrl),
              _buildNumberField('กองทุน ThaiESG (สูงสุด/ปี)', _thaiEsgCtrl),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('บันทึกกฎภาษี'),
        ),
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController ctrl, {bool isPercent = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          suffixText: isPercent ? '%' : 'บาท',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
