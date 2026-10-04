import 'package:flutter/material.dart';
import '../theme/vault_theme.dart';
import 'category_icon_helper.dart';

/// Reusable icon picker dialog/sheet for Accounts, Assets, and Categories.
class AppIconSelector extends StatelessWidget {
  final String? currentIcon;
  final ValueChanged<String> onSelected;

  const AppIconSelector({
    super.key,
    required this.currentIcon,
    required this.onSelected,
  });

  static Future<String?> show(BuildContext context, {String? currentIcon}) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: VaultTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (sheetCtx, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isThai ? 'เลือกไอคอน' : 'Select Icon',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: VaultTheme.primaryText(context),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: CategoryIconHelper.categorizedIcons.entries.map((group) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            group.key,
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: VaultTheme.mutedText(context),
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: group.value.map((iconName) {
                            final isSelected = currentIcon == iconName;
                            final iconData = CategoryIconHelper.getIcon(iconName);
                            return InkWell(
                              onTap: () {
                                Navigator.pop(ctx, iconName);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? VaultTheme.accent(context).withValues(alpha: 0.15)
                                      : VaultTheme.background(context),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? VaultTheme.accent(context)
                                        : VaultTheme.border(context),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    iconData,
                                    size: 24,
                                    color: isSelected
                                        ? VaultTheme.accent(context)
                                        : VaultTheme.primaryText(context),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
