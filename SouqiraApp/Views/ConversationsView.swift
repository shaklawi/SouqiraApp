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
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                SouqiraPatternBackground()

                if viewModel.isLoading && viewModel.conversations.isEmpty {
                    ProgressView()
                        .controlSize(.large)
                } else if viewModel.conversations.isEmpty {
                    emptyState
                } else {
                    conversationsList
                }
            }
            .navigationTitle(localizationManager.localize(key: "messages"))
            .task {
                await viewModel.loadConversations()
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 10_000_000_000)
                    if !Task.isCancelled {
                        await viewModel.loadConversations()
                    }
                }
            }
            .refreshable {
                await viewModel.loadConversations()
            }
        }
    }
    
    private var conversationsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.conversations) { conversation in
                    NavigationLink(destination: ChatView(conversation: conversation)) {
                        ConversationRow(
                            conversation: conversation,
                            currentUserId: authViewModel.currentUser?.id ?? ""
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
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
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: conversation.latestMessage.createdAt, relativeTo: Date())
    }

    private var isUnread: Bool {
        conversation.latestMessage.senderId != currentUserId && !conversation.latestMessage.isRead
    }
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primaryGradient)
                    .frame(width: 54, height: 54)
                    .shadow(color: DesignSystem.Colors.primary.opacity(0.18), radius: 8, x: 0, y: 4)

                Text(conversation.partner.name.prefix(1).uppercased())
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                if isUnread {
                    Circle()
                        .fill(DesignSystem.Colors.accent)
                        .frame(width: 11, height: 11)
                        .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                        .offset(x: 22, y: -20)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.partner.name)
                        .font(.headline)
                        .fontWeight(isUnread ? .bold : .semibold)
                        .foregroundColor(DesignSystem.Colors.gray900)
                    
                    Spacer()
                    
                    Text(timeAgo)
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.gray500)
                }
                
                Text(conversation.latestMessage.content)
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.gray600)
                    .lineLimit(1)
            }

            if isUnread {
                Capsule()
                    .fill(DesignSystem.Colors.accentGradient)
                    .frame(width: 8, height: 32)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(DesignSystem.Colors.gray200.opacity(0.9), lineWidth: 1)
                )
        )
        .shadow(color: DesignSystem.Colors.gray900.opacity(0.06), radius: 12, x: 0, y: 5)
    }
}

#Preview {
    ConversationsView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(LocalizationManager.shared)
}
