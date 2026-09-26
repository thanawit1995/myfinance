import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../features/investments/domain/fifo_engine.dart';
import '../../../../core/theme/vault_theme.dart';
import 'asset_form_dialog.dart';

class BuySellTradeScreen extends ConsumerStatefulWidget {
  final Asset? initialAsset;
  final bool initialIsBuy;

  const BuySellTradeScreen({
    super.key,
    this.initialAsset,
    this.initialIsBuy = true,
  });

  static Future<bool?> show(
    BuildContext context, {
    Asset? initialAsset,
    bool initialIsBuy = true,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BuySellTradeScreen(
          initialAsset: initialAsset,
          initialIsBuy: initialIsBuy,
        ),
      ),
    );
  }

  @override
  ConsumerState<BuySellTradeScreen> createState() => _BuySellTradeScreenState();
}

typedef BuySellTradeDialog = BuySellTradeScreen;

class _BuySellTradeScreenState extends ConsumerState<BuySellTradeScreen> {
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
  List<Asset> _assets = [];
  List<Account> _accounts = [];
  bool _isDataLoaded = false;

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

    _loadData();
  }

  Future<void> _loadData() async {
    final assets = await ref.read(investmentsDaoProvider).getAssets();
    final accounts = await ref.read(accountsDaoProvider).getActiveAccounts();
    if (mounted) {
      setState(() {
        _assets = assets;
        _accounts = accounts;

        if (_selectedAssetId == null || !assets.any((a) => a.id == _selectedAssetId)) {
          _selectedAssetId = assets.isNotEmpty ? assets.first.id : null;
        }

        if (_selectedAssetId != null) {
          final matchedAsset = assets.firstWhere((a) => a.id == _selectedAssetId);
          _currency = matchedAsset.currencyCode;
          _fxRateController.text = _currency == 'USD' ? '35.000000' : '1.000000';
          _selectedAccountId ??= matchedAsset.defaultAccountId;
        }

        if (_selectedAccountId == null || !accounts.any((a) => a.id == _selectedAccountId)) {
          _selectedAccountId = accounts.isNotEmpty ? accounts.first.id : null;
        }

        _isDataLoaded = true;
      });
    }
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

  static const _thaiFullMonths = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
  ];
  static const _enMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  String _formatTradeDate(DateTime d, bool isThai) {
    final m = isThai ? _thaiFullMonths[d.month - 1] : _enMonths[d.month - 1];
    return '${d.day} $m ${d.year}';
  }

  Future<void> _submit() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAssetId == null || _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isThai ? 'กรุณาเลือกสินทรัพย์และบัญชีทำรายการ' : 'Please select an asset and an account')),
      );
      return;
    }

    final currentYear = DateTime.now().year;
    final isPastYear = _tradeDate.year < currentYear;

    if (isPastYear) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isThai ? '⚠️ คำเตือนปีภาษีที่ผ่านมาแล้ว' : '⚠️ Past Tax Year Warning'),
          content: Text(
            isThai
                ? 'รายการนี้เกิดขึ้นในปี ค.ศ. ${_tradeDate.year} ซึ่งเป็นปีภาษีที่ผ่านมาแล้ว '
                    'การ${_isBuy ? "ซื้อ" : "ขาย"}ย้อนหลังจะกระทบต่อการจัดสรร Lot และกำไรที่รับรู้ (Realized Gain) '
                    'ที่คุณอาจยื่นภาษีไปแล้ว คุณต้องการดำเนินการต่อหรือไม่?'
                : 'This transaction occurred in ${_tradeDate.year}, which is a past tax year. '
                    'Recording past ${_isBuy ? "purchases" : "sales"} retroactively affects lot allocation and Realized P&L '
                    'that may have already been filed. Do you wish to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade800),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(isThai ? 'ยืนยันดำเนินการ' : 'Proceed'),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    setState(() => _isLoading = true);

    try {
      final quantity = Decimal.parse(_quantityController.text.trim());
      final priceDecimal = Decimal.parse(_priceController.text.trim());
      final priceSatang = (priceDecimal * Decimal.fromInt(100)).round().toBigInt().toInt();
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
          pricePerUnitOriginal: priceDecimal,
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
          pricePerUnitOriginal: priceDecimal,
          currencyCode: _currency,
          fxRate: fxRate,
          feeThbSatang: feeSatang,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );
      }

      ref.read(transactionsVersionProvider.notifier).state++;

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is InsufficientQuantityException ? e.message : (isThai ? 'เกิดข้อผิดพลาด: $e' : 'Error: $e')),
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
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      appBar: AppBar(
        backgroundColor: VaultTheme.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          _isBuy
              ? (isThai ? 'บันทึกการซื้อสินทรัพย์ (Buy)' : 'Buy Asset')
              : (isThai ? 'บันทึกการขายสินทรัพย์ (Sell)' : 'Sell Asset'),
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: VaultTheme.primaryText(context),
          ),
        ),
      ),
      body: !_isDataLoaded
          ? Center(child: CircularProgressIndicator(color: VaultTheme.accent(context)))
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      // 1. Toggle Buy / Sell
                      SegmentedButton<bool>(
                        segments: [
                          ButtonSegment(
                            value: true,
                            label: Text(isThai ? 'ซื้อ (Buy)' : 'Buy'),
                            icon: const Icon(Icons.add_shopping_cart),
                          ),
                          ButtonSegment(
                            value: false,
                            label: Text(isThai ? 'ขาย (Sell)' : 'Sell'),
                            icon: const Icon(Icons.sell),
                          ),
                        ],
                        selected: {_isBuy},
                        onSelectionChanged: (set) => setState(() => _isBuy = set.first),
                      ),
                      const SizedBox(height: 14),

                      // 2. Asset Selector
                      if (_assets.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: VaultTheme.surfaceSubtle(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: VaultTheme.border(context)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                isThai ? 'ยังไม่มีสินทรัพย์ในระบบ' : 'No assets in system yet',
                                style: TextStyle(
                                  fontFamily: VaultTheme.fontFamily,
                                  fontSize: 13,
                                  color: VaultTheme.secondaryText(context),
                                ),
                              ),
                              const SizedBox(height: 10),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(backgroundColor: VaultTheme.accent(context)),
                                icon: const Icon(Icons.add, size: 18),
                                label: Text(isThai ? 'เพิ่มสินทรัพย์ใหม่' : 'Add New Asset'),
                                onPressed: () async {
                                  final ok = await AssetFormDialog.show(context);
                                  if (ok == true) _loadData();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ] else ...[
                        Builder(
                          builder: (context) {
                            final effectiveAssetId = _assets.any((a) => a.id == _selectedAssetId)
                                ? _selectedAssetId
                                : (_assets.isNotEmpty ? _assets.first.id : null);
                            return Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: isThai ? 'สินทรัพย์ *' : 'Asset *',
                                      border: const OutlineInputBorder(),
                                    ),
                                    isExpanded: true,
                                    initialValue: effectiveAssetId,
                                    items: _assets.map((a) {
                                      return DropdownMenuItem(
                                        value: a.id,
                                        child: Text(
                                          '${a.symbol} - ${a.name}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        final match = _assets.firstWhere((a) => a.id == val);
                                        setState(() {
                                          _selectedAssetId = val;
                                          _currency = match.currencyCode;
                                          _selectedAccountId = match.defaultAccountId;
                                          _fxRateController.text = _currency == 'USD' ? '35.000000' : '1.000000';
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Tooltip(
                                  message: isThai ? 'สร้างสินทรัพย์ใหม่' : 'Create New Asset',
                                  child: IconButton.filled(
                                    icon: const Icon(Icons.add, size: 20),
                                    onPressed: () async {
                                      final ok = await AssetFormDialog.show(context);
                                      if (ok == true) _loadData();
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      // 3. Account Selector
                      Builder(
                        builder: (context) {
                          final effectiveAccountId = _accounts.any((a) => a.id == _selectedAccountId)
                              ? _selectedAccountId
                              : (_accounts.isNotEmpty ? _accounts.first.id : null);
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: _isBuy
                                  ? (isThai ? 'หักเงินจากบัญชี *' : 'Deduct from Account *')
                                  : (isThai ? 'รับเงินเข้าบัญชี *' : 'Deposit to Account *'),
                              border: const OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            initialValue: effectiveAccountId,
                            items: _accounts.map((a) {
                              return DropdownMenuItem(
                                value: a.id,
                                child: Text(
                                  '${a.name} (${a.currencyCode})',
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                        decoration: InputDecoration(
                          labelText: isThai ? 'จำนวนหน่วย *' : 'Quantity *',
                          hintText: isThai ? 'เช่น 100 หรือ 0.05' : 'e.g. 100 or 0.05',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return isThai ? 'กรุณาระบุจำนวน' : 'Please specify quantity';
                          try {
                            final d = Decimal.parse(val.trim());
                            if (d <= Decimal.zero) return '> 0';
                          } catch (_) {
                            return isThai ? 'ตัวเลขไม่ถูกต้อง' : 'Invalid number';
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
                          labelText: isThai ? 'ราคา/หน่วย ($_currency) *' : 'Price/Unit ($_currency) *',
                          hintText: isThai ? 'เช่น 65.50' : 'e.g. 65.50',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return isThai ? 'กรุณาระบุราคา' : 'Please specify price';
                          try {
                            final d = Decimal.parse(val.trim());
                            if (d <= Decimal.zero) return '> 0';
                          } catch (_) {
                            return isThai ? 'ราคาไม่ถูกต้อง' : 'Invalid price';
                          }
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
                      labelText: isThai
                          ? 'อัตราแลกเปลี่ยน (THB ต่อ 1 $_currency) *'
                          : 'Exchange Rate (THB per 1 $_currency) *',
                      hintText: 'เช่น 35.500000',
                      border: const OutlineInputBorder(),
                      helperText: isThai
                          ? 'ระบบจะล็อกเรตนี้ไว้ในธุรกรรม และบันทึกลงประวัติ FX'
                          : 'Rate is locked for this transaction and logged in FX history',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return isThai ? 'กรุณาระบุเรต FX' : 'Please specify FX rate';
                      try {
                        final fx = Decimal.parse(val.trim());
                        if (fx <= Decimal.zero) return '> 0';
                      } catch (_) {
                        return isThai ? 'เรตไม่ถูกต้อง' : 'Invalid rate';
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
                        decoration: InputDecoration(
                          labelText: isThai ? 'ค่าธรรมเนียม (บาท)' : 'Fee (THB)',
                          hintText: isThai ? 'เช่น 15.00' : 'e.g. 15.00',
                          border: const OutlineInputBorder(),
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
                  title: Text(_formatTradeDate(_tradeDate, isThai)),
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
                    final p = Decimal.tryParse(_priceController.text.trim()) ?? Decimal.zero;
                    final fx = Decimal.tryParse(_fxRateController.text.trim()) ?? Decimal.one;
                    final fee = double.tryParse(_feeController.text.trim()) ?? 0.0;

                    final origTotalSatang = (q * p * Decimal.fromInt(100)).round().toBigInt().toInt();
                    final thbTotalSatang = (Decimal.fromInt(origTotalSatang) * fx).round().toBigInt().toInt() +
                        (_isBuy ? (fee * 100).round() : -(fee * 100).round());

                    final moneyPreview = Money(thbTotalSatang > 0 ? thbTotalSatang : 0);
                    final summaryLabel = _isBuy
                        ? (isThai ? 'ยอดเงินจ่ายสุทธิ (THB):' : 'Net Amount Paid (THB):')
                        : (isThai ? 'ยอดเงินรับสุทธิ (THB):' : 'Net Amount Received (THB):');

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(summaryLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  decoration: InputDecoration(
                    labelText: isThai ? 'บันทึกช่วยจำ (Note)' : 'Note',
                    hintText: isThai ? 'เช่น DCA ประจำเดือน' : 'e.g. Monthly DCA',
                    border: const OutlineInputBorder(),
                  ),
                ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SizedBox(
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _isBuy ? const Color(0xFF1E88E5) : const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text(
                          _isBuy
                              ? (isThai ? 'ยืนยันการซื้อสินทรัพย์' : 'Confirm Buy')
                              : (isThai ? 'ยืนยันการขายสินทรัพย์' : 'Confirm Sell'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
