//
//  ModernMainTabView.swift
//  Manounou
//
//  Created by Assistant on 18/08/2025.
//  Modern refactored version of MainTabView with proper architecture
//

import SwiftUI
import Foundation

struct ModernMainTabView: View {
    @EnvironmentObject var appContainer: AppContainer
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .environmentObject(appContainer.childrenViewModel)
                .environmentObject(appContainer.eventsViewModel)
                .environmentObject(appContainer.documentsViewModel)
                .environmentObject(appContainer.authViewModel)
                .tabItem {
                    Label("Accueil", systemImage: AppTheme.Icons.home)
                }
                .tag(0)
                .accessibilityLabel("Onglet Accueil")
            
            // Children Tab
            ModernChildrenView()
                .environmentObject(appContainer.childrenViewModel)
                .tabItem {
                    Label("Enfants", systemImage: AppTheme.Icons.children)
                }
                .tag(1)
                .accessibilityLabel("Onglet Enfants")
            
            // Calendar Tab
            ModernCalendarView()
                .environmentObject(appContainer.eventsViewModel)
                .tabItem {
                    Label("Calendrier", systemImage: AppTheme.Icons.calendar)
                }
                .tag(2)
                .accessibilityLabel("Onglet Calendrier")
            
            // Documents Tab
            ModernDocumentsView()
                .environmentObject(appContainer.documentsViewModel)
                .environmentObject(appContainer.childrenViewModel)
                .tabItem {
                    Label("Documents", systemImage: AppTheme.Icons.documents)
                }
                .tag(3)
                .accessibilityLabel("Onglet Documents")
            
            // Settings Tab
            ModernSettingsView()
                .environmentObject(appContainer.authViewModel)
                .tabItem {
                    Label("Paramètres", systemImage: AppTheme.Icons.settings)
                }
                .tag(4)
                .accessibilityLabel("Onglet Paramètres")
        }
        .tint(AppTheme.Colors.primary)
        .onAppear {
            setupTabBarAppearance()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Navigation principale de l'application")
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.Colors.surface)
        
        // Selected tab appearance
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.Colors.primary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.Colors.primary),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Normal tab appearance
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.Colors.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.Colors.textSecondary),
            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Modern Settings View Component
struct ModernSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingProfile = false
    @State private var showingSignOutAlert = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    ProfileHeaderRow(
                        user: authViewModel.currentUser,
                        onTap: {
                            showingProfile = true
                        }
                    )
                }
                
                // Account Section
                Section("Compte") {
                    SettingsRow(
                        title: "Modifier le profil",
                        icon: "person.circle",
                        color: AppTheme.Colors.primary
                    ) {
                        showingProfile = true
                    }
                    
                    SettingsRow(
                        title: "Changer le mot de passe",
                        icon: "key",
                        color: AppTheme.Colors.secondary
                    ) {
                        // TODO: Implement password change
                    }
                    
                    SettingsRow(
                        title: "Notifications",
                        icon: "bell",
                        color: AppTheme.Colors.info
                    ) {
                        // TODO: Implement notifications settings
                    }
                }
                
                // App Section
                Section("Application") {
                    SettingsRow(
                        title: "Confidentialité",
                        icon: "hand.raised",
                        color: AppTheme.Colors.warning
                    ) {
                        // TODO: Implement privacy settings
                    }
                    
                    SettingsRow(
                        title: "À propos",
                        icon: "info.circle",
                        color: AppTheme.Colors.accent
                    ) {
                        showingAbout = true
                    }
                    
                    SettingsRow(
                        title: "Aide et support",
                        icon: "questionmark.circle",
                        color: AppTheme.Colors.success
                    ) {
                        // TODO: Implement help and support
                    }
                }
                
                // Danger Zone
                Section {
                    SettingsRow(
                        title: "Déconnexion",
                        icon: "rectangle.portrait.and.arrow.right",
                        color: AppTheme.Colors.error,
                        showChevron: false
                    ) {
                        showingSignOutAlert = true
                    }
                }
            }
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileEditSheet(user: authViewModel.currentUser) { updatedUser in
                Task {
                    try await authViewModel.updateProfile(
                        firstName: updatedUser.firstName,
                        lastName: updatedUser.lastName
                    )
                }
            }
        }
        .sheet(isPresented: $showingAbout) {
            AboutSheet()
        }
        .alert("Déconnexion", isPresented: $showingSignOutAlert) {
            Button("Annuler", role: .cancel) { }
            Button("Déconnexion", role: .destructive) {
                Task {
                    await authViewModel.signOut()
                }
            }
        } message: {
            Text("Êtes-vous sûr de vouloir vous déconnecter ?")
        }
    }
}

