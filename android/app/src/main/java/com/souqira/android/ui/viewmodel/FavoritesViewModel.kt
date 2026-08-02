package com.souqira.android.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.souqira.android.data.model.BusinessListing
import com.souqira.android.data.repository.ListingsRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class FavoritesUiState(
    val isLoading: Boolean = false,
    val favorites: List<BusinessListing> = emptyList(),
    val errorMessage: String? = null
)

class FavoritesViewModel(private val repository: ListingsRepository) : ViewModel() {
    private val _uiState = MutableStateFlow(FavoritesUiState())
    val uiState: StateFlow<FavoritesUiState> = _uiState.asStateFlow()

    fun loadFavorites() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null) }
            repository.fetchFavorites()
                .onSuccess { listings ->
                    _uiState.update { it.copy(isLoading = false, favorites = listings) }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(isLoading = false, errorMessage = error.message ?: "Failed to load favorites")
                    }
                }
        }
    }

    fun toggleFavorite(listingId: String, isFavorite: Boolean) {
        viewModelScope.launch {
            repository.toggleFavorite(listingId = listingId, isFavorite = isFavorite)
                .onSuccess {
                    _uiState.update { state ->
                        state.copy(favorites = state.favorites.filterNot { it.id == listingId })
                    }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(errorMessage = error.message ?: "Failed to update favorites")
                    }
                }
        }
    }
}

class FavoritesViewModelFactory(private val repository: ListingsRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(FavoritesViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return FavoritesViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
