package com.souqira.android.ui.screen.messages

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.FilledIconButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.souqira.android.R
import com.souqira.android.data.model.Conversation
import com.souqira.android.data.model.Message
import com.souqira.android.ui.viewmodel.MessagesViewModel

@Composable
fun MessagesScreen(viewModel: MessagesViewModel) {
    val uiState by viewModel.uiState.collectAsState()
    var messageText by remember { mutableStateOf("") }
    val selectedPartnerId = uiState.selectedConversationId
    val selectedConversation = uiState.conversations.firstOrNull { it.partner.id == selectedPartnerId }

    LaunchedEffect(Unit) {
        viewModel.loadConversations()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    listOf(Color(0xFFF1F5F8), Color(0xFFEAF1F6))
                )
            )
    ) {
        if (selectedPartnerId == null) {
            Column(modifier = Modifier.fillMaxSize()) {
                Text(
                    text = stringResource(R.string.messages_title),
                    style = MaterialTheme.typography.headlineMedium,
                    color = Color(0xFF1C3347),
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 14.dp)
                )

                if (uiState.isLoading && uiState.conversations.isEmpty()) {
                    CircularProgressIndicator(modifier = Modifier.padding(16.dp))
                }

                if (!uiState.errorMessage.isNullOrBlank()) {
                    Text(uiState.errorMessage ?: "", modifier = Modifier.padding(horizontal = 16.dp))
                }

                if (!uiState.isLoading && uiState.conversations.isEmpty()) {
                    Text(
                        text = stringResource(R.string.messages_empty),
                        style = MaterialTheme.typography.bodyLarge,
                        color = Color(0xFF6B8399),
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                    )
                }

                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = 14.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(uiState.conversations) { conversation ->
                        ConversationCard(
                            conversation = conversation,
                            onClick = { viewModel.openConversation(conversation.partner.id) }
                        )
                    }
                    item { Spacer(modifier = Modifier.padding(bottom = 92.dp)) }
                }
            }
        } else {
            Column(modifier = Modifier.fillMaxSize()) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 12.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    FilledIconButton(onClick = viewModel::closeConversation) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = stringResource(R.string.back))
                    }
                    Spacer(modifier = Modifier.width(10.dp))
                    Text(
                        text = selectedConversation?.partner?.username
                            ?: selectedConversation?.partner?.email
                            ?: stringResource(R.string.messages_chat_fallback),
                        style = MaterialTheme.typography.titleLarge,
                        color = Color(0xFF1C3347),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                LazyColumn(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth()
                        .padding(horizontal = 12.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    items(uiState.messages) { message ->
                        MessageBubble(
                            message = message,
                            isFromPartner = message.senderId == selectedPartnerId
                        )
                    }
                }

                Surface(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 12.dp, vertical = 10.dp),
                    color = Color.White.copy(alpha = 0.95f),
                    shape = RoundedCornerShape(18.dp)
                ) {
                    Row(
                        modifier = Modifier.padding(10.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        OutlinedTextField(
                            value = messageText,
                            onValueChange = { messageText = it },
                            label = { Text(stringResource(R.string.messages_write)) },
                            modifier = Modifier.weight(1f)
                        )

                        OutlinedButton(
                            onClick = {
                                viewModel.sendMessage(messageText)
                                messageText = ""
                            },
                            enabled = messageText.isNotBlank()
                        ) {
                            Text(stringResource(R.string.messages_send))
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun ConversationCard(conversation: Conversation, onClick: () -> Unit) {
    val displayName = conversation.partner.username ?: conversation.partner.email ?: stringResource(R.string.messages_user_fallback)

    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .clickable(onClick = onClick),
        color = Color.White.copy(alpha = 0.92f),
        shape = RoundedCornerShape(20.dp),
        shadowElevation = 6.dp
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 14.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(50.dp)
                    .clip(CircleShape)
                    .background(
                        Brush.linearGradient(
                            listOf(Color(0xFF0A4F66), Color(0xFF0F6A86))
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = displayName.firstOrNull()?.uppercase() ?: "U",
                    color = Color.White,
                    fontWeight = FontWeight.Bold
                )
            }

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = displayName,
                    style = MaterialTheme.typography.titleMedium,
                    color = Color(0xFF1C3347),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = conversation.latestMessage.content,
                    style = MaterialTheme.typography.bodyMedium,
                    color = Color(0xFF6B8399),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}

@Composable
private fun MessageBubble(message: Message, isFromPartner: Boolean) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = if (isFromPartner) Arrangement.Start else Arrangement.End
    ) {
        Surface(
            color = if (isFromPartner) Color.White else Color(0xFF0A4F66),
            shape = RoundedCornerShape(18.dp),
            shadowElevation = 4.dp
        ) {
            Text(
                text = message.content,
                style = MaterialTheme.typography.bodyLarge,
                color = if (isFromPartner) Color(0xFF1C3347) else Color.White,
                modifier = Modifier.padding(horizontal = 14.dp, vertical = 10.dp)
            )
        }
    }
}
