//
//  ProfileEditSheet.swift
//  Manounou
//
//  Created by Assistant on 17/08/2025.
//

import SwiftUI

struct ProfileEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Prénom", text: $firstName)
                        .textContentType(.givenName)

                    TextField("Nom", text: $lastName)
                        .textContentType(.familyName)

                    HStack {
                        Text("Email")
                        Spacer()
                        Text(email.isEmpty ? "—" : email)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Informations personnelles")
                } footer: {
                    Text("L'adresse e-mail ne peut pas être modifiée pour le moment.")
                }

                Section {
                    Button("Sauvegarder") {
                        saveProfile()
                    }
                    .disabled(isLoading || firstName.isEmpty || lastName.isEmpty)
                    
                    Button("Se déconnecter", role: .destructive) {
                        Task {
                            await authViewModel.signOut()
                        }
                        dismiss()
                    }
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
            .alert("Profil", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func loadCurrentProfile() {
        // Charger les données actuelles du profil
        firstName = authViewModel.currentUser?.firstName ?? ""
        lastName = authViewModel.currentUser?.lastName ?? ""
        email = authViewModel.currentUser?.email ?? ""
    }
    
    private func saveProfile() {
        Task { @MainActor in
            isLoading = true

            await authViewModel.updateProfile(firstName: firstName, lastName: lastName)

            isLoading = false

            if let error = authViewModel.errorMessage {
                alertMessage = error
                showingAlert = true
            } else {
                dismiss()
            }
        }
    }
}

#Preview {
    ProfileEditSheet()
        .environmentObject(AuthViewModel(authService: MockAuthService()))
}