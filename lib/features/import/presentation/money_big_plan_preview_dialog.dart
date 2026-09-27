import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/vault_theme.dart';
import '../domain/money_big_plan_import_executor.dart';
import '../domain/money_big_plan_parser.dart';

class MoneyBigPlanPreviewDialog extends ConsumerStatefulWidget {
  final String fileName;
  final List<ParsedMoneyBigPlanRow> rows;

  const MoneyBigPlanPreviewDialog({
    super.key,
    required this.fileName,
    required this.rows,
  });

  static Future<MoneyBigPlanImportResult?> show(
    BuildContext context, {
    required String fileName,
    required List<ParsedMoneyBigPlanRow> rows,
  }) {
    return showDialog<MoneyBigPlanImportResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MoneyBigPlanPreviewDialog(
        fileName: fileName,
        rows: rows,
      ),
    );
  }

  @override
  ConsumerState<MoneyBigPlanPreviewDialog> createState() =>
      _MoneyBigPlanPreviewDialogState();
}

class _MoneyBigPlanPreviewDialogState
    extends ConsumerState<MoneyBigPlanPreviewDialog> {
  late final Set<int> _selectedIndices;
  bool _isImporting = false;
  String _typeFilter = 'all'; // 'all', 'income', 'expense', 'transfer'

  @override
  void initState() {
    super.initState();
    _selectedIndices = widget.rows.map((r) => r.rowIndex).toSet();
  }

  Future<void> _executeImport() async {
    setState(() => _isImporting = true);
    try {
      final db = ref.read(databaseProvider);
      final executor = MoneyBigPlanImportExecutor(db);

      final result = await executor.executeImport(
        widget.rows,
        selectedIndices: _selectedIndices,
        fileName: widget.fileName,
      );

      // Invalidate providers so dashboard, accounts, and history refresh immediately
      ref.read(transactionsVersionProvider.notifier).state++;

      if (mounted) {
        Navigator.of(context).pop(result);
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
    final allSelected = widget.rows.isNotEmpty &&
        _selectedIndices.length == widget.rows.length;

    // Filter rows based on segment filter
    final displayedRows = widget.rows.where((r) {
      if (_typeFilter == 'all') return true;
      if (_typeFilter == 'income') return r.transactionType == 'income';
      if (_typeFilter == 'expense') return r.transactionType == 'expense' && r.tag != 'deduction:life_insurance';
      if (_typeFilter == 'insurance') return r.tag == 'deduction:life_insurance';
      return true;
    }).toList();

    // Summary totals of selected rows
    int totalIncomeSatang = 0;
    int totalExpenseSatang = 0;
    int totalInsuranceSatang = 0;
    for (final r in widget.rows) {
      if (!_selectedIndices.contains(r.rowIndex)) continue;
      if (r.tag == 'deduction:life_insurance') {
        totalInsuranceSatang += r.amountSatang;
      } else if (r.transactionType == 'income') {
        totalIncomeSatang += r.amountSatang;
      } else {
        totalExpenseSatang += r.amountSatang;
      }
    }

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
                  Icon(Icons.table_chart_outlined, color: VaultTheme.accent(context), size: 22),
                  const SizedBox(width: 8),
                  const Text('ตรวจสอบข้อมูลสรุปย้อนหลัง (Money BIG PLAN)'),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'ไฟล์: ${widget.fileName} (เลือก ${_selectedIndices.length} จาก ${widget.rows.length} รายการ)',
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
                    Text('กำลังนำเข้าข้อมูลประวัติศาสตร์ลงระบบ...'),
                  ],
                ),
              )
            : Column(
                children: [
                  // Clean Summary Cards Row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        _buildMetricChip(
                          context,
                          label: 'รายรับรวม',
                          amount: Money(totalIncomeSatang).format(symbol: '฿'),
                          color: VaultTheme.positive(context),
                        ),
                        const SizedBox(width: 12),
                        _buildMetricChip(
                          context,
                          label: 'รายจ่ายรวม',
                          amount: Money(totalExpenseSatang).format(symbol: '฿'),
                          color: VaultTheme.negative(context),
                        ),
                        const SizedBox(width: 12),
                        _buildMetricChip(
                          context,
                          label: 'สะสมประกันออมทรัพย์',
                          amount: Money(totalInsuranceSatang).format(symbol: '฿'),
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),

                  // Filter Segment Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'all', label: Text('ทั้งหมด')),
                            ButtonSegment(value: 'income', label: Text('รายรับ')),
                            ButtonSegment(value: 'expense', label: Text('รายจ่าย')),
                            ButtonSegment(value: 'insurance', label: Text('ประกันออมทรัพย์')),
                          ],
                          selected: {_typeFilter},
                          onSelectionChanged: (set) {
                            setState(() => _typeFilter = set.first);
                          },
                        ),
                        const Spacer(),
                        Text(
                          'แสดง ${displayedRows.length} รายการ',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 16),

                  // Table of transactions
                  Expanded(
                    child: Scrollbar(
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
                                const DataColumn(label: Text('รอบเดือน')),
                                const DataColumn(label: Text('วันที่บันทึก')),
                                const DataColumn(label: Text('รายการ')),
                                const DataColumn(label: Text('ประเภท')),
                                const DataColumn(label: Text('หมวดหมู่')),
                                const DataColumn(label: Text('จำนวนเงิน')),
                                const DataColumn(label: Text('เข้า/ตัดบัญชี')),
                              ],
                              rows: displayedRows.map((row) {
                                final isSelected = _selectedIndices.contains(row.rowIndex);
                                final isIncome = row.transactionType == 'income';
                                final isInsurance = row.tag == 'deduction:life_insurance';

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
                                    DataCell(Text(row.workPeriod)),
                                    DataCell(Text(dateFormat.format(row.date))),
                                    DataCell(
                                      Text(
                                        row.originalLabel,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isInsurance
                                              ? Colors.blue.withValues(alpha: 0.15)
                                              : isIncome
                                                  ? VaultTheme.positive(context).withValues(alpha: 0.15)
                                                  : VaultTheme.negative(context).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isInsurance
                                              ? 'ออมประกัน'
                                              : isIncome
                                                  ? 'รายรับ'
                                                  : 'รายจ่าย',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isInsurance
                                                ? Colors.blueAccent
                                                : isIncome
                                                    ? VaultTheme.positive(context)
                                                    : VaultTheme.negative(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(row.categoryName)),
                                    DataCell(
                                      Text(
                                        '${isIncome ? '+' : '-'}฿${Money(row.amountSatang).format(symbol: '')}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isInsurance
                                              ? Colors.blueAccent
                                              : isIncome
                                                  ? VaultTheme.positive(context)
                                                  : VaultTheme.negative(context),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(isInsurance ? 'SCB → ประกันออมทรัพย์' : 'SCB'),
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
                ],
              ),
      ),
    );
  }

  Widget _buildMetricChip(
    BuildContext context, {
    required String label,
    required String amount,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
