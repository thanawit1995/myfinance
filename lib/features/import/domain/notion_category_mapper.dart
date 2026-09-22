/// Converts raw Notion category strings to the canonical [nameEn] used by
/// the app's default categories.  The mapping is applied **after**
/// [CsvImportParser.cleanNotionRelation] has already stripped the emoji prefix
/// and the month-suffix (e.g. `🍴Eating_DEC24` → `Eating`).
///
/// If a Notion category does not match any entry, `null` is returned so that
/// [ImportExecutor] can fall back to auto-creating a new category with the
/// original name.
class NotionCategoryMapper {
  NotionCategoryMapper._();

  /// Maps a cleaned Notion category name (any case) to the matching
  /// [nameEn] used in [SeedData].  Returns `null` if no match.
  static String? toAppCategoryNameEn(String notionCategory) {
    return _map[notionCategory.toLowerCase().trim()];
  }

  static const Map<String, String> _map = {
    // ─── Expense ───────────────────────────────────────────────────────────
    'eating': 'Food & Dining',
    'transportation': 'Transportation',
    'health & fitness': 'Healthcare',
    'health and fitness': 'Healthcare',
    'home': 'Housing',
    'entertainment': 'Entertainment',
    'lover': 'Gifts',
    'cat': 'Yuzu',
    'shopping': 'Shopping',
    'utilities': 'Utilities',
    'education': 'Education',
    'financial fees': 'Financial Fees',
    'other expense': 'Other Expense',

    // ─── Income ────────────────────────────────────────────────────────────
    'salary': 'Salary',
    'top up': 'Other Income',
    'topup': 'Other Income',
    'on duty': 'Freelance / Shift',
    'freelance': 'Freelance / Shift',
    'interest & dividends': 'Interest & Dividends',
    'dividends': 'Interest & Dividends',
    'business': 'Business / Sales',
    'other income': 'Other Income',
  };
}
