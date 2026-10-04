import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';

class LotInspectionScreen extends ConsumerStatefulWidget {
  final Asset asset;

  const LotInspectionScreen({super.key, required this.asset});

  static Future<void> show(BuildContext context, Asset asset) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LotInspectionScreen(asset: asset)),
    );
  }

  @override
  ConsumerState<LotInspectionScreen> createState() => _LotInspectionScreenState();
}

class _LotInspectionScreenState extends ConsumerState<LotInspectionScreen> {
  Future<void> _showEditLotDialog(InvestmentLot lot) async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final invDao = ref.read(investmentsDaoProvider);

    DateTime editDate = lot.buyDate;
    final qtyCtrl = TextEditingController(text: lot.quantity);
    final priceStr = lot.pricePerUnitOriginal ?? (lot.costPerUnitOriginalSatang / 100.0).toStringAsFixed(4);
    final priceCtrl = TextEditingController(text: priceStr);
    final fxCtrl = TextEditingController(text: lot.fxRate);
    final feeCtrl = TextEditingController(text: (lot.feeThbSatang / 100.0).toStringAsFixed(2));

    // Fetch existing transaction note
    final tx = await (ref.read(databaseProvider).select(ref.read(databaseProvider).transactions)
          ..where((t) => t.id.equals(lot.buyTransactionId)))
        .getSingleOrNull();
    final noteCtrl = TextEditingController(text: tx?.note ?? '');

    if (!mounted) return;

    final updated = await showDialog<bool>(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.edit_note_rounded, color: Colors.blue),
                const SizedBox(width: 8),
                Text(isThai ? 'แก้ไขข้อมูล Lot ซื้อ' : 'Edit Buy Lot'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isThai
                      ? 'ระบบจะอัปเดตธุรกรรมในบัญชี และคำนวณการจัดสรรต้นทุน/กำไร FIFO ใหม่ทั้งหมดให้อัตโนมัติ'
                      : 'Transaction in ledger will update and FIFO lot consumptions will be recalculated automatically.',
                    style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 14),

