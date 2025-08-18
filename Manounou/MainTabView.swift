//
//  MainTabView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI
import Foundation

// MARK: - Main Tab View
struct MainTabView: View {
    @StateObject private var authManager = AuthManager()
    @StateObject private var notificationManager = NotificationManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab - Functional Dashboard
            FunctionalHomeView()
                .environmentObject(authManager)
                .environmentObject(notificationManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }
                .tag(0)
            
            // Children Tab - Functional placeholder
            FunctionalChildrenView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Enfants")
                }
                .tag(1)
            
            // Calendar Tab - Functional placeholder
            FunctionalCalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendrier")
                }
                .tag(2)
            
            // Documents Tab - Functional placeholder
            FunctionalDocumentsView()
                .tabItem {
                    Image(systemName: "doc.fill")
                    Text("Documents")
                }
                .tag(3)
            
            // Settings Tab - Functional placeholder
            FunctionalSettingsView()
                .environmentObject(authManager)
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

// MARK: - Functional Views with Real CRUD Operations

struct FunctionalChildrenView: View {
    @State private var children: [FunctionalChild] = []
    @State private var showingAddChild = false
    @State private var selectedChild: FunctionalChild? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                if children.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Aucun enfant ajouté")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Commencez par ajouter le profil de votre premier enfant")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Ajouter un enfant") {
                            showingAddChild = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(children) { child in
                            ChildRowView(child: child) {
                                selectedChild = child
                            }
                        }
                        .onDelete(perform: deleteChildren)
                    }
                }
            }
            .navigationTitle("Enfants")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        showingAddChild = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddChild) {
            AddChildSheet { newChild in
                children.append(newChild)
            }
        }
        .sheet(item: $selectedChild) { child in
            ChildDetailSheet(child: child) { updatedChild in
                if let index = children.firstIndex(where: { $0.id == updatedChild.id }) {
                    children[index] = updatedChild
                }
            }
        }
    }
    
    private func deleteChildren(offsets: IndexSet) {
        children.remove(atOffsets: offsets)
    }
}

struct FunctionalCalendarView: View {
    @State private var events: [FunctionalEvent] = []
    @State private var showingAddEvent = false
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                // Simple calendar placeholder
                DatePicker("Date sélectionnée", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Divider()
                
                // Events list
                if events.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Aucun événement")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Planifiez votre premier événement")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button("Ajouter un événement") {
                            showingAddEvent = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(events) { event in
                            EventRowView(event: event)
                        }
                        .onDelete(perform: deleteEvents)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Calendrier")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        showingAddEvent = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventSheet { newEvent in
                events.append(newEvent)
            }
        }
    }
    
    private func deleteEvents(offsets: IndexSet) {
        events.remove(atOffsets: offsets)
    }
}

struct FunctionalDocumentsView: View {
    @State private var documents: [FunctionalDocument] = []
    @State private var showingAddDocument = false
    
    var body: some View {
        NavigationView {
            VStack {
                if documents.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        
                        Text("Aucun document")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Organisez vos documents importants")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button("Ajouter un document") {
                            showingAddDocument = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(documents) { document in
                            DocumentRowView(document: document)
                        }
                        .onDelete(perform: deleteDocuments)
                    }
                }
            }
            .navigationTitle("Documents")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        showingAddDocument = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddDocument) {
            AddDocumentSheet { newDocument in
                documents.append(newDocument)
            }
        }
    }
    
    private func deleteDocuments(offsets: IndexSet) {
        documents.remove(atOffsets: offsets)
    }
}

struct FunctionalSettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingProfile = false
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Profil") {
                    Button("Modifier le profil") {
                        showingProfile = true
                    }
                    
                    Button("Changer le mot de passe") {
                        // Action pour changer le mot de passe
                    }
                }
                
                Section("Application") {
                    Button("Notifications") {
                        // Action pour les notifications
                    }
                    
                    Button("Confidentialité") {
                        // Action pour la confidentialité
                    }
                }
                
                Section {
                    Button("Déconnexion") {
                        showingSignOutAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Paramètres")
        }
        .sheet(isPresented: $showingProfile) {
            ProfileEditSheet()
        }
        .alert("Déconnexion", isPresented: $showingSignOutAlert) {
            Button("Déconnexion", role: .destructive) {
                Task {
                    await authManager.signOut()
                }
            }
            Button("Annuler", role: .cancel) { }
        } message: {
            Text("Êtes-vous sûr de vouloir vous déconnecter ?")
        }
    }
}

// MARK: - Functional Models

struct FunctionalChild: Identifiable {
    let id = UUID()
    var firstName: String
    var lastName: String
    var birthDate: Date
    var gender: String
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
}

struct FunctionalEvent: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var description: String
}

struct FunctionalDocument: Identifiable {
    let id = UUID()
    var title: String
    var type: String
    var dateAdded: Date
}

// MARK: - Row Views

struct ChildRowView: View {
    let child: FunctionalChild
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Text(String(child.firstName.prefix(1)))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(child.fullName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(child.age) ans")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct EventRowView: View {
    let event: FunctionalEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.title)
                .font(.headline)
            
