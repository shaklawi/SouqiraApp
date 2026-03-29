package com.souqira.android.ui.screen.listings

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.snapshotFlow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.filter
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.Composable
import androidx.compose.animation.animateColorAsState
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.platform.LocalContext
import coil.compose.AsyncImage
import coil.ImageLoader
import coil.decode.SvgDecoder
import coil.request.ImageRequest
import com.souqira.android.R
import com.souqira.android.ui.viewmodel.ListingsViewModel

enum class ListingsFilterMode {
    CATEGORY,
    REGION
}

@Composable
@Suppress("UNUSED_PARAMETER")
fun ListingsScreen(
    title: String,
    viewModel: ListingsViewModel,
    isAuthenticated: Boolean,
    filterMode: ListingsFilterMode = ListingsFilterMode.CATEGORY,
    onOpenListing: (String) -> Unit,
    onCreateAd: () -> Unit = {},
    onRequireAuth: () -> Unit,
    onSettingsClick: () -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsState()
    var search by remember { mutableStateOf("") }
    val isRegionMode = filterMode == ListingsFilterMode.REGION
    val selectedCategory = uiState.filter.category
    val selectedRegion = uiState.filter.region
    val searchHint = if (filterMode == ListingsFilterMode.CATEGORY) {
        stringResource(R.string.search_home_hint)
    } else if (!selectedRegion.isNullOrBlank()) {
        stringResource(R.string.search_home_hint)
    } else {
        stringResource(R.string.search_cities_hint)
    }
    val backgroundGradient = remember {
        Brush.linearGradient(
            colors = listOf(
                Color(0x1F083A4D),
                Color(0x140A4F66),
                Color.White
            )
        )
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(brush = backgroundGradient)
    ) {
        val filteredRegions = remember(search, uiState.regions) {
            val q = search.trim().lowercase()
            if (q.isBlank()) {
                uiState.regions
            } else {
                uiState.regions.filter { region ->
                    region.name.lowercase().contains(q) || region.id.lowercase().contains(q)
                }
            }
        }

        LaunchedEffect(filterMode) {
            if (isRegionMode) {
                viewModel.updateCategory(null)
                viewModel.updateRegion(null)
                viewModel.updateSearch("")
            }
        }

        val listState = rememberLazyListState()
        val shouldLoadMore = remember {
            derivedStateOf {
                val lastVisible = listState.layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: 0
                val total = listState.layoutInfo.totalItemsCount
                total > 0 && lastVisible >= total - 3
            }
        }
        LaunchedEffect(listState) {
            snapshotFlow { shouldLoadMore.value }
                .distinctUntilChanged()
                .filter { it }
                .collect {
                    if ((!isRegionMode || !selectedRegion.isNullOrBlank()) &&
                        uiState.hasMorePages && !uiState.isLoading
                    ) {
                        viewModel.loadNextPage()
                    }
                }
        }

        LazyColumn(
            state = listState,
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            if (filterMode == ListingsFilterMode.CATEGORY) {
                item {
                    HeroHeader(
                        onSettingsClick = onSettingsClick
                    )
                }
            } else {
                item {
                    Column(modifier = Modifier.padding(horizontal = 16.dp, vertical = 14.dp)) {
                        Text(
                            text = title,
                            style = MaterialTheme.typography.headlineMedium,
                            color = Color(0xFF132B3A)
                        )
                        Text(
                            text = stringResource(R.string.business_marketplace),
                            style = MaterialTheme.typography.bodyMedium,
                            color = Color(0xFF6D8190),
                            modifier = Modifier.padding(top = 2.dp)
                        )
                    }
                }
            }

            item {
                Column(modifier = Modifier.padding(horizontal = 16.dp)) {
                    OutlinedTextField(
                        value = search,
                        onValueChange = {
                            search = it
                            if (!isRegionMode || !selectedRegion.isNullOrBlank()) {
                                viewModel.updateSearch(it)
                                viewModel.refresh()
                            }
                        },
                        placeholder = { Text(searchHint) },
                        leadingIcon = {
                            Icon(
                                imageVector = Icons.Default.Search,
                                contentDescription = null,
                                tint = Color(0xFF6D8190)
                            )
                        },
                        shape = RoundedCornerShape(12.dp),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color(0xFF132B3A),
                            unfocusedTextColor = Color(0xFF132B3A),
                            focusedBorderColor = Color(0xFFCDDAE4),
                            unfocusedBorderColor = Color(0xFFDEE7EE),
                            focusedContainerColor = Color.White,
                            unfocusedContainerColor = Color.White,
                            cursorColor = Color(0xFF0A4F66)
                        ),
                        modifier = Modifier.fillMaxWidth()
                    )

                    if (isRegionMode) {
                        Text(
                            text = stringResource(R.string.cities_explore_title),
                            style = MaterialTheme.typography.titleMedium,
                            color = Color(0xFF153447),
                            modifier = Modifier.padding(top = 10.dp, start = 2.dp)
                        )
                    }
                }
            }

            if (uiState.isLoading && uiState.listings.isEmpty()) {
                item {
                    CircularProgressIndicator(
                        modifier = Modifier.padding(16.dp),
                        color = Color(0xFF0A4F66)
                    )
                }
            }

            if (!uiState.errorMessage.isNullOrBlank()) {
                item {
                    Text(
                        text = uiState.errorMessage ?: "",
                        color = Color(0xFFB42318),
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                    )
                }
            }

            if (filterMode == ListingsFilterMode.CATEGORY) {
                item {
                    Text(
                        text = stringResource(R.string.home_featured_listings),
                        style = MaterialTheme.typography.headlineSmall,
                        color = Color(0xFF153447),
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                    )
                }

                if (uiState.listings.isNotEmpty()) {
                    item {
                        FeaturedListingCard(
                            listing = uiState.listings.first(),
                            onOpenListing = { onOpenListing(uiState.listings.first().id) }
                        )
                    }
                }

                // Filter chips after featured/premium ads
                item {
                    LazyRow(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 4.dp),
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        item {
                            ModernFilterChip(
                                label = stringResource(R.string.filter_all),
                                selected = selectedCategory == null,
                                onClick = {
                                    viewModel.updateCategory(null)
                                    viewModel.updateRegion(null)
                                    viewModel.refresh()
                                }
                            )
                        }
                        items(uiState.categories) { category ->
                            val isSelected = selectedCategory == category.id
                            ModernFilterChip(
                                label = categoryLabel(category.id),
                                selected = isSelected,
                                onClick = {
                                    viewModel.updateCategory(if (isSelected) null else category.id)
                                    viewModel.updateRegion(null)
                                    viewModel.refresh()
                                }
                            )
                        }
                    }
                }

                if (uiState.listings.isNotEmpty()) {
                    item {
                        Text(
                            text = stringResource(R.string.home_all_listings),
                            style = MaterialTheme.typography.headlineSmall,
                            color = Color(0xFF153447),
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                        )
                    }

                    itemsIndexed(uiState.listings.drop(1).chunked(2)) { _, rowItems ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 16.dp),
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            rowItems.forEach { listing ->
                                CompactListingCard(
                                    listing = listing,
                                    modifier = Modifier.weight(1f),
                                    onOpenListing = { onOpenListing(listing.id) }
                                )
                            }
                            if (rowItems.size == 1) {
                                Spacer(modifier = Modifier.weight(1f))
                            }
                        }
                    }
                }
            } else {
                if (selectedRegion.isNullOrBlank()) {
                    if (filteredRegions.isEmpty()) {
                        item {
                            Text(
                                text = stringResource(R.string.cities_no_match),
                                color = Color(0xFF6D8190),
                                style = MaterialTheme.typography.bodyLarge,
                                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                            )
                        }
                    } else {
                        items(filteredRegions.chunked(2)) { rowItems ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(horizontal = 16.dp),
                                horizontalArrangement = Arrangement.spacedBy(12.dp)
                            ) {
                                rowItems.forEach { region ->
                                    CityCard(
                                        regionId = region.id,
                                        modifier = Modifier.weight(1f),
                                        onClick = {
                                            search = ""
                                            viewModel.updateRegion(region.id)
                                            viewModel.updateCategory(null)
                                            viewModel.updateSearch("")
                                            viewModel.refresh()
                                        }
                                    )
                                }
                                if (rowItems.size == 1) {
                                    Spacer(modifier = Modifier.weight(1f))
                                }
                            }
                        }
                    }
                } else {
                    item {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 16.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = regionLabel(selectedRegion),
                                style = MaterialTheme.typography.titleMedium,
                                color = Color(0xFF153447),
                                fontWeight = FontWeight.Bold
                            )
                            ModernFilterChip(
                                label = stringResource(R.string.filter_all),
                                selected = false,
                                onClick = {
                                    search = ""
                                    viewModel.updateRegion(null)
                                    viewModel.updateSearch("")
                                    viewModel.refresh()
                                }
                            )
                        }
                    }

                    items(uiState.listings) { listing ->
                        Card(
                            modifier = Modifier
                                .padding(horizontal = 16.dp)
                                .fillMaxWidth()
                                .clickable { onOpenListing(listing.id) },
                            shape = RoundedCornerShape(22.dp),
                            colors = CardDefaults.cardColors(
                                containerColor = Color.White.copy(alpha = 0.93f)
                            ),
                            elevation = CardDefaults.cardElevation(defaultElevation = 6.dp)
                        ) {
                            Column {
                                if (listing.images.isNotEmpty()) {
                                    AsyncImage(
                                        model = listing.images.first(),
                                        contentDescription = listing.title,
                                        contentScale = ContentScale.Crop,
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .height(150.dp)
                                    )
                                }

                                Column(modifier = Modifier.padding(14.dp)) {
                                    Text(
                                        listing.title,
                                        fontWeight = FontWeight.Bold,
                                        color = MaterialTheme.colorScheme.onSurface,
                                        maxLines = 2
                                    )
                                    Text(
                                        listing.location,
                                        style = MaterialTheme.typography.bodyMedium,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                                        modifier = Modifier.padding(top = 4.dp)
                                    )
                                    Row(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .padding(top = 8.dp),
                                        horizontalArrangement = Arrangement.Start,
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Text(
                                            text = "${listing.currency.uppercase()} ${listing.price.toInt()}",
                                            style = MaterialTheme.typography.titleLarge,
                                            color = MaterialTheme.colorScheme.primary
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }

            item {
                if ((!isRegionMode || !selectedRegion.isNullOrBlank()) && uiState.isLoading && uiState.listings.isNotEmpty()) {
                    CircularProgressIndicator(
                        modifier = Modifier.padding(vertical = 16.dp),
                        color = Color(0xFF0A4F66)
                    )
                }
                Spacer(modifier = Modifier.height(98.dp))
            }
        }
    }
}

@Composable
private fun CityCard(
    regionId: String,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Card(
        modifier = modifier
            .heightIn(min = 128.dp)
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = 0.94f)),
        elevation = CardDefaults.cardElevation(defaultElevation = 5.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 14.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(38.dp)
                    .clip(CircleShape)
                    .background(Color(0xFFE6F0F6)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = cityEmoji(regionId),
                    fontSize = 17.sp,
                    color = Color(0xFF2C6783)
                )
            }

            Text(
                text = regionLabel(regionId),
                style = MaterialTheme.typography.titleMedium,
                color = Color(0xFF153447),
                fontWeight = FontWeight.Bold,
                maxLines = 1
            )

            Text(
                text = stringResource(R.string.cities_card_hint),
                style = MaterialTheme.typography.bodySmall,
                color = Color(0xFF6D8190),
                maxLines = 2
            )
        }
    }
}

