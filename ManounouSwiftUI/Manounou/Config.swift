//
//  Config.swift
//  Manounou
//
//  Created by Assistant on 2025-01-13.
//

import Foundation

// MARK: - Configuration de l'application
struct AppConfig {
    
    // MARK: - Supabase Configuration
    struct Supabase {
        // ✅ Configuration Supabase - Clés configurées
        // Dashboard Supabase : https://app.supabase.com/project/emgrtgencepzainsknsb
        
        static let url = "https://emgrtgencepzainsknsb.supabase.co"
        static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtZ3J0Z2VuY2VwemFpbnNrbnNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxNjU3MzcsImV4cCI6MjA3MDc0MTczN30.2TtED_BEXHf6UqgPPcuOOd5YYTZlyqLSZRMoZtO93yM"
        
        // URL complète pour l'API
        static var apiURL: URL {
            guard let url = URL(string: url) else {
                fatalError("URL Supabase invalide: \(url)")
            }
            return url
        }
    }
    
    // MARK: - App Information
    struct App {
        static let name = "Manounou"
        static let version = "1.0.0"
        static let bundleId = "com.manounou.app"
        static let supportEmail = "support@manounou.app"
        static let websiteURL = "https://manounou.app"
    }
    
    // MARK: - API Configuration
    struct API {
        static let timeout: TimeInterval = 30.0
        static let maxRetries = 3
    }
    
    // MARK: - Feature Flags
    struct Features {
        static let enablePushNotifications = true
        static let enableOfflineMode = false
        static let enableAnalytics = true
        static let enableCrashReporting = true
    }
    
    // MARK: - UI Configuration
    struct UI {
        static let animationDuration = 0.3
        static let cornerRadius = 12.0
        static let shadowRadius = 4.0
    }
    
    // MARK: - Validation Rules
    struct Validation {
        static let minPasswordLength = 6
        static let maxPasswordLength = 128
        static let maxNameLength = 50
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    }
    
    // MARK: - Storage Keys
    struct StorageKeys {
        static let userToken = "user_token"
        static let userProfile = "user_profile"
        static let appSettings = "app_settings"
        static let lastSyncDate = "last_sync_date"
    }
    
    // MARK: - Environment Detection
    enum Environment {
        case development
        case staging
        case production
        
        static var current: Environment {
            #if DEBUG
            return .development
            #elseif STAGING
            return .staging
            #else
            return .production
            #endif
        }
        
        var isProduction: Bool {
            return self == .production
        }
        
        var isDevelopment: Bool {
            return self == .development
        }
    }
    
    // MARK: - Debug Configuration
    struct Debug {
        static let enableLogging = Environment.current.isDevelopment
        static let enableNetworkLogging = Environment.current.isDevelopment
        static let showDebugInfo = Environment.current.isDevelopment
    }
}

// MARK: - Configuration Validation
extension AppConfig {
    
    /// Valide la configuration de l'application au démarrage
    static func validateConfiguration() {
        // Vérification de la configuration Supabase
        guard !Supabase.url.contains("your-project-ref") else {
            fatalError("❌ Configuration Supabase manquante! Veuillez configurer votre URL Supabase dans Config.swift")
        }
        
        guard !Supabase.anonKey.contains("your-anon-key") else {
            fatalError("❌ Clé Supabase manquante! Veuillez configurer votre clé anonyme dans Config.swift")
        }
        
        // Vérification de la validité de l'URL
        guard URL(string: Supabase.url) != nil else {
            fatalError("❌ URL Supabase invalide: \(Supabase.url)")
        }
        
        if Debug.enableLogging {
            print("✅ Configuration validée avec succès")
            print("🌍 Environnement: \(Environment.current)")
            print("🔗 URL Supabase: \(Supabase.url)")
        }
    }
}

// MARK: - Helper Extensions
extension AppConfig {
    
    /// Retourne les headers par défaut pour les requêtes API
    static var defaultHeaders: [String: String] {
        return [
            "Content-Type": "application/json",
            "User-Agent": "\(App.name)/\(App.version)",
            "apikey": Supabase.anonKey
        ]
    }
    
    /// Retourne l'URL complète pour un endpoint donné
    static func apiURL(for endpoint: String) -> URL {
        return Supabase.apiURL.appendingPathComponent(endpoint)
    }
}

// MARK: - Configuration pour différents environnements
#if DEBUG
extension AppConfig.Supabase {
    // Configuration de développement
    static let enableDetailedLogging = true
    static let bypassSSLValidation = false // ⚠️ Jamais en production!
}
#endif

// MARK: - Instructions de configuration
/*
 📋 INSTRUCTIONS DE CONFIGURATION SUPABASE
 
 1. Allez sur https://app.supabase.com
 2. Créez un nouveau projet ou sélectionnez un projet existant
 3. Dans les paramètres du projet, section "API":
    - Copiez l'"URL" dans AppConfig.Supabase.url
    - Copiez la "anon public" key dans AppConfig.Supabase.anonKey
 
 4. Exemple de configuration :
    static let url = "https://abcdefghijklmnop.supabase.co"
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 
 5. Assurez-vous d'avoir configuré les tables nécessaires (voir README.md)
 
 ⚠️ SÉCURITÉ:
 - Ne commitez jamais vos vraies clés dans un repository public
 - Utilisez des variables d'environnement en production
 - Activez Row Level Security (RLS) sur Supabase
 */