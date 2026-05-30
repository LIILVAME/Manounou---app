// HomeView.swift — Manounou
// Direction C — Statut en direct
// Brand #FA4270 · SF Rounded · paper background #F4F2EC

import SwiftUI

// MARK: - Child Status

private enum ChildStatus {
    case atHome
    case dropping
    case withCarer
    case returning

    // MARK: Display

    var label: String {
        switch self {
        case .atHome:    return "À la maison"
        case .dropping:  return "En route · dépôt"
        case .withCarer: return "Chez Fatou"
        case .returning: return "En route · récupération"
        }
    }

    var icon: String {
        switch self {
        case .atHome:    return "house.fill"
        case .dropping:  return "car.fill"
        case .withCarer: return "heart.fill"
        case .returning: return "figure.walk"
        }
    }

    /// 0-based index in the 3-step progress bar (Dépôt · Chez Fatou · Récup)
    var stepIndex: Int {
        switch self {
        case .atHome:    return 0
        case .dropping:  return 0
        case .withCarer: return 1
        case .returning: return 2
        }
    }

    /// True when in transit or actively with carer — drives the live-pulse indicator
    var isActive: Bool {
        switch self {
        case .dropping, .withCarer, .returning: return true
        case .atHome: return false
        }
    }

    // MARK: Factory

    static func current(for hour: Int) -> ChildStatus {
        switch hour {
        case 0..<8:   return .atHome
        case 8..<9:   return .dropping
        case 9..<17:  return .withCarer
        case 17..<18: return .returning
        default:      return .atHome
        }
    }
}

// MARK: - HomeView

struct HomeView: View {

    // MARK: Environment

    @EnvironmentObject var authViewModel:      AuthViewModel
    @EnvironmentObject var childrenViewModel:  ChildrenViewModel
    @EnvironmentObject var eventsViewModel:    EventsViewModel
    @EnvironmentObject var documentsViewModel: DocumentsViewModel

    // MARK: State

    @State private var showingNotifications = false
    @State private var showingAddEvent      = false
    @State private var showingAddDocument   = false
    @State private var showingMessages      = false
    @State private var showingDeclaration   = false

    @State private var navigateToCalendar   = false
    @State private var navigateToDocuments  = false

    /// Drives the live-pulse animation on the hero card
    @State private var livePulse = false

    // MARK: Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                AppTheme.Colors.paper.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.lg) {

                        headerBar
                            .padding(.horizontal, AppTheme.Spacing.screenPadding)
                            .padding(.top, AppTheme.Spacing.md)

                        heroCard
                            .padding(.horizontal, AppTheme.Spacing.screenPadding)

                        declarationCard
                            .padding(.horizontal, AppTheme.Spacing.screenPadding)

                        weeklyStrip
                            .padding(.horizontal, AppTheme.Spacing.screenPadding)

                        quickActionsRow
                            .padding(.horizontal, AppTheme.Spacing.screenPadding)

                        upcomingEventsSection

                        recentDocumentsSection

