import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../database/daos/budgets_dao.dart';
import '../database/daos/transactions_dao.dart';

String getCategoryLocalizedName(
  BuildContext context, {
  required String nameTh,
  String? nameEn,
}) {
  final isEn = Localizations.localeOf(context).languageCode == 'en';
  if (isEn && nameEn != null && nameEn.trim().isNotEmpty) {
    return nameEn;
  }
  return nameTh;
}

extension CategoryLocalizationExtension on Category {
  String localizedName(BuildContext context) {
    return getCategoryLocalizedName(context, nameTh: nameTh, nameEn: nameEn);
  }
}

extension CategoryBudgetStatusLocalization on CategoryBudgetStatus {
  String localizedName(BuildContext context) {
    return getCategoryLocalizedName(context, nameTh: categoryNameTh, nameEn: categoryNameEn);
  }
}

extension CategoryExpenseSummaryLocalization on CategoryExpenseSummary {
  String localizedName(BuildContext context) {
    return getCategoryLocalizedName(context, nameTh: categoryNameTh, nameEn: categoryNameEn);
  }
}
