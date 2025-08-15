//
//  MainTabView.swift
//  Manounou
//
//  Created by Assistant on 2025-01-13.
//

import SwiftUI
import Foundation
import Supabase
import UserNotifications
import Network

// MARK: - Performance & Cache Management System

struct CacheConfiguration {
    let maxMemorySize: Int // en MB
    let defaultTTL: TimeInterval // Time To Live en secondes
    let maxItems: Int
    
    static let `default` = CacheConfiguration(
        maxMemorySize: 50, // 50MB
        defaultTTL: 300, // 5 minutes
        maxItems: 1000
    )
    
    static let aggressive = CacheConfiguration(
        maxMemorySize: 100, // 100MB
        defaultTTL: 600, // 10 minutes
        maxItems: 2000
    )
}

struct CacheEntry<T> {
    let data: T
    let timestamp: Date
    let ttl: TimeInterval
    let size: Int // taille estimée en bytes
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > ttl
    }
}

class CacheManager: ObservableObject {
    @Published var cacheHitRate: Double = 0.0
    @Published var currentMemoryUsage: Int = 0 // en bytes
    
    private var cache: [String: Any] = [:]
    private var cacheMetadata: [String: (timestamp: Date, ttl: TimeInterval, size: Int)] = [:]
    private let configuration: CacheConfiguration
    private let queue = DispatchQueue(label: "CacheManager", attributes: .concurrent)
    
    // Statistiques
    private var hitCount = 0
    private var missCount = 0
    
    init(configuration: CacheConfiguration = .default) {
        self.configuration = configuration
        startCleanupTimer()
    }
    
    func set<T>(_ key: String, value: T, ttl: TimeInterval? = nil) {
        queue.async(flags: .barrier) {
            let actualTTL = ttl ?? self.configuration.defaultTTL
            let estimatedSize = self.estimateSize(of: value)
            
            // Vérifier si on dépasse la limite mémoire
            if self.currentMemoryUsage + estimatedSize > self.configuration.maxMemorySize * 1024 * 1024 {
                self.evictLRU()
            }
            
            self.cache[key] = value
            self.cacheMetadata[key] = (Date(), actualTTL, estimatedSize)
            
            DispatchQueue.main.async {
                self.currentMemoryUsage += estimatedSize
            }
            
            print("📦 Cache SET: \(key) (\(estimatedSize) bytes, TTL: \(actualTTL)s)")
        }
    }
    
    func get<T>(_ key: String, type: T.Type) -> T? {
        return queue.sync {
            guard let metadata = cacheMetadata[key] else {
                missCount += 1
                updateHitRate()
                return nil
            }
            
            // Vérifier expiration
            if Date().timeIntervalSince(metadata.timestamp) > metadata.ttl {
                remove(key)
                missCount += 1
                updateHitRate()
                return nil
            }
            
            hitCount += 1
            updateHitRate()
            print("🎯 Cache HIT: \(key)")
            return cache[key] as? T
        }
    }
    
    func remove(_ key: String) {
        queue.async(flags: .barrier) {
            if let metadata = self.cacheMetadata[key] {
                let sizeToRemove = metadata.size
                self.cache.removeValue(forKey: key)
                self.cacheMetadata.removeValue(forKey: key)
                
                DispatchQueue.main.async {
                    self.currentMemoryUsage -= sizeToRemove
                }
                
                print("🗑️ Cache REMOVE: \(key)")
            }
        }
    }
    
    func clear() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
            self.cacheMetadata.removeAll()
            
            DispatchQueue.main.async {
                self.currentMemoryUsage = 0
            }
            print("🧹 Cache CLEARED")
        }
    }
    
    private func evictLRU() {
        // Supprimer les entrées les plus anciennes
        let sortedKeys = cacheMetadata.sorted { $0.value.timestamp < $1.value.timestamp }
        let keysToRemove = sortedKeys.prefix(max(1, sortedKeys.count / 4)).map { $0.key }
        
        for key in keysToRemove {
            remove(key)
        }
        
        print("♻️ Cache LRU eviction: \(keysToRemove.count) items removed")
    }
    
    private func estimateSize<T>(of value: T) -> Int {
        // Estimation basique de la taille
        if let data = value as? Data {
            return data.count
        } else if let string = value as? String {
            return string.utf8.count
        } else if let array = value as? [Any] {
            return array.count * 100 // estimation
        } else {
            return 64 // taille par défaut
        }
    }
    
    private func updateHitRate() {
        let total = hitCount + missCount
        if total > 0 {
            DispatchQueue.main.async {
                self.cacheHitRate = Double(self.hitCount) / Double(total)
            }
        }
    }
    
    private func startCleanupTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.cleanupExpiredEntries()
        }
    }
    
    private func cleanupExpiredEntries() {
        queue.async(flags: .barrier) {
            let now = Date()
            let expiredKeys = self.cacheMetadata.compactMap { key, metadata in
                now.timeIntervalSince(metadata.timestamp) > metadata.ttl ? key : nil
            }
            
            for key in expiredKeys {
                self.remove(key)
            }
            
            if !expiredKeys.isEmpty {
                print("🕐 Cache cleanup: \(expiredKeys.count) expired entries removed")
            }
        }
    }
}

class MemoryManager: ObservableObject {
    @Published var memoryUsage: Double = 0.0 // en MB
    @Published var memoryWarning = false
    
    private let warningThreshold: Double = 100.0 // 100MB
    private let criticalThreshold: Double = 200.0 // 200MB
    
    init() {
        startMemoryMonitoring()
        setupMemoryWarningNotification()
    }
    
    private func startMemoryMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.updateMemoryUsage()
        }
    }
    
    private func updateMemoryUsage() {
        let usage = getMemoryUsage()
        DispatchQueue.main.async {
            self.memoryUsage = usage
            self.memoryWarning = usage > self.warningThreshold
            
            if usage > self.criticalThreshold {
                self.handleCriticalMemory()
            }
        }
    }
    
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024.0 / 1024.0 // Convert to MB
        }
        return 0.0
    }
    
    private func setupMemoryWarningNotification() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.handleMemoryWarning()
            }
        }
    }
    
    private func handleMemoryWarning() {
        print("⚠️ Memory warning received - cleaning up")
        // Notifier les autres composants pour qu'ils libèrent de la mémoire
        NotificationCenter.default.post(name: .memoryCleanupRequired, object: nil)
    }
    
    private func handleCriticalMemory() {
        print("🚨 Critical memory usage: \(memoryUsage)MB")
        handleMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension Notification.Name {
    static let memoryCleanupRequired = Notification.Name("memoryCleanupRequired")
}

// MARK: - Error Management System

enum AppError: LocalizedError, Equatable {
    case networkUnavailable
    case authenticationRequired
    case authenticationFailed
    case serverError(String)
    case dataCorrupted
    case operationCancelled
    case rateLimitExceeded
    case insufficientPermissions
    case validationError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Aucune connexion internet. Vérifiez votre réseau."
        case .authenticationRequired:
            return "Vous devez vous connecter pour continuer."
        case .authenticationFailed:
            return "Échec de l'authentification. Reconnectez-vous."
        case .serverError(let message):
            return "Erreur serveur: \(message)"
        case .dataCorrupted:
            return "Données corrompues. Veuillez réessayer."
        case .operationCancelled:
            return "Opération annulée."
        case .rateLimitExceeded:
            return "Trop de requêtes. Attendez un moment."
        case .insufficientPermissions:
            return "Permissions insuffisantes."
        case .validationError(let message):
            return "Erreur de validation: \(message)"
        case .unknownError(let message):
            return "Erreur inconnue: \(message)"
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .serverError, .rateLimitExceeded:
            return true
        default:
            return false
        }
    }
    
    var severity: ErrorSeverity {
        switch self {
        case .networkUnavailable, .operationCancelled:
            return .low
        case .validationError, .rateLimitExceeded:
            return .medium
        case .authenticationFailed, .serverError, .dataCorrupted:
            return .high
        case .authenticationRequired, .insufficientPermissions, .unknownError:
            return .critical
        }
    }
}

enum ErrorSeverity {
    case low, medium, high, critical
}

struct RetryConfiguration {
    let maxAttempts: Int
    let baseDelay: TimeInterval
    let maxDelay: TimeInterval
    let backoffMultiplier: Double
    
    static let `default` = RetryConfiguration(
        maxAttempts: 3,
        baseDelay: 1.0,
        maxDelay: 10.0,
        backoffMultiplier: 2.0
    )
    
    static let aggressive = RetryConfiguration(
        maxAttempts: 5,
        baseDelay: 0.5,
        maxDelay: 5.0,
        backoffMultiplier: 1.5
    )
}

class NetworkMonitor: ObservableObject {
    @Published var isConnected = true
    @Published var connectionType: NWInterface.InterfaceType?
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}

class ErrorManager: ObservableObject {
    @Published var currentError: AppError?
    @Published var isShowingError = false
    @Published var errorHistory: [ErrorLogEntry] = []
    
    private let networkMonitor = NetworkMonitor()
    private let maxHistorySize = 50
    
    struct ErrorLogEntry: Identifiable {
        let id = UUID()
        let error: AppError
        let timestamp: Date
        let context: String?
        
        init(error: AppError, context: String? = nil) {
            self.error = error
            self.timestamp = Date()
            self.context = context
        }
    }
    
    func handleError(_ error: Error, context: String? = nil) {
        let appError = mapToAppError(error)
        logError(appError, context: context)
        
        // Afficher l'erreur seulement si elle est significative
        if appError.severity != .low {
            DispatchQueue.main.async {
                self.currentError = appError
                self.isShowingError = true
            }
        }
    }
    
    func clearError() {
        DispatchQueue.main.async {
            self.currentError = nil
            self.isShowingError = false
        }
    }
    
    private func mapToAppError(_ error: Error) -> AppError {
        // Vérifier d'abord la connectivité
        if !networkMonitor.isConnected {
            return .networkUnavailable
        }
        
        // Mapper les erreurs spécifiques
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkUnavailable
            case .cancelled:
                return .operationCancelled
            case .timedOut:
                return .serverError("Délai d'attente dépassé")
            default:
                return .serverError(urlError.localizedDescription)
            }
        }
        
        // Erreurs NSError avec codes spécifiques
        if let nsError = error as NSError? {
            switch nsError.domain {
            case "AuthError":
                if nsError.code == 401 {
                    return .authenticationRequired
                }
                return .authenticationFailed
            case "ValidationError":
                return .validationError(nsError.localizedDescription)
            default:
                break
            }
        }
        
        // Erreurs Supabase (si disponibles)
        let errorMessage = error.localizedDescription
        if errorMessage.contains("rate limit") {
            return .rateLimitExceeded
        }
        if errorMessage.contains("permission") || errorMessage.contains("unauthorized") {
            return .insufficientPermissions
        }
        if errorMessage.contains("server") || errorMessage.contains("internal") {
            return .serverError(errorMessage)
        }
        
        return .unknownError(errorMessage)
    }
    
    private func logError(_ error: AppError, context: String?) {
        let entry = ErrorLogEntry(error: error, context: context)
        errorHistory.insert(entry, at: 0)
        
        // Limiter la taille de l'historique
        if errorHistory.count > maxHistorySize {
            errorHistory.removeLast()
        }
        
        // Log pour debugging
        print("🚨 [ErrorManager] \(error.severity): \(error.localizedDescription)")
        if let context = context {
            print("📍 Context: \(context)")
        }
    }
    
    func retryOperation<T>(
        operation: @escaping () async throws -> T,
        configuration: RetryConfiguration = .default,
        context: String? = nil
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...configuration.maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                let appError = mapToAppError(error)
                
                // Ne pas retry si l'erreur n'est pas retryable
                if !appError.isRetryable {
                    throw error
                }
                
                // Ne pas attendre après le dernier essai
                if attempt < configuration.maxAttempts {
                    let delay = min(
                        configuration.baseDelay * pow(configuration.backoffMultiplier, Double(attempt - 1)),
                        configuration.maxDelay
                    )
                    
                    print("🔄 Retry attempt \(attempt)/\(configuration.maxAttempts) in \(delay)s")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        // Toutes les tentatives ont échoué
        if let lastError = lastError {
            handleError(lastError, context: context)
            throw lastError
        }
        
        throw AppError.unknownError("Retry operation failed")
    }
}

