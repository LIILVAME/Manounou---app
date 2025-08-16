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

// MARK: - Temporary Filter Types
struct FilterState {
    var searchText: String = ""
    var selectedGender: Gender? = nil
    var selectedAgeCategory: AgeCategory? = nil
    var sortOption: SortOption = .nameAscending
    
    var hasActiveFilters: Bool {
        return !searchText.isEmpty || selectedGender != nil || selectedAgeCategory != nil || sortOption != .nameAscending
    }
    
    mutating func clearAll() {
        searchText = ""
        selectedGender = nil
        selectedAgeCategory = nil
        sortOption = .nameAscending
    }
}

enum Gender: String, CaseIterable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .male: return "Garçon"
        case .female: return "Fille"
        case .other: return "Autre"
        }
    }
    
    var icon: String {
        switch self {
        case .male: return "figure.child"
        case .female: return "figure.child"
        case .other: return "person"
        }
    }
    
    var color: Color {
        switch self {
        case .male: return .blue
        case .female: return .pink
        case .other: return .purple
        }
    }
}

enum AgeCategory: String, CaseIterable {
    case baby = "baby"
    case toddler = "toddler"
    case preschool = "preschool"
    case school = "school"
    case teen = "teen"
    
    var displayName: String {
        switch self {
        case .baby: return "Bébé (0-2 ans)"
        case .toddler: return "Bambin (2-4 ans)"
        case .preschool: return "Préscolaire (4-6 ans)"
        case .school: return "Scolaire (6-12 ans)"
        case .teen: return "Adolescent (12+ ans)"
        }
    }
    
    var icon: String {
        switch self {
        case .baby: return "figure.child.circle"
        case .toddler: return "figure.walk"
        case .preschool: return "figure.run"
        case .school: return "backpack"
        case .teen: return "figure.wave"
        }
    }
    
    var color: Color {
        switch self {
        case .baby: return .mint
        case .toddler: return .green
        case .preschool: return .orange
        case .school: return .blue
        case .teen: return .purple
        }
    }
}

enum SortOption: String, CaseIterable {
    case nameAscending = "name_asc"
    case nameDescending = "name_desc"
    case ageAscending = "age_asc"
    case ageDescending = "age_desc"
    
    var title: String {
        switch self {
        case .nameAscending: return "Nom A-Z"
        case .nameDescending: return "Nom Z-A"
        case .ageAscending: return "Plus jeune"
        case .ageDescending: return "Plus âgé"
        }
    }
    
    var icon: String {
        switch self {
        case .nameAscending: return "textformat.abc"
        case .nameDescending: return "textformat.abc"
        case .ageAscending: return "arrow.up.circle"
        case .ageDescending: return "arrow.down.circle"
        }
    }
}

// Extensions pour TemporaryChild
extension TemporaryChild {
    var gender: Gender {
        let femaleNames = ["Emma", "Léa", "Chloé", "Manon", "Sarah", "Jade", "Lola", "Anaïs", "Lucie", "Océane"]
        return femaleNames.contains(firstName) ? .female : .male
    }
    
    var ageInYears: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year ?? 0
    }
    
    var ageCategory: AgeCategory {
        let age = ageInYears
        switch age {
        case 0...2: return .baby
        case 2...4: return .toddler
        case 4...6: return .preschool
        case 6...12: return .school
        default: return .teen
        }
    }
    
    func matches(filter: FilterState) -> Bool {
        if !filter.searchText.isEmpty {
            let searchLower = filter.searchText.lowercased()
            let fullNameLower = fullName.lowercased()
            if !fullNameLower.contains(searchLower) {
                return false
            }
        }
        
        if let selectedGender = filter.selectedGender {
            if gender != selectedGender {
                return false
            }
        }
        
        if let selectedAgeCategory = filter.selectedAgeCategory {
            if ageCategory != selectedAgeCategory {
                return false
            }
        }
        
        return true
    }
}

extension Array where Element == TemporaryChild {
    func sorted(by option: SortOption) -> [TemporaryChild] {
        switch option {
        case .nameAscending:
            return self.sorted { $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedAscending }
        case .nameDescending:
            return self.sorted { $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedDescending }
        case .ageAscending:
            return self.sorted { $0.birthDate > $1.birthDate }
        case .ageDescending:
            return self.sorted { $0.birthDate < $1.birthDate }
        }
    }
    
