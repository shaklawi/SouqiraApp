package com.souqira.android.localization

import android.content.Context
import android.content.res.Configuration
import java.util.Locale

object LocaleManager {
    @Volatile
    private var currentLanguage: String = "en"

    suspend fun initialize(languageStore: LanguageStore, context: Context) {
        val saved = languageStore.getLanguage()
        applyLanguage(context, saved)
    }

    suspend fun setLanguage(languageStore: LanguageStore, context: Context, language: String) {
        val normalized = normalize(language)
        languageStore.setLanguage(normalized)
        applyLanguage(context, normalized)
    }

    fun currentLanguage(): String = currentLanguage

    private fun applyLanguage(context: Context, language: String) {
        currentLanguage = normalize(language)
        val locale = Locale(currentLanguage)
        Locale.setDefault(locale)

        val config = Configuration(context.resources.configuration)
        config.setLocale(locale)
        context.createConfigurationContext(config)
    }

    private fun normalize(language: String?): String {
        return when (language?.lowercase()) {
            "ar" -> "ar"
            "ku" -> "ku"
            else -> "en"
        }
    }
}