// MARK: - Child Model
struct Child: Identifiable, Codable {
    let id: UUID
    let parentId: UUID
    let firstName: String
    let lastName: String
    let dateOfBirth: Date
    let gender: String?
    let createdAt: Date
    let updatedAt: Date
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }
    
    var ageText: String {
        let age = self.age
        return age <= 1 ? "\(age) an" : "\(age) ans"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case parentId = "parent_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case dateOfBirth = "date_of_birth"
        case gender
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Décodeur personnalisé pour gérer les dates Supabase
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        parentId = try container.decode(UUID.self, forKey: .parentId)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        
        // Décodage personnalisé des dates
        dateOfBirth = try Self.decodeDate(from: container, forKey: .dateOfBirth)
        createdAt = try Self.decodeDate(from: container, forKey: .createdAt)
        updatedAt = try Self.decodeDate(from: container, forKey: .updatedAt)
    }
    
    private static func decodeDate(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Date {
        // Essayer d'abord le décodage standard
        if let date = try? container.decode(Date.self, forKey: key) {
            return date
        }
        
        // Si ça échoue, essayer avec une chaîne
        let dateString = try container.decode(String.self, forKey: key)
        
        let formatters = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS+00:00",
            "yyyy-MM-dd'T'HH:mm:ss+00:00",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd"
        ]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        for format in formatters {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Cannot decode date string \(dateString)")
    }
}

struct CreateChildRequest: Codable {
    let parentId: UUID
    let firstName: String
    let lastName: String
    let dateOfBirth: Date
    let gender: String?
    
    enum CodingKeys: String, CodingKey {
        case parentId = "parent_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case dateOfBirth = "date_of_birth"
        case gender
    }
}

enum Gender: String, CaseIterable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .male: return "Garçon"
        case .female: return "Fille"
        case .other: return "Autre"
        }
    }
}

// MARK: - Childcare Model
struct ChildcareInfo: Codable {
    let nannyName: String?
    let nannyPhone: String?
    let dropOffTime: Date?
    let pickUpTime: Date?
    let weeklyDays: [Int]? // 1-7 pour lundi-dimanche
    let isRecurring: Bool
    
    init(nannyName: String? = nil, nannyPhone: String? = nil, dropOffTime: Date? = nil, pickUpTime: Date? = nil, weeklyDays: [Int]? = nil, isRecurring: Bool = false) {
        self.nannyName = nannyName
        self.nannyPhone = nannyPhone
        self.dropOffTime = dropOffTime
        self.pickUpTime = pickUpTime
        self.weeklyDays = weeklyDays
        self.isRecurring = isRecurring
    }
}

// MARK: - Event Model
struct Event: Identifiable, Codable {
    let id: UUID
    let parentId: UUID
    let title: String
    let description: String?
    let eventType: EventType
    let startDate: Date
    let endDate: Date?
    let childId: UUID?
    let childcareInfo: ChildcareInfo?
    let createdAt: Date
    let updatedAt: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(startDate)
    }
    
    var isUpcoming: Bool {
        startDate > Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case parentId = "parent_id"
        case title
        case description
        case eventType = "event_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case childId = "child_id"
        case childcareInfo = "childcare_info"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Décodeur personnalisé pour gérer les dates Supabase
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        parentId = try container.decode(UUID.self, forKey: .parentId)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        eventType = try container.decode(EventType.self, forKey: .eventType)
        childId = try container.decodeIfPresent(UUID.self, forKey: .childId)
        
        // Décodage personnalisé des dates
        startDate = try Self.decodeDate(from: container, forKey: .startDate)
        endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
        createdAt = try Self.decodeDate(from: container, forKey: .createdAt)
        updatedAt = try Self.decodeDate(from: container, forKey: .updatedAt)
        
        // Décodage des informations de garde d'enfant
        childcareInfo = try container.decodeIfPresent(ChildcareInfo.self, forKey: .childcareInfo)
    }
    
    private static func decodeDate(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Date {
        // Essayer d'abord le décodage standard
        if let date = try? container.decode(Date.self, forKey: key) {
            return date
        }
        
        // Si ça échoue, essayer avec une chaîne
        let dateString = try container.decode(String.self, forKey: key)
        
        let formatters = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS+00:00",
            "yyyy-MM-dd'T'HH:mm:ss+00:00",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd"
        ]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        for format in formatters {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Cannot decode date string \(dateString)")
    }
}

struct CreateEventRequest: Codable {
    let parentId: UUID
    let title: String
    let description: String?
    let eventType: EventType
    let startDate: Date
    let endDate: Date?
    let childId: UUID?
    
    enum CodingKeys: String, CodingKey {
        case parentId = "parent_id"
        case title
        case description
        case eventType = "event_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case childId = "child_id"
    }
}

enum EventType: String, CaseIterable, Codable {
    case medical = "medical"
    case school = "school"
    case activity = "activity"
    case family = "family"
    case childcare = "childcare"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .medical: return "Médical"
        case .school: return "École"
        case .activity: return "Activité"
        case .family: return "Famille"
        case .childcare: return "Garde d'enfant"
        case .other: return "Autre"
        }
    }
    
    var icon: String {
        switch self {
        case .medical: return "cross.fill"
        case .school: return "book.fill"
        case .activity: return "figure.run"
        case .family: return "house.fill"
        case .childcare: return "person.2.fill"
        case .other: return "calendar"
        }
    }
    
    var color: Color {
        switch self {
        case .medical: return .red
        case .school: return .blue
        case .activity: return .green
        case .family: return .purple
        case .childcare: return .orange
        case .other: return .gray
        }
    }
}

// MARK: - Document Model

struct Document: Identifiable, Codable {
    let id: UUID
    let parentId: UUID
    let title: String
    let description: String?
    let documentType: DocumentType
    let fileName: String?
    let fileUrl: String?
    let childId: UUID?
    let createdAt: Date
    let updatedAt: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case parentId = "parent_id"
        case title
        case description
        case documentType = "document_type"
        case fileName = "file_name"
        case fileUrl = "file_url"
        case childId = "child_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        parentId = try container.decode(UUID.self, forKey: .parentId)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        documentType = try container.decode(DocumentType.self, forKey: .documentType)
        fileName = try container.decodeIfPresent(String.self, forKey: .fileName)
        fileUrl = try container.decodeIfPresent(String.self, forKey: .fileUrl)
        childId = try container.decodeIfPresent(UUID.self, forKey: .childId)
        createdAt = try Self.decodeDate(from: container, forKey: .createdAt)
        updatedAt = try Self.decodeDate(from: container, forKey: .updatedAt)
    }
    
    private static func decodeDate(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Date {
        if let dateString = try? container.decode(String.self, forKey: key) {
            let formatter = ISO8601DateFormatter()
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS+00:00"
            if let date = formatter2.date(from: dateString) {
                return date
            }
            
            formatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+00:00"
            if let date = formatter2.date(from: dateString) {
                return date
            }
        }
        
        throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Date string does not match expected format")
    }
}

struct CreateDocumentRequest: Codable {
    let parentId: UUID
    let title: String
    let description: String?
    let documentType: DocumentType
    let fileName: String?
    let childId: UUID?
    
    enum CodingKeys: String, CodingKey {
        case parentId = "parent_id"
        case title
        case description
        case documentType = "document_type"
        case fileName = "file_name"
        case childId = "child_id"
    }
}

enum DocumentType: String, CaseIterable, Codable {
    case medical = "medical"
    case school = "school"
    case identity = "identity"
    case insurance = "insurance"
    case vaccination = "vaccination"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .medical: return "Médical"
        case .school: return "Scolaire"
        case .identity: return "Identité"
        case .insurance: return "Assurance"
        case .vaccination: return "Vaccination"
        case .other: return "Autre"
        }
    }
    
    var icon: String {
        switch self {
        case .medical: return "cross.fill"
        case .school: return "book.fill"
        case .identity: return "person.text.rectangle.fill"
        case .insurance: return "shield.fill"
        case .vaccination: return "syringe.fill"
        case .other: return "doc.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .medical: return .red
        case .school: return .blue
        case .identity: return .purple
        case .insurance: return .green
        case .vaccination: return .orange
        case .other: return .gray
        }
    }
}

// MARK: - Children Service
class ChildrenService {
    private let supabase: SupabaseClient
    private let errorManager: ErrorManager
    private let cacheManager: CacheManager?
    
    init(errorManager: ErrorManager? = nil, cacheManager: CacheManager? = nil) {
        self.supabase = SupabaseClient(
            supabaseURL: AppConfig.Supabase.apiURL,
            supabaseKey: AppConfig.Supabase.anonKey
        )
        if let errorManager = errorManager {
            self.errorManager = errorManager
        } else {
            self.errorManager = ErrorManager()
        }
        self.cacheManager = cacheManager
    }
    
    func fetchChildren() async throws -> [Child] {
        return try await errorManager.retryOperation(
            operation: { [self] in
                print("📥 Récupération des enfants...")
                
                let response: [Child] = try await self.supabase
                    .from("children")
                    .select()
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                
                print("✅ \(response.count) enfant(s) récupéré(s)")
                return response
            },
            configuration: .default,
            context: "ChildrenService.fetchChildren"
        )
    }
    
    func createChild(firstName: String, lastName: String, dateOfBirth: Date, gender: String?) async throws -> Child {
        print("📝 Création d'un enfant: \(firstName) \(lastName)")
        
        let userId = try await supabase.auth.session.user.id
        
        let createRequest = CreateChildRequest(
            parentId: userId,
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            gender: gender
        )
        
        let response: [Child] = try await supabase
            .from("children")
            .insert(createRequest)
            .select()
            .execute()
            .value
        
        guard let child = response.first else {
            throw NSError(domain: "ChildrenService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Impossible de créer l'enfant"])
        }
        
        print("✅ Enfant créé avec succès: \(child.fullName)")
        return child
    }
    
    func updateChild(_ child: Child, firstName: String, lastName: String, dateOfBirth: Date, gender: String?) async throws -> Child {
        print("📝 Mise à jour de l'enfant: \(child.fullName)")
        
        let updateRequest = CreateChildRequest(
            parentId: child.parentId,
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            gender: gender
        )
        
        let response: [Child] = try await supabase
            .from("children")
            .update(updateRequest)
            .eq("id", value: child.id)
            .select()
            .execute()
            .value
        
        guard let updatedChild = response.first else {
            throw NSError(domain: "ChildrenService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Impossible de mettre à jour l'enfant"])
        }
        
        print("✅ Enfant mis à jour avec succès: \(updatedChild.fullName)")
        return updatedChild
    }
    
    func deleteChild(_ child: Child) async throws {
        print("🗑️ Suppression de l'enfant: \(child.fullName)")
        
        try await supabase
            .from("children")
            .delete()
            .eq("id", value: child.id.uuidString)
            .execute()
        
        print("✅ Enfant supprimé avec succès")
    }
}

