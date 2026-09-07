package com.example.quick_commerce_seller

import android.util.Log
import com.google.firebase.messaging.RemoteMessage
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService

/**
 * Sees every push before Flutter does, so the ringtone can start while the app
 * is backgrounded or killed — the states where the Dart isolate is not running
 * and an in-app player therefore cannot begin.
 *
 * It never suppresses anything: `super.onMessageReceived` is always called, so
 * the tray notification and the Dart handlers behave exactly as before. The
 * only thing added here is starting and stopping the alarm.
 */
class SellerMessagingService : FlutterFirebaseMessagingService() {

    override fun onMessageReceived(message: RemoteMessage) {
        val data = message.data
        val type = data["type"].orEmpty()
        Log.d(TAG, "MESSAGE RECEIVED (native) type=$type")

        when (type) {
            TYPE_NEW_ORDER -> {
                // orderId is the Mongo id; orderDisplayId is the readable code
                // and would not match anything the app can act on.
                val orderId = data["orderId"].takeUnless { it.isNullOrBlank() }
                    ?: data["orderMongoId"].orEmpty()

                if (orderId.isBlank()) {
                    Log.w(TAG, "new_order push with no order id — not ringing")
                } else {
                    NewOrderAlarmService.start(this, orderId)
                }
            }

            // The order stopped being the seller's to answer. Nobody is going
            // to press Accept now, so the ringing has to end on its own.
            TYPE_ORDER_CANCELLED, TYPE_ORDER_TAKEN, TYPE_ORDER_EXPIRED -> {
                Log.d(TAG, "order withdrawn ($type) — stopping ringtone")
                NewOrderAlarmService.stop(this)
            }
        }

        super.onMessageReceived(message)
    }

    private companion object {
        const val TAG = "FCM"
        const val TYPE_NEW_ORDER = "new_order"
        const val TYPE_ORDER_CANCELLED = "order_cancelled"
        const val TYPE_ORDER_TAKEN = "order_taken"
        const val TYPE_ORDER_EXPIRED = "order_expired"
    }
}
