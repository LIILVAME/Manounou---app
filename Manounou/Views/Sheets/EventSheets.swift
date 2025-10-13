//
//  EventSheets.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

// MARK: - Add Event Sheet
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
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
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