            Text(event.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !event.description.isEmpty {
                Text(event.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct DocumentRowView: View {
    let document: FunctionalDocument
    
    var body: some View {
        HStack {
            Image(systemName: "doc.fill")
                .foregroundColor(.purple)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(document.title)
                    .font(.headline)
                
                Text(document.type)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(document.dateAdded, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Add Sheets

struct AddChildSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (FunctionalChild) -> Void
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var birthDate = Date()
    @State private var gender = "Autre"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations") {
                    TextField("Prénom", text: $firstName)
                    TextField("Nom", text: $lastName)
                    DatePicker("Date de naissance", selection: $birthDate, displayedComponents: .date)
                    Picker("Genre", selection: $gender) {
                        Text("Fille").tag("Fille")
                        Text("Garçon").tag("Garçon")
                        Text("Autre").tag("Autre")
                    }
                }
            }
            .navigationTitle("Nouvel enfant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        let newChild = FunctionalChild(
                            firstName: firstName,
                            lastName: lastName,
                            birthDate: birthDate,
                            gender: gender
                        )
                        onSave(newChild)
                        dismiss()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
        }
    }
}

struct AddEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (FunctionalEvent) -> Void
    
    @State private var title = ""
    @State private var date = Date()
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Événement") {
                    TextField("Titre", text: $title)
                    DatePicker("Date", selection: $date)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
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
                        let newEvent = FunctionalEvent(
                            title: title,
                            date: date,
                            description: description
                        )
                        onSave(newEvent)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct AddDocumentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (FunctionalDocument) -> Void
    
    @State private var title = ""
    @State private var type = "Médical"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Document") {
                    TextField("Titre", text: $title)
                    Picker("Type", selection: $type) {
                        Text("Médical").tag("Médical")
                        Text("Scolaire").tag("Scolaire")
                        Text("Administratif").tag("Administratif")
                        Text("Autre").tag("Autre")
                    }
                }
            }
            .navigationTitle("Nouveau document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        let newDocument = FunctionalDocument(
                            title: title,
                            type: type,
                            dateAdded: Date()
                        )
                        onSave(newDocument)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct ChildDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let child: FunctionalChild
    let onSave: (FunctionalChild) -> Void
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var birthDate: Date
    @State private var gender: String
    
    init(child: FunctionalChild, onSave: @escaping (FunctionalChild) -> Void) {
        self.child = child
        self.onSave = onSave
        self._firstName = State(initialValue: child.firstName)
        self._lastName = State(initialValue: child.lastName)
        self._birthDate = State(initialValue: child.birthDate)
        self._gender = State(initialValue: child.gender)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations") {
                    TextField("Prénom", text: $firstName)
                    TextField("Nom", text: $lastName)
                    DatePicker("Date de naissance", selection: $birthDate, displayedComponents: .date)
                    Picker("Genre", selection: $gender) {
                        Text("Fille").tag("Fille")
                        Text("Garçon").tag("Garçon")
                        Text("Autre").tag("Autre")
                    }
                }
            }
            .navigationTitle("Modifier enfant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        var updatedChild = child
                        updatedChild.firstName = firstName
                        updatedChild.lastName = lastName
                        updatedChild.birthDate = birthDate
                        updatedChild.gender = gender
                        onSave(updatedChild)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProfileEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profil") {
                    TextField("Prénom", text: .constant("Utilisateur"))
                    TextField("Nom", text: .constant("Test"))
                    TextField("Email", text: .constant("user@example.com"))
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
                    Button("Sauvegarder") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FunctionalHomeView: View {
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
                        
                        // Quick Actions
                        quickActions(geometry: geometry)
                        
                        // Recent Activity
                        recentActivity(geometry: geometry)
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.top, geometry.size.height * 0.02)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .refreshable {
            // Refresh data
        }
    }
    
    private func welcomeHeader(geometry: GeometryProxy) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(greetingText)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text("Bienvenue sur Manounou")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay {
                    Text("U")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
        }
        .padding(.vertical, 20)
    }
    
    private func quickStats(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Aperçu")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                statCard(
                    title: "Enfants",
                    value: "0",
                    icon: "person.2.fill",
                    color: .green,
                    geometry: geometry
                )
                
                statCard(
                    title: "Événements",
                    value: "0",
                    icon: "calendar",
                    color: .orange,
                    geometry: geometry
                )
                
                statCard(
                    title: "Documents",
                    value: "0",
                    icon: "doc.fill",
                    color: .purple,
                    geometry: geometry
                )
            }
        }
    }
    
    private func statCard(
        title: String,
        value: String,
        icon: String,
        color: Color,
        geometry: GeometryProxy
    ) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private func quickActions(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actions rapides")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                actionButton(
                    title: "Ajouter un enfant",
                    icon: "person.badge.plus",
                    color: .green,
                    geometry: geometry
                ) {
                    // Action
                }
                
                actionButton(
                    title: "Nouvel événement",
                    icon: "calendar.badge.plus",
                    color: .orange,
                    geometry: geometry
                ) {
                    // Action
                }
                
                actionButton(
                    title: "Ajouter document",
                    icon: "doc.badge.plus",
                    color: .purple,
                    geometry: geometry
                ) {
                    // Action
                }
                
                actionButton(
                    title: "Voir paramètres",
                    icon: "gearshape.fill",
                    color: .gray,
                    geometry: geometry
                ) {
                    // Action
                }
            }
        }
    }
    
    private func actionButton(
        title: String,
        icon: String,
        color: Color,
        geometry: GeometryProxy,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
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
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
    
    private func recentActivity(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activité récente")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                activityItem(
                    icon: "checkmark.circle.fill",
                    title: "Application initialisée",
                    subtitle: "Toutes les fonctionnalités sont prêtes",
                    color: .green
                )
                
                activityItem(
                    icon: "info.circle.fill",
                    title: "Commencez par ajouter un enfant",
                    subtitle: "Créez le profil de votre premier enfant",
                    color: .blue
                )
            }
        }
    }
    
    private func activityItem(
        icon: String,
        title: String,
        subtitle: String,
        color: Color
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
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
