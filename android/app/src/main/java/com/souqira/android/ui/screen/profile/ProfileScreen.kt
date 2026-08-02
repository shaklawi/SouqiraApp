package com.souqira.android.ui.screen.profile

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.TextButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import androidx.compose.ui.unit.dp
import com.souqira.android.R
import com.souqira.android.ui.viewmodel.AuthUiState

@Composable
fun ProfileScreen(
    authUiState: AuthUiState,
    currentLanguage: String,
    onOpenFavorites: () -> Unit,
    onOpenMyListings: () -> Unit,
    onChangeLanguage: (String) -> Unit,
    onDeleteAccount: () -> Unit,
    onLogout: () -> Unit,
    onRequireAuth: () -> Unit
) {
    var showDeleteDialog by remember { mutableStateOf(false) }

    val backgroundGradient = Brush.linearGradient(
        colors = listOf(
            Color(0xFFF2F6F9),
            Color(0xFFEBF2F7),
            Color(0xFFE4EDF4)
        )
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(backgroundGradient)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp, vertical = 14.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = stringResource(R.string.profile_title),
                style = MaterialTheme.typography.headlineMedium,
                color = MaterialTheme.colorScheme.onBackground
            )

            if (authUiState.isAuthenticated && authUiState.user != null) {
                val name = authUiState.user.name.safeDisplay(stringResource(R.string.profile_default_user))
                val email = authUiState.user.email.safeDisplay(stringResource(R.string.profile_no_email))
                val role = authUiState.user.role.safeDisplay(stringResource(R.string.profile_user_role_default))

                ProfileHeroCard(
                    name = name,
                    email = email,
                    role = role
                )

                LanguageCard(
                    currentLanguage = currentLanguage,
                    onLanguageSelected = onChangeLanguage
                )

                OutlinedButton(
                    onClick = onOpenFavorites,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Favorite,
                        contentDescription = null,
                        tint = Color(0xFF0A4F66)
                    )
                    Spacer(modifier = Modifier.size(8.dp))
                    Text(
                        text = stringResource(R.string.nav_favorites),
                        style = MaterialTheme.typography.labelLarge
                    )
                }

                OutlinedButton(
                    onClick = onOpenMyListings,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Person,
                        contentDescription = null,
                        tint = Color(0xFF0A4F66)
                    )
                    Spacer(modifier = Modifier.size(8.dp))
                    Text(
                        text = stringResource(R.string.profile_my_listings),
                        style = MaterialTheme.typography.labelLarge
                    )
                }

                InfoCard(
                    title = stringResource(R.string.profile_account),
                    rows = listOf(
                        Triple(stringResource(R.string.profile_name), name, Icons.Default.Person),
                        Triple(stringResource(R.string.profile_email), email, Icons.Default.Email),
                        Triple(stringResource(R.string.profile_role), role.replaceFirstChar { it.uppercase() }, Icons.Default.Shield)
                    )
                )

                authUiState.errorMessage?.let { message ->
                    Text(
                        text = message,
                        color = Color(0xFFB3261E),
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(Color(0xFFFFEDEB))
                            .padding(horizontal = 12.dp, vertical = 10.dp)
                    )
                }

                authUiState.statusMessage?.let { message ->
                    Text(
                        text = message,
                        color = Color(0xFF14532D),
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(Color(0xFFEAF8EE))
                            .padding(horizontal = 12.dp, vertical = 10.dp)
                    )
                }

                OutlinedButton(
                    onClick = { showDeleteDialog = true },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    shape = RoundedCornerShape(16.dp),
                    colors = ButtonDefaults.outlinedButtonColors(
                        contentColor = Color(0xFFB3261E)
                    )
                ) {
                    Text(
                        text = stringResource(R.string.profile_delete_account),
                        style = MaterialTheme.typography.labelLarge
                    )
                }

                Button(
                    onClick = onLogout,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(54.dp),
                    shape = RoundedCornerShape(18.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color(0xFF0A4F66),
                        contentColor = Color.White
                    )
                ) {
                    Text(
                        stringResource(R.string.profile_logout),
                        style = MaterialTheme.typography.titleLarge.copy(fontSize = 19.sp)
                    )
                }
            } else {
                LanguageCard(
                    currentLanguage = currentLanguage,
                    onLanguageSelected = onChangeLanguage
                )

                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(22.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = 0.92f)),
                    elevation = CardDefaults.cardElevation(defaultElevation = 6.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(18.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Text(
                            text = stringResource(R.string.profile_welcome),
                            style = MaterialTheme.typography.titleLarge,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                        Text(
                            text = stringResource(R.string.profile_login_prompt),
                            style = MaterialTheme.typography.bodyLarge,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        OutlinedButton(
                            onClick = onRequireAuth,
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(52.dp),
                            shape = RoundedCornerShape(16.dp)
                        ) {
                            Text(stringResource(R.string.profile_go_to_login), style = MaterialTheme.typography.labelLarge)
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }

        if (showDeleteDialog) {
            AlertDialog(
                onDismissRequest = { showDeleteDialog = false },
                title = {
                    Text(text = stringResource(R.string.profile_delete_account_title))
                },
                text = {
                    Text(text = stringResource(R.string.profile_delete_account_message))
                },
                dismissButton = {
                    TextButton(onClick = { showDeleteDialog = false }) {
                        Text(text = stringResource(R.string.profile_delete_account_cancel))
                    }
                },
                confirmButton = {
                    TextButton(
                        onClick = {
                            showDeleteDialog = false
                            onDeleteAccount()
                        }
                    ) {
                        Text(
                            text = stringResource(R.string.profile_delete_account_confirm),
                            color = Color(0xFFB3261E)
                        )
                    }
                }
            )
        }
    }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
private fun LanguageCard(
    currentLanguage: String,
    onLanguageSelected: (String) -> Unit
) {
    data class LanguageOption(
        val code: String,
        val name: String,
        val flagEmoji: String? = null,
        val flagRes: Int? = null
    )

    val options = listOf(
        LanguageOption("en", stringResource(R.string.lang_english), flagEmoji = "🇬🇧"),
        LanguageOption("ar", stringResource(R.string.lang_arabic), flagEmoji = "🇮🇶"),
        LanguageOption("ku", stringResource(R.string.lang_kurdish), flagRes = R.drawable.flag_ku)
    )
    val selected = options.firstOrNull { it.code == currentLanguage } ?: options.first()
    var showLanguageSheet by remember { mutableStateOf(false) }
    val languageSheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = 0.92f)),
        elevation = CardDefaults.cardElevation(defaultElevation = 6.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Text(
                text = stringResource(R.string.profile_language),
                style = MaterialTheme.typography.titleLarge,
                color = MaterialTheme.colorScheme.onSurface
            )

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(14.dp))
                    .background(Color(0xFFF5F8FB))
                    .border(width = 1.dp, color = Color(0xFFD8E2EA), shape = RoundedCornerShape(14.dp))
                    .clickable { showLanguageSheet = true }
                    .padding(horizontal = 12.dp, vertical = 12.dp),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    if (selected.flagRes != null) {
                        Image(
                            painter = painterResource(id = selected.flagRes),
                            contentDescription = selected.name,
                            modifier = Modifier
                                .size(22.dp)
                                .clip(RoundedCornerShape(4.dp))
                        )
                    } else {
                        Text(text = selected.flagEmoji.orEmpty(), style = MaterialTheme.typography.titleMedium)
                    }
                    Text(
                        text = selected.name,
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                }
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text(
                        text = selected.name,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                        contentDescription = null,
                        tint = Color(0xFF0A4F66)
                    )
                }
            }
        }
    }

    if (showLanguageSheet) {
        ModalBottomSheet(
            onDismissRequest = { showLanguageSheet = false },
            sheetState = languageSheetState,
            containerColor = Color.White
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = stringResource(R.string.profile_select_language),
                        style = MaterialTheme.typography.titleLarge,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    TextButton(onClick = { showLanguageSheet = false }) {
                        Text(text = stringResource(R.string.done))
                    }
                }

                options.forEach { option ->
                    val isSelected = option.code == selected.code
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .clickable {
                                onLanguageSelected(option.code)
                                showLanguageSheet = false
                            }
                            .padding(horizontal = 8.dp, vertical = 10.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                            if (option.flagRes != null) {
                                Image(
                                    painter = painterResource(id = option.flagRes),
                                    contentDescription = option.name,
                                    modifier = Modifier
                                        .size(width = 28.dp, height = 20.dp)
                                        .clip(RoundedCornerShape(3.dp))
                                )
                            } else {
                                Text(text = option.flagEmoji.orEmpty(), style = MaterialTheme.typography.titleMedium)
                            }
                            Text(
                                text = option.name,
                                style = MaterialTheme.typography.bodyLarge,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                        }

                        if (isSelected) {
                            Icon(
                                imageVector = Icons.Default.Check,
                                contentDescription = null,
                                tint = Color(0xFF0A4F66)
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))
            }
        }
    }
}

