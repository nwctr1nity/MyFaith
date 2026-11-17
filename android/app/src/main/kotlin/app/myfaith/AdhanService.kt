package app.myfaith

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.drawable.Icon
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.VolumeProvider
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.os.Build
import android.os.IBinder
import android.os.PowerManager

/**
 * Plays the adhan recording itself instead of leaving it to a notification
 * sound, which Android cuts off at the first press of a volume key. While
 * it plays, the volume keys change the alarm volume and the notification
 * carries a Stop button.
 */
class AdhanService : Service() {
    private var player: MediaPlayer? = null
    private var session: MediaSession? = null
    private var focusRequest: AudioFocusRequest? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null || intent.action == ACTION_STOP) {
            finish(null)
            return START_NOT_STICKY
        }
        val title = intent.getStringExtra(EXTRA_TITLE).orEmpty()
        val body = intent.getStringExtra(EXTRA_BODY).orEmpty()
        val fajr = intent.getBooleanExtra(EXTRA_FAJR, false)
        val sound = intent.getStringExtra(EXTRA_SOUND).orEmpty()

        val playing = notification(this, title, body, playing = true)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(PLAYING_ID, playing, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(PLAYING_ID, playing)
        }

        try {
            val file = recording(sound, fajr)
            Store.log(
                this,
                "play $title fajr=$fajr asked=$sound file=${resources.getResourceEntryName(file)}",
            )
            play(file, notification(this, title, body, playing = false))
        } catch (e: Exception) {
            Store.log(this, "failed $e")
            finish(notification(this, title, body, playing = false))
        }
        return START_NOT_STICKY
    }

    /**
     * The recording chosen in the app, by its name in res/raw. An unknown
     * name (a schedule saved by an older version) gives the default set.
     */
    private fun recording(sound: String, fajr: Boolean): Int {
        fun find(name: String) =
            if (name.isEmpty()) 0 else resources.getIdentifier(name, "raw", packageName)
        val id = find(sound)
        return if (id != 0) id else find(if (fajr) "azan_doha_fajr" else "azan_doha_dhuhr")
    }

    private fun play(recording: Int, whenDone: Notification) {
        releasePlayer()
        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .build()
        val audio = getSystemService(Context.AUDIO_SERVICE) as AudioManager

        // Other sound pauses for the adhan and resumes after it.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                .setAudioAttributes(attributes)
                .build()
            audio.requestAudioFocus(request)
            focusRequest = request
        }

        val media = MediaPlayer()
        player = media
        media.setAudioAttributes(attributes)
        val file = resources.openRawResourceFd(recording)
        try {
            media.setDataSource(file.fileDescriptor, file.startOffset, file.length)
        } finally {
            file.close()
        }
        // Keeps the processor awake until the recording ends.
        media.setWakeMode(applicationContext, PowerManager.PARTIAL_WAKE_LOCK)
        media.setOnCompletionListener { finish(whenDone) }
        media.setOnErrorListener { _, _, _ ->
            finish(whenDone)
            true
        }
        media.prepare()
        media.start()

        startSession(audio)
    }

    /**
     * An active media session receives the volume keys, also on the lock
     * screen. They are passed on to the alarm volume, which is the one the
     * adhan plays at.
     */
    private fun startSession(audio: AudioManager) {
        try {
            val media = MediaSession(this, "adhan")
            media.setPlaybackState(
                PlaybackState.Builder()
                    .setState(PlaybackState.STATE_PLAYING, 0L, 1f)
                    .setActions(PlaybackState.ACTION_STOP or PlaybackState.ACTION_PAUSE)
                    .build(),
            )
            media.setCallback(object : MediaSession.Callback() {
                override fun onStop() = finish(null)
                override fun onPause() = finish(null)
            })
            val stream = AudioManager.STREAM_ALARM
            media.setPlaybackToRemote(
                object : VolumeProvider(
                    VolumeProvider.VOLUME_CONTROL_RELATIVE,
                    audio.getStreamMaxVolume(stream),
                    audio.getStreamVolume(stream),
                ) {
                    override fun onAdjustVolume(direction: Int) {
                        audio.adjustStreamVolume(stream, direction, AudioManager.FLAG_SHOW_UI)
                        setCurrentVolume(audio.getStreamVolume(stream))
                    }
                },
            )
            media.isActive = true
            session = media
        } catch (e: Exception) {
            // Without the session the adhan still plays; the volume keys
            // then change whichever volume Android picks.
        }
    }

    private fun releasePlayer() {
        player?.let {
            it.setOnCompletionListener(null)
            try {
                it.stop()
            } catch (e: IllegalStateException) {
                // Not started yet.
            }
            it.release()
        }
        player = null
        session?.let {
            it.isActive = false
            it.release()
        }
        session = null
        val request = focusRequest
        if (request != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            (getSystemService(Context.AUDIO_SERVICE) as AudioManager).abandonAudioFocusRequest(request)
        }
        focusRequest = null
    }

    /** Stops playback. [leftBehind] stays in the shade as a record of the prayer time. */
    private fun finish(leftBehind: Notification?) {
        releasePlayer()
        stopForeground(STOP_FOREGROUND_REMOVE)
        if (leftBehind != null) {
            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                .notify(DONE_ID, leftBehind)
        }
        stopSelf()
    }

    override fun onDestroy() {
        releasePlayer()
        super.onDestroy()
    }

    companion object {
        private const val ACTION_STOP = "app.myfaith.STOP_ADHAN"
        private const val EXTRA_TITLE = "title"
        private const val EXTRA_BODY = "body"
        private const val EXTRA_FAJR = "fajr"
        private const val EXTRA_SOUND = "sound"
        private const val CHANNEL = "adhan_playing_v1"
        private const val PLAYING_ID = 7001
        private const val DONE_ID = 7002

        fun start(context: Context, title: String, body: String, fajr: Boolean, sound: String) {
            val intent = Intent(context, AdhanService::class.java)
                .putExtra(EXTRA_TITLE, title)
                .putExtra(EXTRA_BODY, body)
                .putExtra(EXTRA_FAJR, fajr)
                .putExtra(EXTRA_SOUND, sound)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        /** Announces a prayer time without the recording. */
        fun notifySilently(context: Context, title: String, body: String) {
            (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                .notify(DONE_ID, notification(context, title, body, playing = false))
        }

        private fun notification(
            context: Context,
            title: String,
            body: String,
            playing: Boolean,
        ): Notification {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // The service plays the sound, so the channel has none.
                val channel = NotificationChannel(
                    CHANNEL,
                    Store.text(context, "channelName", "Adhan"),
                    NotificationManager.IMPORTANCE_HIGH,
                )
                channel.setSound(null, null)
                channel.enableVibration(false)
                channel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                manager.createNotificationChannel(channel)
                Notification.Builder(context, CHANNEL)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(context).setPriority(Notification.PRIORITY_HIGH)
            }

            val immutable = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launch != null) {
                builder.setContentIntent(PendingIntent.getActivity(context, 0, launch, immutable))
            }
            builder
                .setSmallIcon(R.drawable.ic_notification)
                .setContentTitle(title)
                .setContentText(body)
                .setCategory(Notification.CATEGORY_ALARM)
                .setVisibility(Notification.VISIBILITY_PUBLIC)
                .setShowWhen(true)
                .setAutoCancel(!playing)

            if (playing) {
                val stop = PendingIntent.getService(
                    context,
                    1,
                    Intent(context, AdhanService::class.java).setAction(ACTION_STOP),
                    immutable,
                )
                builder
                    .setOngoing(true)
                    // Swiping the notification away also stops the adhan.
                    .setDeleteIntent(stop)
                    .addAction(
                        Notification.Action.Builder(
                            Icon.createWithResource(context, R.drawable.ic_notification),
                            Store.text(context, "stopLabel", "Stop"),
                            stop,
                        ).build(),
                    )
            }
            return builder.build()
        }
    }
}
