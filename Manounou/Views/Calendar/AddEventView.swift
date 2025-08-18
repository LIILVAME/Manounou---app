//
//  AddEventView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    
    // Form fields
    @State private var title = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600) // +1 hour
    @State private var selectedEventType: EventType = EventType.defaultTypes[0]
    @State private var selectedChildren: Set<UUID> = []
    @State private var isAllDay = false
    
    // UI state
    @State private var isLoading = false
    @State private var showingDatePicker = false
    @State private var showingEventTypePicker = false
    @State private var showingChildrenPicker = false
    
    // Validation
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        startDate <= endDate
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.03) {
                        // Header illustration
                        headerIllustration(geometry: geometry)
                        
                        // Form fields
                        formFields(geometry: geometry)
                        
                        // Save button
                        saveButton(geometry: geometry)
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.top, geometry.size.height * 0.02)
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
            }
        }
        .disabled(isLoading)
    }
    
    // MARK: - Header Illustration
    private func headerIllustration(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [selectedEventType.color.opacity(0.3), selectedEventType.color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * 0.25,
                        height: geometry.size.width * 0.25
                    )
                
                Image(systemName: selectedEventType.icon)
                    .font(.system(size: geometry.size.width * 0.1, weight: .light))
                    .foregroundColor(selectedEventType.color)
            }
            
            Text("Planifiez un nouvel événement")
                .font(.system(size: geometry.size.width * 0.045, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Form Fields
    private func formFields(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.025) {
            // Title
            formField(
                title: "Titre *",
                text: $title,
                placeholder: "Entrez le titre de l'événement",
                geometry: geometry
            )
            
            // Description
            descriptionField(geometry: geometry)
            
            // Event Type
            eventTypeField(geometry: geometry)
            
            // Date and Time
            dateTimeFields(geometry: geometry)
            
            // Children Selection
            childrenSelectionField(geometry: geometry)
        }
    }
    
    // MARK: - Form Field Component
    private func formField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        geometry: GeometryProxy
    ) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
            Text(title)
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.primary)
            
            TextField(placeholder, text: text)
                .font(.system(size: geometry.size.width * 0.045, weight: .regular))
                .padding(geometry.size.width * 0.04)
                .background(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Description Field
    private func descriptionField(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
            Text("Description (optionnel)")
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.primary)
            
            TextField(
                "Ajoutez une description...",
                text: $description,
                axis: .vertical
            )
            .font(.system(size: geometry.size.width * 0.04, weight: .regular))
            .padding(geometry.size.width * 0.04)
            .frame(minHeight: geometry.size.height * 0.1)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Event Type Field
    private func eventTypeField(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
            Text("Type d'événement")
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.primary)
            
            Button(action: { showingEventTypePicker = true }) {
                HStack {
                    Image(systemName: selectedEventType.icon)
                        .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                        .foregroundColor(selectedEventType.color)
                    
                    Text(selectedEventType.name)
                        .font(.system(size: geometry.size.width * 0.045, weight: .regular))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(geometry.size.width * 0.04)
                .background(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showingEventTypePicker) {
            eventTypePickerSheet(geometry: geometry)
        }
    }
    
    // MARK: - Date Time Fields
    private func dateTimeFields(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            // All day toggle
            HStack {
                Text("Toute la journée")
                    .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $isAllDay)
                    .onChange(of: isAllDay) { newValue in
                        if newValue {
                            // Set to start of day
                            startDate = Calendar.current.startOfDay(for: startDate)
                            endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? startDate
                        }
                    }
            }
            
            // Start date
            dateField(
                title: "Date de début",
                date: $startDate,
                showTime: !isAllDay,
                geometry: geometry
            )
            
            // End date
            dateField(
                title: "Date de fin",
                date: $endDate,
                showTime: !isAllDay,
                geometry: geometry
            )
        }
    }
    
    // MARK: - Date Field
    private func dateField(
        title: String,
        date: Binding<Date>,
        showTime: Bool,
        geometry: GeometryProxy
    ) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
            Text(title)
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.primary)
            
            DatePicker(
                "",
                selection: date,
                displayedComponents: showTime ? [.date, .hourAndMinute] : [.date]
            )
            .datePickerStyle(.compact)
            .padding(geometry.size.width * 0.04)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    // MARK: - Children Selection Field
    private func childrenSelectionField(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
            Text("Enfants concernés (optionnel)")
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.primary)
            
            if childrenViewModel.children.isEmpty {
                Text("Aucun enfant ajouté")
                    .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                    .foregroundColor(.secondary)
                    .padding(geometry.size.width * 0.04)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                            .fill(Color(.systemGray6))
                    )
            } else {
                VStack(spacing: geometry.size.height * 0.01) {
                    ForEach(childrenViewModel.children, id: \.id) { child in
                        childSelectionRow(child: child, geometry: geometry)
                    }
                }
                .padding(geometry.size.width * 0.04)
                .background(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }
    
    // MARK: - Child Selection Row
    private func childSelectionRow(child: Child, geometry: GeometryProxy) -> some View {
        Button(action: {
            if selectedChildren.contains(child.id) {
                selectedChildren.remove(child.id)
            } else {
                selectedChildren.insert(child.id)
            }
        }) {
            HStack {
                Image(systemName: selectedChildren.contains(child.id) ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                    .foregroundColor(selectedChildren.contains(child.id) ? .blue : .secondary)
                
                Text(child.fullName)
                    .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(child.ageText)
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Event Type Picker Sheet
    private func eventTypePickerSheet(geometry: GeometryProxy) -> some View {
        NavigationView {
            List {
                ForEach(EventType.defaultTypes, id: \.id) { eventType in
                    Button(action: {
                        selectedEventType = eventType
                        showingEventTypePicker = false
                    }) {
                        HStack {
                            Image(systemName: eventType.icon)
                                .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                                .foregroundColor(eventType.color)
                                .frame(width: geometry.size.width * 0.08)
                            
                            Text(eventType.name)
                                .font(.system(size: geometry.size.width * 0.045, weight: .regular))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedEventType.id == eventType.id {
                                Image(systemName: "checkmark")
                                    .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Type d'événement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Terminé") {
                        showingEventTypePicker = false
                    }
                }
            }
        }
    }
    
    // MARK: - Save Button
    private func saveButton(geometry: GeometryProxy) -> some View {
        Button(action: saveEvent) {
            HStack(spacing: geometry.size.width * 0.03) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Text(isLoading ? "Enregistrement..." : "Créer l'événement")
                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height * 0.07)
            .background(
                LinearGradient(
                    colors: isFormValid ? [selectedEventType.color, selectedEventType.color.opacity(0.8)] : [Color.gray, Color.gray.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(geometry.size.width * 0.04)
            .shadow(
                color: isFormValid ? selectedEventType.color.opacity(0.3) : Color.clear,
                radius: geometry.size.width * 0.02,
                x: 0,
                y: geometry.size.width * 0.01
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isFormValid || isLoading)
        .padding(.top, geometry.size.height * 0.02)
    }
    
    // MARK: - Save Event Function
    private func saveEvent() {
        guard isFormValid else { return }
        
        isLoading = true
        
        let newEvent = Event(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            eventType: selectedEventType,
            childrenIds: Array(selectedChildren)
        )
        
        Task {
            await eventsViewModel.createEvent(newEvent)
            
            await MainActor.run {
                isLoading = false
                
                // Check if there was an error
                if eventsViewModel.errorMessage == nil {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
            .environmentObject(EventsViewModel(eventsService: MockEventsService()))
            .environmentObject(ChildrenViewModel(childrenService: MockChildrenService()))
    }
}
#endif