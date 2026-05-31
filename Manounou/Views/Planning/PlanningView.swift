// PlanningView.swift — Manounou
// Planning screen — lets parents configure their childcare schedule
// Brand #FA4270 · SF Rounded · paper background #F4F2EC

import SwiftUI

// MARK: - Models

struct SitterSlot: Identifiable {
    let id: UUID            // = id de l'événement Supabase sous-jacent
    var date: Date
    var name: String
    var arrive: String
    var leave: String

    /// Construit un créneau d'affichage à partir d'un événement Supabase.
    init(event: Event) {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        self.id = event.id
        self.date = event.startDate
        self.name = event.title
        self.arrive = f.string(from: event.startDate)
        self.leave = f.string(from: event.endDate)
    }
}

private let dayLetters = ["L", "M", "M", "J", "V", "S", "D"]

// MARK: - PlanningView

struct PlanningView: View {

    /// Marqueur (champ `description`) distinguant un créneau baby-sitter des
    /// autres événements de la table `events`.
    private static let babysitterTag = "babysitter"

    @EnvironmentObject private var eventsViewModel:            EventsViewModel
    @EnvironmentObject private var planningScheduleViewModel:  PlanningScheduleViewModel
    @EnvironmentObject private var householdViewModel:         HouseholdViewModel

    // MARK: State — editing

    @State private var isEditing    = false
    @State private var scheduleMode = 0            // 0 = fixed, 1 = rotation
    @State private var activeDays   = Set([1, 2, 3, 4, 5])  // Mon–Fri by default
    @State private var dropTime     = "09:00"
    @State private var pickTime     = "17:00"
    @State private var dropBy       = "Papa"
    @State private var pickBy       = "Maman"

    // MARK: State — baby-sitters

    @State private var showingAddSitter = false

