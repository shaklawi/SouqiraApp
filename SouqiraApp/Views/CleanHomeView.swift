//
//  CleanHomeView.swift
//  Souqira
//

import SwiftUI
import CoreLocation

struct CleanHomeView: View {
    @StateObject private var viewModel = ListingsViewModel()
    @StateObject private var distanceProvider = ListingDistanceProvider()
    @EnvironmentObject var appSettings: AppSettings
    @State private var showFilters = false
    @State private var showSettingsSheet = false
    @State private var currentPremiumIndex = 0
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.primaryDark,
                        DesignSystem.Colors.primary,
                        Color(hex: "#1B255A")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        topActionsSection
                            .padding(.horizontal, 16)
                        quickSearchBar
                            .padding(.horizontal, 16)
                        premiumSection
                        listingsSection
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                }
                .refreshable {
                    await refreshContent()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showFilters) { FilterView(viewModel: viewModel) }
            .sheet(isPresented: $showSettingsSheet) { SettingsSheet() }
            .task {
                if viewModel.listings.isEmpty {
                    await refreshContent()
                }
                distanceProvider.requestAuthorizationIfNeeded()
                prefetchVisibleImages()
            }
            .onChange(of: viewModel.listings.count) { _ in
                prefetchVisibleImages()
            }
            .onReceive(NotificationCenter.default.publisher(for: .listingCreated)) { _ in
                Task {
                    await refreshContent()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .listingDeleted)) { notification in
                guard let listingId = notification.object as? String else { return }
                viewModel.listings.removeAll { $0.id == listingId }
            }
        }
    }

    private func prefetchVisibleImages() {
        let urls = Array(viewModel.listings.prefix(12)).compactMap { URL(string: $0.primaryImage) }
        Task {
            await ImagePipeline.shared.prefetch(urls: urls)
        }
    }

    private func refreshContent() async {
        viewModel.searchQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        await viewModel.fetchListings(refresh: true)
        prefetchVisibleImages()
    }

    private var topActionsSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Souqira")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(localizedHeaderCaption)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.65))
            }

            Spacer()

            Button(action: { showSettingsSheet = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }

    private var quickSearchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                
                TextField(
                    "",
                    text: $searchText,
                    prompt: Text(searchPlaceholder)
                        .foregroundColor(.white.opacity(0.62))
                )
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .tint(.white)
                    .submitLabel(.search)
                    .onSubmit {
                        viewModel.searchQuery = searchText
                        Task {
                            await viewModel.fetchListings(refresh: true)
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.09))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button(action: { showFilters = true }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localizedPremiumTitle)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 16)

            if viewModel.isLoading && viewModel.listings.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(.white)
                    Spacer()
                }
                .padding(.vertical, 40)
            } else if !featuredListings.isEmpty {
                TabView(selection: $currentPremiumIndex) {
                    ForEach(Array(featuredListings.enumerated()), id: \.element.id) { index, listing in
                        NavigationLink(destination: ListingDetailView(listing: listing)) {
                            PremiumListingCard(
                                listing: listing,
                                distanceText: distanceProvider.distanceText(for: listing, language: appSettings.language),
                                language: appSettings.language
                            )
                            .padding(.horizontal, 16)
                        }
                        .buttonStyle(.plain)
                        .tag(index)
                    }
                }
                .frame(height: 280)
                .tabViewStyle(.page(indexDisplayMode: .automatic))
            }
        }
    }

    private var listingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(localizedAllListingsTitle)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            if !viewModel.isLoading && viewModel.listings.isEmpty {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 260)
                    .overlay(
                        VStack(spacing: 10) {
                            Image(systemName: "tray")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundColor(.white.opacity(0.75))
                            Text(localizedNoListingsTitle)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    )
            } else {
                let spacing: CGFloat = 16
                let screenWidth = UIScreen.main.bounds.width
                let horizontalPadding: CGFloat = 32
                let cellWidth = (screenWidth - horizontalPadding - spacing) / 2

                LazyVStack(spacing: 16) {
                    ForEach(Array(listingRows.enumerated()), id: \.offset) { rowIndex, row in
                        HStack(alignment: .top, spacing: spacing) {
                            ForEach(row) { listing in
                                listingGridCell(listing, width: cellWidth)
                            }

                            if row.count == 1 {
                                Color.clear
                                    .frame(width: cellWidth, height: 268)
                            }
                        }
                        .frame(width: screenWidth - horizontalPadding, alignment: .leading)
                        .onAppear {
                            if rowIndex >= max(listingRows.count - 2, 0), viewModel.hasMorePages {
                                Task {
                                    await viewModel.fetchListings()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var localizedHeaderCaption: String {
        switch appSettings.language {
        case "ar":
            return "سوق الأعمال والعقارات التجارية"
        case "ku":
            return "بازاڕی کار و موڵکی بازرگانی"
        default:
            return "Business marketplace"
        }
    }

    private var searchPlaceholder: String {
        switch appSettings.language {
        case "ar":
            return "ابحث عن فرصة..."
        case "ku":
            return "بگەڕە دنگی دەرفەت..."
        default:
            return "Search for opportunities..."
        }
    }

    private var localizedPremiumTitle: String {
        switch appSettings.language {
        case "ar":
            return "إعلانات مميزة"
        case "ku":
            return "ڕیکلامی تایبەت"
        default:
            return "Premium ads"
        }
    }

    private var localizedAllListingsTitle: String {
        switch appSettings.language {
        case "ar":
            return "كل الإعلانات"
        case "ku":
            return "هەموو ڕیکلامەکان"
        default:
            return "All listings"
        }
    }

    private var localizedNoListingsTitle: String {
        switch appSettings.language {
        case "ar":
            return "لا توجد إعلانات حالياً"
        case "ku":
            return "ئێستا هیچ ڕیکلامێک نییە"
        default:
            return "No listings available"
        }
    }

    private var featuredListings: [BusinessListing] {
        let premium = viewModel.listings.filter { $0.isFeatured == true }
        if premium.count >= 3 {
            return Array(premium.prefix(3))
        }
        let fallback = viewModel.listings.filter { listing in
            !premium.contains(where: { $0.id == listing.id })
        }
        return Array((premium + fallback).prefix(3))
    }

    private var listingRows: [[BusinessListing]] {
        stride(from: 0, to: viewModel.listings.count, by: 2).map { startIndex in
            Array(viewModel.listings[startIndex..<min(startIndex + 2, viewModel.listings.count)])
        }
    }

    private func listingGridCell(_ listing: BusinessListing, width: CGFloat) -> some View {
        NavigationLink(destination: ListingDetailView(listing: listing)) {
            MarketplaceGridCard(
                listing: listing,
                cardWidth: width,
                distanceText: distanceProvider.distanceText(for: listing, language: appSettings.language),
                language: appSettings.language
            )
        }
        .buttonStyle(.plain)
        .frame(width: width, height: 268)
        .clipped()
    }


}

private struct ListingSoldWatermark: View {
    let language: String

    private var text: String {
        switch language {
        case "ar":
            return "مباع"
        case "ku":
            return "فرۆشراو"
        default:
            return "SOLD"
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .black, design: .rounded))
            .tracking(1.2)
            .foregroundColor(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [Color.red.opacity(0.95), Color(hex: "#991B1B")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.22), radius: 10, x: 0, y: 5)
            .rotationEffect(.degrees(-18))
            .allowsHitTesting(false)
    }
}

private struct PremiumListingCard: View {
    let listing: BusinessListing
    let distanceText: String
    let language: String
    private let cornerRadius: CGFloat = 24
    private var isRTL: Bool { language == "ar" || language == "ku" }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section
            ZStack(alignment: .topTrailing) {
                CachedRemoteImage(url: URL(string: listing.primaryImage)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .overlay {
                            if listing.isSold {
                                Color.black.opacity(0.18)
                            }
                        }
                } placeholder: {
                    LinearGradient(
                        colors: [Color(hex: "#5265A6"), Color(hex: "#3E4C88")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .clipped()

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.6)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9, weight: .bold))
                            Text(premiumBadgeText)
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#EAB308"), Color(hex: "#F4C82F")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())

                        Spacer()
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 6) {
                        Text(listing.title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(isRTL ? .trailing : .leading)
                            .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                            .lineSpacing(1.2)

                        HStack(spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 12, weight: .bold))
                            Text(listing.location.capitalized)
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                            if !distanceText.isEmpty {
                                Text("•")
                                Text(distanceText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.92))
                    }
                }
                .padding(16)

                if listing.isSold {
                    ListingSoldWatermark(language: language)
                }
            }
            .frame(height: 160)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: cornerRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: cornerRadius,
                    style: .continuous
                )
            )

            // Info section
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(priceText)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#0F1A2E"))
                    Spacer()
                    categoryBadge(listing.category)
                        .padding(.horizontal, 0)
                }

                if !listing.description.isEmpty {
                    Text(listing.description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(hex: "#5C6E7E"))
                        .lineLimit(2)
                        .multilineTextAlignment(isRTL ? .trailing : .leading)
                        .lineSpacing(1.4)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(Color.white)
        }
        .frame(height: 280)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color(hex: "#E8EBF1"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }

    private var premiumBadgeText: String {
        switch language {
        case "ar":
            return "خاص"
        case "ku":
            return "تایبەت"
        default:
            return "Featured"
        }
    }

    private var priceText: String {
        if listing.price > 0 {
            return listing.formattedPrice
        }

        switch language {
        case "ar":
            return "السعر عند الطلب"
        case "ku":
            return "نرخ بە داواکاری"
        default:
            return "Price on request"
        }
    }

    private func localizedCategoryName(_ categoryId: String) -> String {
        Category.displayName(for: categoryId, language: language)
    }

    private func categoryBadge(_ categoryId: String) -> some View {
        Text(localizedCategoryName(categoryId))
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(Color(hex: "#1A5276"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "#E8F4F8"))
            .clipShape(Capsule())
    }
}