// MARK: - Events Service
class EventsService {
    private let supabase: SupabaseClient
    private let errorManager: ErrorManager
    private let cacheManager: CacheManager?
    
    init(errorManager: ErrorManager? = nil, cacheManager: CacheManager? = nil) {
        self.supabase = SupabaseClient(
            supabaseURL: AppConfig.Supabase.apiURL,
            supabaseKey: AppConfig.Supabase.anonKey
        )
        if let errorManager = errorManager {
            self.errorManager = errorManager
        } else {
            self.errorManager = ErrorManager()
        }
        self.cacheManager = cacheManager
    }
    
    func fetchEvents() async throws -> [Event] {
        print("📅 Récupération des événements depuis Supabase")
        
        // Vérifier la session d'authentification
        do {
            let session = try await supabase.auth.session
            if session.accessToken.isEmpty {
                throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non authentifié"])
            }
            print("🔐 Session valide, récupération des événements...")
        } catch {
            print("❌ Erreur de session: \(error)")
            throw error
        }
        
        let response: [Event] = try await supabase
            .from("events")
            .select()
            .order("start_date", ascending: true)
            .execute()
            .value
        
        print("✅ \(response.count) événement(s) récupéré(s)")
        return response
    }
    
    func createEvent(title: String, description: String?, eventType: EventType, startDate: Date, endDate: Date?, childId: UUID?) async throws -> Event {
        print("📅 Création d'un nouvel événement: \(title)")
        
        guard let currentUser = try? await supabase.auth.user() else {
            throw NSError(domain: "EventsService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non connecté"])
        }
        
        let createRequest = CreateEventRequest(
            parentId: currentUser.id,
            title: title,
            description: description,
            eventType: eventType,
            startDate: startDate,
            endDate: endDate,
            childId: childId
        )
        
        let response: [Event] = try await supabase
            .from("events")
            .insert(createRequest)
            .select()
            .execute()
            .value
        
        guard let newEvent = response.first else {
            throw NSError(domain: "EventsService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Impossible de créer l'événement"])
        }
        
        print("✅ Événement créé avec succès: \(newEvent.title)")
        return newEvent
    }
    
    func updateEvent(_ event: Event, title: String, description: String?, eventType: EventType, startDate: Date, endDate: Date?, childId: UUID?) async throws -> Event {
        print("📝 Mise à jour de l'événement: \(event.title)")
        
        let updateRequest = CreateEventRequest(
            parentId: event.parentId,
            title: title,
            description: description,
            eventType: eventType,
            startDate: startDate,
            endDate: endDate,
            childId: childId
        )
        
        let response: [Event] = try await supabase
            .from("events")
            .update(updateRequest)
            .eq("id", value: event.id)
            .select()
            .execute()
            .value
        
        guard let updatedEvent = response.first else {
            throw NSError(domain: "EventsService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Impossible de mettre à jour l'événement"])
        }
        
        print("✅ Événement mis à jour avec succès: \(updatedEvent.title)")
        return updatedEvent
    }
    
    func deleteEvent(_ event: Event) async throws {
        print("🗑️ Suppression de l'événement: \(event.title)")
        
        try await supabase
            .from("events")
            .delete()
            .eq("id", value: event.id)
            .execute()
        
        print("✅ Événement supprimé avec succès")
    }
}

// MARK: - Documents Service

class DocumentsService {
    private let supabase: SupabaseClient
    private let errorManager: ErrorManager
    private let cacheManager: CacheManager?
    
    init(errorManager: ErrorManager? = nil, cacheManager: CacheManager? = nil) {
        self.supabase = SupabaseClient(
            supabaseURL: AppConfig.Supabase.apiURL,
            supabaseKey: AppConfig.Supabase.anonKey
        )
        if let errorManager = errorManager {
            self.errorManager = errorManager
        } else {
            self.errorManager = ErrorManager()
        }
        self.cacheManager = cacheManager
    }
    
    func fetchDocuments() async throws -> [Document] {
        print("📄 Chargement des documents...")
        
        // Retourner une liste vide temporairement jusqu'à ce que la table soit créée
        print("⚠️ Table documents pas encore créée - retour liste vide")
        return []
    }
    
    func createDocument(title: String, description: String?, documentType: DocumentType, fileName: String?, childId: UUID?) async throws -> Document {
        print("📄 Création du document: \(title)")
        
        // Temporaire : simuler la création d'un document
        print("⚠️ Table documents pas encore créée - simulation")
        throw NSError(domain: "DocumentsService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Table documents pas encore créée. Veuillez créer la table dans Supabase."])
    }
    
    func updateDocument(_ document: Document, title: String, description: String?, documentType: DocumentType, fileName: String?, childId: UUID?) async throws -> Document {
        print("📄 Mise à jour du document: \(document.title)")
        
        let updateData: [String: AnyJSON] = [
            "title": AnyJSON.string(title),
            "description": description.map(AnyJSON.string) ?? AnyJSON.null,
            "document_type": AnyJSON.string(documentType.rawValue),
            "file_name": fileName.map(AnyJSON.string) ?? AnyJSON.null,
            "child_id": childId.map { AnyJSON.string($0.uuidString) } ?? AnyJSON.null
        ]
        
        let response: [Document] = try await supabase
            .from("documents")
            .update(updateData)
            .eq("id", value: document.id)
            .select()
            .execute()
            .value
        
        guard let updatedDocument = response.first else {
            throw NSError(domain: "DocumentsService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Erreur lors de la mise à jour du document"])
        }
        
        print("✅ Document mis à jour avec succès: \(updatedDocument.title)")
        return updatedDocument
    }
    
    func deleteDocument(_ document: Document) async throws {
        print("🗑️ Suppression du document: \(document.title)")
        
        try await supabase
            .from("documents")
            .delete()
            .eq("id", value: document.id)
            .execute()
        
        print("✅ Document supprimé avec succès")
    }
}

// MARK: - Children ViewModel
@MainActor
class ChildrenViewModel: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddChild = false
    @Published var showingEditChild = false
    @Published var childToEdit: Child?
    
    private let service: ChildrenService
    private let errorManager: ErrorManager
    private let cacheManager: CacheManager
    
    init(errorManager: ErrorManager? = nil, cacheManager: CacheManager? = nil) {
        let errorMgr = errorManager ?? ErrorManager()
        let cacheMgr = cacheManager ?? CacheManager()
        self.errorManager = errorMgr
        self.cacheManager = cacheMgr
        self.service = ChildrenService(errorManager: errorMgr, cacheManager: cacheMgr)
        
        // Observer les notifications de nettoyage mémoire
        NotificationCenter.default.addObserver(
            forName: .memoryCleanupRequired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.handleMemoryCleanup()
            }
        }
    }
    
    func loadChildren() async {
        // Vérifier d'abord le cache
        let cacheKey = "children_list"
        if let cachedChildren = cacheManager.get(cacheKey, type: [Child].self) {
            children = cachedChildren
            print("📦 Children loaded from cache")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            children = try await service.fetchChildren()
            // Mettre en cache pour 5 minutes
            cacheManager.set(cacheKey, value: children, ttl: 300)
        } catch {
            errorManager.handleError(error, context: "ChildrenViewModel.loadChildren")
            errorMessage = "Erreur lors du chargement: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func handleMemoryCleanup() {
        // Libérer les ressources non essentielles
        if !isLoading {
            // Garder seulement les données essentielles
            print("🧹 ChildrenViewModel: Memory cleanup performed")
        }
    }
    
    private func invalidateCache() {
        cacheManager.remove("children_list")
    }
    
    func addChild(firstName: String, lastName: String, dateOfBirth: Date, gender: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await service.createChild(
                firstName: firstName,
                lastName: lastName,
                dateOfBirth: dateOfBirth,
                gender: gender
            )
            
            // Invalider le cache et recharger
            invalidateCache()
            await loadChildren()
            showingAddChild = false
        } catch {
            errorMessage = "Erreur lors de l'ajout: \(error.localizedDescription)"
            print("❌ Erreur addChild: \(error)")
            isLoading = false
        }
    }
    
    func updateChild(_ child: Child, firstName: String, lastName: String, dateOfBirth: Date, gender: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await service.updateChild(
                child,
                firstName: firstName,
                lastName: lastName,
                dateOfBirth: dateOfBirth,
                gender: gender
            )
            
            // Invalider le cache et recharger
            invalidateCache()
            await loadChildren()
            showingEditChild = false
            childToEdit = nil
        } catch {
            errorMessage = "Erreur lors de la modification: \(error.localizedDescription)"
            print("❌ Erreur updateChild: \(error)")
            isLoading = false
        }
    }
    
    func deleteChild(_ child: Child) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.deleteChild(child)
            invalidateCache()
            children.removeAll { $0.id == child.id }
        } catch {
            errorMessage = "Erreur lors de la suppression: \(error.localizedDescription)"
            print("❌ Erreur deleteChild: \(error)")
        }
        
        isLoading = false
    }
    
    func showAddChild() {
        showingAddChild = true
    }
    
    func showEditChild(_ child: Child) {
        childToEdit = child
        showingEditChild = true
    }
    
    func dismissError() {
        errorMessage = nil
    }
}

