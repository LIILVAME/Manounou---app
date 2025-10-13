//
//  AddEventSheet.swift
//  Manounou
//
//  Created by Assistant on 17/08/2025.
//

import SwiftUI

struct AddEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600) // +1 heure
    @State private var selectedChild: Child?
    @State private var eventType: Event.EventType = .appointment
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Détails de l'événement") {
                    TextField("Titre", text: $title)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Type", selection: $eventType) {
                        Text("Rendez-vous").tag(Event.EventType.appointment)
                        Text("Activité").tag(Event.EventType.activity)
                        Text("Rappel").tag(Event.EventType.reminder)
                        Text("Autre").tag(Event.EventType.other)
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Date et heure") {
                    DatePicker("Début", selection: $startDate)
                        .datePickerStyle(.compact)
                    
                    DatePicker("Fin", selection: $endDate)
                        .datePickerStyle(.compact)
                }
                
                Section("Enfant concerné") {
                    Picker("Sélectionner un enfant", selection: $selectedChild) {
                        Text("Aucun enfant spécifique").tag(nil as Child?)
                        ForEach(childrenViewModel.children, id: \.id) { child in
                            Text("\(child.firstName) \(child.lastName)")
                                .tag(child as Child?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    Button("Ajouter l'événement") {
                        addEvent()
                    }
                    .disabled(isLoading || title.isEmpty)
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
            .alert("Événement", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("succès") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func addEvent() {
        isLoading = true
        
        Task {
            do {
                let newEvent = Event(
                    id: UUID(),
                    title: title,
                    description: description.isEmpty ? nil : description,
                    startDate: startDate,
                    endDate: endDate,
                    childId: selectedChild?.id,
                    eventType: eventType,
                    isCompleted: false,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                await eventsViewModel.addEvent(newEvent)
                
                await MainActor.run {
                    alertMessage = "Événement ajouté avec succès"
                    showingAlert = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Erreur lors de l'ajout de l'événement"
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    AddEventSheet()
        .environmentObject(EventsViewModel())
        .environmentObject(ChildrenViewModel())
}