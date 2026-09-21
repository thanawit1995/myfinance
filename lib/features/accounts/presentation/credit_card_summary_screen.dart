import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/credit_card_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';

class CreditCardSummaryScreen extends ConsumerWidget {
  final Account account;

  const CreditCardSummaryScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ccDao = ref.watch(creditCardDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('สรุป ${account.name}'),
      ),
      body: FutureBuilder<CreditCardSummary?>(
        future: ccDao.getSummary(account.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = snapshot.data;
          if (summary == null) {
            return const Center(child: Text('ไม่พบข้อมูลบัตรเครดิต'));
          }

          final cycle = summary.cycle;
          final prevStatementMoney = Money(summary.previousStatementDebtSatang);
          final currentCycleMoney = Money(summary.currentCycleDebtSatang);
          final totalDebtMoney = Money(summary.totalDebtSatang);

          final dateFormat = DateFormat('d MMM yyyy');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Cycle Banner
              Card(
                color: Colors.deepOrange.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'รอบบิลปัจจุบัน',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange.shade900),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cycle.daysRemaining == 0 ? 'ตัดรอบวันนี้!' : 'เหลืออีก ${cycle.daysRemaining} วัน',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${dateFormat.format(cycle.cycleStart)} - ${dateFormat.format(cycle.cycleEnd)}',
                        style: TextStyle(color: Colors.deepOrange.shade800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'วันครบกำหนดชำระ: วันที่ ${cycle.dueDay} ของเดือนถัดไป',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2 Breakdown Cards: ยอดรอบที่แล้ว (ต้องจ่าย) vs ยอดรอบปัจจุบัน (สะสมอยู่)
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.red.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ยอดรอบที่แล้ว\n(ต้องชำระรอบนี้)', style: TextStyle(fontSize: 12, color: Colors.red)),
                            const SizedBox(height: 8),
                            Text(
                              prevStatementMoney.format(symbol: '฿'),
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: Colors.orange.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ยอดรอบปัจจุบัน\n(กำลังสะสม)', style: TextStyle(fontSize: 12, color: Colors.deepOrange)),
                            const SizedBox(height: 8),
                            Text(
                              currentCycleMoney.format(symbol: '฿'),
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Total Debt Card
              Card(
                elevation: 0,
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text('หนี้ค้างชำระรวมทั้งหมด'),
                  trailing: Text(
                    totalDebtMoney.format(symbol: '฿'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Current Cycle Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'รายการในรอบบิลปัจจุบัน (${summary.currentCycleTransactions.length} รายการ)',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (summary.currentCycleTransactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('ไม่มีรายการใช้จ่ายในรอบบิลนี้')),
                )
              else
                ...summary.currentCycleTransactions.map((tx) {
                  final money = Money(tx.amountThbSatang);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(tx.note?.isNotEmpty == true ? tx.note! : 'รูดบัตรเครดิต'),
                      subtitle: Text(DateFormat('d MMM yyyy, HH:mm').format(tx.transactionDate)),
                      trailing: Text(
                        '-${money.format(symbol: '฿')}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
