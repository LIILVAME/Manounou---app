//
//  DataManager.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//  Unified data management for POC - pragmatic approach
//

import Foundation
import Supabase

/// Unified data manager that replaces multiple services for POC simplicity
class DataManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = DataManager()
    
    // MARK: - Dependencies
    private let supabaseClient: SupabaseClient
    
    // MARK: - Published Cache Properties (Simple @Published approach)
    @Published var cachedEvents: [Event] = []
    @Published var cachedChildren: [Child] = []
    @Published var cachedDocuments: [Document] = []
    @Published var lastSyncDate: Date?
    
    // MARK: - Initialization
    init(supabaseClient: SupabaseClient? = nil) {
        // Use provided client or create default one
        if let client = supabaseClient {
            self.supabaseClient = client
        } else {
            // Default Supabase configuration using Config values
            self.supabaseClient = SupabaseClient(
                supabaseURL: Config.supabaseAPIURL,
                supabaseKey: Config.supabaseAnonKey
            )
        }
    }
    
    // MARK: - Events Management
    
    func fetchEvents() async throws -> [Event] {
        do {
            let response: [EventDTO] = try await supabaseClient
                .from("events")
                .select()
                .execute()
                .value
            
            let events = response.map { $0.toEvent() }
            
            await MainActor.run {
                self.cachedEvents = events
                self.lastSyncDate = Date()
            }
            
            return events
        } catch {
            // Return cached data if available
            if !cachedEvents.isEmpty {
                return cachedEvents
            }
            throw ServiceError.networkError("Impossible de récupérer les événements: \(error.localizedDescription)")
        }
    }
    
    func createEvent(_ event: Event) async throws -> Event {
        let eventDTO = EventDTO.from(event)
        let response: EventDTO = try await supabaseClient
            .from("events")
            .insert(eventDTO)
            .select()
            .single()
            .execute()
            .value
        
        let newEvent = response.toEvent()
        
        await MainActor.run {
            self.cachedEvents.append(newEvent)
        }
        
        return newEvent
    }
    
    func updateEvent(_ event: Event) async throws -> Event {
        let eventDTO = EventDTO.from(event)
        let response: EventDTO = try await supabaseClient
            .from("events")
            .update(eventDTO)
            .eq("id", value: event.id)
            .select()
            .single()
            .execute()
            .value
        
        let updatedEvent = response.toEvent()
        
        await MainActor.run {
            if let index = self.cachedEvents.firstIndex(where: { $0.id == event.id }) {
                self.cachedEvents[index] = updatedEvent
            }
        }
        
        return updatedEvent
    }
    
    func deleteEvent(id: UUID) async throws {
        try await supabaseClient
            .from("events")
            .delete()
            .eq("id", value: id)
            .execute()
        
        await MainActor.run {
            self.cachedEvents.removeAll { $0.id == id }
        }
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
            
            await MainActor.run {
                self.cachedChildren = children
                self.lastSyncDate = Date()
            }
            
            return children
        } catch {
            if !cachedChildren.isEmpty {
                return cachedChildren
            }
            throw ServiceError.networkError("Impossible de récupérer les enfants: \(error.localizedDescription)")
        }
    }
    
    func createChild(_ child: Child) async throws -> Child {
        let childDTO = ChildDTO.from(child)
        let response: ChildDTO = try await supabaseClient
            .from("children")
            .insert(childDTO)
            .select()
            .single()
            .execute()
            .value
        
        let newChild = response.toChild()
        
        await MainActor.run {
            self.cachedChildren.append(newChild)
        }
        
        return newChild
    }
    
    func updateChild(_ child: Child) async throws -> Child {
        let childDTO = ChildDTO.from(child)
        let response: ChildDTO = try await supabaseClient
            .from("children")
            .update(childDTO)
            .eq("id", value: child.id)
            .select()
            .single()
            .execute()
            .value
        
        let updatedChild = response.toChild()
        
        await MainActor.run {
            if let index = self.cachedChildren.firstIndex(where: { $0.id == child.id }) {
                self.cachedChildren[index] = updatedChild
            }
        }
        
        return updatedChild
    }
    
    func deleteChild(id: UUID) async throws {
        try await supabaseClient
            .from("children")
            .delete()
            .eq("id", value: id)
            .execute()
        
        await MainActor.run {
            self.cachedChildren.removeAll { $0.id == id }
        }
    }
    
    // MARK: - Documents Management
    
    func fetchDocuments() async throws -> [Document] {
        do {
            let response: [DocumentDTO] = try await supabaseClient
                .from("documents")
                .select()
                .execute()
                .value
            
            let documents = response.map { $0.toDocument() }
            
            await MainActor.run {
                self.cachedDocuments = documents
                self.lastSyncDate = Date()
            }
            
            return documents
        } catch {
            if !cachedDocuments.isEmpty {
                return cachedDocuments
            }
            throw ServiceError.networkError("Impossible de récupérer les documents: \(error.localizedDescription)")
        }
    }
    
    func createDocument(_ document: Document) async throws -> Document {
        let documentDTO = DocumentDTO.from(document)
        let response: DocumentDTO = try await supabaseClient
            .from("documents")
            .insert(documentDTO)
            .select()
            .single()
            .execute()
            .value
        
        let newDocument = response.toDocument()
        
        await MainActor.run {
            self.cachedDocuments.append(newDocument)
        }
        
        return newDocument
    }
    
    func updateDocument(_ document: Document) async throws -> Document {
        let documentDTO = DocumentDTO.from(document)
        let response: DocumentDTO = try await supabaseClient
            .from("documents")
            .update(documentDTO)
            .eq("id", value: document.id)
            .select()
            .single()
            .execute()
            .value
        
        let updatedDocument = response.toDocument()
        
        await MainActor.run {
            if let index = self.cachedDocuments.firstIndex(where: { $0.id == document.id }) {
                self.cachedDocuments[index] = updatedDocument
            }
        }
        
        return updatedDocument
    }
    
    func deleteDocument(id: UUID) async throws {
        try await supabaseClient
            .from("documents")
            .delete()
            .eq("id", value: id)
            .execute()
        
        await MainActor.run {
            self.cachedDocuments.removeAll { $0.id == id }
        }
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        cachedEvents = []
        cachedChildren = []
        cachedDocuments = []
        lastSyncDate = nil
    }
    
    func getCacheStatistics() -> CacheStatistics {
        return CacheStatistics(
            formattedLastSync: lastSyncDate?.formatted() ?? "Jamais",
            hasEventsCache: !cachedEvents.isEmpty,
            hasChildrenCache: !cachedChildren.isEmpty,
            cacheSize: "\(cachedEvents.count + cachedChildren.count + cachedDocuments.count) éléments",
            lastSyncDate: lastSyncDate
        )
    }
}

