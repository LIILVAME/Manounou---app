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
            
            // Convert Supabase User to our custom User model
            let customUser = User(
                email: email,
                firstName: "User", // TODO: Get from profile
                lastName: "Name"   // TODO: Get from profile
            )
            
            await MainActor.run {
                self.currentUser = customUser
                self.isAuthenticated = true
            }
            
            return customUser
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
            
            // User is always present in successful response
            let supabaseUser = response.user
            
            // Convert to our custom User model
            let customUser = User(
                email: email,
                firstName: "New", // TODO: Get from registration form
                lastName: "User"  // TODO: Get from registration form
            )
            
            await MainActor.run {
                self.currentUser = customUser
                self.isAuthenticated = true
            }
            
            return customUser
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
            let supabaseUser = try await supabaseClient.auth.user()
            
            // Convert to our custom User model
            let customUser = User(
                email: supabaseUser.email ?? "unknown@example.com",
                firstName: "Current", // TODO: Get from profile
                lastName: "User"      // TODO: Get from profile
                )
                
                await MainActor.run {
                    self.currentUser = customUser
                    self.isAuthenticated = true
                }
                
                return customUser
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
            email: email,
            firstName: "Test",
            lastName: "User"
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