                  // Date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today, size: 20),
                    title: Text(DateFormat('d MMM yyyy').format(editDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    trailing: const Icon(Icons.edit_calendar, size: 20),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: editDate,
                        firstDate: DateTime(2015),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setDlgState(() => editDate = picked);
                      }
                    },
                  ),
                  const Divider(height: 12),

                  // Quantity
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    decoration: InputDecoration(
                      labelText: isThai ? 'จำนวนหน่วยที่ซื้อ (Quantity) *' : 'Quantity *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price
                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    decoration: InputDecoration(
                      labelText: isThai
                          ? 'ราคาต่อหน่วย (${widget.asset.currencyCode}) *'
                          : 'Price per Unit (${widget.asset.currencyCode}) *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // FX Rate (if foreign)
                  if (widget.asset.currencyCode != 'THB') ...[
                    TextField(
                      controller: fxCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      decoration: InputDecoration(
                        labelText: isThai
                            ? 'อัตราแลกเปลี่ยน FX (฿ ต่อ 1 ${widget.asset.currencyCode}) *'
                            : 'FX Rate *',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Fee
                  TextField(
                    controller: feeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    decoration: InputDecoration(
                      labelText: isThai ? 'ค่าธรรมเนียม (บาท THB)' : 'Fee (THB)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Note
                  TextField(
                    controller: noteCtrl,
                    decoration: InputDecoration(
                      labelText: isThai ? 'บันทึกช่วยจำ (Note)' : 'Note',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dlgCtx, false), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
              FilledButton(
                onPressed: () {
                  final q = Decimal.tryParse(qtyCtrl.text.trim());
                  final p = Decimal.tryParse(priceCtrl.text.trim());
                  final fx = Decimal.tryParse(fxCtrl.text.trim());
                  if (q == null || q <= Decimal.zero || p == null || p <= Decimal.zero || fx == null || fx <= Decimal.zero) {
                    return;
                  }
                  Navigator.pop(dlgCtx, true);
                },
                child: Text(isThai ? 'บันทึก' : 'Save'),
              ),
            ],
          );
        },
      ),
    );

    if (updated == true && mounted) {
      final q = Decimal.parse(qtyCtrl.text.trim());
      final p = Decimal.parse(priceCtrl.text.trim());
      final pSatang = (p * Decimal.fromInt(100)).round().toBigInt().toInt();
      final fx = Decimal.parse(fxCtrl.text.trim());
      final feeDouble = double.tryParse(feeCtrl.text.trim()) ?? 0.0;
      final feeSatang = (feeDouble * 100).round();

      await invDao.updateBuyLotAndTransaction(
        lotId: lot.id,
        buyDate: editDate,
        quantity: q,
        priceOriginalSatang: pSatang,
        pricePerUnitOriginal: p,
        fxRate: fx,
        feeThbSatang: feeSatang,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      );

      ref.read(transactionsVersionProvider.notifier).state++;
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'อัปเดตข้อมูล Lot และคำนวณ FIFO ใหม่สำเร็จ' : 'Updated Lot and recalculated FIFO successfully'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invDao = ref.watch(investmentsDaoProvider);
    final asset = widget.asset;

    return Scaffold(
      appBar: AppBar(
        title: Text('ตรวจสอบ Lot: ${asset.symbol}'),
      ),
      body: FutureBuilder<List<InvestmentLot>>(
        future: invDao.getAllLotsForAsset(asset.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final lots = snapshot.data ?? [];
          if (lots.isEmpty) {
            return Center(
              child: Text('ยังไม่มีประวัติการซื้อ Lot สำหรับ ${asset.symbol}'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lots.length,
            itemBuilder: (context, index) {
              final lot = lots[index];
              final totalCostMoney = Money(lot.totalCostThbSatang);
              final remCostMoney = Money(lot.remainingCostThbSatang);

              Color statusColor;
              String statusLabel;
              if (lot.status == 'closed') {
                statusColor = Colors.grey;
                statusLabel = 'ปิดแล้ว (ขายหมดแล้ว)';
              } else if (lot.status == 'partially_closed') {
                statusColor = Colors.orange;
                statusLabel = 'ขายบางส่วน';
              } else {
                statusColor = Colors.green;
                statusLabel = 'เปิดอยู่ (ยังไม่ขาย)';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Lot ID + Status + Edit Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Lot #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(DateFormat('d MMM yyyy').format(lot.buyDate), style: const TextStyle(fontSize: 13, color: Colors.grey)),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                                tooltip: 'แก้ไขรายการซื้อ Lot นี้',
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                                onPressed: () => _showEditLotDialog(lot),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      // Details Grid
                      Row(
                        children: [
                          Expanded(
                            child: _detailItem('จำนวนที่ซื้อ', '${lot.quantity} หน่วย'),
                          ),
                          Expanded(
                            child: _detailItem('คงเหลือ', '${lot.remainingQuantity} หน่วย'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _detailItem('ราคาซื้อ', '${lot.costPerUnitOriginalSatang / 100.0} ${asset.currencyCode}'),
                          ),
                          Expanded(
                            child: _detailItem('เรต FX วันซื้อ', '${lot.fxRate} ฿/${asset.currencyCode}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _detailItem('ต้นทุนรวมดั้งเดิม', totalCostMoney.format(symbol: '฿')),
                          ),
                          Expanded(
                            child: _detailItem('ต้นทุนคงเหลือ', remCostMoney.format(symbol: '฿')),
                          ),
                        ],
                      ),

                      // Sales consumptions from this lot
                      FutureBuilder<List<InvestmentSale>>(
                        future: invDao.getSalesForLot(lot.id),
                        builder: (context, salesSnap) {
                          final sales = salesSnap.data ?? [];
                          if (sales.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 24),
                              Text('ประวัติการตัดขายจาก Lot นี้:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.primary)),
                              const SizedBox(height: 8),
                              ...sales.map((s) {
                                final pGain = Money(s.priceGainLossThbSatang);
                                final fxGain = Money(s.fxGainLossThbSatang);
                                final netGain = Money(s.realizedGainLossThbSatang);
                                final isProfit = s.realizedGainLossThbSatang >= 0;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('ตัดขาย: ${s.quantitySold} หน่วย (${DateFormat("d MMM yyyy").format(s.sellDate)})',
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          Text(
                                            isProfit ? '+${netGain.format(symbol: '฿')}' : netGain.format(symbol: '฿'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: isProfit ? Colors.green.shade700 : Colors.red.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Price P&L: ${pGain.format(symbol: '฿')}  |  FX P&L: ${fxGain.format(symbol: '฿')}  |  ค่าธรรมเนียม: ${Money(s.feeThbSatang).format(symbol: '฿')}',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
