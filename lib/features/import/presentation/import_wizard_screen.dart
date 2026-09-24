import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/vault_theme.dart';
import '../domain/csv_import_models.dart';
import '../domain/csv_import_parser.dart';
import '../domain/notion_invest_parser.dart';
import '../import_provider.dart';
import 'column_mapping_dialog.dart';
import 'import_history_screen.dart';
import 'import_preview_dialog.dart';
import 'notion_invest_preview_dialog.dart';


class ImportWizardScreen extends ConsumerStatefulWidget {
  const ImportWizardScreen({super.key});

  @override
  ConsumerState<ImportWizardScreen> createState() => _ImportWizardScreenState();
}

class _ImportWizardScreenState extends ConsumerState<ImportWizardScreen> {
  String _selectedTemplate = 'notion_expense'; // 'notion_expense', 'notion_income', 'notion_invest_stocks', 'custom'
  String? _pickedFileName;
  List<List<dynamic>> _rawCsvRows = [];
  CsvColumnMapping? _currentMapping;
  bool _isProcessing = false;

  Future<void> _pickCsvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        String content = '';
        if (file.bytes != null) {
          // Decode with UTF-8, fallback to Latin1
          try {
            content = utf8.decode(file.bytes!);
          } catch (_) {
            content = latin1.decode(file.bytes!);
          }
        }

