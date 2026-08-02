package com.souqira.android.data.repository

import android.util.Log
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.souqira.android.data.model.LoginRequest
import com.souqira.android.data.model.GoogleLoginRequest
import com.souqira.android.data.model.RegisterRequest
import com.souqira.android.data.model.User
import com.souqira.android.data.model.WhatsAppSendOtpRequest
import com.souqira.android.data.model.WhatsAppVerifyOtpRequest
import com.souqira.android.data.network.SouqiraApi
import com.souqira.android.data.network.TokenStore
import retrofit2.HttpException

class AuthRepository(
    private val api: SouqiraApi,
    private val tokenStore: TokenStore
) {
    private companion object {
        const val TAG = "SouqiraAuth"
    }

    suspend fun login(email: String, password: String): Result<User> {
        return try {
            val response = api.login(LoginRequest(usernameOrEmail = email.trim(), password = password))
            val auth = response.data ?: error(response.message ?: "Login failed")

            if (auth.requires2FA == true) {
                error("Two-factor authentication is required for this account")
            }

            val access = auth.accessToken ?: auth.token ?: auth.tokenadmin ?: auth.tempToken
            val refresh = auth.refreshToken ?: access

            if (access.isNullOrBlank() || refresh.isNullOrBlank()) {
                error(response.message ?: "Login failed")
            }

            tokenStore.saveTokens(access, refresh)
            Result.success(auth.user)
        } catch (error: Throwable) {
            Result.failure(mapAuthError(error, fallback = "Login failed"))
        }
    }

    suspend fun register(
        username: String,
        email: String,
        password: String,
        confirmPassword: String = password
    ): Result<String> {
        return runCatching {
            val response = api.register(
                RegisterRequest(
                    username = username.trim(),
                    email = email.trim(),
                    password = password,
                    confirmPassword = confirmPassword
                )
            )
            response.message ?: "Registration successful"
        }
    }

    suspend fun hasStoredSession(): Boolean {
        return !tokenStore.getAccessToken().isNullOrBlank()
    }

    suspend fun getCurrentUser(): Result<User> {
        return runCatching {
            val response = api.getCurrentUser()
            response.data ?: error(response.message ?: "Could not load profile")
        }
    }

    suspend fun loginWithGoogleIdToken(idToken: String): Result<User> {
        return try {
            Log.d(TAG, "Calling backend Google token login. idTokenLength=${idToken.length}")
            val response = api.loginWithGoogle(GoogleLoginRequest(token = idToken, idToken = idToken))
            val auth = response.data ?: error(response.message ?: "Google login failed")
            val access = auth.accessToken ?: auth.token ?: auth.tokenadmin ?: auth.tempToken
            val refresh = auth.refreshToken ?: access
            if (access.isNullOrBlank() || refresh.isNullOrBlank()) {
                error(response.message ?: "Google login failed")
            }
            tokenStore.saveTokens(access, refresh)
            Result.success(auth.user)
        } catch (error: Throwable) {
            Log.e(TAG, "Google backend login failed: ${error.message}", error)
            Result.failure(mapAuthError(error, fallback = "Google login failed"))
        }
    }

    suspend fun sendWhatsAppOtp(phoneNumber: String): Result<String> {
        return try {
            val response = api.sendWhatsAppOtp(WhatsAppSendOtpRequest(phoneNumber = phoneNumber.trim()))
            Result.success(response.message ?: "Verification code sent")
        } catch (error: Throwable) {
            Result.failure(mapAuthError(error, fallback = "Could not send verification code"))
        }
    }

    suspend fun verifyWhatsAppOtp(phoneNumber: String, otp: String): Result<User> {
        return try {
            val response = api.verifyWhatsAppOtp(
                WhatsAppVerifyOtpRequest(phoneNumber = phoneNumber.trim(), otp = otp.trim())
            )
            val auth = response.data ?: error(response.message ?: "WhatsApp login failed")
            val access = auth.accessToken ?: auth.token ?: auth.tokenadmin ?: auth.tempToken
            val refresh = auth.refreshToken ?: access

            if (access.isNullOrBlank() || refresh.isNullOrBlank()) {
                error(response.message ?: "WhatsApp login failed")
            }

            tokenStore.saveTokens(access, refresh)
            Result.success(auth.user)
        } catch (error: Throwable) {
            Result.failure(mapAuthError(error, fallback = "WhatsApp login failed"))
        }
    }

    suspend fun logout() {
        tokenStore.clearTokens()
    }

    suspend fun deleteAccount(force: Boolean = true): Result<String> {
        return runCatching {
            val response = api.deleteAccount(force = force)
            tokenStore.clearTokens()
            response.message ?: "Account deleted successfully"
        }
    }

    private fun mapAuthError(error: Throwable, fallback: String): Throwable {
        if (error !is HttpException) {
            Log.e(TAG, "Non-HTTP auth error: ${error::class.java.simpleName}: ${error.message}", error)
            return error
        }

        val raw = error.response()?.errorBody()?.string().orEmpty()
        Log.e(
            TAG,
            "HTTP auth error status=${error.code()} body=${raw.take(1200)}"
        )

        val message = runCatching {
            val json = Gson().fromJson(raw, JsonObject::class.java)

            when {
                json.has("message") && !json.get("message").isJsonNull -> json.get("message").asString
                json.has("error") && json.get("error").isJsonObject -> {
                    val nested = json.getAsJsonObject("error")
                    if (nested.has("message") && !nested.get("message").isJsonNull) {
                        nested.get("message").asString
                    } else {
                        null
                    }
                }
                else -> null
            }
        }.getOrNull()

        return IllegalStateException(message ?: fallback)
    }
}
