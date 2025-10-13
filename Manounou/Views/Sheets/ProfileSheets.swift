//
//  ProfileSheets.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

// MARK: - Profile Edit Sheet
struct ProfileEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profil") {
                    TextField("Prénom", text: .constant("Utilisateur"))
                    TextField("Nom", text: .constant("Test"))
                    TextField("Email", text: .constant("user@example.com"))
                }
            }
            .navigationTitle("Modifier le profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        dismiss()
                    }
                }
            }
        }
    }
}