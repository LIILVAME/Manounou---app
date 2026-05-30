// PlanningView.swift — Manounou
// Planning screen — lets parents configure their childcare schedule
// Brand #FA4270 · SF Rounded · paper background #F4F2EC

import SwiftUI

// MARK: - Models

struct SitterSlot: Identifiable {
    let id = UUID()
    var date: Date
    var name: String
    var arrive: String
    var leave: String
}

// MARK: - Person colour helper

private enum Person: String, CaseIterable {
    case papa  = "Papa"
    case maman = "Maman"
    case mamie = "Mamie"
    case fatou = "Fatou"
    case lea   = "Léa"

    var color: Color {
        switch self {
        case .papa:  return Color(hex: "2E7BEE")
        case .maman: return Color(hex: "7A5AE0")
        case .mamie: return Color(hex: "1FA87A")
        case .fatou: return Color(hex: "FA4270")
        case .lea:   return Color(hex: "FF8A3D")
        }
    }

    static func color(for name: String) -> Color {
        allCases.first { $0.rawValue == name }?.color ?? AppTheme.Colors.muted
    }
}

// MARK: - Day schedule model

private struct DaySchedule {
    let index: Int        // 1 = Mon … 7 = Sun
    let shortName: String
    let isWorkDay: Bool
    let dropTime: String
    let pickTime: String
    let carer: String
    let dropBy: String
    let pickBy: String
}

private let demoWeek: [DaySchedule] = [
    DaySchedule(index: 1, shortName: "Lun", isWorkDay: true,  dropTime: "9h00",  pickTime: "17h00", carer: "Fatou", dropBy: "Papa",  pickBy: "Maman"),
    DaySchedule(index: 2, shortName: "Mar", isWorkDay: true,  dropTime: "9h00",  pickTime: "17h00", carer: "Fatou", dropBy: "Papa",  pickBy: "Maman"),
    DaySchedule(index: 3, shortName: "Mer", isWorkDay: true,  dropTime: "9h00",  pickTime: "17h00", carer: "Fatou", dropBy: "Papa",  pickBy: "Maman"),
    DaySchedule(index: 4, shortName: "Jeu", isWorkDay: true,  dropTime: "9h00",  pickTime: "17h00", carer: "Fatou", dropBy: "Papa",  pickBy: "Maman"),
    DaySchedule(index: 5, shortName: "Ven", isWorkDay: true,  dropTime: "9h00",  pickTime: "17h00", carer: "Fatou", dropBy: "Papa",  pickBy: "Maman"),
    DaySchedule(index: 6, shortName: "Sam", isWorkDay: false, dropTime: "",      pickTime: "",      carer: "",      dropBy: "",      pickBy: ""),
    DaySchedule(index: 7, shortName: "Dim", isWorkDay: false, dropTime: "",      pickTime: "",      carer: "",      dropBy: "",      pickBy: ""),
]

private let dayLetters = ["L", "M", "M", "J", "V", "S", "D"]

// MARK: - PlanningView

struct PlanningView: View {

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
    @State private var sitters: [SitterSlot] = []

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    cetteMaineCard
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
        }
        .sheet(isPresented: $showingAddSitter) {
            AddSitterSheet(sitters: $sitters)
        }
    }

    // MARK: - Cette semaine card

    private var cetteMaineCard: some View {
        VStack(spacing: 0) {
            // Header row
            HStack {
                Text("CETTE SEMAINE")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.muted)
                    .tracking(1.2)
                Spacer()
                Button {
                    withAnimation(AppTheme.Animation.standard) {
                        isEditing.toggle()
                    }
                } label: {
                    Text(isEditing ? "Terminer" : "Modifier")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.brand)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.sm)

            Rectangle()
                .fill(AppTheme.Colors.divider)
                .frame(height: 1)

            // Day rows
            ForEach(Array(demoWeek.enumerated()), id: \.offset) { idx, day in
                VStack(spacing: 0) {
                    DayRow(day: day)
                    if idx < demoWeek.count - 1 {
                        Rectangle()
                            .fill(AppTheme.Colors.divider)
                            .frame(height: 1)
                            .padding(.leading, AppTheme.Spacing.md)
                    }
                }
            }

            Spacer(minLength: AppTheme.Spacing.xs)
        }
        .themedCard()
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

                // Person pickers
                PersonPickerRow(label: "Déposé par", selection: $dropBy)
                PersonPickerRow(label: "Récupéré par", selection: $pickBy)
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
            PlanSectionLabel(title: "BABY-SITTER PONCTUEL")

            VStack(spacing: 0) {
                if sitters.isEmpty {
                    emptySittersPlaceholder
                } else {
                    ForEach(Array(sitters.enumerated()), id: \.element.id) { idx, slot in
                        VStack(spacing: 0) {
                            SitterRow(slot: slot) {
                                withAnimation(AppTheme.Animation.quick) {
                                    sitters.removeAll { $0.id == slot.id }
                                }
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
                                        carer: entry.carer)
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
        let carer: String
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
                    carer: "Fatou"
                ))
            }
        }
        return entries
    }
}

// MARK: - DayRow

private struct DayRow: View {
    let day: DaySchedule

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            // Day abbreviation
            Text(day.shortName)
                .font(AppTheme.Typography.bodyBold)
                .foregroundColor(AppTheme.Colors.ink)
                .frame(width: 34, alignment: .leading)

            if day.isWorkDay {
                // Time range pill
                Text("\(day.dropTime)–\(day.pickTime)")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.brand)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.brandLight)
                    .clipShape(Capsule())

                Spacer()

                // Carer chip
                PersonChip(name: day.carer)
            } else {
                Text("Repos")
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(AppTheme.Colors.muted)
                Spacer()
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, 12)
    }
}

// MARK: - PersonChip

private struct PersonChip: View {
    let name: String

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Person.color(for: name))
                .frame(width: 7, height: 7)
            Text(name)
                .font(AppTheme.Typography.caption2)
                .foregroundColor(Person.color(for: name))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(Person.color(for: name).opacity(0.10))
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
    let carer: String

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

            PersonChip(name: carer)
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

    private let options = ["Papa", "Maman", "Mamie"]

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Text(label)
                .font(AppTheme.Typography.callout)
                .foregroundColor(AppTheme.Colors.ink)

            Spacer()

            HStack(spacing: 6) {
                ForEach(options, id: \.self) { option in
                    let active = selection == option
                    Button {
                        withAnimation(AppTheme.Animation.quick) {
                            selection = option
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Person.color(for: option))
                                .frame(width: 7, height: 7)
                            Text(option)
                                .font(AppTheme.Typography.caption2)
                                .foregroundColor(active ? Person.color(for: option) : AppTheme.Colors.muted)
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(
                            active
                                ? Person.color(for: option).opacity(0.12)
                                : AppTheme.Colors.surfaceAlt
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    active ? Person.color(for: option).opacity(0.35) : Color.clear,
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
    @Binding var sitters: [SitterSlot]
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
                        let slot = SitterSlot(
                            date: date,
                            name: name.trimmingCharacters(in: .whitespaces),
                            arrive: arriveTime,
                            leave: leaveTime
                        )
                        sitters.append(slot)
                        sitters.sort { $0.date < $1.date }
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
        PlanningView()
            .preferredColorScheme(.light)
            .previewDisplayName("Light")

        PlanningView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark")
    }
}
#endif
