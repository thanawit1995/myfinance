import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/categories_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/theme/vault_theme.dart';
import '../../../../core/widgets/category_icon_helper.dart';
import '../../../../l10n/app_localizations.dart';
import 'category_form_dialog.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLumi = VaultTheme.isLumi(context);
    final accentColor = VaultTheme.accent(context);
    final l10n = AppLocalizations.of(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      appBar: AppBar(
        backgroundColor: VaultTheme.surface(context),
        title: Text(
          l10n?.manageCategories ?? 'จัดการหมวดหมู่รายรับ-รายจ่าย',
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: VaultTheme.primaryText(context),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentColor,
          labelColor: accentColor,
          unselectedLabelColor: VaultTheme.secondaryText(context),
          tabs: [
            Tab(
              icon: const Icon(Icons.arrow_upward, color: Colors.redAccent),
              text: l10n?.expenseCategories ?? 'หมวดหมู่รายจ่าย',
            ),
            Tab(
              icon: const Icon(Icons.arrow_downward, color: Colors.green),
              text: l10n?.incomeCategories ?? 'หมวดหมู่รายรับ',
            ),
          ],
        ),
        actions: [
          Tooltip(
            message: _showInactive
                ? (isThai ? 'ซ่อนหมวดหมู่ที่ปิดใช้งาน' : 'Hide inactive categories')
                : (isThai ? 'แสดงหมวดหมู่ที่ปิดใช้งาน' : 'Show inactive categories'),
            child: IconButton(
              icon: Icon(
                _showInactive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: _showInactive ? accentColor : VaultTheme.secondaryText(context),
              ),
              onPressed: () => setState(() => _showInactive = !_showInactive),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: isLumi ? 3 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isLumi ? 24 : 14)),
        onPressed: () async {
          final currentType = _tabController.index == 0 ? 'expense' : 'income';
          final created = await CategoryFormDialog.show(context, initialType: currentType);
          if (created != null) _refresh();
        },
        icon: const Icon(Icons.add),
        label: Text(l10n?.addNewCategory ?? 'เพิ่มหมวดหมู่ใหม่'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryListView(categoryType: 'expense', showInactive: _showInactive, onChanged: _refresh),
          _CategoryListView(categoryType: 'income', showInactive: _showInactive, onChanged: _refresh),
        ],
      ),
    );
  }
}

class _CategoryListView extends ConsumerStatefulWidget {
  final String categoryType;
  final bool showInactive;
  final VoidCallback onChanged;

  const _CategoryListView({
    required this.categoryType,
    required this.showInactive,
    required this.onChanged,
  });

  @override
  ConsumerState<_CategoryListView> createState() => _CategoryListViewState();
}

