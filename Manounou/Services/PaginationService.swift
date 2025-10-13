//
//  PaginationService.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation
import os.log

// MARK: - Pagination Service
class PaginationService {
    static let shared = PaginationService()
    
    private init() {}
    
    // MARK: - Children Pagination
    
    func loadChildrenPage(page: Int, pageSize: Int, from children: [FunctionalChild]) async throws -> PaginatedResult<FunctionalChild> {
        // Simulate network delay for realistic behavior
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        let startIndex = page * pageSize
        let endIndex = min(startIndex + pageSize, children.count)
        
        guard startIndex < children.count else {
            return PaginatedResult(
                items: [],
                currentPage: page,
                totalPages: (children.count + pageSize - 1) / pageSize,
                totalItems: children.count,
                hasNextPage: false,
                hasPreviousPage: page > 0
            )
        }
        
        let pageItems = Array(children[startIndex..<endIndex])
        let totalPages = (children.count + pageSize - 1) / pageSize
        
        print("📄 Loaded children page \(page): \(pageItems.count) items")
        
        return PaginatedResult(
            items: pageItems,
            currentPage: page,
            totalPages: totalPages,
            totalItems: children.count,
            hasNextPage: endIndex < children.count,
            hasPreviousPage: page > 0
        )
    }
    
    // MARK: - Events Pagination
    
    func loadEventsPage(page: Int, pageSize: Int, from events: [FunctionalEvent]) async throws -> PaginatedResult<FunctionalEvent> {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        let startIndex = page * pageSize
        let endIndex = min(startIndex + pageSize, events.count)
        
        guard startIndex < events.count else {
            return PaginatedResult(
                items: [],
                currentPage: page,
                totalPages: (events.count + pageSize - 1) / pageSize,
                totalItems: events.count,
                hasNextPage: false,
                hasPreviousPage: page > 0
            )
        }
        
        let pageItems = Array(events[startIndex..<endIndex])
        let totalPages = (events.count + pageSize - 1) / pageSize
        
        print("📅 Loaded events page \(page): \(pageItems.count) items")
        
        return PaginatedResult(
            items: pageItems,
            currentPage: page,
            totalPages: totalPages,
            totalItems: events.count,
            hasNextPage: endIndex < events.count,
            hasPreviousPage: page > 0
        )
    }
    
    // MARK: - Documents Pagination
    
    func loadDocumentsPage(page: Int, pageSize: Int, from documents: [FunctionalDocument]) async throws -> PaginatedResult<FunctionalDocument> {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 250_000_000) // 0.25 seconds
        
        let startIndex = page * pageSize
        let endIndex = min(startIndex + pageSize, documents.count)
        
        guard startIndex < documents.count else {
            return PaginatedResult(
                items: [],
                currentPage: page,
                totalPages: (documents.count + pageSize - 1) / pageSize,
                totalItems: documents.count,
                hasNextPage: false,
                hasPreviousPage: page > 0
            )
        }
        
        let pageItems = Array(documents[startIndex..<endIndex])
        let totalPages = (documents.count + pageSize - 1) / pageSize
        
        print("📄 Loaded documents page \(page): \(pageItems.count) items")
        
