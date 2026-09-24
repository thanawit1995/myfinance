import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/vault_theme.dart';
import '../domain/remittance_assessment_engine.dart';

class ForeignRemittanceScreen extends ConsumerStatefulWidget {
  const ForeignRemittanceScreen({super.key});

  @override
  ConsumerState<ForeignRemittanceScreen> createState() => _ForeignRemittanceScreenState();
}

class _ForeignRemittanceScreenState extends ConsumerState<ForeignRemittanceScreen> {
  int _selectedRemittedYear = DateTime.now().year;
  final _currencyFormat = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(remittancesDaoProvider).syncAllTransferTransactions());
  }

  List<int> _availableRemittedYears({bool includePast = false}) {
    final currentYear = DateTime.now().year;
    final maxYear = currentYear; // Do not show future years until arrived
    final minYear = includePast ? 2020 : 2024;
    return List.generate(maxYear - minYear + 1, (i) => maxYear - i);
  }

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final remittancesDao = ref.watch(remittancesDaoProvider);
    final taxDao = ref.watch(taxDaoProvider);
    final accountsDao = ref.watch(accountsDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isThai ? 'ติดตามเงินได้ต่างประเทศ (Remittance)' : 'Foreign Remittance Tracking',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.2),
          maxLines: 2,
          softWrap: true,
        ),
        actions: [
          DropdownButton<int>(
            value: _selectedRemittedYear,
            underline: const SizedBox.shrink(),
            dropdownColor: VaultTheme.surface(context),
            style: TextStyle(
              color: VaultTheme.primaryText(context),
              fontFamily: VaultTheme.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            items: _availableRemittedYears().map((y) {
              final beYear = y + 543;
              return DropdownMenuItem(
                value: y,
                child: Text(isThai ? 'ปีที่นำเข้า $y (พ.ศ. $beYear)' : 'Remitted Year $y'),
              );
            }).toList(),
            onChanged: (y) {
              if (y != null) setState(() => _selectedRemittedYear = y);
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: isThai ? 'ระบุจำนวนวันที่อยู่ในไทย (เกณฑ์ 180 วัน)' : 'Days in Thailand (180-day rule)',
            onPressed: () => _showDaysInThailandDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(isThai ? 'บันทึกนำเงินเข้าไทย' : 'Add Remittance'),
        onPressed: () => _showAddRemittanceDialog(),
      ),
      body: StreamBuilder<TaxResidencyRecord?>(
        stream: taxDao.watchTaxResidency(_selectedRemittedYear),
        builder: (context, residencySnap) {
          final residencyDays = residencySnap.data?.daysInThailand ?? 365;

          return StreamBuilder<List<ForeignRemittance>>(
            stream: remittancesDao.watchRemittancesForYear(_selectedRemittedYear),
            builder: (context, remSnap) {
              final remittances = remSnap.data ?? [];

              return FutureBuilder<List<Account>>(
                future: accountsDao.getAllAccounts(),
                builder: (context, accSnap) {
                  final accounts = accSnap.data ?? [];
                  final accMap = {for (final a in accounts) a.id: a};

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Residency Info Banner
                      Container(
                        decoration: BoxDecoration(
                          color: VaultTheme.surface(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: VaultTheme.border(context), width: 0.75),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: VaultTheme.surfaceSubtle(context),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                residencyDays >= 180 ? Icons.home_outlined : Icons.flight_takeoff_outlined,
                                color: VaultTheme.accent(context),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isThai
                                        ? 'สถานะผู้มีถิ่นที่อยู่ในไทย ปี $_selectedRemittedYear: $residencyDays วัน'
                                        : 'Tax Residency Status in $_selectedRemittedYear: $residencyDays days',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      color: VaultTheme.primaryText(context),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isThai
                                        ? (residencyDays >= 180
                                            ? 'อยู่ในไทย >= 180 วัน เข้าเกณฑ์ Tax Resident ตาม ป.161/2566'
                                            : 'อยู่ในไทย < 180 วัน ได้รับยกเว้นตาม ป.รัษฎากร ม.41 วรรคสาม')
                                        : (residencyDays >= 180
                                            ? 'Stayed in Thailand >= 180 days (Tax Resident under P.161/2566)'
                                            : 'Stayed in Thailand < 180 days (Non-resident, Tax Exempt)'),
                                    style: TextStyle(fontSize: 11.5, color: VaultTheme.secondaryText(context)),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: VaultTheme.accent(context),
                              ),
                              onPressed: () => _showDaysInThailandDialog(initialDays: residencyDays),
                              child: Text(isThai ? 'แก้ไขวัน' : 'Edit Days'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Remittance list header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isThai
                                ? 'รายการนำเงินเข้าไทย (${remittances.length} รายการ)'
                                : 'Remittance Records (${remittances.length})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: VaultTheme.primaryText(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (remittances.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(Icons.payments_outlined, size: 48, color: VaultTheme.mutedText(context)),
                              const SizedBox(height: 12),
                              Text(
                                isThai
                                    ? 'ไม่มีรายการนำเงินเข้าไทยในปี $_selectedRemittedYear'
                                    : 'No remittances recorded in $_selectedRemittedYear',
                                style: TextStyle(color: VaultTheme.secondaryText(context)),
                              ),
                            ],
                          ),
                        )
                      else
                        ...remittances.map((r) {
                          final assess = RemittanceAssessmentEngine.assessRemittance(
                            isPrincipal: r.isPrincipal,
                            taxYearEarned: r.taxYearEarned,
                            taxYearRemitted: r.taxYearRemitted ?? _selectedRemittedYear,
                            daysInThailandYearRemitted: residencyDays,
                          );

                          final srcAcc = accMap[r.sourceAccountId]?.name ?? (isThai ? 'บัญชีต่างประเทศ' : 'Offshore Account');
                          final dstAcc = accMap[r.destinationAccountId]?.name ?? (isThai ? 'บัญชีไทย' : 'Domestic Account');

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: VaultTheme.border(context), width: 0.75),
                            ),
                            color: VaultTheme.surface(context),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _showEditRemittanceDialog(r),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('dd/MM/yyyy').format(r.remittanceDate),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: VaultTheme.primaryText(context),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            _buildStatusBadge(assess, isThai),
                                            const SizedBox(width: 6),
                                            Icon(Icons.edit_outlined, size: 16, color: VaultTheme.mutedText(context)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '$srcAcc ➔ $dstAcc',
                                            style: TextStyle(fontSize: 13, color: VaultTheme.secondaryText(context)),
                                          ),
                                        ),
                                        Text(
                                          '฿${_currencyFormat.format(r.amountThbSatang / 100.0)}',
                                          style: VaultTheme.tabular(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: VaultTheme.primaryText(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${isThai ? "เงินต่างประเทศ" : "Foreign Amount"}: ${_currencyFormat.format(r.amountOriginalSatang / 100.0)} ${r.currencyCode} (${isThai ? "เรต" : "Rate"}: ${r.fxRate})',
                                      style: TextStyle(fontSize: 12, color: VaultTheme.mutedText(context)),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: VaultTheme.surfaceSubtle(context),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: VaultTheme.border(context), width: 0.75),
                                      ),
                                      child: Text(
                                        '${isThai ? "เกิดปีภาษี" : "Tax Year Earned"}: ${r.taxYearEarned ?? "-"} | ${isThai ? "ประเภท" : "Type"}: ${r.incomeSourceType} | ${r.isPrincipal ? (isThai ? "เงินต้นเดิม" : "Principal") : (isThai ? "กำไร/ผลตอบแทน" : "Income/Gain")}\n${isThai ? "เหตุผล" : "Reason"}: ${assess.getLocalizedReason(isThai)}',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: VaultTheme.primaryText(context),
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showEditRemittanceDialog(ForeignRemittance r) async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    bool isPrincipal = r.isPrincipal;
    int taxYearEarned = r.taxYearEarned ?? (_selectedRemittedYear - 1);
    String incomeType = r.incomeSourceType;
    final noteCtrl = TextEditingController(text: r.note ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isThai ? 'แก้ไขข้อมูลภาษีนำเงินเข้าไทย' : 'Edit Remittance Tax Details'),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isThai ? "ยอดเงิน" : "Amount"}: ${_currencyFormat.format(r.amountThbSatang / 100.0)} THB (${_currencyFormat.format(r.amountOriginalSatang / 100.0)} ${r.currencyCode})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        isThai ? 'เป็นเงินต้นเดิมที่เคยส่งออกไป (ยกเว้นภาษี)' : 'Original Capital / Principal (Tax Exempt)',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(isThai
                          ? 'ไม่ใช่ผลตอบแทนหรือกำไร จึงไม่เข้าเกณฑ์เสียภาษีตามกฎหมาย'
                          : 'Not profit or earnings; exempt from tax under revenue code'),
                      value: isPrincipal,
                      onChanged: (v) => setDialogState(() => isPrincipal = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: taxYearEarned,
                      decoration: InputDecoration(
                        labelText: isThai ? 'ปีที่เกิดเงินได้ (Tax Year Earned)' : 'Tax Year Earned',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _availableRemittedYears(includePast: true).map((yr) => DropdownMenuItem(
                        value: yr,
                        child: Text(isThai ? 'ปี $yr (พ.ศ. ${yr + 543})' : 'Year $yr'),
                      )).toList(),
                      onChanged: (v) => setDialogState(() => taxYearEarned = v ?? taxYearEarned),
                    ),
                    if (taxYearEarned < 2024) ...[
                      const SizedBox(height: 6),
                      Text(
                        isThai
                            ? '✓ ได้รับยกเว้นภาษีตามคำสั่ง ป.162/2566 (เกิดก่อน 1 ม.ค. 2024)'
                            : '✓ Tax exempt under Order Paw 162/2566 (earned before Jan 1, 2024)',
                        style: TextStyle(fontSize: 12, color: VaultTheme.positive(context), fontWeight: FontWeight.bold),
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: incomeType,
                      decoration: InputDecoration(
                        labelText: isThai ? 'ประเภทของเงินได้' : 'Income Source Type',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem(value: 'capital_gain', child: Text(isThai ? 'กำไรจากการลงทุน (Capital Gain)' : 'Capital Gain')),
                        DropdownMenuItem(value: 'dividend', child: Text(isThai ? 'เงินปันผล/ดอกเบี้ย (Dividend/Interest)' : 'Dividend / Interest')),
                        DropdownMenuItem(value: 'salary', child: Text(isThai ? 'เงินเดือน/ค่าจ้าง (Salary/Offshore Income)' : 'Salary / Offshore Income')),
                        DropdownMenuItem(value: 'savings_principal', child: Text(isThai ? 'เงินออมสะสม/เงินต้น' : 'Savings / Principal')),
                        DropdownMenuItem(value: 'other', child: Text(isThai ? 'อื่นๆ (Other)' : 'Other')),
                      ],
                      onChanged: (v) => setDialogState(() => incomeType = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      decoration: InputDecoration(
                        labelText: isThai ? 'หมายเหตุ' : 'Note',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: VaultTheme.negative(context)),
                onPressed: () async {
                  await ref.read(remittancesDaoProvider).deleteRemittance(r.id);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: Text(isThai ? 'ลบรายการติดตามนี้' : 'Delete Record'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(remittancesDaoProvider).updateRemittance(
                    ForeignRemittancesCompanion(
                      id: drift.Value(r.id),
                      isPrincipal: drift.Value(isPrincipal),
                      taxYearEarned: drift.Value(taxYearEarned),
                      incomeSourceType: drift.Value(incomeType),
                      note: drift.Value(noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim()),
                      updatedAt: drift.Value(DateTime.now()),
                    ),
                  );
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: Text(isThai ? 'บันทึก' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(RemittanceAssessmentResult assess, bool isThai) {
    final isTax = assess.isTaxable;
    final color = isTax ? VaultTheme.negative(context) : VaultTheme.positive(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.75),
      ),
      child: Text(
        assess.getLocalizedStatus(isThai),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Future<void> _showDaysInThailandDialog({int initialDays = 365}) async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final ctrl = TextEditingController(text: initialDays.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'จำนวนวันที่อยู่ในไทย ปี $_selectedRemittedYear' : 'Days in Thailand in $_selectedRemittedYear'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          decoration: InputDecoration(
            labelText: isThai ? 'จำนวนวัน (1 - 366 วัน)' : 'Days (1 - 366)',
            helperText: isThai
                ? 'หากอยู่รวมตั้งแต่ 180 วันขึ้นไป จะถือเป็นผู้มีถิ่นที่อยู่ในไทย'
                : 'Staying >= 180 days qualifies as Thai Tax Resident',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(ctrl.text);
              if (val != null && val >= 0 && val <= 366) {
                Navigator.of(ctx).pop(val);
              }
            },
            child: Text(isThai ? 'บันทึก' : 'Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await ref.read(taxDaoProvider).setTaxResidency(_selectedRemittedYear, result);
    }
  }

  Future<void> _showAddRemittanceDialog() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final accounts = await ref.read(accountsDaoProvider).getActiveAccounts();
    if (!mounted) return;
    final foreignAccs = accounts.where((a) => !a.isDomestic || a.currencyCode != 'THB').toList();
    final domesticAccs = accounts.where((a) => a.isDomestic && a.currencyCode == 'THB').toList();

    if (foreignAccs.isEmpty || domesticAccs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isThai
              ? 'ต้องมีบัญชีต่างประเทศ (Offshore) และบัญชีไทย (Domestic) ก่อนบันทึก'
              : 'You need both an Offshore account and a Domestic THB account to record a remittance'),
        ),
      );
      return;
    }

    String srcAccId = foreignAccs.first.id;
    String dstAccId = domesticAccs.first.id;
    final amountCtrl = TextEditingController();
    final fxRateCtrl = TextEditingController(text: '35.000000');
    final yearEarnedCtrl = TextEditingController(text: (_selectedRemittedYear - 1).toString());
    String incomeType = 'dividend';
    bool isPrincipal = false;
    DateTime remDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isThai ? 'บันทึกการนำเงินเข้าไทย (Remittance)' : 'Record Foreign Remittance'),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: srcAccId,
                      decoration: InputDecoration(
                        labelText: isThai ? 'บัญชีต้นทาง (ต่างประเทศ)' : 'Source Account (Offshore)',
                      ),
                      items: foreignAccs.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (${a.currencyCode})'))).toList(),
                      onChanged: (v) => setDialogState(() => srcAccId = v!),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: dstAccId,
                      decoration: InputDecoration(
                        labelText: isThai ? 'บัญชีปลายทาง (ในประเทศ)' : 'Destination Account (Domestic)',
                      ),
                      items: domesticAccs.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                      onChanged: (v) => setDialogState(() => dstAccId = v!),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                            decoration: InputDecoration(
                              labelText: isThai ? 'จำนวนเงินต่างประเทศ' : 'Foreign Amount',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: fxRateCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                            decoration: InputDecoration(
                              labelText: isThai ? 'อัตราแลกเปลี่ยน (FX)' : 'Exchange Rate (FX)',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: yearEarnedCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: InputDecoration(
                        labelText: isThai ? 'ปีภาษีที่เกิดเงินได้ (Tax Year Earned)' : 'Tax Year Earned',
                        helperText: isThai
                            ? 'เช่น หากเป็นกำไรปี 2023 ที่นำเข้าปี 2025 ให้ระบุ 2023'
                            : 'e.g. For 2023 gains remitted in 2025, enter 2023',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: incomeType,
                      decoration: InputDecoration(
                        labelText: isThai ? 'ประเภทเงินได้ต้นทาง' : 'Income Source Type',
                      ),
                      items: [
                        DropdownMenuItem(value: 'dividend', child: Text(isThai ? 'เงินปันผล (Dividend)' : 'Dividend')),
                        DropdownMenuItem(value: 'capital_gain', child: Text(isThai ? 'กำไรจากการขายสินทรัพย์ (Capital Gain)' : 'Capital Gain')),
                        DropdownMenuItem(value: 'salary_freelance', child: Text(isThai ? 'เงินเดือน / รับจ้างต่างประเทศ' : 'Salary / Offshore Income')),
                        DropdownMenuItem(value: 'interest', child: Text(isThai ? 'ดอกเบี้ยเงินฝากต่างประเทศ' : 'Interest')),
                        DropdownMenuItem(value: 'principal_return', child: Text(isThai ? 'เงินต้นเดิมที่ส่งไปลงทุน' : 'Principal Return')),
                      ],
                      onChanged: (v) {
                        setDialogState(() {
                          incomeType = v!;
                          if (incomeType == 'principal_return') {
                            isPrincipal = true;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(isThai ? 'เป็นเงินต้นเดิม (ไม่ใช่กำไร)' : 'Original Principal (Not Gains)'),
                      subtitle: Text(isThai ? 'เงินต้นเดิมที่เคยส่งออกไป ไม่ต้องเสียภาษี' : 'Original capital previously sent abroad is tax-exempt'),
                      value: isPrincipal,
                      onChanged: (v) => setDialogState(() => isPrincipal = v),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                  final fx = double.tryParse(fxRateCtrl.text) ?? 1.0;
                  final amtOrigSatang = (amt * 100).round();
                  final amtThbSatang = (amt * fx * 100).round();
                  final yrEarned = int.tryParse(yearEarnedCtrl.text);

                  final srcAcc = foreignAccs.firstWhere((a) => a.id == srcAccId);
                  final now = DateTime.now();
                  final txId = const Uuid().v4();

                  // 1. Record transfer transaction in ledger
                  final transferTx = TransactionsCompanion.insert(
                    id: txId,
                    transactionType: 'transfer',
                    sourceAccountId: drift.Value(srcAccId),
                    destinationAccountId: drift.Value(dstAccId),
                    amountOriginalSatang: amtOrigSatang,
                    currencyCode: srcAcc.currencyCode,
                    fxRate: drift.Value(fxRateCtrl.text.trim()),
                    amountThbSatang: amtThbSatang,
                    feeThbSatang: const drift.Value(0),
                    tag: const drift.Value('remittance'),
                    transactionDate: remDate,
                    note: drift.Value('นำเงินกลับเข้าไทย (${isPrincipal ? "เงินต้น" : "กำไร/ผลตอบแทน"})'),
                    createdAt: now,
                    updatedAt: now,
                  );
                  await ref.read(transactionsDaoProvider).insertTransaction(transferTx);

                  // 2. Record Remittance tracking record
                  await ref.read(remittancesDaoProvider).createRemittance(
                    ForeignRemittancesCompanion.insert(
                      id: const Uuid().v4(),
                      remittanceTransactionId: txId,
                      sourceAccountId: srcAccId,
                      destinationAccountId: drift.Value(dstAccId),
                      amountOriginalSatang: amtOrigSatang,
                      currencyCode: srcAcc.currencyCode,
                      fxRate: fxRateCtrl.text.trim(),
                      amountThbSatang: amtThbSatang,
                      taxYearEarned: drift.Value(yrEarned),
                      taxYearRemitted: drift.Value(_selectedRemittedYear),
                      incomeSourceType: drift.Value(incomeType),
                      isPrincipal: drift.Value(isPrincipal),
                      remittanceDate: remDate,
                      createdAt: now,
                      updatedAt: now,
                    ),
                  );

                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: Text(isThai ? 'บันทึก' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
