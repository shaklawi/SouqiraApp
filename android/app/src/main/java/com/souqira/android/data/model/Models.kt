package com.souqira.android.data.model

import com.google.gson.JsonElement
import com.google.gson.annotations.SerializedName

data class ApiResponse<T>(
    val success: Boolean,
    val data: T?,
    val message: String?,
    val error: String?
)

data class AuthResponse(
    val user: User,
    val accessToken: String? = null,
    val refreshToken: String? = null,
    val token: String? = null,
    val tokenadmin: String? = null,
    val requires2FA: Boolean? = null,
    val tempToken: String? = null,
    val userId: String? = null
)

data class User(
    @SerializedName("_id") val id: String,
    val name: String?,
    val email: String?,
    val username: String?,
    @SerializedName(value = "firstName", alternate = ["firstname"]) val firstName: String?,
    @SerializedName(value = "lastName", alternate = ["lastname"]) val lastName: String?,
    val phone: String?,
    val whatsapp: String?,
    val role: String?,
    @SerializedName(value = "isEmailVerified", alternate = ["isUserVerified"]) val emailVerified: Boolean?,
    val profilePicture: String?
)

data class ListingUser(
    @SerializedName("_id") val id: String,
    val isVerified: Boolean?,
    val name: String?,
    val email: String?
)

data class Coordinates(
    val lat: Double,
    val lng: Double
)

data class BusinessListing(
    @SerializedName("_id") val id: String,
    val title: String,
    val description: String,
    val price: Double,
    val currency: String,
    val location: String,
    val category: String,
    val images: List<String> = emptyList(),
    val address: String?,
    val coordinates: Coordinates?,
    val phone: String?,
    val whatsapp: String?,
    val status: String?,
    val saleStatus: String?,
    val isFeatured: Boolean? = null,
    val views: Int = 0,
    // Backend may return owner as either an object or a raw string id.
    val owner: JsonElement?,
    val createdAt: String?,
    val isFavorite: Boolean? = null
)

data class ListingsResponse(
    val listings: List<BusinessListing> = emptyList(),
    val total: Int = 0
)

data class MessageUser(
    @SerializedName("_id") val id: String,
    val email: String?,
    val firstname: String?,
    val lastname: String?,
    val username: String?
)

data class Message(
    @SerializedName("_id") val id: String,
    @SerializedName("sender") val senderId: String,
    @SerializedName("receiver") val receiverId: String,
    val content: String,
    val isRead: Boolean,
    val createdAt: String
)

data class Conversation(
    @SerializedName("_id") val id: String,
    val partner: MessageUser,
    val latestMessage: Message
)

data class ConversationMessagesResponse(
    val messages: List<Message> = emptyList(),
    val total: Int = 0,
    val page: Int = 1,
    val limit: Int = 20
)

data class AppNotification(
    @SerializedName("_id") val id: String,
    val title: String,
    val message: String,
    val isRead: Boolean,
    val createdAt: String
)

data class RegisterRequest(
    val username: String,
    val email: String,
    val password: String,
    val confirmPassword: String
)

data class LoginRequest(
    @SerializedName("usernameOrEmail") val usernameOrEmail: String,
    val password: String
)

data class GoogleLoginRequest(
    @SerializedName("token") val token: String,
    @SerializedName("idToken") val idToken: String
)

data class WhatsAppSendOtpRequest(
    val phoneNumber: String
)

data class WhatsAppVerifyOtpRequest(
    val phoneNumber: String,
    val otp: String
)

data class DeviceTokenRequest(
    val token: String,
    val platform: String = "android"
)

data class CreateListingInput(
    val title: String,
    val description: String,
    val price: Double,
    val currency: String,
    val location: String,
    val category: String,
    val phone: String,
    val whatsapp: String?,
    val address: String?
)

data class CreateListingRequest(
    val title: String,
    val description: String,
    val price: Double,
    val currency: String,
    val location: String,
    val category: String,
    val phone: String?,
    val whatsapp: String?,
    val address: String?,
    val coordinates: String?,
    val status: String?,
    val saleStatus: String?
)

data class SendMessageRequest(
    val receiver: String,
    val content: String
)

data class ReportListingRequest(
    val reason: String
)

data class Category(
    val id: String,
    val name: String
)

data class Region(
    val id: String,
    val name: String
)

object StaticFilters {
    val categories = listOf(
        Category("restaurants_cafes", "Restaurants & Cafes"),
        Category("retail_stores", "Retail Stores"),
        Category("auto_services", "Auto Services"),
        Category("beauty_salons", "Beauty Salons"),
        Category("ecommerce_online_business", "E-Commerce & Online"),
        Category("it_tech", "IT & Technology"),
        Category("medical_health_services", "Medical & Health"),
        Category("education_training", "Education & Training"),
        Category("real_estate_construction", "Real Estate & Construction"),
        Category("transport_logistics", "Transport & Logistics"),
        Category("manufacturing_industry", "Manufacturing & Industry"),
        Category("agriculture_food_production", "Agriculture & Food"),
        Category("financial_accounting_services", "Financial & Accounting"),
        Category("marketing_advertising", "Marketing & Advertising"),
        Category("tourism_travel", "Tourism & Travel"),
        Category("freelance_services", "Freelance Services"),
        Category("home_based_businesses", "Home Based Business"),
        Category("cleaning_maintenance", "Cleaning & Maintenance"),
        Category("wholesale_distribution", "Wholesale & Distribution"),
        Category("other", "Other"),
        Category("find_a_partner", "Find a Partner"),
        Category("find_an_investor", "Find an Investor")
    )

    val regions = listOf(
        Region("baghdad", "Baghdad"),
        Region("basra", "Basra"),
        Region("erbil", "Erbil"),
        Region("mosul", "Mosul"),
        Region("sulaymaniyah", "Sulaymaniyah"),
        Region("najaf", "Najaf"),
        Region("karbala", "Karbala"),
        Region("kirkuk", "Kirkuk"),
        Region("duhok", "Duhok"),
        Region("ramadi", "Ramadi")
    )
}
