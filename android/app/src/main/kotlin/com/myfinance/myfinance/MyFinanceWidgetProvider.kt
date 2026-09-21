package com.myfinance.myfinance

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class MyFinanceWidget2x2 : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_2x2).apply {
                val remaining = widgetData.getString("remaining_text", "฿0.00")
                val spent = widgetData.getString("spent_text", "฿0.00")
                setTextViewText(R.id.remaining_text, remaining)
                setTextViewText(R.id.spent_text, "ใช้ไป: $spent")

                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.btn_quick_add, pendingIntent)
                setOnClickPendingIntent(R.id.widget_2x2_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

class MyFinanceWidget4x2 : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_4x2).apply {
                val remaining = widgetData.getString("remaining_text", "฿0.00")
                val spent = widgetData.getString("spent_text", "฿0.00")
                val budget = widgetData.getString("budget_text", "฿0.00")
                val month = widgetData.getString("month_name", "")
                val progress = widgetData.getInt("progress_percent", 0)

                setTextViewText(R.id.remaining_text, remaining)
                setTextViewText(R.id.spent_text, "ใช้ไป: $spent")
                setTextViewText(R.id.budget_text, "งบ: $budget")
                if (!month.isNullOrEmpty()) {
                    setTextViewText(R.id.month_name, month)
                }
                setProgressBar(R.id.budget_progress, 100, progress, false)

                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.btn_quick_add, pendingIntent)
                setOnClickPendingIntent(R.id.widget_4x2_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
