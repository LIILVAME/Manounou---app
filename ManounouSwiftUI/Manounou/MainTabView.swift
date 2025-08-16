//
//  MainTabView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//  Refactorisé pour une architecture modulaire et optimisée
//

import SwiftUI
import Foundation
import Supabase
import UserNotifications

// Imports temporaires pour les nouveaux composants
// TODO: Ajouter les fichiers au projet Xcode
typealias EventsViewModel = TemporaryEventsViewModel
typealias CacheService = TemporaryCacheService
typealias Child = TemporaryChild

// MARK: - Main Tab View

struct MainTabView: View {
    @StateObject private var authManager = AuthManager()
    @StateObject private var eventsViewModel = EventsViewModel()
    @StateObject private var childrenViewModel = ChildrenViewModel()
    @StateObject private var cacheService = CacheService.shared
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some View {
        TabView {
            // Onglet Accueil
            HomeView()
                .environmentObject(childrenViewModel)
                .environmentObject(eventsViewModel)
                .environmentObject(authManager)
                .environmentObject(notificationManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }
            
            // Onglet Enfants
            ChildrenView()
                .environmentObject(childrenViewModel)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Enfants")
                }
            
            // Onglet Calendrier
            TemporaryCalendarView()
                .environmentObject(eventsViewModel)
                .environmentObject(childrenViewModel)
                .environmentObject(notificationManager)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendrier")
                }
            
            // Onglet Documents
            DocumentsView()
                .tabItem {
                    Image(systemName: "doc.fill")
                    Text("Documents")
                }
            
            // Onglet Paramètres
            SettingsView()
                .environmentObject(cacheService)
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Paramètres")
                }
        }
        .environmentObject(authManager)
        .environmentObject(eventsViewModel)
        .environmentObject(childrenViewModel)
        .environmentObject(cacheService)
        .environmentObject(notificationManager)
        .onAppear {
            Task {
                await eventsViewModel.loadEvents()
                await childrenViewModel.loadChildren()
            }
        }
    }
}

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // En-tête de bienvenue
                    welcomeHeader
                    
                    // Actions rapides
                    quickActions
                    
                    // Événements d'aujourd'hui
                    todayEvents
                }
            }
            .navigationTitle("Accueil")
            .refreshable {
                await eventsViewModel.loadEvents()
                await childrenViewModel.loadChildren()
            }
        }
        .onAppear {
            Task {
                await eventsViewModel.loadEvents()
                await childrenViewModel.loadChildren()
            }
        }
    }
    
    // MARK: - Welcome Header
    
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bonjour !")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Voici un aperçu de votre journée")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    // MARK: - Quick Actions
    
    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actions rapides")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Nouvel événement",
                    icon: "plus.circle.fill",
                    color: .blue
                ) {
                    // TODO: Action pour nouvel événement
                }
                
                QuickActionButton(
                    title: "Voir agenda",
                    icon: "calendar",
                    color: .green
                ) {
                    // TODO: Action pour voir agenda
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    // MARK: - Today Events
    
    private var todayEvents: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aujourd'hui")
                .font(.headline)
                .fontWeight(.semibold)
            
            if eventsViewModel.todayEvents.isEmpty {
                 VStack(spacing: 12) {
                     Image(systemName: "calendar")
                         .font(.system(size: 30))
                         .foregroundColor(.gray)
                     Text("Aucun événement aujourd'hui")
                         .font(.subheadline)
                         .foregroundColor(.secondary)
                 }
                 .padding(.vertical, 20)
             } else {
                 ForEach(eventsViewModel.todayEvents.prefix(3), id: \.id) { event in
                     HStack {
                         Text(event.title)
                             .font(.subheadline)
                         Spacer()
                         Text(DateFormatter.localizedString(from: event.startDate, dateStyle: .none, timeStyle: .short))
                             .font(.caption)
                             .foregroundColor(.secondary)
                     }
                     .padding(.vertical, 4)
                     .padding(.horizontal, 12)
                     .background(
                         RoundedRectangle(cornerRadius: 8)
                             .fill(Color(.systemGray6))
                     )
                 }
             }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

// MARK: - Placeholder Views (À remplacer par les vraies vues)

struct ChildrenView: View {
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                 if childrenViewModel.children.isEmpty {
                     VStack(spacing: 20) {
                         Image(systemName: "person.2")
                             .font(.system(size: 50))
                             .foregroundColor(.green.opacity(0.6))
                         Text("Aucun enfant")
                             .font(.title3)
                             .fontWeight(.medium)
                         Text("Ajoutez les informations de vos enfants")
                             .font(.subheadline)
                             .foregroundColor(.secondary)
                     }
                     .padding(.top, 40)
                 } else {
                     List(childrenViewModel.children, id: \.id) { child in
                         Text(child.fullName)
                     }
                 }
             }
            .navigationTitle("Enfants")
        }
    }
}

