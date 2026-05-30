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
            notificationsPlaceholder
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
            messagesPlaceholder
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

            notificationButton
        }
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

        // 3-step progress bar
        statusProgressBar

        // Next info line
        HStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: "clock")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.72))

            Text(nextInfoLine)
                .font(AppTheme.Typography.callout)
                .foregroundColor(.white.opacity(0.88))
        }
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

    // MARK: Status Progress Bar

    private var statusProgressBar: some View {
        let steps   = ["Dépôt", "Chez Fatou", "Récup"]
        let active  = currentStatus.stepIndex

        return HStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, label in
                stepDot(index: index, label: label, activeIndex: active,
                        isLast: index == steps.count - 1)
            }
        }
    }

    @ViewBuilder
    private func stepDot(
        index: Int,
        label: String,
        activeIndex: Int,
        isLast: Bool
    ) -> some View {
        let isCompleted = index < activeIndex
        let isCurrent   = index == activeIndex

        HStack(spacing: 0) {
            VStack(spacing: 5) {
                ZStack {
                    if isCurrent {
                        Circle()
                            .stroke(Color.white.opacity(0.6), lineWidth: 2)
                            .frame(width: 18, height: 18)
                    }
                    Circle()
                        .fill(isCompleted || isCurrent
                              ? Color.white
                              : Color.white.opacity(0.30))
                        .frame(width: 10, height: 10)
                }

                Text(label)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(
                        isCompleted || isCurrent
                            ? .white
                            : .white.opacity(0.45)
                    )
                    .fixedSize()
            }

            if !isLast {
                Rectangle()
                    .fill(isCompleted ? Color.white : Color.white.opacity(0.28))
                    .frame(height: 2)
                    .padding(.bottom, 16)   // visually align with dot center
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
        .padding(.vertical, AppTheme.Spacing.xs)
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

    private var notificationsPlaceholder: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.lg) {
                Spacer()
                Image(systemName: "bell.slash")
                    .font(.system(size: 52, weight: .light, design: .rounded))
                    .foregroundColor(AppTheme.Colors.muted)
                Text("Aucune notification")
                    .font(AppTheme.Typography.title3)
                    .foregroundColor(AppTheme.Colors.ink)
                Text("Vos notifications apparaîtront ici")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.muted)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.paper.ignoresSafeArea())
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var messagesPlaceholder: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.lg) {
                Spacer()
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 52, weight: .light, design: .rounded))
                    .foregroundColor(AppTheme.Colors.muted)
                Text("Messages")
                    .font(AppTheme.Typography.title3)
                    .foregroundColor(AppTheme.Colors.ink)
                Text("Fonctionnalité disponible prochainement")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.muted)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.paper.ignoresSafeArea())
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

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
