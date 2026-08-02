package com.souqira.android.ui.screen.listings

import android.content.Intent
import android.content.ActivityNotFoundException
import android.content.Context
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.Chat
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Map
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.AddPhotoAlternate
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Share
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.ChevronLeft
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.ui.graphics.vector.ImageVector
import coil.compose.AsyncImage
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.TextButton
import android.widget.Toast
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import com.google.gson.JsonElement
import com.souqira.android.R
import androidx.compose.ui.res.pluralStringResource
import androidx.compose.ui.res.stringResource
import com.souqira.android.ui.viewmodel.ListingDetailViewModel
import java.io.File
import kotlinx.coroutines.delay

@Composable
@OptIn(ExperimentalFoundationApi::class)
fun ListingDetailScreen(
    listingId: String,
    ownerAction: String? = null,
    isAuthenticated: Boolean,
    viewModel: ListingDetailViewModel,
    onBack: () -> Unit,
    onRequireAuth: () -> Unit,
    onMessageSeller: (String) -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current
    var showBlockDialog by remember { mutableStateOf(false) }
    var showReportDialog by remember { mutableStateOf(false) }
    var showEditDialog by remember { mutableStateOf(false) }
    var showImageViewer by remember { mutableStateOf(false) }
    var imageViewerIndex by remember { mutableStateOf(0) }
    var hasHandledOwnerAction by remember(listingId, ownerAction) { mutableStateOf(false) }
    val pendingImageUris = remember { mutableStateListOf<Uri>() }
    val contentScrollState = rememberScrollState()
    val imagePicker = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetMultipleContents()
    ) { uris ->
        val room = (10 - pendingImageUris.size).coerceAtLeast(0)
        if (room > 0) {
            pendingImageUris.addAll(uris.take(room))
        }
    }

    LaunchedEffect(listingId, isAuthenticated) {
        viewModel.loadListing(id = listingId, tryMineFirst = isAuthenticated)
    }

    val listing = uiState.listing
    val editableImageUrls = remember(listing?.id) { mutableStateListOf<String>() }
    var editTitle by remember(listing?.id) { mutableStateOf("") }
    var editDescription by remember(listing?.id) { mutableStateOf("") }
    var editPrice by remember(listing?.id) { mutableStateOf("") }
    var editLocation by remember(listing?.id) { mutableStateOf("") }
    var editPhone by remember(listing?.id) { mutableStateOf("") }

    LaunchedEffect(listing?.images) {
        editableImageUrls.clear()
        editableImageUrls.addAll(listing?.images.orEmpty())
    }

    LaunchedEffect(listing?.id) {
        val current = listing ?: return@LaunchedEffect
        editTitle = current.title
        editDescription = current.description
        editPrice = current.price.toString()
        editLocation = current.location
        editPhone = current.phone.orEmpty()
    }

    LaunchedEffect(uiState.statusMessage) {
        val message = uiState.statusMessage ?: return@LaunchedEffect
        Toast.makeText(context, localizeListingDetailMessage(context, message), Toast.LENGTH_LONG).show()
        if (message.contains("images updated", ignoreCase = true)) {
            pendingImageUris.clear()
        }
        if (message.contains("listing updated", ignoreCase = true)) {
            showEditDialog = false
        }
        viewModel.consumeStatusMessage()
    }

    LaunchedEffect(uiState.errorMessage) {
        val message = uiState.errorMessage ?: return@LaunchedEffect
        Toast.makeText(context, localizeListingDetailMessage(context, message), Toast.LENGTH_LONG).show()
        viewModel.consumeErrorMessage()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFFF2F6F9))
    ) {
        if (uiState.isLoading && listing == null) {
            CircularProgressIndicator(
                modifier = Modifier.align(Alignment.Center),
                color = MaterialTheme.colorScheme.primary
            )
            return@Box
        }

        if (!uiState.errorMessage.isNullOrBlank() && listing == null) {
            Text(
                text = uiState.errorMessage ?: "",
                modifier = Modifier
                    .align(Alignment.Center)
                    .padding(24.dp)
            )
            return@Box
        }

        if (listing == null) return@Box

        val imageUrls = if (listing.images.isNotEmpty()) listing.images else listOf("")
        val pagerState = rememberPagerState(pageCount = { imageUrls.size })
        val ownerId = extractOwnerId(listing.owner)

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(contentScrollState)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(360.dp)
            ) {
                HorizontalPager(
                    state = pagerState,
                    modifier = Modifier.fillMaxSize()
                ) { page ->
                    val imageUrl = imageUrls[page]
                    if (imageUrl.isNotBlank()) {
                        AsyncImage(
                            model = imageUrl,
                            contentDescription = listing.title,
                            contentScale = ContentScale.Crop,
                            modifier = Modifier
                                .fillMaxSize()
                                .clickable {
                                    imageViewerIndex = page
                                    showImageViewer = true
                                }
                        )
                    } else {
                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .background(
                                    Brush.linearGradient(
                                        listOf(Color(0xFF2D4A7A), Color(0xFF1B2E52))
                                    )
                                )
                        )
                    }
                }

                if (imageUrls.size > 1) {
                    Row(
                        modifier = Modifier
                            .align(Alignment.BottomCenter)
                            .padding(bottom = 18.dp),
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        repeat(imageUrls.size) { index ->
                            val isSelected = pagerState.currentPage == index
                            Box(
                                modifier = Modifier
                                    .size(if (isSelected) 9.dp else 7.dp)
                                    .clip(CircleShape)
                                    .background(
                                        if (isSelected) Color.White else Color.White.copy(alpha = 0.55f)
                                    )
                            )
                        }
                    }
                }

                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .fillMaxHeight(0.55f)
                        .align(Alignment.BottomCenter)
                        .background(
                            Brush.verticalGradient(
                                listOf(Color.Transparent, Color.Black.copy(alpha = 0.55f))
                            )
                        )
                )

                if (listing.saleStatus.equals("sold", ignoreCase = true)) {
                    Text(
                        text = stringResource(R.string.listing_status_sold),
                        color = Color.White,
                        fontWeight = FontWeight.Black,
                        modifier = Modifier
                            .align(Alignment.BottomCenter)
                            .padding(bottom = 24.dp)
                            .background(Color(0xFFE53935), RoundedCornerShape(999.dp))
                            .padding(horizontal = 14.dp, vertical = 6.dp)
                    )
                }

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 50.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    CircleIconButton(
                        imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = stringResource(R.string.ui_back),
                        onClick = onBack
                    )

                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        CircleIconButton(
                            imageVector = Icons.Default.Share,
                            contentDescription = stringResource(R.string.ui_share),
                            onClick = {
                                val sendIntent = Intent(Intent.ACTION_SEND).apply {
                                    type = "text/plain"
                                    putExtra(Intent.EXTRA_TEXT, "${listing.title} - ${listing.location}")
                                }
                                context.startActivity(
                                    Intent.createChooser(sendIntent, context.getString(R.string.ui_share_chooser_title))
                                )
                            }
                        )

                        CircleIconButton(
                            imageVector = if (uiState.isFavorite) Icons.Default.Favorite else Icons.Outlined.FavoriteBorder,
                            contentDescription = if (uiState.isFavorite) {
                                stringResource(R.string.ui_favorite)
                            } else {
                                stringResource(R.string.ui_not_favorite)
                            },
                            highlighted = uiState.isFavorite,
                            onClick = {
                                if (isAuthenticated) {
                                    viewModel.toggleFavorite()
                                } else {
                                    onRequireAuth()
                                }
                            }
                        )
                    }
                }
            }

            Surface(
                shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp),
                color = Color.White,
                modifier = Modifier
                    .fillMaxWidth()
                    .offset(y = (-24).dp)
            ) {
                Column(modifier = Modifier.padding(bottom = 24.dp)) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 20.dp, vertical = 20.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.Top
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = "${listing.currency.uppercase()} ${listing.price.toInt()}",
                                style = MaterialTheme.typography.headlineMedium,
                                color = Color(0xFF0F2240),
                                fontWeight = FontWeight.Black
                            )
                            Row(
                                modifier = Modifier.padding(top = 6.dp),
                                horizontalArrangement = Arrangement.spacedBy(8.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    listing.location,
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = Color(0xFF6B7FA3),
                                    fontWeight = FontWeight.SemiBold
                                )
                                Text("·", color = Color(0xFFC0C8D8))
                                Text(
                                    pluralStringResource(
                                        id = R.plurals.listing_views_count,
                                        count = listing.views,
                                        listing.views
                                    ),
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = Color(0xFF6B7FA3),
                                    fontWeight = FontWeight.SemiBold
                                )
                            }
                        }

                        Text(
                            text = listingDetailCategoryLabel(listing.category),
                            color = Color(0xFF1A4D7C),
                            style = MaterialTheme.typography.labelLarge,
                            modifier = Modifier
                                .background(Color(0xFFE8F2FF), RoundedCornerShape(999.dp))
                                .padding(horizontal = 12.dp, vertical = 7.dp)
                        )
                    }

                    Text(
                        text = listing.title,
                        style = MaterialTheme.typography.titleLarge,
                        color = Color(0xFF0F2240),
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(horizontal = 20.dp)
                    )

                    Column(
                        modifier = Modifier
                            .padding(horizontal = 20.dp, vertical = 16.dp)
                            .clip(RoundedCornerShape(16.dp))
                            .background(Color(0xFFF6F8FC))
                            .padding(16.dp)
                    ) {
                        Text(
                            text = stringResource(R.string.listing_description_title),
                            style = MaterialTheme.typography.labelLarge,
                            color = Color(0xFF6B7FA3)
                        )
                        Text(
                            text = listing.description,
                            style = MaterialTheme.typography.bodyLarge,
                            color = Color(0xFF2C3E55),
                            modifier = Modifier.padding(top = 8.dp)
                        )
                    }

                    if (showEditDialog) {
                        AlertDialog(
                            onDismissRequest = {
                                if (!uiState.isSavingDetails) {
                                    showEditDialog = false
                                }
                            },
                            title = {
                                Text(stringResource(R.string.listing_edit_details))
                            },
                            text = {
                                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                    OutlinedTextField(
                                        value = editTitle,
                                        onValueChange = { editTitle = it },
                                        label = { Text(stringResource(R.string.create_listing_field_title)) },
                                        singleLine = true,
                                        enabled = !uiState.isSavingDetails
                                    )
                                    OutlinedTextField(
                                        value = editDescription,
                                        onValueChange = { editDescription = it },
                                        label = { Text(stringResource(R.string.create_listing_field_description)) },
                                        minLines = 3,
                                        enabled = !uiState.isSavingDetails
                                    )
                                    OutlinedTextField(
                                        value = editPrice,
                                        onValueChange = { editPrice = it },
                                        label = { Text(stringResource(R.string.create_listing_field_price)) },
                                        singleLine = true,
                                        enabled = !uiState.isSavingDetails
                                    )
                                    OutlinedTextField(
                                        value = editLocation,
                                        onValueChange = { editLocation = it },
                                        label = { Text(stringResource(R.string.create_listing_region)) },
                                        singleLine = true,
                                        enabled = !uiState.isSavingDetails
                                    )
                                    OutlinedTextField(
                                        value = editPhone,
                                        onValueChange = { editPhone = it },
                                        label = { Text(stringResource(R.string.create_listing_phone)) },
                                        singleLine = true,
                                        enabled = !uiState.isSavingDetails
                                    )
                                }
                            },
                            confirmButton = {
                                TextButton(
                                    enabled = !uiState.isSavingDetails,
                                    onClick = {
                                        viewModel.updateListingDetails(
                                            title = editTitle,
                                            description = editDescription,
                                            priceText = editPrice,
                                            location = editLocation,
                                            phone = editPhone
                                        )
                                    }
                                ) {
                                    Text(
                                        if (uiState.isSavingDetails) {
                                            stringResource(R.string.listing_saving)
                                        } else {
                                            stringResource(R.string.done)
                                        }
                                    )
                                }
                            },
                            dismissButton = {
                                TextButton(
                                    enabled = !uiState.isSavingDetails,
                                    onClick = {
                                        showEditDialog = false
                                    }
                                ) {
                                    Text(stringResource(R.string.listing_action_cancel))
                                }
                            }
                        )
                    }

                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 20.dp),
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        MetaChip(
                            pluralStringResource(
                                id = R.plurals.listing_views_count,
                                count = listing.views,
                                listing.views
                            )
                        )
                        MetaChip(listing.location)
                        if (listing.isFeatured == true) {
                            MetaChip(
                                text = stringResource(R.string.home_badge_featured),
                                icon = { Icon(Icons.Default.Star, contentDescription = null, tint = Color(0xFFB07700)) },
                                accent = true
                            )
                        }
                    }

                    val mapQuery = when {
                        !listing.address.isNullOrBlank() -> listing.address
                        listing.location.isNotBlank() -> listing.location
                        else -> null
                    }

                    // Map section: exact pin when coordinates exist, otherwise query fallback.
                    listing.coordinates?.let { coords ->
                        MapSection(
                            lat = coords.lat,
                            lng = coords.lng,
                            address = listing.address,
                            title = listing.title,
                            context = context
                        )
                    } ?: mapQuery?.let { query ->
                        MapFallbackSection(
                            query = query,
                            context = context
                        )
                    }

                    Column(
                        modifier = Modifier
                            .padding(horizontal = 20.dp, vertical = 20.dp)
                            .clip(RoundedCornerShape(20.dp))
                            .background(Color(0xFFF6F8FC))
                            .padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Text(
                            text = stringResource(R.string.listing_contact_seller),
                            style = MaterialTheme.typography.titleMedium,
                            color = Color(0xFF0F2240),
                            fontWeight = FontWeight.Bold
                        )

                        if (!ownerId.isNullOrBlank()) {
                            ContactRow(
                                iconBg = Color(0xFFE8EEFF),
                                iconTint = Color(0xFF365CA8),
                                icon = Icons.AutoMirrored.Filled.Send,
                                value = stringResource(R.string.listing_send_message),
                                onClick = {
                                    if (isAuthenticated) {
                                        onMessageSeller(ownerId)
                                    } else {
                                        onRequireAuth()
                                    }
                                }
                            )
                        }

                        if (!listing.phone.isNullOrBlank()) {
                            ContactRow(
                                iconBg = Color(0xFFE8F2FF),
                                iconTint = Color(0xFF1A4D7C),
                                icon = Icons.Default.Phone,
                                value = listing.phone,
                                onClick = {
                                    val cleaned = listing.phone.replace(" ", "").replace("-", "")
                                    context.startActivity(Intent(Intent.ACTION_DIAL, Uri.parse("tel:$cleaned")))
                                }
                            )
                        }

                        val whatsapp = listing.whatsapp ?: listing.phone
                        if (!whatsapp.isNullOrBlank()) {
                            ContactRow(
                                iconBg = Color(0xFFE8FFF2),
                                iconTint = Color(0xFF1A7C4D),
                                icon = Icons.AutoMirrored.Filled.Chat,
                                value = whatsapp,
                                onClick = {
                                    val cleaned = whatsapp.replace(" ", "").replace("-", "")
                                    context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://wa.me/$cleaned")))
                                }
                            )
                        }

                        if (!ownerId.isNullOrBlank() && isAuthenticated) {
                            ContactRow(
                                iconBg = Color(0xFFFFF3E8),
                                iconTint = Color(0xFFB45309),
                                icon = Icons.Default.Shield,
                                value = stringResource(R.string.listing_block_user),
                                onClick = { showBlockDialog = true }
                            )
                        }

                        if (isAuthenticated) {
                            ContactRow(
                                iconBg = Color(0xFFFFEBEE),
                                iconTint = Color(0xFFB3261E),
                                icon = Icons.Default.Star,
                                value = stringResource(R.string.listing_report_listing),
                                onClick = { showReportDialog = true }
                            )
                        }
                    }

                }
            }

            if (uiState.canEditListing) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp)
                        .clip(RoundedCornerShape(20.dp))
                        .background(Color.White)
                        .padding(14.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Text(
                        text = stringResource(R.string.listing_manage_photos_title),
                        style = MaterialTheme.typography.titleMedium,
                        color = Color(0xFF0F2240),
                        fontWeight = FontWeight.Bold
                    )

                    Text(
                        text = stringResource(R.string.listing_manage_photos_hint),
                        style = MaterialTheme.typography.bodySmall,
                        color = Color(0xFF6B7FA3)
                    )

                    ActionPillButton(
                        text = stringResource(R.string.listing_edit_details),
                        icon = Icons.Default.ChevronRight,
                        onClick = { showEditDialog = true }
                    )

                    if (editableImageUrls.isNotEmpty()) {
                        LazyRow(
                            contentPadding = PaddingValues(vertical = 2.dp),
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            items(editableImageUrls) { imageUrl ->
                                Box {
                                    AsyncImage(
                                        model = imageUrl,
                                        contentDescription = listing.title,
                                        contentScale = ContentScale.Crop,
                                        modifier = Modifier
                                            .size(90.dp)
                                            .clip(RoundedCornerShape(10.dp))
                                    )

                                    CircleIconButton(
                                        imageVector = Icons.Default.Delete,
                                        contentDescription = stringResource(R.string.listing_remove_photo),
                                        modifier = Modifier
                                            .align(Alignment.TopEnd)
                                            .offset(x = 8.dp, y = (-8).dp),
                                        onClick = { editableImageUrls.remove(imageUrl) }
                                    )
                                }
                            }
                        }
                    }

                    if (pendingImageUris.isNotEmpty()) {
                        LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            items(pendingImageUris) { uri ->
                                Box {
                                    AsyncImage(
                                        model = uri,
                                        contentDescription = listing.title,
                                        contentScale = ContentScale.Crop,
                                        modifier = Modifier
                                            .size(90.dp)
                                            .clip(RoundedCornerShape(10.dp))
                                    )

                                    CircleIconButton(
                                        imageVector = Icons.Default.Close,
                                        contentDescription = stringResource(R.string.listing_remove_photo),
                                        modifier = Modifier
                                            .align(Alignment.TopEnd)
                                            .offset(x = 8.dp, y = (-8).dp),
                                        onClick = { pendingImageUris.remove(uri) }
                                    )
                                }
                            }
                        }
                    }

                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        ActionPillButton(
                            modifier = Modifier.weight(1f),
                            text = stringResource(R.string.listing_add_more_photos),
                            icon = Icons.Default.AddPhotoAlternate,
                            onClick = { imagePicker.launch("image/*") }
                        )

                        ActionPillButton(
                            modifier = Modifier.weight(1f),
                            text = if (uiState.isSavingImages) {
                                stringResource(R.string.listing_saving_photos)
                            } else {
                                stringResource(R.string.listing_save_photos)
                            },
                            icon = Icons.AutoMirrored.Filled.Send,
                            enabled = !uiState.isSavingImages,
                            onClick = {
                                val files = pendingImageUris.mapNotNull { uri ->
                                    uriToTempJpeg(context, uri)
                                }
                                viewModel.updateListingImages(
                                    keepImageUrls = editableImageUrls.toList(),
                                    newImageFiles = files
                                )
                            }
                        )
                    }
                }

                Spacer(modifier = Modifier.height(18.dp))
            }
        }

        LaunchedEffect(ownerAction, uiState.canEditListing, hasHandledOwnerAction) {
            if (!uiState.canEditListing || hasHandledOwnerAction) return@LaunchedEffect
            when (ownerAction) {
                "details" -> {
                    showEditDialog = true
                    hasHandledOwnerAction = true
                }

                "photos" -> {
                    delay(120)
                    contentScrollState.animateScrollTo(contentScrollState.maxValue)
                    hasHandledOwnerAction = true
                }
            }
        }

        if (showBlockDialog && !ownerId.isNullOrBlank()) {
            AlertDialog(
                onDismissRequest = { showBlockDialog = false },
                title = { Text(text = stringResource(R.string.listing_block_user_title)) },
                text = { Text(text = stringResource(R.string.listing_block_user_message)) },
                dismissButton = {
                    TextButton(onClick = { showBlockDialog = false }) {
                        Text(text = stringResource(R.string.listing_action_cancel))
                    }
                },
                confirmButton = {
                    TextButton(
                        onClick = {
                            showBlockDialog = false
                            viewModel.blockUser(ownerId)
                        }
                    ) {
                        Text(text = stringResource(R.string.listing_action_block), color = Color(0xFFB45309))
                    }
                }
            )
        }

        if (showReportDialog) {
            AlertDialog(
                onDismissRequest = { showReportDialog = false },
                title = { Text(text = stringResource(R.string.listing_report_title)) },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text(text = stringResource(R.string.listing_report_message))
                        ReportReasonButton(label = stringResource(R.string.report_reason_spam)) {
                            showReportDialog = false
                            viewModel.reportListing("spam")
                        }
                        ReportReasonButton(label = stringResource(R.string.report_reason_inappropriate)) {
                            showReportDialog = false
                            viewModel.reportListing("inappropriate")
                        }
                        ReportReasonButton(label = stringResource(R.string.report_reason_fake)) {
                            showReportDialog = false
                            viewModel.reportListing("fake")
                        }
                        ReportReasonButton(label = stringResource(R.string.report_reason_scam)) {
                            showReportDialog = false
                            viewModel.reportListing("scam")
                        }
                        ReportReasonButton(label = stringResource(R.string.report_reason_other)) {
                            showReportDialog = false
                            viewModel.reportListing("other")
                        }
                    }
                },
                confirmButton = {},
                dismissButton = {
                    TextButton(onClick = { showReportDialog = false }) {
                        Text(text = stringResource(R.string.listing_action_cancel))
                    }
                }
            )
        }

        if (showImageViewer && imageUrls.isNotEmpty()) {
            Dialog(onDismissRequest = { showImageViewer = false }) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.Black.copy(alpha = 0.92f))
                ) {
                    AsyncImage(
                        model = imageUrls[imageViewerIndex.coerceIn(0, imageUrls.lastIndex)],
                        contentDescription = listing.title,
                        contentScale = ContentScale.Fit,
                        modifier = Modifier
                            .fillMaxWidth()
                            .align(Alignment.Center)
                    )

                    CircleIconButton(
                        imageVector = Icons.Default.Close,
                        contentDescription = stringResource(R.string.ui_back),
                        modifier = Modifier
                            .align(Alignment.TopEnd)
                            .padding(16.dp),
                        onClick = { showImageViewer = false }
                    )

                    if (imageUrls.size > 1) {
                        CircleIconButton(
                            imageVector = Icons.Default.ChevronLeft,
                            contentDescription = stringResource(R.string.listing_prev_image),
                            modifier = Modifier
                                .align(Alignment.CenterStart)
                                .padding(start = 8.dp),
                            onClick = {
                                imageViewerIndex = if (imageViewerIndex == 0) imageUrls.lastIndex else imageViewerIndex - 1
                            }
                        )

                        CircleIconButton(
                            imageVector = Icons.Default.ChevronRight,
                            contentDescription = stringResource(R.string.listing_next_image),
                            modifier = Modifier
                                .align(Alignment.CenterEnd)
                                .padding(end = 8.dp),
                            onClick = {
                                imageViewerIndex = if (imageViewerIndex == imageUrls.lastIndex) 0 else imageViewerIndex + 1
                            }
                        )
                    }
                }
            }
        }
    }
}

