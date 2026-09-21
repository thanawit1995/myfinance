import 'package:flutter/material.dart';
import '../theme/vault_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../features/transactions/presentation/quick_add_screen.dart';
import '../../features/investments/presentation/buy_sell_trade_dialog.dart';

/// Vault Add Bottom Sheet
/// Minimal, quiet luxury modal sheet with exactly 4 options:
/// 1. Expense
/// 2. Income
/// 3. Transfer
/// 4. Trade
class VaultAddSheet extends StatelessWidget {
  const VaultAddSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: VaultTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const VaultAddSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final borderCol = VaultTheme.border(context);
    final primaryTxt = VaultTheme.primaryText(context);
    final accentCol = VaultTheme.accent(context);

    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: VaultTheme.mutedText(context).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.add ?? 'Add',
              style: TextStyle(
                fontFamily: VaultTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryTxt,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Divider(color: borderCol, height: 1),
            const SizedBox(height: 8),

            // 1. Expense
            _buildOptionTile(
              context: context,
              icon: Icons.arrow_upward_rounded,
              iconColor: VaultTheme.negative(context),
              title: l10n?.expense ?? 'Expense',
              subtitle: isThai ? 'บันทึกค่าใช้จ่ายประจำวัน' : 'Record daily expense',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuickAddScreen(initialType: 'expense', isModal: true),
                  ),
                );
              },
            ),

            // 2. Income
            _buildOptionTile(
              context: context,
              icon: Icons.arrow_downward_rounded,
              iconColor: VaultTheme.positive(context),
              title: l10n?.income ?? 'Income',
              subtitle: isThai ? 'บันทึกเงินเดือน หรือรายรับอื่น' : 'Record salary or other income',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuickAddScreen(initialType: 'income', isModal: true),
                  ),
                );
              },
            ),

            // 3. Transfer
            _buildOptionTile(
              context: context,
              icon: Icons.swap_horiz_rounded,
              iconColor: accentCol,
              title: l10n?.transfer ?? 'Transfer',
              subtitle: isThai ? 'โอนเงินระหว่างบัญชี หรือแลกเปลี่ยน USD' : 'Transfer between accounts or USD FX',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuickAddScreen(initialType: 'transfer', isModal: true),
                  ),
                );
              },
            ),

            // 4. Trade
            _buildOptionTile(
              context: context,
              icon: Icons.candlestick_chart_outlined,
              iconColor: accentCol,
              title: l10n?.trade ?? 'Trade',
              subtitle: isThai ? 'บันทึกการซื้อขายหุ้น, คริปโต หรือทองคำ' : 'Record stock, crypto, or gold trades',
              onTap: () {
                Navigator.pop(context);
                BuySellTradeDialog.show(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: iconColor.withValues(alpha: 0.25), width: 0.75),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: VaultTheme.primaryText(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 12,
                      color: VaultTheme.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: VaultTheme.mutedText(context),
            ),
          ],
        ),
      ),
    );
  }
}
