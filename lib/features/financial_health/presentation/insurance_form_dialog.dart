import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';

class InsuranceFormDialog extends ConsumerStatefulWidget {
  final InsurancePolicy? policyToEdit;

  const InsuranceFormDialog({super.key, this.policyToEdit});

  static Future<bool?> show(BuildContext context, {InsurancePolicy? policy}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => InsuranceFormDialog(policyToEdit: policy),
    );
  }

  @override
  ConsumerState<InsuranceFormDialog> createState() => _InsuranceFormDialogState();
}

class _InsuranceFormDialogState extends ConsumerState<InsuranceFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _sumInsuredController;
  late TextEditingController _medicalCoverageController;
  late TextEditingController _annualPremiumController;
  late TextEditingController _noteController;

  String _insuranceType = 'life';
  DateTime? _dueDate;

  Map<String, String> _getTypeLabels(bool isThai) => {
    'life': isThai ? 'ประกันชีวิต (Life)' : 'Life Insurance',
    'health': isThai ? 'ประกันสุขภาพ (Health)' : 'Health Insurance',
    'accident': isThai ? 'ประกันอุบัติเหตุ (Accident)' : 'Accident Insurance',
    'critical_illness': isThai ? 'ประกันโรคร้ายแรง (CI)' : 'Critical Illness (CI)',
    'savings': isThai ? 'ประกันออมทรัพย์ (Endowment)' : 'Savings / Endowment',
    'other': isThai ? 'อื่นๆ' : 'Other',
  };

  @override
  void initState() {
    super.initState();
    final item = widget.policyToEdit;
    _nameController = TextEditingController(text: item?.policyName ?? '');
    _sumInsuredController = TextEditingController(
      text: item != null ? (item.sumInsuredSatang / 100).toStringAsFixed(2) : '',
    );
    _medicalCoverageController = TextEditingController(
      text: item != null ? (item.medicalCoverageSatang / 100).toStringAsFixed(2) : '',
    );
    _annualPremiumController = TextEditingController(
      text: item != null ? (item.annualPremiumSatang / 100).toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: item?.note ?? '');

    _insuranceType = item?.insuranceType ?? 'life';
    _dueDate = item?.dueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sumInsuredController.dispose();
    _medicalCoverageController.dispose();
    _annualPremiumController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final dao = ref.read(insuranceDaoProvider);
    final sumInsuredBaht = double.tryParse(_sumInsuredController.text.trim()) ?? 0;
    final medCoverageBaht = double.tryParse(_medicalCoverageController.text.trim()) ?? 0;
    final annualPremiumBaht = double.tryParse(_annualPremiumController.text.trim()) ?? 0;

    final sumInsuredSatang = (sumInsuredBaht * 100).round();
    final medCoverageSatang = (medCoverageBaht * 100).round();
    final annualPremiumSatang = (annualPremiumBaht * 100).round();

    if (widget.policyToEdit == null) {
      // Create new
      await dao.createPolicy(
        InsurancePoliciesCompanion.insert(
          id: const Uuid().v4(),
          policyName: _nameController.text.trim(),
          insuranceType: _insuranceType,
          sumInsuredSatang: sumInsuredSatang,
          medicalCoverageSatang: medCoverageSatang,
          annualPremiumSatang: annualPremiumSatang,
          dueDate: drift.Value(_dueDate),
          note: drift.Value(_noteController.text.trim().isEmpty ? null : _noteController.text.trim()),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } else {
      // Update existing
      await dao.updatePolicy(
        InsurancePoliciesCompanion(
          id: drift.Value(widget.policyToEdit!.id),
          policyName: drift.Value(_nameController.text.trim()),
          insuranceType: drift.Value(_insuranceType),
          sumInsuredSatang: drift.Value(sumInsuredSatang),
          medicalCoverageSatang: drift.Value(medCoverageSatang),
          annualPremiumSatang: drift.Value(annualPremiumSatang),
          dueDate: drift.Value(_dueDate),
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
    final isEditing = widget.policyToEdit != null;
    final typeLabels = _getTypeLabels(isThai);

    return AlertDialog(
      title: Text(isEditing
          ? (isThai ? 'แก้ไขกรมธรรม์ประกัน' : 'Edit Insurance Policy')
          : (isThai ? 'เพิ่มกรมธรรม์ประกันใหม่' : 'Add New Insurance Policy')),
      content: SizedBox(
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
                    labelText: isThai ? 'ชื่อแผนประกัน / กรมธรรม์ / บริษัท *' : 'Policy Name / Insurer *',
                    hintText: isThai ? 'เช่น AIA สุขภาพเหมาจ่าย, เมืองไทยประกันชีวิต 10/1' : 'e.g. AIA Health, Muang Thai Life',
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? (isThai ? 'กรุณาระบุชื่อ' : 'Please specify policy name')
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _insuranceType,
                  decoration: InputDecoration(
                    labelText: isThai ? 'ประเภทประกัน' : 'Insurance Type',
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  items: typeLabels.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _insuranceType = val);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sumInsuredController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        decoration: InputDecoration(
                          labelText: isThai ? 'ทุนประกันชีวิต (บาท)' : 'Life Sum Insured (THB)',
                          hintText: '0.00',
                          suffixText: isThai ? 'บาท' : 'THB',
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _medicalCoverageController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        decoration: InputDecoration(
                          labelText: isThai ? 'วงเงินคุ้มครองสุขภาพ/โรคร้าย' : 'Medical / CI Coverage',
                          hintText: '0.00',
                          suffixText: isThai ? 'บาท' : 'THB',
                          isDense: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _annualPremiumController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        decoration: InputDecoration(
                          labelText: isThai ? 'เบี้ยประกันต่อปี (บาท) *' : 'Annual Premium (THB) *',
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
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: _pickDueDate,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          _dueDate != null
                              ? DateFormat('dd/MM/yyyy').format(_dueDate!)
                              : (isThai ? 'วันครบกำหนดชำระ' : 'Due Date'),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: isThai
                        ? 'บันทึกเพิ่มเติม (เช่น เลขกรมธรรม์, ผู้รับผลประโยชน์)'
                        : 'Notes (e.g. policy no., beneficiary)',
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
          onPressed: _save,
          child: Text(isEditing
              ? (isThai ? 'บันทึกการแก้ไข' : 'Save Changes')
              : (isThai ? 'เพิ่มกรมธรรม์' : 'Add Policy')),
        ),
      ],
    );
  }
}
