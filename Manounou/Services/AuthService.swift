//
//  AuthService.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation
import Supabase

class AuthService: AuthServiceProtocol, ObservableObject {
    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticated: Bool = false
    
    private let supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
        Task {
            await checkAuthenticationStatus()
        }
    }
    
    // MARK: - Authentication Methods
    
    func signIn(email: String, password: String) async throws -> User {
        do {
            let response = try await supabaseClient.auth.signIn(
                email: email,
                password: password
            )
            
            await MainActor.run {
                self.currentUser = response.user
                self.isAuthenticated = true
            }
            
            return response.user
        } catch {
            throw ServiceError.authenticationError("Échec de la connexion: \(error.localizedDescription)")
        }
    }
    
    func signUp(email: String, password: String) async throws -> User {
        do {
            let response = try await supabaseClient.auth.signUp(
                email: email,
                password: password
            )
            
            guard let user = response.user else {
                throw ServiceError.authenticationError("Aucun utilisateur retourné après l'inscription")
            }
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
            
            return user
        } catch {
            throw ServiceError.authenticationError("Échec de l'inscription: \(error.localizedDescription)")
        }
    }
    
    func signOut() async throws {
        do {
            try await supabaseClient.auth.signOut()
            
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        } catch {
            throw ServiceError.authenticationError("Échec de la déconnexion: \(error.localizedDescription)")
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await supabaseClient.auth.resetPasswordForEmail(email)
        } catch {
            throw ServiceError.authenticationError("Échec de la réinitialisation: \(error.localizedDescription)")
        }
    }
    
    func getCurrentUser() async throws -> User? {
        do {
            let user = try await supabaseClient.auth.user()
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = user != nil
            }
            
            return user
        } catch {
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
            }
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAuthenticationStatus() async {
        do {
            let user = try await getCurrentUser()
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = user != nil
            }
        } catch {
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        }
    }
}

// MARK: - Mock Implementation for Testing

class MockAuthService: AuthServiceProtocol, ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    
    private var shouldFailAuth = false
    
    init(shouldFailAuth: Bool = false) {
        self.shouldFailAuth = shouldFailAuth
    }
    
    func signIn(email: String, password: String) async throws -> User {
        if shouldFailAuth {
            throw ServiceError.authenticationError("Mock authentication failure")
        }
        
        let mockUser = User(
            id: UUID(),
            appMetadata: [:],
            userMetadata: [:],
            aud: "authenticated",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        await MainActor.run {
            self.currentUser = mockUser
            self.isAuthenticated = true
        }
        
        return mockUser
    }
    
    func signUp(email: String, password: String) async throws -> User {
        return try await signIn(email: email, password: password)
    }
    
    func signOut() async throws {
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    func resetPassword(email: String) async throws {
        if shouldFailAuth {
            throw ServiceError.authenticationError("Mock reset failure")
        }
    }
    
    func getCurrentUser() async throws -> User? {
        return currentUser
    }
    
    func setFailureMode(_ shouldFail: Bool) {
        self.shouldFailAuth = shouldFail
    }
}