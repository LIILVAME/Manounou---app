//
//  MainTabView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI
import Foundation
import Supabase
import UserNotifications

// MARK: - Main Tab View

struct MainTabView: View {
    @StateObject private var authManager = AuthManager()
    @StateObject private var eventsViewModel = EventsViewModel()
    @StateObject private var childrenViewModel = ChildrenViewModel()
    @StateObject private var cacheManager = CacheManager()
    @StateObject private var memoryManager = MemoryManager()
    @StateObject private var errorManager = ErrorManager()
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
            CalendarView()
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
                .environmentObject(cacheManager)
                .environmentObject(memoryManager)
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Paramètres")
                }
        }
        .environmentObject(authManager)
        .environmentObject(eventsViewModel)
        .environmentObject(childrenViewModel)
        .environmentObject(cacheManager)
        .environmentObject(memoryManager)
        .environmentObject(errorManager)
        .environmentObject(notificationManager)
        .alert("Erreur", isPresented: .constant(errorManager.currentError != nil)) {
            Button("OK") {
                errorManager.clearError()
            }
        } message: {
            if let error = errorManager.currentError {
                Text(error.localizedDescription)
            }
        }
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
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showingAddDocument = false
    @State private var showingInviteFamily = false
    @State private var isRefreshing = false
    @State private var showingToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        NavigationView {
            if authManager.isLoading {
                ProgressView("Chargement...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !authManager.isAuthenticated {
                AuthenticationView()
                    .environmentObject(authManager)
            } else {
                ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Bonjour \(authManager.userProfile?.firstName ?? "Utilisateur") !")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
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
                        .padding(.horizontal)
                    }
                    
                    // Quick Actions
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        QuickActionCard(
                            title: "Ajouter un enfant",
                            icon: "plus.circle.fill",
                            color: .blue
                        ) {
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            childrenViewModel.showAddChild()
                        }
                        
                        QuickActionCard(
                            title: "Nouveau document",
                            icon: "doc.badge.plus",
                            color: .green
                        ) {
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            showingAddDocument = true
                        }
                        
                        QuickActionCard(
                            title: "Ajouter un événement",
                            icon: "calendar.badge.plus",
                            color: .orange
                        ) {
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            eventsViewModel.showAddEvent()
                        }
                        
                        QuickActionCard(
                            title: "Inviter la famille",
                            icon: "person.2.fill",
                            color: .purple
                        ) {
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            showingInviteFamily = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // Family Overview
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Votre famille")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            // Children Count Card
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "figure.2.and.child.holdinghands")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                    
                                    Spacer()
                                }
                                
                                Text("\(childrenViewModel.children.count)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text(childrenViewModel.children.count <= 1 ? "enfant" : "enfants")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Events Count Card
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.title2)
                                        .foregroundColor(.orange)
                                    
                                    Spacer()
                                }
                                
                                Text("\(eventsViewModel.events.count)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("à venir")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Upcoming Events
                    if !eventsViewModel.events.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Prochains événements")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button("Voir tout") {
                                    // Switch to calendar tab
                                }
                                .font(.footnote)
                                .foregroundColor(.pink)
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(eventsViewModel.events.prefix(3), id: \.id) { event in
                                    UpcomingEventRow(event: event)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .refreshable {
                await refreshData()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            }
        }
        .sheet(isPresented: $childrenViewModel.showingAddChild) {
            AddChildView { firstName, lastName, dateOfBirth, gender in
                Task {
                    await childrenViewModel.addChild(
                        firstName: firstName,
                        lastName: lastName,
                        dateOfBirth: dateOfBirth,
                        gender: gender
                    )
                }
            }
        }
        .sheet(isPresented: $showingAddDocument) {
            AddDocumentView()
        }
        .sheet(isPresented: $eventsViewModel.showingAddEvent) {
            SimpleAddEventView { title, description, eventType, startDate, endDate, childId in
                Task {
                    await eventsViewModel.addEvent(
                        title: title,
                        description: description,
                        eventType: eventType,
                        startDate: startDate,
                        endDate: endDate,
                        childId: childId,
                        notificationManager: notificationManager
                    )
                }
            }
        }
        .sheet(isPresented: $showingInviteFamily) {
            InviteFamilyView()
        }
        .task {
            // Load data only if user is authenticated
            if authManager.isAuthenticated {
                await childrenViewModel.loadChildren()
                await eventsViewModel.loadEvents()
            }
        }
        .overlay(
            // Toast message
            VStack {
                Spacer()
                if showingToast {
                    Text(toastMessage)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showingToast = false
                                }
                            }
                        }
                }
            }
            .padding(.bottom, 100)
        )
    }
    
    // MARK: - Functions
    private func refreshData() async {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Refresh data only if user is authenticated
        if authManager.isAuthenticated {
            await childrenViewModel.loadChildren()
            await eventsViewModel.loadEvents()
            showToast("Données mises à jour")
        } else {
            showToast("Veuillez vous connecter")
        }
    }
    
    private func showToast(_ message: String) {
        toastMessage = message
        withAnimation(.easeInOut(duration: 0.3)) {
            showingToast = true
        }
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Upcoming Event Row
struct UpcomingEventRow: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 12) {
            // Event Type Icon
            Circle()
                .fill(event.eventType.color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: event.eventType.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(event.eventType.color)
                }
            