                        // Bottom breathing room for tab bar
                        Color.clear.frame(height: AppTheme.Spacing.xxl)
                    }
                }
                .refreshable {
                    await loadData()
                }
            }
            .navigationBarHidden(true)
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
            Task { await loadData() }
            withAnimation(
                .easeInOut(duration: 1.4).repeatForever(autoreverses: true)
            ) {
                livePulse = true
            }
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationsOverlay()
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventSheet()
                .environmentObject(eventsViewModel)
                .environmentObject(childrenViewModel)
        }
        .sheet(isPresented: $showingAddDocument) {
            AddDocumentSheet()
                .environmentObject(documentsViewModel)
                .environmentObject(childrenViewModel)
        }
        .sheet(isPresented: $showingMessages) {
            MessagesView()
        }
        .sheet(isPresented: $showingDeclaration) {
            DeclarationOverlay()
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greetingText)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.muted)
                    .kerning(0.3)

                Text(displayName)
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.Colors.ink)
            }

            Spacer()

            HStack(spacing: 10) {
                messagesButton
                notificationButton
            }
        }
    }

    // Messagerie = overlay transverse (cf. « Carte de navigation »), ouvert
    // depuis l'accueil plutôt que via un onglet dédié.
    private var messagesButton: some View {
        Button {
            showingMessages = true
        } label: {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.Colors.ink)
                .frame(width: 44, height: 44)
                .background(AppTheme.Colors.surface)
                .clipShape(Circle())
                .shadow(
                    color: AppTheme.Shadow.small.color,
                    radius: AppTheme.Shadow.small.radius,
                    x: AppTheme.Shadow.small.x,
                    y: AppTheme.Shadow.small.y
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Messagerie")
    }

    private var notificationButton: some View {
        Button {
            showingNotifications = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.ink)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.Colors.surface)
                    .clipShape(Circle())
                    .shadow(
                        color: AppTheme.Shadow.small.color,
                        radius: AppTheme.Shadow.small.radius,
                        x: AppTheme.Shadow.small.x,
                        y: AppTheme.Shadow.small.y
                    )

                // Unread badge dot
                Circle()
                    .fill(AppTheme.Colors.brand)
                    .frame(width: 9, height: 9)
                    .offset(x: 2, y: -1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Notifications")
    }

    // MARK: - Déclaration Pajemploi (rappel)

    /// Rappel de déclaration mensuelle (cf. « Focus Accueil », carte ambre).
    /// Montants représentatifs tant que le calcul Pajemploi réel n'est pas branché.
    private var declarationCard: some View {
        Button { showingDeclaration = true } label: {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(AppTheme.Colors.amber)
                        .frame(width: 40, height: 40)
                    Image(systemName: "eurosign")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("Déclaration \(Self.monthName(offset: 0)) à faire")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.Colors.ink)
                    Text("86 h · 472,00 € — avant le 5 \(Self.monthName(offset: 1))")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "B07D00"))
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "B07D00").opacity(0.7))
            }
            .padding(13)
            .background(RoundedRectangle(cornerRadius: 16).fill(AppTheme.Colors.amber.opacity(0.08)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.Colors.amber.opacity(0.45), lineWidth: 1.6))
        }
        .buttonStyle(.plain)
    }

    /// Nom du mois en français, décalé de `offset` mois (0 = mois courant).
    private static func monthName(offset: Int) -> String {
        let date = Calendar.current.date(byAdding: .month, value: offset, to: Date()) ?? Date()
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "fr_FR")
        fmt.dateFormat = "LLLL"
        return fmt.string(from: date)
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        ZStack(alignment: .topLeading) {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(hex: "FA4270"),
                    Color(hex: "D4305A")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl))

            // Decorative circles for depth
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 180, height: 180)
                .offset(x: -50, y: -50)

            Circle()
                .fill(Color.white.opacity(0.04))
                .frame(width: 110, height: 110)
                .offset(x: 260, y: 55)

            // Live pulse ring (only when status is active)
            if currentStatus.isActive {
                Circle()
                    .stroke(Color.white.opacity(livePulse ? 0.0 : 0.4), lineWidth: 2)
                    .frame(width: livePulse ? 70 : 46, height: livePulse ? 70 : 46)
                    .offset(x: AppTheme.Spacing.lg - 12, y: AppTheme.Spacing.lg + 44)
                    .animation(
                        .easeOut(duration: 1.4).repeatForever(autoreverses: false),
                        value: livePulse
                    )
            }

            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                heroCardContent
            }
            .padding(AppTheme.Spacing.lg)
        }
        .shadow(
            color: AppTheme.Colors.brandShadow,
            radius: 20,
            x: 0,
            y: 8
        )
    }

    @ViewBuilder
    private var heroCardContent: some View {
        // "EN CE MOMENT" eyebrow label
        HStack(spacing: 6) {
            Circle()
                .fill(.white)
                .frame(width: 6, height: 6)
                .opacity(livePulse ? 1.0 : 0.4)
                .animation(
                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: livePulse
                )

            Text("EN CE MOMENT")
                .font(AppTheme.Typography.caption2)
                .foregroundColor(.white.opacity(0.80))
                .kerning(1.2)
        }

        if let child = childrenViewModel.children.first {
            childHeroContent(child: child)
        } else {
            noChildHeroContent
        }
    }

    @ViewBuilder
    private func childHeroContent(child: Child) -> some View {
        // Child avatar row
        HStack(spacing: AppTheme.Spacing.sm) {
            // Initials circle
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 46, height: 46)
                Text(child.initials)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(child.firstName)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)

                Text(child.formattedAge)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.white.opacity(0.72))
            }
        }

        // Current status — large bold
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: currentStatus.icon)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.88))

            Text(currentStatus.label)
                .font(AppTheme.Typography.title1)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }

        // 3-segment progress bar
        heroSegmentBar

        // Next info line
        HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: "clock")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.72))

            Text(nextInfoLine)
                .font(AppTheme.Typography.callout)
                .foregroundColor(.white.opacity(0.88))
        }

        // Timeline dépôt → garde → récup (avatars P / F / M)
        heroTimeline
            .padding(.top, 4)
    }

    private var noChildHeroContent: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.20))
                        .frame(width: 46, height: 46)
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Aucun enfant")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.white)
                    Text("Commencez ici")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.white.opacity(0.72))
                }
            }

            Button {
                // Navigate to add child — surface this via tab selection or a sheet
            } label: {
                Label("Ajoutez votre enfant", systemImage: "plus.circle.fill")
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.brand)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.button))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Hero progress + timeline (cf. « Focus Accueil »)

    /// Barre à 3 segments (design `.pgr`).
    private var heroSegmentBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i <= currentStatus.stepIndex ? Color.white : Color.white.opacity(0.32))
                    .frame(height: 5)
            }
        }
    }

    /// Timeline humanisée dépôt → garde → récup avec avatars (design `.stages`).
    /// Données représentatives en l'absence de modèle de planning ; à brancher
    /// sur le planning réel quand il existera.
    private var heroTimeline: some View {
        HStack(alignment: .top) {
            heroStage(initial: "P", color: AppTheme.Colors.blue,
                      title: "Dépôt", time: "8h30", align: .leading)
            Spacer(minLength: 0)
            heroStage(initial: "F", color: AppTheme.Colors.brand,
                      title: "Chez Fatou", time: nil, align: .center)
            Spacer(minLength: 0)
            heroStage(initial: "M", color: AppTheme.Colors.purple,
                      title: "Récup.", time: "17h00", align: .trailing)
        }
    }

    private func heroStage(initial: String, color: Color, title: String,
                           time: String?, align: HorizontalAlignment) -> some View {
        VStack(alignment: align, spacing: 5) {
            ZStack {
                Circle().fill(color).frame(width: 30, height: 30)
                // Bord blanc pour détacher l'avatar du fond rose
                Circle().stroke(Color.white.opacity(0.85), lineWidth: 1.5).frame(width: 30, height: 30)
                Text(initial)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            if let time {
                Text(time)
                    .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
    }

    // MARK: - Weekly Strip

    private static let dayLetters:   [String] = ["L", "M", "M", "J", "V", "S", "D"]
    /// Mon–Fri are garde days (0-based Mon = 0)
    private static let gardeIndices: Set<Int>  = [0, 1, 2, 3, 4]

    private var todayWeekdayIndex: Int {
        // Calendar.weekday: 1=Sun, 2=Mon … 7=Sat  →  0=Mon … 6=Sun
        let raw = Calendar.current.component(.weekday, from: Date())
        return (raw + 5) % 7
    }

    private var weeklyStrip: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    let isToday = index == todayWeekdayIndex
                    let isGarde = Self.gardeIndices.contains(index)

                    VStack(spacing: 6) {
                        Text(Self.dayLetters[index])
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(
                                isToday ? .white : (isGarde ? AppTheme.Colors.ink : AppTheme.Colors.muted)
                            )

                        Circle()
                            .fill(
                                isGarde
                                    ? (isToday ? Color.white : AppTheme.Colors.brand)
                                    : Color.clear
                            )
                            .frame(width: 6, height: 6)
                            .overlay(
                                Circle()
                                    .stroke(
                                        isGarde
                                            ? (isToday ? Color.white : AppTheme.Colors.brand)
                                            : AppTheme.Colors.border,
                                        lineWidth: 1.5
                                    )
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(
                        Group {
                            if isToday {
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                                    .fill(AppTheme.Colors.brand)
                            } else {
                                Color.clear
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xs)
            .padding(.top, AppTheme.Spacing.xs)

            // Footer : type de garde + horaires + raccourci Planning (cf. « Focus Accueil »)
            HStack(spacing: 8) {
                Text("Routine")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.brand)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 8).fill(AppTheme.Colors.brandGhost))

                Text("8h30–17h00")
                    .font(.system(size: 13.5, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.ink)

                Spacer(minLength: 0)

                Button { navigateToCalendar = true } label: {
                    Text("Planning ›")
                        .font(.system(size: 12.5, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.Colors.brand)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .overlay(
                Rectangle()
                    .fill(AppTheme.Colors.divider)
                    .frame(height: 1),
                alignment: .top
            )
            .padding(.top, 5)
        }
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
        .shadow(
            color: AppTheme.Shadow.small.color,
            radius: AppTheme.Shadow.small.radius,
            x: AppTheme.Shadow.small.x,
            y: AppTheme.Shadow.small.y
        )
    }

    // MARK: - Quick Actions Row

    private var quickActionsRow: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            HomeQuickActionCard(
                label: "Message à Fatou",
                icon: "bubble.left.fill",
                accentColor: AppTheme.Colors.green
            ) {
                showingMessages = true
            }

            HomeQuickActionCard(
                label: "Baby-sitter du soir",
                icon: "star.fill",
                accentColor: AppTheme.Colors.orange
            ) {
                showingAddEvent = true
            }
        }
    }

    // MARK: - Upcoming Events Section

    private var upcomingEventsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HomeSectionHeader(title: "PROCHAINS ÉVÉNEMENTS") {
                navigateToCalendar = true
            }
            .padding(.horizontal, AppTheme.Spacing.screenPadding)

            if sortedUpcomingEvents.isEmpty {
                HomeEmptyStateCard(
                    icon: "calendar.badge.plus",
                    message: "Pas d'événement à venir",
                    actionLabel: "Ajouter un événement"
                ) {
                    showingAddEvent = true
                }
                .padding(.horizontal, AppTheme.Spacing.screenPadding)
            } else {
                VStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(Array(sortedUpcomingEvents.prefix(3)), id: \.id) { event in
                        HomeEventRow(event: event)
                            .onTapGesture { navigateToCalendar = true }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.screenPadding)
            }
        }
    }

    // MARK: - Recent Documents Section

    private var recentDocumentsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HomeSectionHeader(title: "DOCUMENTS RÉCENTS") {
                navigateToDocuments = true
            }
            .padding(.horizontal, AppTheme.Spacing.screenPadding)

            if recentDocs.isEmpty {
                HomeEmptyStateCard(
                    icon: "doc.badge.plus",
                    message: "Aucun document récent",
                    actionLabel: "Ajouter un document"
                ) {
                    showingAddDocument = true
                }
                .padding(.horizontal, AppTheme.Spacing.screenPadding)
            } else {
                let displayed = Array(recentDocs.prefix(3))
                VStack(spacing: 0) {
                    ForEach(Array(displayed.enumerated()), id: \.element.id) { index, doc in
                        HomeDocumentRow(document: doc)
                            .onTapGesture { navigateToDocuments = true }

                        if index < displayed.count - 1 {
                            Divider()
                                .background(AppTheme.Colors.divider)
                                .padding(.leading, 56)
                        }
                    }
                }
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
                .shadow(
                    color: AppTheme.Shadow.card.color,
                    radius: AppTheme.Shadow.card.radius,
                    x: AppTheme.Shadow.card.x,
                    y: AppTheme.Shadow.card.y
                )
                .padding(.horizontal, AppTheme.Spacing.screenPadding)
            }
        }
    }

    // MARK: - Placeholder Sheets

    // MARK: - Data Loading

    private func loadData() async {
        async let _ = childrenViewModel.loadChildren()
        async let _ = eventsViewModel.loadEvents()
        async let _ = documentsViewModel.loadDocuments()
    }

    // MARK: - Computed Properties

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Bonjour,"
        case 12..<17: return "Bon après-midi,"
        case 17..<22: return "Bonsoir,"
        default:      return "Bonne nuit,"
        }
    }

    private var displayName: String {
        guard let first = authViewModel.currentUser?.firstName,
              !first.isEmpty else { return "Bienvenue" }
        return first
    }

    private var currentStatus: ChildStatus {
        let hour = Calendar.current.component(.hour, from: Date())
        return ChildStatus.current(for: hour)
    }

    private var nextInfoLine: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<8:   return "Dépôt prévu à 08h30"
        case 8..<9:   return "Arrivée chez Fatou à 09h00"
        case 9..<17:  return "Récupération à 17h00"
        case 17..<18: return "Retour à la maison vers 18h00"
        default:      return "Pas de garde ce soir"
        }
    }

    private var sortedUpcomingEvents: [Event] {
        let now = Date()
        return eventsViewModel.events
            .filter { $0.startDate >= now }
            .sorted { $0.startDate < $1.startDate }
    }

    private var recentDocs: [Document] {
        documentsViewModel.documents
            .sorted { $0.createdAt > $1.createdAt }
    }
}

