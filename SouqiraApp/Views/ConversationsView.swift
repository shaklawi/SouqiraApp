//
//  ConversationsView.swift
//  Souqira
//
//  Created on 18/02/2026
//

import SwiftUI

struct ConversationsView: View {
    @StateObject private var viewModel = MessagesViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.conversations.isEmpty {
                    ProgressView()
                } else if viewModel.conversations.isEmpty {
                    emptyState
                } else {
                    conversationsList
                }
            }
            .navigationTitle(localizationManager.localize(key: "messages"))
            .task {
                await viewModel.loadConversations()
            }
            .refreshable {
                await viewModel.loadConversations()
            }
        }
    }
    
    private var conversationsList: some View {
        List(viewModel.conversations) { conversation in
            NavigationLink(destination: ChatView(conversation: conversation)) {
                ConversationRow(
                    conversation: conversation,
                    currentUserId: authViewModel.currentUser?.id ?? ""
                )
            }
        }
        .listStyle(.plain)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(localizationManager.localize(key: "no_messages"))
                .font(.title3)
                .fontWeight(.medium)
            
            Text(localizationManager.localize(key: "no_messages_desc"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    let currentUserId: String
    
    private var otherUser: MessageUser? {
        conversation.participants.first { $0.id != currentUserId }
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: conversation.updatedAt, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 50, height: 50)
                .overlay {
                    Text(otherUser?.name.prefix(1).uppercased() ?? "?")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(otherUser?.name ?? "Unknown")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let listing = conversation.listing {
                    Text(listing.title)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                }
                
                if let lastMessage = conversation.lastMessage {
                    HStack {
                        Text(lastMessage.message)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        if conversation.unreadCount > 0 {
                            Spacer()
                            Text("\(conversation.unreadCount)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ConversationsView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(LocalizationManager.shared)
}