            // Event Details
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(event.eventType.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(formatEventDate(event.startDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Time
            Text(formatEventTime(event.startDate))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(event.eventType.color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private func formatEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
    
    private func formatEventTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

// MARK: - Add Child View
struct AddChildView: View {
    let onSave: (String, String, Date, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Date()
    @State private var gender = "Autre"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations de l'enfant") {
                    TextField("Prénom", text: $firstName)
                    TextField("Nom", text: $lastName)
                    DatePicker("Date de naissance", selection: $dateOfBirth, displayedComponents: .date)
                    Picker("Genre", selection: $gender) {
                        Text("Fille").tag("Fille")
                        Text("Garçon").tag("Garçon")
                        Text("Autre").tag("Autre")
                    }
                }
            }
            .navigationTitle("Ajouter un enfant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        onSave(firstName, lastName, dateOfBirth, gender)
                        dismiss()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Add Document View
struct AddDocumentView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Fonctionnalité à venir")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
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

// MARK: - Simple Add Event View
struct SimpleAddEventView: View {
    let onSave: (String, String?, EventType, Date, Date, UUID?) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var eventType = EventType(name: "Général", color: .blue, icon: "calendar")
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    
    let eventTypes = [
        EventType(name: "Général", color: .blue, icon: "calendar"),
        EventType(name: "Médical", color: .red, icon: "cross.fill"),
        EventType(name: "École", color: .green, icon: "graduationcap.fill"),
        EventType(name: "Activité", color: .orange, icon: "figure.run")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Détails de l'événement") {
                    TextField("Titre", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    Picker("Type", selection: $eventType) {
                        ForEach(eventTypes, id: \.name) { type in
                            Text(type.name).tag(type)
                        }
                    }
                }
                
                Section("Horaires") {
                    DatePicker("Début", selection: $startDate)
                    DatePicker("Fin", selection: $endDate)
                }
            }
            .navigationTitle("Nouvel événement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        onSave(title, description.isEmpty ? nil : description, eventType, startDate, endDate, nil)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// MARK: - Invite Family View
struct InviteFamilyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Fonctionnalité à venir")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
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

// MARK: - Calendar View

enum CalendarViewType: String, CaseIterable {
    case month = "month"
    case week = "week"
    case day = "day"
    case agenda = "agenda"
    
    var displayName: String {
        switch self {
        case .month: return "Mois"
        case .week: return "Semaine"
        case .day: return "Jour"
        case .agenda: return "Agenda"
        }
    }
    
    var icon: String {
        switch self {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.left"
        case .day: return "calendar.day.timeline.leading"
        case .agenda: return "list.bullet.clipboard"
        }
    }
}

struct CalendarView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var selectedViewType: CalendarViewType = .month
    @State private var selectedDate = Date()
    @State private var showingAddEvent = false
    
    @State private var eventsSheetOffset: CGFloat = 100
    @State private var isEventsSheetExpanded = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Contenu principal du calendrier
                VStack(spacing: 0) {
                    // Sélecteur de vue
                    HStack(spacing: 0) {
                        ForEach([CalendarViewType.day, .week, .month], id: \.self) { viewType in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedViewType = viewType
                                }
                            } label: {
                                Text(viewType.displayName)
                                    .font(.system(size: 15, weight: selectedViewType == viewType ? .semibold : .medium))
                                    .foregroundColor(selectedViewType == viewType ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedViewType == viewType ? Color.blue : Color.clear)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Zone de contenu principal
                    Group {
                        switch selectedViewType {
                        case .month:
                            MonthCalendarView(selectedDate: $selectedDate, events: eventsViewModel.events)
                        case .week:
                            WeekCalendarView(selectedDate: $selectedDate, events: eventsViewModel.events)
                        case .day:
                            DayCalendarView(selectedDate: $selectedDate, events: eventsViewModel.events)
                        case .agenda:
                            AgendaCalendarView(events: eventsViewModel.events)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Spacer()
                }
                
                // Bottom Sheet pour les événements
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Handle de glissement amélioré
                        VStack(spacing: 0) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(.systemGray3))
                                .frame(width: 50, height: 5)
                                .padding(.top, 8)
                                .padding(.bottom, 12)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        
                        // En-tête de la section événements avec bouton flottant
                        HStack(alignment: .center, spacing: 16) {
                            Text("Événements")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Text("\(eventsViewModel.events.count)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.blue.opacity(0.8))
                                    )
                                
                                Button(action: { showingAddEvent = true }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(Color.blue)
                                                .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
                                        )
                                }
                                .scaleEffect(1.0)
                                .animation(.easeInOut(duration: 0.1), value: isEventsSheetExpanded)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        
                        // Contenu des événements
                        if eventsViewModel.events.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue.opacity(0.6))
                                
                                Text("Aucun événement")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("Ajoutez votre premier événement")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .padding(.horizontal, 20)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 6) {
                                    ForEach(eventsViewModel.events, id: \.id) { event in
                                        EventRowView(event: event)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 2)
                                    }
                                }
                                .padding(.top, 4)
                                .padding(.bottom, 12)
                            }
                            .frame(maxHeight: isEventsSheetExpanded ? .infinity : 120)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                    )
                    .offset(y: eventsSheetOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newOffset = eventsSheetOffset + value.translation.height
                                let minOffset: CGFloat = 50
                                let maxOffset: CGFloat = 100
                                
                                eventsSheetOffset = max(minOffset, min(maxOffset, newOffset))
                            }
                            .onEnded { value in
                                let velocity = value.translation.height
                                let threshold: CGFloat = 20
                                
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.3)) {
                                    if velocity > threshold {
                                        // Glissement vers le bas - Position ancrée
                                        eventsSheetOffset = 100
                                        isEventsSheetExpanded = false
                                    } else {
                                        // Glissement vers le haut - Ouvrir complètement
                                        eventsSheetOffset = 50
                                        isEventsSheetExpanded = true
                                    }
                                }
                            }
                    )
                }
            }
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView { title, description, eventType, startDate, endDate, childId in
                Task {
                    await eventsViewModel.createEvent(
                        title: title,
                        description: description,
                        eventType: eventType,
                        startDate: startDate,
                        endDate: endDate,
                        childId: childId,
                        recurrenceRule: nil
                    )
                }
            }
            .environmentObject(childrenViewModel)
        }
        .onAppear {
            Task {
                await eventsViewModel.loadEvents()
            }
        }
    }
}

