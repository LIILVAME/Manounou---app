//
//  CacheService.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation
import SwiftUI

/// Service de cache pour optimiser les performances de l'application
@MainActor
class CacheService: CacheServiceProtocol, ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = CacheService()
    
    // MARK: - Properties
    
    private let cache = NSCache<NSString, AnyObject>()
    private let userDefaults = UserDefaults.standard
    private let cacheQueue = DispatchQueue(label: "com.manounou.cache", qos: .utility)
    
    @Published private var lastSyncDate: Date?
    
    // Cache keys
    private enum CacheKeys {
        static let events = "cached_events"
        static let children = "cached_children"
        static let documents = "cached_documents"
        static let userProfile = "cached_user_profile"
        static let lastSyncDate = "last_sync_date"
    }
    
    // MARK: - Initialization
    
    private init() {
        setupCache()
        loadLastSyncDate()
    }
    
    private func setupCache() {
        // Configuration du cache en mémoire
        cache.countLimit = 100 // Limite du nombre d'objets
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // Nettoyage automatique lors des avertissements mémoire
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.clearMemoryCache()
        }
    }
    
    private func loadLastSyncDate() {
        if let date = userDefaults.object(forKey: CacheKeys.lastSyncDate) as? Date {
            self.lastSyncDate = date
        }
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
            hasEventsCache: getCachedEvents() != nil,
            hasChildrenCache: getCachedChildren() != nil,
            cacheSize: formatCacheSize(),
            lastSyncDate: lastSyncDate
        )
    }
    
    // MARK: - Events Cache
    
    func cacheEvents(_ events: [Event]) {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let data = try JSONEncoder().encode(events)
                self.userDefaults.set(data, forKey: CacheKeys.events)
                
                DispatchQueue.main.async {
                    self.updateLastSyncDate()
                }
            } catch {
                print("Erreur lors de la mise en cache des événements: \(error)")
            }
        }
    }
    
    func getCachedEvents() -> [Event]? {
        guard let data = userDefaults.data(forKey: CacheKeys.events) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode([Event].self, from: data)
        } catch {
            print("Erreur lors de la lecture du cache des événements: \(error)")
            return nil
        }
    }
    
    // MARK: - Children Cache
    
    func cacheChildren(_ children: [Child]) {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let data = try JSONEncoder().encode(children)
                self.userDefaults.set(data, forKey: CacheKeys.children)
                
                DispatchQueue.main.async {
                    self.updateLastSyncDate()
                }
            } catch {
                print("Erreur lors de la mise en cache des enfants: \(error)")
            }
        }
    }
    
    func getCachedChildren() -> [Child]? {
        guard let data = userDefaults.data(forKey: CacheKeys.children) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode([Child].self, from: data)
        } catch {
            print("Erreur lors de la lecture du cache des enfants: \(error)")
            return nil
        }
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        clearMemoryCache()
        clearPersistentCache()
        updateLastSyncDate()
    }
    
    func clearEventsCache() {
        userDefaults.removeObject(forKey: CacheKeys.events)
        cache.removeObject(forKey: CacheKeys.events as NSString)
    }
    
    func clearChildrenCache() {
        cache.removeObject(forKey: CacheKeys.children as NSString)
        userDefaults.removeObject(forKey: CacheKeys.children)
    }
    
    // MARK: - Documents Cache
    
    func cacheDocuments(_ documents: [Document]) {
        cacheQueue.async {
            DispatchQueue.main.async {
                // Cache en mémoire
                self.cache.setObject(documents as NSArray, forKey: CacheKeys.documents as NSString)
                
                // Cache persistant
                if let encoded = try? JSONEncoder().encode(documents) {
                    self.userDefaults.set(encoded, forKey: CacheKeys.documents)
                }
                
                self.updateLastSyncDate()
            }
        }
    }
    
    func getCachedDocuments() -> [Document]? {
        // Essayer le cache mémoire d'abord
        if let cached = cache.object(forKey: CacheKeys.documents as NSString) as? [Document] {
            return cached
        }
        
        // Fallback sur le cache persistant
        if let data = userDefaults.data(forKey: CacheKeys.documents),
           let documents = try? JSONDecoder().decode([Document].self, from: data) {
            // Remettre en cache mémoire
            cache.setObject(documents as NSArray, forKey: CacheKeys.documents as NSString)
            return documents
        }
        
        return nil
    }
    
    func clearDocumentsCache() {
        cache.removeObject(forKey: CacheKeys.documents as NSString)
        userDefaults.removeObject(forKey: CacheKeys.documents)
    }
    
    // MARK: - Private Methods
    
    private func clearMemoryCache() {
        cache.removeAllObjects()
    }
    
    private func clearPersistentCache() {
        let keys = [CacheKeys.events, CacheKeys.children, CacheKeys.documents, CacheKeys.userProfile]
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
    
    private func updateLastSyncDate() {
        let now = Date()
        lastSyncDate = now
        userDefaults.set(now, forKey: CacheKeys.lastSyncDate)
    }
    
    private func formatCacheSize() -> String {
        let eventsSize = userDefaults.data(forKey: CacheKeys.events)?.count ?? 0
        let childrenSize = userDefaults.data(forKey: CacheKeys.children)?.count ?? 0
        let documentsSize = userDefaults.data(forKey: CacheKeys.documents)?.count ?? 0
        
        let totalSize = eventsSize + childrenSize + documentsSize
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: Int64(totalSize))
    }
    
    // MARK: - Generic Cache Methods
    
    func cacheObject<T: Codable>(_ object: T, forKey key: String) {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let data = try JSONEncoder().encode(object)
                self.userDefaults.set(data, forKey: key)
                
                DispatchQueue.main.async {
                    self.updateLastSyncDate()
                }
            } catch {
                print("Erreur lors de la mise en cache de l'objet \(key): \(error)")
            }
        }
    }
    
    func getCachedObject<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Erreur lors de la lecture du cache pour \(key): \(error)")
            return nil
        }
    }
    
    func removeCachedObject(forKey key: String) {
        userDefaults.removeObject(forKey: key)
        cache.removeObject(forKey: key as NSString)
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