// ModernMainTabView.swift — Manounou
// Tab navigation (cf. « Carte de navigation ») : 4 onglets
// Accueil · Planning · Documents · Profil.
// La Messagerie n'est PAS un onglet : c'est un overlay accessible depuis
// l'accueil (cf. HomeView). Idem notifications.

import SwiftUI
import Foundation

struct ModernMainTabView: View {
    @EnvironmentObject var appContainer: AppContainer
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            // 1 — Accueil
            HomeView()
                .environmentObject(appContainer.childrenViewModel)
                .environmentObject(appContainer.eventsViewModel)
                .environmentObject(appContainer.documentsViewModel)
                .environmentObject(appContainer.authViewModel)
                .tabItem { Label("Accueil",   systemImage: "house.fill") }
                .tag(0)

            // 2 — Planning
            PlanningView()
                .environmentObject(appContainer.eventsViewModel)
                .tabItem { Label("Planning",  systemImage: "calendar.badge.clock") }
                .tag(1)

            // 3 — Documents
            ModernDocumentsView()
                .environmentObject(appContainer.documentsViewModel)
                .environmentObject(appContainer.childrenViewModel)
                .tabItem { Label("Documents", systemImage: "doc.fill") }
                .tag(2)

            // 4 — Profil
            ProfilFoyerView()
                .environmentObject(appContainer.authViewModel)
                .environmentObject(appContainer.childrenViewModel)
                .tabItem { Label("Profil",    systemImage: "person.crop.circle.fill") }
                .tag(3)
        }
        .tint(AppTheme.Colors.brand)
        .onAppear { setupTabBarAppearance() }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground

        let selected   = UIColor(AppTheme.Colors.brand)
        let unselected = UIColor(AppTheme.Colors.muted)

        let font = UIFont.systemFont(ofSize: 10, weight: .semibold)

        appearance.stackedLayoutAppearance.selected.iconColor = selected
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selected, .font: font
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = unselected
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: unselected, .font: font
        ]

        UITabBar.appearance().standardAppearance   = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Profil / Foyer  (stub — replaced by ProfilFoyerView when ready)

