package com.souqira.android.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.souqira.android.data.model.Category
import com.souqira.android.data.model.CreateListingInput
import com.souqira.android.data.model.Region
import com.souqira.android.data.repository.ListingsRepository
import java.io.File
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class CreateListingUiState(
    val isSubmitting: Boolean = false,
    val categories: List<Category> = emptyList(),
    val regions: List<Region> = emptyList(),
    val success: Boolean = false,
    val errorMessage: String? = null
)

class CreateListingViewModel(private val repository: ListingsRepository) : ViewModel() {
    private val _uiState = MutableStateFlow(
        CreateListingUiState(
            categories = repository.categories(),
            regions = repository.regions()
        )
    )
    val uiState: StateFlow<CreateListingUiState> = _uiState.asStateFlow()

    fun submit(input: CreateListingInput, imageFiles: List<File>) {
        val validationError = validate(input)
        if (validationError != null) {
            _uiState.update { it.copy(errorMessage = validationError) }
            return
        }

        viewModelScope.launch {
            _uiState.update { it.copy(isSubmitting = true, errorMessage = null, success = false) }
            repository.createListing(input, imageFiles)
                .onSuccess {
                    _uiState.update { it.copy(isSubmitting = false, success = true, errorMessage = null) }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(
                            isSubmitting = false,
                            success = false,
                            errorMessage = error.message ?: "Failed to create listing"
                        )
                    }
                }
        }
    }

    fun consumeSuccess() {
        _uiState.update { it.copy(success = false) }
    }

    private fun validate(input: CreateListingInput): String? {
        if (input.title.trim().length < 5) return "Title must be at least 5 characters"
        if (input.description.trim().length < 20) return "Description must be at least 20 characters"
        if (input.phone.trim().length < 6) return "Phone number looks too short"
        if (input.category.isBlank()) return "Please select a category"
        if (input.location.isBlank()) return "Please select a region"
        return null
    }
}

class CreateListingViewModelFactory(private val repository: ListingsRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(CreateListingViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return CreateListingViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
