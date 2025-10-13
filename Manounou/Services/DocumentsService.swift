//
//  DocumentsService.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation
import Supabase

class DocumentsService: DocumentsServiceProtocol, ObservableObject {
    private let supabaseClient: SupabaseClient
    private let cacheService: CacheServiceProtocol
    
    init(supabaseClient: SupabaseClient, cacheService: CacheServiceProtocol) {
        self.supabaseClient = supabaseClient
        self.cacheService = cacheService
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
            cacheService.cacheDocuments(documents)
            
            return documents
        } catch {
            // Fallback to cache if network fails
            if let cachedDocuments = cacheService.getCachedDocuments() {
                return cachedDocuments
            }
            throw ServiceError.networkError("Impossible de récupérer les documents: \(error.localizedDescription)")
        }
    }
    
    func createDocument(_ document: Document) async throws -> Document {
        do {
            let documentDTO = DocumentDTO.from(document)
            let response: DocumentDTO = try await supabaseClient
                .from("documents")
                .insert(documentDTO)
                .select()
                .single()
                .execute()
                .value
            
            return response.toDocument()
        } catch {
            throw ServiceError.networkError("Impossible de créer le document: \(error.localizedDescription)")
        }
    }
    
    func updateDocument(_ document: Document) async throws -> Document {
        do {
            let documentDTO = DocumentDTO.from(document)
            let response: DocumentDTO = try await supabaseClient
                .from("documents")
                .update(documentDTO)
                .eq("id", value: document.id)
                .select()
                .single()
                .execute()
                .value
            
            return response.toDocument()
        } catch {
            throw ServiceError.networkError("Impossible de mettre à jour le document: \(error.localizedDescription)")
        }
    }
    
    func deleteDocument(id: UUID) async throws {
        do {
            try await supabaseClient
                .from("documents")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            throw ServiceError.networkError("Impossible de supprimer le document: \(error.localizedDescription)")
        }
    }
    
    func fetchDocumentsForChild(childId: UUID) async throws -> [Document] {
        do {
            let response: [DocumentDTO] = try await supabaseClient
                .from("documents")
                .select()
                .eq("child_id", value: childId)
                .execute()
                .value
            
            return response.map { $0.toDocument() }
        } catch {
            throw ServiceError.networkError("Impossible de récupérer les documents de l'enfant: \(error.localizedDescription)")
        }
    }
    
    func fetchDocumentsByType(_ type: DocumentType) async throws -> [Document] {
        do {
            let response: [DocumentDTO] = try await supabaseClient
                .from("documents")
                .select()
                .eq("document_type", value: type.rawValue)
                .execute()
                .value
            
            return response.map { $0.toDocument() }
        } catch {
            throw ServiceError.networkError("Impossible de récupérer les documents par type: \(error.localizedDescription)")
        }
    }
    
    // MARK: - File Upload
    
    func uploadFile(data: Data, fileName: String, mimeType: String) async throws -> String {
        do {
            let filePath = "documents/\(UUID().uuidString)_\(fileName)"
            
            // Supabase Storage API expects Data in recent versions
            try await supabaseClient.storage
                .from("documents")
                .upload(filePath, data: data)
            
            let publicURL = try supabaseClient.storage
                .from("documents")
                .getPublicURL(path: filePath)
            
            return publicURL.absoluteString
        } catch {
            throw ServiceError.networkError("Impossible d'uploader le fichier: \(error.localizedDescription)")
        }
    }
    
    func deleteFile(url: String) async throws {
        do {
            // Extract file path from URL
            guard let urlComponents = URLComponents(string: url),
                  let path = urlComponents.path.components(separatedBy: "/documents/").last else {
                throw ServiceError.validationError("URL de fichier invalide")
            }
            
            try await supabaseClient.storage
                .from("documents")
                .remove(paths: ["documents/\(path)"])
        } catch {
            throw ServiceError.networkError("Impossible de supprimer le fichier: \(error.localizedDescription)")
        }
    }
}

// MARK: - Document DTO

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
        case id
        case title
        case description
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

// MARK: - Mock Documents Service

class MockDocumentsService: DocumentsServiceProtocol, ObservableObject {
    private var documents: [Document] = []
    private var shouldFailRequests = false
    
    init(shouldFailRequests: Bool = false) {
        self.shouldFailRequests = shouldFailRequests
        self.documents = Self.sampleDocuments
    }
    
    func fetchDocuments() async throws -> [Document] {
        if shouldFailRequests {
            throw ServiceError.networkError("Erreur simulée")
        }
        return documents
    }
    
    func createDocument(_ document: Document) async throws -> Document {
        if shouldFailRequests {
            throw ServiceError.networkError("Erreur simulée")
        }
        
        let newDocument = Document(
            id: UUID(),
            title: document.title,
            description: document.description,
            documentType: document.documentType,
            fileName: document.fileName,
            fileUrl: document.fileUrl,
            fileSize: document.fileSize,
            mimeType: document.mimeType,
            childId: document.childId,
            userId: document.userId,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        documents.append(newDocument)
        return newDocument
    }
    
    func updateDocument(_ document: Document) async throws -> Document {
        if shouldFailRequests {
            throw ServiceError.networkError("Erreur simulée")
        }
        
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            documents[index] = document
            return document
        }
        
        throw ServiceError.validationError("Document non trouvé")
    }
    
    func deleteDocument(id: UUID) async throws {
        if shouldFailRequests {
            throw ServiceError.networkError("Erreur simulée")
        }
        
        documents.removeAll { $0.id == id }
    }
    
    func fetchDocumentsForChild(childId: UUID) async throws -> [Document] {
        if shouldFailRequests {
            throw ServiceError.networkError("Erreur simulée")
        }
        
        return documents.filter { $0.childId == childId }
    }
    
    func fetchDocumentsByType(_ type: DocumentType) async throws -> [Document] {
        if shouldFailRequests {
            throw ServiceError.networkError("Erreur simulée")
        }
        
        return documents.filter { $0.documentType == type }
    }
    
    func uploadFile(data: Data, fileName: String, mimeType: String) async throws -> String {
        if shouldFailRequests {
            throw ServiceError.networkError("Erreur simulée")
        }
        
        // Simulate file upload
        return "https://example.com/documents/\(UUID().uuidString)_\(fileName)"
    }
    
    func deleteFile(url: String) async throws {
        if shouldFailRequests {
            throw ServiceError.networkError("Erreur simulée")
        }
        
        // Simulate file deletion
    }
    
    func setFailureMode(_ shouldFail: Bool) {
        shouldFailRequests = shouldFail
    }
    
    private static let sampleDocuments: [Document] = [
        Document(
            title: "Carnet de santé",
            description: "Carnet de santé complet",
            documentType: .medical,
            fileName: "carnet_sante.pdf",
            fileSize: 2048000,
            mimeType: "application/pdf",
            userId: UUID()
        ),
        Document(
            title: "Bulletin scolaire",
            description: "Premier trimestre",
            documentType: .school,
            fileName: "bulletin_t1.pdf",
            fileSize: 512000,
            mimeType: "application/pdf",
            userId: UUID()
        ),
        Document(
            title: "Photo anniversaire",
            description: "5ème anniversaire",
            documentType: .photo,
            fileName: "anniversaire.jpg",
            fileSize: 3072000,
            mimeType: "image/jpeg",
            userId: UUID()
        )
    ]
}