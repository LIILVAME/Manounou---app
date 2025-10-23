import Foundation
import Combine

/// Service de cache simple pour l'application Manounou
class CacheService: CacheServiceProtocol {
    static let shared = CacheService()
    
    // MARK: - Cached data
    @Published var cachedEvents: [Event]? = nil
    @Published var cachedChildren: [Child]? = nil
    @Published var cachedDocuments: [Document]? = nil
    @Published var lastSyncDate: Date? = nil
    
    // MARK: - TTL & LRU configuration
    private let defaultTTL: TimeInterval = 300 // 5 minutes par défaut
    private let maxListItems: Int = 200 // Limiter la taille des listes en cache
    
    private var eventsExpiry: Date? = nil
    private var childrenExpiry: Date? = nil
    private var documentsExpiry: Date? = nil
    
    // Petit KV store avec LRU
    private var kvCapacity: Int = 100
    private var kvStore: [String: (value: Any, expiresAt: Date)] = [:]
    private var lruKeys: [String] = []
    
    // MARK: - Caching operations
    func cacheEvents(_ events: [Event]) {
        cachedEvents = Array(events.prefix(maxListItems))
        lastSyncDate = Date()
        eventsExpiry = Date().addingTimeInterval(defaultTTL)
        Logger.cache("Events cached: \(cachedEvents?.count ?? 0), ttl \(Int(defaultTTL))s", level: .info)
    }
    
    func getCachedEvents() -> [Event]? {
        if let expiry = eventsExpiry, expiry < Date() {
            Logger.cache("Events cache expired", level: .debug)
            cachedEvents = nil
            eventsExpiry = nil
            return nil
        }
        return cachedEvents
    }
    
    func cacheChildren(_ children: [Child]) {
        cachedChildren = Array(children.prefix(maxListItems))
        lastSyncDate = Date()
        childrenExpiry = Date().addingTimeInterval(defaultTTL)
        Logger.cache("Children cached: \(cachedChildren?.count ?? 0), ttl \(Int(defaultTTL))s", level: .info)
    }
    
    func getCachedChildren() -> [Child]? {
        if let expiry = childrenExpiry, expiry < Date() {
            Logger.cache("Children cache expired", level: .debug)
            cachedChildren = nil
            childrenExpiry = nil
            return nil
        }
        return cachedChildren
    }
    
    func cacheDocuments(_ documents: [Document]) {
        cachedDocuments = Array(documents.prefix(maxListItems))
        lastSyncDate = Date()
        documentsExpiry = Date().addingTimeInterval(defaultTTL)
        Logger.cache("Documents cached: \(cachedDocuments?.count ?? 0), ttl \(Int(defaultTTL))s", level: .info)
    }
    
    func getCachedDocuments() -> [Document]? {
        if let expiry = documentsExpiry, expiry < Date() {
            Logger.cache("Documents cache expired", level: .debug)
            cachedDocuments = nil
            documentsExpiry = nil
            return nil
        }
        return cachedDocuments
    }
    
    // MARK: - KV LRU API
    func setValue(_ value: Any, forKey key: String, ttl: TimeInterval? = nil) {
        let expiresAt = Date().addingTimeInterval(ttl ?? defaultTTL)
        kvStore[key] = (value, expiresAt)
        if let idx = lruKeys.firstIndex(of: key) { lruKeys.remove(at: idx) }
        lruKeys.insert(key, at: 0)
        evictLRUIfNeeded()
        Logger.cache("KV set: \(key) (ttl: \(Int(ttl ?? defaultTTL))s)", level: .debug)
    }
    
    func getValue(forKey key: String) -> Any? {
        guard let entry = kvStore[key] else { return nil }
        if entry.expiresAt < Date() {
            Logger.cache("KV expired: \(key)", level: .debug)
            kvStore[key] = nil
            if let idx = lruKeys.firstIndex(of: key) { lruKeys.remove(at: idx) }
            return nil
        }
        if let idx = lruKeys.firstIndex(of: key) {
            lruKeys.remove(at: idx)
            lruKeys.insert(key, at: 0)
        }
        return entry.value
    }
    
    func removeValue(forKey key: String) {
        kvStore[key] = nil
        if let idx = lruKeys.firstIndex(of: key) { lruKeys.remove(at: idx) }
        Logger.cache("KV removed: \(key)", level: .debug)
    }
    
    private func evictLRUIfNeeded() {
        while lruKeys.count > kvCapacity {
            if let lastKey = lruKeys.last {
                lruKeys.removeLast()
                kvStore[lastKey] = nil
                Logger.cache("KV evicted LRU: \(lastKey)", level: .debug)
            }
        }
    }
    
    // MARK: - Cache management
    func clearCache() {
        cachedEvents = nil
        cachedChildren = nil
        cachedDocuments = nil
        lastSyncDate = nil
        eventsExpiry = nil
        childrenExpiry = nil
        documentsExpiry = nil
        kvStore.removeAll()
        lruKeys.removeAll()
        Logger.cache("Cache cleared", level: .info)
    }
    
    func clearEventsCache() {
        cachedEvents = nil
        eventsExpiry = nil
        Logger.cache("Events cache cleared", level: .debug)
    }
    
    func clearChildrenCache() {
        cachedChildren = nil
        childrenExpiry = nil
        Logger.cache("Children cache cleared", level: .debug)
    }
    
    func clearDocumentsCache() {
        cachedDocuments = nil
        documentsExpiry = nil
        Logger.cache("Documents cache cleared", level: .debug)
    }
    
    // MARK: - Statistics (protocol property)
    var cacheStatistics: CacheStatistics {
        let eventsCount = cachedEvents?.count ?? 0
        let childrenCount = cachedChildren?.count ?? 0
        let documentsCount = cachedDocuments?.count ?? 0
        
        let totalItems = eventsCount + childrenCount + documentsCount
        let cacheSize = "\(totalItems) éléments"
        
        var lastSyncFormatted = "Jamais"
        if let lastSync = lastSyncDate {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            lastSyncFormatted = formatter.string(from: lastSync)
        }
        
        return CacheStatistics(
            formattedLastSync: lastSyncFormatted,
            hasEventsCache: eventsCount > 0,
            hasChildrenCache: childrenCount > 0,
            cacheSize: cacheSize,
            lastSyncDate: lastSyncDate
        )
    }
}

// Service de cache Mock pour les tests ou le mode démo
class MockCacheService: CacheService {
    override func cacheEvents(_ events: [Event]) {
        super.cacheEvents(events)
    }
    
    override func cacheChildren(_ children: [Child]) {
        super.cacheChildren(children)
    }
    
    override func cacheDocuments(_ documents: [Document]) {
        super.cacheDocuments(documents)
    }
}