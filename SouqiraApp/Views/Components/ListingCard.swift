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
        VStack(spacing: 0) {
            // Image - 140px
            AsyncImage(url: URL(string: listing.images.first ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
                    .overlay {
                        Image(systemName: "building.2")
                            .foregroundColor(.gray)
                            .font(.title)
                    }
            }
            .frame(width: 180, height: 140)
            .clipped()
            
            // Content - 80px
            VStack(spacing: 4) {
                // Title - 2 lines
                Text(listing.title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                    .frame(width: 160, height: 38, alignment: .topLeading)
                    .multilineTextAlignment(.leading)
                
                // Location
                HStack(spacing: 3) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 9))
                    Text(listing.location.capitalized)
                        .font(.system(size: 10))
                        .lineLimit(1)
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 0)
                
                // Price & Views
                HStack(alignment: .center, spacing: 8) {
                    Text(listing.formattedPrice)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.blue)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 8))
                        Text("\(listing.views)")
                            .font(.system(size: 9))
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(width: 180, height: 80)
        }
        .frame(width: 180, height: 220)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
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
