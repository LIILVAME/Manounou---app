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

// MARK: - Temporary Models for Demo

struct TempChild: Identifiable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let birthDate: Date
    let gender: TempGender
    let notes: String?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    var formattedAge: String {
        let components = Calendar.current.dateComponents([.year, .month], from: birthDate, to: Date())
        let years = components.year ?? 0
        let months = components.month ?? 0
        
        if years == 0 {
            return "\(months) mois"
        } else if months == 0 {
            return "\(years) an\(years > 1 ? "s" : "")"
        } else {
            return "\(years) an\(years > 1 ? "s" : "") et \(months) mois"
        }
    }
}

enum TempGender: String, CaseIterable {
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
    
    var color: Color {
        switch self {
        case .male: return .blue
        case .female: return .pink
        case .other: return .purple
        }
    }
}

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

// MARK: - Temporary ViewModels for HomeView

@MainActor
class TempChildrenViewModel: ObservableObject {
    @Published var children: [TempChild] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadChildren() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        children = [
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
            )
        ]
        isLoading = false
    }
}

@MainActor
class TempEventsViewModel: ObservableObject {
    @Published var events: [TempEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadEvents() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        events = [
            TempEvent(
                title: "Rendez-vous médecin",
                startDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                eventType: .medical
            ),
            TempEvent(
                title: "Réunion école",
                startDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                eventType: .school
            )
        ]
        isLoading = false
    }
}

@MainActor
class TempDocumentsViewModel: ObservableObject {
    @Published var documents: [TempDocument] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadDocuments() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        documents = [
            TempDocument(
                title: "Carnet de santé Emma",
                documentType: .medical,
                createdAt: Date()
            ),
            TempDocument(
                title: "Bulletin scolaire Lucas",
                documentType: .school,
                createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
            )
        ]
        isLoading = false
    }
}

// MARK: - Temporary Models for HomeView

struct TempEvent: Identifiable {
    let id = UUID()
    let title: String
    let startDate: Date
    let eventType: TempEventType
    
    var isToday: Bool {
        Calendar.current.isDateInToday(startDate)
    }
}

enum TempEventType {
    case medical, school, activity, other
    
    var color: Color {
        switch self {
        case .medical: return .red
        case .school: return .blue
        case .activity: return .green
        case .other: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .medical: return "cross.fill"
        case .school: return "book.fill"
        case .activity: return "figure.run"
        case .other: return "calendar"
        }
    }
}

struct TempDocument: Identifiable {
    let id = UUID()
    let title: String
    let documentType: TempDocumentType
    let createdAt: Date
    
    var isRecent: Bool {
        let daysSinceCreation = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
        return daysSinceCreation <= 7
    }
}

enum TempDocumentType {
    case medical, school, legal, other
    
    var displayName: String {
        switch self {
        case .medical: return "Médical"
        case .school: return "Scolaire"
        case .legal: return "Légal"
        case .other: return "Autre"
        }
    }
    
    var color: Color {
        switch self {
        case .medical: return .red
        case .school: return .blue
        case .legal: return .purple
        case .other: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .medical: return "cross.fill"
        case .school: return "book.fill"
        case .legal: return "doc.text.fill"
        case .other: return "doc.fill"
        }
    }
}

// MARK: - Tab Views

