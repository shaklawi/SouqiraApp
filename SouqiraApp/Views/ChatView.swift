//
//  ChatView.swift
//  Souqira
//
//  Created on 18/02/2026
//

import SwiftUI

struct ChatView: View {
    let conversation: Conversation
    
    @StateObject private var viewModel = MessagesViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    
    private var otherUser: MessageUser? {
        conversation.participants.first { $0.id != authViewModel.currentUser?.id }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Listing header (if exists)
            if let listing = conversation.listing {
                listingHeader(listing)
            }
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.currentMessages) { message in
                            MessageBubble(
                                message: message,
                                isFromCurrentUser: message.senderId == authViewModel.currentUser?.id
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    scrollProxy = proxy
                    scrollToBottom()
                }
                .onChange(of: viewModel.currentMessages.count) { _ in
                    scrollToBottom()
                }
            }
            
            // Message input
            messageInputBar
        }
        .navigationTitle(otherUser?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMessages(for: conversation.id)
        }
    }
    
    private func listingHeader(_ listing: MessageListing) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: listing.primaryImage)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text("\(listing.currency.uppercased()) \(Int(listing.price))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var messageInputBar: some View {
        HStack(spacing: 12) {
            TextField(localizationManager.localize(key: "type_message"), text: $messageText)
                .textFieldStyle(.roundedBorder)
                .frame(minHeight: 36)
            
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(messageText.isEmpty ? Color.gray : Color.blue)
                    .clipShape(Circle())
            }
            .disabled(messageText.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: -2)
    }
    
    private func sendMessage() {
        guard let receiverId = otherUser?.id,
              let listingId = conversation.listing?.id else {
            return
        }
        
        let text = messageText
        messageText = ""
        
        Task {
            let success = await viewModel.sendMessage(
                to: receiverId,
                listingId: listingId,
                message: text
            )
            
            if success {
                scrollToBottom()
            }
        }
    }
    
    private func scrollToBottom() {
        guard let lastMessage = viewModel.currentMessages.last else { return }
        withAnimation {
            scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.createdAt)
    }
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.message)
                    .font(.body)
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        isFromCurrentUser
                        ? Color.blue
                        : Color(.systemGray5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                
                Text(timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !isFromCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(conversation: Conversation(
            id: "1",
            participants: [
                MessageUser(id: "user1", name: "Ahmed", email: "ahmed@example.com", phone: nil),
                MessageUser(id: "user2", name: "Sara", email: "sara@example.com", phone: nil)
            ],
            listing: MessageListing(
                id: "listing1",
                title: "محل مواد منزلية للبيع",
                price: 5500,
                currency: "usd",
                images: []
            ),
            lastMessage: Message(
                id: "msg1",
                conversationId: "1",
                senderId: "user2",
                receiverId: "user1",
                message: "Hello, is this still available?",
                isRead: false,
                createdAt: Date()
            ),
            unreadCount: 1,
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
    .environmentObject(AuthenticationViewModel())
    .environmentObject(LocalizationManager.shared)
}
