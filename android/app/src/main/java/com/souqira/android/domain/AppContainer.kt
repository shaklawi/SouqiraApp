package com.souqira.android.domain

import android.content.Context
import com.souqira.android.data.network.NetworkModule
import com.souqira.android.data.network.TokenStore
import com.souqira.android.data.repository.AuthRepository
import com.souqira.android.data.repository.ListingsRepository
import com.souqira.android.data.repository.MessagesRepository
import com.souqira.android.localization.LanguageStore
import com.souqira.android.localization.LocaleManager

class AppContainer(context: Context) {
    private val appContext = context.applicationContext
    private val api = NetworkModule.createApi(context)
    private val tokenStore = TokenStore(context)
    val languageStore = LanguageStore(context)

    val authRepository = AuthRepository(api, tokenStore)
    val listingsRepository = ListingsRepository(api)
    val messagesRepository = MessagesRepository(api)

    suspend fun initializeLocale() {
        LocaleManager.initialize(languageStore, appContext)
    }
}
