//
//  MessageComposerView.swift
//  Souqira
//
//  Created on 18/02/2026
//

import SwiftUI

struct MessageComposerView: View {
    let receiverId: String
    let listingId: String
    let listing: BusinessListing
    
    @StateObject private var viewModel = MessagesViewModel()
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var messageText = ""
    @State private var isSending = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Listing preview
                listingPreview
                
                Divider()
                
                // Message input
                VStack(spacing: 16) {
                    Text("Send a message to the seller")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextEditor(text: $messageText)
                        .frame(height: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        sendMessage()
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                }
            }
        }
    }
    
    private var listingPreview: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: listing.images.first ?? "")) { image in
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
                
                Text(listing.formattedPrice)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private func sendMessage() {
        isSending = true
        
        Task {
            let success = await viewModel.sendMessage(
                to: receiverId,
                listingId: listingId,
                message: messageText
            )
            
            isSending = false
            
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    MessageComposerView(
        receiverId: "user123",
        listingId: "listing123",
        listing: BusinessListing(
            id: "1",
            title: "محل مواد منزلية للبيع",
            description: "Great opportunity",
            price: 5500,
            currency: .usd,
            location: "erbil",
            category: "retail",
            images: [],
            vrMedia: nil,
            address: nil,
            coordinates: nil,
            phone: nil,
            whatsapp: nil,
            status: .approved,
            saleStatus: "available",
            views: 28,
            isFeatured: false,
            owner: ListingUser(id: "user1", isVerified: true, name: "Ahmed", email: "ahmed@example.com"),
            createdAt: Date(),
            updatedAt: Date(),
            vrPanoramaUrl: nil,
            vrVideoUrl: nil
        )
    )
    .environmentObject(LocalizationManager.shared)
}
