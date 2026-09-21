import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import 'account_detail_screen.dart';
import 'credit_card_summary_screen.dart';
import 'add_account_dialog.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accDao = ref.watch(accountsDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('บัญชีทั้งหมด'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'เพิ่มบัญชีใหม่',
            onPressed: () async {
              final added = await AddAccountDialog.show(context);
              if (added == true && mounted) {
                setState(() {});
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await AddAccountDialog.show(context);
          if (added == true && mounted) {
            setState(() {});
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มบัญชี'),
      ),
      body: FutureBuilder(
        future: Future.wait([
          accDao.getAllAccounts(),
          accDao.getTotalNetWorthSatang(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }

          final accounts = snapshot.data![0] as List<Account>;
          final totalNetWorth = snapshot.data![1] as int;

          // Group accounts
          final domesticThb = accounts.where((a) => a.isDomestic && a.accountType == 'bank').toList();
          final fcd = accounts.where((a) => a.isDomestic && a.accountType == 'fcd').toList();
          final offshore = accounts.where((a) => !a.isDomestic).toList();
          final creditCards = accounts.where((a) => a.accountType == 'credit_card').toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Total Net Worth Card
              Card(
                color: theme.colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ความมั่งคั่งสุทธิรวม (เฉพาะบัญชีที่เปิดใช้งาน)', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 6),
                      Text(
                        Money(totalNetWorth).format(symbol: '฿'),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (domesticThb.isNotEmpty) ...[
                _buildSectionHeader('บัญชีเงินบาทในประเทศ'),
                ...domesticThb.map((a) => _buildAccountTile(context, a)),
                const SizedBox(height: 12),
              ],

              if (fcd.isNotEmpty) ...[
                _buildSectionHeader('บัญชีเงินตราต่างประเทศ (FCD)'),
                ...fcd.map((a) => _buildAccountTile(context, a)),
                const SizedBox(height: 12),
              ],

              if (offshore.isNotEmpty) ...[
                _buildSectionHeader('บัญชีต่างประเทศ (Offshore)'),
                ...offshore.map((a) => _buildAccountTile(context, a)),
                const SizedBox(height: 12),
              ],

              if (creditCards.isNotEmpty) ...[
                _buildSectionHeader('บัตรเครดิต'),
                ...creditCards.map((a) => _buildCreditCardTile(context, a)),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildAccountTile(BuildContext context, Account account) {
    return FutureBuilder(
      future: ref.read(accountsDaoProvider).getAccountBalanceBreakdown(account.id),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final nativeSatang = data?.nativeBalanceSatang ?? 0;
        final thbSatang = data?.thbEquivalentSatang ?? 0;
        final fxRate = data?.fxRate ?? Decimal.one;

        final isUsd = account.currencyCode == 'USD';
        final nativeMoney = Money(nativeSatang);
        final thbMoney = Money(thbSatang);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isUsd ? Colors.green.shade50 : Colors.blue.shade50,
              child: Icon(Icons.account_balance, color: isUsd ? Colors.green.shade700 : Colors.blue.shade700),
            ),
            title: Row(
              children: [
                Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (isUsd) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('USD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              account.isActive ? 'เปิดใช้งาน' : 'ปิดใช้งาน (ไม่นับรวมสินทรัพย์)',
              style: TextStyle(fontSize: 12, color: account.isActive ? Colors.green : Colors.grey),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  nativeMoney.format(symbol: isUsd ? r'$' : '฿'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (isUsd)
                  Text(
                    '≈ ${thbMoney.format(symbol: '฿')} (เรต ${fxRate.toStringAsFixed(2)})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AccountDetailScreen(account: account),
                ),
              );
              if (mounted) setState(() {});
            },
          ),
        );
      },
    );
  }

  Widget _buildCreditCardTile(BuildContext context, Account account) {
    return FutureBuilder<int>(
      future: ref.read(accountsDaoProvider).getAccountBalanceSatang(account.id),
      builder: (context, snapshot) {
        final balanceSatang = snapshot.data ?? 0;
        // Credit card balance is negative (debt)
        final isDebt = balanceSatang < 0;
        final debtMoney = Money(balanceSatang.abs());

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepOrange.shade50,
              child: Icon(Icons.credit_card, color: Colors.deepOrange.shade700),
            ),
            title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('สรุปยอดทุกวันที่ ${account.closingDay ?? 23}', style: const TextStyle(fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isDebt ? '-${debtMoney.format(symbol: '฿')}' : '฿0.00',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDebt ? Colors.red.shade700 : Colors.black87),
                ),
                Text(
                  isDebt ? 'ยอดหนี้คงค้าง' : 'ไม่มีหนี้',
                  style: TextStyle(fontSize: 11, color: isDebt ? Colors.red.shade700 : Colors.green),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreditCardSummaryScreen(account: account),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