    /// Créneaux baby-sitter dérivés des événements Supabase (source de vérité).
    private var sitters: [SitterSlot] {
        eventsViewModel.events
            .filter { $0.description == Self.babysitterTag }
            .sorted { $0.startDate < $1.startDate }
            .map { SitterSlot(event: $0) }
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    cetteSemaineCard
                    organisationCard
                    if isEditing {
                        typeDeGardeSection
                        editeurSection
                    }
                    babySitterSection
                    prochainsGardesSection
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.bottom, AppTheme.Spacing.xl)
            }
            .background(AppTheme.Colors.paper.ignoresSafeArea())
            .navigationTitle("Planning")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await eventsViewModel.loadEvents()
                let vm = planningScheduleViewModel
                scheduleMode = vm.scheduleMode
                activeDays   = vm.activeDays
                dropTime     = vm.dropTime
                pickTime     = vm.pickTime
                dropBy       = vm.dropBy
                pickBy       = vm.pickBy
            }
            .onChange(of: isEditing) { editing in
                if !editing {
                    planningScheduleViewModel.scheduleMode = scheduleMode
                    planningScheduleViewModel.activeDays   = activeDays
                    planningScheduleViewModel.dropTime     = dropTime
                    planningScheduleViewModel.pickTime     = pickTime
                    planningScheduleViewModel.dropBy       = dropBy
                    planningScheduleViewModel.pickBy       = pickBy
                    Task { await planningScheduleViewModel.saveSchedule() }
                }
            }
        }
        .sheet(isPresented: $showingAddSitter) {
            AddSitterSheet { date, name, arrive, leave in
                addSitter(date: date, name: name, arrive: arrive, leave: leave)
            }
        }
        // Échec d'écriture/chargement Supabase : visible en dev, jamais en prod.
        .debugErrorAlert($eventsViewModel.errorMessage)
    }

    // MARK: - Sitter persistence (Supabase events)

    private func addSitter(date: Date, name: String, arrive: String, leave: String) {
        let start = combine(date, arrive)
        var end = combine(date, leave)
        // Respecte la contrainte events_valid_range (end_date >= start_date) :
        // un créneau qui « passe minuit » bascule la fin au lendemain.
        if end <= start {
            end = Calendar.current.date(byAdding: .day, value: 1, to: end) ?? start.addingTimeInterval(3600)
        }
        let event = Event(
            title: name,
            description: Self.babysitterTag,
            startDate: start,
            endDate: end,
            eventType: EventType(name: "Baby-sitter", icon: "person.fill", color: AppTheme.Colors.brand)
        )
        Task { await eventsViewModel.createEvent(event) }
    }

    private func deleteSitter(_ slot: SitterSlot) {
        guard let event = eventsViewModel.events.first(where: { $0.id == slot.id }) else { return }
        Task { await eventsViewModel.deleteEvent(event) }
    }

    /// Combine un jour et une heure "HH:MM" en une Date.
    private func combine(_ day: Date, _ hhmm: String) -> Date {
        let parts = hhmm.split(separator: ":")
        let h = min(max(Int(parts.first ?? "") ?? 9, 0), 23)
        let m = parts.count > 1 ? min(max(Int(parts[1]) ?? 0, 0), 59) : 0
        return Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: day) ?? day
    }

    // MARK: - Cette semaine (strip compact, cohérent avec l'accueil)

    /// 0 = lundi … 6 = dimanche
    private var todayWeekdayIndex: Int {
        let raw = Calendar.current.component(.weekday, from: Date()) // 1=dim … 7=sam
        return (raw + 5) % 7
    }

    private func hhmm(_ s: String) -> String { s.replacingOccurrences(of: ":", with: "h") }

    private var cetteSemaineCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PlanSectionLabel(title: "CETTE SEMAINE")

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { i in
                        let isGarde = activeDays.contains(i + 1)
                        let isToday = i == todayWeekdayIndex
                        VStack(spacing: 6) {
                            Text(dayLetters[i])
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(isToday ? AppTheme.Colors.brand
                                                 : (isGarde ? AppTheme.Colors.ink : AppTheme.Colors.muted))
                            Circle()
                                .fill(isGarde ? AppTheme.Colors.brand : Color.clear)
                                .frame(width: 7, height: 7)
                                .overlay(
                                    Circle().stroke(isGarde ? AppTheme.Colors.brand : AppTheme.Colors.border,
                                                    lineWidth: 1.5)
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.top, AppTheme.Spacing.sm)

                // Footer : semaine active du roulement + horaires
                HStack(spacing: 8) {
                    Text(scheduleMode == 1 ? "Sem. A" : "Horaires fixes")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.Colors.brand)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 8).fill(AppTheme.Colors.brandGhost))
                    Text("\(hhmm(dropTime))–\(hhmm(pickTime))")
                        .font(.system(size: 13.5, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.Colors.ink)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .overlay(
                    Rectangle().fill(AppTheme.Colors.divider).frame(height: 1),
                    alignment: .top
                )
                .padding(.top, 5)
            }
            .themedCard()
        }
    }

    // MARK: - Organisation (entrée du configurateur)

    private var organisationCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PlanSectionLabel(title: "ORGANISATION")

            Button {
                withAnimation(AppTheme.Animation.standard) { isEditing.toggle() }
            } label: {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.Colors.brandGhost)
                        .frame(width: 42, height: 42)
                        .overlay(
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.brand)
                        )
                    VStack(alignment: .leading, spacing: 1) {
                        Text(scheduleMode == 1 ? "Roulement · 3 semaines" : "Horaires fixes")
                            .font(.system(size: 15.5, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.Colors.ink)
                        Text("Gérée avec \(planningScheduleViewModel.carerName)")
                            .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.Colors.muted)
                    }
                    Spacer(minLength: 0)
                    Text(isEditing ? "Fermer" : "Modifier")
                        .font(.system(size: 12.5, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.Colors.brand)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.muted.opacity(0.5))
                }
                .padding(15)
                .themedCard()
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Type de garde section

    private var typeDeGardeSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PlanSectionLabel(title: "TYPE DE GARDE")

            VStack(spacing: 0) {
                Picker("", selection: $scheduleMode) {
                    Text("Horaires fixes").tag(0)
                    Text("Roulement de semaines").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(AppTheme.Spacing.md)
            }
            .themedCard()
        }
    }

    // MARK: - Éditeur d'horaires section

    private var editeurSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PlanSectionLabel(title: "ÉDITEUR D'HORAIRES")

            VStack(spacing: AppTheme.Spacing.md) {
                // Day toggles — L M M J V S D
                dayToggleRow

                Rectangle()
                    .fill(AppTheme.Colors.divider)
                    .frame(height: 1)

                // Time pickers
                HStack(spacing: AppTheme.Spacing.md) {
                    PlanTimeField(label: "Dépôt", time: $dropTime)
                    PlanTimeField(label: "Récupération", time: $pickTime)
                }

                Rectangle()
                    .fill(AppTheme.Colors.divider)
                    .frame(height: 1)

                // Person pickers (options from household members)
                let memberNames = householdViewModel.memberNames.isEmpty
                    ? ["Papa", "Maman"]
                    : householdViewModel.memberNames
                let colorFor: (String) -> Color = { name in
                    Color(hex: householdViewModel.hexColor(for: name))
                }
                PersonPickerRow(label: "Déposé par",   selection: $dropBy,
                                options: memberNames, colorForName: colorFor)
                PersonPickerRow(label: "Récupéré par", selection: $pickBy,
                                options: memberNames, colorForName: colorFor)

                Rectangle()
                    .fill(AppTheme.Colors.divider)
                    .frame(height: 1)

                // Nom du caregiving (nourrice/nounou)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nom de la garde")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.muted)
                        .tracking(0.3)
                    TextField("ex. Fatou", text: $planningScheduleViewModel.carerName)
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(AppTheme.Colors.ink)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, 10)
                        .background(AppTheme.Colors.surfaceAlt)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm))
                }
            }
            .padding(AppTheme.Spacing.md)
            .themedCard()
        }
    }

    private var dayToggleRow: some View {
        HStack {
            Spacer()
            ForEach(0..<7) { i in
                let dayIndex = i + 1
                let isActive = activeDays.contains(dayIndex)
                Button {
                    withAnimation(AppTheme.Animation.quick) {
                        if isActive {
                            activeDays.remove(dayIndex)
                        } else {
                            activeDays.insert(dayIndex)
                        }
                    }
                } label: {
                    Text(dayLetters[i])
                        .font(AppTheme.Typography.footnote)
                        .frame(width: 36, height: 36)
                        .foregroundColor(isActive ? .white : AppTheme.Colors.muted)
                        .background(isActive ? AppTheme.Colors.brand : AppTheme.Colors.surfaceAlt)
                        .clipShape(Circle())
                }
                if i < 6 { Spacer() }
            }
            Spacer()
        }
    }

    // MARK: - Baby-sitter ponctuel section

    private var babySitterSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PlanSectionLabel(title: "BABY-SITTER & EXCEPTIONS")

            VStack(spacing: 0) {
                if sitters.isEmpty {
                    emptySittersPlaceholder
                } else {
                    ForEach(Array(sitters.enumerated()), id: \.element.id) { idx, slot in
                        VStack(spacing: 0) {
                            SitterRow(slot: slot) {
                                deleteSitter(slot)
                            }
                            if idx < sitters.count - 1 {
                                Rectangle()
                                    .fill(AppTheme.Colors.divider)
                                    .frame(height: 1)
                                    .padding(.leading, AppTheme.Spacing.md)
                            }
                        }
                    }
                }

                Rectangle()
                    .fill(AppTheme.Colors.divider)
                    .frame(height: 1)

                // Ajouter button — secondary / outlined style
                Button {
                    showingAddSitter = true
                } label: {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "plus.circle.fill")
                        Text("Ajouter un baby-sitter ponctuel")
                            .font(AppTheme.Typography.bodyMedium)
                    }
                    .foregroundColor(AppTheme.Colors.brand)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.md)
                }
            }
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card)
                    .strokeBorder(AppTheme.Colors.brand.opacity(0.30), lineWidth: 1.5)
            )
            .shadow(color: AppTheme.Shadow.card.color,
                    radius: AppTheme.Shadow.card.radius,
                    x: AppTheme.Shadow.card.x,
                    y: AppTheme.Shadow.card.y)
        }
    }

    private var emptySittersPlaceholder: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "person.crop.circle.badge.clock")
                .font(.system(size: 36, weight: .light))
                .foregroundColor(AppTheme.Colors.muted.opacity(0.7))
            Text("Aucun baby-sitter prévu")
                .font(AppTheme.Typography.callout)
                .foregroundColor(AppTheme.Colors.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
    }

    // MARK: - Prochains gardes section

    private var prochainsGardesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            PlanSectionLabel(title: "PROCHAINS GARDES")

            VStack(spacing: 0) {
                let upcoming = nextCareDays()
                ForEach(Array(upcoming.enumerated()), id: \.offset) { idx, entry in
                    VStack(spacing: 0) {
                        UpcomingCareRow(weekday: entry.weekday,
                                        dateStr: entry.dateStr,
                                        timeRange: entry.timeRange,
                                        dropBy: entry.dropBy,
                                        pickBy: entry.pickBy,
                                        colorForName: { name in
                                            Color(hex: householdViewModel.hexColor(for: name))
                                        })
                        if idx < upcoming.count - 1 {
                            Rectangle()
                                .fill(AppTheme.Colors.divider)
                                .frame(height: 1)
                                .padding(.leading, AppTheme.Spacing.md)
                        }
                    }
                }
            }
            .themedCard()
        }
    }

    // MARK: - Upcoming care day calculation

    private struct UpcomingEntry {
        let weekday: String
        let dateStr: String
        let timeRange: String
        let dropBy: String
        let pickBy: String
    }

    private func nextCareDays() -> [UpcomingEntry] {
        var entries: [UpcomingEntry] = []
        var cursor = Date()
        let cal = Calendar.current
        let wdFormatter = DateFormatter()
        wdFormatter.locale = Locale(identifier: "fr_FR")
        wdFormatter.dateFormat = "EEE"
        let dtFormatter = DateFormatter()
        dtFormatter.locale = Locale(identifier: "fr_FR")
        dtFormatter.dateFormat = "d MMM"

        while entries.count < 5 {
            guard let next = cal.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
            // Convert Sunday=1…Saturday=7 (Gregorian) → Mon=1…Sun=7
            let greg = cal.component(.weekday, from: cursor)
            let normalized = greg == 1 ? 7 : greg - 1
            if activeDays.contains(normalized) {
                let wd = wdFormatter.string(from: cursor).capitalized
                let dt = dtFormatter.string(from: cursor)
                entries.append(UpcomingEntry(
                    weekday: wd,
                    dateStr: dt,
                    timeRange: "\(dropTime.replacingOccurrences(of: ":", with: "h"))–\(pickTime.replacingOccurrences(of: ":", with: "h"))",
                    dropBy: dropBy,
                    pickBy: pickBy
                ))
            }
        }
        return entries
    }
}