// MARK: - DTOs (reused from existing services)

struct EventDTO: Codable {
    let id: UUID?
    let title: String
    let description: String?
    let startDate: Date
    let endDate: Date
    let childId: UUID?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description
        case startDate = "start_date"
        case endDate = "end_date"
        case childId = "child_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    func toEvent() -> Event {
        return Event(
            id: id ?? UUID(),
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            eventType: EventType(name: "Général", icon: "calendar", color: .blue),
            childrenIds: childId != nil ? [childId!] : [],
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
    
    static func from(_ event: Event) -> EventDTO {
        return EventDTO(
            id: event.id,
            title: event.title,
            description: event.description,
            startDate: event.startDate,
            endDate: event.endDate,
            childId: event.childrenIds.first,
            createdAt: event.createdAt,
            updatedAt: event.updatedAt
        )
    }
}

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
            gender: Gender(rawValue: gender ?? "") ?? .other,
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
            gender: child.gender?.rawValue,
            profileImageURL: child.profileImageURL,
            notes: child.notes,
            createdAt: child.createdAt,
            updatedAt: child.updatedAt
        )
    }
}

struct DocumentDTO: Codable {
    let id: UUID?
    let title: String
    let description: String?
    let documentType: String
    let fileName: String?
    let fileUrl: String?
    let fileSize: Int?
    let mimeType: String?
    let childId: UUID?
    let userId: UUID
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description
        case documentType = "document_type"
        case fileName = "file_name"
        case fileUrl = "file_url"
        case fileSize = "file_size"
        case mimeType = "mime_type"
        case childId = "child_id"
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    func toDocument() -> Document {
        return Document(
            id: id ?? UUID(),
            title: title,
            description: description,
            documentType: DocumentType(rawValue: documentType) ?? .other,
            fileName: fileName,
            fileUrl: fileUrl,
            fileSize: fileSize,
            mimeType: mimeType,
            childId: childId,
            userId: userId,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
    
    static func from(_ document: Document) -> DocumentDTO {
        return DocumentDTO(
            id: document.id,
            title: document.title,
            description: document.description,
            documentType: document.documentType.rawValue,
            fileName: document.fileName,
            fileUrl: document.fileUrl,
            fileSize: document.fileSize,
            mimeType: document.mimeType,
            childId: document.childId,
            userId: document.userId,
            createdAt: document.createdAt,
            updatedAt: document.updatedAt
        )
    }
}