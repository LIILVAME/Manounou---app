//
//  ServiceProtocols.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation
import Supabase

// MARK: - Authentication Service Protocol
protocol AuthServiceProtocol {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }
    
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() async throws
    func resetPassword(email: String) async throws
    func getCurrentUser() async throws -> User?
}

// MARK: - Events Service Protocol
protocol EventsServiceProtocol {
    func fetchEvents() async throws -> [Event]
    func createEvent(_ event: Event) async throws -> Event
    func updateEvent(_ event: Event) async throws -> Event
    func deleteEvent(id: UUID) async throws
    func fetchEventsForChild(childId: UUID) async throws -> [Event]
    func fetchEventsForDateRange(from: Date, to: Date) async throws -> [Event]
}

// MARK: - Children Service Protocol
protocol ChildrenServiceProtocol {
    func fetchChildren() async throws -> [Child]
    func createChild(_ child: Child) async throws -> Child
    func updateChild(_ child: Child) async throws -> Child
    func deleteChild(id: UUID) async throws
    func fetchChild(id: UUID) async throws -> Child?
}

// MARK: - Cache Service Protocol
protocol CacheServiceProtocol {
    var cacheStatistics: CacheStatistics { get }
    
    func cacheEvents(_ events: [Event])
    func getCachedEvents() -> [Event]?
    func cacheChildren(_ children: [Child])
    func getCachedChildren() -> [Child]?
    func clearCache()
    func clearEventsCache()
    func clearChildrenCache()
}

// MARK: - Cache Statistics
struct CacheStatistics {
    let formattedLastSync: String
    let hasEventsCache: Bool
    let hasChildrenCache: Bool
    let cacheSize: String
    let lastSyncDate: Date?
}

// MARK: - Service Error Types
enum ServiceError: LocalizedError {
    case networkError(String)
    case authenticationError(String)
    case validationError(String)
    case cacheError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Erreur réseau: \(message)"
        case .authenticationError(let message):
            return "Erreur d'authentification: \(message)"
        case .validationError(let message):
            return "Erreur de validation: \(message)"
        case .cacheError(let message):
            return "Erreur de cache: \(message)"
        case .unknownError(let message):
            return "Erreur inconnue: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Vérifiez votre connexion internet et réessayez."
        case .authenticationError:
            return "Vérifiez vos identifiants ou reconnectez-vous."
        case .validationError:
            return "Vérifiez les informations saisies."
        case .cacheError:
            return "Essayez de vider le cache dans les paramètres."
        case .unknownError:
            return "Redémarrez l'application ou contactez le support."
        }
    }
}