private fun localizeListingDetailMessage(context: Context, message: String): String {
    return when (message) {
        "Title must be at least 5 characters" -> context.getString(R.string.msg_title_min_5)
        "Description must be at least 20 characters" -> context.getString(R.string.msg_description_min_20)
        "Phone number looks too short" -> context.getString(R.string.msg_phone_too_short)
        "Price is required" -> context.getString(R.string.msg_price_required)
        "Location is required" -> context.getString(R.string.msg_location_required)
        "Failed to load listing" -> context.getString(R.string.msg_failed_load_listing)
        "Failed to update listing images" -> context.getString(R.string.msg_failed_update_listing_images)
        "Failed to update listing" -> context.getString(R.string.msg_failed_update_listing)
        "Failed to update favorite" -> context.getString(R.string.msg_failed_update_favorite)
        "Failed to block user" -> context.getString(R.string.msg_failed_block_user)
        "Failed to report listing" -> context.getString(R.string.msg_failed_report_listing)
        "Listing updated" -> context.getString(R.string.msg_listing_updated)
        "Listing images updated" -> context.getString(R.string.msg_listing_images_updated)
        else -> message
    }
}

@Composable
private fun ActionPillButton(
    modifier: Modifier = Modifier,
    text: String,
    icon: ImageVector,
    enabled: Boolean = true,
    onClick: () -> Unit
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(999.dp))
            .background(if (enabled) Color(0xFF0A4F66) else Color(0xFF90A4AE))
            .clickable(enabled = enabled, onClick = onClick)
            .padding(horizontal = 12.dp, vertical = 10.dp)
    ) {
        Row(
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.fillMaxWidth()
        ) {
            Icon(icon, contentDescription = null, tint = Color.White)
            Spacer(modifier = Modifier.width(6.dp))
            Text(text = text, color = Color.White, style = MaterialTheme.typography.labelLarge)
        }
    }
}