private fun cityEmoji(regionId: String): String {
    return when (regionId) {
        "baghdad" -> "🏛"
        "basra" -> "⚓"
        "erbil" -> "⛰"
        "mosul" -> "🏰"
        "sulaymaniyah" -> "🌄"
        "najaf" -> "🕌"
        "karbala" -> "✨"
        "kirkuk" -> "🛢"
        "duhok" -> "🌿"
        "ramadi" -> "☀"
        else -> "📍"
    }
}

@Composable
private fun FeaturedListingCard(
    listing: com.souqira.android.data.model.BusinessListing,
    onOpenListing: () -> Unit
) {
    Card(
        modifier = Modifier
            .padding(horizontal = 16.dp)
            .fillMaxWidth()
            .clickable(onClick = onOpenListing),
        shape = RoundedCornerShape(26.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = 0.94f)),
        elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
    ) {
        Column {
            Box {
                if (listing.images.isNotEmpty()) {
                    AsyncImage(
                        model = listing.images.first(),
                        contentDescription = listing.title,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(220.dp)
                    )
                }

                Box(
                    modifier = Modifier
                        .align(Alignment.BottomStart)
                        .fillMaxWidth()
                        .height(90.dp)
                        .background(
                            Brush.verticalGradient(
                                colors = listOf(
                                    Color.Transparent,
                                    Color.Black.copy(alpha = 0.55f)
                                )
                            )
                        )
                )

                Box(
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(14.dp)
                        .clip(RoundedCornerShape(20.dp))
                        .background(Color(0xFFE7B80E))
                        .padding(horizontal = 12.dp, vertical = 6.dp)
                ) {
                    Text(
                        text = stringResource(R.string.home_badge_featured),
                        color = Color.White,
                        style = MaterialTheme.typography.labelLarge
                    )
                }
            }

            Column(modifier = Modifier.padding(14.dp)) {
                Text(
                    text = listing.title,
                    style = MaterialTheme.typography.titleLarge,
                    color = Color(0xFF15283A),
                    maxLines = 2
                )
                Text(
                    text = "${listing.currency.uppercase()} ${listing.price.toInt()}",
                    style = MaterialTheme.typography.headlineSmall,
                    color = Color(0xFF15283A),
                    modifier = Modifier.padding(top = 6.dp)
                )
                Text(
                    text = listing.description,
                    style = MaterialTheme.typography.bodyLarge,
                    color = Color(0xFF5F7587),
                    maxLines = 2,
                    modifier = Modifier.padding(top = 8.dp)
                )
            }
        }
    }
}

