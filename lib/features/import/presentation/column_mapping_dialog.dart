import 'package:flutter/material.dart';
import '../../../core/theme/vault_theme.dart';
import '../domain/csv_import_models.dart';

class ColumnMappingDialog extends StatefulWidget {
  final List<String> headers;
  final CsvColumnMapping currentMapping;

  const ColumnMappingDialog({
    super.key,
    required this.headers,
    required this.currentMapping,
  });

  static Future<CsvColumnMapping?> show(
    BuildContext context, {
    required List<String> headers,
    required CsvColumnMapping currentMapping,
  }) {
    return showDialog<CsvColumnMapping>(
      context: context,
      builder: (_) => ColumnMappingDialog(
        headers: headers,
        currentMapping: currentMapping,
      ),
    );
  }

  @override
  State<ColumnMappingDialog> createState() => _ColumnMappingDialogState();
}

class _ColumnMappingDialogState extends State<ColumnMappingDialog> {
  late int _dateCol;
  late int _nameCol;
  late int _categoryCol;
  late int _amountCol;
  int? _accountCol;
  int? _noteCol;
  int? _taxTypeCol;
  int? _whtCol;

  @override
  void initState() {
    super.initState();
    _dateCol = widget.currentMapping.dateCol;
    _nameCol = widget.currentMapping.nameCol;
    _categoryCol = widget.currentMapping.categoryCol;
    _amountCol = widget.currentMapping.amountCol;
    _accountCol = widget.currentMapping.accountCol;
    _noteCol = widget.currentMapping.noteCol;
    _taxTypeCol = widget.currentMapping.taxTypeCol;
    _whtCol = widget.currentMapping.whtCol;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'จับคู่คอลัมน์ (Column Mapping)',
        style: TextStyle(
          fontFamily: VaultTheme.fontFamily,
          fontWeight: FontWeight.bold,
          color: VaultTheme.primaryText(context),
        ),
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdown(
                label: 'วันที่ (Date) *',
                value: _dateCol,
                required: true,
                onChanged: (val) => setState(() => _dateCol = val ?? 0),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'ชื่อรายการ (Name / Description) *',
                value: _nameCol,
                required: true,
                onChanged: (val) => setState(() => _nameCol = val ?? 0),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'หมวดหมู่ (Category) *',
                value: _categoryCol,
                required: true,
                onChanged: (val) => setState(() => _categoryCol = val ?? 0),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'จำนวนเงิน (Amount / THB) *',
                value: _amountCol,
                required: true,
                onChanged: (val) => setState(() => _amountCol = val ?? 0),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'บัญชี / กระเป๋า (Account / Wallet)',
                value: _accountCol,
                required: false,
                onChanged: (val) => setState(() => _accountCol = val),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'หมายเหตุ (Note / Memo)',
                value: _noteCol,
                required: false,
                onChanged: (val) => setState(() => _noteCol = val),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'ประเภทภาษี (Tax Category / มาตรา)',
                value: _taxTypeCol,
                required: false,
                onChanged: (val) => setState(() => _taxTypeCol = val),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'ภาษีหัก ณ ที่จ่าย (Withholding Tax)',
                value: _whtCol,
                required: false,
                onChanged: (val) => setState(() => _whtCol = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: VaultTheme.accent(context)),
          onPressed: () {
            Navigator.of(context).pop(
              CsvColumnMapping(
                dateCol: _dateCol,
                nameCol: _nameCol,
                categoryCol: _categoryCol,
                amountCol: _amountCol,
                accountCol: _accountCol,
                noteCol: _noteCol,
                taxTypeCol: _taxTypeCol,
                whtCol: _whtCol,
              ),
            );
          },
          child: const Text('ตกลง'),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required int? value,
    required bool required,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int?>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      initialValue: (value != null && value >= 0 && value < widget.headers.length) ? value : null,
      items: [
        if (!required)
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('(ไม่ระบุ / ใช้ค่าเริ่มต้น)', style: TextStyle(color: Colors.grey)),
          ),
        for (int i = 0; i < widget.headers.length; i++)
          DropdownMenuItem<int?>(
            value: i,
            child: Text(
              '[$i] ${widget.headers[i].isEmpty ? "(คอลัมน์ว่าง)" : widget.headers[i]}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
