package com.souqira.android.ui.screen.listings

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.PhotoLibrary
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.souqira.android.R
import com.souqira.android.data.model.BusinessListing
import com.souqira.android.ui.viewmodel.MyListingsViewModel

@Composable
fun MyListingsScreen(
    viewModel: MyListingsViewModel,
    currentUserId: String?,
    onBack: () -> Unit,
    onOpenListing: (String) -> Unit,
    onEditDetails: (String) -> Unit,
    onEditPhotos: (String) -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(currentUserId) {
        viewModel.refresh(currentUserId)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFFF2F6F9))
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 14.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(Color.White)
                    .clickable(onClick = onBack),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = stringResource(R.string.ui_back),
                    tint = Color(0xFF0F2240)
                )
            }

            Text(
                text = stringResource(R.string.profile_my_listings),
                style = MaterialTheme.typography.headlineSmall,
                color = Color(0xFF0F2240),
                fontWeight = FontWeight.Bold
            )
        }

        when {
            uiState.isLoading && uiState.listings.isEmpty() -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = Color(0xFF0A4F66))
                }
            }

            !uiState.errorMessage.isNullOrBlank() -> {
                Text(
                    text = localizeMyListingsMessage(uiState.errorMessage),
                    color = MaterialTheme.colorScheme.error,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                )
            }

            uiState.listings.isEmpty() -> {
                Text(
                    text = stringResource(R.string.profile_my_listings_empty),
                    color = Color(0xFF6B7FA3),
                    style = MaterialTheme.typography.bodyLarge,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                )
            }

            else -> {
                LazyColumn(
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    items(uiState.listings) { listing ->
                        MyListingItem(
                            listing = listing,
                            onClick = { onOpenListing(listing.id) },
                            onEditDetails = { onEditDetails(listing.id) },
                            onEditPhotos = { onEditPhotos(listing.id) }
                        )
                    }

                    item { Spacer(modifier = Modifier.height(80.dp)) }
                }
            }
        }
    }
}

@Composable
private fun localizeMyListingsMessage(message: String?): String {
    val raw = message ?: return ""
    return when (raw) {
        "Failed to load your listings" -> stringResource(R.string.msg_failed_load_my_listings)
        else -> raw
    }
}

@Composable
private fun MyListingItem(
    listing: BusinessListing,
    onClick: () -> Unit,
    onEditDetails: () -> Unit,
    onEditPhotos: () -> Unit
) {
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(10.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            AsyncImage(
                model = listing.images.firstOrNull(),
                contentDescription = listing.title,
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .size(76.dp)
                    .clip(RoundedCornerShape(10.dp))
            )

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = listing.title,
                    style = MaterialTheme.typography.titleMedium,
                    color = Color(0xFF0F2240),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    fontWeight = FontWeight.SemiBold
                )
                Text(
                    text = listing.location,
                    style = MaterialTheme.typography.bodyMedium,
                    color = Color(0xFF6B7FA3),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = "${listing.currency.uppercase()} ${listing.price.toInt()}",
                    style = MaterialTheme.typography.titleSmall,
                    color = Color(0xFF0A4F66),
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(top = 4.dp)
                )
            }
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 10.dp)
                .padding(bottom = 10.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            MyListingActionButton(
                modifier = Modifier.weight(1f),
                text = stringResource(R.string.profile_my_listings_edit_details),
                icon = Icons.Default.Edit,
                onClick = onEditDetails
            )
            MyListingActionButton(
                modifier = Modifier.weight(1f),
                text = stringResource(R.string.profile_my_listings_edit_photos),
                icon = Icons.Default.PhotoLibrary,
                onClick = onEditPhotos
            )
        }
    }
}

@Composable
private fun MyListingActionButton(
    modifier: Modifier = Modifier,
    text: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    onClick: () -> Unit
) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(999.dp))
            .background(Color(0xFF0A4F66))
            .clickable(onClick = onClick)
            .padding(horizontal = 12.dp, vertical = 10.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = Color.White,
            modifier = Modifier.size(16.dp)
        )
        Spacer(modifier = Modifier.size(6.dp))
        Text(
            text = text,
            color = Color.White,
            style = MaterialTheme.typography.labelLarge,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}
