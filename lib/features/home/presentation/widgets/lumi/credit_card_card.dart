import 'package:flutter/material.dart';
import '../../../../../core/money/money.dart';
import '../../../../../core/theme/vault_theme.dart';
import '../../../../../l10n/app_localizations.dart';

class CreditCardCard extends StatelessWidget {
  final int currentDebtSatang;
  final String nextCloseText;
  final VoidCallback onTap;

  const CreditCardCard({
    super.key,
    required this.currentDebtSatang,
    required this.nextCloseText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasDebt = currentDebtSatang > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16212D) : const Color(0xFFEEF8FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF233547) : const Color(0xFFCCE7FC),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0x0A1976D2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('💳', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        l10n?.creditCardSummary ?? 'บัตรเครดิต',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF90CAF9) : const Color(0xFF1E4B75),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? const Color(0xFF90CAF9) : const Color(0xFF2B79C2),
                    size: 18,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Debt & Close Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    Money(currentDebtSatang).format(symbol: '฿'),
                    style: VaultTheme.tabular(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: hasDebt
                          ? (isDark ? const Color(0xFF90CAF9) : const Color(0xFF1E4B75))
                          : (isDark ? const Color(0xFF81C784) : const Color(0xFF2E8B57)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F354D) : const Color(0xFFD9EEFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      nextCloseText,
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Text(
                hasDebt
                    ? (l10n?.creditCardPending ?? 'ยอดรอเรียกเก็บรอบบิลปัจจุบัน')
                    : (l10n?.creditCardNoDebt ?? 'ไม่มีหนี้ค้างชำระ ยอดเยี่ยมมาก! 🎉'),
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 11.5,
                  color: isDark ? const Color(0xFF8BA7C4) : const Color(0xFF537494),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