private fun uriToTempJpeg(context: Context, uri: Uri): File? {
    return runCatching {
        val bytes = context.contentResolver.openInputStream(uri)?.use { it.readBytes() } ?: return null
        val file = File.createTempFile("listing-edit-image-", ".jpg", context.cacheDir)
        file.writeBytes(bytes)
        file
    }.getOrNull()
}

@Composable
private fun ReportReasonButton(label: String, onClick: () -> Unit) {
    Text(
        text = label,
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(10.dp))
            .clickable(onClick = onClick)
            .background(Color(0xFFF6F8FC))
            .padding(horizontal = 12.dp, vertical = 10.dp),
        color = Color(0xFF2C3E55),
        style = MaterialTheme.typography.bodyMedium
    )
}

@Composable
private fun CircleIconButton(
    imageVector: ImageVector,
    contentDescription: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    highlighted: Boolean = false
) {
    val backgroundColor = if (highlighted) Color(0xFFFFF1F3) else Color.White.copy(alpha = 0.92f)
    val borderColor = if (highlighted) Color(0xFFFF9CB0) else Color.White.copy(alpha = 0.72f)
    val iconTint = if (highlighted) Color(0xFFB3261E) else Color(0xFF102A43)

    Box(
        modifier = modifier
            .size(46.dp)
            .shadow(elevation = 10.dp, shape = CircleShape)
            .clip(CircleShape)
            .background(backgroundColor)
            .border(width = 1.dp, color = borderColor, shape = CircleShape)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = imageVector,
            contentDescription = contentDescription,
            tint = iconTint,
            modifier = Modifier.size(22.dp)
        )
    }
}

