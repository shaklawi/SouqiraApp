//
//  ContentView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        MainTabView()
            .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(AppSettings())
}