struct DocumentsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "doc")
                    .font(.system(size: 50))
                    .foregroundColor(.orange.opacity(0.6))
                Text("Aucun document")
                    .font(.title3)
                    .fontWeight(.medium)
                Text("Organisez vos documents importants")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            .navigationTitle("Documents")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var cacheService: CacheService
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            List {
                Section("Compte") {
                    if let user = authManager.currentUser {
                        Text("Connecté: \(user.email ?? "Utilisateur")")
                    }
                }
                
                Section("Cache") {
                    let stats = cacheService.cacheStatistics
                    Text("Dernière sync: \(stats.formattedLastSync)")
                    Text("Événements en cache: \(stats.hasEventsCache ? "Oui" : "Non")")
                }
            }
            .navigationTitle("Paramètres")
        }
    }
}

// MARK: - Temporary ViewModels (À remplacer par les vrais ViewModels)

class ChildrenViewModel: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    
    func loadChildren() async {
        // TODO: Implémenter le chargement des enfants
        #if DEBUG
        children = Child.sampleChildren
        #endif
    }
}

class NotificationManager: ObservableObject {
    // TODO: Implémenter la gestion des notifications
}

// MARK: - Temporary Classes (À remplacer par les vrais modèles)

class TemporaryEventsViewModel: ObservableObject {
    @Published var events: [TemporaryEvent] = []
    @Published var isLoading = false
    
    var todayEvents: [TemporaryEvent] {
        events.filter { Calendar.current.isDateInToday($0.startDate) }
    }
    
    func loadEvents() async {
        // TODO: Implémenter le chargement des événements
    }
}

class TemporaryCacheService: ObservableObject {
    static let shared = TemporaryCacheService()
    
    var cacheStatistics: TemporaryCacheStatistics {
        TemporaryCacheStatistics(
            formattedLastSync: "Il y a 5 minutes",
            hasEventsCache: true
        )
    }
}

struct TemporaryCacheStatistics {
    let formattedLastSync: String
    let hasEventsCache: Bool
}

struct TemporaryChild {
    let id = UUID()
    let firstName: String
    let lastName: String
    let birthDate: Date
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    static let sampleChildren: [TemporaryChild] = [
        TemporaryChild(
            firstName: "Emma",
            lastName: "Dupont",
            birthDate: Calendar.current.date(byAdding: .year, value: -5, to: Date()) ?? Date()
        ),
        TemporaryChild(
            firstName: "Lucas",
            lastName: "Martin",
            birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date()
        )
    ]
}

struct TemporaryEvent {
    let id = UUID()
    let title: String
    let startDate: Date
    let endDate: Date
}

struct TemporaryCalendarView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "calendar")
                    .font(.system(size: 50))
                    .foregroundColor(.blue.opacity(0.6))
                Text("Calendrier")
                    .font(.title3)
                    .fontWeight(.medium)
                Text("Vue calendrier en cours de développement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            .navigationTitle("Calendrier")
        }
    }
}

// MARK: - Temporary AddEventView

struct AddEventView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Formulaire d'ajout d'événement")
                    .font(.title2)
                    .padding()
                
                Spacer()
                
                Button("Fermer") {
                    dismiss()
                }
                .padding()
            }
            .navigationTitle("Nouvel événement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}
