package app.myfaith

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.myfaith/native")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        // Replaces the adhan schedule and the data the
                        // home-screen widgets draw from.
                        "sync" -> {
                            Store.save(
                                this,
                                adhans = call.argument<String>("adhans") ?: "[]",
                                prayers = call.argument<String>("prayers") ?: "[]",
                                city = call.argument<String>("city") ?: "",
                                stopLabel = call.argument<String>("stopLabel") ?: "Stop",
                                channelName = call.argument<String>("channelName") ?: "Adhan",
                                openHint = call.argument<String>("openHint") ?: "",
                            )
                            val scheduled = AdhanScheduler.reschedule(this)
                            WidgetUpdater.updateAll(this)
                            result.success(scheduled)
                        }
                        "play" -> {
                            AdhanService.start(
                                this,
                                call.argument<String>("title") ?: "",
                                call.argument<String>("body") ?: "",
                                call.argument<Boolean>("fajr") ?: false,
                                call.argument<String>("sound") ?: "",
                            )
                            result.success(null)
                        }
                        "stop" -> {
                            stopService(android.content.Intent(this, AdhanService::class.java))
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("native", e.toString(), null)
                }
            }
    }
}
