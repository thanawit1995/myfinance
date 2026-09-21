import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../features/investments/domain/fifo_engine.dart';

class BuySellTradeDialog extends ConsumerStatefulWidget {
  final Asset? initialAsset;
  final bool initialIsBuy;

  const BuySellTradeDialog({
    super.key,
    this.initialAsset,
    this.initialIsBuy = true,
  });

  static Future<bool?> show(
    BuildContext context, {
    Asset? initialAsset,
    bool initialIsBuy = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => BuySellTradeDialog(
        initialAsset: initialAsset,
        initialIsBuy: initialIsBuy,
      ),
    );
  }

  @override
  ConsumerState<BuySellTradeDialog> createState() => _BuySellTradeDialogState();
}

class _BuySellTradeDialogState extends ConsumerState<BuySellTradeDialog> {
  final _formKey = GlobalKey<FormState>();

  late bool _isBuy;
  String? _selectedAssetId;
  String? _selectedAccountId;
  late DateTime _tradeDate;

  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _fxRateController;
  late TextEditingController _feeController;
  late TextEditingController _noteController;

  String _currency = 'THB';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isBuy = widget.initialIsBuy;
    _selectedAssetId = widget.initialAsset?.id;
    _selectedAccountId = widget.initialAsset?.defaultAccountId;
    _currency = widget.initialAsset?.currencyCode ?? 'THB';
    _tradeDate = DateTime.now();