// MARK: - Section Header

private struct HomeSectionHeader: View {
    let title:    String
    let onSeeAll: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.Colors.muted)
                .kerning(0.8)

            Spacer()

            Button("Voir tout", action: onSeeAll)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.brand)
        }
    }
}

// MARK: - Quick Action Card

private struct HomeQuickActionCard: View {
    let label:       String
    let icon:        String
    let accentColor: Color
    let action:      () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                        .fill(accentColor.opacity(0.14))
                        .frame(width: 38, height: 38)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(accentColor)
                }

                Text(label)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
            .shadow(
                color: AppTheme.Shadow.card.color,
                radius: AppTheme.Shadow.card.radius,
                x: AppTheme.Shadow.card.x,
                y: AppTheme.Shadow.card.y
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Event Row

private struct HomeEventRow: View {
    let event: Event

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Type icon circle
            ZStack {
                Circle()
                    .fill(event.eventType.color.opacity(0.14))
                    .frame(width: 42, height: 42)
                Image(systemName: event.eventType.icon)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(event.eventType.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(event.title)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.ink)
                    .lineLimit(1)

                Text(eventDateLabel(event.startDate))
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.muted)
            }

            Spacer()

            if event.isToday {
                Text("Aujourd'hui")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.brand)
                    .clipShape(Capsule())
            } else {
                Text(relativeDateLabel(event.startDate))
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.muted)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
        .shadow(
            color: AppTheme.Shadow.card.color,
            radius: AppTheme.Shadow.card.radius,
            x: AppTheme.Shadow.card.x,
            y: AppTheme.Shadow.card.y
        )
        .contentShape(Rectangle())
    }

    private func eventDateLabel(_ date: Date) -> String {
        let f        = DateFormatter()
        f.locale     = Locale(identifier: "fr_FR")
        f.dateFormat = "EEE d MMM · HH'h'mm"
        return f.string(from: date)
    }

    private func relativeDateLabel(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        switch days {
        case 0:     return "Aujourd'hui"
        case 1:     return "Demain"
        case 2...6: return "Dans \(days) j."
        default:
            let f        = DateFormatter()
            f.locale     = Locale(identifier: "fr_FR")
            f.dateFormat = "dd/MM"
            return f.string(from: date)
        }
    }
}

