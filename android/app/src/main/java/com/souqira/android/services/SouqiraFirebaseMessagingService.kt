package com.souqira.android.services

import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class SouqiraFirebaseMessagingService : FirebaseMessagingService() {
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d("SouqiraFCM", "New FCM token received")
        PushNotificationRegistrar.syncTokenIfAuthenticated(applicationContext)
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        val title = remoteMessage.notification?.title ?: "Souqira"
        val body = remoteMessage.notification?.body
            ?: remoteMessage.data["message"]
            ?: "Du har en ny notifikation"

        PushNotificationRegistrar.showIncomingNotification(applicationContext, title, body)
    }
}
