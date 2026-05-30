// ManounouApp.swift — Manounou
// Entry point: handles onboarding on first launch, then the main tab view.

import SwiftUI
import Supabase

@main
struct ManounouApp: App {
    @StateObject private var appContainer = AppContainer.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appContainer)
                .environmentObject(appContainer.authViewModel)
                .task { await appContainer.initialize() }
        }
    }
}

// MARK: - RootView (routing)

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appContainer: AppContainer
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if authViewModel.isLoading {
                SplashView()
            } else if authViewModel.isAuthenticated {
                if hasCompletedOnboarding {
                    ModernMainTabView()
                        .environmentObject(appContainer)
                        .transition(.opacity)
                } else {
                    OnboardingView {
                        withAnimation(AppTheme.Animation.standard) {
                            hasCompletedOnboarding = true
                        }
                    }
                    .transition(.opacity)
                }
            } else if authViewModel.isSignUpMode {
                // Inscription / création de foyer (formulaire complet)
                AuthenticationView()
                    .environmentObject(authViewModel)
                    .transition(.opacity)
            } else {
                // Reconnexion (handoff « Connexion - Déconnecté ») : compte mémorisé + Face ID
                ReconnectionView()
                    .environmentObject(authViewModel)
                    .transition(.opacity)
            }
        }
        .animation(AppTheme.Animation.standard, value: authViewModel.isAuthenticated)
        .animation(AppTheme.Animation.standard, value: authViewModel.isSignUpMode)
        .animation(AppTheme.Animation.standard, value: hasCompletedOnboarding)
    }
}

// MARK: - ContentView (kept as alias for backward compat)
typealias ContentView = RootView

// MARK: - Splash / Loading view

struct SplashView: View {
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            AppTheme.Colors.paper.ignoresSafeArea()

            VStack(spacing: 20) {
                // Logo mark
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.Colors.brand, Color(hex: "D4305A")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 88, height: 88)
                        .shadow(color: AppTheme.Colors.brandShadow, radius: 20, x: 0, y: 8)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)

                VStack(spacing: 4) {
                    Text("Manounou")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.Colors.ink)

                    Text("La garde simplifiée")
                        .font(AppTheme.Typography.footnote)
                        .foregroundColor(AppTheme.Colors.muted)
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(AppTheme.Animation.spring) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - LoadingView (legacy alias)
typealias LoadingView = SplashView
