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
    // Select all rows by default
    _selectedIndices = widget.rows.map((r) => r.rowIndex).toSet();
  }

  Future<void> _executeImport() async {
    setState(() => _isImporting = true);
    try {
      final db = ref.read(databaseProvider);
      final executor = NotionInvestImportExecutor(db);

      final result = await executor.executeImport(
        widget.rows,
        selectedRowIndices: _selectedIndices,
        fileName: widget.fileName,
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
                  Icon(Icons.show_chart, color: VaultTheme.accent(context), size: 22),
                  const SizedBox(width: 8),
                  const Text('ตรวจสอบรายการซื้อหุ้น (US Stocks)'),
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
                    Text('กำลังนำเข้าข้อมูลหุ้นลงพอร์ต...'),
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
                          const DataColumn(label: Text('Ticker')),
                          const DataColumn(label: Text('จำนวนหุ้น')),
                          const DataColumn(label: Text('ต้นทุน USD')),
                          const DataColumn(label: Text('เรต USD/THB')),
                          const DataColumn(label: Text('ต้นทุน THB')),
                          const DataColumn(label: Text('บัญชีที่ตัดเงิน / ชำระ')),
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
                                Text(
                                  row.fxRate.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '฿${numberFormat.format(row.amountThbSatang / 100.0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataCell(
                                Text(
                                  switch (row.paymentType) {
                                    PaymentType.dividend => 'ปันผล (Dime! USD)',
                                    PaymentType.thb => 'THB (Dime! Save)',
                                    PaymentType.fcd => 'FCD (Dime! FCD)',
                                    PaymentType.usd => 'USD (Dime! USD)',
                                  },
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
      ),
    );
  }
}
