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
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'กู้คืนบัญชี' : 'Restore Account'),
        content: Text(isThai
            ? 'คุณต้องการกู้คืนบัญชี "${account.name}" พร้อมรายการธุรกรรมทั้งหมดกลับมาใช่หรือไม่?'
            : 'Restore account "${account.name}" and all associated transactions?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isThai ? 'กู้คืนบัญชี' : 'Restore Account'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(accountsDaoProvider).restoreAccount(account.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isThai ? 'กู้คืนบัญชี "${account.name}" สำเร็จแล้ว' : 'Account "${account.name}" restored successfully')),
        );
        setState(() {});
      }
    }
  }

  Future<void> _confirmPermanentDelete(Account account) async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'ลบบัญชีถาวร' : 'Permanently Delete Account'),
        content: Text(
          isThai
              ? 'คำเตือน: การลบบัญชี "${account.name}" ถาวร จะลบข้อมูลบัญชีและรายการธุรกรรมทั้งหมดทิ้งทันที และไม่สามารถกู้คืนได้อีก\n\nคุณแน่ใจหรือไม่?'
              : 'Warning: Permanently deleting account "${account.name}" will immediately remove all account records and transaction history. This cannot be undone.\n\nAre you sure?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isThai ? 'ลบถาวรทันที' : 'Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(accountsDaoProvider).permanentlyDeleteAccount(account.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isThai ? 'ลบบัญชี "${account.name}" ถาวรเรียบร้อยแล้ว' : 'Account "${account.name}" permanently deleted')),
        );
        setState(() {});
      }
    }
  }

  Future<void> _confirmRestoreAsset(Asset asset) async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'กู้คืนหุ้น / สินทรัพย์' : 'Restore Asset'),
        content: Text(isThai
            ? 'คุณต้องการกู้คืนสินทรัพย์ "${asset.symbol} - ${asset.name}" กลับมายังพอร์ตลงทุนใช่หรือไม่?'
            : 'Restore asset "${asset.symbol} - ${asset.name}" back to investment portfolio?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isThai ? 'กู้คืนสินทรัพย์' : 'Restore Asset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(investmentsDaoProvider).restoreAsset(asset.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isThai ? 'กู้คืนสินทรัพย์ "${asset.symbol}" เรียบร้อยแล้ว' : 'Asset "${asset.symbol}" restored successfully')),
        );
        setState(() {});
      }
    }
  }

  Future<void> _confirmPermanentDeleteAsset(Asset asset) async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'ลบหุ้น / สินทรัพย์ถาวร' : 'Permanently Delete Asset'),
        content: Text(
          isThai
              ? 'คำเตือน: การลบสินทรัพย์ "${asset.symbol} - ${asset.name}" ถาวร จะลบข้อมูลราคาและประวัติ Lot ทั้งหมดทิ้งทันที และไม่สามารถกู้คืนได้อีก\n\nคุณแน่ใจหรือไม่?'
              : 'Warning: Permanently deleting asset "${asset.symbol} - ${asset.name}" will immediately remove all price and lot history. This cannot be undone.\n\nAre you sure?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isThai ? 'ลบถาวรทันที' : 'Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(investmentsDaoProvider).permanentlyDeleteAsset(asset.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isThai ? 'ลบสินทรัพย์ "${asset.symbol}" ถาวรเรียบร้อยแล้ว' : 'Asset "${asset.symbol}" permanently deleted')),
        );
        setState(() {});
      }
    }
  }

  String _formatAssetType(String type, bool isThai) {
    switch (type) {
      case 'thai_stock':
        return isThai ? 'หุ้นไทย' : 'Thai Stock';
      case 'foreign_stock':
      case 'stock_foreign':
        return isThai ? 'หุ้นต่างประเทศ' : 'Foreign Stock';
      case 'crypto':
        return isThai ? 'คริปโต' : 'Crypto';
      case 'gold':
        return isThai ? 'ทองคำ' : 'Gold';
      case 'mutual_fund':
        return isThai ? 'กองทุนรวม' : 'Mutual Fund';
      case 'bond':
        return isThai ? 'พันธบัตร' : 'Bond';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final accDao = ref.watch(accountsDaoProvider);
    final invDao = ref.watch(investmentsDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isThai ? 'ถังขยะ (กู้คืนข้อมูล)' : 'Trash Bin (Restore Data)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.account_balance), text: isThai ? 'บัญชี' : 'Accounts'),
            Tab(icon: const Icon(Icons.pie_chart), text: isThai ? 'หุ้น / สินทรัพย์' : 'Assets'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAccountsTab(accDao, isThai),
          _buildAssetsTab(invDao, isThai),
        ],
      ),
    );
  }

  Widget _buildAccountsTab(AccountsDao accDao, bool isThai) {
    final dateFormat = DateFormat('d MMM yyyy, HH:mm', isThai ? 'th' : 'en_US');

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
                Text(
                  isThai ? 'ไม่มีบัญชีในถังขยะ' : 'No accounts in trash',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  isThai
                      ? 'บัญชีที่ถูกลบจะถูกเก็บไว้ที่นี่ 30 วันก่อนลบถาวร'
                      : 'Deleted accounts are kept here for 30 days before permanent deletion',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
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
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.red.shade50,
                                child: Icon(Icons.account_balance, color: Colors.red.shade700),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      acc.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${acc.currencyCode} · ${acc.accountType}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Text(
                            isThai ? 'เหลือ $daysRemaining วัน' : '$daysRemaining days left',
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
                          isThai
                              ? 'ลบเมื่อ: ${dateFormat.format(deletedDate)} (มี $count รายการธุรกรรม)'
                              : 'Deleted: ${dateFormat.format(deletedDate)} ($count transactions)',
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          icon: const Icon(Icons.delete_forever, size: 16),
                          label: Text(isThai ? 'ลบถาวร' : 'Delete'),
                          onPressed: () => _confirmPermanentDelete(acc),
                        ),
                        const SizedBox(width: 10),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          icon: const Icon(Icons.restore, size: 16),
                          label: Text(isThai ? 'กู้คืน' : 'Restore'),
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

  Widget _buildAssetsTab(InvestmentsDao invDao, bool isThai) {
    final dateFormat = DateFormat('d MMM yyyy, HH:mm', isThai ? 'th' : 'en_US');

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
                Text(
                  isThai ? 'ไม่มีหุ้นหรือสินทรัพย์ในถังขยะ' : 'No assets in trash',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  isThai
                      ? 'สินทรัพย์ที่ถูกลบจะถูกเก็บไว้ที่นี่ 30 วันก่อนลบถาวร'
                      : 'Deleted assets are kept here for 30 days before permanent deletion',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
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
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.purple.shade50,
                                child: Icon(Icons.show_chart, color: Colors.purple.shade700),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      asset.symbol,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${asset.name} (${_formatAssetType(asset.assetType, isThai)})',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Text(
                            isThai ? 'เหลือ $daysRemaining วัน' : '$daysRemaining days left',
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
                      isThai
                          ? 'ลบเมื่อ: ${dateFormat.format(deletedDate)} · สกุลเงิน: ${asset.currencyCode}'
                          : 'Deleted: ${dateFormat.format(deletedDate)} · Currency: ${asset.currencyCode}',
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          icon: const Icon(Icons.delete_forever, size: 16),
                          label: Text(isThai ? 'ลบถาวร' : 'Delete'),
                          onPressed: () => _confirmPermanentDeleteAsset(asset),
                        ),
                        const SizedBox(width: 10),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          icon: const Icon(Icons.restore, size: 16),
                          label: Text(isThai ? 'กู้คืน' : 'Restore'),
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
