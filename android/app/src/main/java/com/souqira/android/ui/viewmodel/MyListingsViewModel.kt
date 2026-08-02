package com.souqira.android.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.google.gson.JsonElement
import com.souqira.android.data.model.BusinessListing
import com.souqira.android.data.repository.ListingsRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class MyListingsUiState(
    val isLoading: Boolean = false,
    val listings: List<BusinessListing> = emptyList(),
    val errorMessage: String? = null
)

class MyListingsViewModel(private val repository: ListingsRepository) : ViewModel() {
    private val _uiState = MutableStateFlow(MyListingsUiState())
    val uiState: StateFlow<MyListingsUiState> = _uiState.asStateFlow()

    fun refresh(userId: String?) {
        if (userId.isNullOrBlank()) {
            _uiState.update { it.copy(isLoading = false, listings = emptyList(), errorMessage = null) }
            return
        }

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null) }
            val ownListings = mutableListOf<BusinessListing>()
            var page = 1
            var keepLoading = true

            while (keepLoading) {
                val result = repository.fetchListings(
                    page = page,
                    category = null,
                    region = null,
                    minPrice = null,
                    maxPrice = null,
                    search = null
                )

                result
                    .onSuccess { payload ->
                        val listings = payload.first
                        val total = payload.second
                        val pages = (total + 11) / 12
                        ownListings += listings.filter { listing ->
                            extractOwnerId(listing.owner) == userId
                        }
                        page += 1
                        keepLoading = page <= pages
                    }
                    .onFailure { error ->
                        keepLoading = false
                        _uiState.update {
                            it.copy(
                                isLoading = false,
                                errorMessage = error.message ?: "Failed to load your listings"
                            )
                        }
                    }
            }

            if (_uiState.value.isLoading) {
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                        listings = ownListings,
                            errorMessage = null
                        )
                    }
            }
        }
    }

    private fun extractOwnerId(owner: JsonElement?): String? {
        if (owner == null || owner.isJsonNull) return null
        return when {
            owner.isJsonObject -> owner.asJsonObject.get("_id")?.asString
            owner.isJsonPrimitive -> owner.asString
            else -> null
        }
    }
}

class MyListingsViewModelFactory(private val repository: ListingsRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(MyListingsViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return MyListingsViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