// MARK: - Events ViewModel
@MainActor
class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var filteredEvents: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddEvent = false
    @Published var showingEditEvent = false
    @Published var eventToEdit: Event?
    @Published var searchText = ""
    @Published var selectedEventType: EventType?
    @Published var selectedChildId: UUID?
    
    private let service: EventsService
    private let errorManager: ErrorManager
    private let cacheManager: CacheManager
    
    init(errorManager: ErrorManager? = nil, cacheManager: CacheManager? = nil) {
        let errorMgr = errorManager ?? ErrorManager()
        let cacheMgr = cacheManager ?? CacheManager()
        self.errorManager = errorMgr
        self.cacheManager = cacheMgr
        self.service = EventsService(errorManager: errorMgr, cacheManager: cacheMgr)
        
        // Observer les notifications de nettoyage mémoire
        NotificationCenter.default.addObserver(
            forName: .memoryCleanupRequired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
             DispatchQueue.main.async {
                 self?.handleMemoryCleanup()
             }
         }
    }
    
    // Propriétés calculées pour les événements filtrés
    var upcomingEvents: [Event] {
        let filtered = filteredEvents.isEmpty ? events : filteredEvents
        return filtered.filter { $0.isUpcoming }.prefix(3).map { $0 }
    }
    
    var todayEvents: [Event] {
        let filtered = filteredEvents.isEmpty ? events : filteredEvents
        return filtered.filter { $0.isToday }
    }
    
    func loadEvents() async {
        // Vérifier d'abord le cache
        let cacheKey = "events_list"
        if let cachedEvents = cacheManager.get(cacheKey, type: [Event].self) {
            events = cachedEvents
            applyFilters()
            print("📦 Events loaded from cache")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            events = try await service.fetchEvents()
            // Mettre en cache pour 3 minutes (les événements changent plus souvent)
            cacheManager.set(cacheKey, value: events, ttl: 180)
            print("✅ \(events.count) événement(s) chargé(s)")
            applyFilters() // Appliquer les filtres après le chargement
            isLoading = false
        } catch {
            // Gestion spécifique de l'erreur "cancelled"
            if let nsError = error as NSError?, nsError.code == -999 {
                errorMessage = "Connexion annulée. Vérifiez votre authentification."
                print("❌ Erreur loadEvents (cancelled): Problème d'authentification ou de connexion")
            } else {
                errorMessage = "Erreur lors du chargement: \(error.localizedDescription)"
                print("❌ Erreur loadEvents: \(error)")
            }
            isLoading = false
        }
    }
    
    private func handleMemoryCleanup() {
        // Libérer les ressources non essentielles
        if !isLoading {
            // Garder seulement les événements récents
            let recentEvents = events.filter { event in
                abs(event.startDate.timeIntervalSinceNow) < 86400 * 7 // 7 jours
            }
            if recentEvents.count < events.count {
                events = recentEvents
                applyFilters()
                print("🧹 EventsViewModel: Cleaned up old events")
            }
        }
    }
    
    private func invalidateCache() {
        cacheManager.remove("events_list")
    }
    
    // MARK: - Recherche et Filtres
    func applyFilters() {
        var filtered = events
        
        // Filtre par texte de recherche
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            filtered = filtered.filter { event in
                event.title.localizedCaseInsensitiveContains(searchText) ||
                (event.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Filtre par type d'événement
        if let eventType = selectedEventType {
            filtered = filtered.filter { $0.eventType == eventType }
        }
        
        // Filtre par enfant
        if let childId = selectedChildId {
            filtered = filtered.filter { $0.childId == childId }
        }
        
        filteredEvents = filtered
        print("🔍 Filtres appliqués: \(filteredEvents.count)/\(events.count) événements")
    }
    
    func clearFilters() {
        searchText = ""
        selectedEventType = nil
        selectedChildId = nil
        filteredEvents = []
        print("🧹 Filtres effacés")
    }
    
    func updateSearchText(_ text: String) {
        searchText = text
        applyFilters()
    }
    
    func selectEventType(_ eventType: EventType?) {
        selectedEventType = eventType
        applyFilters()
    }
    
    func selectChild(_ childId: UUID?) {
        selectedChildId = childId
        applyFilters()
    }
    
    func addEvent(title: String, description: String?, eventType: EventType, startDate: Date, endDate: Date?, childId: UUID?, notificationManager: NotificationManager? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newEvent = try await service.createEvent(
                title: title,
                description: description,
                eventType: eventType,
                startDate: startDate,
                endDate: endDate,
                childId: childId
            )
            
            // Programmer les notifications intelligentes pour le nouvel événement
            if let notificationManager = notificationManager {
                await notificationManager.scheduleSmartReminders(for: [newEvent])
            }
            
            // Recharger la liste complète depuis Supabase pour assurer la synchronisation
            await loadEvents()
            showingAddEvent = false
        } catch {
            errorMessage = "Erreur lors de l'ajout: \(error.localizedDescription)"
            print("❌ Erreur addEvent: \(error)")
            isLoading = false
        }
    }
    
    func updateEvent(_ event: Event, title: String, description: String?, eventType: EventType, startDate: Date, endDate: Date?, childId: UUID?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await service.updateEvent(
                event,
                title: title,
                description: description,
                eventType: eventType,
                startDate: startDate,
                endDate: endDate,
                childId: childId
            )
            
            // Recharger la liste complète depuis Supabase pour assurer la synchronisation
            await loadEvents()
            showingEditEvent = false
            eventToEdit = nil
        } catch {
            errorMessage = "Erreur lors de la modification: \(error.localizedDescription)"
            print("❌ Erreur updateEvent: \(error)")
            isLoading = false
        }
    }
    
    func deleteEvent(_ event: Event) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.deleteEvent(event)
            // Recharger la liste complète depuis Supabase pour assurer la synchronisation
            await loadEvents()
        } catch {
            errorMessage = "Erreur lors de la suppression: \(error.localizedDescription)"
            print("❌ Erreur deleteEvent: \(error)")
            isLoading = false
        }
    }
    
    func showAddEvent() {
        showingAddEvent = true
    }
    
    func showEditEvent(_ event: Event) {
        eventToEdit = event
        showingEditEvent = true
    }
    
    func editEvent(_ event: Event) {
        eventToEdit = event
        showingEditEvent = true
    }
    
    func dismissError() {
        errorMessage = nil
    }
}

// MARK: - Documents ViewModel

@MainActor
class DocumentsViewModel: ObservableObject {
    @Published var documents: [Document] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddDocument = false
    @Published var showingEditDocument = false
    @Published var documentToEdit: Document?
    
    private let service: DocumentsService
    private let errorManager: ErrorManager
    private let cacheManager: CacheManager
    
    init(errorManager: ErrorManager? = nil, cacheManager: CacheManager? = nil) {
        let errorMgr = errorManager ?? ErrorManager()
        let cacheMgr = cacheManager ?? CacheManager()
        self.errorManager = errorMgr
        self.cacheManager = cacheMgr
        self.service = DocumentsService(errorManager: errorMgr, cacheManager: cacheMgr)
        
        // Observer les notifications de nettoyage mémoire
        NotificationCenter.default.addObserver(
            forName: .memoryCleanupRequired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
             DispatchQueue.main.async {
                 self?.handleMemoryCleanup()
             }
         }
    }
    
    func loadDocuments() async {
        // Vérifier d'abord le cache
        let cacheKey = "documents_list"
        if let cachedDocuments = cacheManager.get(cacheKey, type: [Document].self) {
            documents = cachedDocuments
            print("📦 Documents loaded from cache")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            documents = try await service.fetchDocuments()
            // Mettre en cache pour 10 minutes (les documents changent moins souvent)
            cacheManager.set(cacheKey, value: documents, ttl: 600)
            isLoading = false
        } catch {
            errorMessage = "Erreur lors du chargement: \(error.localizedDescription)"
            print("❌ Erreur loadDocuments: \(error)")
            isLoading = false
        }
    }
    
    private func handleMemoryCleanup() {
        // Libérer les ressources non essentielles
        if !isLoading {
            print("🧹 DocumentsViewModel: Memory cleanup performed")
        }
    }
    
    private func invalidateCache() {
        cacheManager.remove("documents_list")
    }
    
    func addDocument(title: String, description: String?, documentType: DocumentType, fileName: String?, childId: UUID?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await service.createDocument(
                title: title,
                description: description,
                documentType: documentType,
                fileName: fileName,
                childId: childId
            )
            
            // Recharger la liste complète depuis Supabase pour assurer la synchronisation
            await loadDocuments()
            showingAddDocument = false
        } catch {
            errorMessage = "Erreur lors de l'ajout: \(error.localizedDescription)"
            print("❌ Erreur addDocument: \(error)")
            isLoading = false
        }
    }
    
    func updateDocument(_ document: Document, title: String, description: String?, documentType: DocumentType, fileName: String?, childId: UUID?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await service.updateDocument(
                document,
                title: title,
                description: description,
                documentType: documentType,
                fileName: fileName,
                childId: childId
            )
            
            // Recharger la liste complète depuis Supabase pour assurer la synchronisation
            await loadDocuments()
            showingEditDocument = false
            documentToEdit = nil
        } catch {
            errorMessage = "Erreur lors de la mise à jour: \(error.localizedDescription)"
            print("❌ Erreur updateDocument: \(error)")
            isLoading = false
        }
    }
    
    func deleteDocument(_ document: Document) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.deleteDocument(document)
            // Recharger la liste complète depuis Supabase pour assurer la synchronisation
            await loadDocuments()
        } catch {
            errorMessage = "Erreur lors de la suppression: \(error.localizedDescription)"
            print("❌ Erreur deleteDocument: \(error)")
            isLoading = false
        }
    }
    
    func showAddDocument() {
        showingAddDocument = true
    }
    
    func showEditDocument(_ document: Document) {
        documentToEdit = document
        showingEditDocument = true
    }
    
    func dismissError() {
        errorMessage = nil
    }
    
    var medicalDocuments: [Document] {
        documents.filter { $0.documentType == .medical }
    }
    
    var schoolDocuments: [Document] {
        documents.filter { $0.documentType == .school }
    }
    
    var identityDocuments: [Document] {
        documents.filter { $0.documentType == .identity }
    }
}

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    @State private var showingErrorAlert = false
    @StateObject private var errorManager = ErrorManager()
    @StateObject private var cacheManager = CacheManager()
    @StateObject private var memoryManager = MemoryManager()
    @StateObject private var childrenViewModel: ChildrenViewModel
    @StateObject private var eventsViewModel: EventsViewModel
    @StateObject private var documentsViewModel: DocumentsViewModel
    @StateObject private var notificationManager = NotificationManager()
    
    init() {
        // Créer des instances partagées des managers sur le main actor
        let sharedErrorManager = ErrorManager()
        let sharedCacheManager = CacheManager()
        let sharedMemoryManager = MemoryManager()
        
        self._errorManager = StateObject(wrappedValue: sharedErrorManager)
        self._cacheManager = StateObject(wrappedValue: sharedCacheManager)
        self._memoryManager = StateObject(wrappedValue: sharedMemoryManager)
        self._childrenViewModel = StateObject(wrappedValue: ChildrenViewModel(
            errorManager: sharedErrorManager,
            cacheManager: sharedCacheManager
        ))
        self._eventsViewModel = StateObject(wrappedValue: EventsViewModel(
            errorManager: sharedErrorManager,
            cacheManager: sharedCacheManager
        ))
        self._documentsViewModel = StateObject(wrappedValue: DocumentsViewModel(
            errorManager: sharedErrorManager,
            cacheManager: sharedCacheManager
        ))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .environmentObject(childrenViewModel)
                .environmentObject(eventsViewModel)
                .environmentObject(notificationManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }
                .tag(0)
            
            // Children Tab
            ChildrenView()
                .environmentObject(childrenViewModel)
                .tabItem {
                    Image(systemName: "figure.2.and.child.holdinghands")
                    Text("Enfants")
                }
                .tag(1)
            
            // Calendar Tab
            CalendarView()
                .environmentObject(eventsViewModel)
                .environmentObject(childrenViewModel)
                .environmentObject(notificationManager)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendrier")
                }
                .tag(2)
            
            // Documents Tab
            DocumentsView()
                .environmentObject(documentsViewModel)
                .environmentObject(childrenViewModel)
                .tabItem {
                    Image(systemName: "doc.fill")
                    Text("Documents")
                }
                .tag(3)
            
            // Paramètres
            SettingsView()
                            .environmentObject(notificationManager)
                            .environmentObject(cacheManager)
                            .environmentObject(memoryManager)
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Paramètres")
                }
                .tag(4)
        }
        .accentColor(.pink)
        .environmentObject(errorManager)
        .onReceive(errorManager.$isShowingError) { isShowing in
            showingErrorAlert = isShowing
        }
        .alert("Erreur", isPresented: $showingErrorAlert) {
            if let error = errorManager.currentError, error.isRetryable {
                Button("Réessayer") {
                    // Le retry sera géré par les ViewModels
                    errorManager.clearError()
                }
                Button("Annuler", role: .cancel) {
                    errorManager.clearError()
                }
            } else {
                Button("OK") {
                    errorManager.clearError()
                }
            }
        } message: {
            if let error = errorManager.currentError {
                Text(error.localizedDescription)
            }
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showingAddDocument = false
    @State private var showingInviteFamily = false
    @State private var isRefreshing = false
    @State private var showingToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        NavigationView {
            if authManager.isLoading {
                ProgressView("Chargement...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !authManager.isAuthenticated {
                AuthenticationView()
                    .environmentObject(authManager)
            } else {
                ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Bonjour \(authManager.userProfile?.firstName ?? "Utilisateur") !")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Bienvenue dans votre carnet de famille")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "bell")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Quick Actions
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        QuickActionCard(
                            title: "Ajouter un enfant",
                            icon: "plus.circle.fill",
                            color: .blue
                        ) {
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            childrenViewModel.showAddChild()
                        }
                        
                        QuickActionCard(
                            title: "Nouveau document",
                            icon: "doc.badge.plus",
                            color: .green
                        ) {
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            showingAddDocument = true
                        }
                        
                        QuickActionCard(
                            title: "Ajouter un événement",
                            icon: "calendar.badge.plus",
                            color: .orange
                        ) {
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            eventsViewModel.showAddEvent()
                        }
                        
                        QuickActionCard(
                            title: "Inviter la famille",
                            icon: "person.2.fill",
                            color: .purple
                        ) {
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            showingInviteFamily = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // Family Overview
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Votre famille")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            // Children Count Card
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "figure.2.and.child.holdinghands")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                    
                                    Spacer()
                                }
                                
                                Text("\(childrenViewModel.children.count)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text(childrenViewModel.children.count <= 1 ? "enfant" : "enfants")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Events Count Card
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.title2)
                                        .foregroundColor(.orange)
                                    
                                    Spacer()
                                }
                                
                                Text("\(eventsViewModel.upcomingEvents.count)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("à venir")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Upcoming Events
                    if !eventsViewModel.upcomingEvents.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Prochains événements")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button("Voir tout") {
                                    // Switch to calendar tab
                                }
                                .font(.footnote)
                                .foregroundColor(.pink)
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(eventsViewModel.upcomingEvents) { event in
                                    UpcomingEventRow(event: event)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .refreshable {
                await refreshData()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            }
        }
        .sheet(isPresented: $childrenViewModel.showingAddChild) {
            AddChildView { firstName, lastName, dateOfBirth, gender in
                Task {
                    await childrenViewModel.addChild(
                        firstName: firstName,
                        lastName: lastName,
                        dateOfBirth: dateOfBirth,
                        gender: gender
                    )
                }
            }
        }
        .sheet(isPresented: $showingAddDocument) {
            AddDocumentView()
        }
        .sheet(isPresented: $eventsViewModel.showingAddEvent) {
            AddEventView { title, description, eventType, startDate, endDate, childId in
                Task {
                    await eventsViewModel.addEvent(
                        title: title,
                        description: description,
                        eventType: eventType,
                        startDate: startDate,
                        endDate: endDate,
                        childId: childId,
                        notificationManager: notificationManager
                    )
                }
            }
        }
        .sheet(isPresented: $showingInviteFamily) {
            InviteFamilyView()
        }
        .task {
            // Load data only if user is authenticated
            if authManager.isAuthenticated {
                await childrenViewModel.loadChildren()
                await eventsViewModel.loadEvents()
            }
        }
        .overlay(
            // Toast message
            VStack {
                Spacer()
                if showingToast {
                    Text(toastMessage)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showingToast = false
                                }
                            }
                        }
                }
            }
            .padding(.bottom, 100)
        )
    }
    
    // MARK: - Functions
    private func refreshData() async {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Refresh data only if user is authenticated
        if authManager.isAuthenticated {
            await childrenViewModel.loadChildren()
            await eventsViewModel.loadEvents()
            showToast("Données mises à jour")
        } else {
            showToast("Veuillez vous connecter")
        }
    }
    
    private func showToast(_ message: String) {
        toastMessage = message
        withAnimation(.easeInOut(duration: 0.3)) {
            showingToast = true
        }
    }
}

