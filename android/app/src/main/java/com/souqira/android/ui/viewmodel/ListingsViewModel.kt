package com.souqira.android.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.souqira.android.data.model.BusinessListing
import com.souqira.android.data.model.Category
import com.souqira.android.data.model.Region
import com.souqira.android.data.repository.ListingsRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class ListingsFilterState(
    val category: String? = null,
    val region: String? = null,
    val minPrice: Double? = null,
    val maxPrice: Double? = null,
    val search: String? = null
)

data class ListingsUiState(
    val isLoading: Boolean = false,
    val listings: List<BusinessListing> = emptyList(),
    val categories: List<Category> = emptyList(),
    val regions: List<Region> = emptyList(),
    val currentPage: Int = 1,
    val hasMorePages: Boolean = true,
    val filter: ListingsFilterState = ListingsFilterState(),
    val errorMessage: String? = null
)

class ListingsViewModel(private val repository: ListingsRepository) : ViewModel() {
    private val _uiState = MutableStateFlow(
        ListingsUiState(
            categories = repository.categories(),
            regions = repository.regions()
        )
    )
    val uiState: StateFlow<ListingsUiState> = _uiState.asStateFlow()

    fun refresh() {
        loadListings(reset = true)
    }

    fun loadNextPage() {
        if (_uiState.value.hasMorePages) {
            loadListings(reset = false)
        }
    }

    fun updateSearch(search: String) {
        _uiState.update {
            it.copy(filter = it.filter.copy(search = search.ifBlank { null }))
        }
    }

    fun updateCategory(category: String?) {
        _uiState.update { it.copy(filter = it.filter.copy(category = category)) }
    }

    fun updateRegion(region: String?) {
        _uiState.update { it.copy(filter = it.filter.copy(region = region)) }
    }

    fun loadListings(reset: Boolean) {
        viewModelScope.launch {
            val currentState = _uiState.value
            if (currentState.isLoading) return@launch

            val nextPage = if (reset) 1 else currentState.currentPage
            _uiState.update { it.copy(isLoading = true, errorMessage = null) }

            repository.fetchListings(
                page = nextPage,
                category = currentState.filter.category,
                region = currentState.filter.region,
                minPrice = currentState.filter.minPrice,
                maxPrice = currentState.filter.maxPrice,
                search = currentState.filter.search
            ).onSuccess { result ->
                val fetched = result.first
                val total = result.second
                val merged = if (reset) fetched else currentState.listings + fetched
                val pages = (total + 11) / 12

                _uiState.update {
                    it.copy(
                        isLoading = false,
                        listings = merged,
                        currentPage = nextPage + 1,
                        hasMorePages = nextPage < pages,
                        errorMessage = null
                    )
                }
            }.onFailure { error ->
                _uiState.update {
                    it.copy(isLoading = false, errorMessage = error.message ?: "Failed to load listings")
                }
            }
        }
    }

    fun toggleFavorite(listingId: String, isFavorite: Boolean) {
        viewModelScope.launch {
            repository.toggleFavorite(listingId = listingId, isFavorite = isFavorite)
                .onFailure { error ->
                    _uiState.update {
                        it.copy(errorMessage = error.message ?: "Failed to update favorite")
                    }
                }
        }
    }
}

class ListingsViewModelFactory(private val repository: ListingsRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(ListingsViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return ListingsViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
