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
