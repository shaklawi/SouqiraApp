package com.souqira.android.ui

import android.app.Activity
import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsBottomHeight
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Message
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.souqira.android.R
import com.souqira.android.SouqiraApplication
import com.souqira.android.localization.LocaleManager
import com.souqira.android.ui.navigation.NavRoutes
import com.souqira.android.ui.screen.auth.AuthScreen
import com.souqira.android.ui.screen.listings.CreateListingScreen
import com.souqira.android.ui.screen.listings.FavoritesScreen
import com.souqira.android.ui.screen.listings.ListingDetailScreen
import com.souqira.android.ui.screen.listings.ListingsFilterMode
import com.souqira.android.ui.screen.listings.ListingsScreen
import com.souqira.android.ui.screen.listings.MyListingsScreen
import com.souqira.android.ui.screen.messages.MessagesScreen
import com.souqira.android.ui.screen.profile.ProfileScreen
import com.souqira.android.ui.viewmodel.AuthViewModel
import com.souqira.android.ui.viewmodel.AuthViewModelFactory
import com.souqira.android.ui.viewmodel.CreateListingViewModel
import com.souqira.android.ui.viewmodel.CreateListingViewModelFactory
import com.souqira.android.ui.viewmodel.FavoritesViewModel
import com.souqira.android.ui.viewmodel.FavoritesViewModelFactory
import com.souqira.android.ui.viewmodel.ListingDetailViewModel
import com.souqira.android.ui.viewmodel.ListingDetailViewModelFactory
import com.souqira.android.ui.viewmodel.ListingsViewModel
import com.souqira.android.ui.viewmodel.ListingsViewModelFactory
import com.souqira.android.ui.viewmodel.MessagesViewModel
import com.souqira.android.ui.viewmodel.MessagesViewModelFactory
import com.souqira.android.ui.viewmodel.MyListingsViewModel
import com.souqira.android.ui.viewmodel.MyListingsViewModelFactory
import kotlinx.coroutines.launch

data class BottomItem(
    val route: NavRoutes,
    val labelRes: Int,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector
)