// MARK: - Document Row

private struct HomeDocumentRow: View {
    let document: Document

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                    .fill(document.documentType.color.opacity(0.14))
                    .frame(width: 42, height: 42)
                Image(systemName: document.documentType.icon)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(document.documentType.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(document.title)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.ink)
                    .lineLimit(1)

                Text(document.documentType.displayName)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.muted)
            }

            Spacer()

            if document.isRecent {
                Text("Nouveau")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.green)
                    .clipShape(Capsule())
            }
        }
        .padding(AppTheme.Spacing.md)
        .contentShape(Rectangle())
    }
}

// MARK: - Empty State Card

private struct HomeEmptyStateCard: View {
    let icon:        String
    let message:     String
    let actionLabel: String
    let onAction:    () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .light, design: .rounded))
                .foregroundColor(AppTheme.Colors.muted)

            Text(message)
                .font(AppTheme.Typography.callout)
                .foregroundColor(AppTheme.Colors.muted)

            Button(action: onAction) {
                Label(actionLabel, systemImage: "plus")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.brand)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }
}

// MARK: - Preview

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .environmentObject(AuthViewModel(authService: MockAuthService()))
                .environmentObject(ChildrenViewModel(childrenService: MockChildrenService()))
                .environmentObject(EventsViewModel(eventsService: MockEventsService()))
                .environmentObject(DocumentsViewModel(documentsService: MockDocumentsService()))
                .previewDisplayName("Accueil — Direction C (vide)")

            HomeView()
                .environmentObject(previewAuthVM)
                .environmentObject(previewChildrenVM)
                .environmentObject(previewEventsVM)
                .environmentObject(previewDocsVM)
                .previewDisplayName("Accueil — Direction C (données)")
        }
    }

    // MARK: Preview helpers

    static var previewAuthVM: AuthViewModel {
        let vm = AuthViewModel(authService: MockAuthService())
        vm.currentUser = User.sampleUser
        return vm
    }

    static var previewChildrenVM: ChildrenViewModel {
        let vm = ChildrenViewModel(childrenService: MockChildrenService())
        vm.children = Child.sampleChildren
        return vm
    }

    static var previewEventsVM: EventsViewModel {
        let vm = EventsViewModel(eventsService: MockEventsService())
        vm.events = Event.sampleEvents
        return vm
    }

    static var previewDocsVM: DocumentsViewModel {
        let vm = DocumentsViewModel(documentsService: MockDocumentsService())
        vm.documents = Document.sampleDocuments
        return vm
    }
}
#endif

