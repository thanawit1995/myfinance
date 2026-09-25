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

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline, color: VaultTheme.accent(context)),
              const SizedBox(width: 8),
              const Text('ตรวจสอบรายการกองทุนรวม (Mutual Funds)'),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'ไฟล์: ${widget.fileName} (ทั้งหมด ${widget.rows.length} กองทุน, เลือก ${_selectedIndices.length})',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
      content: SizedBox(
        width: 760,
        height: 440,
        child: _isImporting
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('เลือก')),
                        DataColumn(label: Text('วันที่')),
                        DataColumn(label: Text('กองทุน / Symbol')),
                        DataColumn(label: Text('หมวดหมู่')),
                        DataColumn(label: Text('Platform')),
                        DataColumn(label: Text('จำนวนหน่วย')),
                        DataColumn(label: Text('NAV ต้นทุน (฿)')),
                        DataColumn(label: Text('เงินลงทุนรวม (฿)')),
                        DataColumn(label: Text('NAV ปัจจุบัน (฿)')),
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
                                    horizontal: 6, vertical: 2),
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
                              Text(currencyFormat.format(row.totalCostThbSatang / 100.0)),
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
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: VaultTheme.accent(context),
          ),
          onPressed: _isImporting || _selectedIndices.isEmpty
              ? null
              : _executeImport,
          icon: const Icon(Icons.cloud_upload_outlined),
          label: Text('ยืนยันนำเข้า (${_selectedIndices.length} กองทุน)'),
        ),
      ],
    );
  }
}
