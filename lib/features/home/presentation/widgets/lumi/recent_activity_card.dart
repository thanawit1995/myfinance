import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../core/money/money.dart';
import '../../../../../core/theme/vault_theme.dart';
import '../../../../../l10n/app_localizations.dart';

class RecentActivityCard extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onViewAll;
  final VoidCallback onAddTransaction;

  const RecentActivityCard({
    super.key,
    required this.transactions,
    required this.onViewAll,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? VaultTheme.surface(context) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? VaultTheme.border(context) : const Color(0xFFF3DCE5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0x0CFF5B9A),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('📝', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    l10n?.recentActivity ?? 'บันทึกรายการล่าสุด',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? VaultTheme.primaryText(context) : const Color(0xFF332B32),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n?.viewAll ?? 'ดูทั้งหมด',
                        style: const TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF5C9D),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Color(0xFFFF5C9D),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (transactions.isEmpty)
            _buildEmptyState(context)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (_, _) => Divider(
                color: isDark
                    ? VaultTheme.border(context).withValues(alpha: 0.5)
                    : const Color(0xFFF3DCE5).withValues(alpha: 0.6),
                height: 16,
                thickness: 0.75,
              ),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return _buildTransactionItem(context, tx);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction tx) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isIncome = tx.transactionType == 'income';
    final isTransfer = tx.transactionType == 'transfer';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color amountColor = isIncome
        ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E8B57))
        : (isTransfer
            ? (isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2))
            : (isDark ? VaultTheme.primaryText(context) : const Color(0xFF332B32)));

    final String sign = isIncome ? '+' : (isTransfer ? '' : '−');

    final dateStr = DateFormat('d MMM • HH:mm', locale).format(tx.transactionDate);

    // Title label
    final String title = tx.note?.isNotEmpty == true
        ? tx.note!
        : (isTransfer
            ? (l10n?.transfer ?? 'โอนเงิน')
            : (isIncome ? (l10n?.income ?? 'รายรับ') : (l10n?.expense ?? 'รายจ่าย')));

    final iconColor = isIncome
        ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E8B57))
        : (isTransfer
            ? (isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2))
            : const Color(0xFFFF5B9A));

    final iconBgColor = isIncome
        ? (isDark ? const Color(0xFF1A3324) : const Color(0xFFF0FAF2))
        : (isTransfer
            ? (isDark ? const Color(0xFF192A3D) : const Color(0xFFEEF8FF))
            : (isDark ? const Color(0xFF391A29) : const Color(0xFFFFF0F5)));

    final iconData = isIncome
        ? Icons.arrow_downward_rounded
        : (isTransfer ? Icons.swap_horiz_rounded : Icons.shopping_bag_outlined);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Pastel icon bubble
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),

          // Title & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? VaultTheme.primaryText(context) : const Color(0xFF332B32),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 11.5,
                    color: isDark ? const Color(0xFFA594A1) : const Color(0xFF87767F),
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '$sign${Money(tx.amountThbSatang).format(symbol: '฿')}',
            style: VaultTheme.tabular(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF391A29) : const Color(0xFFFFF0F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: Color(0xFFFF5B9A),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n?.noTransactionsThisMonth ?? 'ยังไม่มีรายการในเดือนนี้',
            style: TextStyle(
              fontFamily: VaultTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? VaultTheme.primaryText(context) : const Color(0xFF332B32),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n?.noTransactionsDesc ?? 'เริ่มจดบันทึกรายรับหรือรายจ่ายรายการแรกเพื่อติดตามการเงินของคุณ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: VaultTheme.fontFamily,
              fontSize: 12,
              color: isDark ? const Color(0xFFA594A1) : const Color(0xFF87767F),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onAddTransaction,
            icon: const Icon(Icons.add, size: 16),
            label: Text(
              l10n?.addFirstTransaction ?? 'เพิ่มรายการแรก',
              style: const TextStyle(
                fontFamily: VaultTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF5C9D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