// =====================================================================
// MARK: - Overlays (handoff « Focus Overlays »)
// =====================================================================

// MARK: Notifications

private struct NotifItem: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let time: String
    let body: String
    let unread: Bool
}

/// Overlay Notifications : fil d'activité groupé par moment, actionnable.
/// Données représentatives (le flux réel viendra du backend).
struct NotificationsOverlay: View {
    @Environment(\.dismiss) private var dismiss

    private let today: [NotifItem] = [
        NotifItem(icon: "clock.fill", color: AppTheme.Colors.brand,
                  title: "Récupération dans 30 min", time: "5 min", body: "Awa · 17h00 par Maman", unread: true),
        NotifItem(icon: "eurosign", color: AppTheme.Colors.amber,
                  title: "Déclaration à faire", time: "1 h", body: "Mai · récap prêt — avant le 5 juin", unread: true),
        NotifItem(icon: "bubble.left.fill", color: AppTheme.Colors.blue,
                  title: "Fatou", time: "12h10", body: "« Awa a bien dormi 😊 »", unread: true)
    ]
    private let yesterday: [NotifItem] = [
        NotifItem(icon: "checkmark", color: AppTheme.Colors.green,
                  title: "Awa a été récupérée", time: "Hier", body: "17h05 · par Maman", unread: false)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    section("Aujourd'hui", today)
                    section("Hier", yesterday)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.md)
            }
            .background(AppTheme.Colors.paper.ignoresSafeArea())
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") { dismiss() }.foregroundColor(AppTheme.Colors.brand)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tout lire") {}.foregroundColor(AppTheme.Colors.brand)
                }
            }
        }
    }

    private func section(_ label: String, _ items: [NotifItem]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(AppTheme.Colors.muted)
                .tracking(1)
                .padding(.leading, 4)
            ForEach(items) { item in row(item) }
        }
    }

    private func row(_ item: NotifItem) -> some View {
        HStack(alignment: .top, spacing: 11) {
            RoundedRectangle(cornerRadius: 11)
                .fill(item.color)
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: item.icon).font(.system(size: 16, weight: .bold)).foregroundColor(.white))
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text(item.title).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(AppTheme.Colors.ink)
                    Spacer()
                    Text(item.time).font(.system(size: 11, weight: .bold, design: .rounded)).foregroundColor(AppTheme.Colors.muted.opacity(0.8))
                }
                Text(item.body).font(.system(size: 12.5, weight: .semibold, design: .rounded)).foregroundColor(AppTheme.Colors.muted)
            }
            if item.unread {
                Circle().fill(AppTheme.Colors.brand).frame(width: 8, height: 8).padding(.top, 6)
            }
        }
        .padding(11)
        .background(RoundedRectangle(cornerRadius: 14).fill(item.unread ? AppTheme.Colors.brandGhost : Color.clear))
    }
}

