//
//  ChildrenService.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation
import Supabase

class ChildrenService: ChildrenServiceProtocol, ObservableObject {
    private let supabaseClient: SupabaseClient
    private let cacheService: CacheServiceProtocol
    
    init(supabaseClient: SupabaseClient, cacheService: CacheServiceProtocol) {
        self.supabaseClient = supabaseClient
        self.cacheService = cacheService
    }
    
    // MARK: - Children Management
    
    func fetchChildren() async throws -> [Child] {
        do {
            let response: [ChildDTO] = try await supabaseClient
                .from("children")
                .select()
                .execute()
                .value
            
            let children = response.map { $0.toChild() }
            cacheService.cacheChildren(children)
            
            return children
        } catch {
            // Fallback to cache if network fails
            if let cachedChildren = cacheService.getCachedChildren() {
                return cachedChildren
            }
            throw ServiceError.networkError("Impossible de récupérer les enfants: \(error.localizedDescription)")
        }
    }
    
    func createChild(_ child: Child) async throws -> Child {
        do {
            let childDTO = ChildDTO.from(child)
            let response: ChildDTO = try await supabaseClient
                .from("children")
                .insert(childDTO)
                .select()
                .single()
                .execute()
                .value
            
            return response.toChild()
        } catch {
            throw ServiceError.networkError("Impossible de créer l'enfant: \(error.localizedDescription)")
        }
    }
    
    func updateChild(_ child: Child) async throws -> Child {
        do {
            let childDTO = ChildDTO.from(child)
            let response: ChildDTO = try await supabaseClient
                .from("children")
                .update(childDTO)
                .eq("id", value: child.id)
                .select()
                .single()
                .execute()
                .value
            
            return response.toChild()
        } catch {
            throw ServiceError.networkError("Impossible de mettre à jour l'enfant: \(error.localizedDescription)")
        }
    }
    
    func deleteChild(id: UUID) async throws {
        do {
            try await supabaseClient
                .from("children")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            throw ServiceError.networkError("Impossible de supprimer l'enfant: \(error.localizedDescription)")
        }
    }
    
    func fetchChild(id: UUID) async throws -> Child? {
        do {
            let response: ChildDTO = try await supabaseClient
                .from("children")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            
            return response.toChild()
        } catch {
            throw ServiceError.networkError("Impossible de récupérer l'enfant: \(error.localizedDescription)")
        }
    }
}

// MARK: - Child Data Transfer Object

struct ChildDTO: Codable {
    let id: UUID?
    let firstName: String
    let lastName: String
    let birthDate: Date
    let gender: String?
    let profileImageURL: String?
    let notes: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case birthDate = "birth_date"
        case gender
        case profileImageURL = "profile_image_url"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    func toChild() -> Child {
        return Child(
            id: id ?? UUID(),
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate,
            gender: gender,
            profileImageURL: profileImageURL,
            notes: notes,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
    
    static func from(_ child: Child) -> ChildDTO {
        return ChildDTO(
            id: child.id,
            firstName: child.firstName,
            lastName: child.lastName,
            birthDate: child.birthDate,
            gender: child.gender,
            profileImageURL: child.profileImageURL,
            notes: child.notes,
            createdAt: child.createdAt,
            updatedAt: child.updatedAt
        )
    }
}

// MARK: - Mock Implementation for Testing

class MockChildrenService: ChildrenServiceProtocol, ObservableObject {
    private var children: [Child] = []
    private var shouldFailRequests = false
    
    init(shouldFailRequests: Bool = false) {
        self.shouldFailRequests = shouldFailRequests
        self.children = Self.sampleChildren
    }
    
    func fetchChildren() async throws -> [Child] {
        if shouldFailRequests {
            throw ServiceError.networkError("Mock network failure")
        }
        
        try await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
        return children
    }
    
    func createChild(_ child: Child) async throws -> Child {
        if shouldFailRequests {
            throw ServiceError.networkError("Mock creation failure")
        }
        
        let newChild = Child(
            id: UUID(),
            firstName: child.firstName,
            lastName: child.lastName,
            birthDate: child.birthDate,
            gender: child.gender,
            profileImageURL: child.profileImageURL,
            notes: child.notes,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        children.append(newChild)
        return newChild
    }
    
    func updateChild(_ child: Child) async throws -> Child {
        if shouldFailRequests {
            throw ServiceError.networkError("Mock update failure")
        }
        
        if let index = children.firstIndex(where: { $0.id == child.id }) {
            children[index] = child
        }
        
        return child
    }
    
    func deleteChild(id: UUID) async throws {
        if shouldFailRequests {
            throw ServiceError.networkError("Mock deletion failure")
        }
        
        children.removeAll { $0.id == id }
    }
    
    func fetchChild(id: UUID) async throws -> Child? {
        if shouldFailRequests {
            throw ServiceError.networkError("Mock fetch failure")
        }
        
        return children.first { $0.id == id }
    }
    
    func setFailureMode(_ shouldFail: Bool) {
        self.shouldFailRequests = shouldFail
    }
    
    private static let sampleChildren: [Child] = [
        Child(
            id: UUID(),
            firstName: "Emma",
            lastName: "Dupont",
            birthDate: Calendar.current.date(byAdding: .year, value: -5, to: Date()) ?? Date(),
            gender: "female",
            profileImageURL: nil,
            notes: "Aime les livres et les puzzles",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Child(
            id: UUID(),
            firstName: "Lucas",
            lastName: "Martin",
            birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
            gender: "male",
            profileImageURL: nil,
            notes: "Très énergique, adore le football",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Child(
            id: UUID(),
            firstName: "Chloé",
            lastName: "Bernard",
            birthDate: Calendar.current.date(byAdding: .year, value: -7, to: Date()) ?? Date(),
            gender: "female",
            profileImageURL: nil,
            notes: "Passionnée de danse et de musique",
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
}