private struct MarketplaceGridCard: View {
    let listing: BusinessListing
    let cardWidth: CGFloat
    let distanceText: String
    let language: String
    private let cornerRadius: CGFloat = 20
    private var isRTL: Bool { language == "ar" || language == "ku" }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image with featured badge
            ZStack(alignment: .topLeading) {
                CachedRemoteImage(url: URL(string: listing.primaryImage)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .overlay {
                            if listing.isSold {
                                Color.black.opacity(0.18)
                            }
                        }
                } placeholder: {
                    LinearGradient(
                        colors: [Color(hex: "#5A6A9D"), Color(hex: "#2D476F")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .frame(width: cardWidth, height: 140)
                .clipped()

                if listing.isFeatured == true {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text(featuredMarkerText)
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#EAB308"), Color(hex: "#F4C82F")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .padding(10)
                }

                if listing.isSold {
                    ListingSoldWatermark(language: language)
                }
            }
            .frame(width: cardWidth, height: 140)
            .clipped()
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: cornerRadius,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: cornerRadius,
                    style: .continuous
                )
            )

            // Content area
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(listing.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "#0F1A2E"))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .multilineTextAlignment(isRTL ? .trailing : .leading)
                    .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                    .lineSpacing(1.2)

                // Location
                HStack(spacing: 5) {
                    if isRTL { Spacer() }
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.primary)
                    Text(listing.location.capitalized)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "#6B7A94"))
                        .lineLimit(1)
                    if !isRTL { Spacer() }
                }

                // Distance (if available)
                if !distanceText.isEmpty {
                    HStack(spacing: 5) {
                        if isRTL { Spacer() }
                        Image(systemName: "location.fill")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(hex: "#A0AED1").opacity(0.8))
                        Text(distanceText)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: "#8998B8"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        if !isRTL { Spacer() }
                    }
                }

                Spacer(minLength: 2)

                // Price
                Text(priceText)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#0F1A2E"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .frame(minHeight: 128, alignment: .topLeading)
            .background(Color.white)
        }
        .frame(width: cardWidth, height: 268, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color(hex: "#E8EBF1"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    private var featuredMarkerText: String {
        switch language {
        case "ar":
            return "خاص"
        case "ku":
            return "تایبەت"
        default:
            return "Featured"
        }
    }

    private var priceText: String {
        if listing.price > 0 {
            return listing.formattedPrice
        }

        switch language {
        case "ar":
            return "السعر عند الطلب"
        case "ku":
            return "نرخ بە داواکاری"
        default:
            return "Price on request"
        }
    }
}

private final class ListingDistanceProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var currentLocation: CLLocation?

    private let manager = CLLocationManager()
    private let copenhagenFallback = CLLocation(latitude: 55.6761, longitude: 12.5683)

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestAuthorizationIfNeeded() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            self.currentLocation = locations.last
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func distanceText(for listing: BusinessListing, language: String) -> String {
        guard let destination = destinationLocation(for: listing) else {
            switch language {
            case "ar":
                return "المسافة غير متاحة"
            case "ku":
                return "دووری بەردەست نییە"
            default:
                return "Distance unavailable"
            }
        }

        let source = currentLocation ?? copenhagenFallback
        let km = Int((source.distance(from: destination) / 1000.0).rounded())
        let safeKm = max(km, 1)

        return "\(safeKm) km"
    }

    private func destinationLocation(for listing: BusinessListing) -> CLLocation? {
        if let coordinates = listing.coordinates {
            return CLLocation(latitude: coordinates.lat, longitude: coordinates.lng)
        }

        let cityCenters: [String: CLLocationCoordinate2D] = [
            "baghdad": CLLocationCoordinate2D(latitude: 33.3152, longitude: 44.3661),
            "basra": CLLocationCoordinate2D(latitude: 30.5085, longitude: 47.7804),
            "erbil": CLLocationCoordinate2D(latitude: 36.1911, longitude: 44.0094),
            "mosul": CLLocationCoordinate2D(latitude: 36.3350, longitude: 43.1189),
            "sulaymaniyah": CLLocationCoordinate2D(latitude: 35.5613, longitude: 45.4302),
            "najaf": CLLocationCoordinate2D(latitude: 31.9980, longitude: 44.3396),
            "karbala": CLLocationCoordinate2D(latitude: 32.6160, longitude: 44.0249),
            "kirkuk": CLLocationCoordinate2D(latitude: 35.4681, longitude: 44.3922),
            "duhok": CLLocationCoordinate2D(latitude: 36.8617, longitude: 42.9960),
            "ramadi": CLLocationCoordinate2D(latitude: 33.4259, longitude: 43.2993)
        ]

        let cityKey = listing.location.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let center = cityCenters[cityKey] else {
            return nil
        }

        return CLLocation(latitude: center.latitude, longitude: center.longitude)
    }
}

#Preview {
    CleanHomeView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(AppSettings())
}
