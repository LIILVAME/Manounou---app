//
//  ModernCalendarView.swift
//  Manounou
//
//  Created by Assistant on 18/08/2025.
//  Modern refactored version of CalendarView with NavigationStack
//

import SwiftUI

struct ModernCalendarView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @State private var showingAddEvent = false
    @State private var selectedDate = Date()
    @State private var selectedEvent: Event? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calendar Section
                CalendarSection(
                    selectedDate: $selectedDate,
                    events: eventsViewModel.events
                )
                
                Divider()
                    .background(AppTheme.Colors.border)
                
                // Events Section
                EventsSection(
                    events: filteredEvents,
                    selectedDate: selectedDate,
                    onEventSelected: { event in
                        selectedEvent = event
                    },
                    onDeleteEvents: { offsets in
                        deleteEvents(offsets: offsets)
                    },
                    onAddEvent: {
                        showingAddEvent = true
                    }
                )
            }
            .navigationTitle("Calendrier")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AddEventButton {
                        showingAddEvent = true
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventSheet(selectedDate: selectedDate) { newEvent in
                    Task {
                        await eventsViewModel.addEvent(newEvent)
                    }
                }
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailSheet(event: event) { updatedEvent in
                    Task {
                        await eventsViewModel.updateEvent(updatedEvent)
                    }
                }
            }
            .task {
                await eventsViewModel.loadEvents()
            }
            .refreshable {
                await eventsViewModel.loadEvents()
            }
        }
    }
    
    private var filteredEvents: [Event] {
        let calendar = Calendar.current
        return eventsViewModel.events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: selectedDate)
        }.sorted { $0.startDate < $1.startDate }
    }
    
    private func deleteEvents(offsets: IndexSet) {
        Task {
            for index in offsets {
                let event = filteredEvents[index]
                await eventsViewModel.deleteEvent(event.id)
            }
        }
    }
}

// MARK: - Calendar Section Component
struct CalendarSection: View {
    @Binding var selectedDate: Date
    let events: [Event]
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Date Picker
            DatePicker(
                "Date sélectionnée",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding(.horizontal, AppTheme.Spacing.md)
            .accessibilityLabel("Sélecteur de date pour le calendrier")
            
            // Selected Date Info
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(selectedDate, style: .date)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("\(eventsForSelectedDate.count) événement(s)")
                        .font(AppTheme.Typography.footnote)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                if !eventsForSelectedDate.isEmpty {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(AppTheme.Colors.primary)
                        .font(.title2)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.sm)
        }
        .background(AppTheme.Colors.surface)
    }
    
    private var eventsForSelectedDate: [Event] {
        let calendar = Calendar.current
        return events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: selectedDate)
        }
    }
}

// MARK: - Events Section Component
struct EventsSection: View {
    let events: [Event]
    let selectedDate: Date
    let onEventSelected: (Event) -> Void
    let onDeleteEvents: (IndexSet) -> Void
    let onAddEvent: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Section Header
            HStack {
                Text("Événements du jour")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Text(selectedDate, style: .date)
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.md)
            
            // Events List or Empty State
            if events.isEmpty {
                EmptyEventsView(
                    selectedDate: selectedDate,
                    onAddEvent: onAddEvent
                )
            } else {
                EventsList(
                    events: events,
                    onEventSelected: onEventSelected,
                    onDeleteEvents: onDeleteEvents
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppTheme.Colors.background)
    }
}

// MARK: - Empty Events Component
struct EmptyEventsView: View {
    let selectedDate: Date
    let onAddEvent: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: AppTheme.Icons.calendar)
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.textTertiary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Aucun événement")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Text("Planifiez votre premier événement pour cette date")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Ajouter un événement", action: onAddEvent)
                .themedButton(style: .primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppTheme.Spacing.xl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Aucun événement pour le \(selectedDate, style: .date). Planifiez votre premier événement")
        .accessibilityAction(named: "Ajouter un événement", onAddEvent)
    }
}