struct TempHomeView: View {
    @EnvironmentObject var childrenViewModel: TempChildrenViewModel
    @EnvironmentObject var eventsViewModel: TempEventsViewModel
    @EnvironmentObject var documentsViewModel: TempDocumentsViewModel
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.03) {
                        // Welcome Header
                        welcomeHeader(geometry: geometry)
                        
                        // Quick Stats
                        quickStats(geometry: geometry)
                        
                        // Upcoming Events
                        upcomingEvents(geometry: geometry)
                        
                        // Quick Actions
                        quickActions(geometry: geometry)
                        
                        // Recent Documents
                        recentDocuments(geometry: geometry)
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.top, geometry.size.height * 0.02)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .refreshable {
            await loadData()
        }
    }
    
    // MARK: - Welcome Header
    private func welcomeHeader(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
            HStack {
                VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                    Text(greetingText)
                        .font(.system(size: geometry.size.width * 0.06, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Utilisateur")
                        .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Profile Avatar
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * 0.12,
                                height: geometry.size.width * 0.12
                            )
                        
                        Text("US")
                            .font(.system(size: geometry.size.width * 0.05, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Text("Voici un aperçu de votre famille")
                .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Quick Stats
    private func quickStats(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            Text("Aperçu")
                .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: geometry.size.width * 0.04) {
                // Children Count
                statCard(
                    title: "Enfants",
                    value: "\(childrenViewModel.children.count)",
                    icon: "person.2.fill",
                    color: .blue,
                    geometry: geometry
                )
                
                // Events Count
                statCard(
                    title: "Événements",
                    value: "\(eventsViewModel.events.count)",
                    icon: "calendar",
                    color: .green,
                    geometry: geometry
                )
                
                // Documents Count
                statCard(
                    title: "Documents",
                    value: "\(documentsViewModel.documents.count)",
                    icon: "doc.fill",
                    color: .purple,
                    geometry: geometry
                )
            }
        }
    }
    
    // MARK: - Stat Card
    private func statCard(
        title: String,
        value: String,
        icon: String,
        color: Color,
        geometry: GeometryProxy
    ) -> some View {
        VStack(spacing: geometry.size.height * 0.015) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: geometry.size.width * 0.06, weight: .medium))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                Text(value)
                    .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(geometry.size.width * 0.04)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Upcoming Events
    private func upcomingEvents(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            HStack {
                Text("Événements à venir")
                    .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Voir tout") {}
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            if eventsViewModel.events.isEmpty {
                emptyEventsView(geometry: geometry)
            } else {
                VStack(spacing: geometry.size.height * 0.01) {
                    ForEach(Array(eventsViewModel.events.prefix(3)), id: \.id) { event in
                        eventRow(event: event, geometry: geometry)
                    }
                }
            }
        }
    }
    
    // MARK: - Event Row
    private func eventRow(event: TempEvent, geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.04) {
            // Event type indicator
            ZStack {
                Circle()
                    .fill(event.eventType.color.opacity(0.2))
                    .frame(
                        width: geometry.size.width * 0.1,
                        height: geometry.size.width * 0.1
                    )
                
                Image(systemName: event.eventType.icon)
                    .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                    .foregroundColor(event.eventType.color)
            }
            
            // Event info
            VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                Text(event.title)
                    .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(eventDateText(event.startDate))
                    .font(.system(size: geometry.size.width * 0.035, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Time indicator
            if event.isToday {
                Text("Aujourd'hui")
                    .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                    .foregroundColor(.orange)
                    .padding(.horizontal, geometry.size.width * 0.02)
                    .padding(.vertical, geometry.size.height * 0.005)
                    .background(
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.015)
                            .fill(.orange.opacity(0.1))
                    )
            }
        }
        .padding(.vertical, geometry.size.height * 0.01)
        .padding(.horizontal, geometry.size.width * 0.03)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Empty Events View
    private func emptyEventsView(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.015) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: geometry.size.width * 0.06, weight: .light))
                .foregroundColor(.secondary)
            
            Text("Aucun événement prévu")
                .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                .foregroundColor(.secondary)
            
            Button("Ajouter un événement") {}
                .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, geometry.size.height * 0.02)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Quick Actions
    private func quickActions(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            Text("Actions rapides")
                .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: geometry.size.width * 0.04) {
                // Add Child
                actionButton(
                    title: "Ajouter enfant",
                    icon: "person.badge.plus",
                    color: .blue,
                    geometry: geometry
                ) {}
                
                // Add Event
                actionButton(
                    title: "Nouvel événement",
                    icon: "calendar.badge.plus",
                    color: .green,
                    geometry: geometry
                ) {}
            }
            
            HStack(spacing: geometry.size.width * 0.04) {
                // Add Document
                actionButton(
                    title: "Ajouter document",
                    icon: "doc.badge.plus",
                    color: .purple,
                    geometry: geometry
                ) {}
                
                // View Calendar
                actionButton(
                    title: "Voir calendrier",
                    icon: "calendar",
                    color: .orange,
                    geometry: geometry
                ) {}
            }
        }
    }
    
    // MARK: - Action Button
    private func actionButton(
        title: String,
        icon: String,
        color: Color,
        geometry: GeometryProxy,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: geometry.size.height * 0.015) {
                Image(systemName: icon)
                    .font(.system(size: geometry.size.width * 0.06, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height * 0.12)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                    .fill(color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Recent Documents
    private func recentDocuments(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            HStack {
                Text("Documents récents")
                    .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Voir tout") {}
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            if documentsViewModel.documents.isEmpty {
                emptyDocumentsView(geometry: geometry)
            } else {
                VStack(spacing: geometry.size.height * 0.01) {
                    ForEach(Array(documentsViewModel.documents.prefix(3)), id: \.id) { document in
                        documentRow(document: document, geometry: geometry)
                    }
                }
            }
        }
    }
    
    // MARK: - Document Row
    private func documentRow(document: TempDocument, geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.04) {
            // Document type indicator
            ZStack {
                RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                    .fill(document.documentType.color.opacity(0.2))
                    .frame(
                        width: geometry.size.width * 0.1,
                        height: geometry.size.width * 0.1
                    )
                
                Image(systemName: document.documentType.icon)
                    .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                    .foregroundColor(document.documentType.color)
            }
            
            // Document info
            VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                Text(document.title)
                    .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(document.documentType.displayName)
                    .font(.system(size: geometry.size.width * 0.035, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Recent indicator
            if document.isRecent {
                Text("Nouveau")
                    .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                    .foregroundColor(.green)
                    .padding(.horizontal, geometry.size.width * 0.02)
                    .padding(.vertical, geometry.size.height * 0.005)
                    .background(
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.015)
                            .fill(.green.opacity(0.1))
                    )
            }
        }
        .padding(.vertical, geometry.size.height * 0.01)
        .padding(.horizontal, geometry.size.width * 0.03)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Empty Documents View
    private func emptyDocumentsView(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.015) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: geometry.size.width * 0.06, weight: .light))
                .foregroundColor(.secondary)
            
            Text("Aucun document ajouté")
                .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                .foregroundColor(.secondary)
            
            Button("Ajouter un document") {}
                .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, geometry.size.height * 0.02)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Helper Functions
    private func loadData() async {
        await childrenViewModel.loadChildren()
        await eventsViewModel.loadEvents()
        await documentsViewModel.loadDocuments()
    }
    
    private func eventDateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
    
    // MARK: - Computed Properties
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Bonjour"
        case 12..<17:
            return "Bon après-midi"
        case 17..<22:
            return "Bonsoir"
        default:
            return "Bonne nuit"
        }
    }
}

