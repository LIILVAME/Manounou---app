//
//  DocumentsViewModel.swift
//  Manounou
//
//  Created by Assistant on 17/08/2025.
//

import Foundation
import SwiftUI

@MainActor
class DocumentsViewModel: ObservableObject {
    @Published var documents: [Document] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let documentsService: DocumentsServiceProtocol
    
    init(documentsService: DocumentsServiceProtocol = DocumentsService()) {
        self.documentsService = documentsService
    }
    
    // MARK: - Documents Management
    
    func loadDocuments() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedDocuments = try await documentsService.fetchDocuments()
            self.documents = fetchedDocuments
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createDocument(_ document: Document) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let createdDocument = try await documentsService.createDocument(document)
            self.documents.append(createdDocument)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateDocument(_ document: Document) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedDocument = try await documentsService.updateDocument(document)
            
            if let index = documents.firstIndex(where: { $0.id == document.id }) {
                documents[index] = updatedDocument
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteDocument(_ document: Document) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await documentsService.deleteDocument(id: document.id)
            
            // Delete file if exists
            if let fileUrl = document.fileUrl {
                try await documentsService.deleteFile(url: fileUrl)
            }
            
            documents.removeAll { $0.id == document.id }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func uploadDocument(
        title: String,
        description: String?,
        documentType: DocumentType,
        childId: UUID?,
        userId: UUID,
        fileData: Data,
        fileName: String,
        mimeType: String
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Upload file first
            let fileUrl = try await documentsService.uploadFile(
                data: fileData,
                fileName: fileName,
                mimeType: mimeType
            )
            
            // Create document record
            let document = Document(
                title: title,
                description: description,
                documentType: documentType,
                fileName: fileName,
                fileUrl: fileUrl,
                fileSize: fileData.count,
                mimeType: mimeType,
                childId: childId,
                userId: userId
            )
            
            let createdDocument = try await documentsService.createDocument(document)
            self.documents.append(createdDocument)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchDocumentsForChild(childId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedDocuments = try await documentsService.fetchDocumentsForChild(childId: childId)
            self.documents = fetchedDocuments
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchDocumentsByType(_ type: DocumentType) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedDocuments = try await documentsService.fetchDocumentsByType(type)
            self.documents = fetchedDocuments
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearDocuments() {
        documents.removeAll()
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Computed Properties
    
    var documentsByType: [DocumentType: [Document]] {
        Dictionary(grouping: documents) { $0.documentType }
    }
    
    var recentDocuments: [Document] {
        documents
            .filter { $0.isRecent }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    var documentsCount: Int {
        documents.count
    }
    
    func documentsCount(for type: DocumentType) -> Int {
        documents.filter { $0.documentType == type }.count
    }
    
    func documentsCount(for childId: UUID) -> Int {
        documents.filter { $0.childId == childId }.count
    }
}