    _quantityController = TextEditingController();
    _priceController = TextEditingController();
    _fxRateController = TextEditingController(text: _currency == 'USD' ? '35.000000' : '1.000000');
    _feeController = TextEditingController(text: '0.00');
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _fxRateController.dispose();
    _feeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAssetId == null || _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกสินทรัพย์และบัญชีทำรายการ')),
      );
      return;
    }

    final currentYear = DateTime.now().year;
    final isPastYear = _tradeDate.year < currentYear;

    if (isPastYear) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('⚠️ คำเตือนปีภาษีที่ผ่านมาแล้ว'),
          content: Text(
            'รายการนี้เกิดขึ้นในปี ค.ศ. ${_tradeDate.year} ซึ่งเป็นปีภาษีที่ผ่านมาแล้ว '
            'การ${_isBuy ? "ซื้อ" : "ขาย"}ย้อนหลังจะกระทบต่อการจัดสรร Lot และกำไรที่รับรู้ (Realized Gain) '
            'ที่คุณอาจยื่นภาษีไปแล้ว คุณต้องการดำเนินการต่อหรือไม่?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('ยกเลิก')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade800),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('ยืนยันดำเนินการ'),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    setState(() => _isLoading = true);

    try {
      final quantity = Decimal.parse(_quantityController.text.trim());
      final priceDouble = double.parse(_priceController.text.trim());
      final priceSatang = (priceDouble * 100).round();
      final fxRate = Decimal.parse(_fxRateController.text.trim());
      final feeDouble = double.tryParse(_feeController.text.trim()) ?? 0.0;
      final feeSatang = (feeDouble * 100).round();

      final invDao = ref.read(investmentsDaoProvider);

      if (_isBuy) {
        await invDao.recordBuyTrade(
          assetId: _selectedAssetId!,
          accountId: _selectedAccountId!,
          tradeDate: _tradeDate,
          quantity: quantity,
          priceOriginalSatang: priceSatang,
          currencyCode: _currency,
          fxRate: fxRate,
          feeThbSatang: feeSatang,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );
      } else {
        await invDao.recordSellTrade(
          assetId: _selectedAssetId!,
          accountId: _selectedAccountId!,
          tradeDate: _tradeDate,
          quantity: quantity,
          priceOriginalSatang: priceSatang,
          currencyCode: _currency,
          fxRate: fxRate,
          feeThbSatang: feeSatang,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is InsufficientQuantityException ? e.message : 'เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(_isBuy ? 'บันทึกการซื้อสินทรัพย์ (Buy)' : 'บันทึกการขายสินทรัพย์ (Sell)'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Toggle Buy / Sell
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('ซื้อ (Buy)'), icon: Icon(Icons.add_shopping_cart)),
                    ButtonSegment(value: false, label: Text('ขาย (Sell)'), icon: Icon(Icons.sell)),
                  ],
                  selected: {_isBuy},
                  onSelectionChanged: (set) => setState(() => _isBuy = set.first),
                ),
                const SizedBox(height: 14),

                // 2. Asset Selector
                FutureBuilder<List<Asset>>(
                  future: ref.read(investmentsDaoProvider).getAssets(),
                  builder: (context, snapshot) {
                    final assets = snapshot.data ?? [];
                    if (_selectedAssetId == null && assets.isNotEmpty) {
                      _selectedAssetId = assets.first.id;
                      _currency = assets.first.currencyCode;
                      _selectedAccountId = assets.first.defaultAccountId;
                    }
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'สินทรัพย์ *', border: OutlineInputBorder()),
                      initialValue: _selectedAssetId,
                      items: assets.map((a) {
                        return DropdownMenuItem(
                          value: a.id,
                          child: Text('${a.symbol} - ${a.name} (${a.currencyCode})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final match = assets.firstWhere((a) => a.id == val);
                          setState(() {
                            _selectedAssetId = val;
                            _currency = match.currencyCode;
                            _selectedAccountId = match.defaultAccountId;
                            _fxRateController.text = _currency == 'USD' ? '35.000000' : '1.000000';
                          });
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 3. Account Selector
                FutureBuilder<List<Account>>(
                  future: ref.read(accountsDaoProvider).getActiveAccounts(),
                  builder: (context, snapshot) {
                    final accounts = snapshot.data ?? [];
                    if (_selectedAccountId == null && accounts.isNotEmpty) {
                      _selectedAccountId = accounts.first.id;
                    }
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: _isBuy ? 'หักเงินจากบัญชี *' : 'รับเงินเข้าบัญชี *',
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: _selectedAccountId,
                      items: accounts.map((a) {
                        return DropdownMenuItem(
                          value: a.id,
                          child: Text('${a.name} (${a.currencyCode})'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedAccountId = val),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 4. Quantity & Price
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'จำนวนหน่วย *',
                          hintText: 'เช่น 100 หรือ 0.05',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'กรุณาระบุจำนวน';
                          try {
                            final d = Decimal.parse(val.trim());
                            if (d <= Decimal.zero) return '> 0';
                          } catch (_) {
                            return 'ตัวเลขไม่ถูกต้อง';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'ราคา/หน่วย ($_currency) *',
                          hintText: 'เช่น 65.50',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'กรุณาระบุราคา';
                          final num = double.tryParse(val.trim());
                          if (num == null || num <= 0) return '> 0';
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 5. FX Rate (if USD or foreign)
                if (_currency != 'THB') ...[
                  TextFormField(
                    controller: _fxRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'อัตราแลกเปลี่ยน (THB ต่อ 1 $_currency) *',
                      hintText: 'เช่น 35.500000',
                      border: const OutlineInputBorder(),
                      helperText: 'ระบบจะล็อกเรตนี้ไว้ในธุรกรรม และบันทึกลงประวัติ FX',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'กรุณาระบุเรต FX';
                      try {
                        final fx = Decimal.parse(val.trim());
                        if (fx <= Decimal.zero) return '> 0';
                      } catch (_) {
                        return 'เรตไม่ถูกต้อง';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                ],

                // 6. Fee (THB) & Trade Date
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _feeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'ค่าธรรมเนียม (บาท)',
                          hintText: 'เช่น 15.00',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(DateFormat('d MMMM yyyy', 'th').format(_tradeDate)),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _tradeDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _tradeDate = picked);
                  },
                ),

                // 7. Summary calculation preview
                Builder(
                  builder: (context) {
                    final q = Decimal.tryParse(_quantityController.text.trim()) ?? Decimal.zero;
                    final p = double.tryParse(_priceController.text.trim()) ?? 0.0;
                    final fx = Decimal.tryParse(_fxRateController.text.trim()) ?? Decimal.one;
                    final fee = double.tryParse(_feeController.text.trim()) ?? 0.0;

                    final origTotal = (q * Decimal.parse(p.toStringAsFixed(2))).toDouble();
                    final thbTotalSatang = (Decimal.parse(origTotal.toStringAsFixed(2)) * fx * Decimal.fromInt(100)).round().toBigInt().toInt() +
                        (_isBuy ? (fee * 100).round() : -(fee * 100).round());

                    final moneyPreview = Money(thbTotalSatang > 0 ? thbTotalSatang : 0);

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_isBuy ? 'ยอดเงินจ่ายสุทธิ (THB):' : 'ยอดเงินรับสุทธิ (THB):',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            moneyPreview.format(symbol: '฿'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _isBuy ? Colors.red.shade700 : Colors.green.shade700,
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
                    hintText: 'เช่น DCA ประจำเดือน',
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
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isBuy ? 'ยืนยันการซื้อ' : 'ยืนยันการขาย'),
        ),
      ],
    );
  }
}