// MARK: - Supporting Views

struct EventRowView: View {
    let event: Event
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.eventType.color)
                .frame(width: 4, height: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Image(systemName: event.eventType.icon)
                        .foregroundColor(event.eventType.color)
                    Text(event.eventType.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(timeFormatter.string(from: event.startDate))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

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
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
            )
        }
    }
}

// MARK: - Placeholder Views

struct ChildrenView: View {
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @State private var showingAddChild = false
    @State private var showingEditChild = false
    @State private var childToEdit: Child?
    
    var body: some View {
        NavigationView {
            Group {
                if childrenViewModel.children.isEmpty {
                    // État vide
                    VStack(spacing: 30) {
                        Image(systemName: "figure.2.and.child.holdinghands")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Aucun enfant")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Ajoutez votre premier enfant pour commencer à organiser votre famille")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: { showingAddChild = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Ajouter un enfant")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Liste des enfants
                    List {
                        ForEach(childrenViewModel.children, id: \.id) { child in
                            ChildRowView(child: child) {
                                childToEdit = child
                                showingEditChild = true
                            }
                        }
                        .onDelete(perform: deleteChildren)
                    }
                    .refreshable {
                        await childrenViewModel.loadChildren()
                    }
                }
            }
            .navigationTitle("Enfants")
            .toolbar {
                if !childrenViewModel.children.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddChild = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .overlay {
                if childrenViewModel.isLoading {
                    ProgressView("Chargement...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        }
        .sheet(isPresented: $showingAddChild) {
            AddChildView { firstName, lastName, dateOfBirth, gender in
                Task {
                    await childrenViewModel.addChild(
                        firstName: firstName,
                        lastName: lastName,
                        dateOfBirth: dateOfBirth,
                        gender: gender
                    )
                }
            }
        }
        .sheet(isPresented: $showingEditChild) {
            if let child = childToEdit {
                EditChildView(child: child) { firstName, lastName, dateOfBirth, gender in
                    Task {
                        await childrenViewModel.updateChild(
                            child,
                            firstName: firstName,
                            lastName: lastName,
                            dateOfBirth: dateOfBirth,
                            gender: gender
                        )
                    }
                    childToEdit = nil
                }
            }
        }
        .alert("Erreur", isPresented: .constant(childrenViewModel.errorMessage != nil)) {
            Button("OK") {
                childrenViewModel.dismissError()
            }
        } message: {
            if let errorMessage = childrenViewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .task {
            await childrenViewModel.loadChildren()
        }
    }
    
    private func deleteChildren(offsets: IndexSet) {
        for index in offsets {
            let child = childrenViewModel.children[index]
            Task {
                await childrenViewModel.deleteChild(child)
            }
        }
    }
}

struct DocumentsView: View {
    @StateObject private var documentsViewModel = DocumentsViewModel()
    @State private var showingAddDocument = false
    @State private var showingEditDocument = false
    @State private var documentToEdit: Document?
    @State private var selectedCategory: DocumentType = .all
    
    var filteredDocuments: [Document] {
        if selectedCategory == .all {
            return documentsViewModel.documents
        }
        return documentsViewModel.documents.filter { $0.type == selectedCategory }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filtre par catégorie
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach([DocumentType.all] + DocumentType.allCases.filter { $0 != .all }, id: \.self) { category in
                            CategoryFilterButton(
                                category: category,
                                isSelected: selectedCategory == category,
                                count: category == .all ? documentsViewModel.documents.count : documentsViewModel.documents.filter { $0.type == category }.count
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                
                // Contenu principal
                Group {
                    if documentsViewModel.documents.isEmpty {
                        // État vide
                        VStack(spacing: 30) {
                            Image(systemName: "doc.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("Aucun document")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Stockez vos documents importants pour votre famille en toute sécurité")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: { showingAddDocument = true }) {
                                HStack {
                                    Image(systemName: "doc.badge.plus")
                                    Text("Ajouter un document")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredDocuments.isEmpty {
                        // Aucun résultat pour la catégorie
                        VStack(spacing: 20) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("Aucun document dans cette catégorie")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Ajoutez des documents ou changez de catégorie")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Liste des documents
                        List {
                            ForEach(filteredDocuments, id: \.id) { document in
                                DocumentRowView(document: document) {
                                    documentToEdit = document
                                    showingEditDocument = true
                                }
                            }
                            .onDelete(perform: deleteDocuments)
                        }
                        .refreshable {
                            await documentsViewModel.loadDocuments()
                        }
                    }
                }
            }
            .navigationTitle("Documents")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddDocument = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .overlay {
                if documentsViewModel.isLoading {
                    ProgressView("Chargement...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        }
        .sheet(isPresented: $showingAddDocument) {
            AddDocumentView { title, description, type in
                Task {
                    await documentsViewModel.addDocument(
                        title: title,
                        description: description,
                        type: type
                    )
                }
            }
        }
        .sheet(isPresented: $showingEditDocument) {
            if let document = documentToEdit {
                EditDocumentView(document: document) { title, description, type in
                    Task {
                        await documentsViewModel.updateDocument(
                            document,
                            title: title,
                            description: description,
                            type: type
                        )
                    }
                    documentToEdit = nil
                }
            }
        }
        .alert("Erreur", isPresented: .constant(documentsViewModel.errorMessage != nil)) {
            Button("OK") {
                documentsViewModel.dismissError()
            }
        } message: {
            if let errorMessage = documentsViewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .task {
            await documentsViewModel.loadDocuments()
        }
    }
    
    private func deleteDocuments(offsets: IndexSet) {
        for index in offsets {
            let document = filteredDocuments[index]
            Task {
                await documentsViewModel.deleteDocument(document)
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var cacheManager: CacheManager
    @EnvironmentObject var memoryManager: MemoryManager
    @State private var showingEditProfile = false
    @State private var showingAbout = false
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var biometricEnabled = false
    
    var body: some View {
        NavigationView {
            List {
                // Section Profil
                Section {
                    HStack(spacing: 16) {
                        // Avatar
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay {
                                if let user = authManager.currentUser {
                                    Text(String(user.email?.prefix(1).uppercased() ?? "U"))
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                }
                            }
                        
                        // Informations utilisateur
                        VStack(alignment: .leading, spacing: 4) {
                            if let profile = authManager.userProfile {
                                Text("\(profile.firstName) \(profile.lastName)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text(profile.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else if let user = authManager.currentUser {
                                Text(user.email ?? "Utilisateur")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("Profil non configuré")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Non connecté")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Bouton d'édition
                        Button(action: { showingEditProfile = true }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Profil")
                }
                
                // Section Notifications
                Section {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Notifications")
                        
                        Spacer()
                        
                        Toggle("", isOn: $notificationsEnabled)
                    }
                    
                    if notificationsEnabled {
                        NavigationLink(destination: NotificationSettingsView()) {
                            HStack {
                                Image(systemName: "gear")
                                    .foregroundColor(.gray)
                                    .frame(width: 24)
                                
                                Text("Configurer les notifications")
                            }
                        }
                    }
                } header: {
                    Text("Notifications")
                }
                
                // Section Apparence
                Section {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        
                        Text("Mode sombre")
                        
                        Spacer()
                        
                        Toggle("", isOn: $darkModeEnabled)
                    }
                } header: {
                    Text("Apparence")
                }
                
                // Section Sécurité
                Section {
                    HStack {
                        Image(systemName: "faceid")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text("Authentification biométrique")
                        
                        Spacer()
                        
                        Toggle("", isOn: $biometricEnabled)
                    }
                    
                    NavigationLink(destination: SecuritySettingsView()) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("Sécurité et confidentialité")
                        }
                    }
                } header: {
                    Text("Sécurité")
                }
                
                // Section Stockage
                Section {
                    HStack {
                        Image(systemName: "internaldrive.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Stockage utilisé")
                            Text("2.3 GB sur 5 GB")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Gérer") {
                            // Action pour gérer le stockage
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("Vider le cache")
                                .foregroundColor(.primary)
                        }
                    }
                } header: {
                    Text("Stockage")
                }
                
                // Section Support
                Section {
                    NavigationLink(destination: HelpView()) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Aide et support")
                        }
                    }
                    
                    Button(action: { showingAbout = true }) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            
                            Text("À propos")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            Text("Politique de confidentialité")
                        }
                    }
                } header: {
                    Text("Support")
                }
                
                // Section Déconnexion
                Section {
                    Button(action: {
                        Task {
                            await authManager.signOut()
                        }
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("Se déconnecter")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Paramètres")
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}

struct AddEventView: View {
    let onSave: (String, String, EventType, Date, Date, String?) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedEventType: EventType = EventType(name: "Général", color: .blue, icon: "calendar")
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600) // +1 heure
    @State private var selectedChild: Child?
    @State private var isAllDay = false
    @State private var hasReminder = true
    @State private var reminderTime: ReminderTime = .fifteenMinutes
    @State private var isLoading = false
    
    let eventTypes = [
        EventType(name: "Général", color: .blue, icon: "calendar"),
        EventType(name: "Médical", color: .red, icon: "cross.fill"),
        EventType(name: "École", color: .green, icon: "graduationcap.fill"),
        EventType(name: "Activité", color: .orange, icon: "figure.run"),
        EventType(name: "Repas", color: .purple, icon: "fork.knife"),
        EventType(name: "Sommeil", color: .indigo, icon: "moon.fill"),
        EventType(name: "Autre", color: .gray, icon: "ellipsis.circle.fill")
    ]
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && endDate > startDate
    }
    
    var body: some View {
        NavigationView {
            Form {
                eventInfoSection
                dateTimeSection
                childSection
                reminderSection
            }
            .navigationTitle("Nouvel événement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        saveEvent()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Création en cours...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        }
        .onChange(of: isAllDay) { newValue in
            if newValue {
                let calendar = Calendar.current
                startDate = calendar.startOfDay(for: startDate)
                endDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate)) ?? endDate
            }
        }
        .onChange(of: startDate) { newValue in
            if endDate <= newValue {
                endDate = isAllDay ? 
                    Calendar.current.date(byAdding: .day, value: 1, to: newValue) ?? newValue :
                    newValue.addingTimeInterval(3600)
            }
        }
    }
    
    private var eventInfoSection: some View {
        Section("Informations de l'événement") {
            TextField("Titre", text: $title)
                .textContentType(.none)
            
            TextField("Description (optionnel)", text: $description, axis: .vertical)
                .lineLimit(3...6)
            
            Picker("Type d'événement", selection: $selectedEventType) {
                ForEach(eventTypes, id: \.name) { eventType in
                    HStack {
                        Image(systemName: eventType.icon)
                            .foregroundColor(eventType.color)
                        Text(eventType.name)
                    }
                    .tag(eventType)
                }
            }
        }
    }
    
    private var dateTimeSection: some View {
        Section("Date et heure") {
            Toggle("Toute la journée", isOn: $isAllDay)
            
            if isAllDay {
                DatePicker(
                    "Date de début",
                    selection: $startDate,
                    displayedComponents: .date
                )
                
                DatePicker(
                    "Date de fin",
                    selection: $endDate,
                    in: startDate...,
                    displayedComponents: .date
                )
            } else {
                DatePicker(
                    "Début",
                    selection: $startDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                
                DatePicker(
                    "Fin",
                    selection: $endDate,
                    in: startDate...,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
        }
    }
    
    private var childSection: some View {
        Section("Enfant concerné") {
            Picker("Sélectionner un enfant", selection: $selectedChild) {
                Text("Aucun enfant spécifique").tag(nil as Child?)
                ForEach(childrenViewModel.children, id: \.id) { child in
                    Text("\(child.firstName) \(child.lastName)").tag(child as Child?)
                }
            }
        }
    }
    
    private var reminderSection: some View {
        Section("Rappel") {
            Toggle("Activer le rappel", isOn: $hasReminder)
            
            if hasReminder {
                Picker("Temps avant l'événement", selection: $reminderTime) {
                    ForEach(ReminderTime.allCases, id: \.self) { time in
                        Text(time.displayName).tag(time)
                    }
                }
            }
        }
    }
    
    private func saveEvent() {
        isLoading = true
        
        onSave(
            title.trimmingCharacters(in: .whitespaces),
            description.trimmingCharacters(in: .whitespaces),
            selectedEventType,
            startDate,
            endDate,
            selectedChild?.id.uuidString
        )
        
        dismiss()
    }
}

// MARK: - Temporary Models

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let description: String?
    let startDate: Date
    let endDate: Date
    let eventType: EventType
    let childId: String?
}

struct EventType: Hashable {
    let id = UUID()
    let name: String
    let color: Color
    let icon: String
    
    var displayName: String { name }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: EventType, rhs: EventType) -> Bool {
        lhs.name == rhs.name
    }
}

struct Child: Identifiable, Hashable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let birthDate: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Child, rhs: Child) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Settings Support Views

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations personnelles") {
                    TextField("Prénom", text: $firstName)
                        .textContentType(.givenName)
                    
                    TextField("Nom", text: $lastName)
                        .textContentType(.familyName)
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Modifier le profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        saveProfile()
                    }
                    .disabled(isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Enregistrement...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        }
        .onAppear {
            loadCurrentProfile()
        }
    }
    
    private func loadCurrentProfile() {
        if let profile = authManager.userProfile {
            firstName = profile.firstName
            lastName = profile.lastName
            email = profile.email
        } else if let user = authManager.currentUser {
            email = user.email ?? ""
        }
    }
    
    private func saveProfile() {
        isLoading = true
        
        Task {
            await authManager.updateUserProfile(
                firstName: firstName,
                lastName: lastName,
                email: email
            )
            
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        }
    }
}

struct NotificationSettingsView: View {
    @State private var eventsNotifications = true
    @State private var remindersNotifications = true
    @State private var documentsNotifications = false
    @State private var marketingNotifications = false
    
    var body: some View {
        Form {
            Section("Notifications de l'application") {
                Toggle("Événements", isOn: $eventsNotifications)
                Toggle("Rappels", isOn: $remindersNotifications)
                Toggle("Documents", isOn: $documentsNotifications)
            }
            
            Section("Communications") {
                Toggle("Offres et nouveautés", isOn: $marketingNotifications)
            }
            
            Section("Paramètres système") {
                Button("Ouvrir les paramètres iOS") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SecuritySettingsView: View {
    @State private var autoLockEnabled = true
    @State private var autoLockTime = 5
    @State private var dataEncryptionEnabled = true
    
    let autoLockOptions = [1, 5, 15, 30, 60]
    
    var body: some View {
        Form {
            Section("Verrouillage automatique") {
                Toggle("Activer le verrouillage", isOn: $autoLockEnabled)
                
                if autoLockEnabled {
                    Picker("Délai de verrouillage", selection: $autoLockTime) {
                        ForEach(autoLockOptions, id: \.self) { minutes in
                            Text("\(minutes) min").tag(minutes)
                        }
                    }
                }
            }
            
            Section("Chiffrement des données") {
                Toggle("Chiffrer les données locales", isOn: $dataEncryptionEnabled)
            }
            
            Section("Actions") {
                Button("Changer le mot de passe") {
                    // Action pour changer le mot de passe
                }
                
                Button("Supprimer le compte", role: .destructive) {
                    // Action pour supprimer le compte
                }
            }
        }
        .navigationTitle("Sécurité")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpView: View {
    var body: some View {
        List {
            Section("Questions fréquentes") {
                NavigationLink("Comment ajouter un enfant ?") {
                    FAQDetailView(question: "Comment ajouter un enfant ?", answer: "Pour ajouter un enfant, rendez-vous dans l'onglet Enfants et appuyez sur le bouton +. Remplissez les informations demandées et validez.")
                }
                
                NavigationLink("Comment gérer les documents ?") {
                    FAQDetailView(question: "Comment gérer les documents ?", answer: "Dans l'onglet Documents, vous pouvez ajouter, organiser et consulter tous vos documents importants par catégorie.")
                }
                
                NavigationLink("Comment configurer les notifications ?") {
                    FAQDetailView(question: "Comment configurer les notifications ?", answer: "Allez dans Paramètres > Notifications pour personnaliser vos préférences de notification.")
                }
            }
            
            Section("Contact") {
                Button("Envoyer un email de support") {
                    if let url = URL(string: "mailto:support@manounou.app") {
                        UIApplication.shared.open(url)
                    }
                }
                
                Button("Signaler un problème") {
                    // Action pour signaler un problème
                }
            }
        }
        .navigationTitle("Aide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FAQDetailView: View {
    let question: String
    let answer: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(question)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(answer)
                    .font(.body)
                    .lineSpacing(4)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo et nom de l'app
                    VStack(spacing: 16) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.pink)
                        
                        Text("Manounou")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("À propos de Manounou")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Manounou est votre assistant personnel pour organiser la vie de famille. Gérez vos enfants, vos documents et vos événements en toute simplicité.")
                            .font(.body)
                            .lineSpacing(4)
                    }
                    
                    // Informations légales
                    VStack(spacing: 8) {
                        Text("© 2024 Manounou. Tous droits réservés.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Développé avec ❤️ pour les familles")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("À propos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        // Fermer la vue
                    }
                }
            }
        }
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Politique de confidentialité")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Dernière mise à jour : 16 août 2024")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Group {
                    Text("1. Collecte des données")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Nous collectons uniquement les données nécessaires au fonctionnement de l'application : informations de profil, données des enfants et documents que vous choisissez de stocker.")
                        .font(.body)
                        .lineSpacing(4)
                    
                    Text("2. Utilisation des données")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Vos données sont utilisées exclusivement pour vous fournir les services de l'application. Nous ne vendons ni ne partageons vos données personnelles avec des tiers.")
                        .font(.body)
                        .lineSpacing(4)
                    
                    Text("3. Sécurité")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Nous mettons en œuvre des mesures de sécurité appropriées pour protéger vos données contre tout accès non autorisé, modification ou suppression.")
                        .font(.body)
                        .lineSpacing(4)
                }
            }
            .padding()
        }
        .navigationTitle("Confidentialité")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Document Management Models

struct Document: Identifiable {
    let id = UUID()
    let title: String
    let description: String?
    let type: DocumentType
    let dateAdded: Date
    let fileURL: URL?
    let fileSize: Int64?
}

enum DocumentType: String, CaseIterable {
    case all = "all"
    case medical = "medical"
    case school = "school"
    case administrative = "administrative"
    case insurance = "insurance"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .all: return "Tous"
        case .medical: return "Médical"
        case .school: return "École"
        case .administrative: return "Administratif"
        case .insurance: return "Assurance"
        case .other: return "Autre"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "doc.fill"
        case .medical: return "cross.fill"
        case .school: return "graduationcap.fill"
        case .administrative: return "building.2.fill"
        case .insurance: return "shield.fill"
        case .other: return "folder.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .gray
        case .medical: return .red
        case .school: return .blue
        case .administrative: return .orange
        case .insurance: return .green
        case .other: return .purple
        }
    }
}

// MARK: - Document Management Views

struct CategoryFilterButton: View {
    let category: DocumentType
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.caption)
                
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? category.color : .white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? .white : category.color)
                        )
                }
            }
            .foregroundColor(isSelected ? .white : category.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? category.color : category.color.opacity(0.1))
            )
        }
    }
}

struct DocumentRowView: View {
    let document: Document
    let onEdit: () -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 16) {
            // Icône du type de document
            RoundedRectangle(cornerRadius: 8)
                .fill(document.type.color.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: document.type.icon)
                        .font(.title2)
                        .foregroundColor(document.type.color)
                }
            
            // Informations du document
            VStack(alignment: .leading, spacing: 4) {
                Text(document.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                if let description = document.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(document.type.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(document.type.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(document.type.color.opacity(0.1))
                        )
                    
                    Text(dateFormatter.string(from: document.dateAdded))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Bouton d'édition
            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
    }
}


struct EditChildView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String
    @State private var lastName: String
    @State private var dateOfBirth: Date
    @State private var selectedGender: Gender?
    @State private var isLoading = false
    
    let child: Child
    let onSave: (String, String, Date, String?) -> Void
    
    init(child: Child, onSave: @escaping (String, String, Date, String?) -> Void) {
        self.child = child
        self.onSave = onSave
        self._firstName = State(initialValue: child.firstName)
        self._lastName = State(initialValue: child.lastName)
        self._dateOfBirth = State(initialValue: child.birthDate)
        self._selectedGender = State(initialValue: nil) // TODO: Ajouter gender au modèle Child
    }
    
    var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations de l'enfant") {
                    TextField("Prénom", text: $firstName)
                        .textContentType(.givenName)
                    
                    TextField("Nom", text: $lastName)
                        .textContentType(.familyName)
                    
                    DatePicker(
                        "Date de naissance",
                        selection: $dateOfBirth,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    
                    Picker("Genre", selection: $selectedGender) {
                        Text("Non spécifié").tag(nil as Gender?)
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.displayName).tag(gender as Gender?)
                        }
                    }
                }
            }
            .navigationTitle("Modifier l'enfant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        saveChild()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Modification en cours...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        }
    }
    
    private func saveChild() {
        isLoading = true
        
        onSave(
            firstName.trimmingCharacters(in: .whitespaces),
            lastName.trimmingCharacters(in: .whitespaces),
            dateOfBirth,
            selectedGender?.rawValue
        )
        
        dismiss()
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
}

enum ReminderTime: String, CaseIterable {
    case none = "none"
    case atTime = "at_time"
    case fiveMinutes = "5_minutes"
    case fifteenMinutes = "15_minutes"
    case thirtyMinutes = "30_minutes"
    case oneHour = "1_hour"
    case oneDay = "1_day"
    
    var displayName: String {
        switch self {
        case .none: return "Aucun rappel"
        case .atTime: return "À l'heure de l'événement"
        case .fiveMinutes: return "5 minutes avant"
        case .fifteenMinutes: return "15 minutes avant"
        case .thirtyMinutes: return "30 minutes avant"
        case .oneHour: return "1 heure avant"
        case .oneDay: return "1 jour avant"
        }
    }
    
    var timeInterval: TimeInterval {
        switch self {
        case .none: return 0
        case .atTime: return 0
        case .fiveMinutes: return -300
        case .fifteenMinutes: return -900
        case .thirtyMinutes: return -1800
        case .oneHour: return -3600
        case .oneDay: return -86400
        }
    }
}

// MARK: - Temporary ViewModels

class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var showingAddEvent = false
    
    func loadEvents() async {
        await MainActor.run {
            isLoading = true
        }
        
        // Simulation de chargement
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            // Données de test
            events = [
                Event(
                    title: "Rendez-vous médecin",
                    description: "Visite de contrôle",
                    startDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                    endDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())?.addingTimeInterval(3600) ?? Date(),
                    eventType: EventType(name: "Médical", color: .red, icon: "cross.fill"),
                    childId: nil
                ),
                Event(
                    title: "École",
                    description: "Réunion parents-professeurs",
                    startDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                    endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())?.addingTimeInterval(7200) ?? Date(),
                    eventType: EventType(name: "École", color: .green, icon: "graduationcap.fill"),
                    childId: nil
                )
            ]
            isLoading = false
        }
    }
    
    func showAddEvent() {
        showingAddEvent = true
    }
    
    func addEvent(title: String, description: String?, eventType: EventType, startDate: Date, endDate: Date, childId: UUID?, notificationManager: NotificationManager) async {
        let newEvent = Event(
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            eventType: eventType,
            childId: childId?.uuidString
        )
        
        await MainActor.run {
            events.append(newEvent)
            showingAddEvent = false
        }
    }
    
    func createEvent(title: String, description: String, eventType: EventType, startDate: Date, endDate: Date, childId: String?, recurrenceRule: String?) async {
        let newEvent = Event(
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            eventType: eventType,
            childId: childId
        )
        
        await MainActor.run {
            events.append(newEvent)
        }
    }
}

class DocumentsViewModel: ObservableObject {
    @Published var documents: [Document] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadDocuments() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulation de chargement
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            // Données de test
            documents = [
                Document(
                    title: "Carnet de santé Emma",
                    description: "Carnet de santé complet avec vaccinations",
                    type: .medical,
                    dateAdded: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
                    fileURL: nil,
                    fileSize: nil
                ),
                Document(
                    title: "Certificat de scolarité",
                    description: "Certificat pour l'année scolaire 2024-2025",
                    type: .school,
                    dateAdded: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
                    fileURL: nil,
                    fileSize: nil
                ),
                Document(
                    title: "Assurance responsabilité civile",
                    description: "Police d'assurance famille",
                    type: .insurance,
                    dateAdded: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                    fileURL: nil,
                    fileSize: nil
                )
            ]
            isLoading = false
        }
    }
    
    func addDocument(title: String, description: String, type: DocumentType) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulation d'ajout
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            let newDocument = Document(
                title: title,
                description: description.isEmpty ? nil : description,
                type: type,
                dateAdded: Date(),
                fileURL: nil,
                fileSize: nil
            )
            documents.append(newDocument)
            isLoading = false
        }
    }
    
    func updateDocument(_ document: Document, title: String, description: String, type: DocumentType) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulation de mise à jour
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            if let index = documents.firstIndex(where: { $0.id == document.id }) {
                documents[index] = Document(
                    title: title,
                    description: description.isEmpty ? nil : description,
                    type: type,
                    dateAdded: document.dateAdded,
                    fileURL: document.fileURL,
                    fileSize: document.fileSize
                )
            }
            isLoading = false
        }
    }
    
    func deleteDocument(_ document: Document) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulation de suppression
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            documents.removeAll { $0.id == document.id }
            isLoading = false
        }
    }
    
    func dismissError() {
        errorMessage = nil
    }
}

