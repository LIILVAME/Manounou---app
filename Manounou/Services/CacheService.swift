//
//  CacheService.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation
import SwiftUI

/// Service de cache simplifié pour le POC
@MainActor
class CacheService: CacheServiceProtocol, ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = CacheService()
    
    // MARK: - Simple Cache Properties
    
    @Published private var cachedEvents: [Event]?
    @Published private var cachedChildren: [Child]?
    @Published private var cachedDocuments: [Document]?
    @Published private var lastSyncDate: Date?
    
    // MARK: - Initialization
    
    private init() {
        // Simple initialization - no complex setup needed for POC
    }
    
    // MARK: - CacheServiceProtocol Implementation
    
    var cacheStatistics: CacheStatistics {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        
        let lastSyncFormatted: String
        if let lastSync = lastSyncDate {
            lastSyncFormatted = formatter.localizedString(for: lastSync, relativeTo: Date())
        } else {
            lastSyncFormatted = "Jamais"
        }
        
        return CacheStatistics(
            formattedLastSync: lastSyncFormatted,
            hasEventsCache: cachedEvents != nil,
            hasChildrenCache: cachedChildren != nil,
            cacheSize: "En mémoire",
            lastSyncDate: lastSyncDate
        )
    }
    
    // MARK: - Events Cache
    
    func cacheEvents(_ events: [Event]) {
        cachedEvents = events
        lastSyncDate = Date()
    }
    
    func getCachedEvents() -> [Event]? {
        return cachedEvents
    }
    
    // MARK: - Children Cache
    
    func cacheChildren(_ children: [Child]) {
        cachedChildren = children
        lastSyncDate = Date()
    }
    
    func getCachedChildren() -> [Child]? {
        return cachedChildren
    }
    
    // MARK: - Documents Cache
    
    func cacheDocuments(_ documents: [Document]) {
        cachedDocuments = documents
        lastSyncDate = Date()
    }
    
    func getCachedDocuments() -> [Document]? {
        return cachedDocuments
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        cachedEvents = nil
        cachedChildren = nil
        cachedDocuments = nil
        lastSyncDate = nil
    }
    
    func clearEventsCache() {
        cachedEvents = nil
    }
    
    func clearChildrenCache() {
        cachedChildren = nil
    }
    
    func clearDocumentsCache() {
        cachedDocuments = nil
    }
}

// MARK: - Mock Implementation for Testing

class MockCacheService: CacheServiceProtocol, ObservableObject {
    private var eventsCache: [Event]?
    private var childrenCache: [Child]?
    private var documentsCache: [Document]?
    private var mockLastSyncDate: Date?
    
    var cacheStatistics: CacheStatistics {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        
        let lastSyncFormatted: String
        if let lastSync = mockLastSyncDate {
            lastSyncFormatted = formatter.localizedString(for: lastSync, relativeTo: Date())
        } else {
            lastSyncFormatted = "Jamais"
        }
        
        return CacheStatistics(
            formattedLastSync: lastSyncFormatted,
            hasEventsCache: eventsCache != nil,
            hasChildrenCache: childrenCache != nil,
            cacheSize: "1.2 MB",
            lastSyncDate: mockLastSyncDate
        )
    }
    
    func cacheEvents(_ events: [Event]) {
        eventsCache = events
        mockLastSyncDate = Date()
    }
    
    func getCachedEvents() -> [Event]? {
        return eventsCache
    }
    
    func cacheChildren(_ children: [Child]) {
        childrenCache = children
        mockLastSyncDate = Date()
    }
    
    func getCachedChildren() -> [Child]? {
        return childrenCache
    }
    
    func clearCache() {
        eventsCache = nil
        childrenCache = nil
        mockLastSyncDate = nil
    }
    
    func clearEventsCache() {
        eventsCache = nil
    }
    
    func clearChildrenCache() {
        childrenCache = nil
    }
    
    func cacheDocuments(_ documents: [Document]) {
        documentsCache = documents
        mockLastSyncDate = Date()
    }
    
    func getCachedDocuments() -> [Document]? {
        return documentsCache
    }
    
    func clearDocumentsCache() {
        documentsCache = nil
        mockLastSyncDate = Date()
    }
}