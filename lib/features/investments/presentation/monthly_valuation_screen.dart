import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/daos/investments_dao.dart';
import '../../../../core/money/money.dart';

class MonthlyValuationScreen extends ConsumerStatefulWidget {
  const MonthlyValuationScreen({super.key});

  static Future<bool?> show(BuildContext context) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const MonthlyValuationScreen()),
    );
  }

  @override
  ConsumerState<MonthlyValuationScreen> createState() => _MonthlyValuationScreenState();
}

class _MonthlyValuationScreenState extends ConsumerState<MonthlyValuationScreen> {
  late DateTime _selectedMonth;
  late TextEditingController _usdFxController;
  final Map<String, TextEditingController> _priceControllers = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _usdFxController = TextEditingController(text: '35.000000');
    _loadLatestFx();
  }

  Future<void> _loadLatestFx() async {
    final fx = await ref.read(investmentsDaoProvider).getLatestUsdFxRate();
    if (mounted) {
      _usdFxController.text = fx.toString();
    }
  }

  @override
  void dispose() {
    _usdFxController.dispose();
    for (final c in _priceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAll(List<PortfolioAssetHolding> holdings) async {
    setState(() => _isSaving = true);
    final invDao = ref.read(investmentsDaoProvider);
    final rawFx = _usdFxController.text.trim().replaceAll(',', '.');
    final fxRateUsd = Decimal.tryParse(rawFx) ?? Decimal.parse('35.000000');

    // Last day of selected month
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    int savedCount = 0;
    for (final h in holdings) {
      final ctrl = _priceControllers[h.asset.id];
      Decimal? pDecimal;
      int pSatang = h.currentPriceOriginalSatang;

      if (ctrl != null && ctrl.text.trim().isNotEmpty) {
        final parsed = Decimal.tryParse(ctrl.text.trim().replaceAll(',', '.'));
        if (parsed != null && parsed > Decimal.zero) {
          pDecimal = parsed;
          pSatang = (parsed * Decimal.fromInt(100)).round().toBigInt().toInt();
        }
      }

      final fx = h.asset.currencyCode == 'USD' ? fxRateUsd : Decimal.one;

      await invDao.recordAssetPrice(
        assetId: h.asset.id,
        priceDate: lastDay,
        marketPriceOriginalSatang: pSatang,
        marketPriceOriginal: pDecimal,
        fxRate: fx,
      );
      savedCount++;
    }

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกราคาตลาดประจำเดือนสำเร็จ $savedCount รายการ')),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invDao = ref.watch(investmentsDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'อัปเดตราคาตลาดประจำเดือน',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
          maxLines: 2,
          softWrap: true,
        ),
      ),
      body: FutureBuilder<PortfolioSummary>(
        future: invDao.getPortfolioSummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = snapshot.data;
          final holdings = summary?.holdings ?? [];

          if (holdings.isEmpty) {
            return const Center(
              child: Text('ยังไม่มีสินทรัพย์คงเหลือในพอร์ตที่ต้องประเมินราคา'),
            );
          }

          // Initialize controllers for each holding if not already
          for (final h in holdings) {
            if (!_priceControllers.containsKey(h.asset.id)) {
              final currentDec = h.currentPriceOriginal;
              final currentDouble = h.currentPriceOriginalSatang / 100.0;
              _priceControllers[h.asset.id] = TextEditingController(
                text: currentDec != null
                    ? currentDec.toString()
                    : (currentDouble > 0 ? currentDouble.toStringAsFixed(2) : ''),
              );
            }
          }

          final hasUsdAsset = holdings.any((h) => h.asset.currencyCode == 'USD');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Month Header & FX Rate
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Text(
                            'ประจำเดือน: ${DateFormat("MMMM yyyy", "th").format(_selectedMonth)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_month, size: 18),
                            label: const Text('เปลี่ยนเดือน'),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedMonth,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _selectedMonth = DateTime(picked.year, picked.month, 1));
                              }
                            },
                          ),
                        ],
                      ),
                      if (hasUsdAsset) ...[
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Expanded(
                              flex: 3,
                              child: Text(
                                'อัตราแลกเปลี่ยน USD/THB ประจำเดือนนี้:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _usdFxController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                  suffixText: '฿',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Table of Holdings to enter prices
              Text(
                'กรอกราคาปิดสิ้นงวดของแต่ละสินทรัพย์',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...holdings.map((h) {
                final ctrl = _priceControllers[h.asset.id]!;
                final costMoney = Money(h.totalCostThbSatang);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(h.asset.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(h.asset.currencyCode, style: TextStyle(fontSize: 11, color: Colors.blue.shade800)),
                                  ),
                                ],
                              ),
                              Text(h.asset.name, style: TextStyle(fontSize: 13, color: Colors.grey.shade600), maxLines: 1),
                              const SizedBox(height: 4),
                              Text('ถืออยู่: ${h.totalQuantity} หน่วย | ต้นทุนรวม: ${costMoney.format(symbol: '฿')}',
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 140,
                          child: TextField(
                            controller: ctrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                            textAlign: TextAlign.end,
                            decoration: InputDecoration(
                              labelText: 'ราคา (${h.asset.currencyCode})',
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isSaving ? 'กำลังบันทึก...' : 'บันทึกราคาตลาดทั้งหมด (${holdings.length} รายการ)'),
                onPressed: _isSaving ? null : () => _saveAll(holdings),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