    func filtered(by filterState: FilterState) -> [TemporaryChild] {
        return self.filter { $0.matches(filter: filterState) }
    }
    
    func filteredAndSorted(by filterState: FilterState) -> [TemporaryChild] {
        return self.filtered(by: filterState).sorted(by: filterState.sortOption)
    }
}

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
    

    
    // MARK: - Search and Filters Section
     private func searchAndFiltersSection(geometry: GeometryProxy) -> some View {
         VStack(spacing: geometry.size.height * 0.015) {
             // Barre de recherche
             HStack(spacing: geometry.size.width * 0.03) {
                 HStack(spacing: geometry.size.width * 0.03) {
                     Image(systemName: "magnifyingglass")
                         .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                         .foregroundColor(.secondary)
                     
                     TextField("Rechercher un enfant...", text: $filterState.searchText)
                         .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                         .textFieldStyle(PlainTextFieldStyle())
                     
                     if !filterState.searchText.isEmpty {
                         Button(action: { filterState.searchText = "" }) {
                             Image(systemName: "xmark.circle.fill")
                                 .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                                 .foregroundColor(.secondary)
                         }
                     }
                 }
                 .padding(.horizontal, geometry.size.width * 0.04)
                 .padding(.vertical, geometry.size.height * 0.015)
                 .background(
                     RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                         .fill(Color(.systemGray6))
                 )
             }
             
             // Filtres rapides
             if filterState.hasActiveFilters {
                 HStack {
                     ScrollView(.horizontal, showsIndicators: false) {
                         HStack(spacing: geometry.size.width * 0.025) {
                             if let gender = filterState.selectedGender {
                                 filterChip(title: gender.displayName, color: gender.color, geometry: geometry) {
                                     filterState.selectedGender = nil
                                 }
                             }
                             
                             if let ageCategory = filterState.selectedAgeCategory {
                                 filterChip(title: ageCategory.displayName, color: ageCategory.color, geometry: geometry) {
                                     filterState.selectedAgeCategory = nil
                                 }
                             }
                             
                             if filterState.sortOption != .nameAscending {
                                 filterChip(title: filterState.sortOption.title, color: .blue, geometry: geometry) {
                                     cycleSortOption()
                                 }
                             }
                         }
                         .padding(.horizontal, geometry.size.width * 0.01)
                     }
                     
                     Spacer()
                     
                     Button(action: { filterState.clearAll() }) {
                         Text("Effacer")
                             .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                             .foregroundColor(.red)
                     }
                 }
             }
             
             // Boutons de tri rapide
             HStack(spacing: geometry.size.width * 0.02) {
                 Button(action: { cycleSortOption() }) {
                     HStack(spacing: geometry.size.width * 0.02) {
                         Image(systemName: filterState.sortOption.icon)
                             .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                         Text(filterState.sortOption.title)
                             .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                     }
                     .foregroundColor(.blue)
                     .padding(.horizontal, geometry.size.width * 0.03)
                     .padding(.vertical, geometry.size.height * 0.01)
                     .background(
                         RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                             .fill(Color.blue.opacity(0.1))
                     )
                 }
                 
                 Spacer()
                 
                 // Filtres par genre
                 Menu {
                     Button("Tous") { filterState.selectedGender = nil }
                     ForEach(Gender.allCases, id: \.self) { gender in
                         Button(gender.displayName) {
                             filterState.selectedGender = filterState.selectedGender == gender ? nil : gender
                         }
                     }
                 } label: {
                     HStack(spacing: geometry.size.width * 0.02) {
                         Image(systemName: "person.2")
                             .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                         Text(filterState.selectedGender?.displayName ?? "Genre")
                             .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                     }
                     .foregroundColor(filterState.selectedGender != nil ? .white : .purple)
                     .padding(.horizontal, geometry.size.width * 0.03)
                     .padding(.vertical, geometry.size.height * 0.01)
                     .background(
                         RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                             .fill(filterState.selectedGender != nil ? Color.purple : Color.purple.opacity(0.1))
                     )
                 }
                 
                 // Filtres par âge
                 Menu {
                     Button("Tous") { filterState.selectedAgeCategory = nil }
                     ForEach(AgeCategory.allCases, id: \.self) { category in
                         Button(category.displayName) {
                             filterState.selectedAgeCategory = filterState.selectedAgeCategory == category ? nil : category
                         }
                     }
                 } label: {
                     HStack(spacing: geometry.size.width * 0.02) {
                         Image(systemName: "figure.walk")
                             .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                         Text(filterState.selectedAgeCategory?.displayName ?? "Âge")
                             .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                             .lineLimit(1)
                             .minimumScaleFactor(0.8)
                     }
                     .foregroundColor(filterState.selectedAgeCategory != nil ? .white : .green)
                     .padding(.horizontal, geometry.size.width * 0.03)
                     .padding(.vertical, geometry.size.height * 0.01)
                     .background(
                         RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                             .fill(filterState.selectedAgeCategory != nil ? Color.green : Color.green.opacity(0.1))
                     )
                 }
             }
         }
         .padding(.horizontal, geometry.size.width * 0.05)
         .padding(.bottom, geometry.size.height * 0.02)
     }
     
     // MARK: - Filter Chip Helper
     private func filterChip(title: String, color: Color, geometry: GeometryProxy, action: @escaping () -> Void) -> some View {
         Button(action: action) {
             HStack(spacing: geometry.size.width * 0.015) {
                 Text(title)
                     .font(.system(size: geometry.size.width * 0.032, weight: .medium))
                     .foregroundColor(.white)
                 
                 Image(systemName: "xmark")
                     .font(.system(size: geometry.size.width * 0.025, weight: .bold))
                     .foregroundColor(.white)
             }
             .padding(.horizontal, geometry.size.width * 0.025)
             .padding(.vertical, geometry.size.height * 0.008)
             .background(
                 RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                     .fill(color)
             )
         }
     }
     
     // MARK: - Sort Cycle Helper
     private func cycleSortOption() {
         switch filterState.sortOption {
         case .nameAscending:
             filterState.sortOption = .nameDescending
         case .nameDescending:
             filterState.sortOption = .ageAscending
         case .ageAscending:
             filterState.sortOption = .ageDescending
         case .ageDescending:
             filterState.sortOption = .nameAscending
         }
     }
     
     // MARK: - Results Header
     private func resultsHeader(geometry: GeometryProxy) -> some View {
         HStack {
             Text("\(filteredChildren.count) résultat(s)")
                 .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                 .foregroundColor(.secondary)
             
             Spacer()
             
             Button(action: {
                 filterState.clearAll()
             }) {
                 Text("Effacer")
                     .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                     .foregroundColor(.blue)
             }
         }
         .padding(.bottom, geometry.size.height * 0.01)
     }
                .tag(0)
            
            // Enfants
            TemporaryChildrenView()
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
                        
                        // Actions rapides - 4 boutons en grille
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
            .frame(height: geometry.size.height * 0.11)
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

