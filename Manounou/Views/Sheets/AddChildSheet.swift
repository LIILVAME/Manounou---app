//
//  AddChildSheet.swift
//  Manounou
//
//  Created by Assistant on 17/08/2025.
//

import SwiftUI

struct AddChildSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var birthDate = Date()
    @State private var gender: Gender = .other
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations de l'enfant") {
                    TextField("Prénom", text: $firstName)
                        .textContentType(.givenName)
                    
                    TextField("Nom", text: $lastName)
                        .textContentType(.familyName)
                    
                    DatePicker("Date de naissance", selection: $birthDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                    
                    Picker("Genre", selection: $gender) {
                        Text("Fille").tag(Gender.female)
                        Text("Garçon").tag(Gender.male)
                        Text("Autre").tag(Gender.other)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button("Ajouter l'enfant") {
                        addChild()
                    }
                    .disabled(isLoading || firstName.isEmpty || lastName.isEmpty)
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
            }
            .alert("Enfant", isPresented: $showingAlert) {
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
    
    private func addChild() {
        isLoading = true

        Task { @MainActor in
            let newChild = Child(
                firstName: firstName,
                lastName: lastName,
                birthDate: birthDate,
                gender: gender
            )

            await childrenViewModel.createChild(newChild)

            isLoading = false
            if let error = childrenViewModel.errorMessage {
                alertMessage = "Erreur lors de l'ajout de l'enfant : \(error)"
            } else {
                alertMessage = "Enfant ajouté avec succès"
            }
            showingAlert = true
        }
    }
}

#Preview {
    AddChildSheet()
        .environmentObject(AppContainer.createForTesting().childrenViewModel)
}