import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/widgets/category_icon_helper.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  final Category? categoryToEdit;
  final String? initialType; // 'expense' or 'income'

  const CategoryFormDialog({
    super.key,
    this.categoryToEdit,
    this.initialType,
  });

  static Future<Category?> show(
    BuildContext context, {
    Category? category,
    String? initialType,
  }) {
    return showDialog<Category?>(
      context: context,
      builder: (_) => CategoryFormDialog(
        categoryToEdit: category,
        initialType: initialType,
      ),
    );
  }

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameThController;
  late TextEditingController _nameEnController;
  late String _categoryType;

  final List<String> _commonIcons = CategoryIconHelper.allIcons;

  late String _selectedIcon;

  @override
  void initState() {
    super.initState();
    final c = widget.categoryToEdit;
    _nameThController = TextEditingController(text: c?.nameTh ?? '');
    _nameEnController = TextEditingController(text: c?.nameEn ?? '');
    _categoryType = c?.categoryType ?? widget.initialType ?? 'expense';
    _selectedIcon = c?.icon ?? _commonIcons.first;
  }

  @override
  void dispose() {
    _nameThController.dispose();
    _nameEnController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final dao = ref.read(categoriesDaoProvider);
    final nameTh = _nameThController.text.trim();
    final nameEn = _nameEnController.text.trim().isNotEmpty
        ? _nameEnController.text.trim()
        : nameTh;
    final now = DateTime.now();

    if (widget.categoryToEdit == null) {
      // Create
      final newId = const Uuid().v4();
      await dao.createCategory(
        CategoriesCompanion.insert(
          id: newId,
          nameTh: nameTh,
          nameEn: nameEn,
          categoryType: _categoryType,
          icon: drift.Value(_selectedIcon),
          isSystem: const drift.Value(false),
          isActive: const drift.Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final created = await dao.getCategoryById(newId);
      if (mounted) {
        Navigator.of(context).pop(created);
      }
    } else {
      // Update
      final existing = widget.categoryToEdit!;
      await dao.updateCategory(
        existing.toCompanion(true).copyWith(
          nameTh: drift.Value(nameTh),
          nameEn: drift.Value(nameEn),
          categoryType: drift.Value(_categoryType),
          icon: drift.Value(_selectedIcon),
          updatedAt: drift.Value(now),
        ),
      );

      final updated = await dao.getCategoryById(existing.id);
      if (mounted) {
        Navigator.of(context).pop(updated);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoryToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'แก้ไขหมวดหมู่' : 'สร้างหมวดหมู่ใหม่'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _categoryType,
                  decoration: const InputDecoration(
                    labelText: 'ประเภทหมวดหมู่',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'expense', child: Text('รายจ่าย (Expense)')),
                    DropdownMenuItem(value: 'income', child: Text('รายรับ (Income)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _categoryType = val);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameThController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อหมวดหมู่ (ภาษาไทย) *',
                    hintText: 'เช่น ค่าอาหาร, กาแฟ, เงินเดือน',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณาระบุชื่อ' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameEnController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อภาษาอังกฤษ (English Name)',
                    hintText: 'เช่น Food, Coffee, Salary',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('เลือกไอคอนสัญลักษณ์:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: CategoryIconHelper.categorizedIcons.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: entry.value.map((iconName) {
                              final isSelected = iconName == _selectedIcon;
                              return InkWell(
                                onTap: () => setState(() => _selectedIcon = iconName),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Icon(
                                    CategoryIconHelper.getIcon(iconName),
                                    size: 22,
                                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade700,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(isEditing ? 'บันทึกการแก้ไข' : 'สร้างหมวดหมู่'),
        ),
      ],
    );
  }
}
