//
//  LocalizationManager.swift
//  Souqira
//
//  Created on 17/02/2026
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var language: String = "en"
    
    init() {
        // Detect system language
        if let languageCode = Locale.current.language.languageCode?.identifier {
            if languageCode.starts(with: "ar") {
                language = "ar"
            } else if languageCode.starts(with: "ku") || languageCode.starts(with: "ckb") {
                language = "ku"
            }
        }
    }
    
    func localize(key: String) -> String {
        // Map keys to LocalizedString instances
        let mapping: [String: LocalizedString] = [
            "messages": LocalizationManager.messages,
            "no_messages": LocalizationManager.noMessages,
            "no_messages_desc": LocalizationManager.noMessagesDesc,
            "type_message": LocalizationManager.typeMessage,
            "home": LocalizationManager.home,
            "favorites": LocalizationManager.favorites,
            "cities": LocalizationManager.cities,
            "profile": LocalizationManager.profile
        ]
        
        return mapping[key]?.get(language: language) ?? key
    }
    
    // MARK: - Localized Strings
    
    // Main navigation
    static let home = LocalizedString(
        en: "Home",
        ar: "الرئيسية",
        ku: "سەرەکی"
    )
    
    static let favorites = LocalizedString(
        en: "Favorites",
        ar: "المفضلة",
        ku: "دڵخوازەکان"
    )
    
    static let profile = LocalizedString(
        en: "Profile",
        ar: "الملف الشخصي",
        ku: "پرۆفایل"
    )
    
    static let cities = LocalizedString(
        en: "Cities",
        ar: "المدن",
        ku: "شارەکان"
    )
    
    static let messages = LocalizedString(
        en: "Messages",
        ar: "الرسائل",
        ku: "نامەکان"
    )
    
    // Home Screen
    static let heroTitle = LocalizedString(
        en: "Find or Sell a Business with Ease and Confidence",
        ar: "ابحث عن أو بع مشروعًا تجاريًا بسهولة وثقة",
        ku: "بە ئاسانی و متمانەوە بزنسێک بدۆزەرەوە یان بیفرۆشە"
    )
    
    static let heroSubtitle = LocalizedString(
        en: "Souqira connects buyers and sellers in Iraq on a secure platform",
        ar: "يربط سوقيرة المشترين والبائعين في العراق على منصة آمنة",
        ku: "سووقێرە کڕیار و فرۆشیاران لە عێراق لەسەر پلاتفۆرمێکی پارێزراو پێکەوە دەبەستێتەوە"
    )
    
    static let createAd = LocalizedString(
        en: "Create Ad",
        ar: "إنشاء إعلان",
        ku: "دروستکردنی ڕیکلام"
    )
    
    static let searchBusinesses = LocalizedString(
        en: "Search businesses...",
        ar: "البحث عن الشركات...",
        ku: "گەڕان بۆ بزنس..."
    )
    
    static let filters = LocalizedString(
        en: "Filters",
        ar: "التصفية",
        ku: "فلتەرەکان"
    )
    
    static let allBusinessListings = LocalizedString(
        en: "All Business Listings",
        ar: "جميع قوائم الأعمال",
        ku: "هەموو لیستی بزنسەکان"
    )
    
    static let discoverOpportunities = LocalizedString(
        en: "Discover the newest business opportunities available",
        ar: "اكتشف أحدث الفرص التجارية المتاحة",
        ku: "دۆزینەوەی نوێترین دەرفەتە بازرگانییەکان"
    )
    
    // Listing Details
    static let sold = LocalizedString(
        en: "SOLD",
        ar: "مباع",
        ku: "فرۆشراوە"
    )
    
    static let views = LocalizedString(
        en: "views",
        ar: "مشاهدة",
        ku: "بینین"
    )
    
    static let description = LocalizedString(
        en: "Description",
        ar: "الوصف",
        ku: "وەسف"
    )
    
    static let category = LocalizedString(
        en: "Category",
        ar: "الفئة",
        ku: "جۆر"
    )
    
    static let posted = LocalizedString(
        en: "Posted",
        ar: "تاريخ النشر",
        ku: "بڵاوکرایەوە"
    )
    
    static let contactSeller = LocalizedString(
        en: "Contact Seller",
        ar: "اتصل بالبائع",
        ku: "پەیوەندی بە فرۆشیار"
    )
    
    // Contact Options
    static let call = LocalizedString(
        en: "Call",
        ar: "اتصال",
        ku: "پەیوەندی"
    )
    
    static let whatsapp = LocalizedString(
        en: "WhatsApp",
        ar: "واتساب",
        ku: "واتساپ"
    )
    
    static let email = LocalizedString(
        en: "Email",
        ar: "البريد الإلكتروني",
        ku: "ئیمەیڵ"
    )
    
    static let close = LocalizedString(
        en: "Close",
        ar: "إغلاق",
        ku: "داخستن"
    )
    
    // Profile
    static let myListings = LocalizedString(
        en: "My Listings",
        ar: "قوائمي",
        ku: "لیستەکانم"
    )
    
    static let myAds = LocalizedString(
        en: "My Ads",
        ar: "إعلاناتي",
        ku: "ڕیکلامەکانم"
    )
    
    static let settings = LocalizedString(
        en: "Settings",
        ar: "الإعدادات",
        ku: "ڕێکخستنەکان"
    )
    
    static let language = LocalizedString(
        en: "Language",
        ar: "اللغة",
        ku: "زمان"
    )
    
    static let darkMode = LocalizedString(
        en: "Dark Mode",
        ar: "الوضع الداكن",
        ku: "دۆخی تاریک"
    )
    
    static let logout = LocalizedString(
        en: "Log Out",
        ar: "تسجيل الخروج",
        ku: "چوونەدەرەوە"
    )
    
    // Empty States
    static let noListingsFound = LocalizedString(
        en: "No listings found",
        ar: "لم يتم العثور على قوائم",
        ku: "هیچ لیستێک نەدۆزرایەوە"
    )
    
    static let adjustFilters = LocalizedString(
        en: "Try adjusting your filters",
        ar: "حاول تعديل الفلاتر الخاصة بك",
        ku: "هەوڵبدە فلتەرەکانت بگۆڕیت"
    )
    
    static let noFavoritesYet = LocalizedString(
        en: "No Favorites Yet",
        ar: "لا توجد مفضلات بعد",
        ku: "هێشتا هیچ دڵخوازێک نییە"
    )
    
    static let startAddingFavorites = LocalizedString(
        en: "Start adding listings to your favorites",
        ar: "ابدأ بإضافة القوائم إلى مفضلاتك",
        ku: "دەست پێبکە بە زیادکردنی لیست بۆ دڵخوازەکانت"
    )
    
    static let noListingsYet = LocalizedString(
        en: "No Listings Yet",
        ar: "لا توجد قوائم بعد",
        ku: "هێشتا هیچ لیستێک نییە"
    )
    
    static let createFirstListing = LocalizedString(
        en: "Create your first listing to get started",
        ar: "قم بإنشاء أول قائمة للبدء",
        ku: "یەکەم لیستەکەت دروست بکە بۆ دەستپێکردن"
    )
    
    // Common Actions
    static let retry = LocalizedString(
        en: "Retry",
        ar: "إعادة المحاولة",
        ku: "هەوڵبدەرەوە"
    )
    
    static let cancel = LocalizedString(
        en: "Cancel",
        ar: "إلغاء",
        ku: "هەڵوەشاندنەوە"
    )
    
    static let done = LocalizedString(
        en: "Done",
        ar: "تم",
        ku: "تەواو"
    )
    
    static let save = LocalizedString(
        en: "Save",
        ar: "حفظ",
        ku: "پاشەکەوتکردن"
    )
    
    // Language Names
    static let english = LocalizedString(
        en: "English",
        ar: "English",
        ku: "English"
    )
    
    static let arabic = LocalizedString(
        en: "العربية",
        ar: "العربية",
        ku: "عەرەبی"
    )
    
    static let kurdish = LocalizedString(
        en: "کوردی",
        ar: "کوردی",
        ku: "کوردی"
    )
    
    static let selectLanguage = LocalizedString(
        en: "Select Language",
        ar: "اختر اللغة",
        ku: "زمان هەڵبژێرە"
    )
    
    // Errors
    static let failedToLoad = LocalizedString(
        en: "Failed to load listings",
        ar: "فشل تحميل القوائم",
        ku: "شکستی هێنا لە بارکردنی لیستەکان"
    )
    
    static let failedToLoadDetails = LocalizedString(
        en: "Failed to load listing details",
        ar: "فشل تحميل تفاصيل القائمة",
        ku: "شکستی هێنا لە بارکردنی وردەکاری"
    )
    
    static let failedToLoadFavorites = LocalizedString(
        en: "Failed to load favorites",
        ar: "فشل تحميل المفضلات",
        ku: "شکستی هێنا لە بارکردنی دڵخوازەکان"
    )
    
    // Messages & Chat
    static let noMessages = LocalizedString(
        en: "No Messages Yet",
        ar: "لا توجد رسائل بعد",
        ku: "هێشتا هیچ نامەیەک نییە"
    )
    
    static let noMessagesDesc = LocalizedString(
        en: "Start a conversation by contacting a seller",
        ar: "ابدأ محادثة عن طريق الاتصال بالبائع",
        ku: "گفتوگۆیەک دەست پێبکە بە پەیوەندیکردن بە فرۆشیار"
    )
    
    static let typeMessage = LocalizedString(
        en: "Type a message...",
        ar: "اكتب رسالة...",
        ku: "نامەیەک بنووسە..."
    )
}

// MARK: - LocalizedString Helper
struct LocalizedString {
    let en: String
    let ar: String
    let ku: String
    
    func get(language: String) -> String {
        switch language {
        case "ar":
            return ar
        case "ku":
            return ku
        default:
            return en
        }
    }
}
