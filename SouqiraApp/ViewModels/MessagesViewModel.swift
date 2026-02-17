//
//  MessagesViewModel.swift
//  Souqira
//
//  Created on 18/02/2026
//

import Foundation
import Combine

@MainActor
class MessagesViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var currentMessages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService()
    private var refreshTimer: Timer?
    
    init() {
        startAutoRefresh()
    }
    
    deinit {
        stopAutoRefresh()
    }
    
    // MARK: - Conversations
    
    func loadConversations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            conversations = try await apiService.getConversations()
            print("✅ Loaded \(conversations.count) conversations")
        } catch {
            errorMessage = "Failed to load conversations: \(error.localizedDescription)"
            print("❌ Error loading conversations: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Messages
    
    func loadMessages(for conversationId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentMessages = try await apiService.getMessages(conversationId: conversationId)
            print("✅ Loaded \(currentMessages.count) messages")
        } catch {
            errorMessage = "Failed to load messages: \(error.localizedDescription)"
            print("❌ Error loading messages: \(error)")
        }
        
        isLoading = false
    }
    
    func sendMessage(to receiverId: String, listingId: String, message: String) async -> Bool {
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        do {
            let sentMessage = try await apiService.sendMessage(
                receiverId: receiverId,
                listingId: listingId,
                message: message
            )
            
            // Add message to current messages
            currentMessages.append(sentMessage)
            
            // Refresh conversations to update last message
            await loadConversations()
            
            print("✅ Message sent successfully")
            return true
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
            print("❌ Error sending message: \(error)")
            return false
        }
    }
    
    // MARK: - Auto Refresh
    
    private func startAutoRefresh() {
        // Refresh conversations every 10 seconds
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.loadConversations()
            }
        }
    }
    
    nonisolated private func stopAutoRefresh() {
        Task { @MainActor in
            refreshTimer?.invalidate()
            refreshTimer = nil
        }
    }
    
    // MARK: - Helpers
    
    func getUnreadCount() -> Int {
        conversations.reduce(0) { $0 + $1.unreadCount }
    }
    
    func getOtherParticipant(in conversation: Conversation, currentUserId: String) -> MessageUser? {
        conversation.participants.first { $0.id != currentUserId }
    }
}
