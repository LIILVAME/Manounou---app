//
//  ManounouApp.swift
//  Manounou
//
//  Created by Assistant on 2025-01-13.
//

import SwiftUI
import Supabase

@main
struct ManounouApp: App {
    @StateObject private var appContainer = AppContainer.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appContainer)
                .task {
                    await appContainer.initialize()
                }
        }
    }
}

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var appContainer: AppContainer
    
    var body: some View {
        Group {
            if appContainer.authViewModel.isLoading {
                LoadingView()
            } else if appContainer.authViewModel.isAuthenticated {
                ModernMainTabView()
                    .environmentObject(appContainer)
            } else {
                AuthenticationView()
                    .environmentObject(appContainer.authViewModel)
            }
        }
    }
}

// MARK: - LoadingView
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            LogoView(size: .large, style: .full)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
            
            ProgressView()
                .scaleEffect(1.2)
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    ContentView()
        .environmentObject(AppContainer.shared)
}