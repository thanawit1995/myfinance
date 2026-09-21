import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../money/money.dart';

class WidgetService {
  static const appGroupId = 'group.com.myfinance.myfinance';
  static const androidWidgetName2x2 = 'MyFinanceWidget2x2';
  static const androidWidgetName4x2 = 'MyFinanceWidget4x2';

  static Future<void> updateWidgetData({
    required int remainingSatang,
    required int spentSatang,
    required int budgetSatang,
    required String monthName,
  }) async {
    // Only execute on Android / mobile platforms
    if (!kIsWeb && !Platform.isAndroid) {
      return;
    }

    try {
      final remainingMoney = Money(remainingSatang);
      final spentMoney = Money(spentSatang);
      final budgetMoney = Money(budgetSatang);

      final progress = budgetSatang > 0 ? (spentSatang / budgetSatang).clamp(0.0, 1.0) : 0.0;
      final progressPercent = (progress * 100).toInt();

      await HomeWidget.saveWidgetData<String>('remaining_text', remainingMoney.format(symbol: '฿'));
      await HomeWidget.saveWidgetData<String>('spent_text', spentMoney.format(symbol: '฿'));
      await HomeWidget.saveWidgetData<String>('budget_text', budgetMoney.format(symbol: '฿'));
      await HomeWidget.saveWidgetData<String>('month_name', monthName);
      await HomeWidget.saveWidgetData<int>('progress_percent', progressPercent);

      await HomeWidget.updateWidget(
        name: androidWidgetName2x2,
        androidName: androidWidgetName2x2,
      );
      await HomeWidget.updateWidget(
        name: androidWidgetName4x2,
        androidName: androidWidgetName4x2,
      );
    } catch (e) {
      debugPrint('Widget update error (ignored on unsupported platform): $e');
    }
  }
}
