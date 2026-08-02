//
//  ModernListingCard.swift
//  Souqira
//
//  Created on 18/02/2026
//

import SwiftUI

struct ModernListingCard: View {
    let listing: BusinessListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            CachedRemoteImage(url: URL(string: listing.images.first ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ZStack {
                    LinearGradient(
                        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .clipped()
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(listing.title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(minHeight: 36, alignment: .top)
                
                // Location
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.blue)
                    Text(listing.location.capitalized)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 4)
                
                // Price and Views
                HStack(alignment: .center, spacing: 8) {
                    Text(listing.formattedPrice)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 9))
                        Text("\(listing.views)")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .frame(height: 110)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    Color.gray.opacity(0.1),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    ModernListingCard(listing: BusinessListing(
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
