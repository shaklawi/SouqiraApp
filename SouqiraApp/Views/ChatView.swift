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
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    private let tabBarReservedSpace: CGFloat = 96
    
    private var otherUser: MessageUser? {
        conversation.partner
    }
    
    var body: some View {
        ZStack {
            SouqiraPatternBackground()

            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.currentMessages) { message in
                                MessageBubble(
                                    message: message,
                                    isFromCurrentUser: message.senderId == authViewModel.currentUser?.id
                                )
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    }
                    .scrollIndicators(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                    .onAppear {
                        scrollProxy = proxy
                        scrollToBottom()
                    }
                    .onChange(of: viewModel.currentMessages.count) { _ in
                        scrollToBottom()
                    }
                }

                messageInputBar
                    .padding(.horizontal, 12)
                    .padding(.top, 6)
                    .padding(.bottom, 8)
            }
        }
        .navigationTitle(otherUser?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: tabBarReservedSpace)
        }
        .task {
            await viewModel.loadMessages(for: conversation.partner.id)
        }
    }
    
    private var messageInputBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left.slash.chevron.right")
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.gray500)

                TextField(localizationManager.localize(key: "type_message"), text: $messageText)
                    .font(.body)
                    .submitLabel(.send)
                    .onSubmit(sendMessage)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(DesignSystem.Colors.gray200, lineWidth: 1)
                    )
            )

            Button(action: sendMessage) {
                Image(systemName: "arrow.up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 42, height: 42)
                    .background(
                        Circle()
                            .fill(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? LinearGradient(colors: [DesignSystem.Colors.gray400, DesignSystem.Colors.gray500], startPoint: .topLeading, endPoint: .bottomTrailing) : DesignSystem.Colors.primaryGradient)
                    )
                    .shadow(color: DesignSystem.Colors.primary.opacity(0.25), radius: 8, x: 0, y: 4)
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(DesignSystem.Colors.gray200.opacity(0.9), lineWidth: 1)
                )
        )
        .shadow(color: DesignSystem.Colors.gray900.opacity(0.08), radius: 14, x: 0, y: 6)
    }
    
    private func sendMessage() {
        guard let receiverId = otherUser?.id else {
            return
        }
        
        let text = messageText
        messageText = ""
        
        Task {
            let success = await viewModel.sendMessage(
                to: receiverId,
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
                Text(message.content)
                    .font(.body)
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        isFromCurrentUser
                        ? DesignSystem.Colors.primaryGradient
                        : LinearGradient(colors: [Color.white.opacity(0.95), DesignSystem.Colors.gray100], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isFromCurrentUser ? Color.clear : DesignSystem.Colors.gray200, lineWidth: 1)
                    )
                    .shadow(color: DesignSystem.Colors.gray900.opacity(isFromCurrentUser ? 0.14 : 0.08), radius: 8, x: 0, y: 4)
                
                Text(timeString)
                    .font(.caption2)
                    .foregroundColor(DesignSystem.Colors.gray500)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: 280, alignment: isFromCurrentUser ? .trailing : .leading)
            
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
            partner: MessageUser(id: "user2", email: "sara@example.com", firstname: "Sara", lastname: nil, username: nil),
            latestMessage: Message(
                id: "msg1",
                senderId: "user2",
                receiverId: "user1",
                content: "Hello, is this still available?",
                isRead: false,
                createdAt: Date()
            )
        ))
    }
    .environmentObject(AuthenticationViewModel())
    .environmentObject(LocalizationManager.shared)
}
