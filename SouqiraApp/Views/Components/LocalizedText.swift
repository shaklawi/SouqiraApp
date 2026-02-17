//
//  LocalizedText.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

// MARK: - Localized Text View
struct LocalizedText: View {
    let localizedString: LocalizedString
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        Text(localizedString.get(language: appSettings.language))
    }
}
