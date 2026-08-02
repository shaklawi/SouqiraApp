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
    @Environment(\.dismiss) var dismiss
    @State private var currentImageIndex = 0
    @State private var isFavorite = false
    @State private var showShareSheet = false
    @State private var region: MKCoordinateRegion
    @State private var detailedListing: BusinessListing?
    @State private var showReportSheet = false
    @State private var showBlockConfirm = false
    @State private var reportReason = "spam"
    @State private var actionFeedback: String?
    @State private var showFeedback = false
    @State private var showChatSheet = false
    @State private var messageText = ""
    @State private var isSendingMessage = false
    @State private var fallbackCoordinate: CLLocationCoordinate2D?
    @State private var engagementStartTime: Date?
    @State private var hasTrackedViewStart = false
    @State private var lastTrackedImageIndex: Int?
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var messagesViewModel = MessagesViewModel()

    private let apiService = APIService()

    private var currentListing: BusinessListing {
        guard let detailedListing else {
            return listing
        }

        if !detailedListing.images.isEmpty {
            return detailedListing
        }

        return BusinessListing(
            id: detailedListing.id,
            title: detailedListing.title,
            description: detailedListing.description,
            price: detailedListing.price,
            currency: detailedListing.currency,
            location: detailedListing.location,
            category: detailedListing.category,
            images: listing.images,
            vrMedia: detailedListing.vrMedia,
            address: detailedListing.address,
            coordinates: detailedListing.coordinates,
            phone: detailedListing.phone,
            whatsapp: detailedListing.whatsapp,
            status: detailedListing.status,
            saleStatus: detailedListing.saleStatus,
            views: detailedListing.views,
            isFeatured: detailedListing.isFeatured,
            owner: detailedListing.owner,
            createdAt: detailedListing.createdAt,
            updatedAt: detailedListing.updatedAt,
            vrPanoramaUrl: detailedListing.vrPanoramaUrl,
            vrVideoUrl: detailedListing.vrVideoUrl
        )
    }

    private var isRTL: Bool { appSettings.language == "ar" || appSettings.language == "ku" }

    private var currentMapCoordinate: CLLocationCoordinate2D? {
        if let coords = currentListing.coordinates {
            return CLLocationCoordinate2D(latitude: coords.lat, longitude: coords.lng)
        }

        return fallbackCoordinate
    }

    private var whatsappContactNumber: String? {
        if let w = currentListing.whatsapp?.trimmingCharacters(in: .whitespacesAndNewlines), !w.isEmpty { return w }
        if let p = currentListing.phone?.trimmingCharacters(in: .whitespacesAndNewlines), !p.isEmpty { return p }
        return nil
    }

    private var contactPhoneNumber: String? {
        guard let p = currentListing.phone?.trimmingCharacters(in: .whitespacesAndNewlines), !p.isEmpty else { return nil }
        return p
    }

    private var hasPhone: Bool { contactPhoneNumber != nil }
    private var hasWhatsApp: Bool { whatsappContactNumber != nil }

    private var galleryImageURLs: [URL] {
        let rawImages = currentListing.images.isEmpty ? [currentListing.primaryImage] : currentListing.images
        return rawImages
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .compactMap { raw in
                if let directURL = URL(string: raw) {
                    return directURL
                }

                let encoded = raw.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? raw
                return URL(string: encoded)
            }
    }

    private var galleryIdentityKey: String {
        galleryImageURLs.map(\.absoluteString).joined(separator: "|")
    }

    init(listing: BusinessListing) {
        self.listing = listing
        if let coordinate = ListingLocationResolver.initialCoordinate(existing: listing.coordinates, location: listing.location) {
            _region = State(initialValue: MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 33.3152, longitude: 44.3661),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                imageGallery
                mainContent
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .overlay(alignment: .top) { navOverlay }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [generateShareText(currentListing)])
        }
        .confirmationDialog(
            getLocalizedText(en: "Report or Block", ar: "الإبلاغ أو الحجب", ku: "ڕاپۆرت یان بلۆک"),
            isPresented: $showReportSheet,
            titleVisibility: .visible
        ) {
            Button(getLocalizedText(en: "Report as Spam", ar: "الإبلاغ كبريد عشوائي", ku: "ڕاپۆرت وەک سپام")) { submitReport("spam") }
            Button(getLocalizedText(en: "Report as Fake", ar: "الإبلاغ كمزيف", ku: "ڕاپۆرت وەک دروستکراو")) { submitReport("fake") }
            Button(getLocalizedText(en: "Report as Scam", ar: "الإبلاغ كاحتيال", ku: "ڕاپۆرت وەک خەپاندن")) { submitReport("scam") }
            Button(getLocalizedText(en: "Report as Inappropriate", ar: "الإبلاغ كمحتوى غير لائق", ku: "ڕاپۆرت وەک نامناسب")) { submitReport("inappropriate") }
            Divider()
            Button(getLocalizedText(en: "Block this User", ar: "حجب هذا المستخدم", ku: "ئەم بەکارهێنەرە بلۆک بکە"), role: .destructive) { showBlockConfirm = true }
            Button(getLocalizedText(en: "Cancel", ar: "إلغاء", ku: "هەڵوەشاندنەوە"), role: .cancel) {}
        }
        .alert(
            getLocalizedText(en: "Block User?", ar: "هل تريد حجب المستخدم؟", ku: "بەکارهێنەرەکە بلۆک بکەیت؟"),
            isPresented: $showBlockConfirm
        ) {
            Button(getLocalizedText(en: "Block", ar: "حجب", ku: "بلۆک"), role: .destructive) { performBlock() }
            Button(getLocalizedText(en: "Cancel", ar: "إلغاء", ku: "هەڵوەشاندنەوە"), role: .cancel) {}
        } message: {
            Text(getLocalizedText(en: "You won't see their listings anymore.", ar: "لن ترى إعلاناتهم بعد الآن.", ku: "دیگەر ئاگەهداریەکانیان نابینیت."))
        }
        .overlay(alignment: .bottom) {
            if showFeedback, let msg = actionFeedback {
                Text(msg)
                    .font(.subheadline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding(.bottom, 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onChange(of: galleryImageURLs.count) { newCount in
            if newCount == 0 {
                currentImageIndex = 0
            } else if currentImageIndex >= newCount {
                currentImageIndex = 0
            }
        }
        .onChange(of: currentImageIndex) { newIndex in
            guard galleryImageURLs.count > 1 else { return }
            guard lastTrackedImageIndex != newIndex else { return }
            lastTrackedImageIndex = newIndex

            Task {
                try? await trackEngagement(event: .imageView)
            }
        }
        .onAppear {
            guard authViewModel.isAuthenticated else { return }
            guard !hasTrackedViewStart else { return }

            hasTrackedViewStart = true
            engagementStartTime = Date()
            lastTrackedImageIndex = currentImageIndex

            Task {
                try? await trackEngagement(event: .viewStart)
            }
        }
        .onDisappear {
            guard authViewModel.isAuthenticated else { return }
            guard let start = engagementStartTime else { return }

            let seconds = max(1, Int(Date().timeIntervalSince(start)))
            Task {
                try? await trackEngagement(event: .viewEnd, durationSec: seconds)
            }

            engagementStartTime = nil
            hasTrackedViewStart = false
            lastTrackedImageIndex = nil
        }
        .task { await loadDetailedListing() }
    }

    // MARK: - Nav Overlay
    private var navOverlay: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
            Spacer()
            HStack(spacing: 10) {
                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Circle())
                }
                Button(action: { toggleFavorite() }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isFavorite ? .red : .white)
                        .frame(width: 38, height: 38)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Circle())
                }
                if authViewModel.isAuthenticated {
                    Button(action: { showReportSheet = true }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
    }

    // MARK: - Image Gallery
    private var imageGallery: some View {
        return ZStack(alignment: .bottom) {
            TabView(selection: $currentImageIndex) {
                ForEach(Array(galleryImageURLs.enumerated()), id: \.offset) { index, url in
                    CachedRemoteImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        LinearGradient(colors: [Color(hex: "#2D4A7A"), Color(hex: "#1B2E52")],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                    .frame(width: UIScreen.main.bounds.width, height: 380)
                    .clipped()
                    .tag(index)
                }
            }
            .id(galleryIdentityKey)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 380)

            // gradient fade at bottom
            LinearGradient(colors: [.clear, Color.black.opacity(0.55)],
                           startPoint: .center, endPoint: .bottom)
            .frame(height: 180)
            .allowsHitTesting(false)

            // dot indicators + counter
            if galleryImageURLs.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<galleryImageURLs.count, id: \.self) { i in
                        Circle()
                            .fill(i == currentImageIndex ? Color.white : Color.white.opacity(0.45))
                            .frame(width: i == currentImageIndex ? 8 : 5, height: i == currentImageIndex ? 8 : 5)
                            .animation(.spring(response: 0.3), value: currentImageIndex)
                    }
                }
                .padding(.bottom, 20)
                .allowsHitTesting(false)
            }

            if !galleryImageURLs.isEmpty {
                Text("\(min(currentImageIndex + 1, galleryImageURLs.count))/\(galleryImageURLs.count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Capsule())
                    .padding(.bottom, 52)
                        .allowsHitTesting(false)
            }

            // "SOLD" badge if sold
            if currentListing.isSold {
                Text("SOLD")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .padding(.bottom, 84)
                        .allowsHitTesting(false)
            }
        }
        .frame(height: 380)
    }

    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            // White card pulling up over image
            VStack(alignment: .leading, spacing: 0) {
                // Price + category row
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: isRTL ? .trailing : .leading, spacing: 6) {
                        Text(currentListing.formattedPrice)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "#0F2240"))
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B7FA3"))
                            Text(currentListing.location.capitalized)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B7FA3"))
                            Text("·")
                                .foregroundColor(Color(hex: "#C0C8D8"))
                            Image(systemName: "eye")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "#6B7FA3"))
                            Text("\(currentListing.views)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B7FA3"))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)

                    Text(getLocalizedCategoryName(currentListing.category))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "#1A4D7C"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color(hex: "#E8F2FF"))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)

                Divider().padding(.horizontal, 20)

                // Title
                Text(currentListing.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#0F2240"))
                    .lineSpacing(3)
                    .multilineTextAlignment(isRTL ? .trailing : .leading)
                    .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)

                // Description card
                VStack(alignment: isRTL ? .trailing : .leading, spacing: 10) {
                    Label {
                        Text(descriptionLabel)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "#6B7FA3"))
                    } icon: {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "#6B7FA3"))
                    }
                    .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)

                    Text(currentListing.description)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(hex: "#2C3E55"))
                        .lineSpacing(4)
                        .multilineTextAlignment(isRTL ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
                }
                .padding(18)
                .background(Color(hex: "#F6F8FC"))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                // Meta chips row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        metaChip(icon: "calendar", text: formattedDate(currentListing.createdAt))
                        metaChip(icon: "tag", text: getLocalizedCategoryName(currentListing.category))
                        if currentListing.isFeatured == true {
                            metaChip(icon: "star.fill", text: featuredLabel, accent: true)
                        }
                        if currentListing.isSold {
                            metaChip(icon: "checkmark.seal.fill", text: soldLabel, red: true)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 24)

                // Map section
                if let coordinate = currentMapCoordinate {
                    mapSection(coordinate: coordinate)
                }

                // Contact section (single visible contact action area)
                if hasPhone || hasWhatsApp {
                    contactSection
                }

                // Chat section
                if authViewModel.isAuthenticated {
                    chatSection
                }

                Spacer(minLength: 20)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(.top, -28)
        }
        .background(Color.white)
    }

    // MARK: - Map
    private func mapSection(coordinate: CLLocationCoordinate2D) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "map.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A4D7C"))
                Text(locationLabel)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "#0F2240"))
            }
            .padding(.horizontal, 20)

            if let address = currentListing.address, !address.isEmpty {
                Text(address)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#6B7FA3"))
                    .padding(.horizontal, 20)
            }

            Map(coordinateRegion: $region, annotationItems: [MapLocation(id: currentListing.id, coordinate: coordinate)]) { loc in
                MapMarker(coordinate: loc.coordinate, tint: Color(hex: "#1A4D7C"))
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(.horizontal, 20)
            .onTapGesture { openInMaps() }

            Button(action: openInMaps) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        .font(.system(size: 15))
                    Text(openInMapsLabel)
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .foregroundColor(Color(hex: "#1A4D7C"))
                .background(Color(hex: "#E8F2FF"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 28)
    }

    // MARK: - Contact section (inside scroll)
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A4D7C"))
                Text(contactLabel)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "#0F2240"))
            }

            if let phone = contactPhoneNumber {
                inlineContactRow(icon: "phone.fill", text: phone, color: Color(hex: "#1A4D7C"), bg: Color(hex: "#E8F2FF")) {
                    callPhone(number: phone)
                }
            }

            if let whatsapp = whatsappContactNumber {
                inlineContactRow(icon: "message.fill", text: whatsapp, color: Color(hex: "#1A7C4D"), bg: Color(hex: "#E8FFF2")) {
                    openWhatsApp(number: whatsapp)
                }
            }

            if let email = currentListing.owner.email {
                inlineContactRow(icon: "envelope.fill", text: email, color: Color(hex: "#6B3FA0"), bg: Color(hex: "#F3E8FF")) {
                    if let url = URL(string: "mailto:\(email)") { UIApplication.shared.open(url) }
                }
            }
        }
        .padding(20)
        .background(Color(hex: "#F6F8FC"))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    private var chatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A4D7C"))
                Text("Send a Message")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "#0F2240"))
                Spacer()
            }

            Button(action: { showChatSheet = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(Color(hex: "#1A4D7C"))
                        .clipShape(Circle())
                    Text("Message the seller")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#0F2240"))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "#1A4D7C"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Color(hex: "#F6F8FC"))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .sheet(isPresented: $showChatSheet) {
            chatSheetContent
        }
    }

    private var chatSheetContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Message \(currentListing.owner.name ?? "Seller")")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#0F2240"))
                Spacer()
                Button(action: { showChatSheet = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#C0C8D8"))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()
            
            // Messages section
            if messagesViewModel.isLoading && messagesViewModel.currentMessages.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading messages...")
                        .foregroundColor(Color(hex: "#6B7FA3"))
                }
                .frame(maxHeight: .infinity)
            } else if messagesViewModel.currentMessages.isEmpty {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Listing: \(currentListing.title)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#0F2240"))
                            Text(currentListing.formattedPrice)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "#6B7FA3"))
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(hex: "#F6F8FC"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Text("Start a conversation with the seller")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#6B7FA3"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .frame(maxHeight: .infinity, alignment: .top)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messagesViewModel.currentMessages) { message in
                                MessageBubble(
                                    message: message,
                                    isFromCurrentUser: message.senderId == authViewModel.currentUser?.id
                                )
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    }
                    .scrollIndicators(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                    .onAppear {
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: messagesViewModel.currentMessages.count) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                }
            }

            Divider()
                .padding(.vertical, 8)

            // Message input
            HStack(spacing: 12) {
                TextField("Type your message...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 14))
                    .padding(.vertical, 4)

                Button(action: { sendMessage() }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(Color(hex: "#1A4D7C"))
                        .clipShape(Circle())
                }
                .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty || isSendingMessage)
            }
            .padding(16)
        }
        .presentationDetents([.medium, .large])
        .task {
            await messagesViewModel.loadMessages(for: currentListing.owner.id)
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let lastMessage = messagesViewModel.currentMessages.last else { return }
        withAnimation {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }

    private func sendMessage() {
        let msg = messageText.trimmingCharacters(in: .whitespaces)
        guard !msg.isEmpty else { return }

        isSendingMessage = true
        Task {
            let success = await messagesViewModel.sendMessage(
                to: currentListing.owner.id,
                message: msg
            )
            
            if success {
                messageText = ""
                actionFeedback = "Message sent!"
                showFeedback = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showFeedback = false
                }
            } else {
                actionFeedback = "Failed to send message"
                showFeedback = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showFeedback = false
                }
            }
            isSendingMessage = false
        }
    }

    private func inlineContactRow(icon: String, text: String, color: Color, bg: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 38, height: 38)
                    .background(bg)
                    .clipShape(Circle())
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#2C3E55"))
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers
    private func metaChip(icon: String, text: String, accent: Bool = false, red: Bool = false) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(red ? Color(hex: "#C0392B") : accent ? Color(hex: "#B07700") : Color(hex: "#4A6080"))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(red ? Color(hex: "#FFF0EE") : accent ? Color(hex: "#FFF8E0") : Color(hex: "#F0F4FA"))
        .clipShape(Capsule())
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }

    private func toggleFavorite() {
        let prev = isFavorite
        isFavorite.toggle()
        Task {
            do {
                try await apiService.toggleFavorite(listingId: currentListing.id, isCurrentlyFavorite: prev)
            } catch {
                isFavorite = prev
            }
        }
    }

    private func openWhatsApp(number: String) {
        let clean = number.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        let msg = "Hi, I'm interested in your listing: \(currentListing.title)"
        if let url = URL(string: "https://wa.me/\(clean)?text=\(msg.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url)
        }
    }

    private func callPhone(number: String) {
        let clean = number.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        if let url = URL(string: "tel://\(clean)") { UIApplication.shared.open(url) }
    }

    private func openInMaps() {
        guard let coordinate = currentMapCoordinate else { return }
        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = currentListing.title
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    private func loadDetailedListing() async {
        do {
            if NetworkManager.shared.accessToken != nil {
                detailedListing = try await apiService.fetchMyListingDetail(id: listing.id)
            } else {
                detailedListing = try await apiService.fetchListingDetail(id: listing.id)
            }
            // Update isFavorite from API response
            if let detailed = detailedListing {
                isFavorite = detailed.isFavorite
            }
            await updateMapCoordinate()
        } catch {
            detailedListing = try? await apiService.fetchListingDetail(id: listing.id)
            // Update isFavorite even on fallback
            if let detailed = detailedListing {
                isFavorite = detailed.isFavorite
            }
            await updateMapCoordinate()
        }
    }

    private func updateMapCoordinate() async {
        let resolved = await ListingLocationResolver.resolvedCoordinate(
            existing: currentListing.coordinates,
            address: currentListing.address,
            location: currentListing.location
        )

        fallbackCoordinate = currentListing.coordinates == nil ? resolved : nil

        guard let resolved else { return }

        region = MKCoordinateRegion(
            center: resolved,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    private func generateShareText(_ l: BusinessListing) -> String {
        "Check out this on Souqira!\n\n\(l.title)\n\(l.formattedPrice)\n\(l.location.capitalized)\n\n\(l.description)"
    }

    private func trackEngagement(event: ListingEngagementEvent, durationSec: Int? = nil) async throws {
        guard authViewModel.isAuthenticated else { return }
        try await apiService.trackListingEngagement(
            listingId: currentListing.id,
            event: event,
            durationSec: durationSec
        )
    }

    // MARK: - Localized strings
    private var descriptionLabel: String {
        switch appSettings.language {
        case "ar": return "الوصف"
        case "ku": return "وەسف"
        default: return "Description"
        }
    }
    private var locationLabel: String {
        switch appSettings.language {
        case "ar": return "الموقع"
        case "ku": return "شوێن"
        default: return "Location"
        }
    }
    private var contactLabel: String {
        switch appSettings.language {
        case "ar": return "تواصل مع البائع"
        case "ku": return "پەیوەندی بکە لەگەڵ فرۆشیار"
        default: return "Contact seller"
        }
    }
    private var openInMapsLabel: String {
        switch appSettings.language {
        case "ar": return "فتح في الخرائط"
        case "ku": return "کرانەوە لە نەخشەدا"
        default: return "Open in Maps"
        }
    }
    private var callLabel: String {
        switch appSettings.language {
        case "ar": return "اتصال"
        case "ku": return "پەیوەندی"
        default: return "Call"
        }
    }
    private var featuredLabel: String {
        switch appSettings.language {
        case "ar": return "مميز"
        case "ku": return "تایبەت"
        default: return "Featured"
        }
    }
    private var soldLabel: String {
        switch appSettings.language {
        case "ar": return "مباع"
        case "ku": return "فرۆشراو"
        default: return "Sold"
        }
    }

    private func getLocalizedCategoryName(_ categoryId: String) -> String {
        Category.displayName(for: categoryId, language: appSettings.language)
    }

    private func getLocalizedText(en: String, ar: String, ku: String) -> String {
        switch appSettings.language {
        case "ar": return ar
        case "ku": return ku
        default: return en
        }
    }

    private func submitReport(_ reason: String) {
        Task {
            do {
                try await apiService.reportListing(id: currentListing.id, reason: reason)
                showFeedback(getLocalizedText(en: "Report submitted", ar: "تم الإبلاغ", ku: "ڕاپۆرت نێردرا"))
            } catch {
                showFeedback(getLocalizedText(en: "Could not submit report", ar: "تعذر الإبلاغ", ku: "ڕاپۆرت نەنێردرا"))
            }
        }
    }

    private func performBlock() {
        let ownerId = currentListing.owner.id
        guard !ownerId.isEmpty else { return }
        Task {
            do {
                try await apiService.blockUser(id: ownerId)
                showFeedback(getLocalizedText(en: "User blocked", ar: "تم حجب المستخدم", ku: "بەکارهێنەر بلۆک کرا"))
            } catch {
                showFeedback(getLocalizedText(en: "Could not block user", ar: "تعذر حجب المستخدم", ku: "بلۆک کردن سەرنەخست"))
            }
        }
    }

    private func showFeedback(_ message: String) {
        actionFeedback = message
        withAnimation { showFeedback = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showFeedback = false }
        }
    }
}

struct ContactSellerView: View {
    let listing: BusinessListing
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showMessageComposer = false

    private var whatsappNumber: String? {
        if let whatsapp = listing.whatsapp?.trimmingCharacters(in: .whitespacesAndNewlines), !whatsapp.isEmpty {
            return whatsapp
        }
        if let phone = listing.phone?.trimmingCharacters(in: .whitespacesAndNewlines), !phone.isEmpty {
            return phone
        }
        return nil
    }
    
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
                if let whatsapp = whatsappNumber {
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
                    Text(LocalizationManager.noContactInformation.get(language: appSettings.language))
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
