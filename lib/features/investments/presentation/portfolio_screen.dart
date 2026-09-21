import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/daos/investments_dao.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/app_theme.dart';
import 'asset_form_dialog.dart';
import 'buy_sell_trade_dialog.dart';
import 'dividend_income_dialog.dart';
import 'monthly_valuation_screen.dart';
import 'lot_inspection_screen.dart';
import '../../settings/presentation/trash_bin_screen.dart';
import '../../../../l10n/app_localizations.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showHoldingOptions(BuildContext context, PortfolioAssetHolding holding) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(holding.asset.symbol.substring(0, 1)),
                ),
                title: Text('${holding.asset.symbol} - ${holding.asset.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('ถืออยู่ ${holding.totalQuantity} หน่วย'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                title: const Text('ซื้อเพิ่ม (Buy)'),
                onTap: () async {
                  Navigator.pop(context);
                  final ok = await BuySellTradeDialog.show(context, initialAsset: holding.asset, initialIsBuy: true);
                  if (ok == true && mounted) setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.sell, color: Colors.green),
                title: const Text('ขายทำกำไร/ตัดขาดทุน (Sell FIFO)'),
                onTap: () async {
                  Navigator.pop(context);
                  final ok = await BuySellTradeDialog.show(context, initialAsset: holding.asset, initialIsBuy: false);
                  if (ok == true && mounted) setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long, color: Colors.purple),
                title: const Text('ตรวจสอบ Lot และประวัติการตัดขาย (FIFO)'),
                onTap: () {
                  Navigator.pop(context);
                  LotInspectionScreen.show(context, holding.asset);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.orange),
                title: const Text('แก้ไขข้อมูลสินทรัพย์'),
                onTap: () async {
                  Navigator.pop(context);
                  final ok = await AssetFormDialog.show(context, assetToEdit: holding.asset);
                  if (ok == true && mounted) setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteAsset(Asset asset) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ลบสินทรัพย์ ${asset.symbol}'),
        content: Text('คุณต้องการลบสินทรัพย์ "${asset.name}" ออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบสินทรัพย์'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(investmentsDaoProvider).softDeleteAsset(asset.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบสินทรัพย์ ${asset.symbol} ย้ายไปถังขยะเรียบร้อยแล้ว'),
            action: SnackBarAction(
              label: 'กู้คืน',
              onPressed: () async {
                await ref.read(investmentsDaoProvider).restoreAsset(asset.id);
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('กู้คืน ${asset.symbol} สำเร็จ')),
                  );
                }
              },
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        setState(() {});
      }
    }
  }

  Future<void> _confirmDeleteTrade(InvestmentTradeRecord trade) async {
    final isBuy = trade.tradeType == 'buy';
    final symbol = trade.asset?.symbol ?? 'สินทรัพย์';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ยืนยันลบรายการ${isBuy ? "ซื้อ" : "ขาย"} $symbol'),
        content: Text(
          isBuy
              ? 'คุณต้องการลบรายการซื้อ $symbol ใช่หรือไม่?\n\nระบบจะยกเลิก Lot นี้ และคำนวณต้นทุน/กำไร FIFO ใหม่ทั้งหมดให้อัตโนมัติ'
              : 'คุณต้องการลบรายการขาย $symbol ใช่หรือไม่?\n\nระบบจะคืนหุ้นกลับเข้าพอร์ต และคำนวณต้นทุน/กำไร FIFO ใหม่ทั้งหมดให้อัตโนมัติ',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบรายการ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(transactionsDaoProvider).softDeleteTransaction(trade.id);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบรายการ${isBuy ? "ซื้อ" : "ขาย"} $symbol เรียบร้อยแล้ว')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final invDao = ref.watch(investmentsDaoProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text((l10n?.portfolio ?? 'PORTFOLIO').toUpperCase()),
        actions: [
          IconButton(
            tooltip: 'อัปเดตราคาตลาดสิ้นเดือน',
            icon: const Icon(Icons.price_change_outlined),
            onPressed: () async {
              final ok = await MonthlyValuationScreen.show(context);
              if (ok == true && mounted) setState(() {});
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'เมนูเพิ่มเติม',
            onSelected: (val) async {
              if (val == 'new_asset') {
                final ok = await AssetFormDialog.show(context);
                if (ok == true && mounted) setState(() {});
              } else if (val == 'income') {
                final ok = await DividendIncomeDialog.show(context);
                if (ok == true && mounted) setState(() {});
              } else if (val == 'trash') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrashBinScreen(initialTab: 1),
                  ),
                );
                if (mounted) setState(() {});
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'new_asset', child: Row(children: [Icon(Icons.add), SizedBox(width: 8), Text('เพิ่มสินทรัพย์ใหม่')])),
              const PopupMenuItem(value: 'income', child: Row(children: [Icon(Icons.attach_money), SizedBox(width: 8), Text('บันทึกเงินปันผล/ดอกเบี้ย')])),
              const PopupMenuItem(value: 'trash', child: Row(children: [Icon(Icons.delete_outline), SizedBox(width: 8), Text('ถังขยะหุ้น (กู้คืนหุ้นที่ลบ)')])),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n?.holdings ?? 'สินทรัพย์ที่ถือครอง', icon: const Icon(Icons.pie_chart)),
            Tab(text: l10n?.realizedPnl ?? 'กำไรที่รับรู้แล้ว', icon: const Icon(Icons.history)),
            Tab(text: l10n?.history ?? 'ประวัติการซื้อ-ขาย', icon: const Icon(Icons.swap_horiz)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.swap_horiz),
        label: Text(Localizations.localeOf(context).languageCode == 'th' ? 'ซื้อ / ขาย' : (l10n?.trade ?? 'Buy / Sell')),
        onPressed: () async {
          final ok = await BuySellTradeDialog.show(context);
          if (ok == true && mounted) setState(() {});
        },
      ),
      body: FutureBuilder<PortfolioSummary>(
        future: invDao.getPortfolioSummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = snapshot.data;
          final holdings = summary?.holdings ?? [];

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Holdings & Portfolio Overview
              _buildHoldingsTab(context, summary, holdings),

              // Tab 2: Realized Gain/Loss Summary
              _buildRealizedGainLossTab(context, invDao),

              // Tab 3: Trade History
              _buildTradeHistoryTab(context, invDao),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHoldingsTab(BuildContext context, PortfolioSummary? summary, List<PortfolioAssetHolding> holdings) {
    final theme = Theme.of(context);

    if (summary == null || (holdings.isEmpty && summary.uninvestedAssets.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('ยังไม่มีสินทรัพย์ในพอร์ตการลงทุน', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('เพิ่มสินทรัพย์และบันทึกซื้อ'),
              onPressed: () async {
                final ok = await AssetFormDialog.show(context);
                if (ok == true && mounted) setState(() {});
              },
            ),
          ],
        ),
      );
    }

    final totalValMoney = Money(summary.totalValueThbSatang);
    final totalCostMoney = Money(summary.totalCostThbSatang);
    final totalPnlMoney = Money(summary.totalUnrealizedGainLossThbSatang);
    final isTotalProfit = summary.totalUnrealizedGainLossThbSatang >= 0;
    final pnlPct = summary.totalCostThbSatang > 0
        ? (summary.totalUnrealizedGainLossThbSatang / summary.totalCostThbSatang) * 100.0
        : 0.0;

    final pricePnlMoney = Money(summary.totalUnrealizedPriceGainLossThbSatang);
    final fxPnlMoney = Money(summary.totalUnrealizedFxGainLossThbSatang);

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Overall Portfolio Summary Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: theme.brightness == Brightness.dark ? const Color(0x3334D399) : const Color(0xFF6EE7B7),
                width: 1,
              ),
            ),
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : const Color(0xFFECFDF5),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'มูลค่าพอร์ตปัจจุบันรวม',
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalValMoney.format(symbol: '฿'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ต้นทุนรวม', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text(totalCostMoney.format(symbol: '฿'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isTotalProfit ? AppTheme.incomeColor(context) : AppTheme.expenseColor(context)).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${isTotalProfit ? '+' : ''}${totalPnlMoney.format(symbol: '฿')} (${isTotalProfit ? '+' : ''}${pnlPct.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isTotalProfit ? AppTheme.incomeColor(context) : AppTheme.expenseColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // 2. Split: Price P&L vs FX P&L
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('กำไรจากราคา (Price P&L)', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                              const SizedBox(height: 2),
                              Text(
                                '${summary.totalUnrealizedPriceGainLossThbSatang >= 0 ? '+' : ''}${pricePnlMoney.format(symbol: '฿')}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: summary.totalUnrealizedPriceGainLossThbSatang >= 0 ? AppTheme.incomeColor(context) : AppTheme.expenseColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('กำไรจากอัตราแลกเปลี่ยน (FX)', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                              const SizedBox(height: 2),
                              Text(
                                '${summary.totalUnrealizedFxGainLossThbSatang >= 0 ? '+' : ''}${fxPnlMoney.format(symbol: '฿')}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: summary.totalUnrealizedFxGainLossThbSatang >= 0 ? AppTheme.incomeColor(context) : AppTheme.expenseColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Quick Action Buttons (เพิ่มสินทรัพย์, อัปเดตราคา, บันทึกปันผล)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('เพิ่มสินทรัพย์', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      final ok = await AssetFormDialog.show(context);
                      if (ok == true && mounted) setState(() {});
                    },
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.price_change_outlined, size: 20),
                    label: const Text('อัปเดตราคาตลาด', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      final ok = await MonthlyValuationScreen.show(context);
                      if (ok == true && mounted) setState(() {});
                    },
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.savings_outlined, size: 20),
                    label: const Text('บันทึกเงินปันผล', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      final ok = await DividendIncomeDialog.show(context);
                      if (ok == true && mounted) setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Asset Allocation Donut Chart
          _buildAllocationChart(context, holdings, summary.totalValueThbSatang),
          const SizedBox(height: 16),

          // 4. Holdings List
          if (holdings.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('รายการสินทรัพย์ที่ถืออยู่ (${holdings.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  'แตะเพื่อจัดการ Lot หรือซื้อขาย',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 36, color: theme.colorScheme.primary),
                      const SizedBox(height: 8),
                      Text('ยังไม่มีรายการที่ถือครองอยู่ในพอร์ต', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text('เลือกกดปุ่ม "ซื้อ" จากรายชื่อสินทรัพย์ด้านล่างเพื่อเริ่มบันทึกการลงทุน', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          ...holdings.map((h) {
            final valMoney = Money(h.currentValueThbSatang);
            final costMoney = Money(h.totalCostThbSatang);
            final pnlMoney = Money(h.totalUnrealizedGainLossThbSatang);
            final isProfit = h.totalUnrealizedGainLossThbSatang >= 0;
            final itemPct = h.totalCostThbSatang > 0
                ? (h.totalUnrealizedGainLossThbSatang / h.totalCostThbSatang) * 100.0
                : 0.0;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      h.asset.symbol.isNotEmpty ? h.asset.symbol.substring(0, 1) : '?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(h.asset.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        h.asset.currencyCode,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.asset.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text('ถือ: ${h.totalQuantity} หน่วย • ทุน: ${costMoney.format(symbol: '฿')}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(valMoney.format(symbol: '฿'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isProfit ? AppTheme.incomeColor(context) : AppTheme.expenseColor(context)).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${isProfit ? '+' : ''}${pnlMoney.format(symbol: '฿')} (${isProfit ? '+' : ''}${itemPct.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isProfit ? AppTheme.incomeColor(context) : AppTheme.expenseColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _showHoldingOptions(context, h),
              ),
            );
          }),

          // 5. Uninvested Assets List (Watchlist / 0 units)
          if (summary.uninvestedAssets.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'สินทรัพย์ที่รอเข้าซื้อ (${summary.uninvestedAssets.length})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'ยังไม่มีรายการซื้อในพอร์ต',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...summary.uninvestedAssets.map((asset) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: Text(
                      asset.symbol.isNotEmpty ? asset.symbol.substring(0, 1) : '?',
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(asset.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(asset.currencyCode, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      ),
                      if (asset.market != null && asset.market!.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(asset.market!, style: TextStyle(fontSize: 10, color: Colors.amber.shade900)),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(asset.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () async {
                          final ok = await BuySellTradeDialog.show(context, initialAsset: asset, initialIsBuy: true);
                          if (ok == true && mounted) setState(() {});
                        },
                        child: const Text('ซื้อ'),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'แก้ไขข้อมูลสินทรัพย์',
                        onPressed: () async {
                          final ok = await AssetFormDialog.show(context, assetToEdit: asset);
                          if (ok == true && mounted) setState(() {});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        tooltip: 'ลบสินทรัพย์',
                        onPressed: () => _confirmDeleteAsset(asset),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildAllocationChart(BuildContext context, List<PortfolioAssetHolding> holdings, int totalValue) {
    if (totalValue <= 0) return const SizedBox.shrink();

    // Group by asset type
    final typeMap = <String, int>{};
    for (final h in holdings) {
      typeMap[h.asset.assetType] = (typeMap[h.asset.assetType] ?? 0) + h.currentValueThbSatang;
    }

    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.amber.shade700,
      Colors.purple.shade600,
      Colors.teal.shade600,
      Colors.orange.shade700,
      Colors.indigo.shade600,
    ];

    final sections = <PieChartSectionData>[];
    int colorIdx = 0;

    typeMap.forEach((type, satang) {
      final pct = (satang / totalValue) * 100.0;
      final c = colors[colorIdx % colors.length];
      colorIdx++;
      sections.add(
        PieChartSectionData(
          color: c,
          value: satang.toDouble(),
          title: '${pct.toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('สัดส่วนตามประเภทสินทรัพย์', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 30,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: typeMap.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Container(width: 10, height: 10, color: colors[typeMap.keys.toList().indexOf(e.key) % colors.length]),
                              const SizedBox(width: 6),
                              Expanded(child: Text(_assetTypeLabel(e.key), style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _assetTypeLabel(String type) {
    switch (type) {
      case 'thai_stock':
        return 'หุ้นไทย';
      case 'foreign_stock':
        return 'หุ้นต่างประเทศ';
      case 'etf':
        return 'ETF';
      case 'mutual_fund':
        return 'กองทุนรวม';
      case 'crypto':
        return 'คริปโต';
      case 'gold':
        return 'ทองคำ';
      case 'bond':
        return 'พันธบัตร/หุ้นกู้';
      default:
        return type;
    }
  }

  Widget _buildRealizedGainLossTab(BuildContext context, InvestmentsDao invDao) {
    return FutureBuilder<List<RealizedGainLossYearSummary>>(
      future: invDao.getRealizedGainLossByYear(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final summaries = snapshot.data ?? [];
        if (summaries.isEmpty) {
          return const Center(
            child: Text('ยังไม่มีประวัติกำไร/ขาดทุนที่รับรู้แล้ว (ยังไม่มีการขายสินทรัพย์)'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: summaries.length,
          itemBuilder: (context, index) {
            final y = summaries[index];
            final netMoney = Money(y.totalRealizedGainLossThbSatang);
            final priceMoney = Money(y.totalPriceGainLossThbSatang);
            final fxMoney = Money(y.totalFxGainLossThbSatang);
            final feeMoney = Money(y.totalFeeThbSatang);
            final costMoney = Money(y.totalCostThbSatang);
            final sellPriceMoney = Money(y.totalSellPriceThbSatang);
            final buyCostMoney = Money(y.totalBuyCostThbSatang);
            final isProfit = y.totalRealizedGainLossThbSatang >= 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0x22FFFFFF)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year & Net P&L Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'ปีภาษี ค.ศ. ${y.year} (พ.ศ. ${y.year + 543})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isProfit ? AppTheme.incomeColor(context) : AppTheme.expenseColor(context)).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isProfit ? '+${netMoney.format(symbol: '฿')}' : netMoney.format(symbol: '฿'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isProfit ? AppTheme.incomeColor(context) : AppTheme.expenseColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Clean 3-Metric Summary Strip
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text('ยอดขายรวม', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 2),
                                Text(sellPriceMoney.format(symbol: '฿'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 26, color: Theme.of(context).colorScheme.outlineVariant),
                          Expanded(
                            child: Column(
                              children: [
                                Text('เงินต้นที่ขาย', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 2),
                                Text(costMoney.format(symbol: '฿'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          if (y.totalBuyCostThbSatang > 0) ...[
                            Container(width: 1, height: 26, color: Theme.of(context).colorScheme.outlineVariant),
                            Expanded(
                              child: Column(
                                children: [
                                  Text('ซื้อเพิ่มปีนี้', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                  const SizedBox(height: 2),
                                  Text(buyCostMoney.format(symbol: '฿'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtle breakdown note
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'กำไรจากราคา: ${priceMoney.format(symbol: '฿')}  •  จาก FX: ${fxMoney.format(symbol: '฿')}${y.totalFeeThbSatang > 0 ? '  •  ค่าธรรมเนียม: ${feeMoney.format(symbol: '฿')}' : ''}',
                        style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),

                    // รายละเอียดหุ้นที่มีการซื้อขายในปีภาษีนี้ (Clean Expandable List)
                    if (y.assetSummaries.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.pie_chart_outline_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            'รายละเอียดหุ้นที่มีการซื้อขาย (${y.assetSummaries.length})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...y.assetSummaries.map((a) {
                        final aCostMoney = Money(a.totalCostThbSatang);
                        final aSellPriceMoney = Money(a.totalSellPriceThbSatang);
                        final aNetMoney = Money(a.realizedGainLossThbSatang);
                        final aPriceMoney = Money(a.priceGainLossThbSatang);
                        final aFxMoney = Money(a.fxGainLossThbSatang);
                        final aBuyCostMoney = Money(a.totalBuyCostThbSatang);
                        final isAssetProfit = a.realizedGainLossThbSatang >= 0;

                        String netQtyStr;
                        if (a.quantityBought > Decimal.zero && a.quantitySold > Decimal.zero) {
                          netQtyStr = 'ซื้อ ${a.quantityBought} | ขาย ${a.quantitySold}';
                        } else if (a.quantitySold > Decimal.zero) {
                          netQtyStr = 'ขาย ${a.quantitySold} หน่วย';
                        } else {
                          netQtyStr = 'ซื้อ ${a.quantityBought} หน่วย';
                        }

                        return Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                              dense: true,
                              title: Row(
                                children: [
                                  Text(a.asset.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    '($netQtyStr)',
                                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              trailing: a.quantitySold > Decimal.zero
                                  ? Text(
                                      '${isAssetProfit ? '+' : ''}${aNetMoney.format(symbol: '฿')}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isAssetProfit ? AppTheme.incomeColor(context) : AppTheme.expenseColor(context),
                                      ),
                                    )
                                  : Text(
                                      'ซื้อเข้า',
                                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    ),
                              children: [
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                if (a.quantitySold > Decimal.zero) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('ยอดขายรวม:', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                      Text(aSellPriceMoney.format(symbol: '฿'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('เงินต้นที่ขาย:', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                      Text(aCostMoney.format(symbol: '฿'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('กำไรราคา: ${aPriceMoney.format(symbol: '฿')} • FX: ${aFxMoney.format(symbol: '฿')}',
                                          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                      if (a.feeThbSatang > 0)
                                        Text('ค่าธรรมเนียม: ${Money(a.feeThbSatang).format(symbol: '฿')}',
                                            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                    ],
                                  ),
                                ],
                                if (a.quantityBought > Decimal.zero) ...[
                                  const SizedBox(height: 3),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('เงินต้นที่ซื้อในปีนี้:', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                      Text(aBuyCostMoney.format(symbol: '฿'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.secondary)),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTradeHistoryTab(BuildContext context, InvestmentsDao invDao) {
    return FutureBuilder<List<InvestmentTradeRecord>>(
      future: invDao.getInvestmentTrades(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final trades = snapshot.data ?? [];
        if (trades.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_horiz, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('ยังไม่มีประวัติการซื้อ-ขายสินทรัพย์', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('บันทึก ซื้อ / ขาย'),
                  onPressed: () async {
                    final ok = await BuySellTradeDialog.show(context);
                    if (ok == true && mounted) setState(() {});
                  },
                ),
              ],
            ),
          );
        }

        final dateFormat = DateFormat('d MMM yyyy, HH:mm', 'th_TH');

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: trades.length,
          itemBuilder: (context, index) {
            final trade = trades[index];
            final isBuy = trade.tradeType == 'buy';
            final symbol = trade.asset?.symbol ?? 'ASSET';
            final totalMoney = Money(trade.totalThbSatang);
            final feeMoney = Money(trade.feeThbSatang);
            final hasRealizedPnl = !isBuy && trade.realizedGainLossThbSatang != null;
            final isRealizedProfit = (trade.realizedGainLossThbSatang ?? 0) >= 0;

            final buyBadgeColor = AppTheme.incomeColor(context);
            final sellBadgeColor = Theme.of(context).colorScheme.tertiary;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0x22FFFFFF)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Type Badge, Symbol, and Net Amount (Single clear display)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (isBuy ? buyBadgeColor : sellBadgeColor).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isBuy ? 'ซื้อ' : 'ขาย',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isBuy ? buyBadgeColor : sellBadgeColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            if (trade.asset?.currencyCode != null && trade.asset!.currencyCode != 'THB') ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  trade.asset!.currencyCode,
                                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isBuy ? '-${totalMoney.format(symbol: '฿')}' : '+${totalMoney.format(symbol: '฿')}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isBuy
                                    ? Theme.of(context).colorScheme.primary
                                    : AppTheme.incomeColor(context),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              tooltip: 'ลบรายการนี้',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _confirmDeleteTrade(trade),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Row 2: Date & Account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateFormat.format(trade.tradeDate),
                          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        if (trade.accountName != null)
                          Text(
                            trade.accountName!,
                            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),

                    // Row 3: Quantity & Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${trade.quantity} หน่วย @ ${Money(trade.priceOriginalSatang).format(symbol: trade.currencyCode == 'THB' ? '฿' : '\$')}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        if (hasRealizedPnl)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isRealizedProfit ? AppTheme.incomeColor(context) : AppTheme.expenseColor(context)).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${isRealizedProfit ? 'กำไร: +' : 'ขาดทุน: '}${Money(trade.realizedGainLossThbSatang!).format(symbol: '฿')}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isRealizedProfit ? AppTheme.incomeColor(context) : AppTheme.expenseColor(context),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Additional Details (FX Rate, Fee, FIFO Lot inspection)
                    if (trade.currencyCode != 'THB' || trade.feeThbSatang > 0 || trade.costThbSatang != null || trade.asset != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (trade.currencyCode != 'THB')
                                Text(
                                  'เรต: ${trade.fxRate}',
                                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              if (trade.currencyCode != 'THB' && trade.feeThbSatang > 0)
                                Text(
                                  '  •  ',
                                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              if (trade.feeThbSatang > 0)
                                Text(
                                  'ค่าธรรมเนียม: ${feeMoney.format(symbol: '฿')}',
                                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                            ],
                          ),
                          if (trade.asset != null)
                            InkWell(
                              onTap: () => LotInspectionScreen.show(context, trade.asset!),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.receipt_long, size: 13, color: Theme.of(context).colorScheme.primary),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Lot FIFO',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
