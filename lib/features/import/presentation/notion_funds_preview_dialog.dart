import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/vault_theme.dart';
import '../domain/notion_funds_import_executor.dart';
import '../domain/notion_funds_parser.dart';

class NotionFundsPreviewDialog extends ConsumerStatefulWidget {
  final String fileName;
  final List<ParsedFundRow> rows;

  const NotionFundsPreviewDialog({
    super.key,
    required this.fileName,
    required this.rows,
  });

  static Future<NotionFundsImportResult?> show(
    BuildContext context, {
    required String fileName,
    required List<ParsedFundRow> rows,
  }) {
    return showDialog<NotionFundsImportResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => NotionFundsPreviewDialog(
        fileName: fileName,
        rows: rows,
      ),
    );
  }

  @override
  ConsumerState<NotionFundsPreviewDialog> createState() =>
      _NotionFundsPreviewDialogState();
}

class _NotionFundsPreviewDialogState
    extends ConsumerState<NotionFundsPreviewDialog> {
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
      final executor = NotionFundsImportExecutor(db);

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
            content: Text('การนำเข้ากองทุนล้มเหลว: $e'),
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
                  Icon(Icons.pie_chart_outline, color: VaultTheme.accent(context), size: 22),
                  const SizedBox(width: 8),
                  const Text('ตรวจสอบรายการกองทุนรวม (Mutual Funds)'),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'ไฟล์: ${widget.fileName} (ทั้งหมด ${widget.rows.length} กองทุน, เลือก ${_selectedIndices.length})',
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
                label: Text('ยืนยันนำเข้า (${_selectedIndices.length} กองทุน)'),
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
                    Text('กำลังนำเข้ากองทุนรวมลงพอร์ตโฟลิโอ...'),
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
                          const DataColumn(label: Text('กองทุน / Symbol')),
                          const DataColumn(label: Text('หมวดหมู่')),
                          const DataColumn(label: Text('Platform')),
                          const DataColumn(label: Text('จำนวนหน่วย')),
                          const DataColumn(label: Text('NAV ต้นทุน (฿)')),
                          const DataColumn(label: Text('เงินลงทุนรวม (฿)')),
                          const DataColumn(label: Text('NAV ปัจจุบัน (฿)')),
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
                              DataCell(Text(dateFormat.format(row.buyDate))),
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
                              DataCell(Text(row.subType ?? '-')),
                              DataCell(Text(row.platform)),
                              DataCell(Text(row.quantity.toString())),
                              DataCell(
                                Text(row.unitCostThb.toString()),
                              ),
                              DataCell(
                                Text(
                                  currencyFormat.format(row.totalCostThbSatang / 100.0),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataCell(
                                Text(row.currentNav > Decimal.zero
                                    ? row.currentNav.toString()
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