@Composable
private fun CompactListingCard(
    listing: com.souqira.android.data.model.BusinessListing,
    modifier: Modifier = Modifier,
    onOpenListing: () -> Unit
) {
    Card(
        modifier = modifier
            .height(295.dp)
            .clickable(onClick = onOpenListing),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = 0.94f)),
        elevation = CardDefaults.cardElevation(defaultElevation = 6.dp)
    ) {
        Column {
            if (listing.images.isNotEmpty()) {
                AsyncImage(
                    model = listing.images.first(),
                    contentDescription = listing.title,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(140.dp)
                )
            }
            Column(modifier = Modifier.padding(10.dp)) {
                Text(
                    text = listing.title,
                    style = MaterialTheme.typography.titleMedium,
                    color = Color(0xFF15283A),
                    maxLines = 2
                )
                Text(
                    text = listing.description,
                    style = MaterialTheme.typography.bodyMedium,
                    color = Color(0xFF5F7587),
                    maxLines = 2,
                    modifier = Modifier.padding(top = 4.dp)
                )
                Text(
                    text = "${listing.currency.uppercase()} ${listing.price.toInt()}",
                    style = MaterialTheme.typography.labelLarge,
                    color = Color(0xFF0A4F66),
                    modifier = Modifier.padding(top = 6.dp)
                )
            }
        }
    }
}

