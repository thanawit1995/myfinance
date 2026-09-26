import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/budgets_dao.dart';
import '../../../../core/database/daos/projects_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/vault_theme.dart';
import '../../../../core/widgets/category_icon_helper.dart';
import '../../../../core/widgets/category_name_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../categories/presentation/categories_screen.dart';
import '../../categories/presentation/category_form_dialog.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = VaultTheme.accent(context);
    final l10n = AppLocalizations.of(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: VaultTheme.surface(context),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: VaultTheme.border(context)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                _tabController.animateTo(0);
                                setState(() {});
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _tabController.index == 0
                                      ? accentColor.withValues(alpha: 0.16)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  l10n?.monthlyBudgetTab ?? (isThai ? 'งบประมาณรายเดือน' : 'Monthly Budget'),
                                  style: TextStyle(
                                    fontFamily: VaultTheme.fontFamily,
                                    fontSize: 12,
                                    fontWeight: _tabController.index == 0
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                    color: _tabController.index == 0
                                        ? accentColor
                                        : VaultTheme.secondaryText(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                _tabController.animateTo(1);
                                setState(() {});
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _tabController.index == 1
                                      ? accentColor.withValues(alpha: 0.16)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  l10n?.specialProjectsTab ?? (isThai ? 'โครงการพิเศษ' : 'Projects'),
                                  style: TextStyle(
                                    fontFamily: VaultTheme.fontFamily,
                                    fontSize: 12,
                                    fontWeight: _tabController.index == 1
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                    color: _tabController.index == 1
                                        ? accentColor
                                        : VaultTheme.secondaryText(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_tabController.index == 0)
                    IconButton(
                      icon: const Icon(Icons.category_outlined, size: 20),
                      tooltip: l10n?.manageCategories ?? 'จัดการหมวดหมู่',
                      visualDensity: VisualDensity.compact,
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                        );
                        if (mounted) setState(() {});
                      },
                    ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add, size: 18),
                    tooltip: _tabController.index == 0
                        ? (isThai ? 'ตั้งงบหมวดหมู่' : 'Set Category Budget')
                        : (isThai ? 'สร้างโครงการใหม่' : 'New Project'),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      if (_tabController.index == 0) {
                        _showAddBudgetDialog(context);
                      } else {
                        _showProjectFormDialog(context);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMonthlyBudgetsTab(context),
                  _buildProjectsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBudgetsTab(BuildContext context) {
    final bgDao = ref.watch(budgetsDaoProvider);
    final now = DateTime.now();
    final isLumi = VaultTheme.isLumi(context);
    final ext = VaultTheme.extension(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<List<CategoryBudgetStatus>>(
      future: bgDao.getBudgetStatusForMonth(now.year, now.month),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'เกิดข้อผิดพลาด: ${snapshot.error}',
              style: TextStyle(color: VaultTheme.negative(context)),
            ),
          );
        }

        final budgets = snapshot.data ?? [];
        if (budgets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pie_chart_outline, size: 64, color: VaultTheme.mutedText(context)),
                const SizedBox(height: 16),
                Text(
                  isThai ? 'ยังไม่ได้ตั้งงบประมาณสำหรับหมวดหมู่ใดๆ' : 'No budget set for any category',
                  style: TextStyle(color: VaultTheme.secondaryText(context), fontSize: 15),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: VaultTheme.accent(context),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(isThai ? 'ตั้งงบประมาณหมวดหมู่' : 'Set Category Budget'),
                  onPressed: () => _showAddBudgetDialog(context),
                ),
              ],
            ),
          );
        }

        int totalLimit = 0;
        int totalSpent = 0;
        for (final b in budgets) {
          totalLimit += b.limitSatang;
          totalSpent += b.spentSatang;
        }

        final totalRemaining = totalLimit - totalSpent;
        final totalProgress = totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary Banner
            Container(
              decoration: BoxDecoration(
                gradient: isLumi ? ext?.masterBudgetGradient : null,
                color: isLumi ? null : VaultTheme.surface(context),
                borderRadius: BorderRadius.circular(isLumi ? 20 : 16),
                border: Border.all(
                  color: isLumi ? const Color(0xFFFF5C9D).withValues(alpha: 0.25) : VaultTheme.border(context),
                  width: 0.75,
                ),
                boxShadow: isLumi
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF5C9D).withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLumi ? (l10n?.summaryBudgetNonRollover ?? 'สรุปงบประมาณรวมเดือนนี้ 🌸 (ไม่ Rollover)') : 'SUMMARY BUDGET (NON-ROLLOVER)',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: isLumi ? 0.3 : 1.2,
                      color: isLumi ? const Color(0xFF8A3052) : VaultTheme.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n?.leftBudget ?? (isThai ? 'เหลือ' : 'Left')} ${Money(totalRemaining).format(symbol: '฿')}',
                        style: VaultTheme.tabular(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: VaultTheme.primaryText(context),
                        ),
                      ),
                      Text(
                        '${l10n?.totalBudgetLabel ?? (isThai ? 'งบรวม' : 'Total')} ${Money(totalLimit).format(symbol: '฿')}',
                        style: VaultTheme.tabular(
                          fontSize: 14,
                          color: VaultTheme.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: totalProgress,
                      minHeight: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        totalProgress >= 1.0
                            ? VaultTheme.negative(context)
                            : (totalProgress >= 0.8
                                ? Colors.orange
                                : (isLumi ? const Color(0xFFFF5C9D) : VaultTheme.accent(context))),
                      ),
                      backgroundColor: isLumi ? Colors.white.withValues(alpha: 0.6) : VaultTheme.border(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n?.budgetByCategory ?? (isThai ? 'งบประมาณแยกตามหมวดหมู่' : 'Budget by Category'),
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: VaultTheme.primaryText(context),
                  ),
                ),
                Text(
                  l10n?.tapItemToEdit ?? (isThai ? 'แตะรายการเพื่อแก้ไข' : 'Tap item to edit'),
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 12,
                    color: VaultTheme.secondaryText(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...budgets.map((b) => _buildBudgetTile(context, b)),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }

  Widget _buildBudgetTile(BuildContext context, CategoryBudgetStatus b) {
    final isLumi = VaultTheme.isLumi(context);
    final l10n = AppLocalizations.of(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    Color progressColor = Colors.green.shade600;
    String statusText = l10n?.budgetStatusNormal ?? (isThai ? 'ปกติ' : 'Normal');

    if (b.isExceeded) {
      progressColor = VaultTheme.negative(context);
      statusText = l10n?.budgetStatusExceeded ?? (isThai ? 'เกินงบแล้ว!' : 'Over Budget!');
    } else if (b.isWarning) {
      progressColor = Colors.orange.shade700;
      statusText = l10n?.budgetStatusWarning ?? (isThai ? 'ใกล้เต็มงบ (≥ 80%)' : 'Near Limit (≥ 80%)');
    } else if (isLumi) {
      progressColor = const Color(0xFFFF5C9D);
    }

    final percentDisplay = (b.percentUsed * 100).toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLumi ? 18 : 14),
        side: BorderSide(color: VaultTheme.border(context), width: 0.75),
      ),
      color: VaultTheme.surface(context),
      child: InkWell(
        borderRadius: BorderRadius.circular(isLumi ? 18 : 14),
        onTap: () => _showEditBudgetDialog(context, b),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: progressColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            CategoryIconHelper.getIcon(b.icon),
                            size: 18,
                            color: progressColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            b.localizedName(context),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: VaultTheme.primaryText(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.edit_outlined, size: 14, color: VaultTheme.mutedText(context)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n?.spentLabel ?? (isThai ? 'ใช้ไป' : 'Spent')}: ${Money(b.spentSatang).format(symbol: '฿')} ($percentDisplay%)',
                    style: VaultTheme.tabular(
                      fontSize: 13,
                      color: VaultTheme.secondaryText(context),
                    ),
                  ),
                  Text(
                    '${l10n?.budgetLabel ?? (isThai ? 'งบ' : 'Budget')}: ${Money(b.limitSatang).format(symbol: '฿')}',
                    style: VaultTheme.tabular(
                      fontSize: 13,
                      color: VaultTheme.secondaryText(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: b.percentUsed.clamp(0.0, 1.0),
                  minHeight: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  backgroundColor: VaultTheme.border(context),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    label: Text(
                      l10n?.deleteBudget ?? (isThai ? 'ลบงบประมาณ' : 'Delete Budget'),
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () async {
                      final catName = b.localizedName(context);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n?.confirmDeleteBudget ?? (isThai ? 'ยืนยันลบงบประมาณ' : 'Confirm Delete Budget')),
                          content: Text(
                            isThai
                                ? 'ต้องการลบงบประมาณสำหรับ "$catName" หรือไม่?\n\n(ข้อมูลรายจ่ายที่บันทึกไปแล้วจะไม่หายไป)'
                                : 'Delete budget for "$catName"?\n\n(Recorded expenses will not be lost)',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(isThai ? 'ลบ' : 'Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref.read(budgetsDaoProvider).deleteBudget(b.budgetId);
                        if (mounted) setState(() {});
                      }
                    },
                  ),
                  Text(
                    b.remainingSatang >= 0
                        ? '${l10n?.leftBudget ?? (isThai ? 'เหลืออีก' : 'Left')} ${Money(b.remainingSatang).format(symbol: '฿')}'
                        : '${isThai ? 'เกินงบไป' : 'Over by'} ${Money(b.remainingSatang.abs()).format(symbol: '฿')}',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: b.remainingSatang >= 0 ? Colors.green.shade700 : VaultTheme.negative(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsTab(BuildContext context) {
    final projectsDao = ref.watch(projectsDaoProvider);
    final isLumi = VaultTheme.isLumi(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return FutureBuilder<List<ProjectStatus>>(
      future: projectsDao.getAllActiveProjectStatuses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'เกิดข้อผิดพลาด: ${snapshot.error}',
              style: TextStyle(color: VaultTheme.negative(context)),
            ),
          );
        }

        final projectStatuses = snapshot.data ?? [];
        if (projectStatuses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_special_outlined, size: 64, color: VaultTheme.mutedText(context)),
                const SizedBox(height: 16),
                Text(
                  isThai ? 'ยังไม่มีโครงการพิเศษที่กำลังดำเนินการ' : 'No active special projects yet',
                  style: TextStyle(color: VaultTheme.secondaryText(context), fontSize: 15),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: VaultTheme.accent(context),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(isThai ? 'สร้างโครงการใหม่' : 'New Project'),
                  onPressed: () => _showProjectFormDialog(context),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projectStatuses.length + 1,
          itemBuilder: (context, index) {
            if (index == projectStatuses.length) {
              return const SizedBox(height: 80);
            }

            final ps = projectStatuses[index];
            final p = ps.project;
            final percent = (ps.percentUsed * 100).toStringAsFixed(0);

            Color progressColor = Colors.green.shade600;
            String statusText = isThai ? 'ปกติ' : 'Normal';
            if (ps.isOverBudget) {
              progressColor = VaultTheme.negative(context);
              statusText = isThai ? 'เกินงบแล้ว!' : 'Over budget!';
            } else if (ps.percentUsed >= 0.8) {
              progressColor = Colors.orange.shade700;
              statusText = isThai ? 'ใกล้เต็มงบ (≥ 80%)' : 'Near limit (≥ 80%)';
            } else if (isLumi) {
              progressColor = const Color(0xFFFF5C9D);
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isLumi ? 20 : 16),
                side: BorderSide(color: VaultTheme.border(context), width: 0.75),
              ),
              color: VaultTheme.surface(context),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.all(16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.name,
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: VaultTheme.primaryText(context),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: progressColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      isThai
                          ? 'ระยะเวลา: ${p.startDate.day}/${p.startDate.month}/${p.startDate.year} - ${p.endDate.day}/${p.endDate.month}/${p.endDate.year} (เหลือ ${ps.daysLeft} วัน)'
                          : 'Period: ${p.startDate.day}/${p.startDate.month}/${p.startDate.year} - ${p.endDate.day}/${p.endDate.month}/${p.endDate.year} (${ps.daysLeft} days left)',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 12,
                        color: VaultTheme.secondaryText(context),
                      ),
                    ),
                    if (p.description != null && p.description!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        p.description!,
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 12,
                          color: VaultTheme.mutedText(context),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${isThai ? "ใช้ไป" : "Spent"}: ${Money(ps.spentSatang).format(symbol: "฿")} ($percent%)',
                          style: VaultTheme.tabular(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: VaultTheme.primaryText(context),
                          ),
                        ),
                        Text(
                          '${isThai ? "งบ" : "Budget"}: ${Money(p.targetBudgetSatang).format(symbol: "฿")}',
                          style: VaultTheme.tabular(
                            fontSize: 13,
                            color: VaultTheme.secondaryText(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ps.percentUsed.clamp(0.0, 1.0),
                        minHeight: 8,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        backgroundColor: VaultTheme.border(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        ps.remainingSatang >= 0
                            ? '${isThai ? "เหลืองบอีก" : "Remaining"} ${Money(ps.remainingSatang).format(symbol: "฿")}'
                            : '${isThai ? "เกินงบไป" : "Over by"} ${Money(ps.remainingSatang.abs()).format(symbol: "฿")}',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ps.remainingSatang >= 0 ? Colors.green.shade700 : VaultTheme.negative(context),
                        ),
                      ),
                    ),
                  ],
                ),
                children: [
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isThai
                            ? 'รายการใช้จ่ายในโครงการ (${ps.transactions.length})'
                            : 'Project Transactions (${ps.transactions.length})',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: VaultTheme.primaryText(context),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_outlined, size: 20, color: VaultTheme.secondaryText(context)),
                            tooltip: isThai ? 'แก้ไขโครงการ' : 'Edit project',
                            onPressed: () => _showProjectFormDialog(context, p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            tooltip: isThai ? 'ลบโครงการ' : 'Delete project',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(isThai ? 'ยืนยันลบโครงการ' : 'Confirm Delete Project'),
                                  content: Text(
                                    isThai
                                        ? 'คุณต้องการลบโครงการ "${p.name}" ใช่หรือไม่?'
                                        : 'Do you want to delete project "${p.name}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: Text(isThai ? 'ลบโครงการ' : 'Delete Project'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref.read(projectsDaoProvider).deleteProject(p.id);
                                if (mounted) setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (ps.transactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        isThai
                            ? 'ยังไม่มีรายการที่ผูกกับโครงการนี้\n(สามารถเลือกโครงการได้ในหน้า "บันทึกด่วน")'
                            : 'No transactions linked to this project yet\n(Select project in Quick Add)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: VaultTheme.mutedText(context), fontSize: 12),
                      ),
                    )
                  else
                    ...ps.transactions.map((tx) {
                      final isTxExpense = tx.transactionType == 'expense';
                      final amount = tx.amountThbSatang + tx.feeThbSatang;
                      final defaultTxTitle = isTxExpense
                          ? (isThai ? 'รายจ่ายโครงการ' : 'Project Expense')
                          : (isThai ? 'รายรับโครงการ' : 'Project Income');
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isTxExpense ? Icons.remove_circle_outline : Icons.add_circle_outline,
                          color: isTxExpense ? VaultTheme.negative(context) : VaultTheme.positive(context),
                          size: 20,
                        ),
                        title: Text(
                          tx.note ?? defaultTxTitle,
                          style: TextStyle(
                            fontFamily: VaultTheme.fontFamily,
                            fontSize: 13,
                            color: VaultTheme.primaryText(context),
                          ),
                        ),
                        subtitle: Text(
                          '${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}',
                          style: TextStyle(
                            fontFamily: VaultTheme.fontFamily,
                            fontSize: 11,
                            color: VaultTheme.secondaryText(context),
                          ),
                        ),
                        trailing: Text(
                          '${isTxExpense ? "-" : "+"}${Money(amount).format(symbol: "฿")}',
                          style: VaultTheme.tabular(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isTxExpense ? VaultTheme.negative(context) : VaultTheme.positive(context),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddBudgetDialog(BuildContext context) async {
    var categories = await ref.read(categoriesDaoProvider).getActiveCategories('expense');
    String? selectedCatId = categories.isNotEmpty ? categories.first.id : null;
    final amountController = TextEditingController();

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) {
        final isThai = Localizations.localeOf(context).languageCode == 'th';
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text(isThai ? 'ตั้งงบประมาณรายเดือน' : 'Set Monthly Budget'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: isThai ? 'เลือกหมวดหมู่' : 'Select Category',
                            border: const OutlineInputBorder(),
                          ),
                          isExpanded: true,
                          initialValue: selectedCatId,
                          items: categories
                              .map((c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Row(
                                      children: [
                                        Icon(CategoryIconHelper.getIcon(c.icon), size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            c.localizedName(context),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) => setDialogState(() => selectedCatId = val),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: isThai ? 'สร้างหมวดหมู่ใหม่' : 'New Category',
                        child: IconButton.filled(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () async {
                            Navigator.of(ctx).pop('_create_new_category_');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      labelText: isThai ? 'จำนวนเงินงบประมาณ (บาท)' : 'Budget Amount (THB)',
                      prefixText: '฿ ',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
                FilledButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount > 0 && selectedCatId != null) {
                      final satang = (amount * 100).round();
                      await ref.read(budgetsDaoProvider).setBudget(categoryId: selectedCatId!, limitSatang: satang);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                      if (mounted) setState(() {});
                    }
                  },
                  child: Text(isThai ? 'บันทึก' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    ).then((result) async {
      if (result == '_create_new_category_' && context.mounted) {
        final newCat = await CategoryFormDialog.show(context, initialType: 'expense');
        if (newCat != null && context.mounted) {
          final updatedCategories = await ref.read(categoriesDaoProvider).getActiveCategories('expense');
          if (context.mounted) {
            String? preselect = newCat.id;
            await _showAddBudgetDialogWithPreselect(context, updatedCategories, preselect);
          }
        }
      }
    });
  }

  Future<void> _showAddBudgetDialogWithPreselect(
    BuildContext context,
    List<Category> categories,
    String? preselectedId,
  ) async {
    String? selectedCatId = preselectedId ?? (categories.isNotEmpty ? categories.first.id : null);
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        final isThai = Localizations.localeOf(ctx).languageCode == 'th';
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text(isThai ? 'ตั้งงบประมาณรายเดือน' : 'Set Monthly Budget'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: isThai ? 'เลือกหมวดหมู่' : 'Select Category',
                            border: const OutlineInputBorder(),
                          ),
                          isExpanded: true,
                          initialValue: selectedCatId,
                          items: categories
                              .map((c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Row(
                                      children: [
                                        Icon(CategoryIconHelper.getIcon(c.icon), size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            c.localizedName(context),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) => setDialogState(() => selectedCatId = val),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: isThai ? 'สร้างหมวดหมู่ใหม่' : 'Create New Category',
                        child: IconButton.filled(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () async {
                            Navigator.of(ctx).pop('_create_new_category_');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      labelText: isThai ? 'จำนวนเงินงบประมาณ (บาท)' : 'Budget Amount (THB)',
                      prefixText: '฿ ',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
                FilledButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (amount > 0 && selectedCatId != null) {
                      final satang = (amount * 100).round();
                      await ref.read(budgetsDaoProvider).setBudget(categoryId: selectedCatId!, limitSatang: satang);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                      if (mounted) setState(() {});
                    }
                  },
                  child: Text(isThai ? 'บันทึก' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    ).then((result) async {
      if (result == '_create_new_category_' && context.mounted) {
        final newCat = await CategoryFormDialog.show(context, initialType: 'expense');
        if (newCat != null && context.mounted) {
          final updatedCategories = await ref.read(categoriesDaoProvider).getActiveCategories('expense');
          if (context.mounted) {
            String? preselect = newCat.id;
            await _showAddBudgetDialogWithPreselect(context, updatedCategories, preselect);
          }
        }
      }
    });
  }

  Future<void> _showEditBudgetDialog(BuildContext context, CategoryBudgetStatus b) async {
    final amountController = TextEditingController(text: (b.limitSatang / 100).toStringAsFixed(0));
    final catName = b.localizedName(context);

    await showDialog(
      context: context,
      builder: (ctx) {
        final isThai = Localizations.localeOf(ctx).languageCode == 'th';
        return AlertDialog(
          title: Text(isThai ? 'แก้ไขงบประมาณ: $catName' : 'Edit Budget: $catName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${isThai ? "ใช้ไปแล้วในเดือนนี้" : "Spent this month"}: ${Money(b.spentSatang).format(symbol: "฿")}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                autofocus: true,
                decoration: InputDecoration(
                  labelText: isThai ? 'งบประมาณใหม่ (บาท)' : 'New Budget (THB)',
                  prefixText: '฿ ',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: ctx,
                  builder: (confirmCtx) => AlertDialog(
                    title: Text(isThai ? 'ยืนยันลบงบประมาณ' : 'Delete Budget'),
                    content: Text(
                        isThai
                            ? 'คุณต้องการลบงบประมาณของหมวดหมู่ "$catName" ใช่หรือไม่? (ไม่กระทบกับบันทึกค่าใช้จ่ายที่มีอยู่)'
                            : 'Do you want to delete budget for "$catName"? (Does not affect existing transactions)'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(confirmCtx).pop(false), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.of(confirmCtx).pop(true),
                        child: Text(isThai ? 'ลบงบประมาณ' : 'Delete Budget'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(budgetsDaoProvider).deleteBudget(b.budgetId);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (mounted) setState(() {});
                }
              },
              child: Text(isThai ? 'ลบงบประมาณ' : 'Delete Budget'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                if (amount > 0) {
                  final satang = (amount * 100).round();
                  await ref.read(budgetsDaoProvider).setBudget(categoryId: b.categoryId, limitSatang: satang);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (mounted) setState(() {});
                }
              },
              child: Text(isThai ? 'บันทึก' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showProjectFormDialog(BuildContext context, [Project? existing]) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');
    final budgetController = TextEditingController(
      text: existing != null ? (existing.targetBudgetSatang / 100).toStringAsFixed(0) : '',
    );
    DateTime startDate = existing?.startDate ?? DateTime.now();
    DateTime endDate = existing?.endDate ?? DateTime.now().add(const Duration(days: 30));

    await showDialog(
      context: context,
      builder: (ctx) {
        final isThai = Localizations.localeOf(ctx).languageCode == 'th';
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text(existing == null
                  ? (isThai ? 'สร้างโครงการพิเศษใหม่' : 'New Special Project')
                  : (isThai ? 'แก้ไขโครงการ' : 'Edit Project')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: isThai ? 'ชื่อโครงการ *' : 'Project Name *',
                        hintText: isThai ? 'เช่น เที่ยวญี่ปุ่น, รีโนเวทบ้าน, จัดงานแต่ง' : 'e.g. Japan Trip, Home Renovation, Wedding',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: budgetController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        labelText: isThai ? 'งบประมาณเป้าหมาย (บาท) *' : 'Target Budget (THB) *',
                        prefixText: '฿ ',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: isThai ? 'คำอธิบาย / รายละเอียด (ไม่บังคับ)' : 'Description (Optional)',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(dialogCtx).dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isThai ? 'ระยะเวลาโครงการ' : 'Project Period',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(dialogCtx).hintColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: dialogCtx,
                                      initialDate: startDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2050),
                                    );
                                    if (picked != null) {
                                      setDialogState(() => startDate = picked);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: VaultTheme.accent(dialogCtx)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${isThai ? "เริ่ม: " : "Start: "}${startDate.day}/${startDate.month}/${startDate.year}',
                                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.arrow_forward, size: 14, color: Theme.of(dialogCtx).hintColor),
                              ),
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: dialogCtx,
                                      initialDate: endDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2050),
                                    );
                                    if (picked != null) {
                                      setDialogState(() => endDate = picked);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.event, size: 16, color: VaultTheme.accent(dialogCtx)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${isThai ? "สิ้นสุด: " : "End: "}${endDate.day}/${endDate.month}/${endDate.year}',
                                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final budget = double.tryParse(budgetController.text.trim()) ?? 0.0;
                    if (name.isEmpty || budget <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isThai
                              ? 'กรุณาระบุชื่อโครงการและงบประมาณให้ถูกต้อง'
                              : 'Please enter a valid project name and budget'),
                        ),
                      );
                      return;
                    }

                    final satang = (budget * 100).round();
                    final projectsDao = ref.read(projectsDaoProvider);
                    final now = DateTime.now();

                    if (existing == null) {
                      await projectsDao.createProject(
                        ProjectsCompanion.insert(
                          id: const Uuid().v4(),
                          name: name,
                          description: Value(descController.text.trim().isEmpty ? null : descController.text.trim()),
                          targetBudgetSatang: satang,
                          startDate: startDate,
                          endDate: endDate,
                          isActive: const Value(true),
                          createdAt: now,
                          updatedAt: now,
                        ),
                      );
                    } else {
                      await projectsDao.updateProject(
                        ProjectsCompanion(
                          id: Value(existing.id),
                          name: Value(name),
                          description: Value(descController.text.trim().isEmpty ? null : descController.text.trim()),
                          targetBudgetSatang: Value(satang),
                          startDate: Value(startDate),
                          endDate: Value(endDate),
                          updatedAt: Value(now),
                        ),
                      );
                    }

                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (mounted) setState(() {});
                  },
                  child: Text(isThai ? 'บันทึก' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
