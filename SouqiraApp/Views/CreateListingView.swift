//
//  CreateListingView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI
import PhotosUI
import UIKit

extension Notification.Name {
    static let listingCreated = Notification.Name("listingCreated")
    static let listingDeleted = Notification.Name("listingDeleted")
}

struct CreateListingView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    @State private var selectedCurrency = "USD"
    @State private var selectedCategory: Category?
    @State private var selectedRegion: Region?
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var imageData: [Data] = []
    @State private var showCameraSheet = false
    @State private var showCameraUnavailableAlert = false
    @State private var showImageLimitAlert = false
    @State private var phone = ""
    @State private var whatsapp = ""
    @State private var email = ""
    
    @State private var categories: [Category] = []
    @State private var regions: [Region] = []
    @State private var isLoadingCategories = false
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var errorMessage: String?
    
    private let apiService = APIService()
    let currencies = ["USD", "IQD"]
    
    var isFormValid: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        !price.isEmpty &&
        selectedCategory != nil &&
        selectedRegion != nil &&
        !phone.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                SouqiraPatternBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        photosCard
                        businessDetailsCard
                        categoryLocationCard
                        contactCard
                        submitCard
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(localize(en: "Create Listing", ar: "إنشاء إعلان", ku: "دروستکردنی ڕیکلام"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localize(en: "Cancel", ar: "إلغاء", ku: "هەڵوەشاندنەوە")) {
                        dismiss()
                    }
                }
            }
            .alert(localize(en: "Success", ar: "نجاح", ku: "سەرکەوتوو"), isPresented: $showSuccessAlert) {
                Button(localize(en: "OK", ar: "حسنًا", ku: "باشە")) {
                    dismiss()
                }
            } message: {
                Text(localize(en: "Your listing has been created successfully!", ar: "تم إنشاء إعلانك بنجاح!", ku: "ڕیکلامەکەت بە سەرکەوتوویی دروستکرا!"))
            }
            .onChange(of: selectedImages) { newItems in
                Task {
                    for item in newItems {
                        guard imageData.count < 5 else {
                            showImageLimitAlert = true
                            break
                        }
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            imageData.append(data)
                        }
                    }
                    selectedImages = []
                }
            }
            .sheet(isPresented: $showCameraSheet) {
                CameraImagePicker(sourceType: .camera) { capturedImage in
                    addCapturedImage(capturedImage)
                }
                .ignoresSafeArea()
            }
            .alert(localize(en: "Camera Not Available", ar: "الكاميرا غير متاحة", ku: "کامێرا بەردەست نییە"), isPresented: $showCameraUnavailableAlert) {
                Button(localize(en: "OK", ar: "حسنًا", ku: "باشە"), role: .cancel) { }
            } message: {
                Text(localize(en: "This device does not have a camera.", ar: "هذا الجهاز لا يحتوي على كاميرا.", ku: "ئەم ئامێرە کامێرای تێدا نییە."))
            }
            .alert(localize(en: "Maximum Photos", ar: "الحد الأقصى للصور", ku: "زۆرترین وێنە"), isPresented: $showImageLimitAlert) {
                Button(localize(en: "OK", ar: "حسنًا", ku: "باشە"), role: .cancel) { }
            } message: {
                Text(localize(en: "You can add up to 5 photos only.", ar: "يمكنك إضافة 5 صور فقط.", ku: "تەنیا دەتوانیت 5 وێنە زیاد بکەیت."))
            }
            .task {
                await loadCategoriesAndRegions()
            }
        }
    }

    private var photosCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(localize(en: "Photos", ar: "الصور", ku: "وێنەکان"))

            HStack(spacing: 10) {
                Button(action: openCamera) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                        Text(localize(en: "Take Photo", ar: "التقاط صورة", ku: "وێنە بگرە"))
                        Spacer()
                    }
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(DesignSystem.Colors.gray200, lineWidth: 1)
                    )
                    .cornerRadius(12)
                }

                PhotosPicker(selection: $selectedImages, maxSelectionCount: max(0, 5 - imageData.count), matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text(localize(en: "Gallery", ar: "المعرض", ku: "گەلێری"))
                        Spacer()
                    }
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(DesignSystem.Colors.gray200, style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                    .cornerRadius(12)
                }
            }

            HStack(spacing: 10) {
                Image(systemName: "photo.stack")
                    .foregroundColor(DesignSystem.Colors.primary)
                Text(localize(en: "Add up to 5 photos", ar: "إضافة حتى 5 صور", ku: "زیادکردنی تا 5 وێنە"))
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.gray700)
                Spacer()
                Text("\(imageData.count)/5")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.gray600)
            }

            if !imageData.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(imageData.indices, id: \.self) { index in
                            if let uiImage = UIImage(data: imageData[index]) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 106, height: 106)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(DesignSystem.Colors.gray200, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var businessDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(localize(en: "Business Details", ar: "تفاصيل النشاط", ku: "وردەکارییەکانی کار"))

            labeledTextField(
                title: localize(en: "Title", ar: "عنوان الإعلان", ku: "ناونیشان"),
                helper: localize(
                    en: "Write the business/listing name, not the detailed address.",
                    ar: "اكتب اسم النشاط أو اسمًا واضحًا للإعلان، وليس العنوان التفصيلي للموقع.",
                    ku: "ناوی بزنس/ڕیکلام بنووسە، نەک ناونیشانی وردی شوێن."
                ),
                text: $title
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(localize(en: "Description", ar: "الوصف", ku: "وەسف"))
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.gray600)

                TextEditor(text: $description)
                    .frame(minHeight: 120)
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

                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var categoryLocationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(localize(en: "Category & Location", ar: "الفئة والموقع", ku: "جۆر و شوێن"))

            if isLoadingCategories {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
            } else {
                Menu {
                    Button(localize(en: "Select Category", ar: "اختر الفئة", ku: "جۆر هەڵبژێرە")) {
                        selectedCategory = nil
                    }
                    ForEach(categories) { category in
                        Button(categoryDisplayName(category)) {
                            selectedCategory = category
                        }
                    }
                } label: {
                    selectionRow(
                        title: localize(en: "Category", ar: "الفئة", ku: "جۆر"),
                        value: selectedCategory.map(categoryDisplayName) ?? localize(en: "Select Category", ar: "اختر الفئة", ku: "جۆر هەڵبژێرە")
                    )
                }

                Menu {
                    Button(localize(en: "Select Region", ar: "اختر المنطقة", ku: "ناوچە هەڵبژێرە")) {
                        selectedRegion = nil
                    }
                    ForEach(regions) { region in
                        Button("\(region.emoji) \(regionDisplayName(region))") {
                            selectedRegion = region
                        }
                    }
                } label: {
                    selectionRow(
                        title: localize(en: "Region", ar: "المنطقة", ku: "ناوچە"),
                        value: selectedRegion.map { "\($0.emoji) \(regionDisplayName($0))" } ?? localize(en: "Select Region", ar: "اختر المنطقة", ku: "ناوچە هەڵبژێرە")
                    )
                }
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var contactCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(localize(en: "Contact Information", ar: "معلومات التواصل", ku: "زانیاری پەیوەندی"))

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

            labeledTextField(
                title: localize(en: "Email (optional)", ar: "البريد الإلكتروني (اختياري)", ku: "ئیمەیڵ (ئارەزوومەندانە)"),
                text: $email,
                keyboardType: .emailAddress
            )
            .textInputAutocapitalization(.never)
        }
        .padding(16)
        .background(cardBackground)
    }

    private var submitCard: some View {
        VStack(spacing: 10) {
            Button(action: submitListing) {
                HStack(spacing: 10) {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.subheadline)
                    }
                    Text(localize(en: "Create Listing", ar: "إنشاء إعلان", ku: "دروستکردنی ڕیکلام"))
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isFormValid && !isSubmitting ? AnyShapeStyle(DesignSystem.Colors.primaryGradient) : AnyShapeStyle(DesignSystem.Colors.gray400))
                )
            }
            .disabled(!isFormValid || isSubmitting)

            if let error = errorMessage {
                Text(error)
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

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(DesignSystem.Colors.gray800)
    }

    private func labeledTextField(
        title: String,
        helper: String? = nil,
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

            if let helper, !helper.isEmpty {
                Text(helper)
                    .font(.caption2)
                    .foregroundColor(DesignSystem.Colors.gray500)
            }
        }
    }

    private func selectionRow(title: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.gray600)
                Text(value)
                    .foregroundColor(DesignSystem.Colors.gray900)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.down")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.gray500)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.95))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DesignSystem.Colors.gray200, lineWidth: 1)
        )
        .cornerRadius(12)
    }

    private func categoryDisplayName(_ category: Category) -> String {
        switch appSettings.language {
        case "ar":
            return category.nameAr
        case "ku":
            return category.nameKu
        default:
            return category.nameEn
        }
    }

    private func regionDisplayName(_ region: Region) -> String {
        switch appSettings.language {
        case "ar":
            return region.nameAr
        case "ku":
            return region.nameKu
        default:
            return region.nameEn
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
    
    private func loadCategoriesAndRegions() async {
        isLoadingCategories = true
        do {
            categories = try await apiService.fetchCategories()
            regions = try await apiService.fetchRegions()
        } catch {
            print("Failed to load data: \(error)")
        }
        isLoadingCategories = false
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showCameraUnavailableAlert = true
            return
        }
        showCameraSheet = true
    }

    private func addCapturedImage(_ image: UIImage) {
        guard imageData.count < 5 else {
            showImageLimitAlert = true
            return
        }

        if let data = image.jpegData(compressionQuality: 0.85) {
            imageData.append(data)
        }
    }
    
    private func submitListing() {
        guard isFormValid else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        Task {
            do {
                let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                let cleanedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
                let cleanedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
                let cleanedWhatsApp = whatsapp.trimmingCharacters(in: .whitespacesAndNewlines)
                let resolvedCoordinates = await ListingLocationResolver.requestCoordinatesJSONString(
                    existing: nil,
                    address: nil,
                    location: selectedRegion?.id ?? ""
                )
                
                let request = CreateListingRequest(
                    title: cleanedTitle,
                    description: cleanedDescription,
                    price: Double(price) ?? 0,
                    currency: selectedCurrency.lowercased(),
                    location: selectedRegion?.id ?? "",
                    category: selectedCategory?.id ?? "",
                    phone: cleanedPhone,
                    whatsapp: cleanedWhatsApp.isEmpty ? cleanedPhone : cleanedWhatsApp,
                    address: nil,
                    coordinates: resolvedCoordinates,
                    status: nil,
                    saleStatus: nil
                )
                
                _ = try await apiService.createListing(request, images: imageData)
                NotificationCenter.default.post(name: .listingCreated, object: nil)
                showSuccessAlert = true
            } catch let error as NetworkError {
                switch error {
                case .serverError(let message):
                    errorMessage = message
                default:
                    errorMessage = "Failed to create listing. Please try again."
                }
                print("❌ Create listing error: \(error)")
            } catch {
                errorMessage = "Failed to create listing. Please try again."
                print("❌ Create listing error: \(error)")
            }
            
            isSubmitting = false
        }
    }
}

struct CameraImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImageCaptured: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraImagePicker

        init(_ parent: CameraImagePicker) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            parent.dismiss()
        }
    }
}

#Preview {
    CreateListingView()
        .environmentObject(AuthenticationViewModel())
    .environmentObject(AppSettings())
}
