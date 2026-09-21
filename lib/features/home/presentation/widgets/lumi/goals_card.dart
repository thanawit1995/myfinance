import 'package:flutter/material.dart';
import '../../../../../core/database/daos/projects_dao.dart';
import '../../../../../core/money/money.dart';
import '../../../../../core/theme/vault_theme.dart';

class GoalsCard extends StatelessWidget {
  final List<ProjectStatus> activeProjects;
  final VoidCallback onAddGoal;
  final VoidCallback onNavigateToPlan;

  const GoalsCard({
    super.key,
    required this.activeProjects,
    required this.onAddGoal,
    required this.onNavigateToPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3DCE5), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0CFF5B9A),
            blurRadius: 14,
            offset: Offset(0, 3),
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
                children: const [
                  Text('🎯', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text(
                    'เป้าหมายการเงิน',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF332B32),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: onNavigateToPlan,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                        'ดูทั้งหมด',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF87767F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Material(
                    color: const Color(0xFFFFF0F5),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: onAddGoal,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: Color(0xFFFF5B9A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (activeProjects.isEmpty)
            _buildEmptyState(context)
          else
            Column(
              children: activeProjects.take(3).map((status) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildGoalItem(context, status),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(BuildContext context, ProjectStatus status) {
    final p = status.project;
    final totalTargetSatang = p.targetBudgetSatang;
    // spentSatang in savings project represents accumulated savings
    final currentSavedSatang = status.spentSatang;
    final percent = totalTargetSatang > 0
        ? ((currentSavedSatang / totalTargetSatang) * 100).clamp(0, 100).toInt()
        : 0;

    final progressRatio = totalTargetSatang > 0
        ? (currentSavedSatang / totalTargetSatang).clamp(0.0, 1.0)
        : 0.0;

    // Pick a pastel color and icon based on project name or index
    final iconData = _getGoalIcon(p.name);
    final color = _getGoalColor(p.name);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3DCE5).withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF332B32),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${Money(currentSavedSatang).format(symbol: '฿')} / ${Money(totalTargetSatang).format(symbol: '฿')}',
                      style: VaultTheme.tabular(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF87767F),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percent%',
                  style: VaultTheme.tabular(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  color: const Color(0xFFECE5EA),
                ),
                FractionallySizedBox(
                  widthFactor: progressRatio,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE5F2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Image.asset(
              'assets/images/lumi_savings_cat.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.savings_rounded,
                color: Color(0xFFFF5B9A),
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'ยังไม่มีเป้าหมายเงินออม',
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF332B32),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'เริ่มต้นตั้งเป้าหมายแรกเพื่อความสุขในอนาคตกันเถอะ ✨',
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 11.5,
                    color: Color(0xFF87767F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGoalIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('ญี่ปุ่น') || lower.contains('japan') || lower.contains('เที่ยว') || lower.contains('travel')) {
      return Icons.flight_takeoff_rounded;
    }
    if (lower.contains('macbook') || lower.contains('คอม') || lower.contains('โน้ตบุ๊ก') || lower.contains('gadget')) {
      return Icons.laptop_mac_rounded;
    }
    if (lower.contains('ฉุกเฉิน') || lower.contains('สำรอง') || lower.contains('emergency')) {
      return Icons.shield_rounded;
    }
    return Icons.star_rounded;
  }

  Color _getGoalColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('ญี่ปุ่น') || lower.contains('japan') || lower.contains('เที่ยว') || lower.contains('travel')) {
      return const Color(0xFFFF5B9A);
    }
    if (lower.contains('macbook') || lower.contains('คอม') || lower.contains('โน้ตบุ๊ก')) {
      return const Color(0xFF7CCCF5);
    }
    if (lower.contains('ฉุกเฉิน') || lower.contains('สำรอง') || lower.contains('emergency')) {
      return const Color(0xFF77CFA0);
    }
    return const Color(0xFFFFB86A);
  }
}
