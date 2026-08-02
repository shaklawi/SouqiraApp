//
//  ProfileView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appSettings: AppSettings
    @State private var myListings: [BusinessListing] = []
    @State private var isLoadingListings = false
    @State private var showLanguageSheet = false
    @State private var showDeleteConfirmation = false
    @State private var pushInboxItems: [PushInboxItem] = []
    
    private let apiService = APIService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                SouqiraPatternBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        profileHero
                        pushInboxCard
                        listingsCard
                        favoritesCard
                        settingsCard
                        if authViewModel.isAuthenticated {
                            logoutCard
                            deleteAccountCard
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showLanguageSheet) {
                LanguageSelectionView()
            }
            .confirmationDialog(
                LocalizationManager.deleteConfirmationTitle.get(language: appSettings.language),
                isPresented: $showDeleteConfirmation,
                actions: {
                    Button(LocalizationManager.delete.get(language: appSettings.language), role: .destructive) {
                        Task {
                            await authViewModel.deleteAccount()
                        }
                    }
                    Button(LocalizationManager.cancel.get(language: appSettings.language), role: .cancel) { }
                },
                message: {
                    Text(LocalizationManager.deleteConfirmationMessage.get(language: appSettings.language))
                }
            )
            .task {
                refreshPushInbox()
                if authViewModel.isAuthenticated {
                    await loadMyListings()
                } else {
                    myListings = []
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .pushInboxUpdated)) { _ in
                refreshPushInbox()
            }
            .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    Task {
                        await loadMyListings()
                    }
                } else {
                    myListings = []
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .listingCreated)) { _ in
                guard authViewModel.isAuthenticated else { return }
                Task {
                    await loadMyListings()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .listingDeleted)) { notification in
                guard let listingId = notification.object as? String else { return }
                myListings.removeAll { $0.id == listingId }
            }
        }
    }

    private var profileHero: some View {
        Group {
            if let user = authViewModel.currentUser {
                HStack(spacing: 14) {
                    Circle()
                        .fill(DesignSystem.Colors.primaryGradient)
                        .frame(width: 70, height: 70)
                        .overlay {
                            Text(user.name.prefix(1).uppercased())
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .shadow(color: DesignSystem.Colors.primary.opacity(0.2), radius: 10, x: 0, y: 5)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.gray900)

                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(DesignSystem.Colors.gray600)
                            .lineLimit(1)
                    }

                    Spacer()

                    Circle()
                        .fill(DesignSystem.Colors.accentGradient)
                        .frame(width: 12, height: 12)
                }
                .padding(18)
                .background(cardBackground)
            }
        }
    }

    private var listingsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizationManager.myListings.get(language: appSettings.language))
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.gray700)

            NavigationLink {
                MyListingsView(listings: $myListings)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.title3)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(width: 34)

                    Text(LocalizationManager.myAds.get(language: appSettings.language))
                        .foregroundColor(DesignSystem.Colors.gray900)

                    Spacer()

                    if isLoadingListings {
                        ProgressView()
                            .controlSize(.small)
                    } else if !myListings.isEmpty {
                        Text("\(myListings.count)")
                            .font(.subheadline)
                            .foregroundColor(DesignSystem.Colors.gray500)
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.gray400)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.9))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(cardBackground)
    }

    private var pushInboxCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Push Messages")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.gray700)

            NavigationLink {
                PushInboxView(items: pushInboxItems)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title3)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(width: 34)

                    Text("View received push notifications")
                        .foregroundColor(DesignSystem.Colors.gray900)

                    Spacer()

                    if !pushInboxItems.isEmpty {
                        Text("\(pushInboxItems.count)")
                            .font(.subheadline)
                            .foregroundColor(DesignSystem.Colors.gray500)
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.gray400)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.9))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(cardBackground)
    }

    private var favoritesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizationManager.favorites.get(language: appSettings.language))
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.gray700)

            NavigationLink {
                FavoritesView()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                        .frame(width: 34)

                    Text(LocalizationManager.favorites.get(language: appSettings.language))
                        .foregroundColor(DesignSystem.Colors.gray900)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.gray400)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.9))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(cardBackground)
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizationManager.settings.get(language: appSettings.language))
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.gray700)

            Button {
                showLanguageSheet = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "globe")
                        .font(.title3)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(width: 34)

                    Text(LocalizationManager.language.get(language: appSettings.language))
                        .foregroundColor(DesignSystem.Colors.gray900)

                    Spacer()

                    Text(languageName)
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.Colors.gray500)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.gray400)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.9))
                )
            }
            .buttonStyle(.plain)

            Toggle(isOn: $appSettings.isDarkMode) {
                HStack(spacing: 12) {
                    Image(systemName: "moon.fill")
                        .font(.title3)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(width: 34)

                    Text(LocalizationManager.darkMode.get(language: appSettings.language))
                        .foregroundColor(DesignSystem.Colors.gray900)
                }
            }
            .tint(DesignSystem.Colors.primary)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.9))
            )
        }
        .padding(16)
        .background(cardBackground)
    }

    private var logoutCard: some View {
        Button(role: .destructive) {
            authViewModel.logout()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.title3)
                Text(LocalizationManager.logout.get(language: appSettings.language))
                    .font(.headline)
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.94))
            )
        }
    }

    private var deleteAccountCard: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "trash.fill")
                    .font(.title3)
                Text(LocalizationManager.deleteAccount.get(language: appSettings.language))
                    .font(.headline)
                Spacer()
                if authViewModel.isLoading {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.94))
            )
        }
        .disabled(authViewModel.isLoading)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(DesignSystem.Colors.gray200.opacity(0.9), lineWidth: 1)
            )
            .shadow(color: DesignSystem.Colors.gray900.opacity(0.06), radius: 12, x: 0, y: 4)
    }
    
    private var languageName: String {
        switch appSettings.language {
        case "ar":
            return "العربية"
        case "ku":
            return "کوردی"
        default:
            return "English"
        }
    }
    
    private func loadMyListings() async {
        guard authViewModel.isAuthenticated else {
            myListings = []
            isLoadingListings = false
            return
        }

        isLoadingListings = true
        do {
            myListings = try await apiService.fetchUserListings()
        } catch {
            print("Failed to load user listings: \(error)")
        }
        isLoadingListings = false
    }

    private func refreshPushInbox() {
        pushInboxItems = PushNotificationManager.shared.getInboxItems()
    }
}