// MARK: Déclaration Pajemploi

/// Overlay Déclaration : net du mois calculé + extrait copiable (cf. « Focus Overlays »).
/// Montants représentatifs tant que le calcul Pajemploi réel n'est pas branché.
struct DeclarationOverlay: View {
    @Environment(\.dismiss) private var dismiss
    @State private var declared = false

    private let lines: [(String, String)] = [
        ("Heures d'accueil", "86 h"),
        ("Salaire net", "387,00 €"),
        ("Indemnités d'entretien", "70,00 €")
    ]

    private func monthName(_ offset: Int) -> String {
        let d = Calendar.current.date(byAdding: .month, value: offset, to: Date()) ?? Date()
        let f = DateFormatter(); f.locale = Locale(identifier: "fr_FR"); f.dateFormat = "LLLL yyyy"
        return f.string(from: d).capitalized
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    // Hero
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NET À PAYER À FATOU")
                            .font(.system(size: 10.5, weight: .heavy, design: .rounded))
                            .foregroundColor(.white.opacity(0.92)).tracking(1)
                        Text("472,00 €")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        HStack(spacing: 18) {
                            heroStat("Heures", "86 h")
                            heroStat("Jours", "20")
                            Spacer()
                            Text("avant le 5 \(monthName(1).components(separatedBy: " ").first ?? "")")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 22).fill(AppTheme.Colors.brand))
                    .shadow(color: AppTheme.Colors.brand.opacity(0.45), radius: 16, y: 10)

