import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/vault_theme.dart';
import 'insurance_form_dialog.dart';
import 'liability_form_dialog.dart';

class LiabilitiesInsuranceScreen extends ConsumerStatefulWidget {
  const LiabilitiesInsuranceScreen({super.key});

  @override
  ConsumerState<LiabilitiesInsuranceScreen> createState() => _LiabilitiesInsuranceScreenState();
}

class _LiabilitiesInsuranceScreenState extends ConsumerState<LiabilitiesInsuranceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    return Scaffold(
      appBar: AppBar(
        title: Text(isThai ? 'ทะเบียนหนี้สินและกรมธรรม์ประกัน' : 'Debts & Insurance Registry'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.credit_card_off_outlined), text: isThai ? 'ภาระหนี้สิน' : 'Debts'),
            Tab(icon: const Icon(Icons.security_outlined), text: isThai ? 'กรมธรรม์ประกันภัย' : 'Insurance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LiabilitiesTab(onChanged: _refresh),
          _InsuranceTab(onChanged: _refresh),
        ],
      ),
    );
  }
}

class _LiabilitiesTab extends ConsumerWidget {
  final VoidCallback onChanged;

  const _LiabilitiesTab({required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(liabilitiesDaoProvider);
    final theme = Theme.of(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return FutureBuilder(
      future: Future.wait([
        dao.getActiveLiabilities(),
        dao.getTotalLiabilitiesSatang(),
        dao.getShortTermLiabilitiesSatang(),
        dao.getTotalMonthlyPaymentSatang(),
        ref.read(accountsDaoProvider).getActiveAccounts(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(isThai ? 'เกิดข้อผิดพลาด: ${snapshot.error}' : 'Error: ${snapshot.error}'));
        }

        final items = snapshot.data![0] as List<Liability>;
        final totalDebtsSatang = snapshot.data![1] as int;
        final shortTermSatang = snapshot.data![2] as int;
        final monthlyPaymentSatang = snapshot.data![3] as int;
        final accounts = snapshot.data![4] as List<Account>;

        final accountsMap = {for (final a in accounts) a.id: a};

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final created = await LiabilityFormDialog.show(context);
              if (created == true) onChanged();
            },
            icon: const Icon(Icons.add),
            label: Text(isThai ? 'เพิ่มหนี้สิน' : 'Add Debt'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Card with High-Contrast Adaptive Theme
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: VaultTheme.negative(context).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                color: VaultTheme.surface(context),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isThai ? 'ยอดหนี้รวมทั้งหมด' : 'Total Debt Balance',
                                style: TextStyle(fontSize: 12, color: VaultTheme.secondaryText(context)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Money(totalDebtsSatang).format(symbol: '฿'),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: VaultTheme.negative(context),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isThai ? 'ภาระผ่อนต่อเดือน' : 'Monthly Payment',
                                style: TextStyle(fontSize: 12, color: VaultTheme.secondaryText(context)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Money(monthlyPaymentSatang).format(symbol: '฿'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            '${isThai ? "หนี้ระยะสั้น (<= 1 ปี)" : "Short-term (<= 1 yr)"}: ${Money(shortTermSatang).format(symbol: '฿')}',
                            style: TextStyle(fontSize: 12.5, color: theme.colorScheme.onSurfaceVariant),
                          ),
                          Text(
                            '${isThai ? "หนี้ระยะยาว" : "Long-term"}: ${Money(totalDebtsSatang - shortTermSatang).format(symbol: '฿')}',
                            style: TextStyle(fontSize: 12.5, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade400),
                      const SizedBox(height: 12),
                      Text(
                        isThai ? 'ไม่มีภาระหนี้สินคงค้าง' : 'No Outstanding Debts',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isThai ? 'คุณไม่มีหนี้สินที่บันทึกไว้ในระบบ' : 'You have no debts recorded in the system.',
                        style: TextStyle(color: VaultTheme.secondaryText(context)),
                      ),
                    ],
                  ),
                )
              else
                ...items.map((item) {
                  final linkedAccount = item.linkedAccountId != null ? accountsMap[item.linkedAccountId] : null;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: VaultTheme.border(context), width: 0.8),
                    ),
                    color: VaultTheme.surface(context),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  _getTypeLabel(item.liabilityType, isThai),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: VaultTheme.negative(context),
                                  ),
                                ),
                              ),
                              if (item.isShortTerm) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isThai ? 'ระยะสั้น' : 'Short-term',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onTertiaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () async {
                                  final edited = await LiabilityFormDialog.show(context, liability: item);
                                  if (edited == true) onChanged();
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 18, color: VaultTheme.negative(context)),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(isThai ? 'ยืนยันลบหนี้สิน' : 'Confirm Delete Debt'),
                                      content: Text(
                                        isThai
                                            ? 'คุณต้องการลบ "${item.name}" หรือไม่?'
                                            : 'Are you sure you want to delete "${item.name}"?',
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
                                    await dao.deleteLiability(item.id);
                                    onChanged();
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (linkedAccount != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.link, size: 14, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  isThai
                                      ? 'เชื่อมกับบัญชี: ${linkedAccount.name} (ดึงยอดสด)'
                                      : 'Linked account: ${linkedAccount.name} (Live balance)',
                                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isThai ? 'ยอดหนี้คงเหลือ' : 'Remaining Balance',
                                    style: TextStyle(fontSize: 11, color: VaultTheme.secondaryText(context)),
                                  ),
                                  Text(
                                    Money(item.remainingPrincipalSatang).format(symbol: '฿'),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isThai ? 'ผ่อนเดือนละ' : 'Monthly Payment',
                                    style: TextStyle(fontSize: 11, color: VaultTheme.secondaryText(context)),
                                  ),
                                  Text(
                                    Money(item.monthlyPaymentSatang).format(symbol: '฿'),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    isThai ? 'ดอกเบี้ยต่อปี' : 'Interest Rate',
                                    style: TextStyle(fontSize: 11, color: VaultTheme.secondaryText(context)),
                                  ),
                                  Text(
                                    '${item.interestRatePercent}%',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (item.note != null && item.note!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${isThai ? "หมายเหตุ" : "Note"}: ${item.note!}',
                              style: TextStyle(fontSize: 11.5, color: VaultTheme.secondaryText(context)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  String _getTypeLabel(String type, bool isThai) {
    switch (type) {
      case 'credit_card':
        return isThai ? 'บัตรเครดิต' : 'Credit Card';
      case 'personal_loan':
        return isThai ? 'สินเชื่อบุคคล' : 'Personal Loan';
      case 'mortgage':
        return isThai ? 'สินเชื่อบ้าน' : 'Mortgage';
      case 'car_loan':
      case 'auto_loan':
        return isThai ? 'สินเชื่อรถยนต์' : 'Auto Loan';
      case 'student_loan':
        return isThai ? 'กยศ.' : 'Student Loan';
      default:
        return isThai ? 'หนี้สินอื่นๆ' : 'Other Debt';
    }
  }
}

class _InsuranceTab extends ConsumerWidget {
  final VoidCallback onChanged;

  const _InsuranceTab({required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(insuranceDaoProvider);
    final theme = Theme.of(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return FutureBuilder(
      future: Future.wait([
        dao.getActivePolicies(),
        dao.getTotalSumInsuredSatang(),
        dao.getTotalMedicalCoverageSatang(),
        dao.getTotalAnnualPremiumSatang(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(isThai ? 'เกิดข้อผิดพลาด: ${snapshot.error}' : 'Error: ${snapshot.error}'));
        }

        final items = snapshot.data![0] as List<InsurancePolicy>;
        final sumInsuredSatang = snapshot.data![1] as int;
        final medicalSatang = snapshot.data![2] as int;
        final premiumSatang = snapshot.data![3] as int;

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final created = await InsuranceFormDialog.show(context);
              if (created == true) onChanged();
            },
            icon: const Icon(Icons.add),
            label: Text(isThai ? 'เพิ่มกรมธรรม์' : 'Add Policy'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: VaultTheme.border(context), width: 0.8),
                ),
                color: VaultTheme.surface(context),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isThai ? 'ทุนประกันชีวิตรวม' : 'Total Life Sum Insured',
                                style: TextStyle(fontSize: 12, color: VaultTheme.secondaryText(context)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Money(sumInsuredSatang).format(symbol: '฿'),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isThai ? 'เบี้ยประกันรวมต่อปี' : 'Annual Premium',
                                style: TextStyle(fontSize: 12, color: VaultTheme.secondaryText(context)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Money(premiumSatang).format(symbol: '฿'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            '${isThai ? "ความคุ้มครองค่ารักษา/โรคร้าย" : "Medical & CI Coverage"}: ${Money(medicalSatang).format(symbol: '฿')}',
                            style: TextStyle(fontSize: 12.5, color: theme.colorScheme.onSurfaceVariant),
                          ),
                          Text(
                            '${items.length} ${isThai ? "ฉบับ" : "policies"}',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.shield_outlined, size: 64, color: Colors.blue.shade300),
                      const SizedBox(height: 12),
                      Text(
                        isThai ? 'ยังไม่มีข้อมูลกรมธรรม์ประกันภัย' : 'No Insurance Policies Recorded',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isThai ? 'บันทึกกรมธรรม์เพื่อประเมินความคุ้มครองชีวิตและค่ารักษา' : 'Record policies to evaluate life and health protection.',
                        style: TextStyle(color: VaultTheme.secondaryText(context)),
                      ),
                    ],
                  ),
                )
              else
                ...items.map((item) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: VaultTheme.border(context), width: 0.8),
                    ),
                    color: VaultTheme.surface(context),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  _getInsuranceTypeLabel(item.insuranceType, isThai),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () async {
                                  final edited = await InsuranceFormDialog.show(context, policy: item);
                                  if (edited == true) onChanged();
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 18, color: VaultTheme.negative(context)),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(isThai ? 'ยืนยันลบกรมธรรม์' : 'Confirm Delete Policy'),
                                      content: Text(
                                        isThai
                                            ? 'คุณต้องการลบ "${item.policyName}" หรือไม่?'
                                            : 'Are you sure you want to delete "${item.policyName}"?',
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
                                    await dao.deletePolicy(item.id);
                                    onChanged();
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.policyName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (item.note != null && item.note!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.note!,
                              style: TextStyle(fontSize: 12, color: VaultTheme.secondaryText(context)),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isThai ? 'ทุนชีวิต' : 'Life Coverage',
                                    style: TextStyle(fontSize: 11, color: VaultTheme.secondaryText(context)),
                                  ),
                                  Text(
                                    Money(item.sumInsuredSatang).format(symbol: '฿'),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isThai ? 'คุ้มครองรักษา/โรคร้าย' : 'Medical / CI',
                                    style: TextStyle(fontSize: 11, color: VaultTheme.secondaryText(context)),
                                  ),
                                  Text(
                                    Money(item.medicalCoverageSatang).format(symbol: '฿'),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    isThai ? 'เบี้ยต่อปี' : 'Annual Premium',
                                    style: TextStyle(fontSize: 11, color: VaultTheme.secondaryText(context)),
                                  ),
                                  Text(
                                    Money(item.annualPremiumSatang).format(symbol: '฿'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: VaultTheme.positive(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (item.dueDate != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.event, size: 14, color: VaultTheme.secondaryText(context)),
                                const SizedBox(width: 4),
                                Text(
                                  '${isThai ? "ครบกำหนดชำระ" : "Due Date"}: ${DateFormat('dd/MM/yyyy').format(item.dueDate!)}',
                                  style: TextStyle(fontSize: 11.5, color: VaultTheme.secondaryText(context)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  String _getInsuranceTypeLabel(String type, bool isThai) {
    switch (type) {
      case 'life':
        return isThai ? 'ประกันชีวิต' : 'Life Insurance';
      case 'health':
        return isThai ? 'ประกันสุขภาพ' : 'Health Insurance';
      case 'accident':
        return isThai ? 'ประกันอุบัติเหตุ' : 'Accident';
      case 'critical_illness':
        return isThai ? 'โรคร้ายแรง' : 'Critical Illness';
      case 'savings':
        return isThai ? 'ออมทรัพย์' : 'Endowment / Savings';
      case 'unit_linked':
        return isThai ? 'ยูนิตลิงค์' : 'Unit-Linked';
      default:
        return isThai ? 'อื่นๆ' : 'Other';
    }
  }
}