class _CategoryListViewState extends ConsumerState<_CategoryListView> {
  List<Category>? _activeCategories;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant _CategoryListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryType != widget.categoryType ||
        oldWidget.showInactive != widget.showInactive) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final dao = ref.read(categoriesDaoProvider);
    try {
      final list = widget.showInactive
          ? await dao.getInactiveCategories(widget.categoryType)
          : await dao.getActiveCategories(widget.categoryType);
      if (mounted) {
        setState(() {
          _activeCategories = list;
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
    final dao = ref.watch(categoriesDaoProvider);
    final isExpense = widget.categoryType == 'expense';
    final isLumi = VaultTheme.isLumi(context);
    final l10n = AppLocalizations.of(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final accentColor = VaultTheme.accent(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final categories = _activeCategories ?? [];

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.showInactive ? Icons.visibility_off_outlined : Icons.category_outlined,
              size: 48,
              color: VaultTheme.mutedText(context),
            ),
            const SizedBox(height: 12),
            Text(
              widget.showInactive
                  ? (isThai ? 'ไม่มีหมวดหมู่ที่ถูกปิดใช้งาน' : 'No inactive categories')
                  : (isThai
                      ? 'ยังไม่มีหมวดหมู่สำหรับ${isExpense ? 'รายจ่าย' : 'รายรับ'}'
                      : 'No categories for ${isExpense ? 'Expense' : 'Income'}'),
              style: TextStyle(color: VaultTheme.secondaryText(context)),
            ),
          ],
        ),
      );
    }

    if (widget.showInactive) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isThai
                          ? 'หมวดหมู่เหล่านี้ถูกซ่อนอยู่ กดปุ่ม "กู้คืน" เพื่อเปิดใช้งานอีกครั้ง'
                          : 'These categories are hidden. Tap "Restore" to reactivate.',
                      style: const TextStyle(fontSize: 13, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            );
          }
          if (index == categories.length + 1) {
            return const SizedBox(height: 80);
          }
          final cat = categories[index - 1];
          return _buildCategoryCard(cat, isExpense, isLumi, isThai, l10n, dao, index - 1);
        },
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: VaultTheme.surface(context).withValues(alpha: 0.6),
          child: Row(
            children: [
              Icon(Icons.swap_vert, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isThai
                      ? 'กดค้างแล้วลากเพื่อจัดลำดับ (ลำดับนี้จะแสดงในหน้า Quick Add)'
                      : 'Press & drag to reorder (used in Quick Add)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: VaultTheme.secondaryText(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            itemCount: categories.length,
            // ignore: deprecated_member_use
            onReorder: (oldIndex, newIndex) async {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              setState(() {
                final item = categories.removeAt(oldIndex);
                categories.insert(newIndex, item);
              });
              await dao.updateCategorySortOrders(categories.map((c) => c.id).toList());
              widget.onChanged();
            },
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _buildCategoryCard(
                cat,
                isExpense,
                isLumi,
                isThai,
                l10n,
                dao,
                index,
                key: ValueKey(cat.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    Category cat,
    bool isExpense,
    bool isLumi,
    bool isThai,
    AppLocalizations? l10n,
    CategoriesDao dao,
    int index, {
    Key? key,
  }) {
    final showInactive = widget.showInactive;
    final primaryName = isThai
        ? cat.nameTh
        : (cat.nameEn.trim().isNotEmpty ? cat.nameEn : cat.nameTh);
    final secondaryName = isThai
        ? cat.nameEn
        : (cat.nameEn.trim().isNotEmpty ? cat.nameTh : '');

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLumi ? 16 : 12),
        side: BorderSide(color: VaultTheme.border(context)),
      ),
      color: showInactive
          ? VaultTheme.surface(context).withValues(alpha: 0.5)
          : VaultTheme.surface(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: (showInactive
                      ? Colors.grey
                      : isExpense
                          ? const Color(0xFFFF5C9D)
                          : Colors.green)
                  .withValues(alpha: 0.15),
              child: Icon(
                CategoryIconHelper.getIcon(cat.icon),
                size: 20,
                color: showInactive
                    ? Colors.grey
                    : isExpense
                        ? const Color(0xFFFF5C9D)
                        : Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          primaryName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: VaultTheme.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: showInactive
                                ? VaultTheme.mutedText(context)
                                : VaultTheme.primaryText(context),
                          ),
                        ),
                      ),
                      if (cat.isSystem) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: VaultTheme.border(context).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n?.defaultBadge ?? 'ค่าเริ่มต้น',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: VaultTheme.secondaryText(context),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (secondaryName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      secondaryName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 12,
                        color: VaultTheme.secondaryText(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (showInactive)
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () async {
                  await dao.restoreCategory(cat.id);
                  widget.onChanged();
                  await _loadData();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isThai
                          ? 'เปิดใช้งาน "${cat.nameTh}" แล้ว'
                          : 'Restored "$primaryName"'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  l10n?.restoreCategory ?? 'กู้คืน',
                  style: const TextStyle(fontSize: 12),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.edit_outlined,
                        size: 18, color: VaultTheme.secondaryText(context)),
                    tooltip: l10n?.editCategory ?? 'แก้ไขหมวดหมู่',
                    onPressed: () async {
                      final updated =
                          await CategoryFormDialog.show(context, category: cat);
                      if (updated != null) {
                        widget.onChanged();
                        await _loadData();
                      }
                    },
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.visibility_off_outlined,
                        size: 18, color: Colors.orange),
                    tooltip: cat.isSystem
                        ? (isThai ? 'ซ่อนหมวดหมู่นี้' : 'Hide default category')
                        : (isThai ? 'ปิดใช้งานหมวดหมู่' : 'Deactivate category'),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(cat.isSystem
                              ? (isThai ? 'ซ่อนหมวดหมู่ค่าเริ่มต้น' : 'Hide Default Category')
                              : (isThai ? 'ยืนยันปิดใช้งาน' : 'Confirm Deactivation')),
                          content: Text(
                            cat.isSystem
                                ? (isThai
                                    ? 'ต้องการซ่อนหมวดหมู่ "${cat.nameTh}" ไว้ก่อนหรือไม่?\n\nสามารถกู้คืนได้ตลอดเวลาโดยกดไอคอนตาในหน้านี้'
                                    : 'Hide default category "$primaryName"?\n\nYou can restore it anytime via the eye icon.')
                                : (isThai
                                    ? 'ต้องการปิดใช้งานหมวดหมู่ "${cat.nameTh}" หรือไม่?\n\nสามารถกู้คืนได้ตลอดเวลา'
                                    : 'Deactivate category "$primaryName"?\n\nYou can restore it anytime.'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
                            ),
                            FilledButton(
                              style:
                                  FilledButton.styleFrom(backgroundColor: Colors.orange),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(isThai ? 'ซ่อน / ปิดใช้งาน' : 'Hide / Deactivate'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await dao.deactivateCategory(cat.id);
                        widget.onChanged();
                        await _loadData();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isThai
                                ? 'ซ่อน "${cat.nameTh}" แล้ว — กดไอคอนตาเพื่อกู้คืน'
                                : 'Hidden "$primaryName" — tap eye icon to restore'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  ),
                  if (!cat.isSystem) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      tooltip: isThai ? 'ลบหมวดหมู่นี้' : 'Delete category',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(isThai ? 'ยืนยันลบหมวดหมู่' : 'Confirm Delete Category'),
                            content: Text(
                              isThai
                                  ? 'คุณต้องการลบหมวดหมู่ "$primaryName" ใช่หรือไม่?\n\n(รายการธุรกรรมเดิมที่เคยบันทึกไว้จะไม่สูญหาย)'
                                  : 'Do you want to delete category "$primaryName"?\n\n(Existing recorded transactions will not be lost)',
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

                        if (confirm == true) {
                          await dao.softDeleteCategory(cat.id);
                          widget.onChanged();
                          await _loadData();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isThai
                                  ? 'ลบหมวดหมู่ "$primaryName" แล้ว'
                                  : 'Deleted category "$primaryName"'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                  if (!showInactive) ...[
                    const SizedBox(width: 4),
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: Icon(
                          Icons.drag_indicator,
                          size: 20,
                          color: VaultTheme.secondaryText(context).withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
