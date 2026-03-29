//
//  Category.swift
//  Souqira
//
//  Created on 17/02/2026
//

import Foundation

struct Category: Codable, Identifiable, Hashable {
    let id: String
    let nameEn: String
    let nameAr: String
    let nameKu: String
    let icon: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameEn
        case nameAr
        case nameKu
        case icon
    }
    
    func localizedName(language: String) -> String {
        switch language {
        case "ar":
            return nameAr
        case "ku":
            return nameKu
        default:
            return nameEn
        }
    }

    static func displayName(for id: String, language: String) -> String {
        let normalizedId = id
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")

        let names: (en: String, ar: String, ku: String)

        switch normalizedId {
        case "restaurants_cafes":
            names = ("Restaurants & Cafes", "مطاعم ومقاهي", "چێشتخانە و چایخانە")
        case "retail_stores":
            names = ("Retail Stores", "متاجر التجزئة", "فرۆشگاکانی بازاڕ")
        case "auto_services":
            names = ("Auto Services", "خدمات السيارات", "خزمەتگوزاری ئۆتۆمبێل")
        case "beauty_salons":
            names = ("Beauty Salons", "صالونات التجميل", "سالۆنی جوانکاری")
        case "ecommerce_online_business":
            names = ("E-Commerce & Online", "التجارة الإلكترونية", "بازرگانی ئۆنلاین")
        case "it_tech":
            names = ("IT & Technology", "تقنية المعلومات والتكنولوجيا", "ئای تی و تەکنەلۆژیا")
        case "medical_health_services":
            names = ("Medical & Health", "الخدمات الطبية والصحية", "خزمەتگوزاری تەندروستی")
        case "education_training":
            names = ("Education & Training", "التعليم والتدريب", "فێرکاری و راهێنان")
        case "real_estate_construction":
            names = ("Real Estate & Construction", "العقارات والبناء", "ئیملاک و بیناسازی")
        case "transport_logistics":
            names = ("Transport & Logistics", "النقل والخدمات اللوجستية", "گواستنەوە و لۆجستیک")
        case "manufacturing_industry":
            names = ("Manufacturing & Industry", "التصنيع والصناعة", "بەرهەمهێنان و پیشەسازی")
        case "agriculture_food_production":
            names = ("Agriculture & Food", "الزراعة وإنتاج الغذاء", "کشتوکاڵ و بەرهەمهێنانی خۆراک")
        case "financial_accounting_services":
            names = ("Financial & Accounting", "الخدمات المالية والمحاسبية", "خزمەتگوزاری دارایی و ژمێریاری")
        case "marketing_advertising":
            names = ("Marketing & Advertising", "التسويق والإعلان", "مارکێتینگ و ڕیکلام")
        case "tourism_travel":
            names = ("Tourism & Travel", "السياحة والسفر", "گەشتیاری و گەشت")
        case "freelance_services":
            names = ("Freelance Services", "خدمات العمل الحر", "خزمەتگوزاری سەربەخۆ")
        case "home_based_businesses":
            names = ("Home Based Business", "أعمال منزلية", "کاروباری ماڵەوە")
        case "cleaning_maintenance":
            names = ("Cleaning & Maintenance", "التنظيف والصيانة", "پاککردنەوە و چاکسازی")
        case "wholesale_distribution":
            names = ("Wholesale & Distribution", "الجملة والتوزيع", "فرۆشی کۆمەڵ و دابەشکردن")
        case "other":
            names = ("Other", "أخرى", "هی تر")
        case "find_a_partner":
            names = ("Find a Partner", "ابحث عن شريك", "دۆزینەوەی هاوبەش")
        case "find_an_investor":
            names = ("Find an Investor", "ابحث عن مستثمر", "دۆزینەوەی وەبەرهێنەر")
        default:
            let fallback = normalizedId.replacingOccurrences(of: "_", with: " ").capitalized
            return fallback
        }

        switch language {
        case "ar":
            return names.ar
        case "ku":
            return names.ku
        default:
            return names.en
        }
    }
}

struct Region: Codable, Identifiable, Hashable {
    let id: String
    let nameEn: String
    let nameAr: String
    let nameKu: String
    let emoji: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameEn
        case nameAr
        case nameKu
        case emoji
    }
    
    func localizedName(language: String) -> String {
        switch language {
        case "ar":
            return nameAr
        case "ku":
            return nameKu
        default:
            return nameEn
        }
    }
}