        return PaginatedResult(
            items: pageItems,
            currentPage: page,
            totalPages: totalPages,
            totalItems: documents.count,
            hasNextPage: endIndex < documents.count,
            hasPreviousPage: page > 0
        )
    }
    
    // MARK: - Search Results Pagination
    
    func searchChildren(query: String, page: Int, pageSize: Int, from children: [FunctionalChild]) async throws -> PaginatedResult<FunctionalChild> {
        // Simulate search delay
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        
        let filteredChildren = children.filter { child in
            child.firstName.localizedCaseInsensitiveContains(query) ||
            child.lastName.localizedCaseInsensitiveContains(query)
        }
        
        let startIndex = page * pageSize
        let endIndex = min(startIndex + pageSize, filteredChildren.count)
        
        guard startIndex < filteredChildren.count else {
            return PaginatedResult(
                items: [],
                currentPage: page,
                totalPages: (filteredChildren.count + pageSize - 1) / pageSize,
                totalItems: filteredChildren.count,
                hasNextPage: false,
                hasPreviousPage: page > 0
            )
        }
        
        let pageItems = Array(filteredChildren[startIndex..<endIndex])
        let totalPages = (filteredChildren.count + pageSize - 1) / pageSize
        
        print("🔍 Search results page \(page): \(pageItems.count) items for query '\(query)'")
        
        return PaginatedResult(
            items: pageItems,
            currentPage: page,
            totalPages: totalPages,
            totalItems: filteredChildren.count,
            hasNextPage: endIndex < filteredChildren.count,
            hasPreviousPage: page > 0
        )
    }
    
    func searchEvents(query: String, page: Int, pageSize: Int, from events: [FunctionalEvent]) async throws -> PaginatedResult<FunctionalEvent> {
        // Simulate search delay
        try await Task.sleep(nanoseconds: 350_000_000) // 0.35 seconds
        
        let filteredEvents = events.filter { event in
            event.title.localizedCaseInsensitiveContains(query) ||
            event.description.localizedCaseInsensitiveContains(query)
        }
        
        let startIndex = page * pageSize
        let endIndex = min(startIndex + pageSize, filteredEvents.count)
        
        guard startIndex < filteredEvents.count else {
            return PaginatedResult(
                items: [],
                currentPage: page,
                totalPages: (filteredEvents.count + pageSize - 1) / pageSize,
                totalItems: filteredEvents.count,
                hasNextPage: false,
                hasPreviousPage: page > 0
            )
        }
        
        let pageItems = Array(filteredEvents[startIndex..<endIndex])
        let totalPages = (filteredEvents.count + pageSize - 1) / pageSize
        
        print("🔍 Search events page \(page): \(pageItems.count) items for query '\(query)'")
        
        return PaginatedResult(
            items: pageItems,
            currentPage: page,
            totalPages: totalPages,
            totalItems: filteredEvents.count,
            hasNextPage: endIndex < filteredEvents.count,
            hasPreviousPage: page > 0
        )
    }
    
    func searchDocuments(query: String, page: Int, pageSize: Int, from documents: [FunctionalDocument]) async throws -> PaginatedResult<FunctionalDocument> {
        // Simulate search delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        let filteredDocuments = documents.filter { document in
            document.title.localizedCaseInsensitiveContains(query) ||
            document.type.localizedCaseInsensitiveContains(query)
        }
        
        let startIndex = page * pageSize
        let endIndex = min(startIndex + pageSize, filteredDocuments.count)
        
        guard startIndex < filteredDocuments.count else {
            return PaginatedResult(
                items: [],
                currentPage: page,
                totalPages: (filteredDocuments.count + pageSize - 1) / pageSize,
                totalItems: filteredDocuments.count,
                hasNextPage: false,
                hasPreviousPage: page > 0
            )
        }
        
        let pageItems = Array(filteredDocuments[startIndex..<endIndex])
        let totalPages = (filteredDocuments.count + pageSize - 1) / pageSize
        
        print("🔍 Search documents page \(page): \(pageItems.count) items for query '\(query)'")
        
        return PaginatedResult(
            items: pageItems,
            currentPage: page,
            totalPages: totalPages,
            totalItems: filteredDocuments.count,
            hasNextPage: endIndex < filteredDocuments.count,
            hasPreviousPage: page > 0
        )
    }
}

// MARK: - Pagination Error
enum PaginationError: LocalizedError {
    case invalidPage
    case networkError
    case dataCorruption
    
    var errorDescription: String? {
        switch self {
        case .invalidPage:
            return "Page invalide demandée"
        case .networkError:
            return "Erreur de réseau lors du chargement"
        case .dataCorruption:
            return "Données corrompues détectées"
        }
    }
}