// MARK: - Events List Component
struct EventsList: View {
    let events: [Event]
    let onEventSelected: (Event) -> Void
    let onDeleteEvents: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(events) { event in
                ModernEventRowView(event: event) {
                    onEventSelected(event)
                }
            }
            .onDelete(perform: onDeleteEvents)
        }
        .listStyle(.insetGrouped)
        .accessibilityLabel("Liste des événements")
    }
}

// MARK: - Modern Event Row Component
struct ModernEventRowView: View {
    let event: Event
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Event Type Icon
                ZStack {
                    Circle()
                        .fill(eventTypeColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: eventTypeIcon)
                        .foregroundColor(eventTypeColor)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                // Event Details
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(event.title)
                        .font(AppTheme.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Text(event.startDate, style: .time)
                            .font(AppTheme.Typography.footnote)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        if let endDate = event.endDate {
                            Text("→")
                                .font(AppTheme.Typography.footnote)
                                .foregroundColor(AppTheme.Colors.textTertiary)
                            
                            Text(endDate, style: .time)
                                .font(AppTheme.Typography.footnote)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                    
                    if let description = event.description, !description.isEmpty {
                        Text(description)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Priority Indicator
                if event.priority == .high {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.error)
                        .font(.caption)
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
            .padding(.vertical, AppTheme.Spacing.xs)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Événement: \(event.title), \(event.startDate, style: .time)")
        .accessibilityHint("Appuyez pour voir les détails")
    }
    
    private var eventTypeColor: Color {
        switch event.eventType {
        case .appointment: return AppTheme.Colors.primary
        case .vaccination: return AppTheme.Colors.success
        case .milestone: return AppTheme.Colors.warning
        case .reminder: return AppTheme.Colors.info
        default: return AppTheme.Colors.secondary
        }
    }
    
    private var eventTypeIcon: String {
        switch event.eventType {
        case .appointment: return AppTheme.Icons.appointment
        case .vaccination: return AppTheme.Icons.vaccination
        case .milestone: return AppTheme.Icons.milestone
        case .reminder: return AppTheme.Icons.reminder
        default: return AppTheme.Icons.calendar
        }
    }
}

// MARK: - Add Event Button Component
struct AddEventButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(AppTheme.Colors.primary)
        }
        .accessibilityLabel("Ajouter un événement")
        .accessibilityHint("Ouvre le formulaire pour ajouter un nouvel événement")
    }
}

