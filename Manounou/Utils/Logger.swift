import Foundation
import os.log

/// Système de logging sécurisé et professionnel pour l'application Manounou
/// Remplace tous les statements print() par un logging structuré et sécurisé
final class Logger {
    
    // MARK: - Log Categories
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.manounou.app"
    
    private static let authLogger = OSLog(subsystem: subsystem, category: "Authentication")
    private static let networkLogger = OSLog(subsystem: subsystem, category: "Network")
    private static let cacheLogger = OSLog(subsystem: subsystem, category: "Cache")
    private static let uiLogger = OSLog(subsystem: subsystem, category: "UI")
    private static let dataLogger = OSLog(subsystem: subsystem, category: "Data")
    private static let performanceLogger = OSLog(subsystem: subsystem, category: "Performance")
    private static let errorLogger = OSLog(subsystem: subsystem, category: "Error")
    
    // MARK: - Log Levels
    enum LogLevel {
        case debug
        case info
        case warning
        case error
        case critical
        
        var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .warning:
                return .default
            case .error:
                return .error
            case .critical:
                return .fault
            }
        }
    }
    
    // MARK: - Log Categories
    enum Category {
        case auth
        case network
        case cache
        case ui
        case data
        case performance
        case error
        
        var logger: OSLog {
            switch self {
            case .auth:
                return authLogger
            case .network:
                return networkLogger
            case .cache:
                return cacheLogger
            case .ui:
                return uiLogger
            case .data:
                return dataLogger
            case .performance:
                return performanceLogger
            case .error:
                return errorLogger
            }
        }
    }
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Logging Methods
    
    /// Log général avec catégorie et niveau spécifiés
    static func log(
        _ message: String,
        level: LogLevel = .info,
        category: Category = .data,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "[\(fileName):\(line)] \(function) - \(message)"
        os_log("%{public}@", log: category.logger, type: level.osLogType, formattedMessage)
        #else
        // En production, on évite d'exposer les détails de fichier/ligne
        os_log("%{public}@", log: category.logger, type: level.osLogType, message)
        #endif
    }
    
    /// Log de debug (uniquement en développement)
    static func debug(
        _ message: String,
        category: Category = .data,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        log(message, level: .debug, category: category, file: file, function: function, line: line)
        #endif
    }
    
    /// Log d'information
    static func info(
        _ message: String,
        category: Category = .data,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    /// Log d'avertissement
    static func warning(
        _ message: String,
        category: Category = .data,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    /// Log d'erreur
    static func error(
        _ message: String,
        error: Error? = nil,
        category: Category = .error,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var fullMessage = message
        if let error = error {
            fullMessage += " - Error: \(error.localizedDescription)"
        }
        log(fullMessage, level: .error, category: category, file: file, function: function, line: line)
    }
    
    /// Log critique (erreurs graves)
    static func critical(
        _ message: String,
        error: Error? = nil,
        category: Category = .error,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var fullMessage = message
        if let error = error {
            fullMessage += " - Critical Error: \(error.localizedDescription)"
        }
        log(fullMessage, level: .critical, category: category, file: file, function: function, line: line)
    }
    
    // MARK: - Specialized Logging Methods
    
    /// Log pour les opérations d'authentification
    static func auth(_ message: String, level: LogLevel = .info) {
        log(message, level: level, category: .auth)
    }
    
    /// Log pour les opérations réseau
    static func network(_ message: String, level: LogLevel = .info) {
        log(message, level: level, category: .network)
    }
    
    /// Log pour les opérations de cache
    static func cache(_ message: String, level: LogLevel = .info) {
        log(message, level: level, category: .cache)
    }
    
    /// Log pour les interactions UI
    static func ui(_ message: String, level: LogLevel = .info) {
        log(message, level: level, category: .ui)
    }
    
    /// Log pour les mesures de performance
    static func performance(_ message: String, duration: TimeInterval? = nil) {
        var fullMessage = message
        if let duration = duration {
            fullMessage += " - Duration: \(String(format: "%.3f", duration))s"
        }
        log(fullMessage, level: .info, category: .performance)
    }
    
    // MARK: - Performance Measurement
    
    /// Mesure le temps d'exécution d'une opération
    static func measureTime<T>(
        operation: String,
        category: Category = .performance,
        block: () throws -> T
    ) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        performance("\(operation) completed", duration: timeElapsed)
        return result
    }
    
    /// Mesure le temps d'exécution d'une opération asynchrone
    static func measureTimeAsync<T>(
        operation: String,
        category: Category = .performance,
        block: () async throws -> T
    ) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        performance("\(operation) completed", duration: timeElapsed)
        return result
    }
}

// MARK: - Extensions pour faciliter l'utilisation

extension Logger {
    
    /// Log d'événement utilisateur (sans données sensibles)
    static func userEvent(_ event: String, parameters: [String: Any] = [:]) {
        let sanitizedParams = parameters.compactMapValues { value in
            // Éviter de logger des données sensibles
            if let stringValue = value as? String {
                return stringValue.count > 50 ? "\(stringValue.prefix(50))..." : stringValue
            }
            return String(describing: value)
        }
        
        let message = "User Event: \(event)" + (sanitizedParams.isEmpty ? "" : " - Params: \(sanitizedParams)")
        ui(message, level: .info)
    }
    
    /// Log de navigation
    static func navigation(from: String, to: String) {
        ui("Navigation: \(from) → \(to)", level: .debug)
    }
    
    /// Log de chargement de données
    static func dataLoad(_ dataType: String, count: Int, duration: TimeInterval? = nil) {
        var message = "Loaded \(count) \(dataType)"
        if let duration = duration {
            message += " in \(String(format: "%.3f", duration))s"
        }
        log(message, level: .info, category: .data)
    }
}

// MARK: - Configuration de logging

extension Logger {
    
    /// Configuration du niveau de logging selon l'environnement
    static func configure() {
        #if DEBUG
        info("Logger configured for DEBUG environment", category: .data)
        #else
        info("Logger configured for PRODUCTION environment", category: .data)
        #endif
    }
    
    /// Vérifie si le logging est activé pour un niveau donné
    static func isEnabled(for level: LogLevel, category: Category) -> Bool {
        #if DEBUG
        return true
        #else
        // En production, on peut désactiver certains niveaux
        return level != .debug
        #endif
    }
}

// MARK: - Performance Timer Helper

struct PerformanceTimer {
    private let label: String
    private let category: Logger.Category
    private let start: DispatchTime
    
    init(_ label: String, category: Logger.Category = .performance) {
        self.label = label
        self.category = category
        self.start = DispatchTime.now()
        Logger.debug("⏱️ Start: \(label)", category: category)
    }
    
    func end(extra: String? = nil) {
        let end = DispatchTime.now()
        let nanos = end.uptimeNanoseconds - start.uptimeNanoseconds
        let ms = Double(nanos) / 1_000_000
        let durationMsg = String(format: "%.2f ms", ms)
        if let extra = extra {
            Logger.performance("⏱️ End: \(label) — \(durationMsg) — \(extra)")
        } else {
            Logger.performance("⏱️ End: \(label) — \(durationMsg)")
        }
    }
}