@Composable
private fun ProfileHeroCard(
    name: String,
    email: String,
    role: String
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = Color.Transparent),
        elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
    ) {
        Surface(
            color = Color.Transparent,
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    Brush.linearGradient(
                        colors = listOf(
                            Color(0xFF0A4F66),
                            Color(0xFF156784),
                            Color(0xFF2A7F9B)
                        )
                    )
                )
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(18.dp),
                horizontalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(62.dp)
                        .clip(CircleShape)
                        .background(Color.White.copy(alpha = 0.20f))
                        .padding(2.dp),
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .clip(CircleShape)
                            .background(Color.White.copy(alpha = 0.24f))
                    )
                    Text(
                        text = name.firstOrNull()?.uppercase() ?: "S",
                        modifier = Modifier.padding(start = 21.dp, top = 14.dp),
                        style = MaterialTheme.typography.titleLarge.copy(
                            color = Color.White,
                            fontWeight = FontWeight.Bold
                        )
                    )
                }

                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(2.dp)
                ) {
                    Text(
                        text = name,
                        style = MaterialTheme.typography.titleLarge,
                        color = Color.White,
                        maxLines = 1
                    )
                    Text(
                        text = email,
                        style = MaterialTheme.typography.bodyMedium,
                        color = Color.White.copy(alpha = 0.86f),
                        maxLines = 1
                    )
                    Text(
                        text = role.replaceFirstChar { it.uppercase() },
                        style = MaterialTheme.typography.labelLarge,
                        color = Color.White.copy(alpha = 0.86f)
                    )
                }
            }
        }
    }
}

@Composable
private fun InfoCard(
    title: String,
    rows: List<Triple<String, String, androidx.compose.ui.graphics.vector.ImageVector>>
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = 0.92f)),
        elevation = CardDefaults.cardElevation(defaultElevation = 6.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleLarge,
                color = MaterialTheme.colorScheme.onSurface
            )
            rows.forEach { row ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(14.dp))
                        .background(Color(0xFFF5F8FB))
                        .padding(horizontal = 12.dp, vertical = 12.dp),
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Icon(
                        imageVector = row.third,
                        contentDescription = row.first,
                        tint = Color(0xFF0A4F66)
                    )
                    Column {
                        Text(
                            text = row.first,
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            text = row.second,
                            style = MaterialTheme.typography.bodyLarge,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                    }
                }
            }
        }
    }
}

private fun String?.safeDisplay(fallback: String): String {
    if (this == null) return fallback
    val trimmed = this.trim()
    return if (trimmed.isEmpty() || trimmed.equals("null", ignoreCase = true)) fallback else trimmed
}