class ChildrenViewModel: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddChild = false
    
    func loadChildren() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulation de chargement
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            // Données de test
            children = [
                Child(firstName: "Emma", lastName: "Dupont", birthDate: Calendar.current.date(byAdding: .year, value: -5, to: Date()) ?? Date()),
                Child(firstName: "Lucas", lastName: "Martin", birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date())
            ]
            isLoading = false
        }
    }
    
    func showAddChild() {
        showingAddChild = true
    }
    
    func addChild(firstName: String, lastName: String, dateOfBirth: Date, gender: String) async {
        let newChild = Child(firstName: firstName, lastName: lastName, birthDate: dateOfBirth)
        
        await MainActor.run {
            children.append(newChild)
            showingAddChild = false
        }
    }
    
    func updateChild(_ child: Child, firstName: String, lastName: String, dateOfBirth: Date, gender: String) async {
        await MainActor.run {
            if let index = children.firstIndex(where: { $0.id == child.id }) {
                children[index] = Child(id: child.id, firstName: firstName, lastName: lastName, birthDate: dateOfBirth)
            }
        }
    }
    
    func deleteChild(_ child: Child) async {
        await MainActor.run {
            children.removeAll { $0.id == child.id }
        }
    }
    
    func dismissError() {
        errorMessage = nil
    }
    
    func addChild(firstName: String, lastName: String, dateOfBirth: Date, gender: String?) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulation d'ajout
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            let newChild = Child(
                firstName: firstName,
                lastName: lastName,
                birthDate: dateOfBirth
            )
            children.append(newChild)
            isLoading = false
        }
    }
    
    func updateChild(_ child: Child, firstName: String, lastName: String, dateOfBirth: Date, gender: String?) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulation de mise à jour
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            if let index = children.firstIndex(where: { $0.id == child.id }) {
                children[index] = Child(
                    firstName: firstName,
                    lastName: lastName,
                    birthDate: dateOfBirth
                )
            }
            isLoading = false
        }
    }
    
}

