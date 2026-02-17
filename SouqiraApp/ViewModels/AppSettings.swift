//
//  AppSettings.swift
//  Souqira
//
//  Created on 17/02/2026
//

import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    @AppStorage("appLanguage") var language: String = ""
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    init() {
        // Auto-detect device language on first launch
        if language.isEmpty {
            language = detectDeviceLanguage()
        }
    }
    
    var isRTL: Bool {
        return language == "ar" || language == "ku"
    }
    
    func setLanguage(_ lang: String) {
        language = lang
    }
    
    private func detectDeviceLanguage() -> String {
        let deviceLanguage = Locale.preferredLanguages.first ?? "en"
        
        // Check for Kurdish variants
        if deviceLanguage.starts(with: "ku") || deviceLanguage.starts(with: "ckb") {
            return "ku" // Kurdish (Sorani)
        }
        // Check for Arabic
        else if deviceLanguage.starts(with: "ar") {
            return "ar"
        }
        // Default to English
        else {
            return "en"
        }
    }
}