// MARK: - Temporary Enhanced Children View

struct TemporaryChildrenView: View {
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @State private var showingAddChild = false
    @State private var filterState = FilterState()
    
    var filteredChildren: [Child] {
        return childrenViewModel.children.filteredAndSorted(by: filterState)
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header moderne
                    headerSection(geometry: geometry)
                    
                    // Barre de recherche simple
                    if !childrenViewModel.children.isEmpty {
                        VStack(spacing: geometry.size.height * 0.015) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                TextField("Rechercher...", text: $filterState.searchText)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                if !filterState.searchText.isEmpty {
                                    Button("Effacer") {
                                        filterState.clearAll()
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Contenu
                    if childrenViewModel.children.isEmpty {
                        // État vide amélioré
                        emptyState(geometry: geometry)
                    } else if filteredChildren.isEmpty {
                        VStack {
                            Text("Aucun résultat")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            Button("Effacer les filtres") {
                                filterState.clearAll()
                            }
                            .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Liste des enfants
                        childrenList(geometry: geometry)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddChild) {
            AddChildView()
        }
        .onAppear {
            Task {
                await childrenViewModel.loadChildren()
            }
        }
    }
    
    // MARK: - Header Section
    private func headerSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            HStack {
                VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                    Text("Enfants")
                        .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if !childrenViewModel.children.isEmpty {
                        Text("\(filterState.hasActiveFilters ? filteredChildren.count : childrenViewModel.children.count) enfant(s)")
                            .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Bouton d'ajout moderne
                Button(action: { showingAddChild = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(
                            width: geometry.size.width * 0.12,
                            height: geometry.size.width * 0.12
                        )
                        .background(
                            Circle()
                                .fill(Color.blue)
                        )
                        .shadow(
                            color: Color.blue.opacity(0.3),
                            radius: geometry.size.width * 0.01,
                            x: 0,
                            y: geometry.size.width * 0.005
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, geometry.size.width * 0.05)
        .padding(.top, geometry.size.height * 0.02)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Empty State
    private func emptyState(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.04) {
            Spacer()
            
            // Illustration
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.1),
                                Color.green.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * 0.3,
                        height: geometry.size.width * 0.3
                    )
                
                Image(systemName: "figure.2.and.child.holdinghands")
                    .font(.system(size: geometry.size.width * 0.12, weight: .light))
                    .foregroundColor(.blue)
            }
            
            // Message principal
            VStack(spacing: geometry.size.height * 0.015) {
                Text("Commencez votre carnet de famille")
                    .font(.system(size: geometry.size.width * 0.06, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Ajoutez les informations de vos enfants pour créer un espace familial personnalisé")
                    .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, geometry.size.width * 0.08)
            
            // Bouton CTA
            Button(action: { showingAddChild = true }) {
                HStack(spacing: geometry.size.width * 0.03) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Ajouter votre premier enfant")
                        .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height * 0.07)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(geometry.size.width * 0.04)
                .shadow(
                    color: Color.blue.opacity(0.3),
                    radius: geometry.size.width * 0.02,
                    x: 0,
                    y: geometry.size.width * 0.01
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, geometry.size.width * 0.06)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Children List
    private func childrenList(geometry: GeometryProxy) -> some View {
        ScrollView {
            LazyVStack(spacing: geometry.size.height * 0.015) {
                // Résumé des résultats
                if filterState.hasActiveFilters {
                    HStack {
                        Text("\(filteredChildren.count) résultat(s)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Effacer") {
                            filterState.clearAll()
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                }
                
                ForEach(filteredChildren, id: \.id) { child in
                    childCard(child: child, geometry: geometry)
                }
            }
            .padding(.horizontal, geometry.size.width * 0.05)
            .padding(.top, geometry.size.height * 0.02)
        }
        .refreshable {
            await childrenViewModel.loadChildren()
        }
    }
    
    // MARK: - Child Card
    private func childCard(child: Child, geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.04) {
            // Avatar
             ZStack {
                 Circle()
                     .fill(
                         LinearGradient(
                             colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing
                         )
                     )
                     .frame(
                         width: geometry.size.width * 0.15,
                         height: geometry.size.width * 0.15
                     )
                 
                 Text("\(child.firstName.first?.uppercased() ?? "")\(child.lastName.first?.uppercased() ?? "")")
                     .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                     .foregroundColor(.blue)
             }
            
            // Informations
            VStack(alignment: .leading, spacing: geometry.size.height * 0.008) {
                HStack {
                    Text(child.fullName)
                        .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text({
                         let calendar = Calendar.current
                         let ageComponents = calendar.dateComponents([.year], from: child.birthDate, to: Date())
                         let years = ageComponents.year ?? 0
                         return years <= 1 ? "\(years) an" : "\(years) ans"
                     }())
                           .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                           .foregroundColor(.secondary)
                }
                
                HStack(spacing: geometry.size.width * 0.02) {
                     // Badge âge
                     HStack(spacing: geometry.size.width * 0.01) {
                         Image(systemName: "calendar")
                             .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                             .foregroundColor(.blue)
                         
                         Text("Né(e) le \(child.birthDate.formatted(date: .abbreviated, time: .omitted))")
                             .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                             .foregroundColor(.blue)
                     }
                     .padding(.horizontal, geometry.size.width * 0.02)
                     .padding(.vertical, geometry.size.height * 0.005)
                     .background(
                         RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                             .fill(Color.blue.opacity(0.15))
                     )
                     
                     Spacer()
                 }
            }
        }
        .padding(geometry.size.width * 0.04)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: geometry.size.width * 0.01,
                    x: 0,
                    y: geometry.size.width * 0.005
                )
        )
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
