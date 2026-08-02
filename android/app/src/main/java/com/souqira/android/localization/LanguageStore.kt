package com.souqira.android.localization

import android.content.Context
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map

private val Context.languageDataStore by preferencesDataStore(name = "souqira_settings")

class LanguageStore(private val context: Context) {
    private val languageKey = stringPreferencesKey("app_language")
    private val termsAcceptedKey = booleanPreferencesKey("terms_accepted")

    val languageFlow: Flow<String> = context.languageDataStore.data.map {
        normalizeLanguage(it[languageKey])
    }

    val termsAcceptedFlow: Flow<Boolean> = context.languageDataStore.data.map {
        it[termsAcceptedKey] ?: false
    }

    suspend fun getLanguage(): String {
        return normalizeLanguage(context.languageDataStore.data.first()[languageKey])
    }

    suspend fun setLanguage(language: String) {
        val normalized = normalizeLanguage(language)
        context.languageDataStore.edit { prefs ->
            prefs[languageKey] = normalized
        }
    }

    suspend fun setTermsAccepted() {
        context.languageDataStore.edit { prefs ->
            prefs[termsAcceptedKey] = true
        }
    }

    private fun normalizeLanguage(language: String?): String {
        return when (language?.lowercase()) {
            "ar" -> "ar"
            "ku" -> "ku"
            else -> "en"
        }
    }
}