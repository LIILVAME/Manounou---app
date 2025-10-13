//
//  SecureConfig.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation

/// Configuration sécurisée pour les clés API et secrets
struct SecureConfig {
    
    // MARK: - Supabase Configuration
    
    /// URL Supabase sécurisée
    static var supabaseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let url = URL(string: urlString) else {
            // Fallback vers la configuration existante en développement
            #if DEBUG
            return Config.supabaseAPIURL
            #else
            fatalError("SUPABASE_URL manquante dans Info.plist")
            #endif
        }
        return url
    }
    
    /// Clé anonyme Supabase sécurisée
    static var supabaseAnonKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            // Fallback vers la configuration existante en développement
            #if DEBUG
            return Config.supabaseAnonKey
            #else
            fatalError("SUPABASE_ANON_KEY manquante dans Info.plist")
            #endif
        }
        return key
    }
    
    // MARK: - Environment Detection
    
    /// Détecte l'environnement actuel
    static var currentEnvironment: Environment {
        #if DEBUG
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }
    
    enum Environment {
        case development
        case staging
        case production
        
        var isProduction: Bool {
            return self == .production
        }
        
        var isDevelopment: Bool {
            return self == .development
        }
        
        var displayName: String {
            switch self {
            case .development: return "Développement"
            case .staging: return "Test"
            case .production: return "Production"
            }
        }
    }
    
    // MARK: - Security Validation
    
    /// Valide la configuration de sécurité
    static func validateSecurityConfiguration() {
        guard currentEnvironment.isProduction else {
            // En développement, on peut être plus permissif
            return
        }
        
        // En production, vérifier que les clés ne sont pas hardcodées
        let anonKey = supabaseAnonKey
        
        // Vérifier que la clé n'est pas la clé de développement hardcodée
        let developmentKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
        if anonKey.hasPrefix(developmentKey) {
            assertionFailure("⚠️ SÉCURITÉ: Clé de développement détectée en production!")
        }
        
        // Vérifier que l'URL n'est pas localhost
        let urlString = supabaseURL.absoluteString
        if urlString.contains("localhost") || urlString.contains("127.0.0.1") {
            assertionFailure("⚠️ SÉCURITÉ: URL localhost détectée en production!")
        }
    }
    
    // MARK: - Headers sécurisés
    
    /// Headers HTTP sécurisés
    static var secureHeaders: [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "User-Agent": "\(Config.App.name)/\(Config.App.version)",
            "apikey": supabaseAnonKey
        ]
        
        // Ajouter des headers de sécurité en production
        if currentEnvironment.isProduction {
            headers["X-Environment"] = "production"
            headers["X-App-Version"] = Config.App.version
        }
        
        return headers
    }
}

// MARK: - Migration Helper

/// Helper pour migrer depuis l'ancienne configuration
extension SecureConfig {
    
    /// Vérifie si la migration de sécurité est nécessaire
    static var needsSecurityMigration: Bool {
        // Vérifier si les clés sont encore hardcodées dans AppConfig
        let hardcodedKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSI"
        return Config.supabaseAnonKey.hasPrefix(hardcodedKey)
    }
    
    /// Instructions pour la migration de sécurité
    static var migrationInstructions: String {
        """
        🔒 MIGRATION DE SÉCURITÉ REQUISE
        
        Pour sécuriser votre application, suivez ces étapes :
        
        1. Ouvrez Info.plist
        2. Ajoutez ces clés :
           - SUPABASE_URL: $(SUPABASE_URL)
           - SUPABASE_ANON_KEY: $(SUPABASE_ANON_KEY)
        
        3. Dans les Build Settings de Xcode :
           - Ajoutez SUPABASE_URL = https://votre-projet.supabase.co
           - Ajoutez SUPABASE_ANON_KEY = votre_clé_anonyme
        
        4. Supprimez les clés hardcodées de Config.swift
        
        5. Utilisez SecureConfig au lieu d'AppConfig.Supabase
        """
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension SecureConfig {
    
    /// Affiche les informations de configuration en mode debug
    static func printDebugInfo() {
        print("Configuration Manounou")
        print("Environment: \(currentEnvironment.displayName)")
        print("Supabase URL configurée")
        print("Anon Key: \(supabaseAnonKey.prefix(20))...")
        print("Migration needed: \(needsSecurityMigration)")
        
        if needsSecurityMigration {
            print("⚠️ Migration de sécurité requise")
        }
    }
}
#endif