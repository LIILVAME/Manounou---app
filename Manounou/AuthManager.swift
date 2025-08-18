//
//  AuthManager.swift
//  Manounou
//
//  Created by Assistant on 15/08/2025.
//

import Foundation
import SwiftUI
import Supabase

struct UserProfile: Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var avatarUrl: String?
    var createdAt: Date
    var updatedAt: Date
}

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: Auth.User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userProfile: UserProfile?
    
    private let supabase = SupabaseClient(
        supabaseURL: Config.supabaseAPIURL,
        supabaseKey: Config.supabaseAnonKey
    )
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        Task {
            do {
                let session = try await supabase.auth.session
                self.isAuthenticated = true
                self.currentUser = session.user
            } catch {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            self.isAuthenticated = true
            self.currentUser = session.user
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await supabase.auth.signUp(email: email, password: password)
            self.isAuthenticated = true
            self.currentUser = session.user
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            self.isAuthenticated = false
            self.currentUser = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func clearError() {
        self.errorMessage = nil
    }
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            // Success - user will receive email
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateUserProfile(firstName: String, lastName: String, email: String) async {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implémenter la mise à jour du profil utilisateur
        // avec Supabase
        
        // Simuler une mise à jour réussie
        let updatedProfile = UserProfile(
            id: userProfile?.id ?? UUID(),
            firstName: firstName,
            lastName: lastName,
            email: email,
            avatarUrl: userProfile?.avatarUrl,
            createdAt: userProfile?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        self.userProfile = updatedProfile
        isLoading = false
    }
}
