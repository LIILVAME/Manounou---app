//
//  HomeView.swift
//  Manounou
//
//  Created by Assistant on 17/08/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var documentsViewModel: DocumentsViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Navigation states
    @State private var showingProfile = false
    @State private var showingAddChild = false
    @State private var showingAddEvent = false
    @State private var showingAddDocument = false
    @State private var navigateToCalendar = false
    @State private var navigateToChildren = false
    @State private var navigateToDocuments = false
    
    var body: some View {
        NavigationStack {
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
            .navigationDestination(isPresented: $navigateToChildren) {
                ModernChildrenView()
                    .environmentObject(childrenViewModel)
            }
            .navigationDestination(isPresented: $navigateToCalendar) {
                ModernCalendarView()
                    .environmentObject(eventsViewModel)
            }
            .navigationDestination(isPresented: $navigateToDocuments) {
                ModernDocumentsView()
                    .environmentObject(documentsViewModel)
                    .environmentObject(childrenViewModel)
            }
        }
        .onAppear {
            Task {
                await loadData()
            }
        }
        .refreshable {
            await loadData()
        }
        .sheet(isPresented: $showingProfile) {
            ProfileEditSheet()
        }
        .sheet(isPresented: $showingAddChild) {
            AddChildSheet()
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventSheet()
        }
        .sheet(isPresented: $showingAddDocument) {
            AddDocumentSheet()
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
                    
                    Text(displayName)
                        .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Profile Avatar
                Button(action: {
                    showingProfile = true
                }) {
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
                        
                        Text(userInitials)
                            .font(.system(size: geometry.size.width * 0.05, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Profil utilisateur")
                .accessibilityHint("Appuyez pour modifier votre profil")
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
                Button(action: { navigateToChildren = true }) {
                    statCard(
                        title: "Enfants",
                        value: "\(childrenViewModel.children.count)",
                        icon: "person.2.fill",
                        color: .blue,
                        geometry: geometry
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { navigateToCalendar = true }) {
                    statCard(
                        title: "Événements",
                        value: "\(upcomingEventsCount)",
                        icon: "calendar.badge.clock",
                        color: .green,
                        geometry: geometry
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { navigateToDocuments = true }) {
                    statCard(
                        title: "Documents",
                        value: "\(documentsViewModel.documents.count)",
                        icon: "doc.text.fill",
                        color: .purple,
                        geometry: geometry
                    )
                }
                .buttonStyle(PlainButtonStyle())
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
        VStack(spacing: geometry.size.height * 0.01) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                
                Spacer()
                
                Text(value)
                    .font(.system(size: geometry.size.width * 0.06, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(geometry.size.width * 0.04)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                .fill(color.opacity(0.1))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
        .accessibilityHint("Appuyez pour voir les détails")
    }
    
    // MARK: - Upcoming Events
    private func upcomingEvents(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            HStack {
                Text("Prochains événements")
                    .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Voir tout") {
                    navigateToCalendar = true
                }
                .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                .foregroundColor(.blue)
                .accessibilityLabel("Voir tous les événements")
            }
            
            if upcomingEvents.isEmpty {
                emptyEventsView(geometry: geometry)
            } else {
                VStack(spacing: geometry.size.height * 0.015) {
                    ForEach(Array(upcomingEvents.prefix(3)), id: \.id) { event in
                        Button(action: { navigateToCalendar = true }) {
                            eventRow(event: event, geometry: geometry)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    // MARK: - Event Row
    private func eventRow(event: Event, geometry: GeometryProxy) -> some View {
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
                    .foregroundColor(.white)
                    .padding(.horizontal, geometry.size.width * 0.02)
                    .padding(.vertical, geometry.size.height * 0.005)
                    .background(
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.015)
                            .fill(Color.orange)
                    )
            } else {
                Text(relativeDateText(event.startDate))
                    .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(geometry.size.width * 0.04)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: geometry.size.width * 0.01,
                    x: 0,
                    y: geometry.size.width * 0.005
                )
        )
    }
    
    // MARK: - Empty Events View
    private func emptyEventsView(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: geometry.size.width * 0.08, weight: .light))
                .foregroundColor(.secondary)
            
            Text("Aucun événement planifié")
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.secondary)
            
            Button("Ajouter un événement") {
                showingAddEvent = true
            }
            .font(.system(size: geometry.size.width * 0.035, weight: .medium))
            .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, geometry.size.height * 0.03)
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
                ) {
                    showingAddChild = true
                }
                
                // Add Event
                actionButton(
                    title: "Nouvel événement",
                    icon: "calendar.badge.plus",
                    color: .green,
                    geometry: geometry
                ) {
                    showingAddEvent = true
                }
            }
            
            HStack(spacing: geometry.size.width * 0.04) {
                // Add Document
                actionButton(
                    title: "Ajouter document",
                    icon: "doc.badge.plus",
                    color: .purple,
                    geometry: geometry
                ) {
                    showingAddDocument = true
                }
                
                // View Calendar
                actionButton(
                    title: "Voir calendrier",
                    icon: "calendar",
                    color: .orange,
                    geometry: geometry
                ) {
                    navigateToCalendar = true
                }
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
                
                Button("Voir tout") {
                    navigateToDocuments = true
                }
                .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                .foregroundColor(.blue)
            }
            
            if recentDocuments.isEmpty {
                emptyDocumentsView(geometry: geometry)
            } else {
                VStack(spacing: geometry.size.height * 0.01) {
                    ForEach(Array(recentDocuments.prefix(3)), id: \.id) { document in
                        Button(action: { navigateToDocuments = true }) {
                            documentRow(document: document, geometry: geometry)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    // MARK: - Document Row
    private func documentRow(document: Document, geometry: GeometryProxy) -> some View {
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
                    .foregroundColor(.white)
                    .padding(.horizontal, geometry.size.width * 0.02)
                    .padding(.vertical, geometry.size.height * 0.005)
                    .background(
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.015)
                            .fill(Color.green)
                    )
            }
        }
        .padding(.vertical, geometry.size.height * 0.01)
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
            
            Button("Ajouter un document") {
                showingAddDocument = true
            }
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
    
    private func relativeDateText(_ date: Date) -> String {
        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: Date(), to: date).day ?? 0
        
        if daysDifference == 0 {
            return "Aujourd'hui"
        } else if daysDifference == 1 {
            return "Demain"
        } else if daysDifference > 1 && daysDifference <= 7 {
            return "Dans \(daysDifference) jours"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM"
            return formatter.string(from: date)
        }
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
    
    private var displayName: String {
        if let firstName = authViewModel.currentUser?.firstName, !firstName.isEmpty {
            return firstName
        }
        return "Utilisateur"
    }
    
    private var userInitials: String {
        let firstName = authViewModel.currentUser?.firstName ?? ""
        let lastName = authViewModel.currentUser?.lastName ?? ""
        let firstInitial = firstName.first?.uppercased() ?? "U"
        let lastInitial = lastName.first?.uppercased() ?? "S"
        return "\(firstInitial)\(lastInitial)"
    }
    
    private var upcomingEvents: [Event] {
        let now = Date()
        return eventsViewModel.events
            .filter { $0.startDate >= now }
            .sorted { $0.startDate < $1.startDate }
    }
    
    private var upcomingEventsCount: Int {
        upcomingEvents.count
    }
    
    private var recentDocuments: [Document] {
        documentsViewModel.documents
            .sorted { $0.createdAt > $1.createdAt }
    }
}

// MARK: - Preview
#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ChildrenViewModel(childrenService: MockChildrenService()))
            .environmentObject(EventsViewModel(eventsService: MockEventsService()))
            .environmentObject(DocumentsViewModel(documentsService: MockDocumentsService()))
            .environmentObject(AuthViewModel(authService: MockAuthService()))
    }
}
#endif