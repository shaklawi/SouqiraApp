package com.souqira.android.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.souqira.android.data.model.BusinessListing
import com.souqira.android.data.repository.ListingsRepository
import java.io.File
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class ListingDetailUiState(
    val isLoading: Boolean = false,
    val listing: BusinessListing? = null,
    val canEditListing: Boolean = false,
    val isSavingDetails: Boolean = false,
    val isSavingImages: Boolean = false,
    val isFavorite: Boolean = false,
    val errorMessage: String? = null,
    val statusMessage: String? = null
)

class ListingDetailViewModel(private val repository: ListingsRepository) : ViewModel() {
    private val _uiState = MutableStateFlow(ListingDetailUiState())
    val uiState: StateFlow<ListingDetailUiState> = _uiState.asStateFlow()

    fun loadListing(id: String, tryMineFirst: Boolean) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null) }
            repository.fetchListingDetail(id = id, tryMineFirst = tryMineFirst)
                .onSuccess { detail ->
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            listing = detail.listing,
                            canEditListing = detail.canEdit,
                            isFavorite = detail.listing.isFavorite == true,
                            errorMessage = null
                        )
                    }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(isLoading = false, errorMessage = error.message ?: "Failed to load listing")
                    }
                }
        }
    }

    fun updateListingImages(keepImageUrls: List<String>, newImageFiles: List<File>) {
        val listing = _uiState.value.listing ?: return
        viewModelScope.launch {
            _uiState.update { it.copy(isSavingImages = true, errorMessage = null, statusMessage = null) }
            repository.updateListingImages(
                listingId = listing.id,
                keepImageUrls = keepImageUrls,
                newImageFiles = newImageFiles
            ).onSuccess { updatedListing ->
                _uiState.update {
                    it.copy(
                        isSavingImages = false,
                        listing = updatedListing,
                        statusMessage = "Listing images updated",
                        errorMessage = null
                    )
                }
            }.onFailure { error ->
                _uiState.update {
                    it.copy(
                        isSavingImages = false,
                        errorMessage = error.message ?: "Failed to update listing images"
                    )
                }
            }
        }
    }

    fun updateListingDetails(
        title: String,
        description: String,
        priceText: String,
        location: String,
        phone: String
    ) {
        val listing = _uiState.value.listing ?: return
        val price = priceText.toDoubleOrNull()
        if (title.trim().length < 5) {
            _uiState.update { it.copy(errorMessage = "Title must be at least 5 characters") }
            return
        }
        if (description.trim().length < 20) {
            _uiState.update { it.copy(errorMessage = "Description must be at least 20 characters") }
            return
        }
        if (price == null) {
            _uiState.update { it.copy(errorMessage = "Price is required") }
            return
        }
        if (location.trim().isEmpty()) {
            _uiState.update { it.copy(errorMessage = "Location is required") }
            return
        }
        if (phone.trim().length < 6) {
            _uiState.update { it.copy(errorMessage = "Phone number looks too short") }
            return
        }

        viewModelScope.launch {
            _uiState.update { it.copy(isSavingDetails = true, errorMessage = null, statusMessage = null) }
            repository.updateListingDetails(
                listingId = listing.id,
                title = title,
                description = description,
                price = price,
                location = location,
                phone = phone
            ).onSuccess { updatedListing ->
                _uiState.update {
                    it.copy(
                        isSavingDetails = false,
                        listing = updatedListing,
                        statusMessage = "Listing updated",
                        errorMessage = null
                    )
                }
            }.onFailure { error ->
                _uiState.update {
                    it.copy(
                        isSavingDetails = false,
                        errorMessage = error.message ?: "Failed to update listing"
                    )
                }
            }
        }
    }

    fun toggleFavorite() {
        val listing = _uiState.value.listing ?: return
        val currentlyFavorite = _uiState.value.isFavorite

        viewModelScope.launch {
            repository.toggleFavorite(listing.id, currentlyFavorite)
                .onSuccess {
                    _uiState.update { it.copy(isFavorite = !currentlyFavorite, errorMessage = null) }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(errorMessage = error.message ?: "Failed to update favorite")
                    }
                }
        }
    }

    fun blockUser(userId: String) {
        viewModelScope.launch {
            repository.blockUser(userId)
                .onSuccess { message ->
                    _uiState.update { it.copy(statusMessage = message, errorMessage = null) }
                }
                .onFailure { error ->
                    _uiState.update { it.copy(errorMessage = error.message ?: "Failed to block user") }
                }
        }
    }

    fun reportListing(reason: String) {
        val listingId = _uiState.value.listing?.id ?: return
        viewModelScope.launch {
            repository.reportListing(listingId = listingId, reason = reason)
                .onSuccess { message ->
                    _uiState.update { it.copy(statusMessage = message, errorMessage = null) }
                }
                .onFailure { error ->
                    _uiState.update { it.copy(errorMessage = error.message ?: "Failed to report listing") }
                }
        }
    }

    fun consumeStatusMessage() {
        _uiState.update { it.copy(statusMessage = null) }
    }

    fun consumeErrorMessage() {
        _uiState.update { it.copy(errorMessage = null) }
    }
}

class ListingDetailViewModelFactory(private val repository: ListingsRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(ListingDetailViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return ListingDetailViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
