package com.souqira.android.ui.screen.listings

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.souqira.android.R
import com.souqira.android.ui.viewmodel.FavoritesViewModel

@Composable
fun FavoritesScreen(
    viewModel: FavoritesViewModel,
    onOpenListing: (String) -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(Unit) {
        viewModel.loadFavorites()
    }

    Column(modifier = Modifier.fillMaxSize()) {
        Text(
            text = stringResource(R.string.nav_favorites),
            style = MaterialTheme.typography.headlineMedium,
            modifier = Modifier.padding(16.dp)
        )

        if (uiState.isLoading) {
            CircularProgressIndicator(modifier = Modifier.padding(16.dp))
        }

        if (!uiState.errorMessage.isNullOrBlank()) {
            Text(uiState.errorMessage ?: "", modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp))
        }

        if (!uiState.isLoading && uiState.favorites.isEmpty()) {
            Text(stringResource(R.string.favorites_empty), modifier = Modifier.padding(16.dp))
        }

        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(uiState.favorites) { listing ->
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { onOpenListing(listing.id) },
                    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                ) {
                    Column(modifier = Modifier.padding(14.dp)) {
                        Text(listing.title, fontWeight = FontWeight.SemiBold)
                        Text(listing.location, style = MaterialTheme.typography.bodySmall)
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(top = 10.dp),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text("${listing.currency.uppercase()} ${listing.price.toInt()}")
                            Button(onClick = {
                                viewModel.toggleFavorite(listing.id, isFavorite = true)
                            }) {
                                Text(stringResource(R.string.favorites_remove))
                            }
                        }
                    }
                }
            }
        }
    }
}
