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
import Combine

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
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
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
                .tag(0)
            
            // Onglet Enfants
            ChildrenView()
                .environmentObject(childrenViewModel)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Enfants")
                }
                .tag(1)
            
            // Onglet Calendrier
            TemporaryCalendarView()
                .environmentObject(eventsViewModel)
                .environmentObject(childrenViewModel)
                .environmentObject(notificationManager)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendrier")
                }
                .tag(2)
            
            // Onglet Documents
            DocumentsView()
                .tabItem {
                    Image(systemName: "doc.fill")
                    Text("Documents")
                }
                .tag(3)
            
            // Onglet Paramètres
            SettingsView()
                .environmentObject(cacheService)
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Paramètres")
                }
                .tag(4)
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
        // Navigation par onglets sera implémentée plus tard
    }
}

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var showingAddChild = false
    @State private var showingAddDocument = false
    @State private var showingAddEvent = false
    @State private var showingInviteFamily = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.025) {
                        // En-tête de bienvenue
                        welcomeHeader
                        
                        // Actions rapides en grille
                        quickActionsGrid
                        
                        // Statistiques familiales
                        familyStatistics
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.top, geometry.size.height * 0.04)
                    .frame(maxHeight: geometry.size.height * 0.65)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddChild) {
            AddChildView()
        }
        .sheet(isPresented: $showingAddDocument) {
            AddDocumentView()
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView()
                .environmentObject(eventsViewModel)
                .environmentObject(childrenViewModel)
        }
        .sheet(isPresented: $showingInviteFamily) {
            InviteFamilyView()
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
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(welcomeMessage)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Bienvenue dans votre carnet de famille")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Computed Properties
    
    private var welcomeMessage: String {
        if let user = authManager.currentUser {
            // Fallback : extraire le prénom depuis l'email
            if let email = user.email {
                let emailPrefix = String(email.split(separator: "@").first ?? "")
                let firstName = emailPrefix.capitalized
                return "Bonjour \(firstName) !"
            }
        }
        return "Bonjour Utilisateur !"
    }
    
    // MARK: - Quick Actions Grid
    
    private var quickActionsGrid: some View {
        GeometryReader { geometry in
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: geometry.size.width * 0.03), count: 2), spacing: geometry.size.width * 0.03) {
                // Ajouter un enfant
                ActionCard(
                    title: "Ajouter un enfant",
                    icon: "plus",
                    iconColor: .white,
                    backgroundColor: Color.blue,
                    geometry: geometry
                ) {
                    showingAddChild = true
                }
                
                // Nouveau document
                ActionCard(
                    title: "Nouveau document",
                    icon: "plus",
                    iconColor: .white,
                    backgroundColor: Color.green,
                    geometry: geometry
                ) {
                    showingAddDocument = true
                }
                
                // Ajouter un événement
                ActionCard(
                    title: "Ajouter un événement",
                    icon: "plus",
                    iconColor: .white,
                    backgroundColor: Color.orange,
                    geometry: geometry
                ) {
                    showingAddEvent = true
                }
                
                // Inviter la famille
                ActionCard(
                    title: "Inviter la famille",
                    icon: "person.2",
                    iconColor: .white,
                    backgroundColor: Color.purple,
                    geometry: geometry
                ) {
                    showingInviteFamily = true
                }
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.25)
    }
    
    // MARK: - Family Statistics
    
    private var familyStatistics: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
                Text("Votre famille")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: geometry.size.width * 0.03) {
                    // Statistique enfants
                    StatisticCard(
                        count: childrenViewModel.children.count,
                        label: "enfants",
                        icon: "figure.2.and.child.holdinghands",
                        backgroundColor: Color.blue.opacity(0.1),
                        iconColor: Color.blue,
                        geometry: geometry
                    )
                    
                    // Statistique événements à venir
                    StatisticCard(
                        count: eventsViewModel.events.count,
                        label: "à venir",
                        icon: "calendar",
                        backgroundColor: Color.orange.opacity(0.1),
                        iconColor: Color.orange,
                        geometry: geometry
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: UIScreen.main.bounds.height * 0.12)
    }
}

// MARK: - Action Card

struct ActionCard: View {
    let title: String
    let icon: String
    let iconColor: Color
    let backgroundColor: Color
    let geometry: GeometryProxy
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: geometry.size.height * 0.015) {
                Image(systemName: icon)
                    .font(.system(size: geometry.size.width * 0.06, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: geometry.size.width * 0.12, height: geometry.size.width * 0.12)
                    .background(
                        Circle()
                            .fill(backgroundColor)
                    )
                
                Text(title)
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height * 0.45)
            .padding(.vertical, geometry.size.height * 0.015)
            .padding(.horizontal, geometry.size.width * 0.03)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Statistic Card

struct StatisticCard: View {
    let count: Int
    let label: String
    let icon: String
    let backgroundColor: Color
    let iconColor: Color
    let geometry: GeometryProxy
    
    var body: some View {
        HStack(spacing: geometry.size.width * 0.03) {
            Image(systemName: icon)
                .font(.system(size: geometry.size.width * 0.06, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1)
            
            VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                Text("\(count)")
                    .font(.system(size: geometry.size.width * 0.07, weight: .bold))
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Text(label)
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(.secondary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: geometry.size.height * 0.08)
        .padding(geometry.size.width * 0.04)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                .fill(backgroundColor)
        )
    }
}

// MARK: - Interactive Statistic Card (Removed temporarily for compilation)

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
    
    init() {
        #if DEBUG
        children = Child.sampleChildren
        #endif
    }
    
    func loadChildren() async {
        // TODO: Implémenter le chargement des enfants
        #if DEBUG
        await MainActor.run {
            children = Child.sampleChildren
        }
        #endif
    }
    
    func addChild(_ child: Child) {
        children.append(child)
    }
}

class NotificationManager: ObservableObject {
    @Published var hasNotifications = false
    
    init() {
        // Initialisation des notifications
    }
    
    func requestPermission() {
        // TODO: Implémenter la demande de permission
    }
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
        #if DEBUG
        events = [
            TemporaryEvent(
                title: "Rendez-vous médecin",
                startDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()) ?? Date()
            ),
            TemporaryEvent(
                title: "École maternelle",
                startDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 2, to: Calendar.current.date(byAdding: .hour, value: 6, to: Date()) ?? Date()) ?? Date()
            )
        ]
        #endif
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

// MARK: - Temporary Views

struct AddChildView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Ajouter un enfant")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Formulaire d'ajout d'enfant en cours de développement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Nouvel enfant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddDocumentView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Nouveau document")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Formulaire d'ajout de document en cours de développement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Nouveau document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddEventView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Ajouter un événement")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Formulaire d'ajout d'événement en cours de développement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Nouvel événement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InviteFamilyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.2.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                Text("Inviter la famille")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Fonctionnalité d'invitation familiale en cours de développement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Inviter la famille")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
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
