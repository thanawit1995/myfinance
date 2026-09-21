import 'package:flutter/material.dart';
import '../../../../../core/money/money.dart';
import '../../../../../core/theme/vault_theme.dart';

class PortfolioCard extends StatelessWidget {
  final int portfolioValueSatang;
  final double returnPercent;
  final VoidCallback onTap;

  const PortfolioCard({
    super.key,
    required this.portfolioValueSatang,
    required this.returnPercent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = returnPercent >= 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0FAF2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCEECD8), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A2E8B57),
                blurRadius: 10,
                offset: Offset(0, 2),
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
                    children: const [
                      Text('📈', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6),
                      Text(
                        'พอร์ตการลงทุน',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E5236),
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF2E8B57),
                    size: 18,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Portfolio Value & Return Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    Money(portfolioValueSatang).format(symbol: '฿'),
                    style: VaultTheme.tabular(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E5236),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPositive ? const Color(0xFFDCF3E4) : const Color(0xFFFFE0E5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                          size: 16,
                          color: isPositive ? const Color(0xFF2E8B57) : const Color(0xFFE64A63),
                        ),
                        Text(
                          '${isPositive ? '+' : ''}${returnPercent.toStringAsFixed(2)}%',
                          style: VaultTheme.tabular(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isPositive ? const Color(0xFF2E8B57) : const Color(0xFFE64A63),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              const Text(
                'มูลค่าสินทรัพย์การลงทุนปัจจุบัน',
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 11.5,
                  color: Color(0xFF5A7B69),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