// MARK: - Upcoming Event Row
struct UpcomingEventRow: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 12) {
            // Event Type Icon
            Circle()
                .fill(event.eventType.color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: event.eventType.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(event.eventType.color)
                }
            
            // Event Info
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(event.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if event.isToday {
                    Text("Aujourd'hui")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Placeholder Views
struct ChildrenView: View {
    @EnvironmentObject var viewModel: ChildrenViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.children.isEmpty && !viewModel.isLoading {
                    // Empty state
                    VStack(spacing: 30) {
                        Image(systemName: "figure.2.and.child.holdinghands")
                            .font(.system(size: 60))
                            .foregroundColor(.pink)
                        
                        Text("Aucun enfant")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Ajoutez votre premier enfant pour commencer")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: viewModel.showAddChild) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Ajouter un enfant")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.pink)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 40)
                } else {
                    // Children list
                    List {
                        ForEach(viewModel.children) { child in
                            ChildRow(
                                child: child,
                                onEdit: {
                                    viewModel.showEditChild(child)
                                },
                                onDelete: {
                                    Task {
                                        await viewModel.deleteChild(child)
                                    }
                                }
                            )
                        }
                    }
                    .refreshable {
                        await viewModel.loadChildren()
                    }
                }
            }
            .navigationTitle("Enfants")
            .toolbar {
                if !viewModel.children.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: viewModel.showAddChild) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Chargement...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddChild) {
            AddChildView { firstName, lastName, dateOfBirth, gender in
                Task {
                    await viewModel.addChild(
                        firstName: firstName,
                        lastName: lastName,
                        dateOfBirth: dateOfBirth,
                        gender: gender
                    )
                }
            }
        }
        .sheet(isPresented: $viewModel.showingEditChild) {
            if let childToEdit = viewModel.childToEdit {
                EditChildView(child: childToEdit) { firstName, lastName, dateOfBirth, gender in
                    Task {
                        await viewModel.updateChild(
                            childToEdit,
                            firstName: firstName,
                            lastName: lastName,
                            dateOfBirth: dateOfBirth,
                            gender: gender
                        )
                    }
                }
            }
        }
        .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.dismissError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .task {
            await viewModel.loadChildren()
        }
    }
}

enum CalendarViewType: String, CaseIterable {
    case month = "month"
    case week = "week"
    case day = "day"
    case agenda = "agenda"
    
    var displayName: String {
        switch self {
        case .month: return "Mois"
        case .week: return "Semaine"
        case .day: return "Jour"
        case .agenda: return "Agenda"
        }
    }
    
    var icon: String {
        switch self {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.left"
        case .day: return "calendar.day.timeline.leading"
        case .agenda: return "list.bullet.clipboard"
        }
    }
}

enum CalendarSheet: Identifiable {
    case filters
    case addEvent
    case editEvent
    
    var id: Int {
        switch self {
        case .filters: return 0
        case .addEvent: return 1
        case .editEvent: return 2
        }
    }
}

struct CalendarView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var activeSheet: CalendarSheet?
    @State private var selectedViewType: CalendarViewType = .month
    @State private var selectedDate = Date()
    
    // Événements à afficher (filtrés ou tous)
    private var displayedEvents: [Event] {
        eventsViewModel.filteredEvents.isEmpty ? eventsViewModel.events : eventsViewModel.filteredEvents
    }
    
    // Indicateur de filtres actifs
    private var hasActiveFilters: Bool {
        !eventsViewModel.searchText.isEmpty || 
        eventsViewModel.selectedEventType != nil || 
        eventsViewModel.selectedChildId != nil
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Barre de recherche
                SearchBar(text: $eventsViewModel.searchText) { text in
                    eventsViewModel.updateSearchText(text)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // En-tête avec sélecteur et bouton Aujourd'hui
                VStack(spacing: 12) {
                    // Sélecteur de vue calendrier
                    Picker("Vue calendrier", selection: $selectedViewType) {
                        ForEach(CalendarViewType.allCases, id: \.self) { viewType in
                            HStack {
                                Image(systemName: viewType.icon)
                                Text(viewType.displayName)
                            }
                            .tag(viewType)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Bouton Aujourd'hui (sauf pour la vue Agenda qui a le sien)
                    if selectedViewType != .agenda {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedDate = Date()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "calendar.circle.fill")
                                        .font(.caption)
                                    Text("Aujourd'hui")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.blue)
                                )
                            }
                            .disabled(Calendar.current.isDate(selectedDate, inSameDayAs: Date()))
                            .opacity(Calendar.current.isDate(selectedDate, inSameDayAs: Date()) ? 0.5 : 1.0)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Filtres actifs
                if hasActiveFilters {
                    ActiveFiltersView(
                        searchText: eventsViewModel.searchText,
                        selectedEventType: eventsViewModel.selectedEventType,
                        selectedChildId: eventsViewModel.selectedChildId,
                        children: childrenViewModel.children,
                        onClearFilters: {
                            eventsViewModel.clearFilters()
                        }
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                // Vue calendrier selon le type sélectionné
                Group {
                    switch selectedViewType {
                    case .month:
                        MonthCalendarView(selectedDate: $selectedDate, events: displayedEvents)
                    case .week:
                        WeekCalendarView(selectedDate: $selectedDate, events: displayedEvents)
                    case .day:
                        DayCalendarView(selectedDate: $selectedDate, events: displayedEvents)
                    case .agenda:
                        AgendaCalendarView(selectedDate: $selectedDate, events: displayedEvents)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: selectedViewType)
                
                Group {
                    if eventsViewModel.events.isEmpty && !eventsViewModel.isLoading {
                        // Empty state
                        VStack(spacing: 30) {
                            Image(systemName: "calendar")
                                .font(.system(size: 60))
                                .foregroundColor(.pink)
                            
                            Text("Aucun événement")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Ajoutez votre premier événement pour commencer")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: eventsViewModel.showAddEvent) {
                                HStack {
                                    Image(systemName: "calendar.badge.plus")
                                    Text("Ajouter un événement")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.pink)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 40)
                    } else if displayedEvents.isEmpty && hasActiveFilters {
                        // No results state
                        VStack(spacing: 20) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("Aucun résultat")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Aucun événement ne correspond à vos critères")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Effacer les filtres") {
                                eventsViewModel.clearFilters()
                            }
                            .foregroundColor(.pink)
                        }
                        .padding(.top, 60)
                    } else {
                        // Events list
                        List {
                            ForEach(displayedEvents) { event in
                                EventRow(
                                    event: event,
                                    onEdit: {
                                        eventsViewModel.eventToEdit = event
                                        activeSheet = .editEvent
                                    },
                                    onDelete: {
                                        Task {
                                            await eventsViewModel.deleteEvent(event)
                                        }
                                    }
                                )
                            }
                        }
                        .refreshable {
                            await eventsViewModel.loadEvents()
                        }
                    }
                }
            }
            .navigationTitle("Calendrier")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { activeSheet = .filters }) {
                        Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(hasActiveFilters ? .pink : .primary)
                    }
                }
                
                if !eventsViewModel.events.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { activeSheet = .addEvent }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .overlay {
                if eventsViewModel.isLoading {
                    ProgressView("Chargement...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
            .task {
                await eventsViewModel.loadEvents()
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .filters:
                FiltersView(
                    eventsViewModel: eventsViewModel,
                    childrenViewModel: childrenViewModel
                )
            case .addEvent:
                AddEventView { title, description, eventType, startDate, endDate, childId in
                    Task {
                        await eventsViewModel.addEvent(
                            title: title,
                            description: description,
                            eventType: eventType,
                            startDate: startDate,
                            endDate: endDate,
                            childId: childId,
                            notificationManager: notificationManager
                        )
                    }
                    activeSheet = nil
                }
            case .editEvent:
                if let eventToEdit = eventsViewModel.eventToEdit {
                    EditEventView(event: eventToEdit) { title, description, eventType, startDate, endDate, childId in
                        Task {
                            await eventsViewModel.updateEvent(
                                eventToEdit,
                                title: title,
                                description: description,
                                eventType: eventType,
                                startDate: startDate,
                                endDate: endDate,
                                childId: childId
                            )
                        }
                        activeSheet = nil
                    }
                }
            }
        }
        .alert("Erreur", isPresented: .constant(eventsViewModel.errorMessage != nil)) {
            Button("OK") {
                eventsViewModel.dismissError()
            }
        } message: {
            Text(eventsViewModel.errorMessage ?? "")
        }
    }
}

