import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/credit_card_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/vault_theme.dart';

class CreditCardSummaryScreen extends ConsumerStatefulWidget {
  final Account account;

  const CreditCardSummaryScreen({super.key, required this.account});

  @override
  ConsumerState<CreditCardSummaryScreen> createState() => _CreditCardSummaryScreenState();
}

class _CreditCardSummaryScreenState extends ConsumerState<CreditCardSummaryScreen> {
  int _selectedCycleIndex = 0; // 0..5 = statementCycles, 6 = All transactions

  @override
  Widget build(BuildContext context) {
    ref.watch(transactionsVersionProvider);
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final ccDao = ref.watch(creditCardDaoProvider);
    final dateFormat = DateFormat('d MMM yyyy');

    final bg = VaultTheme.background(context);
    final surface = VaultTheme.surface(context);
    final surfaceSubtle = VaultTheme.surfaceSubtle(context);
    final border = VaultTheme.border(context);
    final primaryText = VaultTheme.primaryText(context);
    final secondaryText = VaultTheme.secondaryText(context);
    final accent = VaultTheme.accent(context);
    final negative = VaultTheme.negative(context);
    final positive = VaultTheme.positive(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: Text(
          widget.account.name,
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isThai ? 'รีเฟรชยอด' : 'Refresh',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: FutureBuilder<CreditCardSummary?>(
        future: ccDao.getSummary(widget.account.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accent));
          }

          final summary = snapshot.data;
          if (summary == null) {
            return Center(
              child: Text(
                isThai ? 'ไม่พบข้อมูลบัตรเครดิต' : 'Credit card not found',
                style: TextStyle(color: secondaryText),
              ),
            );
          }

          final cycle = summary.cycle;
          final prevStatementMoney = Money(summary.previousStatementDebtSatang);
          final currentCycleMoney = Money(summary.currentCycleDebtSatang);
          final totalDebtMoney = Money(summary.totalDebtSatang);

          final cycles = summary.statementCycles;
          final isViewingAll = _selectedCycleIndex >= cycles.length;
          final selectedCycle = !isViewingAll && _selectedCycleIndex < cycles.length
              ? cycles[_selectedCycleIndex]
              : null;
          final displayedTxs = isViewingAll
              ? summary.allTransactions
              : (selectedCycle?.transactions ?? summary.currentCycleTransactions);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Cycle & Cutoff Banner
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: 0.75),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.credit_card, size: 20, color: accent),
                            const SizedBox(width: 8),
                            Text(
                              isThai ? 'รอบบิลปัจจุบัน' : 'Current Billing Cycle',
                              style: TextStyle(
                                fontFamily: VaultTheme.fontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cycle.daysRemaining == 0
                                ? negative.withValues(alpha: 0.15)
                                : accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: cycle.daysRemaining == 0 ? negative : accent,
                              width: 0.75,
                            ),
                          ),
                          child: Text(
                            cycle.daysRemaining == 0
                                ? (isThai ? 'ตัดรอบวันนี้!' : 'Closes today!')
                                : (isThai
                                    ? 'เหลืออีก ${cycle.daysRemaining} วัน'
                                    : '${cycle.daysRemaining} days left'),
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: cycle.daysRemaining == 0 ? negative : accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${dateFormat.format(cycle.cycleStart)} - ${dateFormat.format(cycle.cycleEnd)}',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isThai
                          ? 'วันครบกำหนดชำระ: วันที่ ${cycle.dueDay} ของเดือนถัดไป'
                          : 'Payment due: day ${cycle.dueDay} of next month',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 12,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Breakdown Cards: Previous Statement vs Current Cycle
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: summary.previousStatementDebtSatang > 0 ? negative.withValues(alpha: 0.5) : border,
                          width: 0.75,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isThai ? 'ยอดรอบที่แล้ว\n(ต้องชำระรอบนี้)' : 'Previous Statement\n(Due this cycle)',
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: summary.previousStatementDebtSatang > 0 ? negative : secondaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            prevStatementMoney.format(symbol: '฿'),
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: summary.previousStatementDebtSatang > 0 ? negative : primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border, width: 0.75),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isThai ? 'ยอดรอบปัจจุบัน\n(กำลังสะสม)' : 'Current Cycle\n(Unbilled)',
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: secondaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentCycleMoney.format(symbol: '฿'),
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Total Debt Card + Pay Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border, width: 0.75),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isThai ? 'หนี้ค้างชำระรวมทั้งหมด' : 'Total Outstanding Balance',
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontSize: 12.5,
                              color: secondaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalDebtMoney.format(symbol: '฿'),
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: summary.totalDebtSatang > 0 ? negative : positive,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: positive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.payments_outlined, size: 18),
                      label: Text(
                        isThai ? 'ชำระหนี้' : 'Pay Card',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: () => _showPaymentSheet(summary, isThai),
                    ),
                  ],
                ),
              ),

              // 3.1 Historical Debt Banner (if any charges exist before 24 Aug 2026)
              FutureBuilder<int>(
                future: ccDao.getHistoricalDebtSatang(widget.account.id),
                builder: (context, histSnapshot) {
                  final histDebt = histSnapshot.data ?? 0;
                  if (histDebt <= 0) return const SizedBox.shrink();
                  final histMoney = Money(histDebt);

                  return Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade900.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.4), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history_rounded, size: 20, color: Colors.amber.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isThai ? 'มียอดค้างชำระในอดีต (ก่อน 24 ส.ค. 69)' : 'Historical balance before 24 Aug 2026',
                                style: TextStyle(
                                  fontFamily: VaultTheme.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isThai
                              ? 'ตรวจพบยอดใช้จ่ายในอดีต ${histMoney.format(symbol: "฿")} จากการนำเข้าข้อมูล หากคุณชำระรอบเก่าไปหมดแล้ว สามารถกดตัดยอดเพื่อให้ยอดหนี้เหลือเฉพาะ 2 รอบล่าสุดได้ทันที'
                              : 'Found ${histMoney.format(symbol: "฿")} from historical imports. If already paid, you can clear it to keep only the 2 recent cycles.',
                          style: TextStyle(
                            fontFamily: VaultTheme.fontFamily,
                            fontSize: 12,
                            color: secondaryText,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.amber.shade800.withValues(alpha: 0.3),
                              foregroundColor: Colors.amber.shade200,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            icon: const Icon(Icons.check_circle_outline, size: 16),
                            label: Text(
                              isThai ? 'ตัดยอดประวัติศาสตร์ (ก่อน 24 ส.ค. 69)' : 'Clear Historical Debt',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            onPressed: () => _handleSettleHistoricalDebt(ccDao, histDebt, isThai),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),


              // 4. Billing Cycle Selector Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isThai ? 'เลือกรอบบิลที่ต้องการดู' : 'Select Statement Cycle',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...List.generate(cycles.length, (idx) {
                      final c = cycles[idx];
                      final isSelected = _selectedCycleIndex == idx;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selectedColor: accent,
                          backgroundColor: surface,
                          side: BorderSide(color: isSelected ? accent : border, width: 0.75),
                          label: Text(
                            c.label,
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : primaryText,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedCycleIndex = idx);
                          },
                        ),
                      );
                    }),
                    ChoiceChip(
                      selectedColor: accent,
                      backgroundColor: surface,
                      side: BorderSide(
                        color: isViewingAll ? accent : border,
                        width: 0.75,
                      ),
                      label: Text(
                        isThai ? 'ทั้งหมด (${summary.allTransactions.length})' : 'All (${summary.allTransactions.length})',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: isViewingAll ? FontWeight.bold : FontWeight.normal,
                          color: isViewingAll ? Colors.white : primaryText,
                        ),
                      ),
                      selected: isViewingAll,
                      onSelected: (val) {
                        if (val) setState(() => _selectedCycleIndex = cycles.length);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 5. Selected Cycle Summary Details
              if (!isViewingAll && selectedCycle != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: surfaceSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: border, width: 0.75),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${dateFormat.format(selectedCycle.cycleStart)} - ${dateFormat.format(selectedCycle.cycleEnd)}',
                        style: TextStyle(fontSize: 12, color: secondaryText),
                      ),
                      Text(
                        '${isThai ? "ยอดใช้จ่าย" : "Charges"}: ฿${(selectedCycle.chargesSatang / 100.0).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // 6. Transactions List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isThai
                        ? 'รายการใช้จ่าย (${displayedTxs.length} รายการ)'
                        : 'Transactions (${displayedTxs.length})',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (displayedTxs.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border, width: 0.75),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 36, color: secondaryText),
                      const SizedBox(height: 8),
                      Text(
                        isThai ? 'ไม่มีรายการในรอบนี้' : 'No transactions in this cycle',
                        style: TextStyle(fontSize: 13, color: secondaryText),
                      ),
                    ],
                  ),
                )
              else
                ...displayedTxs.map((tx) {
                  final isExpense = tx.transactionType == 'expense';
                  final cost = tx.amountThbSatang + tx.feeThbSatang;
                  final money = Money(cost);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border, width: 0.75),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isExpense
                            ? negative.withValues(alpha: 0.12)
                            : positive.withValues(alpha: 0.12),
                        child: Icon(
                          isExpense ? Icons.shopping_bag_outlined : Icons.check_circle_outline,
                          color: isExpense ? negative : positive,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        tx.note?.isNotEmpty == true
                            ? tx.note!
                            : (isExpense
                                ? (isThai ? 'รูดบัตรเครดิต' : 'Credit Card Charge')
                                : (isThai ? 'ชำระหนี้บัตรเครดิต' : 'Payment')),
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: primaryText,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('d MMM yyyy, HH:mm').format(tx.transactionDate),
                        style: TextStyle(fontSize: 12, color: secondaryText),
                      ),
                      trailing: Text(
                        isExpense
                            ? '-${money.format(symbol: '฿')}'
                            : '+${money.format(symbol: '฿')}',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: isExpense ? negative : positive,
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }


  Future<void> _handleSettleHistoricalDebt(CreditCardDao ccDao, int debtSatang, bool isThai) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'ยืนยันตัดยอดประวัติศาสตร์' : 'Confirm Historical Settle'),
        content: Text(
          isThai
              ? 'ระบบจะบันทึกว่ายอดใช้จ่ายบัตรเครดิตก่อนวันที่ 24 ส.ค. 2569 จำนวน ${Money(debtSatang).format(symbol: "฿")} ได้รับการชำระครบแล้ว โดยประวัติรายจ่ายทั้งหมดยังคงอยู่ครบถ้วน\n\nต้องการดำเนินการต่อหรือไม่?'
              : 'The app will mark all credit card charges before 24 Aug 2026 (${Money(debtSatang).format(symbol: "฿")}) as fully settled. All past expense records will be preserved.\n\nProceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isThai ? 'ตัดยอดทันที' : 'Settle Now'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final settled = await ccDao.settleHistoricalDebt(widget.account.id);
      ref.read(transactionsVersionProvider.notifier).state++;
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isThai
                ? 'ตัดยอดประวัติศาสตร์ ${Money(settled).format(symbol: "฿")} สำเร็จ ยอดหนี้คงเหลือเฉพาะ 2 รอบล่าสุดแล้ว'
                : 'Historical debt ${Money(settled).format(symbol: "฿")} settled successfully.',
          ),
          backgroundColor: VaultTheme.positive(context),
        ),
      );
    }
  }


  Future<void> _showPaymentSheet(CreditCardSummary summary, bool isThai) async {

    final accDao = ref.read(accountsDaoProvider);
    final allAccounts = await accDao.getActiveAccounts();
    // Only bank/deposit/cash accounts that are not credit cards
    final bankAccounts = allAccounts.where((a) => a.accountType != 'credit_card').toList();

    if (bankAccounts.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isThai
              ? 'ไม่พบบัญชีเงินฝากสำหรับชำระหนี้ กรุณาเพิ่มบัญชีเงินฝากก่อน'
              : 'No bank account found to make payment'),
        ),
      );
      return;
    }

    String selectedBankId = bankAccounts.first.id;
    // Default to unpaid previous statement if available, else total debt
    final defaultSatang = summary.previousStatementDebtSatang > 0
        ? summary.previousStatementDebtSatang
        : summary.totalDebtSatang;
    final amountController = TextEditingController(
      text: defaultSatang > 0 ? (defaultSatang / 100.0).toStringAsFixed(2) : '',
    );
    DateTime paymentDate = DateTime.now();

    if (!mounted) return;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: VaultTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final primaryText = VaultTheme.primaryText(context);
            final secondaryText = VaultTheme.secondaryText(context);
            final border = VaultTheme.border(context);

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isThai ? 'บันทึกชำระหนี้บัตรเครดิต' : 'Record Credit Card Payment',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // From Bank Account Selector
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: isThai ? 'หักเงินจากบัญชี' : 'Pay from Account',
                      border: const OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    initialValue: selectedBankId,
                    items: bankAccounts.map((a) {
                      return DropdownMenuItem(
                        value: a.id,
                        child: Text(
                          '${a.name} (${a.currencyCode})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setSheetState(() => selectedBankId = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Amount
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      labelText: isThai ? 'จำนวนเงินที่ชำระ (บาท)' : 'Payment Amount (THB)',
                      prefixText: '฿ ',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Date
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: paymentDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2050),
                      );
                      if (picked != null) {
                        setSheetState(() => paymentDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${isThai ? "วันที่ชำระ" : "Payment Date"}: ${DateFormat("d MMM yyyy").format(paymentDate)}',
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontSize: 14,
                              color: primaryText,
                            ),
                          ),
                          Icon(Icons.calendar_today, size: 18, color: secondaryText),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: VaultTheme.positive(context),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final amountDouble = double.tryParse(amountController.text.trim()) ?? 0.0;
                      if (amountDouble <= 0) return;
                      Navigator.of(ctx).pop(true);
                    },
                    child: Text(
                      isThai ? 'ยืนยันบันทึกชำระหนี้' : 'Confirm Payment',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (confirmed == true) {
      final amountDouble = double.tryParse(amountController.text.trim()) ?? 0.0;
      final satang = (amountDouble * 100).round();
      if (satang <= 0) return;

      await ref.read(creditCardDaoProvider).recordCreditCardPayment(
        fromAccountId: selectedBankId,
        creditCardAccountId: widget.account.id,
        amountSatang: satang,
        paymentDate: paymentDate,
      );

      ref.read(transactionsVersionProvider.notifier).state++;

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            backgroundColor: VaultTheme.positive(context),
            content: Text(
              isThai
                  ? 'บันทึกการชำระหนี้บัตร ${widget.account.name} จำนวน ฿${amountDouble.toStringAsFixed(2)} เรียบร้อยแล้ว'
                  : 'Successfully recorded payment of ฿${amountDouble.toStringAsFixed(2)}',
            ),
          ),
        );
      }
    }
  }
}
