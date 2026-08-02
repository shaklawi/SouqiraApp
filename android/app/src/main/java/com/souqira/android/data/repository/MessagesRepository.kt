package com.souqira.android.data.repository

import com.souqira.android.data.model.Conversation
import com.souqira.android.data.model.Message
import com.souqira.android.data.model.SendMessageRequest
import com.souqira.android.data.network.SouqiraApi

class MessagesRepository(private val api: SouqiraApi) {
    suspend fun getConversations(): Result<List<Conversation>> {
        return runCatching {
            val response = api.getConversations()
            response.data ?: emptyList()
        }
    }

    suspend fun getMessages(partnerId: String): Result<List<Message>> {
        return runCatching {
            val response = api.getMessages(partnerId)
            response.data?.messages ?: emptyList()
        }
    }

    suspend fun sendMessage(receiverId: String, message: String): Result<Message> {
        return runCatching {
            val response = api.sendMessage(SendMessageRequest(receiver = receiverId, content = message))
            response.data ?: error(response.message ?: "Could not send message")
        }
    }
}
