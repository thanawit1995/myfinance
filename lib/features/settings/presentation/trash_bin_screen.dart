import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/daos/accounts_dao.dart';
import '../../../../core/database/daos/investments_dao.dart';

class TrashBinScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const TrashBinScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  ConsumerState<TrashBinScreen> createState() => _TrashBinScreenState();
}

class _TrashBinScreenState extends ConsumerState<TrashBinScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    // Auto cleanup accounts & assets in trash > 30 days
    _cleanupExpired();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cleanupExpired() async {
    final accDao = ref.read(accountsDaoProvider);
    final invDao = ref.read(investmentsDaoProvider);
    await accDao.cleanupExpiredDeletedAccounts();
    await invDao.cleanupExpiredDeletedAssets();
  }

  Future<void> _confirmRestore(Account account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('กู้คืนบัญชี'),
        content: Text('คุณต้องการกู้คืนบัญชี "${account.name}" พร้อมรายการธุรกรรมทั้งหมดกลับมาใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('กู้คืนบัญชี'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(accountsDaoProvider).restoreAccount(account.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('กู้คืนบัญชี "${account.name}" สำเร็จแล้ว')),
        );
        setState(() {});
      }
    }
  }

  Future<void> _confirmPermanentDelete(Account account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบบัญชีถาวร'),
        content: Text(
          'คำเตือน: การลบบัญชี "${account.name}" ถาวร จะลบข้อมูลบัญชีและรายการธุรกรรมทั้งหมดทิ้งทันที และไม่สามารถกู้คืนได้อีก\n\nคุณแน่ใจหรือไม่?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ลบถาวรทันที'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(accountsDaoProvider).permanentlyDeleteAccount(account.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบบัญชี "${account.name}" ถาวรเรียบร้อยแล้ว')),
        );
        setState(() {});
      }
    }
  }

  Future<void> _confirmRestoreAsset(Asset asset) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('กู้คืนหุ้น / สินทรัพย์'),
        content: Text('คุณต้องการกู้คืนสินทรัพย์ "${asset.symbol} - ${asset.name}" กลับมายังพอร์ตลงทุนใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('กู้คืนสินทรัพย์'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(investmentsDaoProvider).restoreAsset(asset.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('กู้คืนสินทรัพย์ "${asset.symbol}" เรียบร้อยแล้ว')),
        );
        setState(() {});
      }
    }
  }

  Future<void> _confirmPermanentDeleteAsset(Asset asset) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบหุ้น / สินทรัพย์ถาวร'),
        content: Text(
          'คำเตือน: การลบสินทรัพย์ "${asset.symbol} - ${asset.name}" ถาวร จะลบข้อมูลราคาและประวัติ Lot ทั้งหมดทิ้งทันที และไม่สามารถกู้คืนได้อีก\n\nคุณแน่ใจหรือไม่?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ลบถาวรทันที'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(investmentsDaoProvider).permanentlyDeleteAsset(asset.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบสินทรัพย์ "${asset.symbol}" ถาวรเรียบร้อยแล้ว')),
        );
        setState(() {});
      }
    }
  }

  String _formatAssetType(String type) {
    switch (type) {
      case 'thai_stock':
        return 'หุ้นไทย';
      case 'foreign_stock':
      case 'stock_foreign':
        return 'หุ้นต่างประเทศ';
      case 'crypto':
        return 'คริปโต';
      case 'gold':
        return 'ทองคำ';
      case 'mutual_fund':
        return 'กองทุนรวม';
      case 'bond':
        return 'พันธบัตร';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accDao = ref.watch(accountsDaoProvider);
    final invDao = ref.watch(investmentsDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ถังขยะ (กู้คืนข้อมูล)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.account_balance), text: 'บัญชี'),
            Tab(icon: Icon(Icons.pie_chart), text: 'หุ้น / สินทรัพย์'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAccountsTab(accDao),
          _buildAssetsTab(invDao),
        ],
      ),
    );
  }

  Widget _buildAccountsTab(AccountsDao accDao) {
    return FutureBuilder<List<Account>>(
      future: accDao.getDeletedAccounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final deletedAccounts = snapshot.data ?? [];

        if (deletedAccounts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text('ไม่มีบัญชีในถังขยะ', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text('บัญชีที่ถูกลบจะถูกเก็บไว้ที่นี่ 30 วันก่อนลบถาวร', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        final now = DateTime.now();

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: deletedAccounts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final acc = deletedAccounts[index];
            final deletedDate = acc.deletedAt ?? now;
            final daysInTrash = now.difference(deletedDate).inDays;
            final daysRemaining = (30 - daysInTrash).clamp(0, 30);

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.red.shade50,
                              child: Icon(Icons.account_balance, color: Colors.red.shade700),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  acc.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '${acc.currencyCode} · ${acc.accountType}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Text(
                            'เหลือ $daysRemaining วัน',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<int>(
                      future: accDao.countTransactionsForAccount(acc.id),
                      builder: (context, txCountSnap) {
                        final count = txCountSnap.data ?? 0;
                        return Text(
                          'ลบเมื่อ: ${DateFormat('d MMMM yyyy, HH:mm', 'th').format(deletedDate)} (มี $count รายการธุรกรรม)',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade200),
                          ),
                          icon: const Icon(Icons.delete_forever, size: 18),
                          label: const Text('ลบถาวร'),
                          onPressed: () => _confirmPermanentDelete(acc),
                        ),
                        const SizedBox(width: 10),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                          ),
                          icon: const Icon(Icons.restore, size: 18),
                          label: const Text('กู้คืน'),
                          onPressed: () => _confirmRestore(acc),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAssetsTab(InvestmentsDao invDao) {
    return FutureBuilder<List<Asset>>(
      future: invDao.getDeletedAssets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final deletedAssets = snapshot.data ?? [];

        if (deletedAssets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text('ไม่มีหุ้นหรือสินทรัพย์ในถังขยะ', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text('สินทรัพย์ที่ถูกลบจะถูกเก็บไว้ที่นี่ 30 วันก่อนลบถาวร', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        final now = DateTime.now();

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: deletedAssets.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final asset = deletedAssets[index];
            final deletedDate = asset.deletedAt ?? now;
            final daysInTrash = now.difference(deletedDate).inDays;
            final daysRemaining = (30 - daysInTrash).clamp(0, 30);

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.purple.shade50,
                              child: Icon(Icons.show_chart, color: Colors.purple.shade700),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  asset.symbol,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '${asset.name} (${_formatAssetType(asset.assetType)})',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Text(
                            'เหลือ $daysRemaining วัน',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ลบเมื่อ: ${DateFormat('d MMMM yyyy, HH:mm', 'th').format(deletedDate)} · สกุลเงิน: ${asset.currencyCode}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade200),
                          ),
                          icon: const Icon(Icons.delete_forever, size: 18),
                          label: const Text('ลบถาวร'),
                          onPressed: () => _confirmPermanentDeleteAsset(asset),
                        ),
                        const SizedBox(width: 10),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                          ),
                          icon: const Icon(Icons.restore, size: 18),
                          label: const Text('กู้คืน'),
                          onPressed: () => _confirmRestoreAsset(asset),
                        ),
                      ],
                    ),
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
