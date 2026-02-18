//
//  ListingCard.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

struct ListingCard: View {
    let listing: BusinessListing
    
    var body: some View {
        HStack(spacing: 0) {
            // Image section - larger and more prominent
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: listing.images.first ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.15),
                                Color.purple.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 38, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .frame(width: 130, height: 130)
                .clipped()
                
                // Featured badge - repositioned
                if listing.isFeatured == true {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text("مميز")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.6, blue: 0.0), Color(red: 1.0, green: 0.3, blue: 0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .orange.opacity(0.4), radius: 6, x: 0, y: 2)
                    )
                    .padding(10)
                }
            }
            .frame(width: 130)
            
            // Content section - more spacious
            VStack(alignment: .leading, spacing: 8) {
                // Title - larger and bolder
                Text(listing.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                
                // Location with better icon
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text(listing.location.capitalized)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 4)
                
                // Bottom row with price and views
                HStack(alignment: .center, spacing: 10) {
                    // Price - prominent and colorful
                    Text(listing.formattedPrice)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.2, green: 0.5, blue: 1.0), Color(red: 0.6, green: 0.3, blue: 0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Views counter - subtle but visible
                    HStack(spacing: 5) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text("\(listing.views)")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray5))
                    )
                }
            }
            .padding(.leading, 14)
            .padding(.trailing, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 130)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    ListingCard(listing: BusinessListing(
        id: "1",
        title: "محل مواد منزلية للبيع",
        description: "A great opportunity",
        price: 5500,
        currency: .usd,
        location: "erbil",
        category: "retail",
        images: [],
        vrMedia: nil,
        address: "Main Street, Erbil",
        coordinates: Coordinates(lat: 36.1911, lng: 44.0094),
        phone: "+964 770 123 4567",
        whatsapp: "+964 770 123 4567",
        status: .approved,
        saleStatus: "available",
        views: 28,
        isFeatured: false,
        owner: ListingUser(id: "user1", isVerified: true, name: "Ahmed", email: "ahmed@example.com"),
        createdAt: Date(),
        updatedAt: Date(),
        vrPanoramaUrl: nil,
        vrVideoUrl: nil
    ))
    .padding()
}