@Composable
fun SouqiraAppRoot() {
    val context = LocalContext.current
    val appContainer = (context.applicationContext as SouqiraApplication).appContainer

    val authViewModel: AuthViewModel = viewModel(factory = AuthViewModelFactory(appContainer.authRepository))
    val listingsViewModel: ListingsViewModel = viewModel(factory = ListingsViewModelFactory(appContainer.listingsRepository))
    val favoritesViewModel: FavoritesViewModel = viewModel(factory = FavoritesViewModelFactory(appContainer.listingsRepository))
    val listingDetailViewModel: ListingDetailViewModel = viewModel(factory = ListingDetailViewModelFactory(appContainer.listingsRepository))
    val createListingViewModel: CreateListingViewModel = viewModel(factory = CreateListingViewModelFactory(appContainer.listingsRepository))
    val messagesViewModel: MessagesViewModel = viewModel(factory = MessagesViewModelFactory(appContainer.messagesRepository))
    val myListingsViewModel: MyListingsViewModel = viewModel(factory = MyListingsViewModelFactory(appContainer.listingsRepository))

    val authUi by authViewModel.uiState.collectAsState()
    val selectedLanguage by appContainer.languageStore.languageFlow.collectAsState(initial = LocaleManager.currentLanguage())
    val navController = rememberNavController()
    val scope = rememberCoroutineScope()
    val current = navController.currentBackStackEntryAsState().value?.destination?.route

    LaunchedEffect(Unit) {
        authViewModel.bootstrap()
        listingsViewModel.refresh()
    }

    // Navigate to Home whenever a fresh login/register occurs
    var wasAuthenticated by remember { mutableStateOf(authUi.isAuthenticated) }
    LaunchedEffect(authUi.isAuthenticated) {
        if (authUi.isAuthenticated && !wasAuthenticated) {
            navController.navigate(NavRoutes.Home.route) {
                popUpTo(navController.graph.findStartDestination().id)
                launchSingleTop = true
            }
        }
        wasAuthenticated = authUi.isAuthenticated
    }

    val bottomItems = if (authUi.isAuthenticated) {
        listOf(
            BottomItem(NavRoutes.Home, R.string.nav_home, Icons.Filled.Home, Icons.Outlined.Home),
            BottomItem(NavRoutes.Listings, R.string.nav_cities, Icons.Filled.Search, Icons.Filled.Search),
            BottomItem(NavRoutes.Messages, R.string.nav_messages, Icons.Filled.Notifications, Icons.AutoMirrored.Filled.Message),
            BottomItem(NavRoutes.Profile, R.string.nav_profile, Icons.Filled.Person, Icons.Outlined.Person)
        )
    } else {
        listOf(
            BottomItem(NavRoutes.Home, R.string.nav_home, Icons.Filled.Home, Icons.Outlined.Home),
            BottomItem(NavRoutes.Listings, R.string.nav_cities, Icons.Filled.Search, Icons.Filled.Search),
            BottomItem(NavRoutes.Favorites, R.string.nav_favorites, Icons.Filled.Favorite, Icons.Outlined.FavoriteBorder),
            BottomItem(NavRoutes.Profile, R.string.nav_profile, Icons.Filled.Person, Icons.Outlined.Person)
        )
    }

    val activeTabRoutes = bottomItems.map { it.route.route }

    Scaffold(
        containerColor = Color(0xFFF1F6FA),
        bottomBar = {
            if (current in activeTabRoutes) {
                IosStyleTabBar(
                    items = bottomItems,
                    currentRoute = current,
                    onTabClick = { route ->
                        if (current == route) {
                            if (route == NavRoutes.Home.route) {
                                listingsViewModel.refresh()
                            }
                            return@IosStyleTabBar
                        }
                        navController.navigate(route) {
                            popUpTo(navController.graph.findStartDestination().id) {
                                saveState = true
                            }
                            launchSingleTop = true
                            restoreState = route != NavRoutes.Home.route
                        }
                        if (route == NavRoutes.Home.route) {
                            listingsViewModel.refresh()
                        }
                    },
                    onCreateClick = {
                        if (authUi.isAuthenticated) {
                            navController.navigate(NavRoutes.CreateListing.route)
                        } else {
                            navController.navigate(NavRoutes.Profile.route)
                        }
                    }
                )
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = NavRoutes.Home.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(NavRoutes.Home.route) {
                ListingsScreen(
                    title = stringResource(R.string.app_name),
                    viewModel = listingsViewModel,
                    isAuthenticated = authUi.isAuthenticated,
                    userDisplayName = authUi.user?.name
                        ?: authUi.user?.username
                        ?: authUi.user?.firstName,
                    filterMode = ListingsFilterMode.CATEGORY,
                    onOpenListing = { listingId ->
                        navController.navigate(NavRoutes.ListingDetail.createRoute(listingId))
                    },
                    onCreateAd = {
                        if (authUi.isAuthenticated) {
                            navController.navigate(NavRoutes.CreateListing.route)
                        } else {
                            navController.navigate(NavRoutes.Profile.route)
                        }
                    },
                    onRequireAuth = {
                        navController.navigate(NavRoutes.Profile.route)
                    },
                    onSettingsClick = {
                        navController.navigate(NavRoutes.Profile.route)
                    }
                )
            }
            composable(NavRoutes.Listings.route) {
                ListingsScreen(
                    title = stringResource(R.string.cities_title),
                    viewModel = listingsViewModel,
                    isAuthenticated = authUi.isAuthenticated,
                    userDisplayName = authUi.user?.name
                        ?: authUi.user?.username
                        ?: authUi.user?.firstName,
                    filterMode = ListingsFilterMode.REGION,
                    onOpenListing = { listingId ->
                        navController.navigate(NavRoutes.ListingDetail.createRoute(listingId))
                    },
                    onRequireAuth = {
                        navController.navigate(NavRoutes.Messages.route)
                    }
                )
            }
            composable(NavRoutes.Favorites.route) {
                if (authUi.isAuthenticated) {
                    FavoritesScreen(
                        viewModel = favoritesViewModel,
                        onOpenListing = { listingId ->
                            navController.navigate(NavRoutes.ListingDetail.createRoute(listingId))
                        }
                    )
                } else {
                    AuthScreen(authViewModel)
                }
            }
            composable(NavRoutes.Messages.route) {
                if (authUi.isAuthenticated) {
                    MessagesScreen(messagesViewModel)
                } else {
                    AuthScreen(authViewModel)
                }
            }
            composable(NavRoutes.Profile.route) {
                ProfileScreen(
                    authUiState = authUi,
                    currentLanguage = selectedLanguage,
                    onOpenFavorites = {
                        navController.navigate(NavRoutes.Favorites.route)
                    },
                    onOpenMyListings = {
                        navController.navigate(NavRoutes.MyListings.route)
                    },
                    onChangeLanguage = { code ->
                        scope.launch {
                            LocaleManager.setLanguage(appContainer.languageStore, context, code)
                            (context as? Activity)?.recreate()
                        }
                    },
                    onDeleteAccount = {
                        authViewModel.deleteAccount(force = true)
                    },
                    onLogout = authViewModel::logout,
                    onRequireAuth = {
                        navController.navigate(NavRoutes.Messages.route)
                    }
                )
            }
            composable(NavRoutes.MyListings.route) {
                if (authUi.isAuthenticated) {
                    MyListingsScreen(
                        viewModel = myListingsViewModel,
                        currentUserId = authUi.user?.id,
                        onBack = { navController.popBackStack() },
                        onOpenListing = { listingId ->
                            navController.navigate(NavRoutes.ListingDetail.createRoute(listingId))
                        },
                        onEditDetails = { listingId ->
                            navController.navigate(NavRoutes.ListingDetail.createRoute(listingId, "details"))
                        },
                        onEditPhotos = { listingId ->
                            navController.navigate(NavRoutes.ListingDetail.createRoute(listingId, "photos"))
                        }
                    )
                } else {
                    AuthScreen(authViewModel)
                }
            }
            composable(NavRoutes.CreateListing.route) {
                if (authUi.isAuthenticated) {
                    CreateListingScreen(
                        viewModel = createListingViewModel,
                        onCreated = {
                            listingsViewModel.refresh()
                            favoritesViewModel.loadFavorites()
                            navController.popBackStack()
                        },
                        onBack = {
                            navController.popBackStack()
                        }
                    )
                } else {
                    AuthScreen(authViewModel)
                }
            }
            composable(
                route = NavRoutes.ListingDetail.route,
                arguments = listOf(
                    navArgument("ownerAction") {
                        type = NavType.StringType
                        nullable = true
                        defaultValue = null
                    }
                )
            ) { entry ->
                val listingId = entry.arguments?.getString("id").orEmpty()
                val ownerAction = entry.arguments?.getString("ownerAction")
                ListingDetailScreen(
                    listingId = listingId,
                    ownerAction = ownerAction,
                    isAuthenticated = authUi.isAuthenticated,
                    viewModel = listingDetailViewModel,
                    onBack = { navController.popBackStack() },
                    onRequireAuth = { navController.navigate(NavRoutes.Messages.route) },
                    onMessageSeller = { ownerId ->
                        messagesViewModel.openConversation(ownerId)
                        navController.navigate(NavRoutes.Messages.route)
                    }
                )
            }
        }
    }
}

@Composable
private fun IosStyleTabBar(
    items: List<BottomItem>,
    currentRoute: String?,
    onTabClick: (String) -> Unit,
    onCreateClick: () -> Unit
) {
    val navAccent = Color(0xFF2B7EA1)
    val navAccentStrong = Color(0xFF4F9DC0)
    val isRtl = LocalLayoutDirection.current == LayoutDirection.Rtl
    val displayItems = if (isRtl) items.reversed() else items
    val leftItems = displayItems.take(2)
    val rightItems = displayItems.takeLast(2)

    CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Ltr) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color(0xFF050B26))
                .padding(horizontal = 12.dp)
                .padding(bottom = 2.dp)
        ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(
                    elevation = 16.dp,
                    shape = RoundedCornerShape(24.dp),
                    clip = false,
                    ambientColor = Color.Black.copy(alpha = 0.28f),
                    spotColor = Color.Black.copy(alpha = 0.28f)
                )
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(24.dp))
                    .background(Color(0xFF050B26))
            ) {
                Box(
                    modifier = Modifier
                        .align(Alignment.TopCenter)
                        .fillMaxWidth()
                        .height(1.dp)
                        .background(Color.White.copy(alpha = 0.08f))
                )

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 10.dp)
                        .padding(top = 16.dp, bottom = 10.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    if (displayItems.size >= 4) {
                        TabBarButton(
                            item = displayItems[0],
                            selected = currentRoute == displayItems[0].route.route,
                            onClick = { onTabClick(displayItems[0].route.route) },
                            modifier = Modifier.weight(1f)
                        )
                        TabBarButton(
                            item = displayItems[1],
                            selected = currentRoute == displayItems[1].route.route,
                            onClick = { onTabClick(displayItems[1].route.route) },
                            modifier = Modifier.weight(1f)
                        )

                        // Reserved center slot for the floating create button.
                        Spacer(modifier = Modifier.weight(1f))

                        TabBarButton(
                            item = displayItems[2],
                            selected = currentRoute == displayItems[2].route.route,
                            onClick = { onTabClick(displayItems[2].route.route) },
                            modifier = Modifier.weight(1f)
                        )
                        TabBarButton(
                            item = displayItems[3],
                            selected = currentRoute == displayItems[3].route.route,
                            onClick = { onTabClick(displayItems[3].route.route) },
                            modifier = Modifier.weight(1f)
                        )
                    } else {
                        leftItems.forEach { item ->
                            TabBarButton(
                                item = item,
                                selected = currentRoute == item.route.route,
                                onClick = { onTabClick(item.route.route) },
                                modifier = Modifier.weight(1f)
                            )
                        }

                        Spacer(modifier = Modifier.weight(1f))

                        rightItems.forEach { item ->
                            TabBarButton(
                                item = item,
                                selected = currentRoute == item.route.route,
                                onClick = { onTabClick(item.route.route) },
                                modifier = Modifier.weight(1f)
                            )
                        }
                    }
                }
            }

            Box(
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .offset(y = (-40).dp)
                    .size(80.dp)
                    .clip(CircleShape)
                    .background(Color(0xFF050B26))
            )
        }

        Box(
            modifier = Modifier
                .align(Alignment.TopCenter)
                .offset(y = (-34).dp)
                .size(68.dp)
                .shadow(
                    elevation = 14.dp,
                    shape = CircleShape,
                    clip = false,
                    ambientColor = navAccent.copy(alpha = 0.42f),
                    spotColor = navAccent.copy(alpha = 0.42f)
                )
                .clip(CircleShape)
                .background(
                    brush = Brush.linearGradient(
                        colors = listOf(navAccentStrong, navAccent)
                    ),
                    shape = CircleShape
                )
                .border(4.dp, Color.White.copy(alpha = 0.8f), CircleShape)
                .clickable(onClick = onCreateClick),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Default.Add,
                contentDescription = null,
                tint = Color.White,
                modifier = Modifier.size(30.dp)
            )
        }

        Spacer(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .background(Color(0xFF050B26))
                .windowInsetsBottomHeight(WindowInsets.navigationBars)
        )
        }
    }
}