private struct PushInboxView: View {
    let items: [PushInboxItem]

    var body: some View {
        List {
            if items.isEmpty {
                Text("No push messages yet")
                    .foregroundColor(.secondary)
            } else {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.headline)
                        Text(item.body)
                            .font(.body)
                            .foregroundColor(.primary)
                        Text(item.receivedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Push Messages")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MyListingsView: View {
    @Binding var listings: [BusinessListing]
    @EnvironmentObject var appSettings: AppSettings
    @State private var editingListing: BusinessListing?
    @State private var updatingListingID: String?
    @State private var deletingListingID: String?
    @State private var listingPendingDeletion: BusinessListing?
    @State private var isRefreshingListings = false
    @State private var errorMessage: String?
    private let apiService = APIService()
    
    var body: some View {
        ZStack {
            SouqiraPatternBackground()

            ScrollView {
            if listings.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "square.stack.3d.up")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text(LocalizationManager.noListingsYet.get(language: appSettings.language))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(LocalizationManager.createFirstListing.get(language: appSettings.language))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(Array(listings.enumerated()), id: \.element.id) { index, listing in
                        VStack(spacing: 10) {
                            NavigationLink(destination: ListingDetailView(listing: listing)) {
                                ListingCard(listing: listing)
                            }
                            .buttonStyle(.plain)

                            HStack(spacing: 10) {
                                Button {
                                    editingListing = listing
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "pencil")
                                        Text(localize(en: "Edit Ad", ar: "تعديل الإعلان", ku: "دەستکاریکردنی ڕیکلام"))
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(DesignSystem.Colors.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .contentShape(Rectangle())
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color.white.opacity(0.9))
                                    )
                                }

                                Button(role: .destructive) {
                                    listingPendingDeletion = listing
                                } label: {
                                    HStack(spacing: 6) {
                                        if deletingListingID == listing.id {
                                            ProgressView()
                                                .controlSize(.small)
                                        } else {
                                            Image(systemName: "trash")
                                        }
                                        Text(localize(en: "Delete", ar: "حذف", ku: "سڕینەوە"))
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(DesignSystem.Colors.error)
                                    )
                                }
                                .disabled(deletingListingID == listing.id)

                                Menu {
                                    Button {
                                        updateSaleStatus(for: listing, saleStatus: "available")
                                    } label: {
                                        Label(localize(en: "Available", ar: "متاح", ku: "بەردەست"), systemImage: "checkmark.circle")
                                    }

                                    Button {
                                        updateSaleStatus(for: listing, saleStatus: "sold")
                                    } label: {
                                        Label(localize(en: "Sold", ar: "مباع", ku: "فرۆشراو"), systemImage: "xmark.circle")
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        if updatingListingID == listing.id {
                                            ProgressView()
                                                .controlSize(.small)
                                        }
                                        Text(statusDisplayText(for: listing))
                                            .font(.subheadline)
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(statusColor(for: listing))
                                    )
                                }

                                Spacer()
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(DesignSystem.Colors.gray200.opacity(0.8), lineWidth: 1)
                        )
                        .shadow(color: DesignSystem.Colors.gray900.opacity(0.04), radius: 8, x: 0, y: 4)
                        .zIndex(Double(listings.count - index))
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(DesignSystem.Colors.error)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .scrollIndicators(.hidden)
        }
        .navigationTitle(LocalizationManager.myAds.get(language: appSettings.language))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if listings.isEmpty {
                await refreshListingsFromBackend()
            }
        }
        .refreshable {
            await refreshListingsFromBackend()
        }
        .sheet(item: $editingListing) { listing in
            EditListingView(listing: listing) { updatedListing in
                replaceListing(updatedListing)
            }
        }
        .alert(
            localize(en: "Delete Listing", ar: "حذف الإعلان", ku: "سڕینەوەی ڕیکلام"),
            isPresented: Binding(
                get: { listingPendingDeletion != nil },
                set: { if !$0 { listingPendingDeletion = nil } }
            ),
            actions: {
                Button(localize(en: "Cancel", ar: "إلغاء", ku: "هەڵوەشاندنەوە"), role: .cancel) {
                    listingPendingDeletion = nil
                }
                Button(localize(en: "Delete", ar: "حذف", ku: "سڕینەوە"), role: .destructive) {
                    guard let listing = listingPendingDeletion else { return }
                    deleteListing(listing)
                    listingPendingDeletion = nil
                }
            },
            message: {
                Text(localize(en: "Are you sure you want to delete this ad?", ar: "هل أنت متأكد أنك تريد حذف هذا الإعلان؟", ku: "دڵنیایت دەتەوێت ئەم ڕیکلامە بسڕیتەوە؟"))
            }
        )
    }

    private func replaceListing(_ updatedListing: BusinessListing) {
        if let index = listings.firstIndex(where: { $0.id == updatedListing.id }) {
            listings[index] = updatedListing
        }
    }

    private func updateSaleStatus(for listing: BusinessListing, saleStatus: String) {
        updatingListingID = listing.id
        errorMessage = nil

        Task {
            do {
                let resolvedCoordinates = await ListingLocationResolver.requestCoordinatesJSONString(
                    existing: listing.coordinates,
                    address: listing.address,
                    location: listing.location
                )
                let request = CreateListingRequest(
                    title: listing.title,
                    description: listing.description,
                    price: listing.price,
                    currency: listing.currency.rawValue,
                    location: listing.location,
                    category: listing.category,
                    phone: listing.phone,
                    whatsapp: listing.whatsapp,
                    address: listing.address,
                    coordinates: resolvedCoordinates,
                    status: listing.status.rawValue,
                    saleStatus: saleStatus
                )

                _ = try await apiService.updateListing(id: listing.id, listing: request)
                await refreshListingFromBackend(id: listing.id)
            } catch let error as NetworkError {
                switch error {
                case .serverError(let message):
                    errorMessage = message
                default:
                    errorMessage = localize(en: "Failed to update status.", ar: "فشل تحديث الحالة.", ku: "نوێکردنەوەی دۆخ سەرکەوتوو نەبوو.")
                }
            } catch {
                errorMessage = localize(en: "Failed to update status.", ar: "فشل تحديث الحالة.", ku: "نوێکردنەوەی دۆخ سەرکەوتوو نەبوو.")
            }

            updatingListingID = nil
        }
    }

    private func statusDisplayText(for listing: BusinessListing) -> String {
        switch listing.status {
        case .pending:
            return localize(en: "Pending", ar: "قيد المراجعة", ku: "چاوەڕوانی پشکنین")
        case .rejected:
            return localize(en: "Rejected", ar: "مرفوض", ku: "ڕەتکراوە")
        case .approved:
            if listing.saleStatus == "sold" {
                return localize(en: "Sold", ar: "مباع", ku: "فرۆشراو")
            }
            if listing.saleStatus == "available" {
                return localize(en: "Available", ar: "متاح", ku: "بەردەست")
            }
            return localize(en: "Approved", ar: "مقبول", ku: "پەسەندکراو")
        }
    }

    private func statusColor(for listing: BusinessListing) -> Color {
        switch listing.status {
        case .pending:
            return .orange
        case .rejected:
            return DesignSystem.Colors.error
        case .approved:
            return listing.saleStatus == "sold" ? DesignSystem.Colors.error : DesignSystem.Colors.success
        }
    }

    private func refreshListingsFromBackend() async {
        guard !isRefreshingListings else { return }
        isRefreshingListings = true
        defer { isRefreshingListings = false }

        do {
            listings = try await apiService.fetchUserListings()
        } catch {
            errorMessage = localize(en: "Failed to load listings.", ar: "فشل تحميل الإعلانات.", ku: "بارکردنی ڕیکلامەکان سەرکەوتوو نەبوو.")
        }
    }

    private func refreshListingFromBackend(id: String) async {
        do {
            let refreshed = try await apiService.fetchMyListingDetail(id: id)
            replaceListing(refreshed)
        } catch {
            // Fall back to full list refresh if single-item endpoint fails.
            await refreshListingsFromBackend()
        }
    }

    private func deleteListing(_ listing: BusinessListing) {
        deletingListingID = listing.id
        errorMessage = nil

        Task {
            do {
                try await apiService.deleteListing(id: listing.id)
                await MainActor.run {
                    listings.removeAll { $0.id == listing.id }
                    deletingListingID = nil
                }
                NotificationCenter.default.post(name: .listingDeleted, object: listing.id)
            } catch let error as NetworkError {
                await MainActor.run {
                    switch error {
                    case .serverError(let message):
                        errorMessage = message
                    default:
                        errorMessage = localize(en: "Failed to delete listing.", ar: "فشل حذف الإعلان.", ku: "سڕینەوەی ڕیکلام سەرکەوتوو نەبوو.")
                    }
                    deletingListingID = nil
                }
            } catch {
                await MainActor.run {
                    errorMessage = localize(en: "Failed to delete listing.", ar: "فشل حذف الإعلان.", ku: "سڕینەوەی ڕیکلام سەرکەوتوو نەبوو.")
                    deletingListingID = nil
                }
            }
        }
    }

    private func localize(en: String, ar: String, ku: String) -> String {
        switch appSettings.language {
        case "ar":
            return ar
        case "ku":
            return ku
        default:
            return en
        }
    }
}

struct EditListingView: View {
    let listing: BusinessListing
    let onSaved: (BusinessListing) -> Void

    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var description: String
    @State private var price: String
    @State private var selectedCurrency: String
    @State private var saleStatus: String
    @State private var phone: String
    @State private var whatsapp: String

    @State private var isSaving = false
    @State private var errorMessage: String?

    private let apiService = APIService()

    init(listing: BusinessListing, onSaved: @escaping (BusinessListing) -> Void) {
        self.listing = listing
        self.onSaved = onSaved
        _title = State(initialValue: listing.title)
        _description = State(initialValue: listing.description)
        _price = State(initialValue: listing.price == 0 ? "" : String(Int(listing.price)))
        _selectedCurrency = State(initialValue: listing.currency.rawValue.uppercased())
        _saleStatus = State(initialValue: listing.saleStatus == "sold" ? "sold" : "available")
        _phone = State(initialValue: listing.phone ?? "")
        _whatsapp = State(initialValue: listing.whatsapp ?? "")
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !price.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SouqiraPatternBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        editorHeader
                        statusCard
                        detailsCard
                        contactCard
                        saveCard
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(localize(en: "Edit Listing", ar: "تعديل الإعلان", ku: "دەستکاریکردنی ڕیکلام"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localize(en: "Cancel", ar: "إلغاء", ku: "هەڵوەشاندنەوە")) {
                        dismiss()
                    }
                }
            }
        }
    }

