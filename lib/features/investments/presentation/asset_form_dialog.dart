import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';

class AssetFormDialog extends ConsumerStatefulWidget {
  final Asset? assetToEdit;

  const AssetFormDialog({super.key, this.assetToEdit});

  static Future<bool?> show(BuildContext context, {Asset? assetToEdit}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AssetFormDialog(assetToEdit: assetToEdit),
    );
  }

  @override
  ConsumerState<AssetFormDialog> createState() => _AssetFormDialogState();
}

class _AssetFormDialogState extends ConsumerState<AssetFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _symbolController;
  late TextEditingController _nameController;
  late TextEditingController _marketController;
  late TextEditingController _noteController;
  late TextEditingController _couponRateController;

  String _selectedAssetType = 'thai_stock';
  String _selectedCurrency = 'THB';
  String? _selectedAccountId;
  DateTime? _maturityDate;
  String _couponFrequency = 'semi_annually';

  final _assetTypes = [
    {'key': 'thai_stock', 'label': 'หุ้นไทย'},
    {'key': 'foreign_stock', 'label': 'หุ้นต่างประเทศ'},
    {'key': 'etf', 'label': 'ETF'},
    {'key': 'mutual_fund', 'label': 'กองทุนรวม'},
    {'key': 'crypto', 'label': 'คริปโตเคอร์เรนซี'},
    {'key': 'gold', 'label': 'ทองคำ'},
    {'key': 'bond', 'label': 'พันธบัตร / หุ้นกู้'},
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.assetToEdit;
    _symbolController = TextEditingController(text: a?.symbol ?? '');
    _nameController = TextEditingController(text: a?.name ?? '');
    _marketController = TextEditingController(text: a?.market ?? '');
    _noteController = TextEditingController(text: a?.note ?? '');
    _couponRateController = TextEditingController();

    if (a != null) {
      _selectedAssetType = a.assetType;
      _selectedCurrency = a.currencyCode;
      _selectedAccountId = a.defaultAccountId;
      if (a.extraDetailsJson != null && a.extraDetailsJson!.isNotEmpty) {
        try {
          final extra = jsonDecode(a.extraDetailsJson!) as Map<String, dynamic>;
          _couponRateController.text = extra['couponRate']?.toString() ?? '';
          if (extra['maturityDate'] != null) {
            _maturityDate = DateTime.tryParse(extra['maturityDate']);
          }
          _couponFrequency = extra['frequency'] ?? 'semi_annually';
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _nameController.dispose();
    _marketController.dispose();
    _noteController.dispose();
    _couponRateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกบัญชีที่ถือครองสินทรัพย์นี้')),
      );
      return;
    }

    final now = DateTime.now();
    String? extraJson;
    if (_selectedAssetType == 'bond') {
      extraJson = jsonEncode({
        'couponRate': _couponRateController.text.trim(),
        'maturityDate': _maturityDate?.toIso8601String(),
        'frequency': _couponFrequency,
      });
    }

    final invDao = ref.read(investmentsDaoProvider);

    if (widget.assetToEdit == null) {
      // Create
      await invDao.createAsset(
        AssetsCompanion.insert(
          id: const Uuid().v4(),
          symbol: _symbolController.text.trim().toUpperCase(),
          name: _nameController.text.trim(),
          assetType: _selectedAssetType,
          currencyCode: _selectedCurrency,
          defaultAccountId: _selectedAccountId!,
          market: Value(_marketController.text.trim().isEmpty ? null : _marketController.text.trim()),
          note: Value(_noteController.text.trim().isEmpty ? null : _noteController.text.trim()),
          extraDetailsJson: Value(extraJson),
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      // Update
      await invDao.updateAsset(
        AssetsCompanion(
          id: Value(widget.assetToEdit!.id),
          symbol: Value(_symbolController.text.trim().toUpperCase()),
          name: Value(_nameController.text.trim()),
          assetType: Value(_selectedAssetType),
          currencyCode: Value(_selectedCurrency),
          defaultAccountId: Value(_selectedAccountId!),
          market: Value(_marketController.text.trim().isEmpty ? null : _marketController.text.trim()),
          note: Value(_noteController.text.trim().isEmpty ? null : _noteController.text.trim()),
          extraDetailsJson: Value(extraJson),
          updatedAt: Value(now),
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.assetToEdit == null ? 'เพิ่มสินทรัพย์ใหม่' : 'แก้ไขสินทรัพย์'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Symbol & Name
                TextFormField(
                  controller: _symbolController,
                  decoration: const InputDecoration(
                    labelText: 'สัญลักษณ์ / ตัวย่อ (Symbol) *',
                    hintText: 'เช่น PTT, VOO, BTC, ทองแท่ง 96.5%',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'กรุณาระบุสัญลักษณ์' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อเต็มของสินทรัพย์ *',
                    hintText: 'เช่น บริษัท ปตท. จำกัด (มหาชน)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'กรุณาระบุชื่อสินทรัพย์' : null,
                ),
                const SizedBox(height: 12),

                // 2. Asset Type Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'ประเภทสินทรัพย์', border: OutlineInputBorder()),
                  initialValue: _selectedAssetType,
                  items: _assetTypes.map((t) => DropdownMenuItem(value: t['key'], child: Text(t['label']!))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedAssetType = val;
                        // Auto-suggest currency
                        if (val == 'foreign_stock' || val == 'etf') {
                          _selectedCurrency = 'USD';
                        } else if (val == 'thai_stock' || val == 'mutual_fund' || val == 'gold') {
                          _selectedCurrency = 'THB';
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                // 3. Currency & Market
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'สกุลเงิน', border: OutlineInputBorder()),
                        initialValue: _selectedCurrency,
                        items: const [
                          DropdownMenuItem(value: 'THB', child: Text('THB (฿)')),
                          DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCurrency = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _marketController,
                        decoration: const InputDecoration(
                          labelText: 'ตลาด / Exchange',
                          hintText: 'เช่น SET, NYSE, Binance',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. Default Holding Account
                FutureBuilder<List<Account>>(
                  future: ref.read(accountsDaoProvider).getActiveAccounts(),
                  builder: (context, snapshot) {
                    final accounts = snapshot.data ?? [];
                    if (_selectedAccountId == null && accounts.isNotEmpty) {
                      _selectedAccountId = accounts.first.id;
                    }
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'บัญชีที่ถือครอง *', border: OutlineInputBorder()),
                      initialValue: _selectedAccountId,
                      items: accounts.map((a) {
                        return DropdownMenuItem(
                          value: a.id,
                          child: Text('${a.name} (${a.currencyCode}) [${a.isDomestic ? "ไทย" : "ต่างประเทศ"}]'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedAccountId = val),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 5. If Bond: extra fields
                if (_selectedAssetType == 'bond') ...[
                  TextFormField(
                    controller: _couponRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'อัตราดอกเบี้ยหน้าตั๋ว (% ต่อปี)',
                      hintText: 'เช่น 3.5',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_maturityDate == null
                        ? 'วันครบกำหนดไถ่ถอน (แตะเพื่อเลือก)'
                        : 'วันครบกำหนด: ${_maturityDate!.day}/${_maturityDate!.month}/${_maturityDate!.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _maturityDate ?? DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2050),
                      );
                      if (picked != null) {
                        setState(() => _maturityDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // 6. Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'บันทึกช่วยจำ (Note)',
                    hintText: 'เช่น พอร์ตระยะยาวปันผล',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('ยกเลิก')),
        FilledButton(onPressed: _submit, child: const Text('บันทึกสินทรัพย์')),
      ],
    );
  }
}
