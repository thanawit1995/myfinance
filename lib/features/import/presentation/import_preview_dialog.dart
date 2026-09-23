import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/vault_theme.dart';
import '../domain/csv_import_models.dart';
import '../import_provider.dart';

class ImportPreviewDialog extends ConsumerStatefulWidget {
  final String fileName;
  final String templateType;
  final List<ParsedCsvRow> rows;

  const ImportPreviewDialog({
    super.key,
    required this.fileName,
    required this.templateType,
    required this.rows,
  });

  static Future<CsvImportBatchResult?> show(
    BuildContext context, {
    required String fileName,
    required String templateType,
    required List<ParsedCsvRow> rows,
  }) {
    return showDialog<CsvImportBatchResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ImportPreviewDialog(
        fileName: fileName,
        templateType: templateType,
        rows: rows,
      ),
    );
  }

  @override
  ConsumerState<ImportPreviewDialog> createState() => _ImportPreviewDialogState();
}

class _ImportPreviewDialogState extends ConsumerState<ImportPreviewDialog> {
  String? _selectedAccountId;
  bool _skipDuplicates = true;
  bool _autoCreateCategories = true;
  final bool _autoCreateAccounts = true;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultAccount();
  }

  Future<void> _loadDefaultAccount() async {
    final accounts = await ref.read(accountsDaoProvider).getActiveAccounts();
    if (accounts.isNotEmpty && mounted) {
      setState(() {
        _selectedAccountId = accounts.first.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0.00', 'th');
    final dateFormat = DateFormat('dd/MM/yyyy');

    final validCount = widget.rows.where((r) => r.isValid && !r.isDuplicate).length;
    final dupCount = widget.rows.where((r) => r.isDuplicate).length;
    final summaryCount = widget.rows.where((r) => r.isSummaryRow).length;
    final errorCount = widget.rows.where((r) => !r.isValid && !r.isSummaryRow).length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 640,
        padding: const EdgeInsets.all(20),
        child: _isImporting
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('กำลังนำเข้าข้อมูลลงสู่ฐานข้อมูล...'),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & File info
                  Row(
                    children: [
                      Icon(Icons.table_view_outlined, color: VaultTheme.accent(context), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ตรวจสอบข้อมูลก่อนนำเข้า (Preview)',
                              style: TextStyle(
                                fontFamily: VaultTheme.fontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: VaultTheme.primaryText(context),
                              ),
                            ),
                            Text(
                              'ไฟล์: ${widget.fileName} (ทั้งหมด ${widget.rows.length} แถว)',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Summary Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBadge('พร้อมนำเข้า: $validCount', VaultTheme.positive(context)),
                      if (widget.rows.any((r) => !r.isCleared))
                        _buildBadge(
                          'ค้างรับ/ตกเบิก: ${widget.rows.where((r) => !r.isCleared && r.isValid && !r.isSummaryRow).length}',
                          Colors.amber.shade800,
                        ),
                      if (dupCount > 0) _buildBadge('พบซ้ำในระบบ: $dupCount', Colors.orange),
                      if (summaryCount > 0) _buildBadge('แถวสรุปยอด (ข้าม): $summaryCount', Colors.grey),
                      if (errorCount > 0) _buildBadge('ข้อมูลผิดพลาด: $errorCount', Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Destination Account Dropdown & Settings
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: VaultTheme.surface(context),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_balance_wallet_outlined, size: 20),
                              const SizedBox(width: 8),
                              const Text('บัญชีปลายทางหลัก (Default Account):', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FutureBuilder(
                                  future: ref.read(accountsDaoProvider).getActiveAccounts(),
                                  builder: (context, snapshot) {
                                    final accounts = snapshot.data ?? [];
                                    return DropdownButton<String>(
                                      isExpanded: true,
                                      value: _selectedAccountId,
                                      underline: const SizedBox.shrink(),
                                      items: accounts.map((a) {
                                        return DropdownMenuItem(
                                          value: a.id,
                                          child: Text('${a.name} (${a.currencyCode})'),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setState(() => _selectedAccountId = val),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  title: const Text('ข้ามรายการที่ซ้ำกับในระบบ', style: TextStyle(fontSize: 13)),
                                  value: _skipDuplicates,
                                  onChanged: (val) => setState(() => _skipDuplicates = val ?? true),
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  title: const Text('สร้างหมวดหมู่ใหม่ที่ยังไม่มีให้อัตโนมัติ', style: TextStyle(fontSize: 13)),
                                  value: _autoCreateCategories,
                                  onChanged: (val) => setState(() => _autoCreateCategories = val ?? true),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'ตัวอย่าง 20 แถวแรกจากไฟล์:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 6),

                  // Table Preview
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 38,
                            dataRowMinHeight: 36,
                            dataRowMaxHeight: 44,
                            columns: [
                              const DataColumn(label: Text('สถานะ', style: TextStyle(fontWeight: FontWeight.bold))),
                              const DataColumn(label: Text('วันที่', style: TextStyle(fontWeight: FontWeight.bold))),
                              if (widget.rows.any((r) => r.workPeriod != null && r.workPeriod!.isNotEmpty))
                                const DataColumn(label: Text('รอบเดือน', style: TextStyle(fontWeight: FontWeight.bold))),
                              const DataColumn(label: Text('รายการ', style: TextStyle(fontWeight: FontWeight.bold))),
                              const DataColumn(label: Text('หมวดหมู่', style: TextStyle(fontWeight: FontWeight.bold))),
                              const DataColumn(label: Text('บัญชี', style: TextStyle(fontWeight: FontWeight.bold))),
                              const DataColumn(label: Text('จำนวนเงิน', style: TextStyle(fontWeight: FontWeight.bold))),
                              const DataColumn(label: Text('ภาษี/WHT', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: widget.rows.take(20).map((row) {
                              Widget statusBadge;
                              if (row.isSummaryRow) {
                                statusBadge = _buildSmallBadge('สรุปยอด (ข้าม)', Colors.grey);
                              } else if (!row.isValid) {
                                statusBadge = _buildSmallBadge(row.validationError ?? 'ผิดพลาด', Colors.redAccent);
                              } else if (!row.isCleared) {
                                statusBadge = _buildSmallBadge('ค้างรับ/ตกเบิก', Colors.amber.shade800);
                              } else if (row.isDuplicate) {
                                statusBadge = _buildSmallBadge('ซ้ำในระบบ', Colors.orange);
                              } else {
                                statusBadge = _buildSmallBadge('ปกติ', Colors.green);
                              }

                              final dateText = row.date != null ? dateFormat.format(row.date!) : row.rawDateString;
                              final displaySatang = (!row.isCleared && row.expectedAmountSatang != null && row.expectedAmountSatang! > 0)
                                  ? row.expectedAmountSatang!
                                  : row.amountSatang;
                              final amountText = '฿${currencyFormat.format(displaySatang / 100.0)}';

                              return DataRow(
                                color: WidgetStateProperty.resolveWith<Color?>((states) {
                                  if (row.isSummaryRow) return Colors.grey.withValues(alpha: 0.08);
                                  if (row.isDuplicate) return Colors.orange.withValues(alpha: 0.08);
                                  if (!row.isValid) return Colors.red.withValues(alpha: 0.08);
                                  if (!row.isCleared) return Colors.amber.withValues(alpha: 0.08);
                                  return null;
                                }),
                                cells: [
                                  DataCell(statusBadge),
                                  DataCell(Text(dateText, style: const TextStyle(fontSize: 12))),
                                  if (widget.rows.any((r) => r.workPeriod != null && r.workPeriod!.isNotEmpty))
                                    DataCell(Text(row.workPeriod ?? '-', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                                  DataCell(
                                    Text(
                                      row.name,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DataCell(Text(row.categoryName, style: const TextStyle(fontSize: 12))),
                                  DataCell(Text(row.accountName ?? '-', style: const TextStyle(fontSize: 12))),
                                  DataCell(
                                    Text(
                                      !row.isCleared ? '$amountText (รอรับ)' : amountText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: !row.isCleared
                                            ? Colors.amber.shade900
                                            : (row.transactionType == 'income'
                                                ? VaultTheme.positive(context)
                                                : VaultTheme.primaryText(context)),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      row.taxCategory != null
                                          ? '${row.taxCategory}${row.withholdingTaxSatang > 0 ? " (WHT: ฿${(row.withholdingTaxSatang / 100).toStringAsFixed(0)})" : ""}'
                                          : '-',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('ยกเลิก'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: VaultTheme.accent(context),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: Text('ยืนยันนำเข้า ($validCount รายการ)'),
                        onPressed: (_selectedAccountId == null || validCount == 0)
                            ? null
                            : () async {
                                final nav = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                final negativeColor = VaultTheme.negative(context);

                                setState(() => _isImporting = true);
                                try {
                                  final executor = ref.read(importExecutorProvider);
                                  final res = await executor.executeImport(
                                    fileName: widget.fileName,
                                    templateType: widget.templateType,
                                    rows: widget.rows,
                                    defaultAccountId: _selectedAccountId!,
                                    skipDuplicates: _skipDuplicates,
                                    autoCreateMissingCategories: _autoCreateCategories,
                                    autoCreateMissingAccounts: _autoCreateAccounts,
                                  );
                                  if (mounted) {
                                    nav.pop(res);
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() => _isImporting = false);
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text('เกิดข้อผิดพลาดในการนำเข้า: $e'),
                                        backgroundColor: negativeColor,
                                      ),
                                    );
                                  }
                                }
                              },
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