class CacheManager: ObservableObject {
    // Temporary implementation
}

class MemoryManager: ObservableObject {
    // Temporary implementation
}

class ErrorManager: ObservableObject {
    @Published var currentError: Error?
    
    func clearError() {
        currentError = nil
    }
}

class NotificationManager: ObservableObject {
    func requestPermission() async {
        // Temporary implementation
    }
}

struct User {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
}

// MARK: - Calendar Views

struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    let events: [Event]
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // En-tête du mois
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(dateFormatter.string(from: selectedDate))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // Grille du calendrier
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    // En-têtes des jours
                    ForEach(["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .frame(height: 30)
                    }
                    
                    // Jours du mois
                    ForEach(daysInMonth, id: \.self) { date in
                        DayCell(date: date, selectedDate: $selectedDate, events: eventsForDate(date))
                    }
                }
                .padding(.horizontal)
                
                // Liste des événements du jour sélectionné
                if !eventsForSelectedDate.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Événements du \(dayFormatter.string(from: selectedDate))")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ForEach(eventsForSelectedDate, id: \.id) { event in
                            EventRowView(event: event)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end - 1)
        else { return [] }
        
        var days: [Date] = []
        var date = monthFirstWeek.start
        
        while date < monthLastWeek.end {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return days
    }
    
    private var eventsForSelectedDate: [Event] {
        eventsForDate(selectedDate)
    }
    
    private func eventsForDate(_ date: Date) -> [Event] {
        events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: date)
        }
    }
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    private func previousMonth() {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextMonth() {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
    }
}

