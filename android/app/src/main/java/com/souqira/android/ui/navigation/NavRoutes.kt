package com.souqira.android.ui.navigation

sealed class NavRoutes(val route: String) {
    data object Home : NavRoutes("home")
    data object Listings : NavRoutes("listings")
    data object Favorites : NavRoutes("favorites")
    data object Messages : NavRoutes("messages")
    data object Profile : NavRoutes("profile")
    data object MyListings : NavRoutes("my-listings")
    data object CreateListing : NavRoutes("create-listing")

    data object ListingDetail : NavRoutes("listing-detail/{id}?ownerAction={ownerAction}") {
        fun createRoute(id: String): String = "listing-detail/$id"

        fun createRoute(id: String, ownerAction: String): String {
            return "listing-detail/$id?ownerAction=$ownerAction"
        }
    }
}
