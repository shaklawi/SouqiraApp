package com.souqira.android.data.network

import com.souqira.android.data.model.ApiResponse
import com.souqira.android.data.model.AppNotification
import com.souqira.android.data.model.AuthResponse
import com.souqira.android.data.model.BusinessListing
import com.souqira.android.data.model.Conversation
import com.souqira.android.data.model.ConversationMessagesResponse
import com.souqira.android.data.model.CreateListingRequest
import com.souqira.android.data.model.DeviceTokenRequest
import com.souqira.android.data.model.GoogleLoginRequest
import com.souqira.android.data.model.ListingsResponse
import com.souqira.android.data.model.LoginRequest
import com.souqira.android.data.model.Message
import com.souqira.android.data.model.ReportListingRequest
import com.souqira.android.data.model.RegisterRequest
import com.souqira.android.data.model.SendMessageRequest
import com.souqira.android.data.model.User
import com.souqira.android.data.model.WhatsAppSendOtpRequest
import com.souqira.android.data.model.WhatsAppVerifyOtpRequest
import okhttp3.MultipartBody
import okhttp3.RequestBody
import retrofit2.http.Body
import retrofit2.http.DELETE
import retrofit2.http.GET
import retrofit2.http.Multipart
import retrofit2.http.POST
import retrofit2.http.Part
import retrofit2.http.PartMap
import retrofit2.http.PUT
import retrofit2.http.Path
import retrofit2.http.Query

interface SouqiraApi {
    @POST("api/auth/login")
    suspend fun login(@Body request: LoginRequest): ApiResponse<AuthResponse>

    @POST("api/auth/register")
    suspend fun register(@Body request: RegisterRequest): ApiResponse<AuthResponse>

    @POST("api/auth/google/token")
    suspend fun loginWithGoogle(@Body request: GoogleLoginRequest): ApiResponse<AuthResponse>

    @POST("api/auth/whatsapp/send-otp")
    suspend fun sendWhatsAppOtp(@Body request: WhatsAppSendOtpRequest): ApiResponse<Any>

    @POST("api/auth/whatsapp/verify-otp")
    suspend fun verifyWhatsAppOtp(@Body request: WhatsAppVerifyOtpRequest): ApiResponse<AuthResponse>

    @GET("api/user/profile")
    suspend fun getCurrentUser(): ApiResponse<User>

    @PUT("api/user/delete")
    suspend fun deleteAccount(
        @Query("force") force: Boolean = true
    ): ApiResponse<Any>

    @GET("api/listing")
    suspend fun fetchListings(
        @Query("page") page: Int = 1,
        @Query("limit") limit: Int = 12,
        @Query("category") category: String? = null,
        @Query("location") location: String? = null,
        @Query("minPrice") minPrice: Int? = null,
        @Query("maxPrice") maxPrice: Int? = null,
        @Query("search") search: String? = null
    ): ApiResponse<ListingsResponse>

    @GET("api/listing/approved/{id}")
    suspend fun fetchListingDetail(@Path("id") id: String): ApiResponse<BusinessListing>

    @GET("api/listing/my-listings/{id}")
    suspend fun fetchMyListingDetail(@Path("id") id: String): ApiResponse<BusinessListing>

    @POST("api/listing/create")
    suspend fun createListing(@Body request: CreateListingRequest): ApiResponse<BusinessListing>

    @Multipart
    @POST("api/listing/create")
    suspend fun createListingMultipart(
        @PartMap fields: Map<String, @JvmSuppressWildcards RequestBody>,
        @Part images: List<MultipartBody.Part>
    ): ApiResponse<BusinessListing>

    @Multipart
    @PUT("api/listing/update/{listingId}")
    suspend fun updateListingMultipart(
        @Path("listingId") listingId: String,
        @Part parts: List<MultipartBody.Part>
    ): ApiResponse<BusinessListing>

    @GET("api/listing/my-favorites")
    suspend fun fetchFavorites(): ApiResponse<List<BusinessListing>>

    @POST("api/listing/report/{id}")
    suspend fun reportListing(
        @Path("id") id: String,
        @Body request: ReportListingRequest
    ): ApiResponse<Any>

    @POST("api/listing/favorites/{id}")
    suspend fun addFavorite(@Path("id") id: String): ApiResponse<Any>

    @DELETE("api/listing/favorites/{id}")
    suspend fun removeFavorite(@Path("id") id: String): ApiResponse<Any>

    @GET("api/message/me")
    suspend fun getConversations(): ApiResponse<List<Conversation>>

    @GET("api/message/{partnerId}")
    suspend fun getMessages(@Path("partnerId") partnerId: String): ApiResponse<ConversationMessagesResponse>

    @POST("api/message")
    suspend fun sendMessage(@Body request: SendMessageRequest): ApiResponse<Message>

    @POST("api/message/block/{userId}")
    suspend fun blockUser(@Path("userId") userId: String): ApiResponse<Any>

    @GET("api/user/notifications")
    suspend fun getNotifications(): ApiResponse<List<AppNotification>>

    @PUT("api/user/notifications/{id}/read")
    suspend fun markNotificationRead(@Path("id") id: String): ApiResponse<AppNotification>

    @PUT("api/user/device-token")
    suspend fun registerDeviceToken(@Body request: DeviceTokenRequest): ApiResponse<Any>

    @PUT("api/user/device-token/public")
    suspend fun registerPublicDeviceToken(@Body request: DeviceTokenRequest): ApiResponse<Any>
}
