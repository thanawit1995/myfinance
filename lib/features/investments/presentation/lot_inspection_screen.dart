import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';

class LotInspectionScreen extends ConsumerWidget {
  final Asset asset;

  const LotInspectionScreen({super.key, required this.asset});

  static Future<void> show(BuildContext context, Asset asset) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LotInspectionScreen(asset: asset)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final invDao = ref.watch(investmentsDaoProvider);

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
                      // Header: Lot ID + Status
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
                          Text(DateFormat('d MMM yyyy').format(lot.buyDate), style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
