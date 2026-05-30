//
//  Config.swift
//  Manounou
//
//  Created by Assistant on 2025-01-13.
//

import Foundation

// MARK: - Configuration de l'application
struct Config {
    
    // MARK: - Supabase Configuration
    // ✅ Configuration Supabase - Clés configurées
    // Dashboard Supabase : https://app.supabase.com/project/mdrodvshrxvspelmjrhu
    //
    // NOTE SÉCURITÉ : la clé `anon` est PUBLIQUE par conception (embarquée dans
    // le client, protégée côté serveur par les politiques RLS). Ce n'est pas un
    // secret. Ne JAMAIS placer la clé `service_role` ici.

    static let supabaseURL = "https://mdrodvshrxvspelmjrhu.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kcm9kdnNocnh2c3BlbG1qcmh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAxMjc4NDEsImV4cCI6MjA5NTcwMzg0MX0.EKVHy5aLp_xCo4yyHpA9b1SVFuBmsWY8UK45CvIzuF4"
    
    // URL complète pour l'API
    static var supabaseAPIURL: URL {
        guard let url = URL(string: supabaseURL) else {
            fatalError("URL Supabase invalide: \(supabaseURL)")
        }
        return url
    }
    
    // MARK: - Supabase Tables
    struct Tables {
        static let children = "children"
        static let events = "events"
        static let documents = "documents"
        static let users = "users"
        static let families = "families"
        static let nannies = "nannies"
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
extension Config {
    
    /// Valide la configuration de l'application au démarrage
    static func validateConfiguration() {
        // Vérification de la configuration Supabase
        guard !supabaseURL.contains("your-project-ref") else {
            fatalError("❌ Configuration Supabase manquante! Veuillez configurer votre URL Supabase dans Config.swift")
        }
        
        guard !supabaseAnonKey.contains("your-anon-key") else {
            fatalError("❌ Clé Supabase manquante! Veuillez configurer votre clé anonyme dans Config.swift")
        }
        
        // Vérification de la validité de l'URL
        guard URL(string: supabaseURL) != nil else {
            fatalError("❌ URL Supabase invalide: \(supabaseURL)")
        }
        
        if Debug.enableLogging {
            print("✅ Configuration validée avec succès")
            print("🌍 Environnement: \(Environment.current)")
            print("🔗 URL Supabase configurée")
        }
    }
}

// MARK: - Helper Extensions
extension Config {
    
    /// Retourne les headers par défaut pour les requêtes API
    static var defaultHeaders: [String: String] {
        return [
            "Content-Type": "application/json",
            "User-Agent": "\(App.name)/\(App.version)",
            "apikey": supabaseAnonKey
        ]
    }
    
    /// Retourne l'URL complète pour un endpoint donné
    static func apiURL(for endpoint: String) -> URL {
        return supabaseAPIURL.appendingPathComponent(endpoint)
    }
}

// MARK: - Configuration pour différents environnements
#if DEBUG
extension Config {
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