// MARK: - Add Event Sheet Component
struct AddEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    let selectedDate: Date
    let onSave: (Event) -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var eventType = EventType.appointment
    @State private var priority = EventPriority.medium
    @State private var isAllDay = false
    @State private var isLoading = false
    
    init(selectedDate: Date, onSave: @escaping (Event) -> Void) {
        self.selectedDate = selectedDate
        self.onSave = onSave
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let defaultStart = calendar.date(byAdding: .hour, value: 9, to: startOfDay) ?? selectedDate
        let defaultEnd = calendar.date(byAdding: .hour, value: 1, to: defaultStart) ?? selectedDate
        
        self._startDate = State(initialValue: defaultStart)
        self._endDate = State(initialValue: defaultEnd)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations de l'événement") {
                    ThemedTextField(
                        "Titre",
                        text: $title,
                        placeholder: "Entrez le titre de l'événement"
                    )
                    
                    ThemedTextField(
                        "Description",
                        text: $description,
                        placeholder: "Description optionnelle"
                    )
                }
                
                Section("Date et heure") {
                    Toggle("Toute la journée", isOn: $isAllDay)
                        .font(AppTheme.Typography.body)
                    
                    DatePicker(
                        "Début",
                        selection: $startDate,
                        displayedComponents: isAllDay ? .date : [.date, .hourAndMinute]
                    )
                    .font(AppTheme.Typography.body)
                    
                    if !isAllDay {
                        DatePicker(
                            "Fin",
                            selection: $endDate,
                            in: startDate...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .font(AppTheme.Typography.body)
                    }
                }
                
                Section("Détails") {
                    Picker("Type d'événement", selection: $eventType) {
                        ForEach(EventType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Priorité", selection: $priority) {
                        ForEach(EventPriority.allCases, id: \.self) { priorityLevel in
                            Text(priorityLevel.displayName).tag(priorityLevel)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Nouvel événement")
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
                        saveEvent()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .disabled(title.isEmpty || isLoading)
                }
            }
        }
        .interactiveDismissDisabled(isLoading)
    }
    
    private func saveEvent() {
        isLoading = true
        
        let finalEndDate = isAllDay ? nil : endDate
        
        let newEvent = Event(
            id: UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: startDate,
            endDate: finalEndDate,
            eventType: eventType,
            priority: priority,
            isAllDay: isAllDay,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        onSave(newEvent)
        dismiss()
    }
}

// MARK: - Event Detail Sheet Component
struct EventDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let event: Event
    let onSave: (Event) -> Void
    
    @State private var title: String
    @State private var description: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var eventType: EventType
    @State private var priority: EventPriority
    @State private var isAllDay: Bool
    @State private var isLoading = false
    
    init(event: Event, onSave: @escaping (Event) -> Void) {
        self.event = event
        self.onSave = onSave
        self._title = State(initialValue: event.title)
        self._description = State(initialValue: event.description ?? "")
        self._startDate = State(initialValue: event.startDate)
        self._endDate = State(initialValue: event.endDate ?? event.startDate)
        self._eventType = State(initialValue: event.eventType)
        self._priority = State(initialValue: event.priority)
        self._isAllDay = State(initialValue: event.isAllDay)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations de l'événement") {
                    ThemedTextField(
                        "Titre",
                        text: $title,
                        placeholder: "Entrez le titre de l'événement"
                    )
                    
                    ThemedTextField(
                        "Description",
                        text: $description,
                        placeholder: "Description optionnelle"
                    )
                }
                
                Section("Date et heure") {
                    Toggle("Toute la journée", isOn: $isAllDay)
                        .font(AppTheme.Typography.body)
                    
                    DatePicker(
                        "Début",
                        selection: $startDate,
                        displayedComponents: isAllDay ? .date : [.date, .hourAndMinute]
                    )
                    .font(AppTheme.Typography.body)
                    
                    if !isAllDay {
                        DatePicker(
                            "Fin",
                            selection: $endDate,
                            in: startDate...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .font(AppTheme.Typography.body)
                    }
                }
                
                Section("Détails") {
                    Picker("Type d'événement", selection: $eventType) {
                        ForEach(EventType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Priorité", selection: $priority) {
                        ForEach(EventPriority.allCases, id: \.self) { priorityLevel in
                            Text(priorityLevel.displayName).tag(priorityLevel)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Informations") {
                    HStack {
                        Text("Créé le")
                        Spacer()
                        Text(event.createdAt, style: .date)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    if event.updatedAt != event.createdAt {
                        HStack {
                            Text("Modifié le")
                            Spacer()
                            Text(event.updatedAt, style: .date)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                }
            }
            .navigationTitle("Modifier l'événement")
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
                        saveEvent()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .disabled(title.isEmpty || isLoading)
                }
            }
        }
        .interactiveDismissDisabled(isLoading)
    }
    
    private func saveEvent() {
        isLoading = true
        
        let finalEndDate = isAllDay ? nil : endDate
        
        let updatedEvent = Event(
            id: event.id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: startDate,
            endDate: finalEndDate,
            eventType: eventType,
            priority: priority,
            isAllDay: isAllDay,
            createdAt: event.createdAt,
            updatedAt: Date()
        )
        
        onSave(updatedEvent)
        dismiss()
    }
}

// MARK: - Extensions
extension EventType {
    var displayName: String {
        switch self {
        case .appointment: return "Rendez-vous"
        case .vaccination: return "Vaccination"
        case .milestone: return "Étape importante"
        case .reminder: return "Rappel"
        default: return "Autre"
        }
    }
}

extension EventPriority {
    var displayName: String {
        switch self {
        case .low: return "Faible"
        case .medium: return "Moyenne"
        case .high: return "Élevée"
        }
    }
}

// MARK: - Preview
#if DEBUG
struct ModernCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ModernCalendarView()
            .environmentObject(EventsViewModel(eventsService: MockEventsService()))
            .preferredColorScheme(.light)
        
        ModernCalendarView()
            .environmentObject(EventsViewModel(eventsService: MockEventsService()))
            .preferredColorScheme(.dark)
    }
}
#endif