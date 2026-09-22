import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/vault_theme.dart';
import '../domain/notion_invest_import_executor.dart';
import '../domain/notion_invest_parser.dart';

/// Summary object returned when user finishes import
class NotionInvestImportSummary {
  final int imported;
  final int skippedDuplicates;
  final int skippedDividends;
  final List<String> errors;

  const NotionInvestImportSummary({
    required this.imported,
    required this.skippedDuplicates,
    required this.skippedDividends,
    required this.errors,
  });
}

class NotionInvestPreviewDialog extends ConsumerStatefulWidget {
  final String fileName;
  final List<ParsedInvestRow> rows;

  const NotionInvestPreviewDialog({
    super.key,
    required this.fileName,
    required this.rows,
  });

  static Future<NotionInvestImportSummary?> show(
    BuildContext context, {
    required String fileName,
    required List<ParsedInvestRow> rows,
  }) {
    return showDialog<NotionInvestImportSummary>(
      context: context,
      barrierDismissible: false,
      builder: (_) => NotionInvestPreviewDialog(
        fileName: fileName,
        rows: rows,
      ),
    );
  }

  @override
  ConsumerState<NotionInvestPreviewDialog> createState() =>
      _NotionInvestPreviewDialogState();
}

class _NotionInvestPreviewDialogState
    extends ConsumerState<NotionInvestPreviewDialog> {
  late final Set<int> _selectedIndices;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    // Select all non-dividend rows by default
    _selectedIndices = widget.rows
        .where((r) => r.paymentType != PaymentType.dividend)
        .map((r) => r.rowIndex)
        .toSet();
  }

  Future<void> _executeImport() async {
    setState(() => _isImporting = true);
    try {
      final db = ref.read(databaseProvider);
      final executor = NotionInvestImportExecutor(db);

      final result = await executor.executeImport(
        widget.rows,
        selectedRowIndices: _selectedIndices,
      );

      if (mounted) {
        Navigator.of(context).pop(NotionInvestImportSummary(
          imported: result.imported,
          skippedDuplicates: result.skippedDuplicates,
          skippedDividends: result.skippedDividends,
          errors: result.errors,
        ));
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

    final dividendCount = widget.rows
        .where((r) => r.paymentType == PaymentType.dividend)
        .length;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: VaultTheme.accent(context)),
              const SizedBox(width: 8),
              const Text('ตรวจสอบรายการซื้อหุ้น'),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'ไฟล์: ${widget.fileName} (ทั้งหมด ${widget.rows.length} รายการ, เลือก ${_selectedIndices.length})',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (dividendCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'ℹ️ มีรายการปันผล $dividendCount รายการ (ข้ามอัตโนมัติ)',
                style: const TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ),
        ],
      ),
      content: SizedBox(
        width: 680,
        height: 420,
        child: _isImporting
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('กำลังนำเข้าข้อมูลหุ้นลงพอร์ต...'),
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
                        DataColumn(label: Text('Ticker')),
                        DataColumn(label: Text('จำนวนหุ้น')),
                        DataColumn(label: Text('ต้นทุน USD')),
                        DataColumn(label: Text('ต้นทุน THB')),
                        DataColumn(label: Text('ประเภทชำระ')),
                      ],
                      rows: widget.rows.map((row) {
                        final isDividend = row.paymentType == PaymentType.dividend;
                        final isSelected = _selectedIndices.contains(row.rowIndex);

                        return DataRow(
                          selected: isSelected,
                          onSelectChanged: isDividend
                              ? null
                              : (selected) {
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
                                onChanged: isDividend
                                    ? null
                                    : (val) {
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
                                  row.ticker,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: VaultTheme.accent(context),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(row.quantity.toString())),
                            DataCell(
                              Text(row.amountUsdSatang > 0
                                  ? '\$${numberFormat.format(row.amountUsdSatang / 100.0)}'
                                  : '-'),
                            ),
                            DataCell(
                              Text('฿${numberFormat.format(row.amountThbSatang / 100.0)}'),
                            ),
                            DataCell(
                              Text(
                                isDividend
                                    ? 'ปันผล (ข้าม)'
                                    : row.paymentType.name.toUpperCase(),
                                style: TextStyle(
                                  color: isDividend ? Colors.grey : null,
                                ),
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
          label: Text('ยืนยันนำเข้า (${_selectedIndices.length} รายการ)'),
        ),
      ],
    );
  }
}