@Composable
private fun MetaChip(
    text: String,
    icon: @Composable (() -> Unit)? = null,
    accent: Boolean = false
) {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(999.dp))
            .background(if (accent) Color(0xFFFFF8E0) else Color(0xFFF0F4FA))
            .padding(horizontal = 12.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(6.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        icon?.invoke()
        Text(
            text = text,
            color = if (accent) Color(0xFFB07700) else Color(0xFF4A6080),
            style = MaterialTheme.typography.bodySmall,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

@Composable
private fun ContactRow(
    iconBg: Color,
    iconTint: Color,
    icon: ImageVector,
    value: String,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(Color.White)
            .clickable(onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(iconBg),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = iconTint,
                modifier = Modifier.size(20.dp)
            )
        }
        Spacer(modifier = Modifier.width(12.dp))
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium,
            color = Color(0xFF2C3E55),
            modifier = Modifier.weight(1f)
        )
        Icon(
            imageVector = Icons.Default.ChevronRight,
            contentDescription = null,
            tint = iconTint.copy(alpha = 0.6f),
            modifier = Modifier.size(20.dp)
        )
    }
}

@Composable
private fun MapSection(
    lat: Double,
    lng: Double,
    address: String?,
    title: String,
    context: android.content.Context
) {
    val safeLat = lat.coerceIn(-85.0511, 85.0511)
    val safeLng = ((lng + 180.0) % 360.0 + 360.0) % 360.0 - 180.0
    val mapPreviewUrl =
        "https://api.souqira.com/api/places/static-map?lat=$safeLat&lng=$safeLng&zoom=15&width=1000&height=340"

    Column(
        modifier = Modifier
            .padding(horizontal = 20.dp, vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Default.Map,
                contentDescription = null,
                tint = Color(0xFF1A4D7C),
                modifier = Modifier.size(16.dp)
            )
            Text(
                text = stringResource(R.string.listing_location_title),
                style = MaterialTheme.typography.titleMedium,
                color = Color(0xFF0F2240),
                fontWeight = FontWeight.Bold
            )
        }

        if (!address.isNullOrBlank()) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.LocationOn,
                    contentDescription = null,
                    tint = Color(0xFF6B7FA3),
                    modifier = Modifier.size(14.dp)
                )
                Text(
                    text = address,
                    style = MaterialTheme.typography.bodySmall,
                    color = Color(0xFF6B7FA3)
                )
            }
        }

        // Static preview based on a live OSM tile endpoint.
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(170.dp)
                .clip(RoundedCornerShape(18.dp))
                .clickable {
                    openLocationInMaps(context, lat, lng, title)
                }
        ) {
            AsyncImage(
                model = mapPreviewUrl,
                contentDescription = stringResource(R.string.ui_map),
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize()
            )
            Icon(
                imageVector = Icons.Default.LocationOn,
                contentDescription = null,
                tint = Color(0xFF1A4D7C),
                modifier = Modifier
                    .align(Alignment.Center)
                    .size(26.dp)
            )
        }

        // "Open in Maps" button
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(14.dp))
                .background(Color(0xFFE8F2FF))
                .clickable {
                    openLocationInMaps(context, lat, lng, title)
                }
                .padding(horizontal = 16.dp, vertical = 13.dp),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Default.Map,
                contentDescription = null,
                tint = Color(0xFF1A4D7C),
                modifier = Modifier.size(16.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = stringResource(R.string.listing_open_in_maps),
                style = MaterialTheme.typography.labelLarge,
                color = Color(0xFF1A4D7C),
                fontWeight = FontWeight.SemiBold
            )
        }
    }
}