@Composable
private fun TabBarButton(
    item: BottomItem,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val iconColor by animateColorAsState(
        targetValue = if (selected) Color(0xFF4F9DC0) else Color.White.copy(alpha = 0.62f),
        label = "tab_icon_color"
    )
    val textColor by animateColorAsState(
        targetValue = if (selected) Color.White else Color.White.copy(alpha = 0.62f),
        label = "tab_text_color"
    )
    val indicatorColor by animateColorAsState(
        targetValue = if (selected) Color(0xFF4F9DC0) else Color.Transparent,
        label = "tab_indicator_color"
    )

    Column(
        modifier = modifier
            .clickable(onClick = onClick)
            .padding(vertical = 2.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            imageVector = if (selected) item.selectedIcon else item.unselectedIcon,
            contentDescription = stringResource(item.labelRes),
            tint = iconColor,
            modifier = Modifier.size(22.dp)
        )
        Text(
            text = stringResource(item.labelRes),
            color = textColor,
            fontSize = 10.sp,
            fontWeight = if (selected) FontWeight.SemiBold else FontWeight.Medium,
            maxLines = 1
        )
        Box(
            modifier = Modifier
                .padding(top = 4.dp)
                .size(width = 16.dp, height = 2.dp)
                .background(indicatorColor, RoundedCornerShape(999.dp))
        )
    }
}
