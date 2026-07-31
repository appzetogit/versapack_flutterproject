package com.fooddelivery.app

import android.app.KeyguardManager
import android.content.Context
import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app.fooddelivery/unlock"
    private val ONLINE_CHANNEL = "app.fooddelivery/rider_online"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "unlockScreen") {
                unlockScreen()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ONLINE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Failures are reported rather than thrown: going online must
                    // not be blocked by the service. A rider whose OEM refuses the
                    // foreground service still needs to take orders — they just
                    // lose the keep-alive guarantee.
                    "start" -> {
                        try {
                            RiderOnlineService.start(applicationContext)
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    "stop" -> {
                        try {
                            RiderOnlineService.stop(applicationContext)
                        } catch (_: Exception) {
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun unlockScreen() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(true)
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
            window.addFlags(
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or 
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
    }
}
