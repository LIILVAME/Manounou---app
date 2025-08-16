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
class CacheService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = CacheService()
    
    // MARK: - Properties
    
    private let cache = NSCache<NSString, AnyObject>()
    private let userDefaults = UserDefaults.standard
    private let cacheQueue = DispatchQueue(label: "com.manounou.cache", qos: .utility)
    
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
    
    // MARK: - Events Cache
    
    func cacheEvents(_ events: [Event]) {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Cache en mémoire
            self.cache.setObject(events as NSArray, forKey: CacheKeys.events as NSString)
            
            // Cache persistant
            if let data = try? JSONEncoder().encode(events) {
                self.userDefaults.set(data, forKey: CacheKeys.events)
                self.updateLastSyncDate()
            }
        }
    }
    
    func getCachedEvents() -> [Event]? {
        // Vérifier d'abord le cache mémoire
        if let cachedEvents = cache.object(forKey: CacheKeys.events as NSString) as? [Event] {
            return cachedEvents
        }
        
        // Sinon, vérifier le cache persistant
        guard let data = userDefaults.data(forKey: CacheKeys.events),
              let events = try? JSONDecoder().decode([Event].self, from: data) else {
            return nil
        }
        
        // Remettre en cache mémoire
        cache.setObject(events as NSArray, forKey: CacheKeys.events as NSString)
        return events
    }
    
    // MARK: - Children Cache
    
    func cacheChildren(_ children: [Child]) {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Cache en mémoire
            self.cache.setObject(children as NSArray, forKey: CacheKeys.children as NSString)
            
            // Cache persistant
            if let data = try? JSONEncoder().encode(children) {
                self.userDefaults.set(data, forKey: CacheKeys.children)
                self.updateLastSyncDate()
            }
        }
    }
    
    func getCachedChildren() -> [Child]? {
        // Vérifier d'abord le cache mémoire
        if let cachedChildren = cache.object(forKey: CacheKeys.children as NSString) as? [Child] {
            return cachedChildren
        }
        
        // Sinon, vérifier le cache persistant
        guard let data = userDefaults.data(forKey: CacheKeys.children),
              let children = try? JSONDecoder().decode([Child].self, from: data) else {
            return nil
        }
        
        // Remettre en cache mémoire
        cache.setObject(children as NSArray, forKey: CacheKeys.children as NSString)
        return children
    }
    
    // MARK: - User Profile Cache
    
    func cacheUserProfile(_ profile: UserProfile) {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Cache en mémoire
            self.cache.setObject(profile as AnyObject, forKey: CacheKeys.userProfile as NSString)
            
            // Cache persistant
            if let data = try? JSONEncoder().encode(profile) {
                self.userDefaults.set(data, forKey: CacheKeys.userProfile)
            }
        }
    }
    
    func getCachedUserProfile() -> UserProfile? {
        // Vérifier d'abord le cache mémoire
        if let cachedProfile = cache.object(forKey: CacheKeys.userProfile as NSString) as? UserProfile {
            return cachedProfile
        }
        
        // Sinon, vérifier le cache persistant
        guard let data = userDefaults.data(forKey: CacheKeys.userProfile),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return nil
        }
        
        // Remettre en cache mémoire
        cache.setObject(profile as AnyObject, forKey: CacheKeys.userProfile as NSString)
        return profile
    }
    
    // MARK: - Cache Management
    
    func clearMemoryCache() {
        cache.removeAllObjects()
    }
    
    func clearPersistentCache() {
        let keys = [CacheKeys.events, CacheKeys.children, CacheKeys.userProfile]
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
    
    func clearAllCache() {
        clearMemoryCache()
        clearPersistentCache()
        userDefaults.removeObject(forKey: CacheKeys.lastSyncDate)
    }
    
    // MARK: - Cache Validation
    
    func isCacheValid(maxAge: TimeInterval = 300) -> Bool { // 5 minutes par défaut
        guard let lastSync = userDefaults.object(forKey: CacheKeys.lastSyncDate) as? Date else {
            return false
        }
        
        return Date().timeIntervalSince(lastSync) < maxAge
    }
    
    private func updateLastSyncDate() {
        userDefaults.set(Date(), forKey: CacheKeys.lastSyncDate)
    }
    
    // MARK: - Cache Statistics
    
    var cacheStatistics: CacheStatistics {
        CacheStatistics(
            memoryObjectCount: cache.countLimit,
            memoryTotalCost: cache.totalCostLimit,
            hasEventsCache: getCachedEvents() != nil,
            hasChildrenCache: getCachedChildren() != nil,
            hasUserProfileCache: getCachedUserProfile() != nil,
            lastSyncDate: userDefaults.object(forKey: CacheKeys.lastSyncDate) as? Date
        )
    }
}

// MARK: - Cache Statistics

struct CacheStatistics {
    let memoryObjectCount: Int
    let memoryTotalCost: Int
    let hasEventsCache: Bool
    let hasChildrenCache: Bool
    let hasUserProfileCache: Bool
    let lastSyncDate: Date?
    
    var formattedLastSync: String {
        guard let lastSyncDate = lastSyncDate else {
            return "Jamais"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.localizedString(for: lastSyncDate, relativeTo: Date())
    }
}

// MARK: - Cache Manager (Legacy Support)

/// Alias pour la compatibilité avec l'ancien code
typealias CacheManager = CacheService