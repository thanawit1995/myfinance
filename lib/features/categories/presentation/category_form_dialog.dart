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
    return Navigator.push<Category?>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryFormDialog(
          categoryToEdit: category,
          initialType: initialType,
        ),
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

  Future<void> _hideCategory() async {
    final existing = widget.categoryToEdit;
    if (existing == null) return;
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing.isSystem
            ? (isThai ? 'ซ่อนหมวดหมู่ค่าเริ่มต้น' : 'Hide Default Category')
            : (isThai ? 'ยืนยันการซ่อนหมวดหมู่' : 'Confirm Hide Category')),
        content: Text(
          isThai
              ? 'ต้องการซ่อนหมวดหมู่ "${existing.nameTh}" ไว้ก่อนหรือไม่?\n\nสามารถกู้คืนได้ตลอดเวลาจากเมนู "หมวดหมู่ที่ถูกซ่อน"'
              : 'Hide category "${existing.nameTh}"?\n\nYou can restore it anytime from hidden categories.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isThai ? 'ซ่อนหมวดหมู่' : 'Hide'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final dao = ref.read(categoriesDaoProvider);
      await dao.deactivateCategory(existing.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai
                ? 'ซ่อนหมวดหมู่ "${existing.nameTh}" แล้ว'
                : 'Hidden category "${existing.nameTh}"'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(existing);
      }
    }
  }

  Future<void> _deleteCategory() async {
    final existing = widget.categoryToEdit;
    if (existing == null || existing.isSystem) return;
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'ยืนยันลบหมวดหมู่' : 'Confirm Delete Category'),
        content: Text(
          isThai
              ? 'คุณต้องการลบหมวดหมู่ "${existing.nameTh}" ใช่หรือไม่?\n\n(รายการธุรกรรมเดิมที่เคยบันทึกไว้จะไม่สูญหาย)'
              : 'Do you want to delete category "${existing.nameTh}"?\n\n(Existing recorded transactions will not be lost)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isThai ? 'ลบหมวดหมู่' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final dao = ref.read(categoriesDaoProvider);
      await dao.softDeleteCategory(existing.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai
                ? 'ลบหมวดหมู่ "${existing.nameTh}" แล้ว'
                : 'Deleted category "${existing.nameTh}"'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(existing);
      }
    }
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
    final isSystem = widget.categoryToEdit?.isSystem ?? false;
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? (isThai ? 'แก้ไขหมวดหมู่' : 'Edit Category')
            : (isThai ? 'สร้างหมวดหมู่ใหม่' : 'New Category')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _categoryType,
                  decoration: InputDecoration(
                    labelText: isThai ? 'ประเภทหมวดหมู่' : 'Category Type',
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'expense',
                      child: Text(isThai ? 'รายจ่าย (Expense)' : 'Expense'),
                    ),
                    DropdownMenuItem(
                      value: 'income',
                      child: Text(isThai ? 'รายรับ (Income)' : 'Income'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _categoryType = val);
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameThController,
                  decoration: InputDecoration(
                    labelText: isThai ? 'ชื่อหมวดหมู่ (ภาษาไทย) *' : 'Thai Name *',
                    hintText: isThai ? 'เช่น ค่าอาหาร, กาแฟ, เงินเดือน' : 'e.g. ค่าอาหาร, กาแฟ',
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? (isThai ? 'กรุณาระบุชื่อ' : 'Please enter name') : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameEnController,
                  decoration: InputDecoration(
                    labelText: isThai ? 'ชื่อภาษาอังกฤษ (English Name)' : 'English Name',
                    hintText: isThai ? 'เช่น Food, Coffee, Salary' : 'e.g. Food, Coffee, Salary',
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isThai ? 'เลือกไอคอนสัญลักษณ์:' : 'Choose an icon:',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 240,
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
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primaryContainer
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Icon(
                                    CategoryIconHelper.getIcon(iconName),
                                    size: 22,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade700,
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
                if (isEditing) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    isThai ? 'การจัดการหมวดหมู่' : 'Category Actions',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        icon: const Icon(Icons.visibility_off_outlined, size: 18),
                        label: Text(isThai ? 'ซ่อนหมวดหมู่นี้' : 'Hide Category'),
                        onPressed: _hideCategory,
                      ),
                      if (!isSystem)
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: Text(isThai ? 'ลบหมวดหมู่นี้' : 'Delete Category'),
                          onPressed: _deleteCategory,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _save,
            child: Text(
              isEditing
                  ? (isThai ? 'บันทึกการแก้ไข' : 'Save Changes')
                  : (isThai ? 'สร้างหมวดหมู่' : 'Create Category'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
