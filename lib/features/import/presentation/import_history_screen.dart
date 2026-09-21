import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/vault_theme.dart';

class ImportHistoryScreen extends ConsumerStatefulWidget {
  const ImportHistoryScreen({super.key});

  @override
  ConsumerState<ImportHistoryScreen> createState() => _ImportHistoryScreenState();
}

class _ImportHistoryScreenState extends ConsumerState<ImportHistoryScreen> {
  bool _isLoading = false;

  Future<void> _rollbackBatch(String batchId, String fileName, int count) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันยกเลิกการนำเข้า (Rollback)'),
        content: Text('คุณต้องการลบรายการทั้งหมด ($count รายการ) ที่นำเข้าจากไฟล์ "$fileName" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: VaultTheme.negative(context)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ลบรายการที่นำเข้า'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final deletedCount = await ref.read(importBatchesDaoProvider).rollbackBatch(batchId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ยกเลิกการนำเข้าเรียบร้อยแล้ว (ลบ $deletedCount รายการ)'),
            backgroundColor: VaultTheme.positive(context),
          ),
        );
        setState(() {}); // refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการยกเลิก: $e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'th');

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      appBar: AppBar(
        backgroundColor: VaultTheme.surface(context),
        title: Text(
          'ประวัติการนำเข้าไฟล์ CSV',
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontWeight: FontWeight.bold,
            color: VaultTheme.primaryText(context),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: ref.read(importBatchesDaoProvider).getAllBatches(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final batches = snapshot.data ?? [];
                if (batches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'ยังไม่มีประวัติการนำเข้าไฟล์',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: batches.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final batch = batches[index];
                    final isRolledBack = batch.isRolledBack;

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      color: isRolledBack
                          ? (VaultTheme.isDark(context) ? Colors.white10 : Colors.grey.shade100)
                          : VaultTheme.surface(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isRolledBack ? Icons.undo : Icons.insert_drive_file_outlined,
                                  color: isRolledBack ? Colors.grey : VaultTheme.accent(context),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    batch.fileName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      decoration: isRolledBack ? TextDecoration.lineThrough : null,
                                      color: isRolledBack ? Colors.grey : VaultTheme.primaryText(context),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isRolledBack
                                        ? Colors.grey.withValues(alpha: 0.2)
                                        : VaultTheme.positive(context).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isRolledBack ? 'ยกเลิกแล้ว (Rolled Back)' : 'สำเร็จ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isRolledBack ? Colors.grey : VaultTheme.positive(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'รูปแบบ: ${batch.templateType}',
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                ),
                                const Spacer(),
                                Text(
                                  'นำเข้า: ${batch.totalImported} รายการ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: VaultTheme.primaryText(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'วันที่นำเข้า: ${dateFormat.format(batch.importedAt)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                            if (isRolledBack && batch.rolledBackAt != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'ยกเลิกเมื่อ: ${dateFormat.format(batch.rolledBackAt!)}',
                                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                                ),
                              ),
                            if (!isRolledBack && batch.totalImported > 0) ...[
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.undo, size: 16, color: Colors.redAccent),
                                  label: const Text(
                                    'ยกเลิกการนำเข้าชุดนี้ (Rollback 1 คลิก)',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                  onPressed: () => _rollbackBatch(
                                    batch.id,
                                    batch.fileName,
                                    batch.totalImported,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
