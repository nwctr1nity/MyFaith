package app.myfaith

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONException

/** One adhan to play at [time] (epoch milliseconds). */
data class Adhan(
    val id: Int,
    val time: Long,
    val title: String,
    val body: String,
    val fajr: Boolean,
    /** The recording to play, a name in res/raw; empty for the default. */
    val sound: String,
)

/** One prayer time for the widgets, with its texts already localized. */
data class WidgetPrayer(
    val time: Long,
    /** Calendar day in the place's zone, the same for all prayers of a day. */
    val day: String,
    /** 0 Fajr, 1 sunrise, 2 Dhuhr, 3 Asr, 4 Maghrib, 5 Isha. */
    val slot: Int,
    val name: String,
    val clock: String,
)

/**
 * What the Flutter side last sent. The alarm receiver, the service and the
 * widgets all run without the Flutter engine, so they read it from here.
 */
object Store {
    private const val PREFS = "myfaith_native"

    fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun save(
        context: Context,
        adhans: String,
        prayers: String,
        city: String,
        stopLabel: String,
        channelName: String,
        openHint: String,
    ) {
        prefs(context).edit()
            .putString("adhans", adhans)
            .putString("prayers", prayers)
            .putString("city", city)
            .putString("stopLabel", stopLabel)
            .putString("channelName", channelName)
            .putString("openHint", openHint)
            .apply()
    }

    /**
     * A short journal of what the adhan code did, newest last. It is the
     * only way to learn what happened on a phone at a prayer time nobody
     * was watching; the app copies it out on request.
     */
    fun log(context: Context, line: String) {
        val stamp = java.text.SimpleDateFormat("MM-dd HH:mm:ss", java.util.Locale.US)
            .format(java.util.Date())
        val kept = journal(context).lines().filter { it.isNotEmpty() }.takeLast(59)
        prefs(context).edit()
            .putString("journal", (kept + "$stamp $line").joinToString("\n"))
            .apply()
    }

    fun journal(context: Context): String = prefs(context).getString("journal", "") ?: ""

    fun text(context: Context, key: String, fallback: String): String =
        prefs(context).getString(key, null)?.takeIf { it.isNotEmpty() } ?: fallback

    fun adhans(context: Context): List<Adhan> {
        val list = ArrayList<Adhan>()
        try {
            val array = JSONArray(prefs(context).getString("adhans", "[]"))
            for (i in 0 until array.length()) {
                val o = array.getJSONObject(i)
                list.add(
                    Adhan(
                        id = o.getInt("id"),
                        time = o.getLong("t"),
                        title = o.optString("title"),
                        body = o.optString("body"),
                        fajr = o.optBoolean("fajr"),
                        sound = o.optString("sound"),
                    ),
                )
            }
        } catch (e: JSONException) {
            // A damaged value means nothing is scheduled until the next sync.
        }
        return list
    }

    fun prayers(context: Context): List<WidgetPrayer> {
        val list = ArrayList<WidgetPrayer>()
        try {
            val array = JSONArray(prefs(context).getString("prayers", "[]"))
            for (i in 0 until array.length()) {
                val o = array.getJSONObject(i)
                list.add(
                    WidgetPrayer(
                        time = o.getLong("t"),
                        day = o.optString("day"),
                        slot = o.optInt("slot"),
                        name = o.optString("name"),
                        clock = o.optString("clock"),
                    ),
                )
            }
        } catch (e: JSONException) {
            // The widgets show the "open the app" hint.
        }
        list.sortBy { it.time }
        return list
    }
}
