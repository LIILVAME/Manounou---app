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
    @State private var gender: Child.Gender = .other
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
                        Text("Fille").tag(Child.Gender.female)
                        Text("Garçon").tag(Child.Gender.male)
                        Text("Autre").tag(Child.Gender.other)
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
        
        Task {
            do {
                let newChild = Child(
                    id: UUID(),
                    firstName: firstName,
                    lastName: lastName,
                    birthDate: birthDate,
                    gender: gender,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                await childrenViewModel.addChild(newChild)
                
                await MainActor.run {
                    alertMessage = "Enfant ajouté avec succès"
                    showingAlert = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Erreur lors de l'ajout de l'enfant"
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    AddChildSheet()
        .environmentObject(ChildrenViewModel())
}