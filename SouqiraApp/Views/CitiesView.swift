//
//  CitiesView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

struct CitiesView: View {
    @StateObject private var viewModel = ListingsViewModel()
    @EnvironmentObject var appSettings: AppSettings
    @State private var citySearchText = ""

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var filteredRegions: [Region] {
        let q = citySearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return viewModel.regions }

        return viewModel.regions.filter { region in
            region.nameEn.lowercased().contains(q)
            || region.nameAr.lowercased().contains(q)
            || region.nameKu.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.primaryDark,
                        DesignSystem.Colors.primary,
                        Color(hex: "#103B57")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        citiesHeader
                            .padding(.horizontal, 16)
                            .padding(.top, 10)

                        searchBar
                            .padding(.horizontal, 16)

                        cityStatsRow
                            .padding(.horizontal, 16)

                        if viewModel.regions.isEmpty {
                            loadingState
                                .padding(.horizontal, 16)
                                .padding(.vertical, 30)
                        } else if filteredRegions.isEmpty {
                            emptyState
                                .padding(.horizontal, 16)
                                .padding(.vertical, 40)
                        } else {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(filteredRegions) { region in
                                    NavigationLink(destination: CityListingsView(region: region)) {
                                        ModernCityCard(region: region, language: appSettings.language)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                        }
                    }
                    .padding(.bottom, 26)
                }
                .refreshable {
                    await viewModel.loadCategoriesAndRegions(forceRefresh: true)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                if viewModel.regions.isEmpty {
                    await viewModel.loadCategoriesAndRegions()
                }
            }
        }
    }

    private var citiesHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizationManager.exploreCities.get(language: appSettings.language))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(LocalizationManager.discoverBusinessOpportunities.get(language: appSettings.language))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.72))
                    .lineLimit(2)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 52, height: 52)
                Image(systemName: "building.2.crop.circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))

            TextField(
                "",
                text: $citySearchText,
                prompt: Text(searchPlaceholder)
                    .foregroundColor(.white.opacity(0.62))
            )
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .tint(.white)

            if !citySearchText.isEmpty {
                Button(action: { citySearchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.55))
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var cityStatsRow: some View {
        HStack(spacing: 10) {
            Text(statsLabel)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.92))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.14))
                .clipShape(Capsule())

            if !citySearchText.isEmpty {
                Text(searchResultsLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.75))
            }

            Spacer()
        }
    }

    private var loadingState: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.12)

            Text(loadingCitiesLabel)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 38)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 44, weight: .light))
                .foregroundColor(.white.opacity(0.7))

            Text(noCitiesMatchLabel)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            Text(searchHintLabel)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var searchPlaceholder: String {
        switch appSettings.language {
        case "ar": return "ابحث عن مدينة..."
        case "ku": return "بگەڕە بە شوێن شارێک..."
        default: return "Search by city..."
        }
    }

    private var loadingCitiesLabel: String {
        switch appSettings.language {
        case "ar": return "جارٍ تحميل المدن..."
        case "ku": return "شارەکان بار دەکرێن..."
        default: return "Loading cities..."
        }
    }

    private var noCitiesMatchLabel: String {
        switch appSettings.language {
        case "ar": return "لا توجد مدينة مطابقة"
        case "ku": return "هیچ شارێک نەدۆزرایەوە"
        default: return "No matching cities"
        }
    }

    private var searchHintLabel: String {
        switch appSettings.language {
        case "ar": return "جرّب كتابة اسم مختلف"
        case "ku": return "ناوێکی تر تاقی بکەوە"
        default: return "Try another city name"
        }
    }

    private var statsLabel: String {
        switch appSettings.language {
        case "ar": return "\(filteredRegions.count) مدينة"
        case "ku": return "\(filteredRegions.count) شار"
        default: return "\(filteredRegions.count) cities"
        }
    }

    private var searchResultsLabel: String {
        switch appSettings.language {
        case "ar": return "نتائج البحث"
        case "ku": return "ئەنجامی گەڕان"
        default: return "Search results"
        }
    }
}

struct ModernCityCard: View {
    let region: Region
    let language: String

    private var primaryName: String {
        region.localizedName(language: language)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(region.emoji)
                    .font(.system(size: 28))
                    .frame(width: 48, height: 48)
                    .background(Color.white.opacity(0.13))
                    .clipShape(Circle())

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
            }

