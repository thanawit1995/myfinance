import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/theme/vault_theme.dart';
import '../../../../core/widgets/category_icon_helper.dart';
import 'category_form_dialog.dart';

class CategoryPickerSheet extends ConsumerStatefulWidget {
  final String categoryType; // 'income' or 'expense'
  final String? selectedCategoryId;

  const CategoryPickerSheet({
    super.key,
    required this.categoryType,
    this.selectedCategoryId,
  });

  static Future<Category?> show(
    BuildContext context, {
    required String categoryType,
    String? selectedCategoryId,
  }) {
    return showModalBottomSheet<Category?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CategoryPickerSheet(
        categoryType: categoryType,
        selectedCategoryId: selectedCategoryId,
      ),
    );
  }

  @override
  ConsumerState<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<CategoryPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<Category> _allCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final list = await ref
          .read(categoriesDaoProvider)
          .getActiveCategories(widget.categoryType);
      if (mounted) {
        setState(() {
          _allCategories = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final filtered = _allCategories.where((c) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final th = c.nameTh.toLowerCase();
      final en = c.nameEn.toLowerCase();
      return th.contains(query) || en.contains(query);
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: VaultTheme.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: VaultTheme.border(context),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Top Header: Title & Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    isThai ? 'เลือกหมวดหมู่' : 'Select Category',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: VaultTheme.primaryText(context),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: VaultTheme.secondaryText(context),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: isThai ? 'ค้นหาหมวดหมู่...' : 'Search categories...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  isDense: true,
                  filled: true,
                  fillColor: VaultTheme.surfaceSubtle(context),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
              ),
            ),

            // Add New Category Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final nav = Navigator.of(context);
                  final newCat = await CategoryFormDialog.show(
                    context,
                    initialType: widget.categoryType,
                  );
                  if (newCat != null && mounted) {
                    nav.pop(newCat);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        isThai ? 'สร้างหมวดหมู่ใหม่' : 'Create New Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Category List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Text(
                            isThai ? 'ไม่พบหมวดหมู่ที่ตรงกัน' : 'No matching categories',
                            style: TextStyle(color: VaultTheme.secondaryText(context)),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 0.5,
                            color: VaultTheme.border(context),
                          ),
                          itemBuilder: (context, index) {
                            final cat = filtered[index];
                            final isSelected = cat.id == widget.selectedCategoryId;
                            final name = isThai
                                ? cat.nameTh
                                : (cat.nameEn.trim().isNotEmpty ? cat.nameEn : cat.nameTh);

                            return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              leading: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary.withValues(alpha: 0.15)
                                      : VaultTheme.surfaceSubtle(context),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  CategoryIconHelper.getIcon(cat.icon),
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : VaultTheme.primaryText(context),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : VaultTheme.primaryText(context),
                                ),
                              ),
                              subtitle: (cat.nameEn.isNotEmpty && cat.nameTh != cat.nameEn)
                                  ? Text(
                                      isThai ? cat.nameEn : cat.nameTh,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: VaultTheme.secondaryText(context),
                                      ),
                                    )
                                  : null,
                              trailing: isSelected
                                  ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 20)
                                  : null,
                              onTap: () {
                                Navigator.of(context).pop(cat);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
