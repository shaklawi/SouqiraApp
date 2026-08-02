package com.souqira.android.data.repository

import com.souqira.android.data.model.BusinessListing
import com.souqira.android.data.model.CreateListingInput
import com.souqira.android.data.model.CreateListingRequest
import com.souqira.android.data.model.ReportListingRequest
import com.souqira.android.data.model.StaticFilters
import com.souqira.android.data.network.SouqiraApi
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.File

data class ListingDetailResult(
    val listing: BusinessListing,
    val canEdit: Boolean
)

class ListingsRepository(private val api: SouqiraApi) {
    suspend fun fetchListings(
        page: Int,
        category: String?,
        region: String?,
        minPrice: Double?,
        maxPrice: Double?,
        search: String?
    ): Result<Pair<List<BusinessListing>, Int>> {
        return runCatching {
            val response = api.fetchListings(
                page = page,
                category = category,
                location = region,
                minPrice = minPrice?.toInt(),
                maxPrice = maxPrice?.toInt(),
                search = search
            )
            val data = response.data ?: error(response.message ?: "Failed to fetch listings")
            Pair(data.listings, data.total)
        }
    }

    suspend fun fetchFavorites(): Result<List<BusinessListing>> {
        return runCatching {
            val response = api.fetchFavorites()
            response.data ?: emptyList()
        }
    }

    suspend fun fetchListingDetail(id: String, tryMineFirst: Boolean): Result<ListingDetailResult> {
        return runCatching {
            if (tryMineFirst) {
                val my = runCatching { api.fetchMyListingDetail(id) }.getOrNull()
                val myListing = my?.data
                if (myListing != null) {
                    return@runCatching ListingDetailResult(listing = myListing, canEdit = true)
                }
            }
            val response = api.fetchListingDetail(id)
            response.data ?: error(response.message ?: "Failed to load listing")
        }.mapCatching { listingOrResult ->
            when (listingOrResult) {
                is ListingDetailResult -> listingOrResult
                is BusinessListing -> ListingDetailResult(listing = listingOrResult, canEdit = false)
                else -> error("Unexpected listing detail response")
            }
        }
    }

    suspend fun updateListingImages(
        listingId: String,
        keepImageUrls: List<String>,
        newImageFiles: List<File>
    ): Result<BusinessListing> {
        return runCatching {
            val imageType = "image/jpeg".toMediaType()
            val parts = mutableListOf<MultipartBody.Part>()

            keepImageUrls
                .distinct()
                .forEach { imageUrl ->
                    parts += MultipartBody.Part.createFormData("images", imageUrl)
                }

            newImageFiles.forEachIndexed { index, file ->
                val body = file.asRequestBody(imageType)
                parts += MultipartBody.Part.createFormData(
                    "images",
                    file.name.ifBlank { "listing-image-${index + 1}.jpg" },
                    body
                )
            }

            val response = api.updateListingMultipart(listingId = listingId, parts = parts)
            response.data ?: error(response.message ?: "Failed to update listing images")
        }
    }

    suspend fun updateListingDetails(
        listingId: String,
        title: String,
        description: String,
        price: Double,
        location: String,
        phone: String
    ): Result<BusinessListing> {
        return runCatching {
            val parts = mutableListOf<MultipartBody.Part>()

            parts += MultipartBody.Part.createFormData("title", title.trim())
            parts += MultipartBody.Part.createFormData("description", description.trim())
            parts += MultipartBody.Part.createFormData("price", price.toString())
            parts += MultipartBody.Part.createFormData("location", location.trim())
            parts += MultipartBody.Part.createFormData("phone", phone.trim())

            val response = api.updateListingMultipart(listingId = listingId, parts = parts)
            response.data ?: error(response.message ?: "Failed to update listing")
        }
    }

    suspend fun toggleFavorite(listingId: String, isFavorite: Boolean): Result<Unit> {
        return runCatching {
            if (isFavorite) {
                api.removeFavorite(listingId)
            } else {
                api.addFavorite(listingId)
            }
            Unit
        }
    }

    suspend fun blockUser(userId: String): Result<String> {
        return runCatching {
            val response = api.blockUser(userId)
            response.message ?: "User blocked"
        }
    }

    suspend fun reportListing(listingId: String, reason: String): Result<String> {
        return runCatching {
            val response = api.reportListing(id = listingId, request = ReportListingRequest(reason = reason))
            response.message ?: "Listing reported"
        }
    }

    suspend fun createListing(input: CreateListingInput, imageFiles: List<File>): Result<BusinessListing> {
        return runCatching {
            if (imageFiles.isEmpty()) {
                val response = api.createListing(
                    CreateListingRequest(
                        title = input.title,
                        description = input.description,
                        price = input.price,
                        currency = input.currency.lowercase(),
                        location = input.location,
                        category = input.category,
                        phone = input.phone,
                        whatsapp = input.whatsapp,
                        address = input.address,
                        coordinates = null,
                        status = null,
                        saleStatus = null
                    )
                )
                return@runCatching response.data ?: error(response.message ?: "Failed to create listing")
            }

            val textType = "text/plain".toMediaType()
            val fields = linkedMapOf(
                "title" to input.title.toRequestBody(textType),
                "description" to input.description.toRequestBody(textType),
                "price" to input.price.toString().toRequestBody(textType),
                "currency" to input.currency.lowercase().toRequestBody(textType),
                "location" to input.location.toRequestBody(textType),
                "category" to input.category.toRequestBody(textType),
                "phone" to input.phone.toRequestBody(textType)
            )

            if (!input.whatsapp.isNullOrBlank()) {
                fields["whatsapp"] = input.whatsapp.toRequestBody(textType)
            }
            if (!input.address.isNullOrBlank()) {
                fields["address"] = input.address.toRequestBody(textType)
            }

            val imageType = "image/jpeg".toMediaType()
            val images = imageFiles.mapIndexed { index, file ->
                val body = file.asRequestBody(imageType)
                MultipartBody.Part.createFormData("images", file.name.ifBlank { "listing-image-${index + 1}.jpg" }, body)
            }

            val response = api.createListingMultipart(fields, images)
            response.data ?: error(response.message ?: "Failed to create listing")
        }
    }

    fun categories() = StaticFilters.categories

    fun regions() = StaticFilters.regions
}
