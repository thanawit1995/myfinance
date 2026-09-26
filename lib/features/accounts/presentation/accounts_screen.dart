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
  @override
  Widget build(BuildContext context) {
    ref.watch(transactionsVersionProvider);
    final theme = Theme.of(context);
    final accDao = ref.watch(accountsDaoProvider);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      appBar: AppBar(
        title: Text(isThai ? 'บัญชีทั้งหมด' : 'All Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: isThai ? 'เพิ่มบัญชีใหม่' : 'Add New Account',
            onPressed: () async {
              final added = await AddAccountDialog.show(context);
              if (added == true && mounted) {
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: () async {
          final accounts = await accDao.getAllAccounts();
          int portValue = 0;
          try {
            final portSummary = await ref.read(investmentsDaoProvider).getPortfolioSummary();
            portValue = portSummary.totalValueThbSatang;
          } catch (_) {}
          final totalNetWorth = await accDao.getTotalNetWorthSatang(portfolioValueSatang: portValue);
          return (accounts: accounts, totalNetWorth: totalNetWorth, portValue: portValue);
        }(),
        builder: (context, AsyncSnapshot<({List<Account> accounts, int totalNetWorth, int portValue})> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${isThai ? "เกิดข้อผิดพลาด" : "Error"}: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final accounts = data.accounts;
          final totalNetWorth = data.totalNetWorth;
          final portValue = data.portValue;

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
                      Text(
                        isThai
                            ? 'ความมั่งคั่งสุทธิรวม (เงินฝาก + พอร์ตลงทุน)'
                            : 'Total Net Worth (Cash + Investments)',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        Money(totalNetWorth).format(symbol: '฿'),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if (portValue > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          isThai
                              ? 'รวมมูลค่าพอร์ตการลงทุนปัจจุบัน ${Money(portValue).format(symbol: "฿")}'
                              : 'Includes current portfolio value ${Money(portValue).format(symbol: "฿")}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (domesticThb.isNotEmpty) ...[
                _buildSectionHeader(isThai ? 'บัญชีเงินบาทในประเทศ' : 'Domestic Bank Accounts (THB)'),
                ...domesticThb.map((a) => _buildAccountTile(context, a, isThai)),
                const SizedBox(height: 12),
              ],

              if (fcd.isNotEmpty) ...[
                _buildSectionHeader(isThai ? 'บัญชีเงินตราต่างประเทศ (FCD)' : 'Foreign Currency Deposit (FCD)'),
                ...fcd.map((a) => _buildAccountTile(context, a, isThai)),
                const SizedBox(height: 12),
              ],

              if (offshore.isNotEmpty) ...[
                _buildSectionHeader(isThai ? 'บัญชีต่างประเทศ (Offshore)' : 'Offshore Accounts'),
                ...offshore.map((a) => _buildAccountTile(context, a, isThai)),
                const SizedBox(height: 12),
              ],

              if (creditCards.isNotEmpty) ...[
                _buildSectionHeader(isThai ? 'บัตรเครดิต' : 'Credit Cards'),
                ...creditCards.map((a) => _buildCreditCardTile(context, a, isThai)),
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

  Widget _buildAccountTile(BuildContext context, Account account, bool isThai) {
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
              account.isActive
                  ? (isThai ? 'เปิดใช้งาน' : 'Active')
                  : (isThai ? 'ปิดใช้งาน (ไม่นับรวมสินทรัพย์)' : 'Inactive (Excluded from assets)'),
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
                    '≈ ${thbMoney.format(symbol: '฿')} (${isThai ? "เรต" : "Rate"} ${fxRate.toStringAsFixed(2)})',
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
            onLongPress: () => _showEditAccountDialog(account, isThai),
          ),
        );
      },
    );
  }

  Widget _buildCreditCardTile(BuildContext context, Account account, bool isThai) {
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
            subtitle: Text(
              isThai
                  ? 'สรุปยอดทุกวันที่ ${account.closingDay ?? 23}'
                  : 'Statement closes on day ${account.closingDay ?? 23}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isDebt ? '-${debtMoney.format(symbol: '฿')}' : '฿0.00',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDebt ? Colors.red.shade700 : Colors.black87),
                ),
                Text(
                  isDebt
                      ? (isThai ? 'ยอดหนี้คงค้าง' : 'Outstanding balance')
                      : (isThai ? 'ไม่มีหนี้' : 'Zero balance'),
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
            onLongPress: () => _showEditAccountDialog(account, isThai),
          ),
        );
      },
    );
  }

  Future<void> _showEditAccountDialog(Account account, bool isThai) async {
    final controller = TextEditingController(text: account.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'แก้ไขชื่อบัญชี' : 'Edit Account Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: isThai ? 'ชื่อบัญชี' : 'Account Name',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isNotEmpty) {
                Navigator.of(ctx).pop(trimmed);
              }
            },
            child: Text(isThai ? 'บันทึก' : 'Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != account.name) {
      await ref.read(accountsDaoProvider).updateAccountName(account.id, newName);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text(isThai
                ? 'แก้ไขชื่อบัญชีเป็น "$newName" สำเร็จ'
                : 'Account name updated to "$newName"'),
          ),
        );
      }
    }
  }
}