struct DayCell: View {
    let date: Date
    @Binding var selectedDate: Date
    let events: [Event]
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: { selectedDate = date }) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(textColor)
                
                if !events.isEmpty {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(isSelected ? Color.blue : Color.clear)
            )
        }
    }
    
    private var isSelected: Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var isCurrentMonth: Bool {
        calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary
        }
    }
}

struct WeekCalendarView: View {
    @Binding var selectedDate: Date
    let events: [Event]
    
    private let calendar = Calendar.current
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Navigation de semaine
                HStack {
                    Button(action: previousWeek) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(weekTitle)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: nextWeek) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // Vue de la semaine
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(daysInWeek, id: \.self) { date in
                        WeekDayView(date: date, selectedDate: $selectedDate, events: eventsForDate(date))
                    }
                }
                .padding(.horizontal)
                
                // Événements détaillés
                if !eventsForSelectedDate.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Événements du \(dayFormatter.string(from: selectedDate))")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ForEach(eventsForSelectedDate, id: \.id) { event in
                            EventRowView(event: event)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private var daysInWeek: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else { return [] }
        
        var days: [Date] = []
        var date = weekInterval.start
        
        while date < weekInterval.end {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return days
    }
    
    private var weekTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "'Semaine du' d MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: daysInWeek.first ?? selectedDate)
    }
    
    private var eventsForSelectedDate: [Event] {
        eventsForDate(selectedDate)
    }
    
    private func eventsForDate(_ date: Date) -> [Event] {
        events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: date)
        }
    }
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    private func previousWeek() {
        selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextWeek() {
        selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
    }
}