@Composable
private fun HeroHeader(
    onSettingsClick: () -> Unit
) {
    val context = LocalContext.current
    val svgImageLoader = remember {
        ImageLoader.Builder(context)
            .components {
                add(SvgDecoder.Factory())
            }
            .build()
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(150.dp)
            .background(
                Brush.linearGradient(
                    colors = listOf(
                        Color(0xFF083A4D),
                        Color(0xFF0A4F66),
                        Color(0xFF1E5F7B)
                    )
                )
            )
            .drawBehind {
                drawCircle(
                    color = Color.White.copy(alpha = 0.08f),
                    radius = size.minDimension * 0.35f,
                    center = Offset(x = size.width * 0.12f, y = size.height * 0.14f),
                    style = Stroke(width = 2.5f)
                )
                drawCircle(
                    color = Color.White.copy(alpha = 0.06f),
                    radius = size.minDimension * 0.28f,
                    center = Offset(x = size.width * 0.88f, y = size.height * 0.92f),
                    style = Stroke(width = 2f)
                )
                drawLine(
                    color = Color.White.copy(alpha = 0.08f),
                    start = Offset(x = size.width * 0.28f, y = size.height * 0.12f),
                    end = Offset(x = size.width * 0.96f, y = size.height * 0.12f),
                    strokeWidth = 1.8f
                )
            }
    ) {
        AsyncImage(
            model = ImageRequest.Builder(context)
                .data("file:///android_asset/souqira-logo.svg")
                .crossfade(true)
                .build(),
            imageLoader = svgImageLoader,
            error = painterResource(id = R.drawable.logo),
            fallback = painterResource(id = R.drawable.logo),
            contentDescription = stringResource(R.string.app_name),
            contentScale = ContentScale.Fit,
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .height(118.dp)
                .padding(horizontal = 12.dp, vertical = 6.dp)
        )

        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            horizontalArrangement = Arrangement.End,
            verticalAlignment = Alignment.Top
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(RoundedCornerShape(22.dp))
                    .background(Color.White.copy(alpha = 0.14f))
                    .border(1.dp, Color.White.copy(alpha = 0.2f), RoundedCornerShape(22.dp))
                    .clickable(onClick = onSettingsClick),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Settings,
                    contentDescription = null,
                    tint = Color.White
                )
            }
        }
    }
}

