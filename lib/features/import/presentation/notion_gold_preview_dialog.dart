import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/vault_theme.dart';
import '../domain/notion_gold_import_executor.dart';
import '../domain/notion_gold_parser.dart';

class NotionGoldPreviewDialog extends ConsumerStatefulWidget {
  final String fileName;
  final List<ParsedGoldRow> rows;

  const NotionGoldPreviewDialog({
    super.key,
    required this.fileName,
    required this.rows,
  });

  static Future<NotionGoldImportResult?> show(
    BuildContext context, {
    required String fileName,
    required List<ParsedGoldRow> rows,
  }) {
    return showDialog<NotionGoldImportResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => NotionGoldPreviewDialog(
        fileName: fileName,
        rows: rows,
      ),
    );
  }

  @override
  ConsumerState<NotionGoldPreviewDialog> createState() =>
      _NotionGoldPreviewDialogState();
}

class _NotionGoldPreviewDialogState
    extends ConsumerState<NotionGoldPreviewDialog> {
  late final Set<int> _selectedIndices;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _selectedIndices = widget.rows.map((r) => r.rowIndex).toSet();
  }

  Future<void> _executeImport() async {
    setState(() => _isImporting = true);
    try {
      final db = ref.read(databaseProvider);
      final executor = NotionGoldImportExecutor(db);

      final result = await executor.executeImport(
        widget.rows,
        selectedRowIndices: _selectedIndices,
        fileName: widget.fileName,
      );

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isImporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('การนำเข้าทองคำล้มเหลว: $e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat('#,##0.00');
    final allSelected = widget.rows.isNotEmpty &&
        _selectedIndices.length == widget.rows.length;

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
                  Icon(Icons.savings_outlined, color: VaultTheme.accent(context), size: 22),
                  const SizedBox(width: 8),
                  const Text('ตรวจสอบรายการทองคำ (Gold)'),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'ไฟล์: ${widget.fileName} (ทั้งหมด ${widget.rows.length} รายการ, เลือก ${_selectedIndices.length})',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                onPressed: _isImporting || _selectedIndices.isEmpty
                    ? null
                    : _executeImport,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: Text('ยืนยันนำเข้า (${_selectedIndices.length} รายการ)'),
              ),
            ),
          ],
        ),
        body: _isImporting
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('กำลังนำเข้าทองคำลงพอร์ตโฟลิโอ...'),
                  ],
                ),
              )
            : Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        columns: [
                          DataColumn(
                            label: Row(
                              children: [
                                Checkbox(
                                  value: allSelected,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val ?? false) {
                                        _selectedIndices =
                                            widget.rows.map((r) => r.rowIndex).toSet();
                                      } else {
                                        _selectedIndices.clear();
                                      }
                                    });
                                  },
                                ),
                                const Text('เลือก'),
                              ],
                            ),
                          ),
                          const DataColumn(label: Text('วันที่')),
                          const DataColumn(label: Text('ชื่อสินทรัพย์')),
                          const DataColumn(label: Text('น้ำหนักทอง')),
                          const DataColumn(label: Text('ต้นทุนเฉลี่ย USD')),
                          const DataColumn(label: Text('ลงทุนรวม USD')),
                          const DataColumn(label: Text('USDTHB FX')),
                          const DataColumn(label: Text('ต้นทุนรวม THB')),
                          const DataColumn(label: Text('ราคาตลาด USD')),
                        ],
                        rows: widget.rows.map((row) {
                          final isSelected = _selectedIndices.contains(row.rowIndex);

                          return DataRow(
                            selected: isSelected,
                            onSelectChanged: (selected) {
                              setState(() {
                                if (selected ?? false) {
                                  _selectedIndices.add(row.rowIndex);
                                } else {
                                  _selectedIndices.remove(row.rowIndex);
                                }
                              });
                            },
                            cells: [
                              DataCell(
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val ?? false) {
                                        _selectedIndices.add(row.rowIndex);
                                      } else {
                                        _selectedIndices.remove(row.rowIndex);
                                      }
                                    });
                                  },
                                ),
                              ),
                              DataCell(Text(dateFormat.format(row.recordDate))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: VaultTheme.accent(context)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    row.symbol,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: VaultTheme.accent(context),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(row.quantity.toString())),
                              DataCell(
                                Text(row.unitCostUsd > Decimal.zero
                                    ? '\$${row.unitCostUsd}'
                                    : '-'),
                              ),
                              DataCell(
                                Text(row.amountUsdSatang > 0
                                    ? '\$${currencyFormat.format(row.amountUsdSatang / 100.0)}'
                                    : '-'),
                              ),
                              DataCell(
                                Text(
                                  row.fxRate.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '฿${currencyFormat.format(row.totalCostThbSatang / 100.0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataCell(
                                Text(row.marketPriceUsd > Decimal.zero
                                    ? '\$${row.marketPriceUsd}'
                                    : '-'),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