@Composable
private fun MapFallbackSection(
    query: String,
    context: android.content.Context
) {
    Column(
        modifier = Modifier
            .padding(horizontal = 20.dp, vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Default.Map,
                contentDescription = null,
                tint = Color(0xFF1A4D7C),
                modifier = Modifier.size(16.dp)
            )
            Text(
                text = stringResource(R.string.listing_location_title),
                style = MaterialTheme.typography.titleMedium,
                color = Color(0xFF0F2240),
                fontWeight = FontWeight.Bold
            )
        }

        Text(
            text = stringResource(R.string.listing_location_estimated),
            style = MaterialTheme.typography.bodySmall,
            color = Color(0xFF6B7FA3)
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(14.dp))
                .background(Color(0xFFE8F2FF))
                .clickable {
                    openLocationQueryInMaps(context, query)
                }
                .padding(horizontal = 16.dp, vertical = 13.dp),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Default.Map,
                contentDescription = null,
                tint = Color(0xFF1A4D7C),
                modifier = Modifier.size(16.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = stringResource(R.string.listing_open_location),
                style = MaterialTheme.typography.labelLarge,
                color = Color(0xFF1A4D7C),
                fontWeight = FontWeight.SemiBold
            )
        }
    }
}

@Composable
private fun listingDetailCategoryLabel(categoryId: String): String {
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

private fun openLocationInMaps(context: Context, lat: Double, lng: Double, title: String) {
    val encodedTitle = Uri.encode(title)
    val geoIntent = Intent(Intent.ACTION_VIEW, Uri.parse("geo:$lat,$lng?q=$lat,$lng($encodedTitle)"))
        .setPackage("com.google.android.apps.maps")

    try {
        context.startActivity(geoIntent)
    } catch (_: ActivityNotFoundException) {
        context.startActivity(
            Intent(Intent.ACTION_VIEW, Uri.parse("https://maps.google.com/?q=$lat,$lng"))
        )
    }
}

private fun openLocationQueryInMaps(context: Context, query: String) {
    val encodedQuery = Uri.encode(query)
    val geoIntent = Intent(Intent.ACTION_VIEW, Uri.parse("geo:0,0?q=$encodedQuery"))
        .setPackage("com.google.android.apps.maps")

    try {
        context.startActivity(geoIntent)
    } catch (_: ActivityNotFoundException) {
        context.startActivity(
            Intent(Intent.ACTION_VIEW, Uri.parse("https://maps.google.com/?q=$encodedQuery"))
        )
    }
}

private fun extractOwnerId(owner: JsonElement?): String? {
    if (owner == null || owner.isJsonNull) return null
    return when {
        owner.isJsonPrimitive -> owner.asString
        owner.isJsonObject -> {
            val obj = owner.asJsonObject
            when {
                obj.has("_id") && !obj.get("_id").isJsonNull -> obj.get("_id").asString
                obj.has("id") && !obj.get("id").isJsonNull -> obj.get("id").asString
                else -> null
            }
        }
        else -> null
    }
}