                    // À reporter
                    HStack {
                        Text("À REPORTER SUR PAJEMPLOI")
                            .font(.system(size: 10.5, weight: .heavy, design: .rounded))
                            .foregroundColor(AppTheme.Colors.muted).tracking(1)
                        Spacer()
                        Button {
                            UIPasteboard.general.string =
                                "Heures: 86 h\nSalaire net: 387,00 €\nIndemnités: 70,00 €\nNet à payer: 472,00 €"
                        } label: {
                            Label("Copier", systemImage: "doc.on.doc")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.Colors.brand)
                        }
                    }
                    .padding(.top, 4)

                    VStack(spacing: 0) {
                        ForEach(Array(lines.enumerated()), id: \.offset) { _, l in
                            extractLine(l.0, l.1, total: false)
                            Rectangle().fill(AppTheme.Colors.divider).frame(height: 1)
                        }
                        extractLine("Net à payer", "472,00 €", total: true)
                    }
                    .padding(.horizontal, 14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(AppTheme.Colors.surface))
                    .shadow(color: AppTheme.Shadow.small.color, radius: AppTheme.Shadow.small.radius, y: 1)

                    Button {
                        declared = true
                    } label: {
                        Text(declared ? "Déclaré ✓" : "Marquer comme déclaré")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 48)
                            .background(RoundedRectangle(cornerRadius: 14).fill(declared ? AppTheme.Colors.green : AppTheme.Colors.brand))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.md)
            }
            .background(AppTheme.Colors.paper.ignoresSafeArea())
            .navigationTitle(monthName(0))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") { dismiss() }.foregroundColor(AppTheme.Colors.brand)
                }
            }
        }
    }

    private func heroStat(_ k: String, _ v: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(k).font(.system(size: 11, weight: .bold, design: .rounded)).foregroundColor(.white.opacity(0.85))
            Text(v).font(.system(size: 17, weight: .bold, design: .rounded)).foregroundColor(.white)
        }
    }

    private func extractLine(_ label: String, _ value: String, total: Bool) -> some View {
        HStack {
            Text(label).font(.system(size: total ? 14 : 13.5, weight: total ? .heavy : .bold, design: .rounded))
                .foregroundColor(AppTheme.Colors.ink)
            Spacer()
            Text(value).font(.system(size: total ? 17 : 14, weight: .bold, design: .rounded))
                .foregroundColor(total ? AppTheme.Colors.brand : AppTheme.Colors.ink)
        }
        .padding(.vertical, 11)
    }
}