struct WeekDayView: View {
    let date: Date
    @Binding var selectedDate: Date
    let events: [Event]
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: { selectedDate = date }) {
            VStack(spacing: 8) {
                Text(dayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text("\(calendar.component(.day, from: date))")
                    .font(.title2)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                
                if !events.isEmpty {
                    VStack(spacing: 2) {
                        ForEach(events.prefix(3), id: \.id) { event in
                            Rectangle()
                                .fill(event.eventType.color)
                                .frame(height: 3)
                                .cornerRadius(1.5)
                        }
                    }
                } else {
                    Spacer(minLength: 12)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color.clear)
            )
        }
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date).uppercased()
    }
    
    private var isSelected: Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
}

struct DayCalendarView: View {
    @Binding var selectedDate: Date
    let events: [Event]
    
    private let calendar = Calendar.current
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Navigation du jour
                HStack {
                    Button(action: previousDay) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(dayFormatter.string(from: selectedDate))
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("\(eventsForSelectedDate.count) événement(s)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: nextDay) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // Timeline du jour
                if eventsForSelectedDate.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Aucun événement aujourd'hui")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("Profitez de cette journée libre !")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(eventsForSelectedDate.sorted(by: { $0.startDate < $1.startDate }), id: \.id) { event in
                            DayEventCard(event: event)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    private var eventsForSelectedDate: [Event] {
        events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: selectedDate)
        }
    }
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    private func previousDay() {
        selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextDay() {
        selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }
}

struct DayEventCard: View {
    let event: Event
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 16) {
            // Indicateur de temps
            VStack(spacing: 4) {
                Text(timeFormatter.string(from: event.startDate))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Rectangle()
                    .fill(event.eventType.color)
                    .frame(width: 3, height: 40)
                    .cornerRadius(1.5)
                
                Text(timeFormatter.string(from: event.endDate))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            // Contenu de l'événement
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: event.eventType.icon)
                        .foregroundColor(event.eventType.color)
                    
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(event.eventType.name)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(event.eventType.color.opacity(0.2))
                        .foregroundColor(event.eventType.color)
                        .cornerRadius(8)
                }
                
