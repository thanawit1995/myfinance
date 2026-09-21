import 'package:flutter/material.dart';
import '../../../../../core/money/money.dart';
import '../../../../../core/theme/vault_theme.dart';

class BudgetHeroCard extends StatelessWidget {
  final int remainingSatang;
  final int totalBudgetSatang;
  final int totalExpenseSatang;
  final VoidCallback onTap;

  const BudgetHeroCard({
    super.key,
    required this.remainingSatang,
    required this.totalBudgetSatang,
    required this.totalExpenseSatang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentUsed = totalBudgetSatang > 0
        ? ((totalExpenseSatang / totalBudgetSatang) * 100).clamp(0, 100).toInt()
        : 0;

    final progressRatio = totalBudgetSatang > 0
        ? (totalExpenseSatang / totalBudgetSatang).clamp(0.0, 1.0)
        : 0.0;

    final isWarning = totalBudgetSatang > 0 && remainingSatang < (totalBudgetSatang * 0.2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: const BoxConstraints(minHeight: 220),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF0F5), Color(0xFFFFF7EA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFFF3DCE5), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14FF5B9A),
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
          child: Stack(
            children: [
              // ข้อมูลตัวเลขและแถบสถานะ (ด้านซ้าย)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ส่วนหัวการ์ด
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF3DCE5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('✨', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 4),
                            Text(
                              'เงินที่ใช้ได้ในเดือนนี้ 🌸',
                              style: TextStyle(
                                fontFamily: VaultTheme.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF87767F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                    const SizedBox(height: 10),

                    // ยอดเงินคงเหลือตัวโต
                    Text(
                      Money(remainingSatang).format(symbol: '฿'),
                      style: VaultTheme.tabular(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: isWarning ? const Color(0xFFE64A63) : const Color(0xFF332B32),
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ตัวเลขสรุป: ใช้ไป / จากงบทั้งหมด
                    Wrap(
                      spacing: 16,
                      runSpacing: 6,
                      children: [
                        _buildSubMetric(
                          label: 'ใช้ไปแล้ว',
                          value: Money(totalExpenseSatang).format(symbol: '฿'),
                          color: const Color(0xFFFF5B9A),
                        ),
                        _buildSubMetric(
                          label: 'จากงบรวม',
                          value: Money(totalBudgetSatang).format(symbol: '฿'),
                          color: const Color(0xFF87767F),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // แถบ Progress Bar พร้อม %
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ความคืบหน้าการใช้เงิน',
                              style: TextStyle(
                                fontFamily: VaultTheme.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF87767F),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5B9A).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ใช้ไป $percentUsed%',
                                style: VaultTheme.tabular(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFF5B9A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Container(
                                height: 10,
                                width: double.infinity,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              FractionallySizedBox(
                                widthFactor: progressRatio,
                                child: Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isWarning
                                          ? [const Color(0xFFFF6E82), const Color(0xFFE64A63)]
                                          : [const Color(0xFFFFB86A), const Color(0xFFFF5B9A)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              // ตัวการ์ตูนมาสคอต Lumi นั่งอยู่มุมขวาบน/ขวากลาง (Contained ไม่บังข้อมูล)
              Positioned(
                right: 0,
                top: 0,
                bottom: 20,
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 155,
                      height: 155,
                      child: Image.asset(
                        'assets/images/lumi_budget_character.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Image.asset(
                          'assets/images/lumi_mascot.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 12,
            color: Color(0xFF87767F),
          ),
        ),
        Text(
          value,
          style: VaultTheme.tabular(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF332B32),
          ),
        ),
      ],
    );
  }
}
