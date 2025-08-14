//
//  AuthManager.swift
//  Manounou
//
//  Created by Assistant on 2025-01-13.
//

import Foundation
import Supabase
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var currentUser: User?
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?
    
    private let supabase: SupabaseClient
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Validation de la configuration au démarrage
        AppConfig.validateConfiguration()
        
        // Configuration Supabase depuis Config.swift
        self.supabase = SupabaseClient(
            supabaseURL: AppConfig.Supabase.apiURL,
            supabaseKey: AppConfig.Supabase.anonKey
        )
    }
    
    func initialize() async {
        print("🚀 Initialisation AuthManager...")
        
        // Écouter les changements d'état d'authentification
        await supabase.auth.onAuthStateChange { [weak self] event, session in
            print("🔄 Changement d'état auth: \(event)")
            Task { @MainActor in
                self?.handleAuthStateChange(event: event, session: session)
            }
        }
        
        // Vérifier la session actuelle
        await checkCurrentSession()
        
        print("✅ AuthManager initialisé - isAuthenticated: \(isAuthenticated)")
    }
    
    private func handleAuthStateChange(event: AuthChangeEvent, session: Session?) {
        Task { @MainActor in
            switch event {
            case .signedIn:
                self.isAuthenticated = true
                self.currentUser = session?.user
                self.isLoading = false
                print("✅ Utilisateur connecté: \(session?.user.email ?? "unknown")")
                Task {
                    await loadUserProfile()
                }
            case .signedOut:
                self.isAuthenticated = false
                self.currentUser = nil
                self.userProfile = nil
                self.isLoading = false
                print("❌ Utilisateur déconnecté")
            case .tokenRefreshed:
                self.currentUser = session?.user
                print("🔄 Token rafraîchi")
            default:
                break
            }
        }
    }
    
    private func checkCurrentSession() async {
        print("🔍 Vérification de la session actuelle...")
        
        do {
            let session = try await supabase.auth.session
            let hasValidToken = !session.accessToken.isEmpty
            
            print("📋 Session trouvée - Token valide: \(hasValidToken)")
            print("👤 Utilisateur: \(session.user.email ?? "unknown")")
            
            await MainActor.run {
                self.isAuthenticated = hasValidToken
                self.currentUser = session.user
                self.isLoading = false
            }
            
            if hasValidToken {
                await loadUserProfile()
            }
        } catch {
            print("❌ Erreur lors de la vérification de session: \(error.localizedDescription)")
            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
                self.userProfile = nil
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, firstName: String, lastName: String) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: [
                    "first_name": AnyJSON.string(firstName),
                    "last_name": AnyJSON.string(lastName)
                ]
            )
            
            print("📝 Inscription réussie pour: \(response.user.email ?? "unknown")")
            
            // Créer le profil utilisateur
            await createUserProfile(userId: response.user.id, firstName: firstName, lastName: lastName, email: email)
            
            // Mettre à jour immédiatement l'état d'authentification
            await MainActor.run {
                self.isAuthenticated = true
                self.currentUser = response.user
                self.isLoading = false
            }
        } catch {
            print("❌ Erreur d'inscription: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = "Erreur lors de l'inscription: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func signIn(email: String, password: String) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let response = try await supabase.auth.signIn(email: email, password: password)
            print("🔐 Connexion réussie pour: \(response.user.email ?? "unknown")")
            
            // Mettre à jour immédiatement l'état d'authentification
            await MainActor.run {
                self.isAuthenticated = true
                self.currentUser = response.user
                self.isLoading = false
            }
        } catch {
            print("❌ Erreur de connexion: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = "Erreur lors de la connexion: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func signOut() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            try await supabase.auth.signOut()
            print("🚪 Déconnexion réussie")
            
            // Mettre à jour immédiatement l'état d'authentification
            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
                self.isLoading = false
            }
        } catch {
            print("❌ Erreur de déconnexion: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = "Erreur lors de la déconnexion: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func resetPassword(email: String) async {
        do {
            try await supabase.auth.resetPasswordForEmail(email)
        } catch {
            self.errorMessage = "Erreur lors de la réinitialisation: \(error.localizedDescription)"
        }
    }
    
    // MARK: - User Profile
    
    private func createUserProfile(userId: UUID, firstName: String, lastName: String, email: String) async {
        let profile: [String: AnyJSON] = [
            "id": AnyJSON.string(userId.uuidString),
            "first_name": AnyJSON.string(firstName),
            "last_name": AnyJSON.string(lastName),
            "email": AnyJSON.string(email),
            "created_at": AnyJSON.string(ISO8601DateFormatter().string(from: Date()))
        ]
        
        do {
            try await supabase
                .from("profiles")
                .insert(profile)
                .execute()
        } catch {
            print("Erreur lors de la création du profil: \(error)")
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - User Profile Methods
    
    func loadUserProfile() async {
         guard let userId = currentUser?.id else {
             print("❌ Aucun utilisateur connecté pour charger le profil")
             return
         }
         
         do {
             let response: [UserProfile] = try await supabase
                 .from("profiles")
                 .select()
                 .eq("id", value: userId.uuidString)
                 .execute()
                 .value
             
             await MainActor.run {
                 self.userProfile = response.first
                 print("✅ Profil utilisateur chargé: \(response.first?.firstName ?? "N/A")")
             }
         } catch {
             print("❌ Erreur lors du chargement du profil: \(error.localizedDescription)")
             await MainActor.run {
                 self.errorMessage = "Erreur lors du chargement du profil: \(error.localizedDescription)"
             }
         }
     }
     
     func updateUserProfile(firstName: String, lastName: String) async throws {
         guard let userId = currentUser?.id else {
             throw NSError(domain: "AuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Aucun utilisateur connecté"])
         }
         
         let updateData: [String: AnyJSON] = [
             "first_name": AnyJSON.string(firstName),
             "last_name": AnyJSON.string(lastName)
         ]
         
         try await supabase
             .from("profiles")
             .update(updateData)
             .eq("id", value: userId.uuidString)
             .execute()
         
         // Recharger le profil après la mise à jour
         await loadUserProfile()
         
         print("✅ Profil utilisateur mis à jour: \(firstName) \(lastName)")
     }
}

// MARK: - User Model
struct UserProfile: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let createdAt: String
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case createdAt = "created_at"
        case avatarUrl = "avatar_url"
    }
}