// MARK: - PersonChip

private struct PersonChip: View {
    let name: String
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(name)
                .font(AppTheme.Typography.caption2)
                .foregroundColor(color)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(color.opacity(0.10))
        .clipShape(Capsule())
    }
}

// MARK: - SitterRow

private struct SitterRow: View {
    let slot: SitterSlot
    let onDelete: () -> Void

    @State private var showConfirm = false

    private var formattedDate: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr_FR")
        df.dateFormat = "EEE d MMM"
        return df.string(from: slot.date).capitalized
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(slot.name)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.ink)
                Text(formattedDate)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.muted)
            }

            Spacer()

            Text("\(slot.arrive)–\(slot.leave)")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.brand)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(AppTheme.Colors.brandLight)
                .clipShape(Capsule())

            Button {
                showConfirm = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.Colors.muted)
            }
            .confirmationDialog("Supprimer ce créneau ?", isPresented: $showConfirm, titleVisibility: .visible) {
                Button("Supprimer", role: .destructive) { onDelete() }
                Button("Annuler", role: .cancel) {}
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, 13)
    }
}

// MARK: - UpcomingCareRow

private struct UpcomingCareRow: View {
    let weekday: String
    let dateStr: String
    let timeRange: String
    let dropBy: String
    let pickBy: String
    var colorForName: (String) -> Color = { _ in AppTheme.Colors.muted }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            VStack(alignment: .leading, spacing: 1) {
                Text(weekday)
                    .font(AppTheme.Typography.footnote)
                    .foregroundColor(AppTheme.Colors.muted)
                Text(dateStr)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.ink)
            }

            Spacer()

            Text(timeRange)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.brand)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(AppTheme.Colors.brandLight)
                .clipShape(Capsule())

            // Dépose → récup (pilotés par l'éditeur d'horaires)
            HStack(spacing: 3) {
                PersonChip(name: dropBy, color: colorForName(dropBy))
                Image(systemName: "arrow.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(AppTheme.Colors.muted.opacity(0.6))
                PersonChip(name: pickBy, color: colorForName(pickBy))
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, 12)
    }
}

