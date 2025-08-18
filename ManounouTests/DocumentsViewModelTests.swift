//
//  DocumentsViewModelTests.swift
//  ManounouTests
//
//  Created by Assistant on 17/08/2025.
//

import XCTest
@testable import Manounou

@MainActor
class DocumentsViewModelTests: XCTestCase {
    
    var viewModel: DocumentsViewModel!
    var mockService: MockDocumentsService!
    
    override func setUp() {
        super.setUp()
        mockService = MockDocumentsService()
        viewModel = DocumentsViewModel(documentsService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertTrue(viewModel.documents.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.documentsCount, 0)
    }
    
    // MARK: - Load Documents Tests
    
    func testLoadDocumentsSuccess() async {
        // Given
        let expectedDocuments = Document.sampleDocuments
        mockService.mockDocuments = expectedDocuments
        
        // When
        await viewModel.loadDocuments()
        
        // Then
        XCTAssertEqual(viewModel.documents.count, expectedDocuments.count)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadDocumentsFailure() async {
        // Given
        mockService.shouldFail = true
        
        // When
        await viewModel.loadDocuments()
        
        // Then
        XCTAssertTrue(viewModel.documents.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    // MARK: - Create Document Tests
    
    func testCreateDocumentSuccess() async {
        // Given
        let newDocument = Document.sampleDocuments.first!
        
        // When
        await viewModel.createDocument(newDocument)
        
        // Then
        XCTAssertEqual(viewModel.documents.count, 1)
        XCTAssertEqual(viewModel.documents.first?.id, newDocument.id)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Documents by Type Tests
    
    func testDocumentsByType() {
        // Given
        viewModel.documents = Document.sampleDocuments
        
        // When
        let documentsByType = viewModel.documentsByType
        
        // Then
        XCTAssertFalse(documentsByType.isEmpty)
        for (type, docs) in documentsByType {
            XCTAssertTrue(docs.allSatisfy { $0.documentType == type })
        }
    }
    
    // MARK: - Recent Documents Tests
    
    func testRecentDocuments() {
        // Given
        let recentDate = Date()
        let oldDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        
        let recentDoc = Document(
            title: "Recent",
            description: "Recent document",
            documentType: .medical,
            fileName: "recent.pdf",
            fileURL: "url",
            fileSize: 1000,
            mimeType: "application/pdf",
            childId: nil,
            userId: UUID(),
            createdAt: recentDate,
            updatedAt: recentDate
        )
        
        let oldDoc = Document(
            title: "Old",
            description: "Old document",
            documentType: .medical,
            fileName: "old.pdf",
            fileURL: "url",
            fileSize: 1000,
            mimeType: "application/pdf",
            childId: nil,
            userId: UUID(),
            createdAt: oldDate,
            updatedAt: oldDate
        )
        
        viewModel.documents = [oldDoc, recentDoc]
        
        // When
        let recentDocuments = viewModel.recentDocuments
        
        // Then
        XCTAssertEqual(recentDocuments.count, 1)
        XCTAssertEqual(recentDocuments.first?.title, "Recent")
    }
    
    // MARK: - Document Count Tests
    
    func testDocumentsCountForType() {
        // Given
        viewModel.documents = Document.sampleDocuments
        
        // When
        let medicalCount = viewModel.documentsCount(for: .medical)
        
        // Then
        let expectedCount = Document.sampleDocuments.filter { $0.documentType == .medical }.count
        XCTAssertEqual(medicalCount, expectedCount)
    }
    
    func testDocumentsCountForChild() {
        // Given
        let childId = UUID()
        let docWithChild = Document(
            title: "Child Doc",
            description: "Document for child",
            documentType: .medical,
            fileName: "child.pdf",
            fileURL: "url",
            fileSize: 1000,
            mimeType: "application/pdf",
            childId: childId,
            userId: UUID(),
            createdAt: Date(),
            updatedAt: Date()
        )
        
        viewModel.documents = [docWithChild]
        
        // When
        let count = viewModel.documentsCount(for: childId)
        
        // Then
        XCTAssertEqual(count, 1)
    }
    
    // MARK: - Error Handling Tests
    
    func testClearError() {
        // Given
        viewModel.errorMessage = "Test error"
        
        // When
        viewModel.clearError()
        
        // Then
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testClearDocuments() {
        // Given
        viewModel.documents = Document.sampleDocuments
        
        // When
        viewModel.clearDocuments()
        
        // Then
        XCTAssertTrue(viewModel.documents.isEmpty)
        XCTAssertEqual(viewModel.documentsCount, 0)
    }
}

// MARK: - Mock Service

class MockDocumentsService: DocumentsServiceProtocol {
    var mockDocuments: [Document] = []
    var shouldFail = false
    
    func fetchDocuments() async throws -> [Document] {
        if shouldFail {
            throw ServiceError.networkError("Mock error")
        }
        return mockDocuments
    }
    
    func createDocument(_ document: Document) async throws -> Document {
        if shouldFail {
            throw ServiceError.networkError("Mock error")
        }
        return document
    }
    
    func updateDocument(_ document: Document) async throws -> Document {
        if shouldFail {
            throw ServiceError.networkError("Mock error")
        }
        return document
    }
    
    func deleteDocument(id: UUID) async throws {
        if shouldFail {
            throw ServiceError.networkError("Mock error")
        }
    }
    
    func fetchDocumentsForChild(childId: UUID) async throws -> [Document] {
        if shouldFail {
            throw ServiceError.networkError("Mock error")
        }
        return mockDocuments.filter { $0.childId == childId }
    }
    
    func fetchDocumentsByType(_ type: DocumentType) async throws -> [Document] {
        if shouldFail {
            throw ServiceError.networkError("Mock error")
        }
        return mockDocuments.filter { $0.documentType == type }
    }
    
    func uploadFile(data: Data, fileName: String, mimeType: String) async throws -> String {
        if shouldFail {
            throw ServiceError.networkError("Mock error")
        }
        return "mock-url"
    }
    
    func deleteFile(url: String) async throws {
        if shouldFail {
            throw ServiceError.networkError("Mock error")
        }
    }
}