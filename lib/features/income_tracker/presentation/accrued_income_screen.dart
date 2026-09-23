import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/vault_theme.dart';

class AccruedIncomeScreen extends ConsumerStatefulWidget {
  const AccruedIncomeScreen({super.key});

  @override
  ConsumerState<AccruedIncomeScreen> createState() => _AccruedIncomeScreenState();
}

class _AccruedIncomeScreenState extends ConsumerState<AccruedIncomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatWorkPeriod(String? period) {
    if (period == null || period.trim().isEmpty) {
      return 'ไม่ระบุรอบเดือน (Unspecified Period)';
    }
    final parts = period.trim().split('-');
    if (parts.length == 2) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year != null && month != null && month >= 1 && month <= 12) {
        const thaiMonths = [
          'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
          'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
        ];
        return '${thaiMonths[month - 1]} $year (${year + 543})';
      }
    }
    return period;
  }

  @override
  Widget build(BuildContext context) {
    final txDao = ref.watch(transactionsDaoProvider);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      appBar: AppBar(
        backgroundColor: VaultTheme.surface(context),
        title: Text(
          isThai ? 'ติดตามรายได้ค้างรับ & เงินตกเบิก' : 'Accrued Income & Arrears Tracker',
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: VaultTheme.primaryText(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: isThai ? 'บันทึกรายได้ค้างรับใหม่' : 'Add Accrued Income',
            color: VaultTheme.accent(context),
            onPressed: () => _showAddAccruedIncomeDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: txDao.watchAccruedIncomes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: VaultTheme.accent(context)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'เกิดข้อผิดพลาด: ${snapshot.error}',
                style: TextStyle(color: VaultTheme.negative(context)),
              ),
            );
          }

          final allItems = snapshot.data ?? [];

          // Filter by search
          final items = allItems.where((tx) {
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            final note = (tx.note ?? '').toLowerCase();
            final tag = (tx.tag ?? '').toLowerCase();
            final period = (tx.workPeriod ?? '').toLowerCase();
            return note.contains(q) || tag.contains(q) || period.contains(q);
          }).toList();

          // Summary Stats
          final totalPendingSatang = allItems.fold<int>(
            0,
            (sum, tx) => sum + (tx.expectedAmountSatang ?? tx.amountThbSatang),
          );

          // Group by workPeriod
          final grouped = <String, List<Transaction>>{};
          for (final tx in items) {
            final period = tx.workPeriod ?? '';
            grouped.putIfAbsent(period, () => []).add(tx);
          }

          final sortedPeriods = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return Column(
            children: [
              // Summary Banner
              _buildSummaryHeader(
                context,
                totalPendingSatang: totalPendingSatang,
                totalItemsCount: allItems.length,
                pendingMonthsCount: grouped.keys.where((k) => k.isNotEmpty).length,
                isThai: isThai,
              ),

              // Search Filter Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: isThai
                        ? 'ค้นหาชื่อรายการ, ค่าเวร, รอบเดือน...'
                        : 'Search item, shift, period...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: VaultTheme.surface(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
              ),

              // List of Accrued Incomes
              Expanded(
                child: items.isEmpty
                    ? _buildEmptyState(context, isThai)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: sortedPeriods.length,
                        itemBuilder: (context, index) {
                          final periodKey = sortedPeriods[index];
                          final periodItems = grouped[periodKey]!;
                          return _buildPeriodSection(
                            context,
                            periodKey: periodKey,
                            items: periodItems,
                            isThai: isThai,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context, {
    required int totalPendingSatang,
    required int totalItemsCount,
    required int pendingMonthsCount,
    required bool isThai,
  }) {
    final currencyText = Money.fromSatang(totalPendingSatang).format();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VaultTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: totalItemsCount > 0 ? Colors.amber.withValues(alpha: 0.3) : VaultTheme.accent(context).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pending_actions_rounded,
                    color: totalItemsCount > 0 ? Colors.amber.shade700 : VaultTheme.positive(context),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isThai ? 'ยอดเงินค้างรับทั้งหมด' : 'Total Pending Income',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: VaultTheme.secondaryText(context),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: totalItemsCount > 0
                      ? Colors.amber.withValues(alpha: 0.15)
                      : VaultTheme.positive(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  totalItemsCount > 0
                      ? (isThai ? 'ค้างจ่าย $pendingMonthsCount รอบเดือน' : '$pendingMonthsCount months pending')
                      : (isThai ? 'รับครบถ้วน' : 'All cleared'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: totalItemsCount > 0 ? Colors.amber.shade800 : VaultTheme.positive(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            currencyText,
            style: TextStyle(
              fontFamily: VaultTheme.fontFamily,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: totalItemsCount > 0 ? Colors.amber.shade900 : VaultTheme.positive(context),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isThai
                ? 'ยอดเงินยังไม่รวมในยอดเงินสดคงเหลือ จนกว่าจะบันทึกรับเงินจริง'
                : 'Not counted in cash balance until marked as received.',
            style: TextStyle(
              fontSize: 12,
              color: VaultTheme.secondaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSection(
    BuildContext context, {
    required String periodKey,
    required List<Transaction> items,
    required bool isThai,
  }) {
    final periodSatang = items.fold<int>(
      0,
      (sum, tx) => sum + (tx.expectedAmountSatang ?? tx.amountThbSatang),
    );
    final periodFormatted = Money.fromSatang(periodSatang).format();
    final periodTitle = _formatWorkPeriod(periodKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: VaultTheme.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: VaultTheme.background(context).withValues(alpha: 0.6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_outlined, size: 18, color: VaultTheme.accent(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        periodTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${items.length} ${isThai ? "รายการ" : "items"} • $periodFormatted',
                        style: TextStyle(
                          fontSize: 12,
                          color: VaultTheme.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.done_all, size: 16),
                  label: Text(isThai ? 'รับทั้งรอบ' : 'Receive All', style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: VaultTheme.positive(context),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  onPressed: () => _showBatchReceiveDialog(context, periodTitle, items, isThai),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // Transaction Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
            itemBuilder: (context, idx) {
              final tx = items[idx];
              return _buildTransactionRow(context, tx, isThai);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(BuildContext context, Transaction tx, bool isThai) {
    final expectedSatang = tx.expectedAmountSatang ?? tx.amountThbSatang;
    final amountText = Money.fromSatang(expectedSatang).format();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final title = tx.note?.isNotEmpty == true ? tx.note! : (isThai ? 'รายได้แพทย์ค้างรับ' : 'Accrued Income');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule_rounded, color: Colors.amber, size: 20),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (tx.tag != null && tx.tag!.isNotEmpty) ...[
                      Text(
                        tx.tag!,
                        style: TextStyle(
                          fontSize: 11,
                          color: VaultTheme.secondaryText(context),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('•', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      dateFormat.format(tx.transactionDate),
                      style: TextStyle(
                        fontSize: 11,
                        color: VaultTheme.secondaryText(context),
                      ),
                    ),
                    if (tx.taxCategory != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tx.taxCategory!,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Amount & Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.amber.shade900,
                ),
              ),
              const SizedBox(height: 4),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 14),
                label: Text(isThai ? 'รับเงินแล้ว' : 'Mark Received', style: const TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaultTheme.positive(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: const Size(60, 26),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () => _showMarkReceivedDialog(context, tx, isThai),
              ),
            ],
          ),

          // Options Menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade500),
            padding: EdgeInsets.zero,
            onSelected: (action) async {
              if (action == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(isThai ? 'ลบรายการค้างรับ?' : 'Delete Item?'),
                    content: Text(isThai ? 'คุณต้องการลบรายการนี้ใช่หรือไม่' : 'Do you want to delete this accrued item?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(isThai ? 'ลบ' : 'Delete', style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await ref.read(transactionsDaoProvider).softDeleteTransaction(tx.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isThai ? 'ลบรายการแล้ว' : 'Item deleted')),
                    );
                  }
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(isThai ? 'ลบรายการ' : 'Delete', style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isThai) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: VaultTheme.positive(context).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.verified_rounded, size: 48, color: VaultTheme.positive(context)),
            ),
            const SizedBox(height: 16),
            Text(
              isThai ? 'ไม่มีรายได้ค้างรับ' : 'No Accrued Incomes',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isThai
                  ? 'ทุกรายการค่าเวรและเงินสนับสนุนได้รับเงินเข้าบัญชีครบถ้วนแล้ว 🎉'
                  : 'All medical fees and allowances have been received.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: VaultTheme.secondaryText(context)),
            ),
          ],
        ),
      ),
    );
  }

  // --- Dialogs ---

  /// Dialog บันทึกรับเงินเข้าบัญชี (รายตัว)
  Future<void> _showMarkReceivedDialog(BuildContext context, Transaction tx, bool isThai) async {
    final accounts = await ref.read(accountsDaoProvider).getActiveAccounts();
    if (!context.mounted) return;

    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isThai ? 'กรุณาสร้างบัญชีการเงินก่อนบันทึกรับเงิน' : 'Please create an account first.')),
      );
      return;
    }

    String selectedAccountId = accounts.first.id;
    DateTime receivedDate = DateTime.now();
    final defaultAmount = (tx.expectedAmountSatang ?? tx.amountThbSatang) / 100.0;
    final amountController = TextEditingController(text: defaultAmount.toStringAsFixed(2));

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.account_balance_wallet, color: VaultTheme.positive(ctx), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isThai ? 'บันทึกรับเงินเข้าบัญชี' : 'Record Deposit',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.note?.isNotEmpty == true ? tx.note! : (isThai ? 'รายได้ค้างรับ' : 'Income'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (tx.workPeriod != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${isThai ? "รอบการทำงาน" : "Period"}: ${_formatWorkPeriod(tx.workPeriod)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                const SizedBox(height: 16),

                // Select Account
                Text(isThai ? 'บัญชีที่เงินเข้า' : 'Target Account', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedAccountId,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: accounts.map((a) {
                    return DropdownMenuItem(
                      value: a.id,
                      child: Text('${a.name} (${a.currencyCode})', style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedAccountId = val);
                  },
                ),
                const SizedBox(height: 12),

                // Actual Amount Received
                Text(isThai ? 'จำนวนเงินที่ได้รับจริง (บาท)' : 'Actual Amount (THB)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixText: '฿ ',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),

                // Received Date
                Text(isThai ? 'วันที่เงินเข้าจริง' : 'Deposit Date', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(DateFormat('dd/MM/yyyy').format(receivedDate), style: const TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: receivedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => receivedDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: VaultTheme.positive(ctx),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final moneyParsed = Money.tryParse(amountController.text);
                final actualSatang = moneyParsed != null ? moneyParsed.satang : tx.amountThbSatang;

                await ref.read(transactionsDaoProvider).markIncomeAsReceived(
                  tx.id,
                  accountId: selectedAccountId,
                  receivedDate: receivedDate,
                  actualAmountSatang: actualSatang,
                );

                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isThai ? 'บันทึกรับเงินเข้าบัญชีเรียบร้อย ยอดเงินสดปรับปรุงแล้ว' : 'Income marked as received!'),
                      backgroundColor: VaultTheme.positive(context),
                    ),
                  );
                }
              },
              child: Text(isThai ? 'ยืนยันรับเงิน' : 'Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog บันทึกรับเงินทั้งรอบเดือน (Batch)
  Future<void> _showBatchReceiveDialog(
    BuildContext context,
    String periodTitle,
    List<Transaction> items,
    bool isThai,
  ) async {
    final accounts = await ref.read(accountsDaoProvider).getActiveAccounts();
    if (!context.mounted) return;

    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isThai ? 'กรุณาสร้างบัญชีการเงินก่อนบันทึกรับเงิน' : 'Please create an account first.')),
      );
      return;
    }

    String selectedAccountId = accounts.first.id;
    DateTime receivedDate = DateTime.now();

    final totalSatang = items.fold<int>(0, (sum, t) => sum + (t.expectedAmountSatang ?? t.amountThbSatang));

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isThai ? 'รับเงินทั้งรอบเดือน' : 'Receive Whole Period',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'รอบ: $periodTitle',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'รวม ${items.length} รายการ: ${Money.fromSatang(totalSatang).format()}',
                style: TextStyle(fontSize: 13, color: VaultTheme.positive(ctx), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              Text(isThai ? 'บัญชีที่เงินเข้า' : 'Target Account', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: selectedAccountId,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: accounts.map((a) {
                  return DropdownMenuItem(
                    value: a.id,
                    child: Text('${a.name} (${a.currencyCode})', style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedAccountId = val);
                },
              ),
              const SizedBox(height: 12),

              Text(isThai ? 'วันที่เงินเข้าจริง' : 'Deposit Date', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(DateFormat('dd/MM/yyyy').format(receivedDate), style: const TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: receivedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setDialogState(() => receivedDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: VaultTheme.positive(ctx),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final txDao = ref.read(transactionsDaoProvider);
                for (final item in items) {
                  await txDao.markIncomeAsReceived(
                    item.id,
                    accountId: selectedAccountId,
                    receivedDate: receivedDate,
                    actualAmountSatang: item.expectedAmountSatang ?? item.amountThbSatang,
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isThai ? 'บันทึกรับเงินทั้งรอบเรียบร้อยแล้ว' : 'All items in period received!'),
                      backgroundColor: VaultTheme.positive(context),
                    ),
                  );
                }
              },
              child: Text(isThai ? 'ยืนยันรับทั้งหมด' : 'Receive All'),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog เพิ่มรายได้ค้างรับด้วยตนเอง
  Future<void> _showAddAccruedIncomeDialog(BuildContext context) async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final categories = await ref.read(categoriesDaoProvider).getActiveCategories('income');
    final accounts = await ref.read(accountsDaoProvider).getActiveAccounts();
    if (!context.mounted) return;

    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final tagController = TextEditingController();
    final now = DateTime.now();
    String period = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    String? selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
    String? selectedAccountId = accounts.isNotEmpty ? accounts.first.id : null;
    String selectedTaxType = '40(1)';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isThai ? 'เพิ่มรายได้ค้างรับ / ค่าเวร' : 'Add Accrued Income',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(isThai ? 'ชื่อรายการ (เช่น ค่าเวร รพ.ศูนย์, เงินหมื่น)' : 'Title', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: isThai ? 'เช่น เวรเหมา 1หมื่น' : 'e.g. On-duty shift',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),

                // Amount
                Text(isThai ? 'จำนวนเงินคาดหวัง (บาท)' : 'Expected Amount (THB)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixText: '฿ ',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),

                // Work Period (YYYY-MM)
                Text(isThai ? 'รอบเดือนทำงาน (YYYY-MM)' : 'Work Period (YYYY-MM)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatWorkPeriod(period),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.edit_calendar, size: 20),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime(
                            int.parse(period.split('-')[0]),
                            int.parse(period.split('-')[1]),
                          ),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            period = '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tax Category
                Text(isThai ? 'ประเภทเงินได้พึงประเมิน' : 'Tax Category', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedTaxType,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: '40(1)', child: Text('40(1) เงินเดือน/พตส./ไม่ทำเวชฯ')),
                    DropdownMenuItem(value: '40(2)', child: Text('40(2) ค่าเวรเหมา/เบี้ยเลี้ยง')),
                    DropdownMenuItem(value: '40(6)', child: Text('40(6) ค่าแพทย์อิสระ / DF')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedTaxType = val);
                  },
                ),
                const SizedBox(height: 12),

                // Category
                if (categories.isNotEmpty) ...[
                  Text(isThai ? 'หมวดหมู่' : 'Category', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategoryId,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: categories.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.nameTh, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCategoryId = val);
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // Tag
                Text(isThai ? 'แท็ก / ป้ายกำกับ' : 'Tag', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: tagController,
                  decoration: InputDecoration(
                    hintText: isThai ? 'เช่น ค่าเวร รพ.ศูนย์, เวรบ่ายดึก' : 'e.g. Hospital shift',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: VaultTheme.accent(ctx),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final moneyParsed = Money.tryParse(amountController.text);
                if (name.isEmpty || moneyParsed == null || moneyParsed.isZero) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(isThai ? 'กรุณากรอกชื่อและจำนวนเงินที่ถูกต้อง' : 'Please enter valid name and amount.')),
                  );
                  return;
                }

                final defaultAccId = selectedAccountId ?? (accounts.isNotEmpty ? accounts.first.id : 'default');
                final txDao = ref.read(transactionsDaoProvider);
                final txId = const Uuid().v4();
                final nowTime = DateTime.now();

                await txDao.insertTransaction(
                  TransactionsCompanion.insert(
                    id: txId,
                    transactionType: 'income',
                    sourceAccountId: drift.Value(defaultAccId),
                    categoryId: drift.Value(selectedCategoryId),
                    amountOriginalSatang: moneyParsed.satang,
                    amountThbSatang: moneyParsed.satang,
                    currencyCode: 'THB',
                    fxRate: const drift.Value('1.0'),
                    feeThbSatang: const drift.Value(0),
                    taxCategory: drift.Value(selectedTaxType),
                    withholdingTaxSatang: const drift.Value(0),
                    transactionDate: nowTime,
                    workPeriod: drift.Value(period),
                    expectedAmountSatang: drift.Value(moneyParsed.satang),
                    isCleared: const drift.Value(false),
                    note: drift.Value(name),
                    tag: drift.Value(tagController.text.trim().isEmpty ? null : tagController.text.trim()),
                    createdAt: nowTime,
                    updatedAt: nowTime,
                  ),
                );

                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isThai ? 'บันทึกรายการค้างรับเรียบร้อย' : 'Accrued income added!'),
                      backgroundColor: VaultTheme.positive(context),
                    ),
                  );
                }
              },
              child: Text(isThai ? 'บันทึก' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
