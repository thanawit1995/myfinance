import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../transactions/presentation/edit_transaction_dialog.dart';

class AccountDetailScreen extends ConsumerStatefulWidget {
  final Account account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  ConsumerState<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accDao = ref.watch(accountsDaoProvider);
    final txDao = ref.watch(transactionsDaoProvider);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.name),
        actions: [
          IconButton(
            icon: Icon(widget.account.isActive ? Icons.archive_outlined : Icons.unarchive_outlined),
            tooltip: widget.account.isActive
                ? (isThai ? 'ปิดการใช้งานบัญชี' : 'Deactivate account')
                : (isThai ? 'เปิดการใช้งานบัญชี' : 'Activate account'),
            onPressed: () => _toggleActive(isThai),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: isThai ? 'ลบบัญชีนี้ (ย้ายไปถังขยะ)' : 'Delete account (Move to Trash)',
            onPressed: () => _confirmDeleteAccount(isThai),
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance Card
          FutureBuilder(
            future: accDao.getAccountBalanceBreakdown(widget.account.id),
            builder: (context, snapshot) {
              final data = snapshot.data;
              final balance = data?.nativeBalanceSatang ?? 0;
              final thbEquivalent = data?.thbEquivalentSatang ?? 0;
              final fxRate = data?.fxRate;
              final isUsd = widget.account.currencyCode == 'USD';
              final symbol = isUsd ? r'$' : '฿';
              final money = Money(balance);

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isThai ? 'ยอดคงเหลือปัจจุบัน' : 'Current Balance', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(
                      money.format(symbol: symbol),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (isUsd && fxRate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '≈ ${Money(thbEquivalent).format(symbol: '฿')} (${isThai ? "อัตราแลกเปลี่ยน" : "FX Rate"} ${fxRate.toStringAsFixed(2)} ฿/\$)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${isThai ? "สกุลเงิน" : "Currency"}: ${widget.account.currencyCode} · ${widget.account.isDomestic ? (isThai ? 'ในประเทศ' : 'Domestic') : (isThai ? 'ต่างประเทศ' : 'Offshore')}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),

          // Transaction History Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isThai ? 'ประวัติรายการในบัญชีนี้ (แตะเพื่อแก้ไข)' : 'Transaction History (Tap to edit)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Transaction History List
          Expanded(
            child: FutureBuilder<List<Transaction>>(
              future: txDao.getTransactionsForAccount(widget.account.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final transactions = snapshot.data ?? [];
                if (transactions.isEmpty) {
                  return Center(
                    child: Text(
                      isThai ? 'ยังไม่มีรายการในบัญชีนี้' : 'No transactions in this account',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isExpense = tx.sourceAccountId == widget.account.id && tx.transactionType != 'income';
                    final money = Money(tx.amountThbSatang);
                    final color = isExpense ? Colors.red.shade700 : Colors.green.shade700;

                    final fallbackTitle = isExpense
                        ? (isThai ? 'รายจ่าย/โอนออก' : 'Expense / Outflow')
                        : (isThai ? 'รายรับ/โอนเข้า' : 'Income / Inflow');

                    return ListTile(
                      title: Text(tx.note?.isNotEmpty == true ? tx.note! : fallbackTitle),
                      subtitle: Text(DateFormat('d MMM yyyy, HH:mm').format(tx.transactionDate), style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isExpense ? '-${money.format(symbol: '฿')}' : '+${money.format(symbol: '฿')}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.edit_outlined, size: 16, color: Colors.grey.shade400),
                        ],
                      ),
                      onTap: () async {
                        final changed = await EditTransactionDialog.show(context, tx);
                        if (changed == true && mounted) {
                          setState(() {});
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(bool isThai) async {
    final accDao = ref.read(accountsDaoProvider);
    if (widget.account.isActive) {
      await accDao.deactivateAccount(widget.account.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai
                ? 'ปิดการใช้งานบัญชีแล้ว (ยอดเงินจะไม่นับรวมในทรัพย์สินรวม)'
                : 'Account deactivated (excluded from total assets)'),
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      await accDao.activateAccount(widget.account.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isThai ? 'เปิดการใช้งานบัญชีเรียบร้อยแล้ว' : 'Account activated successfully')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _confirmDeleteAccount(bool isThai) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'ลบบัญชี' : 'Delete Account'),
        content: Text(
          isThai
              ? 'คุณต้องการลบบัญชี "${widget.account.name}" ใช่หรือไม่?\n\nบัญชีและรายการธุรกรรมทั้งหมดจะถูกย้ายไปที่ "ถังขยะ" ในหน้าตั้งค่า และสามารถกู้คืนได้ภายใน 30 วัน'
              : 'Delete account "${widget.account.name}"?\n\nThe account and its transactions will be moved to "Trash Bin" in Settings and can be restored within 30 days.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isThai ? 'ลบบัญชี (ย้ายลงถังขยะ)' : 'Delete (Move to Trash)'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(accountsDaoProvider).softDeleteAccount(widget.account.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai
                ? 'ย้ายบัญชี "${widget.account.name}" ไปที่ถังขยะเรียบร้อยแล้ว'
                : 'Account "${widget.account.name}" moved to Trash Bin'),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }
}
