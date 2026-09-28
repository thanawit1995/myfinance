import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/insurance_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/vault_theme.dart';
import '../../transactions/presentation/quick_add_screen.dart';
import 'insurance_policy_form_dialog.dart';

class InsurancePoliciesScreen extends ConsumerStatefulWidget {
  const InsurancePoliciesScreen({super.key});

  @override
  ConsumerState<InsurancePoliciesScreen> createState() => _InsurancePoliciesScreenState();
}

class _InsurancePoliciesScreenState extends ConsumerState<InsurancePoliciesScreen> {
  final List<String> _monthNamesTh = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];

  @override
  void initState() {
    super.initState();
    // Ensure default Muang Thai savings policy exists
    Future.microtask(() async {
      await ref.read(insuranceDaoProvider).getOrCreateDefaultSavingsPolicy();
      if (mounted) setState(() {});
    });
  }

  void _openAddPolicy() async {
    final changed = await InsurancePolicyFormDialog.show(context);
    if (changed == true && mounted) {
      setState(() {});
    }
  }

  void _openEditPolicy(InsurancePolicy policy) async {
    final changed = await InsurancePolicyFormDialog.show(context, existingPolicy: policy);
    if (changed == true && mounted) {
      setState(() {});
    }
  }

  void _openPayPremium(InsurancePolicy policy) {
    // Open Quick Add with policy pre-selected and amount auto-filled
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuickAddScreen(
          initialType: 'expense',
          initialCategoryId: 'cat-exp-0000-4000-8000-000000000015',
          initialPolicyId: policy.id,
          initialAmountSatang: policy.annualPremiumSatang,
          initialNote: 'ชำระเบี้ย ${policy.policyName}',
          isModal: true,
          onTransactionSaved: () {
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  String _getInsuranceTypeLabel(String type) {
    switch (type) {
      case 'savings':
      case 'endowment':
        return 'ประกันออมทรัพย์';
      case 'life':
        return 'ประกันชีวิต';
      case 'health':
        return 'ประกันสุขภาพ';
      case 'critical_illness':
        return 'ประกันโรคร้ายแรง';
      case 'accident':
        return 'ประกันอุบัติเหตุ';
      default:
        return 'ประกันภัย';
    }
  }

  Color _getInsuranceTypeColor(String type, BuildContext context) {
    switch (type) {
      case 'savings':
      case 'endowment':
        return Colors.green;
      case 'life':
        return Colors.blue;
      case 'health':
        return Colors.teal;
      case 'critical_illness':
        return Colors.purple;
      case 'accident':
        return Colors.deepOrange;
      default:
        return VaultTheme.accent(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(insuranceDaoProvider);

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      appBar: AppBar(
        title: Text(
          'กรมธรรม์ประกันภัย',
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontWeight: FontWeight.bold,
            color: VaultTheme.primaryText(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'เพิ่มกรมธรรม์',
            onPressed: _openAddPolicy,
          ),
        ],
      ),
      body: FutureBuilder<List<PolicyProgress>>(
        future: dao.getAllPolicyProgresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final progresses = snapshot.data ?? [];

          int totalSumInsuredSatang = 0;
          int totalAnnualPremiumSatang = 0;
          int totalSavingsAccumulatedSatang = 0;

          for (final p in progresses) {
            totalSumInsuredSatang += p.policy.sumInsuredSatang;
            totalAnnualPremiumSatang += p.policy.annualPremiumSatang;
            if (p.policy.insuranceType == 'savings' || p.policy.insuranceType == 'endowment') {
              totalSavingsAccumulatedSatang += p.totalPaidSatang;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Overview summary cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      title: 'เบี้ยต่อปีรวม',
                      valueText: Money(totalAnnualPremiumSatang).format(symbol: '฿'),
                      icon: Icons.payments_outlined,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      title: 'เงินสะสมในประกัน',
                      valueText: Money(totalSavingsAccumulatedSatang).format(symbol: '฿'),
                      icon: Icons.savings_outlined,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      title: 'ทุนประกันรวม',
                      valueText: Money(totalSumInsuredSatang).format(symbol: '฿'),
                      icon: Icons.security_outlined,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Policy List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'รายการกรมธรรม์ทั้งหมด (${progresses.length})',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: VaultTheme.primaryText(context),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('เพิ่มกรมธรรม์'),
                    onPressed: _openAddPolicy,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (progresses.isEmpty)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  color: VaultTheme.surface(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Column(
                      children: [
                        Icon(Icons.shield_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'ยังไม่มีข้อมูลกรมธรรม์ประกันภัย',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'เพิ่มกรมธรรม์ของคุณเพื่อติดตามค่างวด ความคุ้มครอง และแจ้งเตือนวันครบกำหนด',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: VaultTheme.accent(context)),
                          icon: const Icon(Icons.add),
                          label: const Text('เพิ่มกรมธรรม์ใหม่'),
                          onPressed: _openAddPolicy,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...progresses.map((prog) => _buildPolicyCard(context, prog)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String valueText,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: VaultTheme.surface(context),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              valueText,
              style: TextStyle(
                fontFamily: VaultTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: VaultTheme.primaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCard(BuildContext context, PolicyProgress prog) {
    final policy = prog.policy;
    final typeColor = _getInsuranceTypeColor(policy.insuranceType, context);
    final typeLabel = _getInsuranceTypeLabel(policy.insuranceType);
    final annualPremium = Money(policy.annualPremiumSatang).format(symbol: '฿');
    final totalPaid = Money(prog.totalPaidSatang).format(symbol: '฿');
    final remaining = Money(prog.remainingSatang).format(symbol: '฿');

    final progressRatio = policy.totalPeriods > 0
        ? (prog.paidPeriods / policy.totalPeriods).clamp(0.0, 1.0)
        : 1.0;

    String dueText = '-';
    if (policy.paymentDueMonth != null && policy.paymentDueDay != null) {
      dueText = 'ทุกวันที่ ${policy.paymentDueDay} ${_monthNamesTh[policy.paymentDueMonth! - 1]}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: VaultTheme.surface(context),
      elevation: 0,
      child: InkWell(
        onTap: () => _openEditPolicy(policy),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Name, Badge, Edit button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      policy.insuranceType == 'savings' || policy.insuranceType == 'endowment'
                          ? Icons.savings_outlined
                          : Icons.shield_outlined,
                      color: typeColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          policy.policyName,
                          style: TextStyle(
                            fontFamily: VaultTheme.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: VaultTheme.primaryText(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                typeLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: typeColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (prog.isPaidForCurrentYear)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, size: 12, color: Colors.green),
                                    SizedBox(width: 4),
                                    Text(
                                      'ชำระแล้วปีนี้',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                  ],
                                ),
                              )
                            else if (prog.daysUntilDue != null && prog.daysUntilDue! <= 30 && prog.daysUntilDue! >= 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ครบกำหนดในอีก ${prog.daysUntilDue} วัน',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                              )
                            else if (prog.daysUntilDue != null && prog.daysUntilDue! < 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'เลยกำหนด ${prog.daysUntilDue!.abs()} วัน',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Progress Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: VaultTheme.isDark(context) ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ความคืบหน้าการชำระเบี้ย:',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'ชำระแล้ว ${prog.paidPeriods} / ${policy.totalPeriods} งวด',
                          style: TextStyle(
                            fontFamily: VaultTheme.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: VaultTheme.accent(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        minHeight: 8,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(VaultTheme.accent(context)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ชำระแล้ว: $totalPaid',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.green),
                        ),
                        Text(
                          'คงเหลือ: $remaining',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Detail Row: Annual Premium & Due Date
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('เบี้ยประกันต่อปี', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                        const SizedBox(height: 2),
                        Text(annualPremium, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (policy.sumInsuredSatang > 0)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ทุนประกัน', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                          const SizedBox(height: 2),
                          Text(Money(policy.sumInsuredSatang).format(symbol: '฿'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('กำหนดชำระ', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                        const SizedBox(height: 2),
                        Text(dueText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action button row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: VaultTheme.accent(context),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    icon: const Icon(Icons.payment_outlined, size: 16),
                    label: const Text('ชำระเบี้ยประกัน'),
                    onPressed: () => _openPayPremium(policy),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