        if (content.isNotEmpty) {
          final rows = CsvImportParser.parseRawCsv(content);
          if (rows.isNotEmpty) {
            final headers = rows.first.map((e) => e.toString()).toList();
            var detectedTemplate = _selectedTemplate;
            if (headers.any((h) => h.trim().toLowerCase() == 'bill')) {
              detectedTemplate = 'notion_bills';
            }
            final mapping = CsvImportParser.detectMapping(headers, template: detectedTemplate);

            setState(() {
              _selectedTemplate = detectedTemplate;
              _pickedFileName = file.name;
              _rawCsvRows = rows;
              _currentMapping = mapping;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถเปิดไฟล์ CSV ได้: $e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    }
  }

  Future<void> _adjustMapping() async {
    if (_rawCsvRows.isEmpty || _currentMapping == null) return;
    final headers = _rawCsvRows.first.map((e) => e.toString()).toList();

    final newMapping = await ColumnMappingDialog.show(
      context,
      headers: headers,
      currentMapping: _currentMapping!,
    );

    if (newMapping != null && mounted) {
      setState(() {
        _currentMapping = newMapping;
      });
    }
  }

  Future<void> _proceedToPreview() async {
    // ─── Invest-Stocks path ─────────────────────────────────────────────────
    if (_selectedTemplate == 'notion_invest_stocks') {
      await _proceedToInvestPreview();
      return;
    }

    // ─── Standard expense / income / custom path ────────────────────────────
    if (_rawCsvRows.isEmpty || _currentMapping == null) return;

    setState(() => _isProcessing = true);
    try {
      // 1. Parse rows with current mapping
      final parsed = CsvImportParser.parseRows(
        rawRows: _rawCsvRows,
        mapping: _currentMapping!,
        templateType: _selectedTemplate,
        hasHeader: true,
      );

      // 2. Check for duplicate transactions in SQLite
      final executor = ref.read(importExecutorProvider);
      final checkedRows = await executor.checkDuplicates(parsed);

      if (!mounted) return;
      setState(() => _isProcessing = false);

      // 3. Open Preview Dialog
      final result = await ImportPreviewDialog.show(
        context,
        fileName: _pickedFileName ?? 'notion_export.csv',
        templateType: _selectedTemplate,
        rows: checkedRows,
      );

      if (result != null && mounted) {
        _showSuccessDialog(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการประมวลผล: $e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    }
  }

  /// Handles the invest-stocks import preview flow.
  Future<void> _proceedToInvestPreview() async {
    if (_rawCsvRows.isEmpty) return;

    setState(() => _isProcessing = true);
    try {
      final rows = NotionInvestParser.parseRows(_rawCsvRows);

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (rows.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('ไม่พบข้อมูลหุ้นในไฟล์ CSV นี้'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
        return;
      }

      final result = await NotionInvestPreviewDialog.show(
        context,
        fileName: _pickedFileName ?? 'invest_stocks.csv',
        rows: rows,
      );

      if (result != null && mounted) {
        _showInvestSuccessDialog(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการอ่านไฟล์หุ้น: $e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    }
  }

  void _showInvestSuccessDialog(NotionInvestImportSummary result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: VaultTheme.positive(context)),
            const SizedBox(width: 8),
            const Text('นำเข้าหุ้นสำเร็จ!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• นำเข้าสำเร็จ: ${result.imported} lot'),
            if (result.skippedDuplicates > 0)
              Text('• ข้าม lot ซ้ำ: ${result.skippedDuplicates}',
                  style: const TextStyle(color: Colors.orange)),
            if (result.skippedDividends > 0)
              Text('• ข้ามปันผล (ยังไม่รองรับ): ${result.skippedDividends}',
                  style: const TextStyle(color: Colors.grey)),
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('⚠️ มีข้อผิดพลาด:', style: TextStyle(color: Colors.red)),
              ...result.errors.map((e) => Text('  • $e', style: const TextStyle(fontSize: 12))),
            ],
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: VaultTheme.accent(context)),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _pickedFileName = null;
                _rawCsvRows = [];
                _currentMapping = null;
              });
            },
            child: const Text('เสร็จสิ้น'),
          ),
        ],
      ),
    );
  }


  void _showSuccessDialog(CsvImportBatchResult result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: VaultTheme.positive(context)),
            const SizedBox(width: 8),
            const Text('นำเข้าข้อมูลสำเร็จ!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• นำเข้าสำเร็จ: ${result.importedCount} รายการ'),
            if (result.duplicateCount > 0)
              Text('• ข้ามรายการซ้ำ: ${result.duplicateCount} รายการ', style: const TextStyle(color: Colors.orange)),
            if (result.skippedCount > 0)
              Text('• ข้ามแถวสรุปยอด: ${result.skippedCount} แถว', style: const TextStyle(color: Colors.grey)),
            if (result.createdCategories.isNotEmpty)
              Text('• สร้างหมวดหมู่ใหม่: ${result.createdCategories.join(", ")}'),
            if (result.createdAccounts.isNotEmpty)
              Text('• สร้างบัญชีใหม่: ${result.createdAccounts.join(", ")}'),
            const SizedBox(height: 12),
            const Text(
              'หมายเหตุ: หากพบข้อผิดพลาด คุณสามารถกดปุ่ม "ยกเลิกการนำเข้า (Rollback)" ได้ทุกเมื่อในหน้าประวัติ',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _pickedFileName = null;
                _rawCsvRows = [];
                _currentMapping = null;
              });
            },
            child: const Text('เสร็จสิ้น'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: VaultTheme.accent(context)),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ImportHistoryScreen()),
              );
            },
            child: const Text('ดูประวัติการนำเข้า'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = VaultTheme.isDark(context);

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      appBar: AppBar(
        backgroundColor: VaultTheme.surface(context),
        title: Text(
          'นำเข้าข้อมูลจาก Notion CSV',
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontWeight: FontWeight.bold,
            color: VaultTheme.primaryText(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'ประวัติการนำเข้า',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ImportHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header description
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  color: VaultTheme.surface(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_awesome, color: VaultTheme.accent(context), size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notion Personal Wealth Tracker Import Wizard',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: VaultTheme.primaryText(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'นำเข้าไฟล์ CSV ที่ Export มาจาก Notion โดยตรง ระบบจะตัดข้อความ Relation ลิงก์ให้อัตโนมัติ, ข้ามแถวสรุปยอดรวมประจำเดือน, ตรวจสอบรายการซ้ำ และจัดหมวดหมู่ภาษีการแพทย์ 40(1)/40(2) ให้อัตโนมัติ พร้อมระบบ Rollback 1 คลิก',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Step 1: Select Template
                const Text(
                  'ขั้นตอนที่ 1: เลือกรูปแบบข้อมูล',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildTemplateOption(
                        id: 'notion_expense',
                        title: 'Notion รายจ่าย',
                        subtitle: 'ตัด _OCT23, ละเว้นยอดรวม',
                        icon: Icons.shopping_bag_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTemplateOption(
                        id: 'notion_income',
                        title: 'Notion รายรับการแพทย์',
                        subtitle: 'สธ. 40(1)/40(2)/Top up/P4P',
                        icon: Icons.local_hospital_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildTemplateOption(
                        id: 'notion_bills',
                        title: 'Notion บิลรายจ่ายประจำ',
                        subtitle: 'บิลคงที่, กบข., ประกันออมทรัพย์',
                        icon: Icons.receipt_long_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTemplateOption(
                        id: 'notion_invest_stocks',
                        title: 'Notion ซื้อหุ้น US',
                        subtitle: 'Invest-Stocks (O, JEPQ, NVDA…)',
                        icon: Icons.show_chart,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildTemplateOption(
                        id: 'custom',
                        title: 'CSV ทั่วไป',
                        subtitle: 'กำหนดคอลัมน์เอง',
                        icon: Icons.tune_outlined,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
                const SizedBox(height: 24),

                // Step 2: Upload File
                const Text(
                  'ขั้นตอนที่ 2: เลือกไฟล์ CSV',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _pickCsvFile,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _pickedFileName != null ? VaultTheme.accent(context) : Colors.grey.shade400,
                        width: _pickedFileName != null ? 2 : 1,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      color: _pickedFileName != null
                          ? VaultTheme.accent(context).withValues(alpha: 0.05)
                          : (isDark ? Colors.white10 : Colors.grey.shade50),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _pickedFileName != null ? Icons.check_circle : Icons.upload_file_outlined,
                            size: 44,
                            color: _pickedFileName != null ? VaultTheme.accent(context) : Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _pickedFileName ?? 'แตะเพื่อเลือกไฟล์ .csv จากคอมพิวเตอร์ของคุณ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _pickedFileName != null ? FontWeight.bold : FontWeight.normal,
                              color: _pickedFileName != null ? VaultTheme.primaryText(context) : Colors.grey.shade600,
                            ),
                          ),
                          if (_rawCsvRows.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'ตรวจพบ ${_rawCsvRows.length} แถว (คอลัมน์: ${_rawCsvRows.first.length})',
                              style: TextStyle(fontSize: 12, color: VaultTheme.accent(context)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Step 3: Column Mapping Status & Preview Button
                if (_pickedFileName != null && (_currentMapping != null || _selectedTemplate == 'notion_invest_stocks')) ...[
                  const Text(
                    'ขั้นตอนที่ 3: ตรวจสอบและนำเข้า',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    color: VaultTheme.surface(context),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedTemplate == 'notion_invest_stocks') ...[
                            Row(
                              children: [
                                const Icon(Icons.check, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'รูปแบบ Invest-Stocks (ตรวจจับคอลัมน์ Stock, Date, Shares, Invested อัตโนมัติ)',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              children: [
                                const Icon(Icons.check, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'จับคู่คอลัมน์สำเร็จ (Date: #${_currentMapping!.dateCol}, Name: #${_currentMapping!.nameCol}, Cat: #${_currentMapping!.categoryCol}, Amount: #${_currentMapping!.amountCol})',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.tune, size: 16),
                                  label: const Text('ปรับแต่งคอลัมน์'),
                                  onPressed: _adjustMapping,
                                ),
                              ],
                            ),
                          ],
                          const Divider(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: VaultTheme.accent(context),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.preview_outlined),
                              label: const Text('ตรวจสอบข้อมูลและยืนยันนำเข้า'),
                              onPressed: _proceedToPreview,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildTemplateOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedTemplate == id;
    final accent = VaultTheme.accent(context);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTemplate = id;
          if (_rawCsvRows.isNotEmpty) {
            final headers = _rawCsvRows.first.map((e) => e.toString()).toList();
            _currentMapping = CsvImportParser.detectMapping(headers, template: id);
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accent : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? accent.withValues(alpha: 0.08) : VaultTheme.surface(context),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? accent : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? accent : VaultTheme.primaryText(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
