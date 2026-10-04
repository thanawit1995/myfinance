import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/daos/credit_card_dao.dart';
import '../../../../core/money/money.dart';
import '../../../../core/widgets/app_icon_selector.dart';
import '../../../../core/widgets/category_icon_helper.dart';
import 'account_detail_screen.dart';
import 'credit_card_summary_screen.dart';
import 'add_account_dialog.dart';
import 'edit_credit_card_dialog.dart';
import '../../investments/presentation/portfolio_screen.dart';

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
          final totalCash = await accDao.getTotalCashSatang();
          return (accounts: accounts, totalCash: totalCash, portValue: portValue);
        }(),
        builder: (context, AsyncSnapshot<({List<Account> accounts, int totalCash, int portValue})> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${isThai ? "เกิดข้อผิดพลาด" : "Error"}: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final accounts = data.accounts;
          final totalCash = data.totalCash;
          final portValue = data.portValue;

          // Group accounts
          final domesticThb = accounts.where((a) => a.isDomestic && a.accountType == 'bank').toList();
          final fcd = accounts.where((a) => a.isDomestic && a.accountType == 'fcd').toList();
          final offshore = accounts.where((a) => !a.isDomestic).toList();
          final creditCards = accounts.where((a) => a.accountType == 'credit_card').toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Liquid Cash / Cash Flow Card
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
                            ? 'กระแสเงินสด'
                            : 'Cash Flow / Liquid Cash',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        Money(totalCash).format(symbol: '฿'),
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

              if (portValue > 0) ...[
                _buildSectionHeader(isThai ? 'พอร์ตการลงทุน' : 'Investment Portfolio'),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade50,
                      child: Icon(Icons.show_chart, color: Colors.purple.shade700),
                    ),
                    title: Text(
                      isThai ? 'สินทรัพย์การลงทุนรวม' : 'Total Investment Assets',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isThai ? 'แตะเพื่อดูพอร์ตหุ้น, กองทุน, คริปโต, ทองคำ' : 'Tap to view stocks, funds, crypto, gold',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Money(portValue).format(symbol: '฿'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                      ],
                    ),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PortfolioScreen(),
                        ),
                      );
                      if (mounted) setState(() {});
                    },
                  ),
                ),
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
    return FutureBuilder<({int nativeBalanceSatang, int thbEquivalentSatang, Decimal fxRate})>(
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
              child: Icon(
                account.icon != null
                    ? CategoryIconHelper.getIcon(account.icon)
                    : Icons.account_balance,
                color: isUsd ? Colors.green.shade700 : Colors.blue.shade700,
              ),
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
    return FutureBuilder<CreditCardSummary?>(
      future: ref.read(creditCardDaoProvider).getSummary(account.id),
      builder: (context, snapshot) {
        final summary = snapshot.data;
        final debtSatang = summary?.totalDebtSatang ?? 0;
        final isDebt = debtSatang > 0;
        final debtMoney = Money(debtSatang);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepOrange.shade50,
              child: Icon(
                account.icon != null
                    ? CategoryIconHelper.getIcon(account.icon)
                    : Icons.credit_card,
                color: Colors.deepOrange.shade700,
              ),
            ),
            title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              isThai
                  ? 'ตัดรอบวันที่ ${account.closingDay ?? 23} • ครบชำระวันที่ ${account.dueDay ?? 10}'
                  : 'Closes day ${account.closingDay ?? 23} • Due day ${account.dueDay ?? 10}',
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
    if (account.accountType == 'credit_card') {
      final changed = await EditCreditCardDialog.show(context, account: account);
      if (changed == true && mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 4),
            content: Text(isThai
                ? 'อัปเดตข้อมูลบัตรเครดิตสำเร็จ'
                : 'Credit card updated successfully'),
          ),
        );
      }
      return;
    }

    final controller = TextEditingController(text: account.name);
    String? editedIcon = account.icon;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(isThai ? 'แก้ไขบัญชี' : 'Edit Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      final chosen = await AppIconSelector.show(context, currentIcon: editedIcon);
                      if (chosen != null) {
                        setDlgState(() => editedIcon = chosen);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.primary),
                      ),
                      child: Center(
                        child: Icon(
                          editedIcon != null
                              ? CategoryIconHelper.getIcon(editedIcon)
                              : Icons.account_balance,
                          size: 26,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isThai ? 'ไอคอนประจำบัญชี' : 'Account Icon',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isThai ? 'แตะที่กล่องเพื่อเปลี่ยนไอคอน' : 'Tap to change icon',
                          style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: isThai ? 'ชื่อบัญชี' : 'Account Name',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final trimmed = controller.text.trim();
                if (trimmed.isNotEmpty) {
                  Navigator.of(ctx).pop(true);
                }
              },
              child: Text(isThai ? 'บันทึก' : 'Save'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final trimmed = controller.text.trim();
      await ref.read(accountsDaoProvider).updateAccountName(account.id, trimmed, icon: editedIcon);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 4),
            content: Text(isThai
                ? 'อัปเดตข้อมูลบัญชี "$trimmed" สำเร็จ'
                : 'Account "$trimmed" updated successfully'),
          ),
        );
      }
    }
  }
}
