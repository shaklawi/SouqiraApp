package com.souqira.android.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.souqira.android.data.model.User
import com.souqira.android.data.repository.AuthRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class AuthUiState(
    val isLoading: Boolean = false,
    val isAuthenticated: Boolean = false,
    val user: User? = null,
    val errorMessage: String? = null,
    val statusMessage: String? = null,
    val otpSent: Boolean = false
)

class AuthViewModel(private val repository: AuthRepository) : ViewModel() {
    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    fun bootstrap() {
        viewModelScope.launch {
            repository.getCurrentUser()
                .onSuccess { user ->
                    _uiState.update { it.copy(isAuthenticated = true, user = user, errorMessage = null) }
                }
                .onFailure {
                    _uiState.update { it.copy(isAuthenticated = false, user = null) }
                }
        }
    }

    fun login(email: String, password: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null, statusMessage = null) }
            repository.login(email, password)
                .onSuccess { user ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            isAuthenticated = true,
                            user = user,
                            errorMessage = null,
                            statusMessage = null
                        )
                    }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            errorMessage = error.message ?: "Login failed",
                            isAuthenticated = false
                        )
                    }
                }
        }
    }

    fun register(username: String, email: String, password: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null, statusMessage = null) }
            repository.register(username = username, email = email, password = password)
                .onSuccess { message ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            isAuthenticated = false,
                            user = null,
                            errorMessage = null,
                            statusMessage = message
                        )
                    }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(isLoading = false, errorMessage = error.message ?: "Registration failed")
                    }
                }
        }
    }

    fun loginWithGoogleIdToken(idToken: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null, statusMessage = null) }
            repository.loginWithGoogleIdToken(idToken)
                .onSuccess { user ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            isAuthenticated = true,
                            user = user,
                            errorMessage = null,
                            statusMessage = null
                        )
                    }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(isLoading = false, errorMessage = error.message ?: "Google login failed")
                    }
                }
        }
    }

    fun sendWhatsAppOtp(phoneNumber: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null, statusMessage = null) }
            repository.sendWhatsAppOtp(phoneNumber)
                .onSuccess { message ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            otpSent = true,
                            statusMessage = message,
                            errorMessage = null
                        )
                    }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            otpSent = false,
                            errorMessage = error.message ?: "Could not send verification code"
                        )
                    }
                }
        }
    }

    fun loginWithWhatsAppOtp(phoneNumber: String, otp: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null, statusMessage = null) }
            repository.verifyWhatsAppOtp(phoneNumber, otp)
                .onSuccess { user ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            isAuthenticated = true,
                            user = user,
                            errorMessage = null,
                            statusMessage = null
                        )
                    }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            isAuthenticated = false,
                            errorMessage = error.message ?: "WhatsApp login failed"
                        )
                    }
                }
        }
    }

    fun logout() {
        viewModelScope.launch {
            repository.logout()
            _uiState.value = AuthUiState()
        }
    }

    fun deleteAccount(force: Boolean = true) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null, statusMessage = null) }
            repository.deleteAccount(force = force)
                .onSuccess { message ->
                    _uiState.value = AuthUiState(statusMessage = message)
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            errorMessage = error.message ?: "Could not delete account"
                        )
                    }
                }
        }
    }

    fun setError(message: String) {
        _uiState.update { it.copy(errorMessage = message, statusMessage = null, isLoading = false) }
    }
}

class AuthViewModelFactory(private val repository: AuthRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(AuthViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return AuthViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
