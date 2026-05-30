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
                Section("Informations personnelles") {
                    TextField("Prénom", text: $firstName)
                        .textContentType(.givenName)
                    
                    TextField("Nom", text: $lastName)
                        .textContentType(.familyName)
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button("Sauvegarder") {
                        saveProfile()
                    }
                    .disabled(isLoading || firstName.isEmpty || lastName.isEmpty || email.isEmpty)
                    
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
        isLoading = true
        
        Task {
            do {
                // Simuler la sauvegarde du profil
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 seconde
                
                await MainActor.run {
                    alertMessage = "Profil mis à jour avec succès"
                    showingAlert = true
                    isLoading = false
                }
                
                // Fermer après un délai
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconde
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Erreur lors de la mise à jour du profil"
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ProfileEditSheet()
        .environmentObject(AuthViewModel(authService: MockAuthService()))
}