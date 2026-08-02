package com.souqira.android.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.souqira.android.data.model.Conversation
import com.souqira.android.data.model.Message
import com.souqira.android.data.repository.MessagesRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class MessagesUiState(
    val isLoading: Boolean = false,
    val conversations: List<Conversation> = emptyList(),
    val messages: List<Message> = emptyList(),
    val selectedConversationId: String? = null,
    val errorMessage: String? = null
)

class MessagesViewModel(private val repository: MessagesRepository) : ViewModel() {
    private val _uiState = MutableStateFlow(MessagesUiState())
    val uiState: StateFlow<MessagesUiState> = _uiState.asStateFlow()

    fun loadConversations() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null) }
            repository.getConversations()
                .onSuccess { conversations ->
                    _uiState.update { it.copy(isLoading = false, conversations = conversations) }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(isLoading = false, errorMessage = error.message ?: "Could not load chats")
                    }
                }
        }
    }

    fun openConversation(partnerId: String) {
        viewModelScope.launch {
            _uiState.update {
                it.copy(isLoading = true, selectedConversationId = partnerId, errorMessage = null)
            }
            repository.getMessages(partnerId)
                .onSuccess { messages ->
                    _uiState.update { it.copy(isLoading = false, messages = messages) }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(isLoading = false, errorMessage = error.message ?: "Could not load messages")
                    }
                }
        }
    }

    fun closeConversation() {
        _uiState.update { it.copy(selectedConversationId = null, messages = emptyList(), errorMessage = null) }
    }

    fun sendMessage(message: String) {
        val receiverId = _uiState.value.selectedConversationId ?: return
        if (message.isBlank()) return

        viewModelScope.launch {
            repository.sendMessage(receiverId, message)
                .onSuccess { sent ->
                    _uiState.update { it.copy(messages = it.messages + sent) }
                    loadConversations()
                }
                .onFailure { error ->
                    _uiState.update { it.copy(errorMessage = error.message ?: "Could not send message") }
                }
        }
    }
}

class MessagesViewModelFactory(private val repository: MessagesRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(MessagesViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return MessagesViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