struct DocumentsView: View {
    @EnvironmentObject var documentsViewModel: DocumentsViewModel
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if documentsViewModel.isLoading {
                    ProgressView("Chargement des documents...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if documentsViewModel.documents.isEmpty {
                    // État vide
                    VStack(spacing: 30) {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.pink)
                        
                        Text("Aucun document")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Stockez vos documents importants\npour votre famille")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            documentsViewModel.showAddDocument()
                        }) {
                            HStack {
                                Image(systemName: "doc.badge.plus")
                                Text("Ajouter un document")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.pink)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.top, 40)
                } else {
                    // Liste des documents
                    List {
                        ForEach(documentsViewModel.documents) { document in
                            DocumentRow(
                                document: document,
                                onEdit: {
                                    documentsViewModel.showEditDocument(document)
                                },
                                onDelete: {
                                    Task {
                                        await documentsViewModel.deleteDocument(document)
                                    }
                                }
                            )
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                if let errorMessage = documentsViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .onTapGesture {
                            documentsViewModel.dismissError()
                        }
                }
            }
            .navigationTitle("Documents")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        documentsViewModel.showAddDocument()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $documentsViewModel.showingAddDocument) {
            AddDocumentView { title, description, documentType, fileName, childId in
                Task {
                    await documentsViewModel.addDocument(
                        title: title,
                        description: description,
                        documentType: documentType,
                        fileName: fileName,
                        childId: childId
                    )
                }
            }
            .environmentObject(childrenViewModel)
        }
        .sheet(isPresented: $documentsViewModel.showingEditDocument) {
            if let document = documentsViewModel.documentToEdit {
                EditDocumentView(
                    document: document,
                    onSave: { title, description, documentType, fileName, childId in
                        Task {
                            await documentsViewModel.updateDocument(
                                document,
                                title: title,
                                description: description,
                                documentType: documentType,
                                fileName: fileName,
                                childId: childId
                            )
                        }
                    }
                )
                .environmentObject(childrenViewModel)
            }
        }
        .task {
            await documentsViewModel.loadDocuments()
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingPersonalInfo = false
    @State private var showingNotifications = false
    @State private var showingPrivacy = false
    @State private var showingHelp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Profile Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.pink)
                    
                    Text(authManager.currentUser?.email ?? "Utilisateur")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Mon Profil")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                // Profile Options
                VStack(spacing: 16) {
                    ProfileOption(icon: "person.fill", title: "Informations personnelles") {
                        showingPersonalInfo = true
                    }
                    ProfileOption(icon: "bell.fill", title: "Notifications") {
                        showingNotifications = true
                    }
                    ProfileOption(icon: "lock.fill", title: "Confidentialité") {
                        showingPrivacy = true
                    }
                    ProfileOption(icon: "questionmark.circle.fill", title: "Aide") {
                        showingHelp = true
                    }
                }
                
                Spacer()
                
                // Sign Out Button
                Button(action: {
                    Task {
                        await authManager.signOut()
                    }
                }) {
                    Text("Se déconnecter")
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.top, 40)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingPersonalInfo) {
            PersonalInfoView()
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationsView()
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacyView()
        }
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
    }
}

struct ProfileOption: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.pink)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Modal Views (placeholder supprimé - implémentation complète plus bas)

// MARK: - Document Row

