package com.souqira.android

import android.app.Application
import com.souqira.android.domain.AppContainer
import com.souqira.android.services.PushNotificationRegistrar
import kotlinx.coroutines.runBlocking

class SouqiraApplication : Application() {
    lateinit var appContainer: AppContainer
        private set

    override fun onCreate() {
        super.onCreate()
        appContainer = AppContainer(applicationContext)
        runBlocking {
            appContainer.initializeLocale()
        }
        PushNotificationRegistrar.syncTokenIfAuthenticated(applicationContext)
    }
}
