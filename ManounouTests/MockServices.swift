//
//  MockServices.swift
//  ManounouTests
//
//  Created by Assistant on 17/08/2025.
//

import Foundation
@testable import ManounouApp

// MARK: - Mock Documents Service
class MockDocumentsService: DocumentsServiceProtocol {
    var mockDocuments: [Document] = []
    var shouldFail = false
    
    func fetchDocuments() async throws -> [Document] {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockDocuments
    }
    
    func createDocument(_ document: Document) async throws -> Document {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        mockDocuments.append(document)
        return document
    }
    
    func updateDocument(_ document: Document) async throws -> Document {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        if let index = mockDocuments.firstIndex(where: { $0.id == document.id }) {
            mockDocuments[index] = document
        }
        return document
    }
    
    func deleteDocument(id: UUID) async throws {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        mockDocuments.removeAll { $0.id == id }
    }
    
    func fetchDocumentsForChild(childId: UUID) async throws -> [Document] {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockDocuments.filter { $0.childId == childId }
    }
    
    func fetchDocumentsByType(_ type: DocumentType) async throws -> [Document] {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockDocuments.filter { $0.type == type }
    }
    
    func uploadFile(data: Data, fileName: String, mimeType: String) async throws -> String {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return "mock-file-url"
    }
    
    func deleteFile(url: String) async throws {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
    }
}

// MARK: - Mock Children Service
class MockChildrenService: ChildrenServiceProtocol {
    var mockChildren: [Child] = []
    var shouldFail = false
    
    func fetchChildren() async throws -> [Child] {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockChildren
    }
    
    func createChild(_ child: Child) async throws -> Child {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        mockChildren.append(child)
        return child
    }
    
    func updateChild(_ child: Child) async throws -> Child {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        if let index = mockChildren.firstIndex(where: { $0.id == child.id }) {
            mockChildren[index] = child
        }
        return child
    }
    
    func deleteChild(id: UUID) async throws {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        mockChildren.removeAll { $0.id == id }
    }
}

// MARK: - Mock Events Service
class MockEventsService: EventsServiceProtocol {
    var mockEvents: [Event] = []
    var shouldFail = false
    
    func fetchEvents() async throws -> [Event] {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockEvents
    }
    
    func createEvent(_ event: Event) async throws -> Event {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        mockEvents.append(event)
        return event
    }
    
    func updateEvent(_ event: Event) async throws -> Event {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        if let index = mockEvents.firstIndex(where: { $0.id == event.id }) {
            mockEvents[index] = event
        }
        return event
    }
    
    func deleteEvent(id: UUID) async throws {
        if shouldFail {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        mockEvents.removeAll { $0.id == id }
    }
}