// MARK: - PlanTimeField

private struct PlanTimeField: View {
    let label: String
    @Binding var time: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(label)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.muted)
                .tracking(0.3)

            TextField("HH:MM", text: $time)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.Colors.ink)
                .keyboardType(.numbersAndPunctuation)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(AppTheme.Colors.surfaceAlt)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm))
        }
    }
}

// MARK: - PersonPickerRow

private struct PersonPickerRow: View {
    let label: String
    @Binding var selection: String
    let options: [String]
    let colorForName: (String) -> Color

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Text(label)
                .font(AppTheme.Typography.callout)
                .foregroundColor(AppTheme.Colors.ink)

            Spacer()

            HStack(spacing: 6) {
                ForEach(options, id: \.self) { option in
                    let active = selection == option
                    let accent = colorForName(option)
                    Button {
                        withAnimation(AppTheme.Animation.quick) {
                            selection = option
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(accent)
                                .frame(width: 7, height: 7)
                            Text(option)
                                .font(AppTheme.Typography.caption2)
                                .foregroundColor(active ? accent : AppTheme.Colors.muted)
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(
                            active
                                ? accent.opacity(0.12)
                                : AppTheme.Colors.surfaceAlt
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    active ? accent.opacity(0.35) : Color.clear,
                                    lineWidth: 1
                                )
                        )
                    }
                }
            }
        }
    }
}

