import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';

class HealthSettingsDialog extends ConsumerStatefulWidget {
  const HealthSettingsDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const HealthSettingsDialog(),
    );
  }

  @override
  ConsumerState<HealthSettingsDialog> createState() => _HealthSettingsDialogState();
}

class _HealthSettingsDialogState extends ConsumerState<HealthSettingsDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _basicLiqController;
  late TextEditingController _emergMonthsController;
  late TextEditingController _dtaController;
  late TextEditingController _dtiController;
  late TextEditingController _savingsController;
  late TextEditingController _invRatioController;
  late TextEditingController _familyReserveController;
  late TextEditingController _medicalCostController;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _basicLiqController = TextEditingController();
    _emergMonthsController = TextEditingController();
    _dtaController = TextEditingController();
    _dtiController = TextEditingController();
    _savingsController = TextEditingController();
    _invRatioController = TextEditingController();
    _familyReserveController = TextEditingController();
    _medicalCostController = TextEditingController();

    _loadExistingSettings();
  }

  @override
  void dispose() {
    _basicLiqController.dispose();
    _emergMonthsController.dispose();
    _dtaController.dispose();
    _dtiController.dispose();
    _savingsController.dispose();
    _invRatioController.dispose();
    _familyReserveController.dispose();
    _medicalCostController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingSettings() async {
    final dao = ref.read(financialHealthDaoProvider);

    final basicLiq = await dao.getSettingByMetric('basic_liquidity');
    final emerg = await dao.getSettingByMetric('emergency_fund');
    final dta = await dao.getSettingByMetric('debt_to_asset');
    final dti = await dao.getSettingByMetric('dti');
    final savings = await dao.getSettingByMetric('savings_rate');
    final inv = await dao.getSettingByMetric('investment_ratio');
    final general = await dao.getSettingByMetric('general_settings');

    if (mounted) {
      setState(() {
        _basicLiqController.text = basicLiq?.targetValue ?? '1.0';
        _emergMonthsController.text = emerg?.targetValue ?? '6.0';
        _dtaController.text = dta?.targetValue ?? '50.0';
        _dtiController.text = dti?.targetValue ?? '40.0';
        _savingsController.text = savings?.targetValue ?? '10.0';
        _invRatioController.text = inv?.targetValue ?? '50.0';

        // Convert satang to Baht for display
        final famSatang = general?.userParam1Satang ?? 0;
        _familyReserveController.text = (famSatang / 100).toStringAsFixed(0);

        final medSatang = general?.userParam2Satang ?? 50000000;
        _medicalCostController.text = (medSatang / 100).toStringAsFixed(0);

        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final dao = ref.read(financialHealthDaoProvider);

    final famBaht = double.tryParse(_familyReserveController.text.trim()) ?? 0;
    final medBaht = double.tryParse(_medicalCostController.text.trim()) ?? 500000;

    await dao.upsertSetting(
      metricCode: 'basic_liquidity',
      targetOperator: '>=',
      targetValue: _basicLiqController.text.trim(),
    );

    await dao.upsertSetting(
      metricCode: 'emergency_fund',
      targetOperator: '>=',
      targetValue: _emergMonthsController.text.trim(),
    );

    await dao.upsertSetting(
      metricCode: 'debt_to_asset',
      targetOperator: '<=',
      targetValue: _dtaController.text.trim(),
    );

    await dao.upsertSetting(
      metricCode: 'dti',
      targetOperator: '<=',
      targetValue: _dtiController.text.trim(),
    );

    await dao.upsertSetting(
      metricCode: 'savings_rate',
      targetOperator: '>=',
      targetValue: _savingsController.text.trim(),
    );

    await dao.upsertSetting(
      metricCode: 'investment_ratio',
      targetOperator: '>=',
      targetValue: _invRatioController.text.trim(),
    );

    await dao.upsertSetting(
      metricCode: 'general_settings',
      targetOperator: 'info',
      targetValue: '0',
      userParam1Satang: (famBaht * 100).round(),
      userParam2Satang: (medBaht * 100).round(),
    );

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.tune, color: Colors.blueGrey),
          SizedBox(width: 8),
          Text('ตั้งค่าเกณฑ์สุขภาพการเงิน'),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: 480,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ปรับแต่งเป้าหมายทางการเงินส่วนบุคคลและพารามิเตอร์ครอบครัว:',
                        style: TextStyle(fontSize: 12.5, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      _buildSectionLabel('1. ด้านสภาพคล่อง'),
                      _buildNumberField(
                        controller: _basicLiqController,
                        label: 'เป้าหมายสภาพคล่องพื้นฐาน (เท่า)',
                        hint: '1.0',
                        suffix: 'เท่า',
                      ),
                      const SizedBox(height: 10),
                      _buildNumberField(
                        controller: _emergMonthsController,
                        label: 'เป้าหมายเงินสำรองฉุกเฉิน (เดือน)',
                        hint: '6.0',
                        suffix: 'เดือน',
                      ),
                      const SizedBox(height: 16),

                      _buildSectionLabel('2. ด้านหนี้สิน'),
                      _buildNumberField(
                        controller: _dtaController,
                        label: 'เพดานหนี้สินต่อสินทรัพย์ (%)',
                        hint: '50.0',
                        suffix: '%',
                      ),
                      const SizedBox(height: 10),
                      _buildNumberField(
                        controller: _dtiController,
                        label: 'เพดานภาระหนี้ต่อรายได้ DTI (%)',
                        hint: '40.0',
                        suffix: '%',
                      ),
                      const SizedBox(height: 16),

                      _buildSectionLabel('3. ด้านการออมและการลงทุน'),
                      _buildNumberField(
                        controller: _savingsController,
                        label: 'เป้าหมายอัตราการออมต่อเดือน (%)',
                        hint: '10.0',
                        suffix: '%',
                      ),
                      const SizedBox(height: 10),
                      _buildNumberField(
                        controller: _invRatioController,
                        label: 'เป้าหมายสัดส่วนสินทรัพย์ลงทุน (%)',
                        hint: '50.0',
                        suffix: '%',
                      ),
                      const SizedBox(height: 16),

                      _buildSectionLabel('4. ด้านความคุ้มครองและครอบครัว'),
                      _buildNumberField(
                        controller: _familyReserveController,
                        label: 'เงินสำรองเผื่อครอบครัว/ผู้อยู่ในอุปการะ (บาท)',
                        hint: '0',
                        suffix: 'บาท',
                      ),
                      const SizedBox(height: 10),
                      _buildNumberField(
                        controller: _medicalCostController,
                        label: 'ประมาณการค่ารักษาพยาบาลโรคร้ายแรง (บาท)',
                        hint: '500,000',
                        suffix: 'บาท',
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
          onPressed: _isLoading ? null : _saveSettings,
          child: const Text('บันทึกการตั้งค่า'),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'กรุณาระบุตัวเลข';
        if (double.tryParse(val.trim()) == null) return 'ตัวเลขไม่ถูกต้อง';
        return null;
      },
    );
  }
}