// MARK: - Profile Header Row Component
struct ProfileHeaderRow: View {
    let user: User?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Profile Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.Colors.primary.opacity(0.3),
                                    AppTheme.Colors.secondary.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Text(userInitials)
                        .font(AppTheme.Typography.title3)
                        .foregroundColor(AppTheme.Colors.primary)
                }
                
                // User Info
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(displayName)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    if let email = user?.email {
                        Text(email)
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Text("Modifier le profil")
                        .font(AppTheme.Typography.footnote)
                        .foregroundColor(AppTheme.Colors.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
            .padding(.vertical, AppTheme.Spacing.sm)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Profil utilisateur: \(displayName)")
        .accessibilityHint("Appuyez pour modifier le profil")
    }
    
    private var displayName: String {
        if let firstName = user?.firstName, let lastName = user?.lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = user?.firstName {
            return firstName
        } else {
            return "Utilisateur"
        }
    }
    
    private var userInitials: String {
        let firstName = user?.firstName ?? ""
        let lastName = user?.lastName ?? ""
        let firstInitial = firstName.first?.uppercased() ?? "U"
        let lastInitial = lastName.first?.uppercased() ?? "S"
        return "\(firstInitial)\(lastInitial)"
    }
}

// MARK: - Settings Row Component
struct SettingsRow: View {
    let title: String
    let icon: String
    let color: Color
    let showChevron: Bool
    let action: () -> Void
    
    init(
        title: String,
        icon: String,
        color: Color,
        showChevron: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.showChevron = showChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                        .fill(color.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 16, weight: .medium))
                }
                
                // Title
                Text(title)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                // Chevron
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }
            .padding(.vertical, AppTheme.Spacing.xs)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(title)
        .accessibilityHint("Appuyez pour \(title.lowercased())")
    }
}

// MARK: - Profile Edit Sheet Component
struct ProfileEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    let user: User?
    let onSave: (User) -> Void
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var email: String
    @State private var isLoading = false
    
    init(user: User?, onSave: @escaping (User) -> Void) {
        self.user = user
        self.onSave = onSave
        self._firstName = State(initialValue: user?.firstName ?? "")
        self._lastName = State(initialValue: user?.lastName ?? "")
        self._email = State(initialValue: user?.email ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations personnelles") {
                    ThemedTextField(
                        "Prénom",
                        text: $firstName,
                        placeholder: "Entrez votre prénom"
                    )
                    
                    ThemedTextField(
                        "Nom",
                        text: $lastName,
                        placeholder: "Entrez votre nom"
                    )
                    
                    ThemedTextField(
                        "Email",
                        text: $email,
                        placeholder: "Entrez votre email",
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )
                }
                
                if let user = user {
                    Section("Informations du compte") {
                        HStack {
                            Text("Créé le")
                            Spacer()
                            Text(user.createdAt, style: .date)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        
                        if user.updatedAt != user.createdAt {
                            HStack {
                                Text("Modifié le")
                                Spacer()
                                Text(user.updatedAt, style: .date)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Modifier le profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        saveProfile()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .disabled(firstName.isEmpty || lastName.isEmpty || email.isEmpty || isLoading)
                }
            }
        }
        .interactiveDismissDisabled(isLoading)
    }
    
    private func saveProfile() {
        isLoading = true
        
        let updatedUser = User(
            id: user?.id ?? UUID(),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: user?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        onSave(updatedUser)
        dismiss()
    }
}

// MARK: - About Sheet Component
struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // App Icon and Info
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppTheme.Colors.primary)
                        
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Text(Config.App.name)
                                .font(AppTheme.Typography.largeTitle)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            
                            Text("Version \(Config.App.version)")
                                .font(AppTheme.Typography.callout)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                    
                    // Description
                    VStack(spacing: AppTheme.Spacing.md) {
                        Text("Votre carnet de famille numérique")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Manounou vous aide à organiser et suivre toutes les informations importantes de votre famille en un seul endroit sécurisé.")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Links
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Button("Site web") {
                            if let url = URL(string: Config.App.websiteURL) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .themedButton(style: .primary)
                        
                        Button("Support") {
                            if let url = URL(string: "mailto:\(Config.App.supportEmail)") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .themedButton(style: .secondary)
                    }
                }
                .padding(AppTheme.Spacing.xl)
            }
            .navigationTitle("À propos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
    }
}

// MARK: - Temporary View Definitions
// TODO: Remove these once the separate files are properly recognized by the compiler

struct ModernChildrenView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Enfants")
                    .font(.largeTitle)
                    .padding()
                Text("Vue moderne des enfants")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Enfants")
        }
    }
}

struct ModernCalendarView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Calendrier")
                    .font(.largeTitle)
                    .padding()
                Text("Vue moderne du calendrier")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Calendrier")
        }
    }
}

struct ModernDocumentsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Documents")
                    .font(.largeTitle)
                    .padding()
                Text("Vue moderne des documents")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Documents")
        }
    }
}

struct ThemedTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    
    init(
        _ title: String,
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 4)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ModernMainTabView_Previews: PreviewProvider {
    static var previews: some View {
        ModernMainTabView()
            .environmentObject(AppContainer.shared)
            .preferredColorScheme(.light)

        ModernMainTabView()
            .environmentObject(AppContainer.shared)
            .preferredColorScheme(.dark)
    }
}
#endif