struct DocumentRow: View {
    let document: Document
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icône du type de document
            Circle()
                .fill(document.documentType.color.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: document.documentType.icon)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(document.documentType.color)
                }
            
            // Informations du document
            VStack(alignment: .leading, spacing: 4) {
                Text(document.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if let description = document.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(document.documentType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(document.documentType.color.opacity(0.2))
                        .foregroundColor(document.documentType.color)
                        .cornerRadius(8)
                    
                    Text(document.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Menu d'actions
            Menu {
                Button("Modifier", action: onEdit)
                Button("Supprimer", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Add Document View

struct AddDocumentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDocumentType: DocumentType = .other
    @State private var fileName = ""
    @State private var selectedChildId: UUID?
    @State private var isLoading = false
    
    let onSave: (String, String?, DocumentType, String?, UUID?) -> Void
    
    init(onSave: @escaping (String, String?, DocumentType, String?, UUID?) -> Void = { _, _, _, _, _ in }) {
        self.onSave = onSave
    }
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations du document") {
                    TextField("Titre", text: $title)
                        .textContentType(.none)
                    
                    TextField("Description (optionnel)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Type", selection: $selectedDocumentType) {
                        ForEach(DocumentType.allCases, id: \.self) { documentType in
                            HStack {
                                Image(systemName: documentType.icon)
                                    .foregroundColor(documentType.color)
                                Text(documentType.displayName)
                            }
                            .tag(documentType)
                        }
                    }
                }
                
                Section("Fichier") {
                    TextField("Nom du fichier (optionnel)", text: $fileName)
                        .textContentType(.none)
                }
                
                if !childrenViewModel.children.isEmpty {
                    Section("Enfant associé") {
                        Picker("Enfant", selection: $selectedChildId) {
                            Text("Aucun enfant").tag(nil as UUID?)
                            ForEach(childrenViewModel.children, id: \.id) { child in
                                Text(child.fullName).tag(child.id as UUID?)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nouveau document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        saveDocument()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Ajout en cours...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        }
        .task {
            await childrenViewModel.loadChildren()
        }
    }
    
    private func saveDocument() {
        isLoading = true
        
        onSave(
            title.trimmingCharacters(in: .whitespaces),
            description.isEmpty ? nil : description.trimmingCharacters(in: .whitespaces),
            selectedDocumentType,
            fileName.isEmpty ? nil : fileName.trimmingCharacters(in: .whitespaces),
            selectedChildId
        )
        
        // Le loading sera géré par le ViewModel
        isLoading = false
        dismiss()
    }
}

// MARK: - Edit Document View

struct EditDocumentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @State private var title: String
    @State private var description: String
    @State private var selectedDocumentType: DocumentType
    @State private var fileName: String
    @State private var selectedChildId: UUID?
    @State private var isLoading = false
    
    let document: Document
    let onSave: (String, String?, DocumentType, String?, UUID?) -> Void
    
    init(document: Document, onSave: @escaping (String, String?, DocumentType, String?, UUID?) -> Void) {
        self.document = document
        self.onSave = onSave
        self._title = State(initialValue: document.title)
        self._description = State(initialValue: document.description ?? "")
        self._selectedDocumentType = State(initialValue: document.documentType)
        self._fileName = State(initialValue: document.fileName ?? "")
        self._selectedChildId = State(initialValue: document.childId)
    }
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations du document") {
                    TextField("Titre", text: $title)
                        .textContentType(.none)
                    
                    TextField("Description (optionnel)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Type", selection: $selectedDocumentType) {
                        ForEach(DocumentType.allCases, id: \.self) { documentType in
                            HStack {
                                Image(systemName: documentType.icon)
                                    .foregroundColor(documentType.color)
                                Text(documentType.displayName)
                            }
                            .tag(documentType)
                        }
                    }
                }
                
                Section("Fichier") {
                    TextField("Nom du fichier (optionnel)", text: $fileName)
                        .textContentType(.none)
                }
                
                if !childrenViewModel.children.isEmpty {
                    Section("Enfant associé") {
                        Picker("Enfant", selection: $selectedChildId) {
                            Text("Aucun enfant").tag(nil as UUID?)
                            ForEach(childrenViewModel.children, id: \.id) { child in
                                Text(child.fullName).tag(child.id as UUID?)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Modifier le document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        saveDocument()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Modification en cours...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        }
        .task {
            await childrenViewModel.loadChildren()
        }
    }
    
    private func saveDocument() {
        isLoading = true
        
        onSave(
            title.trimmingCharacters(in: .whitespaces),
            description.isEmpty ? nil : description.trimmingCharacters(in: .whitespaces),
            selectedDocumentType,
            fileName.isEmpty ? nil : fileName.trimmingCharacters(in: .whitespaces),
            selectedChildId
        )
        
        // Le loading sera géré par le ViewModel
        isLoading = false
        dismiss()
    }
}

struct InviteFamilyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Inviter la famille")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Fonctionnalité en cours de développement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Inviter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PersonalInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations personnelles") {
                    TextField("Prénom", text: $firstName)
                        .textContentType(.givenName)
                    
                    TextField("Nom", text: $lastName)
                        .textContentType(.familyName)
                }
                
                Section("Compte") {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(authManager.currentUser?.email ?? "N/A")
                            .foregroundColor(.secondary)
                    }
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                if let successMessage = successMessage {
                    Section {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        saveProfile()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Enregistrement...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        }
        .onAppear {
            loadCurrentProfile()
        }
    }
    
    private func loadCurrentProfile() {
        if let profile = authManager.userProfile {
            firstName = profile.firstName
            lastName = profile.lastName
        }
    }
    
    private func saveProfile() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                try await authManager.updateUserProfile(
                    firstName: firstName.trimmingCharacters(in: .whitespaces),
                    lastName: lastName.trimmingCharacters(in: .whitespaces)
                )
                
                await MainActor.run {
                    successMessage = "Profil mis à jour avec succès !"
                    isLoading = false
                    
                    // Fermer la vue après 1 seconde
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Erreur lors de la mise à jour : \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Notifications")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Fonctionnalité en cours de développement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Confidentialité")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Fonctionnalité en cours de développement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Confidentialité")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Aide")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Fonctionnalité en cours de développement")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Aide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Child Row View
struct ChildRow: View {
    let child: Child
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(Color.pink.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Text(String(child.firstName.prefix(1)))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.pink)
                }
            
            // Child Info
            VStack(alignment: .leading, spacing: 4) {
                Text(child.fullName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(child.ageText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let gender = child.gender {
                    Text(Gender(rawValue: gender)?.displayName ?? gender)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Actions
            Menu {
                Button("Modifier", action: onEdit)
                Button("Supprimer", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Add Child View
struct AddChildView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Date()
    @State private var selectedGender: Gender? = nil
    @State private var isLoading = false
    
    let onSave: (String, String, Date, String?) -> Void
    
    init(onSave: @escaping (String, String, Date, String?) -> Void = { _, _, _, _ in }) {
        self.onSave = onSave
    }
    
    var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations de l'enfant") {
                    TextField("Prénom", text: $firstName)
                        .textContentType(.givenName)
                    
                    TextField("Nom", text: $lastName)
                        .textContentType(.familyName)
                    
                    DatePicker(
                        "Date de naissance",
                        selection: $dateOfBirth,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    
                    Picker("Genre", selection: $selectedGender) {
                        Text("Non spécifié").tag(nil as Gender?)
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.displayName).tag(gender as Gender?)
                        }
                    }
                }
            }
            .navigationTitle("Nouvel enfant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        saveChild()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Ajout en cours...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        }
    }
    
    private func saveChild() {
        isLoading = true
        
        onSave(
            firstName.trimmingCharacters(in: .whitespaces),
            lastName.trimmingCharacters(in: .whitespaces),
            dateOfBirth,
            selectedGender?.rawValue
        )
        
        // Note: isLoading sera géré par le ViewModel après l'opération async
        dismiss()
    }
}

// MARK: - Edit Child View
struct EditChildView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String
    @State private var lastName: String
    @State private var dateOfBirth: Date
    @State private var selectedGender: Gender?
    @State private var isLoading = false
    
    let child: Child
    let onSave: (String, String, Date, String?) -> Void
    
    init(child: Child, onSave: @escaping (String, String, Date, String?) -> Void) {
        self.child = child
        self.onSave = onSave
        self._firstName = State(initialValue: child.firstName)
        self._lastName = State(initialValue: child.lastName)
        self._dateOfBirth = State(initialValue: child.dateOfBirth)
        self._selectedGender = State(initialValue: child.gender.flatMap { Gender(rawValue: $0) })
    }
    
    var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations de l'enfant") {
                    TextField("Prénom", text: $firstName)
                        .textContentType(.givenName)
                    
                    TextField("Nom", text: $lastName)
                        .textContentType(.familyName)
                    
                    DatePicker(
                        "Date de naissance",
                        selection: $dateOfBirth,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    
                    Picker("Genre", selection: $selectedGender) {
                        Text("Non spécifié").tag(nil as Gender?)
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.displayName).tag(gender as Gender?)
                        }
                    }
                }
            }
            .navigationTitle("Modifier l'enfant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        saveChild()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Modification en cours...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        }
    }
    
    private func saveChild() {
        isLoading = true
        
        onSave(
            firstName.trimmingCharacters(in: .whitespaces),
            lastName.trimmingCharacters(in: .whitespaces),
            dateOfBirth,
            selectedGender?.rawValue
        )
        
        // Note: isLoading sera géré par le ViewModel après l'opération async
        dismiss()
    }
}

// MARK: - Event Row View
struct EventRow: View {
    let event: Event
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Event Type Icon
            Circle()
                .fill(event.eventType.color.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: event.eventType.icon)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(event.eventType.color)
                }
            
            // Event Info
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(event.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(event.eventType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(event.eventType.color.opacity(0.2))
                        .foregroundColor(event.eventType.color)
                        .cornerRadius(8)
                    
                    if event.isToday {
                        Text("Aujourd'hui")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
            
            // Actions
            Menu {
                Button("Modifier", action: onEdit)
                Button("Supprimer", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Add Event View
struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedEventType: EventType = .other
    @State private var startDate = Date()
    @State private var endDate: Date?
    @State private var hasEndDate = false
    @State private var selectedChildId: UUID?
    @State private var isLoading = false
    
    let onSave: (String, String?, EventType, Date, Date?, UUID?) -> Void
    
    init(onSave: @escaping (String, String?, EventType, Date, Date?, UUID?) -> Void = { _, _, _, _, _, _ in }) {
        self.onSave = onSave
    }
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations de l'événement") {
                    TextField("Titre", text: $title)
                        .textContentType(.none)
                    
                    TextField("Description (optionnel)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Type", selection: $selectedEventType) {
                        ForEach(EventType.allCases, id: \.self) { eventType in
                            HStack {
                                Image(systemName: eventType.icon)
                                    .foregroundColor(eventType.color)
                                Text(eventType.displayName)
                            }
                            .tag(eventType)
                        }
                    }
                }
                
                Section("Date et heure") {
                    DatePicker(
                        "Début",
                        selection: $startDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    
                    Toggle("Date de fin", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker(
                            "Fin",
                            selection: Binding(
                                get: { endDate ?? startDate.addingTimeInterval(3600) },
                                set: { endDate = $0 }
                            ),
                            in: startDate...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
            }
            .navigationTitle("Nouvel événement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        saveEvent()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Ajout en cours...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        }
    }
    
    private func saveEvent() {
        isLoading = true
        
        onSave(
            title.trimmingCharacters(in: .whitespaces),
            description.isEmpty ? nil : description.trimmingCharacters(in: .whitespaces),
            selectedEventType,
            startDate,
            hasEndDate ? endDate : nil,
            selectedChildId
        )
        
        // Note: isLoading sera géré par le ViewModel après l'opération async
        dismiss()
    }
}

// MARK: - Edit Event View
struct EditEventView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var description: String
    @State private var selectedEventType: EventType
    @State private var startDate: Date
    @State private var endDate: Date?
    @State private var hasEndDate: Bool
    @State private var selectedChildId: UUID?
    @State private var isLoading = false
    
    let event: Event
    let onSave: (String, String?, EventType, Date, Date?, UUID?) -> Void
    
    init(event: Event, onSave: @escaping (String, String?, EventType, Date, Date?, UUID?) -> Void) {
        self.event = event
        self.onSave = onSave
        self._title = State(initialValue: event.title)
        self._description = State(initialValue: event.description ?? "")
        self._selectedEventType = State(initialValue: event.eventType)
        self._startDate = State(initialValue: event.startDate)
        self._endDate = State(initialValue: event.endDate)
        self._hasEndDate = State(initialValue: event.endDate != nil)
        self._selectedChildId = State(initialValue: event.childId)
    }
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations de l'événement") {
                    TextField("Titre", text: $title)
                        .textContentType(.none)
                    
                    TextField("Description (optionnel)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Type", selection: $selectedEventType) {
                        ForEach(EventType.allCases, id: \.self) { eventType in
                            HStack {
                                Image(systemName: eventType.icon)
                                    .foregroundColor(eventType.color)
                                Text(eventType.displayName)
                            }
                            .tag(eventType)
                        }
                    }
                }
                
                Section("Date et heure") {
                    DatePicker(
                        "Début",
                        selection: $startDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    
                    Toggle("Date de fin", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker(
                            "Fin",
                            selection: Binding(
                                get: { endDate ?? startDate.addingTimeInterval(3600) },
                                set: { endDate = $0 }
                            ),
                            in: startDate...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
            }
            .navigationTitle("Modifier l'événement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        saveEvent()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Modification en cours...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
        }
    }
    
    private func saveEvent() {
        isLoading = true
        
        onSave(
            title.trimmingCharacters(in: .whitespaces),
            description.isEmpty ? nil : description.trimmingCharacters(in: .whitespaces),
            selectedEventType,
            startDate,
            hasEndDate ? endDate : nil,
            selectedChildId
        )
        
        // Note: isLoading sera géré par le ViewModel après l'opération async
        dismiss()
    }
}

// MARK: - Notification Manager

@MainActor
class NotificationManager: ObservableObject {
    @Published var isAuthorized = false
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    init() {
        checkAuthorizationStatus()
    }
    
    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            await MainActor.run {
                self.isAuthorized = granted
            }
            print(granted ? "✅ Notifications autorisées" : "❌ Notifications refusées")
        } catch {
            print("❌ Erreur demande permission notifications: \(error)")
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleEventReminder(for event: Event, minutesBefore: Int = 30) async {
        guard isAuthorized else {
            print("❌ Notifications non autorisées")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Rappel d'événement"
        content.body = "\(event.title) dans \(minutesBefore) minutes"
        content.sound = .default
        content.badge = 1
        
        // Calculer la date de notification
        let notificationDate = event.startDate.addingTimeInterval(-Double(minutesBefore * 60))
        
        // Ne programmer que les événements futurs
        guard notificationDate > Date() else {
            print("⏰ Événement trop proche pour programmer une notification")
            return
        }
        
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notificationDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )
        
        let identifier = "event_\(event.id.uuidString)_\(minutesBefore)min"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Notification programmée pour \(event.title) à \(notificationDate)")
        } catch {
            print("❌ Erreur programmation notification: \(error)")
        }
    }
    
    func cancelEventReminders(for eventId: UUID) async {
        let identifiers = [
            "event_\(eventId.uuidString)_30min",
            "event_\(eventId.uuidString)_60min",
            "event_\(eventId.uuidString)_1440min" // 24h
        ]
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🗑️ Notifications supprimées pour l'événement \(eventId)")
    }
    
    func scheduleSmartReminders(for events: [Event]) async {
        for event in events {
            // Rappel 30 minutes avant pour tous les événements
            await scheduleEventReminder(for: event, minutesBefore: 30)
            
            // Rappel 1 heure avant pour les événements médicaux
            if event.eventType == .medical {
                await scheduleEventReminder(for: event, minutesBefore: 60)
            }
            
            // Rappel 24h avant pour les événements scolaires
            if event.eventType == .school {
                await scheduleEventReminder(for: event, minutesBefore: 1440) // 24h
            }
        }
    }
    
    func getPendingNotifications() async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        await MainActor.run {
            self.pendingNotifications = requests
        }
        print("📋 \(requests.count) notifications en attente")
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var cacheManager: CacheManager
    @EnvironmentObject var memoryManager: MemoryManager
    @State private var showingNotificationSettings = false
    
    var body: some View {
        NavigationView {
            List {
                // Section Notifications
                Section("Notifications") {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rappels d'événements")
                                .font(.headline)
                            Text(notificationManager.isAuthorized ? "Activées" : "Désactivées")
                                .font(.caption)
                                .foregroundColor(notificationManager.isAuthorized ? .green : .red)
                        }
                        
                        Spacer()
                        
                        if !notificationManager.isAuthorized {
                            Button("Activer") {
                                Task {
                                    await notificationManager.requestPermission()
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if notificationManager.isAuthorized {
                        Button(action: { showingNotificationSettings = true }) {
                            HStack {
                                Image(systemName: "gear")
                                    .foregroundColor(.gray)
                                    .frame(width: 30)
                                Text("Paramètres de notifications")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                // Section Performance
                Section("Performance") {
                    HStack {
                        Image(systemName: "speedometer")
                            .foregroundColor(.green)
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Cache")
                                .font(.headline)
                            Text("Taux de réussite: \(String(format: "%.1f", cacheManager.cacheHitRate * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(cacheManager.currentMemoryUsage / 1024 / 1024) MB")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "memorychip")
                            .foregroundColor(memoryManager.memoryWarning ? .red : .blue)
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mémoire")
                                .font(.headline)
                            Text("Utilisation: \(String(format: "%.1f", memoryManager.memoryUsage)) MB")
                                .font(.caption)
                                .foregroundColor(memoryManager.memoryWarning ? .red : .secondary)
                        }
                        Spacer()
                        if memoryManager.memoryWarning {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Button(action: {
                        cacheManager.clear()
                        NotificationCenter.default.post(name: .memoryCleanupRequired, object: nil)
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                                .frame(width: 30)
                            Text("Vider le cache")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Section Compte
                Section("Compte") {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Profil utilisateur")
                                .font(.headline)
                            if let email = authManager.currentUser?.email {
                                Text(email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    
                    Button(action: {
                        Task {
                            await authManager.signOut()
                        }
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .frame(width: 30)
                            Text("Se déconnecter")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                
                // Section À propos
                Section("À propos") {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.purple)
                            .frame(width: 30)
                        Text("Version de l'app")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Paramètres")
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
                .environmentObject(notificationManager)
        }
    }
}

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var reminderFor30Min = true
    @State private var reminderFor1Hour = true
    @State private var reminderFor24Hours = false
    @State private var smartReminders = true
    
    var body: some View {
        NavigationView {
            List {
                Section("Rappels par défaut") {
                    Toggle("30 minutes avant", isOn: $reminderFor30Min)
                    Toggle("1 heure avant", isOn: $reminderFor1Hour)
                    Toggle("24 heures avant", isOn: $reminderFor24Hours)
                }
                
                Section("Rappels intelligents") {
                    Toggle("Activer les rappels intelligents", isOn: $smartReminders)
                    
                    if smartReminders {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Les rappels intelligents adaptent automatiquement les notifications selon le type d'événement :")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "cross.fill")
                                    .foregroundColor(.red)
                                Text("Médical : 30min + 1h avant")
                                    .font(.caption)
                            }
                            
                            HStack {
                                Image(systemName: "book.fill")
                                    .foregroundColor(.blue)
                                Text("École : 30min + 24h avant")
                                    .font(.caption)
                            }
                            
                            HStack {
                                Image(systemName: "figure.run")
                                    .foregroundColor(.green)
                                Text("Activité : 30min avant")
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section("Notifications en attente") {
                    HStack {
                        Text("Notifications programmées")
                        Spacer()
                        Text("\(notificationManager.pendingNotifications.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Actualiser") {
                        Task {
                            await notificationManager.getPendingNotifications()
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Terminé") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await notificationManager.getPendingNotifications()
        }
    }
}

// MARK: - Search and Filter Components

struct SearchBar: View {
    @Binding var text: String
    let onSearchTextChanged: (String) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Rechercher des événements...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: text) { newValue in
                    onSearchTextChanged(newValue)
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onSearchTextChanged("")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ActiveFiltersView: View {
    let searchText: String
    let selectedEventType: EventType?
    let selectedChildId: UUID?
    let children: [Child]
    let onClearFilters: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if !searchText.isEmpty {
                    FilterChip(title: "\"\(searchText)\"", color: .blue)
                }
                
                if let eventType = selectedEventType {
                    FilterChip(title: eventType.displayName, color: eventType.color)
                }
                
                if let childId = selectedChildId,
                   let child = children.first(where: { $0.id == childId }) {
                    FilterChip(title: child.fullName, color: .purple)
                }
                
                Button("Effacer tout") {
                    onClearFilters()
                }
                .font(.caption)
                .foregroundColor(.pink)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.pink.opacity(0.1))
                .cornerRadius(6)
            }
            .padding(.horizontal)
        }
    }
}

struct FilterChip: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.caption)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(6)
    }
}

struct FiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var eventsViewModel: EventsViewModel
    @ObservedObject var childrenViewModel: ChildrenViewModel
    
    @State private var tempSearchText: String
    @State private var tempEventType: EventType?
    @State private var tempChildId: UUID?
    
    init(eventsViewModel: EventsViewModel, childrenViewModel: ChildrenViewModel) {
        self.eventsViewModel = eventsViewModel
        self.childrenViewModel = childrenViewModel
        self._tempSearchText = State(initialValue: eventsViewModel.searchText)
        self._tempEventType = State(initialValue: eventsViewModel.selectedEventType)
        self._tempChildId = State(initialValue: eventsViewModel.selectedChildId)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Recherche") {
                    TextField("Rechercher par titre ou description", text: $tempSearchText)
                }
                
                Section("Type d'événement") {
                    Picker("Type", selection: $tempEventType) {
                        Text("Tous les types").tag(nil as EventType?)
                        ForEach(EventType.allCases, id: \.self) { eventType in
                            HStack {
                                Image(systemName: eventType.icon)
                                    .foregroundColor(eventType.color)
                                Text(eventType.displayName)
                            }
                            .tag(eventType as EventType?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                if !childrenViewModel.children.isEmpty {
                    Section("Enfant") {
                        Picker("Enfant", selection: $tempChildId) {
                            Text("Tous les enfants").tag(nil as UUID?)
                            ForEach(childrenViewModel.children) { child in
                                Text(child.fullName).tag(child.id as UUID?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section {
                    Button("Effacer tous les filtres") {
                        tempSearchText = ""
                        tempEventType = nil
                        tempChildId = nil
                    }
                    .foregroundColor(.pink)
                }
            }
            .navigationTitle("Filtres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Appliquer") {
                        applyFilters()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func applyFilters() {
        eventsViewModel.updateSearchText(tempSearchText)
        eventsViewModel.selectEventType(tempEventType)
        eventsViewModel.selectChild(tempChildId)
    }
}

// MARK: - Calendar Views
struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    let events: [Event]
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    var body: some View {
        VStack {
            // En-tête du mois
            HStack {
                Button(action: { changeMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: selectedDate))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { changeMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Grille du calendrier (version simplifiée)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Jours de la semaine
                ForEach(Array(zip(["L", "Ma", "Me", "J", "V", "S", "D"].indices, ["L", "Ma", "Me", "J", "V", "S", "D"])), id: \.0) { index, day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                // Jours du mois
                ForEach(daysInMonth, id: \.self) { date in
                    DayCell(date: date, events: eventsForDate(date), isSelected: calendar.isDate(date, inSameDayAs: selectedDate))
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end - 1)
        else { return [] }
        
        var days: [Date] = []
        var date = monthFirstWeek.start
        
        while date < monthLastWeek.end {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return days
    }
    
    private func eventsForDate(_ date: Date) -> [Event] {
        events.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
    }
    
    private func changeMonth(_ direction: Int) {
        if let newDate = calendar.date(byAdding: .month, value: direction, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

struct DayCell: View {
    let date: Date
    let events: [Event]
    let isSelected: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
            
            // Indicateurs d'événements
            HStack(spacing: 2) {
                ForEach(events.prefix(3), id: \.id) { event in
                    Circle()
                        .fill(event.eventType.color)
                        .frame(width: 4, height: 4)
                }
                if events.count > 3 {
                    Text("+")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: 32, height: 40)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue : Color.clear)
        )
    }
}

struct WeekCalendarView: View {
    @Binding var selectedDate: Date
    let events: [Event]
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    private var weekDays: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }
        
        var days: [Date] = []
        var date = weekInterval.start
        
        while date < weekInterval.end {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // En-tête de la semaine
            HStack {
                Button(action: { changeWeek(-1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(weekTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { changeWeek(1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            // Grille de la semaine
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    WeekDayCell(
                        date: day,
                        events: eventsForDate(day),
                        isSelected: calendar.isDate(day, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(day)
                    )
                    .onTapGesture {
                        selectedDate = day
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var weekTitle: String {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return ""
        }
        
        let startFormatter = DateFormatter()
        startFormatter.dateFormat = "d MMM"
        startFormatter.locale = Locale(identifier: "fr_FR")
        
        let endFormatter = DateFormatter()
        endFormatter.dateFormat = "d MMM yyyy"
        endFormatter.locale = Locale(identifier: "fr_FR")
        
        return "\(startFormatter.string(from: weekInterval.start)) - \(endFormatter.string(from: weekInterval.end - 1))"
    }
    
    private func eventsForDate(_ date: Date) -> [Event] {
        events.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
    }
    
    private func changeWeek(_ direction: Int) {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: direction, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

struct WeekDayCell: View {
    let date: Date
    let events: [Event]
    let isSelected: Bool
    let isToday: Bool
    
    private let calendar = Calendar.current
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 8) {
            // Jour de la semaine
            Text(dayFormatter.string(from: date).capitalized)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            // Numéro du jour
            Text("\(calendar.component(.day, from: date))")
                .font(.title2)
                .fontWeight(isSelected ? .bold : .medium)
                .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.1) : Color.clear))
                )
            
            // Indicateurs d'événements
            VStack(spacing: 2) {
                ForEach(events.prefix(3), id: \.id) { event in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(event.eventType.color)
                        .frame(height: 4)
                }
                
                if events.count > 3 {
                    Text("+\(events.count - 3)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        )
    }
}

struct DayCalendarView: View {
    @Binding var selectedDate: Date
    let events: [Event]
    
    private let calendar = Calendar.current
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private var dayEvents: [Event] {
        events.filter { calendar.isDate($0.startDate, inSameDayAs: selectedDate) }
            .sorted { $0.startDate < $1.startDate }
    }
    
    private var timeSlots: [Int] {
        Array(6...23) // 6h à 23h
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // En-tête du jour
            HStack {
                Button(action: { changeDay(-1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(dayFormatter.string(from: selectedDate).capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if calendar.isDateInToday(selectedDate) {
                        Text("Aujourd'hui")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                Button(action: { changeDay(1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            // Timeline du jour
            if dayEvents.isEmpty {
                // État vide
                VStack(spacing: 16) {
                    Image(systemName: "calendar")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Aucun événement")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Profitez de cette journée libre !")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Liste des événements
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(dayEvents, id: \.id) { event in
                            DayEventCard(event: event)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func changeDay(_ direction: Int) {
        if let newDate = calendar.date(byAdding: .day, value: direction, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

struct AgendaCalendarView: View {
    @Binding var selectedDate: Date
    let events: [Event]
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    private let sectionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    // Événements groupés par date
    private var groupedEvents: [(Date, [Event])] {
        let now = Date()
        let futureEvents = events
            .filter { $0.startDate >= now }
            .sorted { $0.startDate < $1.startDate }
        
        let grouped = Dictionary(grouping: futureEvents) { event in
            calendar.startOfDay(for: event.startDate)
        }
        
        return grouped
            .sorted { $0.key < $1.key }
            .map { (date, events) in
                (date, events.sorted { $0.startDate < $1.startDate })
            }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // En-tête Agenda
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Agenda")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Événements à venir")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Bouton "Aujourd'hui"
                Button(action: {
                    selectedDate = Date()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar.circle")
                        Text("Aujourd'hui")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            // Liste des événements groupés
            if groupedEvents.isEmpty {
                // État vide
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Aucun événement à venir")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text("Tous vos événements futurs apparaîtront ici")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedEvents, id: \.0) { date, dayEvents in
                            AgendaDateSection(date: date, events: dayEvents)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct AgendaDateSection: View {
    let date: Date
    let events: [Event]
    
    private let calendar = Calendar.current
    private let sectionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    private var dateTitle: String {
        if calendar.isDateInToday(date) {
            return "Aujourd'hui"
        } else if calendar.isDateInTomorrow(date) {
            return "Demain"
        } else {
            return sectionDateFormatter.string(from: date).capitalized
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // En-tête de section
            HStack {
                Text(dateTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(events.count) événement\(events.count > 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
            }
            .padding(.top, 20)
            
            // Liste des événements du jour
            VStack(spacing: 8) {
                ForEach(events, id: \.id) { event in
                    AgendaEventCard(event: event)
                }
            }
        }
    }
}

struct AgendaEventCard: View {
    let event: Event
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 12) {
            // Barre colorée et heure
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(event.eventType.color)
                    .frame(width: 4, height: 40)
                
                Text(timeFormatter.string(from: event.startDate))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            // Contenu de l'événement
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: event.eventType.icon)
                        .foregroundColor(event.eventType.color)
                        .font(.caption)
                    
                    Text(event.eventType.displayName)
                        .font(.caption)
                        .foregroundColor(event.eventType.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(event.eventType.color.opacity(0.1))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    if let endDate = event.endDate {
                        Text("\(timeFormatter.string(from: event.startDate)) - \(timeFormatter.string(from: endDate))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                if let description = event.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Informations spéciales pour garde d'enfant
                if event.eventType == .childcare, let childcareInfo = event.childcareInfo {
                    HStack(spacing: 12) {
                        if let nannyName = childcareInfo.nannyName {
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption2)
                                Text(nannyName)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let nannyPhone = childcareInfo.nannyPhone {
                            HStack(spacing: 4) {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.green)
                                    .font(.caption2)
                                Text(nannyPhone)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
    }
}

struct DayEventCard: View {
    let event: Event
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 16) {
            // Heure
            VStack(spacing: 4) {
                Text(timeFormatter.string(from: event.startDate))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                if let endDate = event.endDate {
                    Text(timeFormatter.string(from: endDate))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 50)
            
            // Barre colorée
            RoundedRectangle(cornerRadius: 2)
                .fill(event.eventType.color)
                .frame(width: 4)
            
            // Contenu de l'événement
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: event.eventType.icon)
                        .foregroundColor(event.eventType.color)
                        .font(.caption)
                    
                    Text(event.eventType.displayName)
                        .font(.caption)
                        .foregroundColor(event.eventType.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(event.eventType.color.opacity(0.1))
                        .cornerRadius(4)
                    
                    Spacer()
                }
                
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if let description = event.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                // Informations de garde d'enfant si disponibles
                if event.eventType == .childcare, let childcareInfo = event.childcareInfo {
                    VStack(alignment: .leading, spacing: 4) {
                        if let nannyName = childcareInfo.nannyName {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text("Nanny: \(nannyName)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let nannyPhone = childcareInfo.nannyPhone {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text(nannyPhone)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}