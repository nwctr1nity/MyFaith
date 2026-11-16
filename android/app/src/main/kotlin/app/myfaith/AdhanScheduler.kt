package app.myfaith

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/** Sets one exact alarm per stored adhan. */
object AdhanScheduler {
    private const val ACTION = "app.myfaith.ADHAN"
    private const val EXTRA_ID = "id"

    /** An adhan that could not start within this time is skipped. */
    const val LATE_LIMIT_MS = 10 * 60 * 1000L

    private fun pending(context: Context, id: Int): PendingIntent {
        val intent = Intent(context, AdhanReceiver::class.java)
            .setAction(ACTION)
            .putExtra(EXTRA_ID, id)
        return PendingIntent.getBroadcast(
            context,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    fun idOf(intent: Intent): Int = intent.getIntExtra(EXTRA_ID, -1)

    /** Cancels what was set before and sets the stored adhans. Returns how many. */
    fun reschedule(context: Context): Int {
        val alarms = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val prefs = Store.prefs(context)
        for (old in prefs.getStringSet("scheduledIds", emptySet()) ?: emptySet()) {
            val id = old.toIntOrNull() ?: continue
            alarms.cancel(pending(context, id))
        }

        val now = System.currentTimeMillis()
        val exact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarms.canScheduleExactAlarms()
        val ids = HashSet<String>()
        for (adhan in Store.adhans(context)) {
            if (adhan.time <= now) continue
            val operation = pending(context, adhan.id)
            try {
                if (exact) {
                    alarms.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, adhan.time, operation)
                } else {
                    alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, adhan.time, operation)
                }
            } catch (e: SecurityException) {
                // The exact-alarm permission was withdrawn between the check
                // and the call.
                alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, adhan.time, operation)
            }
            ids.add(adhan.id.toString())
        }
        prefs.edit().putStringSet("scheduledIds", ids).apply()
        return ids.size
    }
}

class AdhanReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = AdhanScheduler.idOf(intent)
        val adhan = Store.adhans(context).firstOrNull { it.id == id }
        if (adhan != null &&
            System.currentTimeMillis() - adhan.time < AdhanScheduler.LATE_LIMIT_MS
        ) {
            try {
                AdhanService.start(context, adhan.title, adhan.body, adhan.fajr, adhan.sound)
            } catch (e: Exception) {
                // Android refused to start playback from the background
                // (an inexact alarm does not carry that right). The prayer
                // time is still announced, without the recording.
                AdhanService.notifySilently(context, adhan.title, adhan.body)
            }
        }
        WidgetUpdater.updateAll(context)
    }
}

/** Alarms do not survive a restart, and a clock change moves every time. */
class RestoreReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        AdhanScheduler.reschedule(context)
        WidgetUpdater.updateAll(context)
    }
}
