package com.souqira.android.ui.screen.listings

import android.content.Context
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import coil.compose.rememberAsyncImagePainter
import com.souqira.android.R
import com.souqira.android.data.model.CreateListingInput
import com.souqira.android.ui.viewmodel.CreateListingViewModel
import java.io.File

@Composable
fun CreateListingScreen(
    viewModel: CreateListingViewModel,
    onCreated: () -> Unit,
    onBack: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current

    var title by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var price by remember { mutableStateOf("") }
    var phone by remember { mutableStateOf("") }
    var whatsapp by remember { mutableStateOf("") }
    var address by remember { mutableStateOf("") }
    var currency by remember { mutableStateOf("USD") }
    var selectedCategoryId by remember { mutableStateOf<String?>(null) }
    var selectedRegionId by remember { mutableStateOf<String?>(null) }
    var categoriesExpanded by remember { mutableStateOf(false) }
    var regionsExpanded by remember { mutableStateOf(false) }

    val selectedImages = remember { mutableStateListOf<Uri>() }

    val imagePicker = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetMultipleContents()
    ) { uris ->
        selectedImages.clear()
        selectedImages.addAll(uris.take(5))
    }

    LaunchedEffect(uiState.success) {
        if (uiState.success) {
            viewModel.consumeSuccess()
            onCreated()
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(stringResource(R.string.create_listing_title), style = MaterialTheme.typography.headlineMedium)
            TextButton(onClick = onBack) { Text(stringResource(R.string.back), color = Color(0xFF0A4F66)) }
        }

        OutlinedTextField(
            value = title,
            onValueChange = { title = it },
            label = { Text(stringResource(R.string.create_listing_field_title)) },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
            singleLine = true
        )
        OutlinedTextField(
            value = description,
            onValueChange = { description = it },
            label = { Text(stringResource(R.string.create_listing_field_description)) },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
            minLines = 3
        )
        OutlinedTextField(
            value = price,
            onValueChange = { price = it },
            label = { Text(stringResource(R.string.create_listing_field_price)) },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
            singleLine = true
        )

        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
            FilterChip(
                selected = currency == "USD",
                onClick = { currency = "USD" },
                label = { Text(stringResource(R.string.currency_usd)) },
                modifier = Modifier.weight(1f),
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = Color(0xFF0A4F66),
                    selectedLabelColor = Color.White
                )
            )
            FilterChip(
                selected = currency == "IQD",
                onClick = { currency = "IQD" },
                label = { Text(stringResource(R.string.currency_iqd)) },
                modifier = Modifier.weight(1f),
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = Color(0xFF0A4F66),
                    selectedLabelColor = Color.White
                )
            )
        }

        Box {
            OutlinedTextField(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { categoriesExpanded = true },
                value = uiState.categories.firstOrNull { it.id == selectedCategoryId }?.let { createListingCategoryLabel(it.id) }
                    ?: stringResource(R.string.create_listing_select_category),
                onValueChange = {},
                readOnly = true,
                label = { Text(stringResource(R.string.create_listing_category)) },
                trailingIcon = { Text("▾", color = Color(0xFF0A4F66)) },
                shape = RoundedCornerShape(14.dp),
                singleLine = true
            )

            DropdownMenu(expanded = categoriesExpanded, onDismissRequest = { categoriesExpanded = false }) {
                uiState.categories.forEach { category ->
                    DropdownMenuItem(
                        text = { Text(createListingCategoryLabel(category.id)) },
                        onClick = {
                            selectedCategoryId = category.id
                            categoriesExpanded = false
                        }
                    )
                }
            }
        }

        Box {
            OutlinedTextField(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { regionsExpanded = true },
                value = uiState.regions.firstOrNull { it.id == selectedRegionId }?.let { createListingRegionLabel(it.id) }
                    ?: stringResource(R.string.create_listing_select_region),
                onValueChange = {},
                readOnly = true,
                label = { Text(stringResource(R.string.create_listing_region)) },
                trailingIcon = { Text("▾", color = Color(0xFF0A4F66)) },
                shape = RoundedCornerShape(14.dp),
                singleLine = true
            )

            DropdownMenu(expanded = regionsExpanded, onDismissRequest = { regionsExpanded = false }) {
                uiState.regions.forEach { region ->
                    DropdownMenuItem(
                        text = { Text(createListingRegionLabel(region.id)) },
                        onClick = {
                            selectedRegionId = region.id
                            regionsExpanded = false
                        }
                    )
                }
            }
        }

        OutlinedTextField(
            value = phone,
            onValueChange = { phone = it },
            label = { Text(stringResource(R.string.create_listing_phone)) },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
            singleLine = true
        )
        OutlinedTextField(
            value = whatsapp,
            onValueChange = { whatsapp = it },
            label = { Text(stringResource(R.string.create_listing_whatsapp_optional)) },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
            singleLine = true
        )
        OutlinedTextField(
            value = address,
            onValueChange = { address = it },
            label = { Text(stringResource(R.string.create_listing_address_optional)) },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
            singleLine = true
        )

        Button(
            onClick = { imagePicker.launch("image/*") },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = Color(0xFF0A4F66),
                contentColor = Color.White
            )
        ) {
            Text(stringResource(R.string.create_listing_add_photos))
        }

        if (selectedImages.isNotEmpty()) {
            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                items(selectedImages) { uri ->
                    Image(
                        painter = rememberAsyncImagePainter(model = uri),
                        contentDescription = stringResource(R.string.create_listing_selected_image),
                        modifier = Modifier
                            .size(88.dp)
                            .clip(RoundedCornerShape(12.dp))
                    )
                }
            }
        }

        if (!uiState.errorMessage.isNullOrBlank()) {
            Text(uiState.errorMessage ?: "", color = MaterialTheme.colorScheme.error)
        }

        Button(
            onClick = {
                val input = CreateListingInput(
                    title = title,
                    description = description,
                    price = price.toDoubleOrNull() ?: 0.0,
                    currency = currency,
                    location = selectedRegionId.orEmpty(),
                    category = selectedCategoryId.orEmpty(),
                    phone = phone,
                    whatsapp = whatsapp.ifBlank { null },
                    address = address.ifBlank { null }
                )

                val imageFiles = selectedImages.mapNotNull { uri ->
                    uriToTempJpeg(context, uri)
                }

                viewModel.submit(input, imageFiles)
            },
            enabled = !uiState.isSubmitting,
            modifier = Modifier
                .fillMaxWidth()
                .height(52.dp),
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = Color(0xFF0A4F66),
                contentColor = Color.White
            )
        ) {
            if (uiState.isSubmitting) {
                CircularProgressIndicator(modifier = Modifier.height(20.dp), strokeWidth = 2.dp)
            } else {
                Text(stringResource(R.string.create_listing_submit))
            }
        }

        Spacer(modifier = Modifier.height(90.dp))
    }
}

@Composable
private fun createListingCategoryLabel(categoryId: String): String {
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
private fun createListingRegionLabel(regionId: String): String {
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

private fun uriToTempJpeg(context: Context, uri: Uri): File? {
    return runCatching {
        val bytes = context.contentResolver.openInputStream(uri)?.use { it.readBytes() } ?: return null
        val file = File.createTempFile("listing-image-", ".jpg", context.cacheDir)
        file.writeBytes(bytes)
        file
    }.getOrNull()
}
