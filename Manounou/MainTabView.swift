//
//  MainTabView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//  Refactorisé pour une architecture modulaire et optimisée
//  Simplifié avec extraction des composants (Phase 2 BIS)
//

import SwiftUI
import Foundation
import Supabase
import UserNotifications

// MARK: - Main Tab View
struct MainTabView: View {
    @StateObject private var authManager = AuthManager()
    @StateObject private var notificationManager = NotificationManager()
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            SimpleHomeView()
                .environmentObject(authManager)
                .environmentObject(notificationManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }
                .tag(0)
            
            // Children Tab
            SimpleChildrenView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Enfants")
                }
                .tag(1)
            
            // Calendar Tab
            SimpleCalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendrier")
                }
                .tag(2)
            
            // Documents Tab
            SimpleDocumentsView()
                .tabItem {
                    Image(systemName: "doc.fill")
                    Text("Documents")
                }
                .tag(3)
            
            // Settings Tab
            SimpleSettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Paramètres")
                }
                .tag(4)
        }
        .environmentObject(authManager)
        .environmentObject(notificationManager)
    }
    
}

// MARK: - Simple Tab Views

struct SimpleHomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "house.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Accueil")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Dashboard familial simplifié")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("✅ Architecture modulaire implémentée")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
            }
            .padding()
            .navigationTitle("Accueil")
        }
    }
}

struct SimpleChildrenView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Enfants")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Gestion des profils enfants")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Enfants")
        }
    }
}

struct SimpleCalendarView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "calendar")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Calendrier")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Planification des événements")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Calendrier")
        }
    }
}

struct SimpleDocumentsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                Text("Documents")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Gestion des fichiers")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Documents")
        }
    }
}

struct SimpleSettingsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Paramètres")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Configuration utilisateur")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Paramètres")
        }
    }
}

// MARK: - Notification Manager
 
 // MARK: - Notification Manager
class NotificationManager: ObservableObject {
    @Published var hasNotifications = false
    
    init() {
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.hasNotifications = granted
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
#endif
