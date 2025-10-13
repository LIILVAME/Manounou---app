//
//  ChildSheets.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

// MARK: - Add Child Sheet
struct AddChildSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (FunctionalChild) -> Void
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var birthDate = Date()
    @State private var gender = "Autre"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations") {
                    TextField("Prénom", text: $firstName)
                    TextField("Nom", text: $lastName)
                    DatePicker("Date de naissance", selection: $birthDate, displayedComponents: .date)
                    Picker("Genre", selection: $gender) {
                        Text("Fille").tag("Fille")
                        Text("Garçon").tag("Garçon")
                        Text("Autre").tag("Autre")
                    }
                }
            }
            .navigationTitle("Nouvel enfant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        let newChild = FunctionalChild(
                            firstName: firstName,
                            lastName: lastName,
                            birthDate: birthDate,
                            gender: gender
                        )
                        onSave(newChild)
                        dismiss()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Child Detail Sheet
struct ChildDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let child: FunctionalChild
    let onSave: (FunctionalChild) -> Void
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var birthDate: Date
    @State private var gender: String
    
    init(child: FunctionalChild, onSave: @escaping (FunctionalChild) -> Void) {
        self.child = child
        self.onSave = onSave
        self._firstName = State(initialValue: child.firstName)
        self._lastName = State(initialValue: child.lastName)
        self._birthDate = State(initialValue: child.birthDate)
        self._gender = State(initialValue: child.gender)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations") {
                    TextField("Prénom", text: $firstName)
                    TextField("Nom", text: $lastName)
                    DatePicker("Date de naissance", selection: $birthDate, displayedComponents: .date)
                    Picker("Genre", selection: $gender) {
                        Text("Fille").tag("Fille")
                        Text("Garçon").tag("Garçon")
                        Text("Autre").tag("Autre")
                    }
                }
            }
            .navigationTitle("Modifier enfant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        var updatedChild = child
                        updatedChild.firstName = firstName
                        updatedChild.lastName = lastName
                        updatedChild.birthDate = birthDate
                        updatedChild.gender = gender
                        onSave(updatedChild)
                        dismiss()
                    }
                }
            }
        }
    }
}