import 'package:flutter/material.dart';
import '../../../../../core/theme/vault_theme.dart';

class LumiTipCard extends StatelessWidget {
  final String message;
  final bool isWarning;
  final VoidCallback? onTap;

  const LumiTipCard({
    super.key,
    required this.message,
    this.isWarning = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark
        ? (isWarning ? const Color(0xFF2E171C) : const Color(0xFF281F14))
        : (isWarning ? const Color(0xFFFFF0F2) : const Color(0xFFFFF4E3));

    final Color borderColor = isDark
        ? (isWarning ? const Color(0xFF4F242C) : const Color(0xFF45341E))
        : (isWarning ? const Color(0xFFFFCCD4) : const Color(0xFFFFE0B8));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : (isWarning ? const Color(0x0DE64A63) : const Color(0x0DFF9800)),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Momo cat mascot avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF231B2B) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? (isWarning ? const Color(0xFF5A2B35) : const Color(0xFF553F24))
                        : (isWarning ? const Color(0xFFFFCCD4) : const Color(0xFFFFDDB0)),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/lumi_cat_crisp.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.pets_rounded,
                      color: Color(0xFFFF9800),
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Advice content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isWarning
                              ? (isThai ? 'แจ้งเตือนสำคัญ ⚠️' : 'Important Alert ⚠️')
                              : (isThai ? 'คำแนะนำจาก Lumi 💡' : 'Lumi Insight 💡'),
                          style: TextStyle(
                            fontFamily: VaultTheme.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isWarning
                                ? (isDark ? const Color(0xFFFF7A88) : const Color(0xFFD32F2F))
                                : (isDark ? const Color(0xFFFFB74D) : const Color(0xFFD97706)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message,
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: isDark ? VaultTheme.primaryText(context) : const Color(0xFF332B32),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: isWarning
                    ? (isDark ? const Color(0xFFFF7A88) : const Color(0xFFE64A63))
                    : (isDark ? const Color(0xFFA594A1) : const Color(0xFF87767F)),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
