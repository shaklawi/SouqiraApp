package com.souqira.android.services

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.content.ContextCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.messaging.FirebaseMessaging
import com.souqira.android.R
import com.souqira.android.data.model.DeviceTokenRequest
import com.souqira.android.data.network.NetworkModule
import com.souqira.android.data.network.TokenStore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

object PushNotificationRegistrar {
    private const val TAG = "PushRegistrar"
    private const val CHANNEL_ID = "souqira_general_notifications"
    private const val CHANNEL_NAME = "Souqira Notifications"

    fun syncTokenIfAuthenticated(context: Context) {
        CoroutineScope(Dispatchers.IO).launch {
            val tokenStore = TokenStore(context)
            val accessToken = tokenStore.getAccessToken()

            runCatching {
                val token = FirebaseMessaging.getInstance().token.await()
                if (token.isBlank()) {
                    return@runCatching
                }

                val api = NetworkModule.createApi(context)
                api.registerPublicDeviceToken(DeviceTokenRequest(token = token, platform = "android"))

                if (!accessToken.isNullOrBlank()) {
                    api.registerDeviceToken(DeviceTokenRequest(token = token, platform = "android"))
                }

                Log.d(TAG, "FCM token synced to backend (public/auth as available)")
            }.onFailure {
                Log.e(TAG, "Failed to sync FCM token", it)
            }
        }
    }

    fun showIncomingNotification(context: Context, title: String, body: String) {
        ensureNotificationChannel(context)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val granted = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
            if (!granted) {
                Log.w(TAG, "Skipping notification: POST_NOTIFICATIONS not granted")
                return
            }
        }

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()

        NotificationManagerCompat.from(context).notify((System.currentTimeMillis() % Int.MAX_VALUE).toInt(), notification)
    }

    private fun ensureNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val existing = manager.getNotificationChannel(CHANNEL_ID)
        if (existing != null) {
            return
        }

        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_HIGH
        )
        manager.createNotificationChannel(channel)
    }
}
