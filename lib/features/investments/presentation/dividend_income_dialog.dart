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
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DividendIncomeDialog(initialAsset: initialAsset),
      ),
    );
  }

  @override
  ConsumerState<DividendIncomeDialog> createState() => _DividendIncomeDialogState();
}

class _DividendIncomeDialogState extends ConsumerState<DividendIncomeDialog> {
  final _formKey = GlobalKey<FormState>();

  List<Asset> _assets = [];
  List<Account> _accounts = [];
  bool _isLoading = true;
  Decimal _latestUsdFx = Decimal.parse('35.000000');

  String? _selectedAssetId;
  String? _selectedAccountId;
  String _incomeType = 'dividend';
  late DateTime _incomeDate;

  late TextEditingController _grossAmountController;
  late TextEditingController _taxController;
  late TextEditingController _fxRateController;
  late TextEditingController _noteController;

  String _currency = 'THB';
  bool _isForeignIncome = false;

  @override
  void initState() {
    super.initState();
    _incomeDate = DateTime.now();

    _grossAmountController = TextEditingController();
    _taxController = TextEditingController();
    _fxRateController = TextEditingController(text: '1.000000');
    _noteController = TextEditingController();

    _loadData();
  }

  Future<void> _loadData() async {
    final invDao = ref.read(investmentsDaoProvider);
    final accDao = ref.read(accountsDaoProvider);

    final assets = await invDao.getAssets();
    final accounts = await accDao.getActiveAccounts();
    final latestFx = await invDao.getLatestUsdFxRate();

    if (!mounted) return;

    setState(() {
      _assets = assets;
      _accounts = accounts;
      _latestUsdFx = latestFx;
      _isLoading = false;

      // Select initial asset
      Asset? currentAsset = widget.initialAsset;
      if (currentAsset == null && _assets.isNotEmpty) {
        currentAsset = _assets.first;
      }

      if (currentAsset != null) {
        _applyAsset(currentAsset);
      }
    });
  }

  void _applyAsset(Asset asset) {
    _selectedAssetId = asset.id;
    _currency = asset.currencyCode;
    _isForeignIncome = _currency != 'THB' || asset.assetType == 'foreign_stock' || asset.assetType == 'etf';

    if (_currency == 'USD') {
      _fxRateController.text = _latestUsdFx.toString();
    } else if (_currency == 'THB') {
      _fxRateController.text = '1.000000';
    }

    // Pick matching account
    if (asset.defaultAccountId.isNotEmpty && _accounts.any((a) => a.id == asset.defaultAccountId)) {
      _selectedAccountId = asset.defaultAccountId;
    } else if (_currency != 'THB') {
      final foreignAcc = _accounts.where((a) => a.currencyCode == _currency || a.accountType == 'offshore' || a.accountType == 'fcd').firstOrNull;
      _selectedAccountId = foreignAcc?.id ?? (_accounts.isNotEmpty ? _accounts.first.id : null);
    } else {
      final thbAcc = _accounts.where((a) => a.currencyCode == 'THB' && a.accountType == 'bank').firstOrNull;
      _selectedAccountId = thbAcc?.id ?? (_accounts.isNotEmpty ? _accounts.first.id : null);
    }

    _recalculateTax();
  }

  void _recalculateTax() {
    final gross = double.tryParse(_grossAmountController.text.trim()) ?? 0.0;
    if (gross > 0) {
      // 10% for Thai stocks, 15% for Foreign stocks
      final rate = _isForeignIncome ? 0.15 : 0.10;
      _taxController.text = (gross * rate).toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _grossAmountController.dispose();
    _taxController.dispose();
    _fxRateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onGrossChanged() {
    _recalculateTax();
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
      dividendTaxCreditSatang: 0,
      netAmountThbSatang: netAmountThbSatang,
      isForeignIncome: _isForeignIncome,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    // Refresh version counter
    ref.read(transactionsVersionProvider.notifier).state++;

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      appBar: AppBar(
        title: Text(isThai ? 'บันทึกเงินปันผล/ดอกเบี้ย' : 'Record Dividend / Interest'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Asset
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'สินทรัพย์ *', border: OutlineInputBorder()),
                        value: _selectedAssetId,
                        items: _assets.map((a) {
                          return DropdownMenuItem(value: a.id, child: Text('${a.symbol} - ${a.name} (${a.currencyCode})'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final match = _assets.firstWhere((a) => a.id == val);
                            setState(() {
                              _applyAsset(match);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // 2. Account
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'รับเงินสุทธิเข้าบัญชี *', border: OutlineInputBorder()),
                        value: _selectedAccountId,
                        items: _accounts.map((a) {
                          return DropdownMenuItem(value: a.id, child: Text('${a.name} (${a.currencyCode})'));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedAccountId = val),
                      ),
                      const SizedBox(height: 12),

                      // 3. Income Type
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'ประเภทรายได้', border: OutlineInputBorder()),
                        value: _incomeType,
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
                                  helperText: 'อัปเดตล่าสุด',
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
                          helperText: _isForeignIncome ? 'อัตรา 15% สำหรับหุ้นต่างประเทศ' : 'อัตรา 10% สำหรับหุ้นไทย',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),

                      // 6. Checkbox: Is Foreign Income
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('เป็นเงินได้จากต่างประเทศ (Foreign Income)'),
                        subtitle: Text(
                          _isForeignIncome
                              ? 'ภาษี 15% หัก ณ ต่างประเทศ (ภาษีไทยจะประเมินเมื่อนำเงินกลับเข้าประเทศ)'
                              : 'ภาษี 10% หัก ณ ที่จ่ายไทย (สามารถเลือก Final Tax หรือนำไปยื่นรวมปลายปีได้)',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                        ),
                        value: _isForeignIncome,
                        onChanged: (val) {
                          setState(() {
                            _isForeignIncome = val ?? false;
                            _recalculateTax();
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      // 7. Net preview
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
                              color: isDark
                                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.greenAccent.withValues(alpha: 0.3)
                                    : Colors.green.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isThai ? 'ยอดเงินสุทธิเข้าบัญชี (THB):' : 'Net Received (THB):',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? theme.colorScheme.onSurface : Colors.black87,
                                  ),
                                ),
                                Text(
                                  moneyPreview.format(symbol: '฿'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark ? Colors.greenAccent : Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      // 8. Note
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'บันทึกช่วยจำ (Note)',
                          hintText: 'เช่น เงินปันผลประจำไตรมาส 1/2026',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _isLoading ? null : _submit,
            child: Text(
              isThai ? 'บันทึกเงินปันผล' : 'Record Dividend',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
