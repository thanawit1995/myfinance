import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/theme/vault_theme.dart';

class InsurancePolicyFormDialog extends ConsumerStatefulWidget {
  final InsurancePolicy? existingPolicy;

  const InsurancePolicyFormDialog({super.key, this.existingPolicy});

  static Future<bool?> show(BuildContext context, {InsurancePolicy? existingPolicy}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => InsurancePolicyFormDialog(existingPolicy: existingPolicy),
    );
  }

  @override
  ConsumerState<InsurancePolicyFormDialog> createState() => _InsurancePolicyFormDialogState();
}

class _InsurancePolicyFormDialogState extends ConsumerState<InsurancePolicyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _nameController;
  late TextEditingController _annualPremiumController;
  late TextEditingController _sumInsuredController;
  late TextEditingController _medicalCoverageController;
  late TextEditingController _totalPeriodsController;
  late TextEditingController _dueDayController;
  late TextEditingController _noteController;

  late String _insuranceType;
  int? _selectedDueMonth;

  final List<String> _monthNamesTh = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingPolicy;
    _nameController = TextEditingController(text: p?.policyName ?? '');
    _insuranceType = p?.insuranceType ?? 'savings';
    _annualPremiumController = TextEditingController(
      text: p != null ? (p.annualPremiumSatang / 100.0).toStringAsFixed(0) : '',
    );
    _sumInsuredController = TextEditingController(
      text: p != null ? (p.sumInsuredSatang / 100.0).toStringAsFixed(0) : '',
    );
    _medicalCoverageController = TextEditingController(
      text: p != null && p.medicalCoverageSatang > 0 ? (p.medicalCoverageSatang / 100.0).toStringAsFixed(0) : '',
    );
    _totalPeriodsController = TextEditingController(
      text: p != null ? p.totalPeriods.toString() : '15',
    );
    _dueDayController = TextEditingController(
      text: p?.paymentDueDay?.toString() ?? '5',
    );
    _selectedDueMonth = p?.paymentDueMonth ?? 10; // Default October
    _noteController = TextEditingController(text: p?.note ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _annualPremiumController.dispose();
    _sumInsuredController.dispose();
    _medicalCoverageController.dispose();
    _totalPeriodsController.dispose();
    _dueDayController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final dao = ref.read(insuranceDaoProvider);
    final now = DateTime.now();

    final premiumThb = double.tryParse(_annualPremiumController.text.replaceAll(',', '')) ?? 0.0;
    final premiumSatang = (premiumThb * 100).round();

    final sumInsuredThb = double.tryParse(_sumInsuredController.text.replaceAll(',', '')) ?? 0.0;
    final sumInsuredSatang = (sumInsuredThb * 100).round();

    final medicalThb = double.tryParse(_medicalCoverageController.text.replaceAll(',', '')) ?? 0.0;
    final medicalSatang = (medicalThb * 100).round();

    final totalPeriods = int.tryParse(_totalPeriodsController.text.trim()) ?? 1;
    final dueDay = int.tryParse(_dueDayController.text.trim());

    if (widget.existingPolicy == null) {
      final newId = _uuid.v4();
      await dao.createPolicy(
        InsurancePoliciesCompanion.insert(
          id: newId,
          policyName: _nameController.text.trim(),
          insuranceType: _insuranceType,
          sumInsuredSatang: sumInsuredSatang,
          medicalCoverageSatang: medicalSatang,
          annualPremiumSatang: premiumSatang,
          totalPeriods: drift.Value(totalPeriods),
          paymentDueDay: drift.Value(dueDay),
          paymentDueMonth: drift.Value(_selectedDueMonth),
          note: drift.Value(_noteController.text.trim().isEmpty ? null : _noteController.text.trim()),
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      await dao.updatePolicy(
        InsurancePoliciesCompanion(
          id: drift.Value(widget.existingPolicy!.id),
          policyName: drift.Value(_nameController.text.trim()),
          insuranceType: drift.Value(_insuranceType),
          sumInsuredSatang: drift.Value(sumInsuredSatang),
          medicalCoverageSatang: drift.Value(medicalSatang),
          annualPremiumSatang: drift.Value(premiumSatang),
          totalPeriods: drift.Value(totalPeriods),
          paymentDueDay: drift.Value(dueDay),
          paymentDueMonth: drift.Value(_selectedDueMonth),
          note: drift.Value(_noteController.text.trim().isEmpty ? null : _noteController.text.trim()),
          updatedAt: drift.Value(now),
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบกรมธรรม์'),
        content: Text('คุณต้องการลบกรมธรรม์ "${widget.existingPolicy!.policyName}" ใช่หรือไม่? (ประวัติการชำระเงินเดิมจะไม่ถูกลบ)'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ยืนยันลบ'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(insuranceDaoProvider).deletePolicy(widget.existingPolicy!.id);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingPolicy != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 520,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
              child: Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit_note_rounded : Icons.add_moderator_rounded,
                    color: VaultTheme.accent(context),
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEdit ? 'แก้ไขกรมธรรม์ประกันภัย' : 'เพิ่มกรมธรรม์ประกันภัย',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: VaultTheme.primaryText(context),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Form Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Policy Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'ชื่อกรมธรรม์ *',
                          hintText: 'เช่น เมืองไทยประกันชีวิต ออมมั่งคั่ง 15/20',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'กรุณากรอกชื่อกรมธรรม์' : null,
                      ),
                      const SizedBox(height: 14),

                      // 2. Insurance Type
                      DropdownButtonFormField<String>(
                        initialValue: _insuranceType,
                        decoration: InputDecoration(
                          labelText: 'ประเภทประกันภัย *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'savings', child: Text('ประกันออมทรัพย์ / สะสมทรัพย์')),
                          DropdownMenuItem(value: 'life', child: Text('ประกันชีวิต (คุ้มครองการเสียชีวิต)')),
                          DropdownMenuItem(value: 'health', child: Text('ประกันสุขภาพ / ค่ารักษาพยาบาล')),
                          DropdownMenuItem(value: 'critical_illness', child: Text('ประกันโรคร้ายแรง')),
                          DropdownMenuItem(value: 'accident', child: Text('ประกันอุบัติเหตุ (PA)')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _insuranceType = v);
                        },
                      ),
                      const SizedBox(height: 14),

                      // 3. Annual Premium & Sum Insured (2 columns)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _annualPremiumController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                              decoration: InputDecoration(
                                labelText: 'เบี้ยประกันต่อปี (บาท) *',
                                hintText: '45000',
                                suffixText: '฿',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'กรุณาระบุเบี้ย';
                                if (double.tryParse(v) == null) return 'ตัวเลขไม่ถูกต้อง';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _sumInsuredController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                              decoration: InputDecoration(
                                labelText: 'ทุนประกัน / คุ้มครอง (บาท)',
                                hintText: '100000',
                                suffixText: '฿',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 4. Total Periods & Payment Due Date
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _totalPeriodsController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: 'จำนวนงวดทั้งหมด',
                                hintText: '15',
                                suffixText: 'งวด/ปี',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _dueDayController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: 'วันที่ชำระ',
                                hintText: '5',
                                suffixText: 'ของเดือน',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<int>(
                              initialValue: _selectedDueMonth,
                              decoration: InputDecoration(
                                labelText: 'เดือนที่ชำระ',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: List.generate(12, (index) {
                                return DropdownMenuItem(
                                  value: index + 1,
                                  child: Text(_monthNamesTh[index], style: const TextStyle(fontSize: 13)),
                                );
                              }),
                              onChanged: (v) => setState(() => _selectedDueMonth = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 5. Notes
                      TextFormField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'หมายเหตุเพิ่มเติม (ถ้ามี)',
                          hintText: 'เช่น เลขที่กรมธรรม์, ช่องทางชำระเงิน, ตัวแทนดูแล',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  if (isEdit)
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('ลบ'),
                      onPressed: _delete,
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('ยกเลิก'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: VaultTheme.accent(context),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(isEdit ? 'บันทึกการแก้ไข' : 'เพิ่มกรมธรรม์'),
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