            Text(primaryName)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)

            VStack(alignment: .leading, spacing: 3) {
                Text(region.nameEn)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.78))
                Text(region.nameAr)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.66))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .frame(height: 154)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct CityListingsView: View {
    let region: Region
    @StateObject private var viewModel = ListingsViewModel()
    @EnvironmentObject var appSettings: AppSettings
    @State private var searchText = ""

    private var filteredListings: [BusinessListing] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return viewModel.listings }

        return viewModel.listings.filter { listing in
            listing.title.lowercased().contains(q)
            || listing.description.lowercased().contains(q)
            || listing.category.lowercased().contains(q)
            || listing.location.lowercased().contains(q)
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    DesignSystem.Colors.primaryDark,
                    DesignSystem.Colors.primary,
                    Color(hex: "#103B57")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    cityHeaderCard
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    listingSearchBar
                        .padding(.horizontal, 16)

                    if viewModel.isLoading && viewModel.listings.isEmpty {
                        loadingListingsState
                            .padding(.horizontal, 16)
                            .padding(.vertical, 30)
                    } else if filteredListings.isEmpty {
                        emptyListingsState
                            .padding(.horizontal, 16)
                            .padding(.vertical, 30)
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(filteredListings) { listing in
                                NavigationLink(destination: ListingDetailView(listing: listing)) {
                                    FullWidthListingCard(listing: listing, language: appSettings.language)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)

                        if viewModel.hasMorePages && searchText.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .tint(.white)
                                Spacer()
                            }
                            .padding(.vertical, 18)
                            .onAppear {
                                Task {
                                    await viewModel.fetchListings()
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 28)
            }
            .refreshable {
                viewModel.selectedRegion = region
                await viewModel.fetchListings(refresh: true)
            }
        }
        .navigationTitle(region.localizedName(language: appSettings.language))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.selectedRegion = region
            await viewModel.fetchListings(refresh: true)
        }
    }

    private var cityHeaderCard: some View {
        HStack(spacing: 12) {
            Text(region.emoji)
                .font(.system(size: 28))
                .frame(width: 54, height: 54)
                .background(Color.white.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(region.localizedName(language: appSettings.language))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(listingsCountLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.75))
            }

            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var listingSearchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))

            TextField(
                "",
                text: $searchText,
                prompt: Text(searchListingsPlaceholder)
                    .foregroundColor(.white.opacity(0.62))
            )
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .tint(.white)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.55))
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var loadingListingsState: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.12)

            Text(loadingListingsLabel)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.78))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var emptyListingsState: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 40, weight: .regular))
                .foregroundColor(.white.opacity(0.72))

            Text(noListingsLabel)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            Text(emptyListingsHint)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var listingsCountLabel: String {
        switch appSettings.language {
        case "ar": return "\(viewModel.listings.count) إعلان"
        case "ku": return "\(viewModel.listings.count) ڕیکلام"
        default: return "\(viewModel.listings.count) listings"
        }
    }

    private var searchListingsPlaceholder: String {
        switch appSettings.language {
        case "ar": return "ابحث داخل هذه المدينة..."
        case "ku": return "لە ناو ئەم شارەدا بگەڕێ..."
        default: return "Search in this city..."
        }
    }

    private var loadingListingsLabel: String {
        switch appSettings.language {
        case "ar": return "جارٍ تحميل الإعلانات..."
        case "ku": return "ڕیکلامەکان بار دەکرێن..."
        default: return "Loading listings..."
        }
    }

    private var noListingsLabel: String {
        switch appSettings.language {
        case "ar": return "لا توجد إعلانات حالياً"
        case "ku": return "ئێستا هیچ ڕیکلامێک نییە"
        default: return "No listings found"
        }
    }

    private var emptyListingsHint: String {
        switch appSettings.language {
        case "ar": return "جرّب البحث بكلمات مختلفة أو عُد لاحقاً"
        case "ku": return "وشەی تر تاقی بکەوە یان دواتر بگەڕێوە"
        default: return "Try another search or check back later"
        }
    }
}

struct FullWidthListingCard: View {
    let listing: BusinessListing
    let language: String

    private var localizedCategoryName: String {
        Category.displayName(for: listing.category, language: language)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                CachedRemoteImage(url: URL(string: listing.primaryImage)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    LinearGradient(
                        colors: [Color(hex: "#4A5D94"), Color(hex: "#2B3E6F")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()

                if listing.isFeatured == true {
                    Text(language == "ar" ? "مميز" : language == "ku" ? "تایبەت" : "Featured")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(hex: "#EAB308"))
                        .clipShape(Capsule())
                        .padding(10)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(listing.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(hex: "#10233F"))
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#355D8A"))
                    Text(listing.location.capitalized)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#5D7290"))

                    Text("•")
                        .foregroundColor(Color(hex: "#A7B3C7"))

                    Image(systemName: "eye")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "#5D7290"))
                    Text("\(listing.views)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#5D7290"))
                }

                HStack(alignment: .center, spacing: 10) {
                    Text(localizedCategoryName)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "#1A5276"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(hex: "#E8F4F8"))
                        .clipShape(Capsule())

                    Spacer()

                    Text(listing.formattedPrice)
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: "#10233F"))
                }
            }
            .padding(14)
            .background(Color.white)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    CitiesView()
}
