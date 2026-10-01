import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/vault_theme.dart';
import '../domain/dividend_excel_import_executor.dart';
import '../domain/dividend_excel_parser.dart';
import 'import_history_screen.dart';

class DividendExcelImportSummary {
  final int imported;
  final String batchId;
  final int totalGrossSatangUsd;
  final int totalTaxSatangUsd;
  final int totalNetThbSatang;

  const DividendExcelImportSummary({
    required this.imported,
    required this.batchId,
    required this.totalGrossSatangUsd,
    required this.totalTaxSatangUsd,
    required this.totalNetThbSatang,
  });

  int get skippedDuplicates => 0;
  List<String> get errors => const [];
}

class DividendExcelPreviewDialog extends ConsumerStatefulWidget {
  final String fileName;
  final List<ParsedDividendExcelRow> rows;

  const DividendExcelPreviewDialog({
    super.key,
    required this.fileName,
    required this.rows,
  });

  static Future<DividendExcelImportSummary?> show(
    BuildContext context, {
    required String fileName,
    required List<ParsedDividendExcelRow> rows,
  }) {
    return showDialog<DividendExcelImportSummary>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DividendExcelPreviewDialog(
        fileName: fileName,
        rows: rows,
      ),
    );
  }

  @override
  ConsumerState<DividendExcelPreviewDialog> createState() =>
      _DividendExcelPreviewDialogState();
}

class _DividendExcelPreviewDialogState
    extends ConsumerState<DividendExcelPreviewDialog> {
  late final Set<int> _selectedIndices;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _selectedIndices = widget.rows.map((r) => r.rowIndex).toSet();
  }

  Future<void> _executeImport() async {
    if (_selectedIndices.isEmpty) return;

    setState(() => _isImporting = true);
    try {
      final db = ref.read(databaseProvider);
      final executor = DividendExcelImportExecutor(db);

      final selectedRows = widget.rows
          .where((r) => _selectedIndices.contains(r.rowIndex))
          .toList();

      final result = await executor.executeImport(
        rows: selectedRows,
        fileName: widget.fileName,
      );

      // Trigger stream/version updates across the app
      ref.read(transactionsVersionProvider.notifier).state++;

      if (mounted) {
        Navigator.of(context).pop(DividendExcelImportSummary(
          imported: result.insertedCount,
          batchId: result.batchId,
          totalGrossSatangUsd: result.totalGrossSatangUsd,
          totalTaxSatangUsd: result.totalTaxSatangUsd,
          totalNetThbSatang: result.totalNetThbSatang,
        ));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('นำเข้าเงินปันผลสำเร็จ ${result.insertedCount} รายการ เข้าบัญชี Dime! USD'),
            backgroundColor: VaultTheme.positive(context),
            action: SnackBarAction(
              label: 'ดูประวัติ/ย้อนกลับ',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ImportHistoryScreen()),
                );
              },
            ),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isImporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('การนำเข้าล้มเหลว: $e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final numberFormat = NumberFormat('#,##0.00');
    final allSelected = widget.rows.isNotEmpty &&
        _selectedIndices.length == widget.rows.length;

    // Calculate totals for selected items
    double selectedGrossUsd = 0;
    double selectedTaxUsd = 0;
    double selectedNetUsd = 0;
    int selectedNetThbSatang = 0;

    for (final r in widget.rows) {
      if (_selectedIndices.contains(r.rowIndex)) {
        selectedGrossUsd += r.grossUsd;
        selectedTaxUsd += r.taxUsd;
        selectedNetUsd += r.netUsd;
        selectedNetThbSatang += r.netThbSatang;
      }
    }

    final theme = Theme.of(context);

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'ปิด',
            onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.payments_outlined, color: VaultTheme.accent(context), size: 22),
                  const SizedBox(width: 8),
                  const Text('ตรวจสอบเงินปันผลหุ้นต่างประเทศ (ปันผล.xlsx)'),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'ไฟล์: ${widget.fileName} (ทั้งหมด ${widget.rows.length} รายการ, เลือก ${_selectedIndices.length})',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: VaultTheme.accent(context),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                icon: _isImporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.file_download_done, size: 20),
                label: Text(
                  _isImporting
                      ? 'กำลังนำเข้า...'
                      : 'ยืนยันนำเข้า (${_selectedIndices.length} รายการ)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: (_isImporting || _selectedIndices.isEmpty)
                    ? null
                    : _executeImport,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Top Summary Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: VaultTheme.surface(context),
                border: Border(bottom: BorderSide(color: VaultTheme.border(context), width: 0.75)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Select All Checkbox
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: allSelected
                                ? true
                                : (_selectedIndices.isNotEmpty ? null : false),
                            tristate: true,
                            onChanged: (val) {
                              setState(() {
                                if (allSelected) {
                                  _selectedIndices.clear();
                                } else {
                                  _selectedIndices.addAll(widget.rows.map((r) => r.rowIndex));
                                }
                              });
                            },
                          ),
                          Text(
                            allSelected ? 'ยกเลิกเลือกทั้งหมด' : 'เลือกทั้งหมด (${widget.rows.length})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'ปลายทาง: Dime! USD (หมวด: ดอกเบี้ยและเงินปันผล)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: VaultTheme.accent(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Summary Badges
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildSummaryBadge(
                        context,
                        label: 'ปันผลรวม (USD)',
                        value: '\$${numberFormat.format(selectedGrossUsd)}',
                        color: Colors.blue,
                      ),
                      _buildSummaryBadge(
                        context,
                        label: 'หักภาษี 15% (USD)',
                        value: '\$${numberFormat.format(selectedTaxUsd)}',
                        color: Colors.orange,
                      ),
                      _buildSummaryBadge(
                        context,
                        label: 'สุทธิเข้า Dime! (USD)',
                        value: '\$${numberFormat.format(selectedNetUsd)}',
                        color: Colors.green,
                      ),
                      _buildSummaryBadge(
                        context,
                        label: 'มูลค่าสุทธิ (THB)',
                        value: '฿${numberFormat.format(selectedNetThbSatang / 100.0)}',
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Rows List
            Expanded(
              child: ListView.separated(
                itemCount: widget.rows.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: VaultTheme.border(context)),
                itemBuilder: (context, index) {
                  final row = widget.rows[index];
                  final isSelected = _selectedIndices.contains(row.rowIndex);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedIndices.add(row.rowIndex);
                          } else {
                            _selectedIndices.remove(row.rowIndex);
                          }
                        });
                      },
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: row.isTaxExemptRefund
                                ? Colors.purple.withValues(alpha: 0.15)
                                : VaultTheme.accent(context).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            row.symbol,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: row.isTaxExemptRefund
                                  ? Colors.purple
                                  : VaultTheme.accent(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          dateFormat.format(row.date),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                        const Spacer(),
                        Text(
                          '+\$${numberFormat.format(row.netUsd)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: VaultTheme.positive(context),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gross: \$${numberFormat.format(row.grossUsd)}  •  ภาษี: \$${numberFormat.format(row.taxUsd)}  •  เรต: ${row.fxRate}',
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                          ),
                          Text(
                            '≈ ฿${numberFormat.format(row.netThbSatang / 100.0)}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIndices.remove(row.rowIndex);
                        } else {
                          _selectedIndices.add(row.rowIndex);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBadge(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
