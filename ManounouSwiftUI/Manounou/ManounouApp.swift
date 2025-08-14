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
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .task {
                    await authManager.initialize()
                }
        }
    }
}

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isLoading {
                LoadingView()
            } else if authManager.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
    }
}

// MARK: - LoadingView avec design Manounou
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: ManounouSpacing.lg) {
            ManounouLogo(size: 80)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
            
            Text("Manounou")
                .font(ManounouTypography.bold(ManounouTypography.hero))
                .foregroundColor(ManounouColors.textPrimary)
            
            Text("Simplifiez la garde")
                .font(ManounouTypography.medium(ManounouTypography.lg))
                .foregroundColor(ManounouColors.primary)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: ManounouColors.primary))
                .scaleEffect(1.2)
                .padding(.top, ManounouSpacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ManounouColors.background)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}