struct ChildrenTabView: View {
    let children: [TempChild]
    @State private var selectedChild: TempChild?
    
    var body: some View {
        NavigationView {
            VStack {
                if children.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Aucun enfant")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Ajoutez des enfants pour commencer")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List(children) { child in
                        Button {
                            selectedChild = child
                        } label: {
                            HStack {
                                Circle()
                                    .fill(child.gender.color.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                    .overlay {
                                        Text(child.initials)
                                            .font(.headline)
                                            .foregroundColor(child.gender.color)
                                    }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(child.fullName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(child.formattedAge)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(child.gender.displayName)
                                        .font(.caption)
                                        .foregroundColor(child.gender.color)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Enfants")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        // TODO: Add child functionality
                    }
                }
            }
        }
        .sheet(item: $selectedChild) { child in
            TempChildDetailView(child: child)
        }
    }
}

struct CalendarTabView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "calendar")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Calendrier")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Gestion des événements et rendez-vous")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("✅ CalendarView développé")
                    Text("✅ AddEventView pour création")
                    Text("✅ EventCardView pour affichage")
                    Text("✅ Gestion des notifications")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                Spacer()
            }
            .padding()
            .navigationTitle("Calendrier")
        }
    }
}

struct DocumentsTabView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                Text("Documents")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Gestion des documents et fichiers")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("✅ DocumentsView développé")
                    Text("✅ DocumentCardView pour affichage")
                    Text("✅ Upload et gestion de fichiers")
                    Text("✅ Structure optimale (2 fichiers)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                Spacer()
            }
            .padding()
            .navigationTitle("Documents")
        }
    }
}

