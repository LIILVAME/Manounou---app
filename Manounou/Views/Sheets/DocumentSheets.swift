//
//  DocumentSheets.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

// MARK: - Add Document Sheet
struct AddDocumentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (FunctionalDocument) -> Void
    
    @State private var title = ""
    @State private var type = "Médical"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Document") {
                    TextField("Titre", text: $title)
                    Picker("Type", selection: $type) {
                        Text("Médical").tag("Médical")
                        Text("Scolaire").tag("Scolaire")
                        Text("Administratif").tag("Administratif")
                        Text("Autre").tag("Autre")
                    }
                }
            }
            .navigationTitle("Nouveau document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        let newDocument = FunctionalDocument(
                            title: title,
                            type: type,
                            dateAdded: Date()
                        )
                        onSave(newDocument)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}