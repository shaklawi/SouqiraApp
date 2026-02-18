//
//  ListingDetailView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI
import MapKit

struct MapLocation: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
}

struct ListingDetailView: View {
    let listing: BusinessListing
    @EnvironmentObject var appSettings: AppSettings
    @State private var currentImageIndex = 0
    @State private var showContactSheet = false
    @State private var isFavorite = false
    @State private var showShareSheet = false
    @State private var showPriceHistory = false
    @State private var region: MKCoordinateRegion
    
    private let apiService = APIService()
    
    init(listing: BusinessListing) {
        self.listing = listing
        if let coords = listing.coordinates {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: coords.lat,
                    longitude: coords.lng
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 33.3152, longitude: 44.3661), // Baghdad center
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Image Gallery
                imageGallery(images: listing.images)
                
                // Content
                VStack(alignment: .leading, spacing: 20) {
                    // Price & Status
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(listing.formattedPrice)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if listing.isSold {
                                Text(LocalizationManager.sold.get(language: appSettings.language))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.red)
                                    .cornerRadius(6)
                            }
                        }
                        
                        Spacer()
                        
                        // Favorite Button
                        Button(action: { toggleFavorite() }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                    }
                        
                    Divider()
                    
                    // Title
                    Text(listing.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    // Location & Views
                    HStack(spacing: 16) {
                        Label(listing.location.capitalized, systemImage: "mappin.circle.fill")
                        Label("\(listing.views) \(LocalizationManager.views.get(language: appSettings.language))", systemImage: "eye.fill")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Divider()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizationManager.description.get(language: appSettings.language))
                            .font(.headline)
                        
                        Text(listing.description)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    Divider()
                    
                    // Price History
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.blue)
                            Text("Price History")
                                .font(.headline)
                            Spacer()
                            Button(action: { showPriceHistory.toggle() }) {
                                Image(systemName: showPriceHistory ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if showPriceHistory {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Original Price:")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(listing.formattedPrice)
                                        .fontWeight(.semibold)
                                }
                                Text("No price changes yet")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    
                    Divider()
                    
                    // Google Maps Location
                    if let address = listing.address, !address.isEmpty, let coords = listing.coordinates {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "map.fill")
                                    .foregroundColor(.blue)
                                Text("Location")
                                    .font(.headline)
                            }
                            
                            Text(address)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Map(coordinateRegion: $region, annotationItems: [MapLocation(id: listing.id, coordinate: CLLocationCoordinate2D(latitude: coords.lat, longitude: coords.lng))]) { location in
                                MapMarker(coordinate: location.coordinate, tint: .blue)
                            }
                            .frame(height: 200)
                            .cornerRadius(12)
                            .onTapGesture {
                                openInMaps()
                            }
                            
                            Button(action: openInMaps) {
                                HStack {
                                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                                    Text("Open in Maps")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Category
                    HStack {
                        Text(LocalizationManager.category.get(language: appSettings.language))
                            .font(.headline)
                        Spacer()
                        Text(listing.category.capitalized)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Posted Date
                    HStack {
                        Text(LocalizationManager.posted.get(language: appSettings.language))
                            .font(.headline)
                        Spacer()
                        Text(listing.createdAt, style: .date)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [generateShareText(listing)])
        }
        .safeAreaInset(edge: .bottom) {
            if !listing.isSold {
                HStack(spacing: 12) {
                    // WhatsApp Button
                    if let whatsapp = listing.whatsapp {
                        Button(action: { openWhatsApp(number: whatsapp) }) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("WhatsApp")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    // Call Button
                    if let phone = listing.phone {
                        Button(action: { callPhone(number: phone) }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("Call")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
        .sheet(isPresented: $showContactSheet) {
            ContactSellerView(listing: listing)
        }
    }
    
    private func openWhatsApp(number: String) {
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        let message = "Hi, I'm interested in your listing: \(listing.title)"
        let urlString = "https://wa.me/\(cleanNumber)?text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func callPhone(number: String) {
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        if let url = URL(string: "tel://\(cleanNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openInMaps() {
        guard let coords = listing.coordinates else { return }
        
        let coordinate = CLLocationCoordinate2D(
            latitude: coords.lat,
            longitude: coords.lng
        )
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = listing.title
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    private func imageGallery(images: [String]) -> some View {
        TabView(selection: $currentImageIndex) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, imageUrl in
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay {
                                ProgressView()
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay {
                                Image(systemName: "building.2")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
                .tag(index)
            }
        }
        .frame(height: 400)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
    
    private var contactButton: some View {
        Button(action: { showContactSheet = true }) {
            HStack {
                Image(systemName: "message.fill")
                Text(LocalizationManager.contactSeller.get(language: appSettings.language))
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
    
    private func toggleFavorite() {
        let previousState = isFavorite
        isFavorite.toggle()
        Task {
            do {
                try await apiService.toggleFavorite(listingId: listing.id, isCurrentlyFavorite: previousState)
            } catch {
                // Revert on error
                isFavorite = previousState
                print("❌ Failed to toggle favorite: \(error)")
            }
        }
    }
    
    private func generateShareText(_ listing: BusinessListing) -> String {
        return """
        Check out this business opportunity on Souqira!
        
        \(listing.title)
        Price: \(listing.formattedPrice)
        Location: \(listing.location.capitalized)
        
        \(listing.description)
        """
    }
}

struct ContactSellerView: View {
    let listing: BusinessListing
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showMessageComposer = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Send Message (if logged in)
                if authViewModel.isAuthenticated {
                    contactOption(
                        icon: "message.fill",
                        title: "Send Message",
                        subtitle: "Chat with seller directly",
                        color: .blue
                    ) {
                        showMessageComposer = true
                    }
                }
                
                // Phone
                if let phone = listing.phone {
                    contactOption(
                        icon: "phone.fill",
                        title: LocalizationManager.call.get(language: appSettings.language),
                        subtitle: phone,
                        color: .green
                    ) {
                        if let url = URL(string: "tel://\(phone)") {
                            UIApplication.shared.open(url)
                        }
                        dismiss()
                    }
                }
                
                // WhatsApp
                if let whatsapp = listing.whatsapp {
                    contactOption(
                        icon: "message.fill",
                        title: "WhatsApp",
                        subtitle: whatsapp,
                        color: .green
                    ) {
                        let urlString = "https://wa.me/\(whatsapp.replacingOccurrences(of: " ", with: ""))"
                        if let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                        dismiss()
                    }
                }
                
                // Email (from owner if available)
                if let email = listing.owner.email {
                    contactOption(
                        icon: "envelope.fill",
                        title: LocalizationManager.email.get(language: appSettings.language),
                        subtitle: email,
                        color: .blue
                    ) {
                        if let url = URL(string: "mailto:\(email)") {
                            UIApplication.shared.open(url)
                        }
                        dismiss()
                    }
                }
                
                // If no contact info available and not logged in
                if !authViewModel.isAuthenticated && listing.phone == nil && listing.whatsapp == nil && listing.owner.email == nil {
                    Text("No contact information available")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding()
            .navigationTitle(LocalizationManager.contactSeller.get(language: appSettings.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizationManager.close.get(language: appSettings.language)) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showMessageComposer) {
                MessageComposerView(
                    receiverId: listing.owner.id,
                    listingId: listing.id,
                    listing: listing
                )
            }
        }
    }
    
    private func contactOption(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