struct SettingsTabView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Paramètres")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Configuration et profil utilisateur")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("✅ ProfileView intégré")
                    Text("✅ EditProfile intégré dans ProfileView")
                    Text("✅ ChangePassword intégré dans ProfileView")
                    Text("✅ Optimisation LEAN (-67% fichiers)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                Spacer()
            }
            .padding()
            .navigationTitle("Paramètres")
        }
     }
 }
 
 // MARK: - Temporary Child Detail View
 
 struct TempChildDetailView: View {
     let child: TempChild
     @Environment(\.dismiss) private var dismiss
     
     var body: some View {
         NavigationView {
             ScrollView {
                 VStack(spacing: 20) {
                     // Header avec photo de profil
                     Circle()
                         .fill(child.gender.color.opacity(0.2))
                         .frame(width: 120, height: 120)
                         .overlay {
                             Text(child.initials)
                                 .font(.system(size: 32, weight: .bold))
                                 .foregroundColor(child.gender.color)
                         }
                     
                     // Nom complet
                     Text(child.fullName)
                         .font(.title)
                         .fontWeight(.bold)
                     
                     // Âge formaté selon la demande "X ans et Y mois"
                     Text(child.formattedAge)
                         .font(.title2)
                         .foregroundColor(.white)
                         .padding(.horizontal, 16)
                         .padding(.vertical, 8)
                         .background(
                             RoundedRectangle(cornerRadius: 12)
                                 .fill(child.gender.color)
                         )
                     
                     // Informations principales
                     VStack(alignment: .leading, spacing: 12) {
                         Text("Informations principales")
                             .font(.headline)
                             .frame(maxWidth: .infinity, alignment: .leading)
                         
                         VStack(spacing: 8) {
                             HStack {
                                 Image(systemName: "calendar")
                                     .foregroundColor(.blue)
                                     .frame(width: 24)
                                 Text("Date de naissance")
                                     .foregroundColor(.secondary)
                                 Spacer()
                                 Text(DateFormatter.localizedString(from: child.birthDate, dateStyle: .medium, timeStyle: .none))
                                     .fontWeight(.medium)
                             }
                             
                             HStack {
                                 Image(systemName: "person.fill")
                                     .foregroundColor(child.gender.color)
                                     .frame(width: 24)
                                 Text("Genre")
                                     .foregroundColor(.secondary)
                                 Spacer()
                                 Text(child.gender.displayName)
                                     .fontWeight(.medium)
                             }
                         }
                     }
                     .padding()
                     .background(
                         RoundedRectangle(cornerRadius: 12)
                             .fill(Color(.systemGray6))
                     )
                     
                     // Notes
                     if let notes = child.notes, !notes.isEmpty {
                         VStack(alignment: .leading, spacing: 12) {
                             Text("Notes")
                                 .font(.headline)
                                 .frame(maxWidth: .infinity, alignment: .leading)
                             
                             HStack {
                                 Image(systemName: "note.text")
                                     .foregroundColor(.yellow)
                                     .frame(width: 24)
                                 Text(notes)
                                     .font(.body)
                                     .multilineTextAlignment(.leading)
                                 Spacer()
                             }
                         }
                         .padding()
                         .background(
                             RoundedRectangle(cornerRadius: 12)
                                 .fill(Color(.systemGray6))
                         )
                     }
                     
                     // Démonstration du formatage d'âge
                     VStack(alignment: .leading, spacing: 12) {
                         Text("Démonstration du formatage d'âge")
                             .font(.headline)
                             .frame(maxWidth: .infinity, alignment: .leading)
                         
                         VStack(spacing: 8) {
                             Text("Format demandé : \"X ans et Y mois\"")
                                 .font(.subheadline)
                                 .foregroundColor(.secondary)
                                 .frame(maxWidth: .infinity, alignment: .leading)
                             
                             HStack {
                                 Text("Âge formaté :")
                                     .foregroundColor(.secondary)
                                 Spacer()
                                 Text(child.formattedAge)
                                     .fontWeight(.bold)
                                     .padding(.horizontal, 12)
                                     .padding(.vertical, 6)
                                     .background(
                                         RoundedRectangle(cornerRadius: 8)
                                             .fill(Color.green.opacity(0.2))
                                     )
                             }
                             
                             Text("✅ Formatage conforme à la demande")
                                 .font(.caption)
                                 .foregroundColor(.green)
                                 .frame(maxWidth: .infinity, alignment: .leading)
                         }
                     }
                     .padding()
                     .background(
                         RoundedRectangle(cornerRadius: 12)
                             .fill(Color(.systemGray6))
                     )
                 }
                 .padding()
             }
             .navigationTitle("Détails de l'enfant")
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
