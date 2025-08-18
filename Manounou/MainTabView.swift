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
    @StateObject private var childrenViewModel = TempChildrenViewModel()
    @StateObject private var eventsViewModel = TempEventsViewModel()
    @StateObject private var documentsViewModel = TempDocumentsViewModel()
    
    @State private var selectedTab = 0
    @State private var sampleChildren: [TempChild] = []
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            TempHomeView()
                .environmentObject(childrenViewModel)
                .environmentObject(eventsViewModel)
                .environmentObject(documentsViewModel)
                .environmentObject(authManager)
                .environmentObject(notificationManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }
                .tag(0)
            
            // Children Tab
            ChildrenTabView(children: sampleChildren)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Enfants")
                }
                .tag(1)
            
            // Calendar Tab
            CalendarTabView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendrier")
                }
                .tag(2)
            
            // Documents Tab
            DocumentsTabView()
                .tabItem {
                    Image(systemName: "doc.fill")
                    Text("Documents")
                }
                .tag(3)
            
            // Settings Tab
            SettingsTabView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Paramètres")
                }
                .tag(4)
        }
        .environmentObject(authManager)
        .environmentObject(notificationManager)
        .environmentObject(childrenViewModel)
        .environmentObject(eventsViewModel)
        .environmentObject(documentsViewModel)
        .onAppear {
            loadSampleData()
            Task {
                await loadViewModelData()
            }
        }
    }
    
    private func loadSampleData() {
        sampleChildren = [
            TempChild(
                firstName: "Emma",
                lastName: "Dupont",
                birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
                gender: .female,
                notes: "Aime les livres et les puzzles"
            ),
            TempChild(
                firstName: "Lucas",
                lastName: "Martin",
                birthDate: Calendar.current.date(byAdding: .month, value: -18, to: Date()) ?? Date(),
                gender: .male,
                notes: "Très actif et curieux"
            ),
            TempChild(
                firstName: "Léa",
                lastName: "Bernard",
                birthDate: Calendar.current.date(byAdding: .month, value: -8, to: Date()) ?? Date(),
                gender: .female,
                notes: "Bébé très calme"
            )
        ]
    }
    
    private func loadViewModelData() async {
        await childrenViewModel.loadChildren()
        await eventsViewModel.loadEvents()
        await documentsViewModel.loadDocuments()
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
