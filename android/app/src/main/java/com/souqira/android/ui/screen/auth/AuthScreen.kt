package com.souqira.android.ui.screen.auth

import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Message
import androidx.compose.material.icons.filled.Apartment
import androidx.compose.material.icons.filled.CheckBoxOutlineBlank
import androidx.compose.material.icons.filled.Email
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.souqira.android.R
import com.souqira.android.localization.LanguageStore
import com.souqira.android.services.GoogleSignInHelper
import com.souqira.android.ui.viewmodel.AuthViewModel
import kotlinx.coroutines.launch

@Composable
fun AuthScreen(viewModel: AuthViewModel) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var registerUsername by remember { mutableStateOf("") }
    var registerEmail by remember { mutableStateOf("") }
    var registerPassword by remember { mutableStateOf("") }
    var registerConfirmPassword by remember { mutableStateOf("") }
    var whatsappPhone by remember { mutableStateOf("") }
    var whatsappOtp by remember { mutableStateOf("") }
    var localTermsChecked by remember { mutableStateOf(false) }
    var showEmailLogin by remember { mutableStateOf(false) }
    var showCreateAccount by remember { mutableStateOf(false) }
    var showWhatsAppLogin by remember { mutableStateOf(false) }
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current
    val scope = rememberCoroutineScope()

    val languageStore = remember { LanguageStore(context) }
    val persistedTermsAccepted by languageStore.termsAcceptedFlow.collectAsState(initial = false)

    // True if the user has ever accepted before (persisted) OR just checked it this session
    val hasAcceptedTerms = persistedTermsAccepted || localTermsChecked

    val googleLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.data == null) {
            viewModel.setError(context.getString(R.string.auth_google_cancelled))
            return@rememberLauncherForActivityResult
        }

        GoogleSignInHelper.extractIdToken(result.data)
            .onSuccess { idToken ->
                viewModel.loginWithGoogleIdToken(idToken)
            }
            .onFailure { error ->
                viewModel.setError(error.message ?: context.getString(R.string.auth_google_failed))
            }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 18.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 8.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Icon(
                imageVector = Icons.Default.Apartment,
                contentDescription = null,
                tint = Color(0xFF0A4F66),
                modifier = Modifier.height(72.dp)
            )
            Text(
                text = stringResource(R.string.auth_welcome_title),
                style = MaterialTheme.typography.headlineSmall,
                color = MaterialTheme.colorScheme.onBackground
            )
            Text(
                text = stringResource(R.string.auth_welcome_subtitle),
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        if (!hasAcceptedTerms) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .clickable {
                        localTermsChecked = true
                        scope.launch { languageStore.setTermsAccepted() }
                    }
                    .padding(vertical = 6.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.CheckBoxOutlineBlank,
                    contentDescription = null,
                    tint = Color(0xFF7A8A98)
                )
                Text(
                    text = stringResource(R.string.auth_terms_agree),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurface
                )
            }
        }

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 4.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Button(
                onClick = {
                    val next = !showEmailLogin
                    showEmailLogin = next
                    if (!next) showCreateAccount = false
                },
                enabled = hasAcceptedTerms,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF1D6FEA),
                    contentColor = Color.White
                )
            ) {
                Icon(imageVector = Icons.Default.Email, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text(stringResource(R.string.auth_signin_email))
            }

            if (showEmailLogin) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color.White)
                        .border(1.dp, Color(0xFFE3E8EF), RoundedCornerShape(12.dp))
                        .padding(12.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    OutlinedTextField(
                        value = email,
                        onValueChange = { email = it },
                        label = { Text(stringResource(R.string.auth_email)) },
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true
                    )

                    OutlinedTextField(
                        value = password,
                        onValueChange = { password = it },
                        label = { Text(stringResource(R.string.auth_password)) },
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true
                    )

                    Button(
                        onClick = { viewModel.login(email, password) },
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(10.dp)
                    ) {
                        Text(stringResource(R.string.auth_login))
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(6.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = stringResource(R.string.auth_no_account_prompt),
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            text = stringResource(R.string.auth_create_one),
                            style = MaterialTheme.typography.bodySmall,
                            color = Color(0xFF0F766E),
                            modifier = Modifier.clickable { showCreateAccount = !showCreateAccount }
                        )
                    }

                    if (showCreateAccount) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(12.dp))
                                .background(Color(0xFFF8FAFC))
                                .border(1.dp, Color(0xFFE3E8EF), RoundedCornerShape(12.dp))
                                .padding(12.dp),
                            verticalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            OutlinedTextField(
                                value = registerUsername,
                                onValueChange = { registerUsername = it },
                                label = { Text(stringResource(R.string.auth_username)) },
                                modifier = Modifier.fillMaxWidth(),
                                singleLine = true
                            )

                            OutlinedTextField(
                                value = registerEmail,
                                onValueChange = { registerEmail = it },
                                label = { Text(stringResource(R.string.auth_email)) },
                                modifier = Modifier.fillMaxWidth(),
                                singleLine = true
                            )

                            OutlinedTextField(
                                value = registerPassword,
                                onValueChange = { registerPassword = it },
                                label = { Text(stringResource(R.string.auth_password)) },
                                modifier = Modifier.fillMaxWidth(),
                                singleLine = true
                            )

                            OutlinedTextField(
                                value = registerConfirmPassword,
                                onValueChange = { registerConfirmPassword = it },
                                label = { Text(stringResource(R.string.auth_confirm_password)) },
                                modifier = Modifier.fillMaxWidth(),
                                singleLine = true
                            )

                            Button(
                                onClick = {
                                    if (registerPassword != registerConfirmPassword) {
                                        viewModel.setError(context.getString(R.string.auth_password_mismatch))
                                    } else {
                                        viewModel.register(
                                            username = registerUsername,
                                            email = registerEmail,
                                            password = registerPassword
                                        )
                                    }
                                },
                                modifier = Modifier.fillMaxWidth(),
                                shape = RoundedCornerShape(10.dp)
                            ) {
                                Text(stringResource(R.string.auth_create_account))
                            }
                        }
                    }
                }
            }

            Button(
                onClick = { showWhatsAppLogin = !showWhatsAppLogin },
                enabled = hasAcceptedTerms,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF22C55E),
                    contentColor = Color.White
                )
            ) {
                Icon(imageVector = Icons.AutoMirrored.Filled.Message, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text(stringResource(R.string.auth_signin_whatsapp))
            }

            if (showWhatsAppLogin) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color.White)
                        .border(1.dp, Color(0xFFE3E8EF), RoundedCornerShape(12.dp))
                        .padding(12.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    OutlinedTextField(
                        value = whatsappPhone,
                        onValueChange = { whatsappPhone = it },
                        label = { Text(stringResource(R.string.auth_whatsapp_phone)) },
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true
                    )

                    Button(
                        onClick = { viewModel.sendWhatsAppOtp(whatsappPhone) },
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(10.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFF16A34A),
                            contentColor = Color.White
                        )
                    ) {
                        Text(stringResource(R.string.auth_whatsapp_send_otp))
                    }

                    if (uiState.otpSent) {
                        OutlinedTextField(
                            value = whatsappOtp,
                            onValueChange = { whatsappOtp = it },
                            label = { Text(stringResource(R.string.auth_whatsapp_otp)) },
                            modifier = Modifier.fillMaxWidth(),
                            singleLine = true
                        )

                        Button(
                            onClick = { viewModel.loginWithWhatsAppOtp(whatsappPhone, whatsappOtp) },
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(10.dp)
                        ) {
                            Text(stringResource(R.string.auth_whatsapp_verify_login))
                        }
                    }
                }
            }

            Button(
                onClick = {
                    runCatching {
                        GoogleSignInHelper.buildSignInIntent(context)
                    }.onSuccess { intent ->
                        googleLauncher.launch(intent)
                    }.onFailure { error ->
                        viewModel.setError(error.message ?: context.getString(R.string.auth_google_not_configured))
                    }
                },
                enabled = hasAcceptedTerms,
                modifier = Modifier
                    .fillMaxWidth()
                    .border(1.dp, Color(0xFFCFD8E3), RoundedCornerShape(12.dp)),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.White,
                    contentColor = Color.Black
                )
            ) {
                Text(stringResource(R.string.auth_continue_google))
            }
        }

        if (uiState.isLoading) {
            Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(modifier = Modifier.padding(top = 8.dp))
            }
        }

        if (!uiState.statusMessage.isNullOrBlank()) {
            Text(text = uiState.statusMessage ?: "", modifier = Modifier.padding(top = 8.dp))
        }

        if (!uiState.errorMessage.isNullOrBlank()) {
            Text(text = uiState.errorMessage ?: "", modifier = Modifier.padding(top = 8.dp))
        }
    }
}
