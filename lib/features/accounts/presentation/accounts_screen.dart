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
import '../../../../core/theme/vault_theme.dart';
import '../../investments/presentation/portfolio_screen.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PortfolioScreen(),
                        ),
                      );
                      if (mounted) setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.purple.shade50,
                            child: Icon(Icons.show_chart, color: Colors.purple.shade700, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isThai ? 'การลงทุน' : 'Investments',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isThai ? 'พอร์ตหุ้น, กองทุน, คริปโต, ทองคำ' : 'Stocks, funds, crypto, gold',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: VaultTheme.secondaryText(context),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            Money(portValue).format(symbol: '฿'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
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

        final isUsd = account.currencyCode == 'USD';
        final nativeMoney = Money(nativeSatang);
        final thbMoney = Money(thbSatang);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AccountDetailScreen(account: account),
                ),
              );
              if (mounted) setState(() {});
            },
            onLongPress: () => _showEditAccountDialog(account, isThai),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Builder(
                    builder: (context) {
                      final iconStr = account.icon ?? 'account_balance';
                      final isCustomImage = iconStr.startsWith('data:image');
                      if (isCustomImage) {
                        return SizedBox(
                          width: 40,
                          height: 40,
                          child: CategoryIconHelper.buildIconWidget(iconStr, size: 40),
                        );
                      }
                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: isUsd ? Colors.green.shade50 : Colors.blue.shade50,
                        child: CategoryIconHelper.buildIconWidget(
                          iconStr,
                          size: 22,
                          color: isUsd ? Colors.green.shade700 : Colors.blue.shade700,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            account.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (account.isDefault) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 10,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  isThai ? 'บัญชีหลัก' : 'Default',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (isUsd) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'USD',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        nativeMoney.format(symbol: isUsd ? r'$' : '฿'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (isUsd)
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Text(
                            '≈ ${thbMoney.format(symbol: '฿')}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      if (!account.isActive)
                        Text(
                          isThai ? 'ปิดใช้งาน' : 'Inactive',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                    ],
                  ),
                ],
              ),
            ),
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
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreditCardSummaryScreen(account: account),
                ),
              );
            },
            onLongPress: () => _showEditAccountDialog(account, isThai),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (context) {
                          final iconStr = account.icon ?? 'credit_card';
                          final isCustomImage = iconStr.startsWith('data:image');
                          if (isCustomImage) {
                            return SizedBox(
                              width: 36,
                              height: 36,
                              child: CategoryIconHelper.buildIconWidget(iconStr, size: 36),
                            );
                          }
                          return CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.deepOrange.shade50,
                            child: CategoryIconHelper.buildIconWidget(
                              iconStr,
                              size: 20,
                              color: Colors.deepOrange.shade700,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          account.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isDebt ? '-${debtMoney.format(symbol: '฿')}' : '฿0.00',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDebt ? Colors.red.shade700 : VaultTheme.primaryText(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 46),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isThai
                              ? 'ตัดรอบ ${account.closingDay ?? 23} • ครบชำระ ${account.dueDay ?? 10}'
                              : 'Cutoff ${account.closingDay ?? 23} • Due ${account.dueDay ?? 10}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: VaultTheme.secondaryText(context),
                          ),
                        ),
                        Text(
                          isDebt
                              ? (isThai ? 'ยอดหนี้คงค้าง' : 'Outstanding')
                              : (isThai ? 'ไม่มีหนี้' : 'Zero balance'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDebt ? Colors.red.shade700 : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                        child: editedIcon != null
                            ? CategoryIconHelper.buildIconWidget(
                                editedIcon,
                                size: 26,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              )
                            : Icon(
                                Icons.account_balance,
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
              const SizedBox(height: 12),
              if (!account.isDefault)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.star_outline, color: Colors.amber),
                  title: Text(
                    isThai ? 'ตั้งเป็นบัญชีหลัก' : 'Set as Default Account',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    isThai
                        ? 'จะแสดงเป็นตัวเลือกแรกเสมอเมื่อบันทึกรายการด่วน'
                        : 'Will appear first in Quick Add by default',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      await ref.read(accountsDaoProvider).setDefaultAccount(account.id);
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop(false);
                      }
                      if (mounted) {
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isThai
                                ? 'ตั้ง "${account.name}" เป็นบัญชีหลักแล้ว'
                                : 'Set "${account.name}" as default account'),
                          ),
                        );
                      }
                    },
                    child: Text(isThai ? 'ตั้งค่าทันที' : 'Set now'),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isThai ? 'บัญชีนี้เป็นบัญชีหลักอยู่ในปัจจุบัน' : 'This is currently the default account',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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