    private var editorHeader: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(DesignSystem.Colors.primaryGradient)
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "square.and.pencil")
                        .font(.title3)
                        .foregroundColor(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(localize(en: "Update your ad", ar: "حدّث إعلانك", ku: "ڕیکلامەکەت نوێ بکەرەوە"))
                    .font(.headline)
                    .foregroundColor(DesignSystem.Colors.gray900)
                Text(localize(en: "Edit details and change status", ar: "عدّل التفاصيل وغيّر الحالة", ku: "وردەکاری دەستکاری بکە و دۆخ بگۆڕە"))
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.gray600)
            }
            Spacer()
        }
        .padding(16)
        .background(cardBackground)
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(localize(en: "Ad Status", ar: "حالة الإعلان", ku: "دۆخی ڕیکلام"))
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.gray800)

            Picker("", selection: $saleStatus) {
                Text(localize(en: "Available", ar: "متاح", ku: "بەردەست")).tag("available")
                Text(localize(en: "Sold", ar: "مباع", ku: "فرۆشراو")).tag("sold")
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .background(cardBackground)
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localize(en: "Business Details", ar: "تفاصيل النشاط", ku: "وردەکارییەکانی کار"))
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.gray800)

            labeledTextField(
                title: localize(en: "Title", ar: "العنوان", ku: "ناونیشان"),
                text: $title
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(localize(en: "Description", ar: "الوصف", ku: "وەسف"))
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.gray600)

                TextEditor(text: $description)
                    .frame(minHeight: 110)
                    .padding(8)
                    .background(Color.white.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(DesignSystem.Colors.gray200, lineWidth: 1)
                    )
                    .cornerRadius(12)
            }

            HStack(spacing: 10) {
                labeledTextField(
                    title: localize(en: "Price", ar: "السعر", ku: "نرخ"),
                    text: $price,
                    keyboardType: .decimalPad
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(localize(en: "Currency", ar: "العملة", ku: "دراو"))
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.gray600)

                    Picker("", selection: $selectedCurrency) {
                        Text("USD").tag("USD")
                        Text("IQD").tag("IQD")
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var contactCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localize(en: "Contact", ar: "التواصل", ku: "پەیوەندی"))
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.gray800)

            labeledTextField(
                title: localize(en: "Phone Number", ar: "رقم الهاتف", ku: "ژمارەی تەلەفۆن"),
                text: $phone,
                keyboardType: .phonePad
            )

            labeledTextField(
                title: localize(en: "WhatsApp (optional)", ar: "واتساب (اختياري)", ku: "واتساپ (ئارەزوومەندانە)"),
                text: $whatsapp,
                keyboardType: .phonePad
            )
        }
        .padding(16)
        .background(cardBackground)
    }

    private var saveCard: some View {
        VStack(spacing: 10) {
            Button(action: saveListing) {
                HStack(spacing: 10) {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                    }

                    Text(localize(en: "Save Changes", ar: "حفظ التعديلات", ku: "پاشەکەوتکردنی گۆڕانکارییەکان"))
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isFormValid && !isSaving ? AnyShapeStyle(DesignSystem.Colors.primaryGradient) : AnyShapeStyle(DesignSystem.Colors.gray400))
                )
            }
            .disabled(!isFormValid || isSaving)

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.error)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(DesignSystem.Colors.gray200.opacity(0.9), lineWidth: 1)
            )
            .shadow(color: DesignSystem.Colors.primary.opacity(0.1), radius: 12, x: 0, y: 5)
    }

    private func labeledTextField(
        title: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.gray600)

            TextField(title, text: text)
                .keyboardType(keyboardType)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignSystem.Colors.gray200, lineWidth: 1)
                )
                .cornerRadius(12)
        }
    }

    private func saveListing() {
        guard isFormValid else { return }

        isSaving = true
        errorMessage = nil

        Task {
            do {
                let cleanedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
                let cleanedWhatsApp = whatsapp.trimmingCharacters(in: .whitespacesAndNewlines)
                let resolvedCoordinates = await ListingLocationResolver.requestCoordinatesJSONString(
                    existing: listing.coordinates,
                    address: listing.address,
                    location: listing.location
                )
                let request = CreateListingRequest(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                    price: Double(price) ?? 0,
                    currency: selectedCurrency.lowercased(),
                    location: listing.location,
                    category: listing.category,
                    phone: cleanedPhone,
                    whatsapp: cleanedWhatsApp.isEmpty ? cleanedPhone : cleanedWhatsApp,
                    address: listing.address,
                    coordinates: resolvedCoordinates,
                    status: listing.status.rawValue,
                    saleStatus: saleStatus
                )

                let updatedListing = try await apiService.updateListing(id: listing.id, listing: request)
                onSaved(updatedListing)
                dismiss()
            } catch let error as NetworkError {
                switch error {
                case .serverError(let message):
                    errorMessage = message
                default:
                    errorMessage = localize(en: "Failed to save changes.", ar: "فشل حفظ التعديلات.", ku: "پاشەکەوتکردنی گۆڕانکارییەکان سەرکەوتوو نەبوو.")
                }
            } catch {
                errorMessage = localize(en: "Failed to save changes.", ar: "فشل حفظ التعديلات.", ku: "پاشەکەوتکردنی گۆڕانکارییەکان سەرکەوتوو نەبوو.")
            }

            isSaving = false
        }
    }

    private func localize(en: String, ar: String, ku: String) -> String {
        switch appSettings.language {
        case "ar":
            return ar
        case "ku":
            return ku
        default:
            return en
        }
    }
}

struct LanguageSelectionView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    let languages = [
        ("en", "English", "🇬🇧"),
        ("ar", "العربية", "🇮🇶"),
        ("ku", "کوردی", "")
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(languages, id: \.0) { code, name, flag in
                    Button {
                        appSettings.setLanguage(code)
                        dismiss()
                    } label: {
                        HStack {
                            flagView(code: code, emoji: flag)
                            Text(name)
                                .foregroundColor(.primary)
                            Spacer()
                            if appSettings.language == code {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle(LocalizationManager.selectLanguage.get(language: appSettings.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizationManager.done.get(language: appSettings.language)) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func flagView(code: String, emoji: String) -> some View {
        Group {
            if code == "ku" {
                Image("flag")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                    )
            } else {
                Text(emoji)
                    .font(.title2)
            }
        }
        .frame(width: 28, alignment: .leading)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(AppSettings())
}
