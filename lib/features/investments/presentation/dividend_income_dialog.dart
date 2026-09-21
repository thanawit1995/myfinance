import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';

class DividendIncomeDialog extends ConsumerStatefulWidget {
  final Asset? initialAsset;

  const DividendIncomeDialog({super.key, this.initialAsset});

  static Future<bool?> show(BuildContext context, {Asset? initialAsset}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DividendIncomeDialog(initialAsset: initialAsset),
    );
  }

  @override
  ConsumerState<DividendIncomeDialog> createState() => _DividendIncomeDialogState();
}

class _DividendIncomeDialogState extends ConsumerState<DividendIncomeDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedAssetId;
  String? _selectedAccountId;
  String _incomeType = 'dividend';
  late DateTime _incomeDate;

  late TextEditingController _grossAmountController;
  late TextEditingController _taxController;
  late TextEditingController _taxCreditController;
  late TextEditingController _fxRateController;
  late TextEditingController _noteController;

  String _currency = 'THB';
  bool _isForeignIncome = false;
  double _corporateTaxRate = 0.20; // Default 20% corporate tax rate for Thai companies

  @override
  void initState() {
    super.initState();
    _selectedAssetId = widget.initialAsset?.id;
    _selectedAccountId = widget.initialAsset?.defaultAccountId;
    _currency = widget.initialAsset?.currencyCode ?? 'THB';
    _isForeignIncome = _currency != 'THB' || widget.initialAsset?.assetType == 'foreign_stock' || widget.initialAsset?.assetType == 'etf';
    _incomeDate = DateTime.now();

    _grossAmountController = TextEditingController();
    _taxController = TextEditingController();
    _taxCreditController = TextEditingController();
    _fxRateController = TextEditingController(text: _currency == 'USD' ? '35.000000' : '1.000000');
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _grossAmountController.dispose();
    _taxController.dispose();
    _taxCreditController.dispose();
    _fxRateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onGrossChanged() {
    final gross = double.tryParse(_grossAmountController.text.trim()) ?? 0.0;
    if (gross > 0) {
      // 10% Withholding tax standard for dividends
      if (_taxController.text.isEmpty) {
        _taxController.text = (gross * 0.10).toStringAsFixed(2);
      }
      // Auto calculate Thai tax credit: gross * (t / (1 - t))
      if (!_isForeignIncome && _corporateTaxRate > 0) {
        final credit = gross * (_corporateTaxRate / (1 - _corporateTaxRate));
        _taxCreditController.text = credit.toStringAsFixed(2);
      }
    }
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAssetId == null || _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกสินทรัพย์และบัญชีรับเงิน')),
      );
      return;
    }

    final grossDouble = double.parse(_grossAmountController.text.trim());
    final grossSatang = (grossDouble * 100).round();

    final taxDouble = double.tryParse(_taxController.text.trim()) ?? 0.0;
    final taxSatang = (taxDouble * 100).round();

    final creditDouble = _isForeignIncome ? 0.0 : (double.tryParse(_taxCreditController.text.trim()) ?? 0.0);
    final creditSatang = (creditDouble * 100).round();

    final fxRate = Decimal.parse(_fxRateController.text.trim());
    final grossThbSatang = (Decimal.fromInt(grossSatang) * fxRate).round().toBigInt().toInt();
    final taxThbSatang = (Decimal.fromInt(taxSatang) * fxRate).round().toBigInt().toInt();
    final netAmountThbSatang = grossThbSatang - taxThbSatang;

    final invDao = ref.read(investmentsDaoProvider);

    await invDao.recordInvestmentIncome(
      assetId: _selectedAssetId!,
      accountId: _selectedAccountId!,
      incomeType: _incomeType,
      incomeDate: _incomeDate,
      grossAmountOriginalSatang: grossSatang,
      currencyCode: _currency,
      fxRate: fxRate,
      withholdingTaxThbSatang: taxThbSatang,
      dividendTaxCreditSatang: creditSatang,
      netAmountThbSatang: netAmountThbSatang,
      isForeignIncome: _isForeignIncome,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('บันทึกรายได้จากการลงทุน'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Asset
                FutureBuilder<List<Asset>>(
                  future: ref.read(investmentsDaoProvider).getAssets(),
                  builder: (context, snapshot) {
                    final assets = snapshot.data ?? [];
                    if (_selectedAssetId == null && assets.isNotEmpty) {
                      _selectedAssetId = assets.first.id;
                      _currency = assets.first.currencyCode;
                      _selectedAccountId = assets.first.defaultAccountId;
                      _isForeignIncome = _currency != 'THB' || assets.first.assetType == 'foreign_stock' || assets.first.assetType == 'etf';
                    }
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'สินทรัพย์ *', border: OutlineInputBorder()),
                      initialValue: _selectedAssetId,
                      items: assets.map((a) {
                        return DropdownMenuItem(value: a.id, child: Text('${a.symbol} - ${a.name} (${a.currencyCode})'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final match = assets.firstWhere((a) => a.id == val);
                          setState(() {
                            _selectedAssetId = val;
                            _currency = match.currencyCode;
                            _selectedAccountId = match.defaultAccountId;
                            _isForeignIncome = _currency != 'THB' || match.assetType == 'foreign_stock' || match.assetType == 'etf';
                            _fxRateController.text = _currency == 'USD' ? '35.000000' : '1.000000';
                            _onGrossChanged();
                          });
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 2. Account
                FutureBuilder<List<Account>>(
                  future: ref.read(accountsDaoProvider).getActiveAccounts(),
                  builder: (context, snapshot) {
                    final accounts = snapshot.data ?? [];
                    if (_selectedAccountId == null && accounts.isNotEmpty) {
                      _selectedAccountId = accounts.first.id;
                    }
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'รับเงินสุทธิเข้าบัญชี *', border: OutlineInputBorder()),
                      initialValue: _selectedAccountId,
                      items: accounts.map((a) {
                        return DropdownMenuItem(value: a.id, child: Text('${a.name} (${a.currencyCode})'));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedAccountId = val),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 3. Income Type
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'ประเภทรายได้', border: OutlineInputBorder()),
                  initialValue: _incomeType,
                  items: const [
                    DropdownMenuItem(value: 'dividend', child: Text('เงินปันผล (Dividend)')),
                    DropdownMenuItem(value: 'interest', child: Text('ดอกเบี้ย (Interest)')),
                    DropdownMenuItem(value: 'bond_coupon', child: Text('คูปองพันธบัตร / หุ้นกู้')),
                    DropdownMenuItem(value: 'other', child: Text('อื่นๆ (Other)')),
                  ],
                  onChanged: (val) => setState(() => _incomeType = val ?? 'dividend'),
                ),
                const SizedBox(height: 12),

                // 4. Gross Amount & FX Rate
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _grossAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        decoration: InputDecoration(
                          labelText: 'ยอดรวมก่อนหักภาษี ($_currency) *',
                          hintText: 'เช่น 1000.00',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'กรุณาระบุยอดรวม';
                          final n = double.tryParse(val.trim());
                          if (n == null || n <= 0) return '> 0';
                          return null;
                        },
                        onChanged: (_) => _onGrossChanged(),
                      ),
                    ),
                    if (_currency != 'THB') ...[
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _fxRateController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                          decoration: const InputDecoration(
                            labelText: 'เรต FX *',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // 5. Withholding Tax
                TextFormField(
                  controller: _taxController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  decoration: InputDecoration(
                    labelText: 'ภาษีหัก ณ ที่จ่าย ($_currency)',
                    hintText: 'เช่น 100.00',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),

                // 6. Checkbox: Is Foreign Income
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('เป็นเงินได้จากต่างประเทศ (Foreign Income)'),
                  subtitle: const Text('เงินได้ต่างประเทศจะไม่มีสิทธิ์เครดิตภาษีตามกฎสรรพากรไทย', style: TextStyle(fontSize: 12)),
                  value: _isForeignIncome,
                  onChanged: (val) {
                    setState(() {
                      _isForeignIncome = val ?? false;
                      if (_isForeignIncome) {
                        _taxCreditController.clear();
                      } else {
                        _onGrossChanged();
                      }
                    });
                  },
                ),
                const SizedBox(height: 8),

                // 7. Thai Dividend Tax Credit (Hidden if foreign income!)
                if (!_isForeignIncome && _incomeType == 'dividend') ...[
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('เครดิตภาษีเงินปันผล (มาตรา 47 ทวิ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<double>(
                                  decoration: const InputDecoration(labelText: 'อัตราภาษีนิติบุคคล', border: OutlineInputBorder()),
                                  initialValue: _corporateTaxRate,
                                  items: const [
                                    DropdownMenuItem(value: 0.20, child: Text('20% (เครดิต 25%)')),
                                    DropdownMenuItem(value: 0.25, child: Text('25% (เครดิต 33%)')),
                                    DropdownMenuItem(value: 0.30, child: Text('30% (เครดิต 42%)')),
                                    DropdownMenuItem(value: 0.0, child: Text('0% (ไม่ได้รับเครดิต)')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      _corporateTaxRate = val;
                                      _onGrossChanged();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: _taxCreditController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                                  decoration: const InputDecoration(
                                    labelText: 'ยอดเครดิตภาษี (บาท)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // 8. Net preview
                Builder(
                  builder: (context) {
                    final gross = double.tryParse(_grossAmountController.text.trim()) ?? 0.0;
                    final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
                    final fx = Decimal.tryParse(_fxRateController.text.trim()) ?? Decimal.one;

                    final netOrigSatang = ((gross - tax) * 100).round();
                    final netThbSatang = (Decimal.fromInt(netOrigSatang) * fx).round().toBigInt().toInt();
                    final moneyPreview = Money(netThbSatang > 0 ? netThbSatang : 0);

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ยอดเงินสุทธิเข้าบัญชี (THB):', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            moneyPreview.format(symbol: '฿'),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green.shade800),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // 9. Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'บันทึกช่วยจำ (Note)',
                    hintText: 'เช่น เงินปันผลประจำไตรมาส 1/2026',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('ยกเลิก')),
        FilledButton(onPressed: _submit, child: const Text('บันทึกรายได้')),
      ],
    );
  }
}
