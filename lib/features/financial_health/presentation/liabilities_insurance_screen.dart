import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('ทะเบียนหนี้สินและกรมธรรม์ประกัน'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.credit_card_off_outlined), text: 'ภาระหนี้สิน'),
            Tab(icon: Icon(Icons.security_outlined), text: 'กรมธรรม์ประกันภัย'),
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
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
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
            label: const Text('เพิ่มหนี้สิน'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
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
                              const Text('ยอดหนี้รวมทั้งหมด', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                Money(totalDebtsSatang).format(symbol: '฿'),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('ภาระผ่อนต่อเดือน', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'หนี้ระยะสั้น (<= 1 ปี): ${Money(shortTermSatang).format(symbol: '฿')}',
                            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                          ),
                          Text(
                            'หนี้ระยะยาว: ${Money(totalDebtsSatang - shortTermSatang).format(symbol: '฿')}',
                            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
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
                      const Text(
                        'ไม่มีภาระหนี้สินคงค้าง',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('คุณไม่มีหนี้สินที่บันทึกไว้ในระบบ', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              else
                ...items.map((item) {
                  final linkedAccount = item.linkedAccountId != null ? accountsMap[item.linkedAccountId] : null;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                                  color: Colors.deepOrange.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.deepOrange.shade200),
                                ),
                                child: Text(
                                  _getTypeLabel(item.liabilityType),
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade800),
                                ),
                              ),
                              if (item.isShortTerm) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('ระยะสั้น', style: TextStyle(fontSize: 10.5, color: Colors.brown)),
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
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('ยืนยันลบหนี้สิน'),
                                      content: Text('คุณต้องการลบ "${item.name}" หรือไม่?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
                                        FilledButton(
                                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                          child: const Text('ลบ'),
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
                                  'เชื่อมกับบัญชี: ${linkedAccount.name} (ดึงยอดสด)',
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
                                  const Text('ยอดหนี้คงเหลือ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text(
                                    Money(item.remainingPrincipalSatang).format(symbol: '฿'),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('ผ่อนเดือนละ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text(
                                    Money(item.monthlyPaymentSatang).format(symbol: '฿'),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('ดอกเบี้ยต่อปี', style: TextStyle(fontSize: 11, color: Colors.grey)),
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
                            Text('หมายเหตุ: ${item.note!}', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
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

  String _getTypeLabel(String type) {
    switch (type) {
      case 'credit_card':
        return 'บัตรเครดิต';
      case 'personal_loan':
        return 'สินเชื่อบุคคล';
      case 'mortgage':
        return 'สินเชื่อบ้าน';
      case 'car_loan':
        return 'สินเชื่อรถยนต์';
      case 'student_loan':
        return 'กยศ.';
      default:
        return 'หนี้สินอื่นๆ';
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
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
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
            label: const Text('เพิ่มกรมธรรม์'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
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
                              const Text('ทุนประกันชีวิตรวม', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                              const Text('เบี้ยประกันรวมต่อปี', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ความคุ้มครองค่ารักษา/โรคร้าย: ${Money(medicalSatang).format(symbol: '฿')}',
                            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                          ),
                          Text(
                            '${items.length} ฉบับ',
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
                      const Text(
                        'ยังไม่มีข้อมูลกรมธรรม์ประกันภัย',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('บันทึกกรมธรรม์เพื่อประเมินความคุ้มครองชีวิตและค่ารักษา', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              else
                ...items.map((item) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Text(
                                  _getTypeLabel(item.insuranceType),
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
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
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('ยืนยันลบกรมธรรม์'),
                                      content: Text('คุณต้องการลบ "${item.policyName}" หรือไม่?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
                                        FilledButton(
                                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                          child: const Text('ลบ'),
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
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('ทุนชีวิต', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text(
                                    Money(item.sumInsuredSatang).format(symbol: '฿'),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('คุ้มครองรักษา/โรคร้าย', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text(
                                    Money(item.medicalCoverageSatang).format(symbol: '฿'),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('เบี้ยต่อปี', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text(
                                    Money(item.annualPremiumSatang).format(symbol: '฿'),
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (item.dueDate != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.event, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  'ครบกำหนดชำระ: ${DateFormat('dd/MM/yyyy').format(item.dueDate!)}',
                                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
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

  String _getTypeLabel(String type) {
    switch (type) {
      case 'life':
        return 'ประกันชีวิต';
      case 'health':
        return 'ประกันสุขภาพ';
      case 'accident':
        return 'ประกันอุบัติเหตุ';
      case 'critical_illness':
        return 'โรคร้ายแรง';
      case 'savings':
        return 'ออมทรัพย์';
      case 'unit_linked':
        return 'ยูนิตลิงค์';
      default:
        return 'อื่นๆ';
    }
  }
}
