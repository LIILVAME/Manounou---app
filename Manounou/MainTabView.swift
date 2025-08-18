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
    @StateObject private var appContainer = AppContainer.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .environmentObject(appContainer.authViewModel)
                .environmentObject(appContainer.notificationManager)
                .environmentObject(appContainer.childrenViewModel)
                .environmentObject(appContainer.eventsViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }
                .tag(0)
            
            // Children Tab
            ChildrenListView()
                .environmentObject(appContainer.childrenViewModel)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Enfants")
                }
                .tag(1)
            
            // Calendar Tab
            CalendarView()
                .environmentObject(appContainer.eventsViewModel)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendrier")
                }
                .tag(2)
            
            // Documents Tab
            DocumentsView()
                .environmentObject(appContainer.documentsViewModel)
                .tabItem {
                    Image(systemName: "doc.fill")
                    Text("Documents")
                }
                .tag(3)
            
            // Settings Tab
            ProfileView()
                .environmentObject(appContainer.authViewModel)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Paramètres")
                }
                .tag(4)
        }
        .environmentObject(appContainer)
        .onAppear {
            Task {
                await appContainer.initialize()
            }
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