struct ProfilFoyerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @State private var showingSignOutAlert = false
    @State private var showingEditProfile  = false
    @State private var showingAddChild     = false
    @State private var showingAbout        = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    profileHeader
                    Divider().padding(.horizontal, 20)
                    settingsList
                }
            }
            .background(AppTheme.Colors.paper.ignoresSafeArea())
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingEditProfile = true } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.brand)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            ProfileEditSheet()
                .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showingAddChild) {
            AddChildSheet()
                .environmentObject(childrenViewModel)
        }
        .sheet(isPresented: $showingAbout) {
            AboutSheet()
        }
        .alert("Déconnexion", isPresented: $showingSignOutAlert) {
            Button("Se déconnecter", role: .destructive) { Task { await authViewModel.signOut() } }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Voulez-vous vraiment vous déconnecter ?")
        }
    }

    // MARK: - Profile header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.brand)
                    .frame(width: 80, height: 80)
                Text(initials)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .shadow(color: AppTheme.Colors.brandShadow, radius: 12, x: 0, y: 4)

            VStack(spacing: 4) {
                Text(displayName)
                    .font(AppTheme.Typography.title3)
                    .foregroundColor(AppTheme.Colors.ink)
                Text(authViewModel.currentUser?.email ?? "")
                    .font(AppTheme.Typography.footnote)
                    .foregroundColor(AppTheme.Colors.muted)
            }

            // Foyer card
            foyerCard
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 28)
    }

    private var foyerCard: some View {
        HStack(spacing: 12) {
            // Icône foyer (solide, cf. design .foyeric)
            Image(systemName: "house.fill")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 46, height: 46)
                .background(RoundedRectangle(cornerRadius: 13).fill(AppTheme.Colors.brand))

            VStack(alignment: .leading, spacing: 2) {
                Text("Famille \(authViewModel.currentUser?.lastName ?? "—")")
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.ink)
                Text(foyerSubtitle)
                    .font(AppTheme.Typography.footnote)
                    .foregroundColor(AppTheme.Colors.muted)
            }
            Spacer()
            stackedMemberAvatars
        }
        .padding(16)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
        .shadow(color: AppTheme.Shadow.card.color,
                radius: AppTheme.Shadow.card.radius,
                x: AppTheme.Shadow.card.x,
                y: AppTheme.Shadow.card.y)
    }

    private var foyerSubtitle: String {
        let n = childrenViewModel.children.count
        return "1 parent · \(n) enfant\(n == 1 ? "" : "s")"
    }

    /// Avatars empilés (cf. design .stack) : le parent + les enfants réels du foyer.
    private var stackedMemberAvatars: some View {
        let members: [(initial: String, color: Color)] =
            [(initials, AppTheme.Colors.blue)]
            + childrenViewModel.children.prefix(3).map {
                (String($0.firstName.prefix(1)).uppercased(), AppTheme.Colors.brand)
            }
        return HStack(spacing: -10) {
            ForEach(Array(members.enumerated()), id: \.offset) { _, m in
                ZStack {
                    Circle().fill(m.color).frame(width: 28, height: 28)
                    Circle().stroke(Color.white, lineWidth: 2.5).frame(width: 28, height: 28)
                    Text(m.initial)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Settings list
    private var settingsList: some View {
        VStack(spacing: 8) {
            // Children section
            PFSettingsSection(title: "MES ENFANTS") {
                ForEach(childrenViewModel.children) { child in
                    PFSettingsRow(icon: "figure.child", iconColor: AppTheme.Colors.brand,
                                  title: "\(child.firstName) \(child.lastName)",
                                  subtitle: child.ageText)
                }
                PFSettingsRow(icon: "person.badge.plus", iconColor: AppTheme.Colors.green,
                              title: "Ajouter un enfant") { showingAddChild = true }
            }

            // Garde section
            PFSettingsSection(title: "GARDE") {
                PFSettingsRow(icon: "person.2.fill", iconColor: AppTheme.Colors.purple,
                              title: "Membres du foyer", subtitle: "Gérer les accès")
                PFSettingsRow(icon: "bell.fill", iconColor: AppTheme.Colors.blue,
                              title: "Notifications")
                PFSettingsRow(icon: "banknote", iconColor: AppTheme.Colors.green,
                              title: "Rémunération & Pajemploi")
            }

            // App section
            PFSettingsSection(title: "APPLICATION") {
                PFSettingsRow(icon: "lock.shield.fill", iconColor: AppTheme.Colors.amber,
                              title: "Confidentialité")
                PFSettingsRow(icon: "questionmark.circle.fill", iconColor: AppTheme.Colors.blue,
                              title: "Aide et support")
                PFSettingsRow(icon: "info.circle.fill", iconColor: AppTheme.Colors.muted,
                              title: "À propos") { showingAbout = true }
            }

            // Sign out
            Button {
                showingSignOutAlert = true
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Déconnexion")
                        .font(AppTheme.Typography.bodyMedium)
                }
                .foregroundColor(AppTheme.Colors.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Computed
    private var displayName: String {
        guard let u = authViewModel.currentUser else { return "Utilisateur" }
        let n = "\(u.firstName) \(u.lastName)".trimmingCharacters(in: .whitespaces)
        return n.isEmpty ? u.email : n
    }

    private var initials: String {
        let f = authViewModel.currentUser?.firstName.first.map(String.init) ?? "?"
        let l = authViewModel.currentUser?.lastName.first.map(String.init)  ?? ""
        return "\(f)\(l)"
    }
}

// MARK: - Helper components

private struct PFSettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.Colors.muted)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 10)
                .kerning(0.6)

            VStack(spacing: 0) {
                content()
            }
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
            .padding(.horizontal, 20)
            .shadow(color: AppTheme.Shadow.card.color,
                    radius: AppTheme.Shadow.card.radius,
                    x: AppTheme.Shadow.card.x,
                    y: AppTheme.Shadow.card.y)
        }
    }
}

private struct PFSettingsRow: View {
    let icon: String
    var iconColor: Color = AppTheme.Colors.muted
    let title: String
    var subtitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            if let action {
                Button(action: action) { rowContent }
                    .buttonStyle(.plain)
            } else {
                rowContent
            }
            Divider().padding(.leading, 60)
        }
    }

    private var rowContent: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.ink)
                if let sub = subtitle {
                    Text(sub)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.muted)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppTheme.Colors.muted.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}

// MARK: - Legacy ModernSettingsView kept for backward compat
// (now ProfilFoyerView is the primary profile screen)
struct ModernSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        ProfilFoyerView()
            .environmentObject(authViewModel)
            .environmentObject(AppContainer.shared.childrenViewModel)
    }
}

// MARK: - Component stubs used by other files

struct ProfileHeaderRow: View {
    var user: UserProfile?
    var onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(AppTheme.Colors.brand).frame(width: 46, height: 46)
                    Text(initials).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName).font(AppTheme.Typography.bodyMedium).foregroundColor(AppTheme.Colors.ink)
                    Text(user?.email ?? "").font(AppTheme.Typography.caption).foregroundColor(AppTheme.Colors.muted)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(AppTheme.Colors.muted)
            }
        }
    }
    private var displayName: String {
        guard let u = user else { return "Utilisateur" }
        return "\(u.firstName) \(u.lastName)".trimmingCharacters(in: .whitespaces)
    }
    private var initials: String {
        let f = user?.firstName.first.map(String.init) ?? "U"
        let l = user?.lastName.first.map(String.init)  ?? ""
        return "\(f)\(l)"
    }
}

struct SettingsRow: View {
    var title: String
    var icon: String
    var color: Color = AppTheme.Colors.brand
    var showChevron: Bool = true
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundColor(color).frame(width: 28)
                Text(title).font(AppTheme.Typography.body).foregroundColor(AppTheme.Colors.ink)
                Spacer()
                if showChevron { Image(systemName: "chevron.right").foregroundColor(AppTheme.Colors.muted) }
            }
        }
    }
}

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "heart.fill").font(.system(size: 48)).foregroundColor(AppTheme.Colors.brand)
                Text("Manounou").font(AppTheme.Typography.title1)
                Text("L'app qui simplifie la garde\nde vos enfants.").font(AppTheme.Typography.body).multilineTextAlignment(.center).foregroundColor(AppTheme.Colors.muted)
            }
            .padding(40)
            .navigationTitle("À propos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Fermer") { dismiss() } } }
        }
    }
}