@Composable
private fun ModernFilterChip(
    label: String,
    selected: Boolean,
    onClick: () -> Unit
) {
    val container by animateColorAsState(
        targetValue = if (selected) Color(0xFFE3EDF4) else Color(0xFFF0F4F8),
        label = "filter_chip_container"
    )
    val content by animateColorAsState(
        targetValue = if (selected) Color(0xFF0A4F66) else Color(0xFF2C5068),
        label = "filter_chip_content"
    )
    val border by animateColorAsState(
        targetValue = if (selected) Color(0xFFAEC4D3) else Color(0xFFCDD9E4),
        label = "filter_chip_border"
    )

    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(20.dp))
            .background(container)
            .border(width = 1.dp, color = border, shape = RoundedCornerShape(20.dp))
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 10.dp)
    ) {
        Text(
            text = label,
            color = content,
            style = MaterialTheme.typography.labelLarge
        )
    }
}

@Composable
private fun categoryLabel(categoryId: String): String {
    val normalizedCategoryId = categoryId
        .trim()
        .lowercase()
        .replace("-", "_")
        .replace(" ", "_")

    return when (normalizedCategoryId) {
        "restaurants_cafes" -> stringResource(R.string.category_restaurants_cafes)
        "retail_stores" -> stringResource(R.string.category_retail_stores)
        "auto_services" -> stringResource(R.string.category_auto_services)
        "beauty_salons" -> stringResource(R.string.category_beauty_salons)
        "ecommerce_online_business" -> stringResource(R.string.category_ecommerce_online_business)
        "it_tech" -> stringResource(R.string.category_it_tech)
        "medical_health_services" -> stringResource(R.string.category_medical_health_services)
        "education_training" -> stringResource(R.string.category_education_training)
        "real_estate_construction" -> stringResource(R.string.category_real_estate_construction)
        "transport_logistics" -> stringResource(R.string.category_transport_logistics)
        "manufacturing_industry" -> stringResource(R.string.category_manufacturing_industry)
        "agriculture_food_production" -> stringResource(R.string.category_agriculture_food_production)
        "financial_accounting_services" -> stringResource(R.string.category_financial_accounting_services)
        "marketing_advertising" -> stringResource(R.string.category_marketing_advertising)
        "tourism_travel" -> stringResource(R.string.category_tourism_travel)
        "freelance_services" -> stringResource(R.string.category_freelance_services)
        "home_based_businesses" -> stringResource(R.string.category_home_based_businesses)
        "cleaning_maintenance" -> stringResource(R.string.category_cleaning_maintenance)
        "wholesale_distribution" -> stringResource(R.string.category_wholesale_distribution)
        "other" -> stringResource(R.string.category_other)
        "find_a_partner" -> stringResource(R.string.category_find_a_partner)
        "find_an_investor" -> stringResource(R.string.category_find_an_investor)
        else -> categoryId
    }
}

@Composable
private fun regionLabel(regionId: String): String {
    return when (regionId) {
        "baghdad" -> stringResource(R.string.region_baghdad)
        "basra" -> stringResource(R.string.region_basra)
        "erbil" -> stringResource(R.string.region_erbil)
        "mosul" -> stringResource(R.string.region_mosul)
        "sulaymaniyah" -> stringResource(R.string.region_sulaymaniyah)
        "najaf" -> stringResource(R.string.region_najaf)
        "karbala" -> stringResource(R.string.region_karbala)
        "kirkuk" -> stringResource(R.string.region_kirkuk)
        "duhok" -> stringResource(R.string.region_duhok)
        "ramadi" -> stringResource(R.string.region_ramadi)
        else -> regionId
    }
}