// MARK: - PlanSectionLabel

private struct PlanSectionLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(AppTheme.Typography.caption)
            .foregroundColor(AppTheme.Colors.muted)
            .tracking(1.2)
            .padding(.leading, 4)
    }
}

// MARK: - AddSitterSheet

private struct AddSitterSheet: View {
    /// (date, nom, arrivée "HH:MM", départ "HH:MM")
    let onAdd: (Date, String, String, String) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var date       = Date()
    @State private var name       = ""
    @State private var arriveTime = "18:00"
    @State private var leaveTime  = "22:00"

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {

                    // DATE
                    sheetSection(title: "DATE") {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .tint(AppTheme.Colors.brand)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.bottom, AppTheme.Spacing.xs)
                            .background(AppTheme.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
                            .shadow(color: AppTheme.Shadow.small.color,
                                    radius: AppTheme.Shadow.small.radius,
                                    x: AppTheme.Shadow.small.x,
                                    y: AppTheme.Shadow.small.y)
                    }

                    // NOM DU BABY-SITTER
                    sheetSection(title: "NOM DU BABY-SITTER") {
                        TextField("ex. Léa, Marie…", text: $name)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.ink)
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, 13)
                            .background(AppTheme.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                    .strokeBorder(AppTheme.Colors.border, lineWidth: 1)
                            )
                    }

                    // HORAIRES
                    sheetSection(title: "HORAIRES") {
                        HStack(spacing: AppTheme.Spacing.md) {
                            PlanTimeField(label: "Arrivée", time: $arriveTime)
                            PlanTimeField(label: "Départ",  time: $leaveTime)
                        }
                        .padding(AppTheme.Spacing.md)
                        .background(AppTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
                        .shadow(color: AppTheme.Shadow.small.color,
                                radius: AppTheme.Shadow.small.radius,
                                x: AppTheme.Shadow.small.x,
                                y: AppTheme.Shadow.small.y)
                    }

                    // Submit
                    Button {
                        onAdd(date, name.trimmingCharacters(in: .whitespaces), arriveTime, leaveTime)
                        dismiss()
                    } label: {
                        Text("Ajouter")
                            .font(AppTheme.Typography.bodyBold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(isValid ? AppTheme.Colors.brand : AppTheme.Colors.muted.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.button))
                    }
                    .disabled(!isValid)
                    .animation(AppTheme.Animation.quick, value: isValid)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.xl)
            }
            .background(AppTheme.Colors.paper.ignoresSafeArea())
            .navigationTitle("Nouveau baby-sitter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                        .foregroundColor(AppTheme.Colors.brand)
                }
            }
        }
    }

    @ViewBuilder
    private func sheetSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.muted)
                .tracking(1.2)
                .padding(.leading, 4)
            content()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct PlanningView_Previews: PreviewProvider {
    static var previews: some View {
        let container = AppContainer.createForTesting()
        return Group {
            PlanningView()
                .environmentObject(container.eventsViewModel)
                .preferredColorScheme(.light)
                .previewDisplayName("Light")

            PlanningView()
                .environmentObject(container.eventsViewModel)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark")
        }
    }
}
#endif
