package app.myfaith

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews

/** The 1x1 widget: next prayer, its time and how long is left. */
class NextPrayerWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        WidgetUpdater.updateAll(context)
    }
}

/** The wide widget: all prayer times of the day. */
class TimetableWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        WidgetUpdater.updateAll(context)
    }
}

/** Fires when the next prayer begins, so the widgets move on to the one after. */
class WidgetRefreshReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        WidgetUpdater.updateAll(context)
    }
}

object WidgetUpdater {
    private const val GREEN = 0xFF37563B.toInt()
    private const val INK = 0xFF1B1B1B.toInt()
    private const val MUTED = 0xFF6B6F6C.toInt()
    private const val WHITE = 0xFFFFFFFF.toInt()

    private val cells = intArrayOf(
        R.id.cell0, R.id.cell1, R.id.cell2, R.id.cell3, R.id.cell4, R.id.cell5,
    )
    private val names = intArrayOf(
        R.id.name0, R.id.name1, R.id.name2, R.id.name3, R.id.name4, R.id.name5,
    )
    private val clocks = intArrayOf(
        R.id.clock0, R.id.clock1, R.id.clock2, R.id.clock3, R.id.clock4, R.id.clock5,
    )

    fun updateAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val small = manager.getAppWidgetIds(ComponentName(context, NextPrayerWidget::class.java))
        val wide = manager.getAppWidgetIds(ComponentName(context, TimetableWidget::class.java))
        if (small.isEmpty() && wide.isEmpty()) return

        val prayers = Store.prayers(context)
        val now = System.currentTimeMillis()
        val next = prayers.firstOrNull { it.time > now }

        if (small.isNotEmpty()) manager.updateAppWidget(small, smallViews(context, next, now))
        if (wide.isNotEmpty()) manager.updateAppWidget(wide, wideViews(context, prayers, next, now))
        if (next != null) scheduleRefresh(context, next.time + 1000)
    }

    private fun openApp(context: Context): PendingIntent? {
        val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: return null
        return PendingIntent.getActivity(
            context,
            0,
            launch,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /** The system counts the chronometer down by itself, without waking the app. */
    private fun countdown(views: RemoteViews, id: Int, next: WidgetPrayer, now: Long) {
        val base = SystemClock.elapsedRealtime() + (next.time - now)
        views.setChronometerCountDown(id, true)
        views.setChronometer(id, base, "−%s", true)
        views.setViewVisibility(id, View.VISIBLE)
    }

    private fun smallViews(context: Context, next: WidgetPrayer?, now: Long): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_next)
        if (next == null) {
            views.setTextViewText(R.id.name, context.getString(R.string.app_name))
            views.setTextViewText(R.id.clock, "–")
            views.setViewVisibility(R.id.countdown, View.INVISIBLE)
        } else {
            views.setTextViewText(R.id.name, next.name)
            views.setTextViewText(R.id.clock, next.clock)
            countdown(views, R.id.countdown, next, now)
        }
        openApp(context)?.let { views.setOnClickPendingIntent(R.id.root, it) }
        return views
    }

    private fun wideViews(
        context: Context,
        prayers: List<WidgetPrayer>,
        next: WidgetPrayer?,
        now: Long,
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_timetable)
        views.setTextViewText(R.id.city, Store.text(context, "city", context.getString(R.string.app_name)))
        openApp(context)?.let { views.setOnClickPendingIntent(R.id.root, it) }

        if (next == null) {
            // The stored days have run out: the app was not opened for long.
            views.setTextViewText(R.id.next_name, Store.text(context, "openHint", ""))
            views.setViewVisibility(R.id.countdown, View.GONE)
            views.setViewVisibility(R.id.row, View.INVISIBLE)
            return views
        }

        views.setViewVisibility(R.id.row, View.VISIBLE)
        views.setTextViewText(R.id.next_name, next.name)
        countdown(views, R.id.countdown, next, now)

        // After Isha this is tomorrow, with its Fajr marked.
        val day = prayers.filter { it.day == next.day }
        for (slot in cells.indices) {
            val prayer = day.firstOrNull { it.slot == slot }
            val marked = prayer != null && prayer.time == next.time
            views.setTextViewText(names[slot], prayer?.name ?: "")
            views.setTextViewText(clocks[slot], prayer?.clock ?: "")
            views.setInt(cells[slot], "setBackgroundResource", if (marked) R.drawable.widget_pill else 0)
            views.setTextColor(names[slot], if (marked) WHITE else MUTED)
            views.setTextColor(clocks[slot], if (marked) WHITE else INK)
        }
        views.setTextColor(R.id.next_name, GREEN)
        return views
    }

    private fun scheduleRefresh(context: Context, at: Long) {
        val alarms = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val operation = PendingIntent.getBroadcast(
            context,
            0,
            Intent(context, WidgetRefreshReceiver::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val exact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarms.canScheduleExactAlarms()
        try {
            if (exact) {
                alarms.setExactAndAllowWhileIdle(AlarmManager.RTC, at, operation)
            } else {
                alarms.set(AlarmManager.RTC, at, operation)
            }
        } catch (e: SecurityException) {
            alarms.set(AlarmManager.RTC, at, operation)
        }
    }
}
