package com.souqira.android.data.network

import android.content.Context
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.MutablePreferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map

private val Context.dataStore by preferencesDataStore(name = "souqira_tokens")

class TokenStore(private val context: Context) {
    private val accessTokenKey = stringPreferencesKey("access_token")
    private val refreshTokenKey = stringPreferencesKey("refresh_token")

    val accessTokenFlow: Flow<String?> = context.dataStore.data.map { it[accessTokenKey] }

    suspend fun saveTokens(accessToken: String, refreshToken: String) {
        context.dataStore.edit { prefs: MutablePreferences ->
            prefs[accessTokenKey] = accessToken
            prefs[refreshTokenKey] = refreshToken
        }
    }

    suspend fun clearTokens() {
        context.dataStore.edit { prefs: MutablePreferences ->
            prefs.remove(accessTokenKey)
            prefs.remove(refreshTokenKey)
        }
    }

    suspend fun getAccessToken(): String? {
        return accessTokenFlow.first()
    }

    suspend fun hasAccessToken(): Boolean {
        return !getAccessToken().isNullOrBlank()
    }
}
