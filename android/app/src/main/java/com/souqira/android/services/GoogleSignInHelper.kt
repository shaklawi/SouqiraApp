@file:Suppress("DEPRECATION")

package com.souqira.android.services

import android.content.Context
import android.content.Intent
import android.util.Log
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.souqira.android.BuildConfig

object GoogleSignInHelper {
    private const val TAG = "SouqiraAuth"
    private const val KNOWN_DEBUG_SHA1 = "68:F6:5D:9E:C3:27:ED:60:14:4F:28:BF:0A:60:DB:A7:C7:0A:7C:08"

    @Suppress("DEPRECATION")
    fun buildSignInIntent(context: Context): Intent {
        val webClientId = context.getString(com.souqira.android.R.string.google_web_client_id)
        Log.d(TAG, "Starting Google Sign-In with webClientId=${webClientId.take(18)}...")
        check(webClientId.isNotBlank() && webClientId != "REPLACE_WITH_WEB_CLIENT_ID") {
            "Missing google_web_client_id in strings.xml"
        }

        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .requestIdToken(webClientId)
            .build()

        val client = GoogleSignIn.getClient(context, gso)
        client.signOut()
        return client.signInIntent
    }

    @Suppress("DEPRECATION")
    fun extractIdToken(data: Intent?): Result<String> {
        return runCatching {
            if (data == null) {
                throw IllegalStateException("Google login blev annulleret.")
            }
            val task = GoogleSignIn.getSignedInAccountFromIntent(data)
            val account = try {
                task.getResult(ApiException::class.java)
            } catch (e: ApiException) {
                Log.e(TAG, "Google Sign-In ApiException statusCode=${e.statusCode}, message=${e.localizedMessage}", e)
                throw IllegalStateException(readableGoogleError(e))
            }
            account.idToken?.also {
                Log.d(TAG, "Google Sign-In returned idToken length=${it.length}")
            } ?: error("No ID token returned by Google")
        }
    }

    private fun readableGoogleError(error: ApiException): String {
        return when (error.statusCode) {
            10 -> {
                val appId = BuildConfig.APPLICATION_ID
                val shaHint = if (BuildConfig.DEBUG) {
                    "Debug SHA-1: '$KNOWN_DEBUG_SHA1'."
                } else {
                    "Brug SHA-1 fra Play App Signing certifikatet (Play Console -> App integrity), " +
                        "ikke debug/upload SHA alene."
                }

                "Google login er ikke konfigureret korrekt (ApiException 10). " +
                    "I Google Cloud Console skal du have en Android OAuth client med package '$appId'. " +
                    "$shaHint " +
                    "Sørg også for at google_web_client_id peger på web client fra samme Google-projekt."
            }

            12500 -> "Google login afvist af Google-konfiguration (12500). Tjek OAuth consent screen og client setup."
            12501 -> "Google login blev annulleret."
            7 -> "Ingen netforbindelse til Google Sign-In."
            else -> "Google sign-in failed (code ${error.statusCode}): ${error.localizedMessage ?: "Unknown error"}"
        }
    }
}