                if let description = event.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct AgendaCalendarView: View {
    let events: [Event]
    
    private let calendar = Calendar.current
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(groupedEvents.keys.sorted(), id: \.self) { date in
                    VStack(alignment: .leading, spacing: 12) {
                        // En-tête de date
                        HStack {
                            Text(dateFormatter.string(from: date))
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(groupedEvents[date]?.count ?? 0) événement(s)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        // Événements du jour
                        if let dayEvents = groupedEvents[date] {
                            ForEach(dayEvents.sorted(by: { $0.startDate < $1.startDate }), id: \.id) { event in
                                EventRowView(event: event)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                if events.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Aucun événement planifié")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("Ajoutez votre premier événement pour commencer")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                }
            }
            .padding(.vertical)
        }
    }
    
    private var groupedEvents: [Date: [Event]] {
        Dictionary(grouping: events) { event in
            calendar.startOfDay(for: event.startDate)
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
}

// MARK: - Missing Views

struct ChildRowView: View {
    let child: Child
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(child.firstName) \(child.lastName)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Né(e) le \(formatDate(child.birthDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

struct EditDocumentView: View {
    let document: Document
    let onSave: (String, String, DocumentType) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Édition de document à implémenter")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Éditer document")
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

// MARK: - Additional Models
// Document and DocumentType are already defined earlier in the file

// MARK: - Preview

#Preview {
    MainTabView()
}
