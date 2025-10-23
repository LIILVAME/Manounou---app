//
//  ErrorHandling.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI
import Foundation

// MARK: - Error State Management

@MainActor
class ErrorStateManager: ObservableObject {
    @Published var currentError: AppError?
    @Published var isShowingError: Bool = false
    
    func showError(_ error: Error) {
        if let appError = error as? AppError {
            currentError = appError
        } else if let serviceError = error as? ServiceError {
            currentError = AppError.from(serviceError)
        } else {
            currentError = AppError.unknown(error.localizedDescription)
        }
        isShowingError = true
    }
    
    func clearError() {
        currentError = nil
        isShowingError = false
    }
}

// MARK: - App Error Types

enum AppError: LocalizedError, Identifiable {
    case network(NetworkError)
    case authentication(AuthError)
    case validation(ValidationError)
    case cache(CacheError)
    case unknown(String)
    
    var id: String {
        switch self {
        case .network(let error): return "network_\(error.code)"
        case .authentication(let error): return "auth_\(error.code)"
        case .validation(let error): return "validation_\(error.field)"
        case .cache(let error): return "cache_\(error.operation)"
        case .unknown(let message): return "unknown_\(message.hashValue)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .network(let error): return error.message
        case .authentication(let error): return error.message
        case .validation(let error): return error.message
        case .cache(let error): return error.message
        case .unknown(let message): return message
        }
    }
    
    var failureReason: String? {
        switch self {
        case .network(let error): return error.reason
        case .authentication(let error): return error.reason
        case .validation(let error): return error.reason
        case .cache(let error): return error.reason
        case .unknown: return "Une erreur inattendue s'est produite"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .network(let error): return error.recoverySuggestion
        case .authentication(let error): return error.recoverySuggestion
        case .validation(let error): return error.recoverySuggestion
        case .cache(let error): return error.recoverySuggestion
        case .unknown: return "Redémarrez l'application ou contactez le support"
        }
    }
    
    var severity: ErrorSeverity {
        switch self {
        case .network(let error): return error.severity
        case .authentication(let error): return error.severity
        case .validation: return .warning
        case .cache: return .info
        case .unknown: return .critical
        }
    }
    
    var icon: String {
        switch severity {
        case .info: return AppTheme.Icons.info
        case .warning: return AppTheme.Icons.warning
        case .error: return AppTheme.Icons.error
        case .critical: return AppTheme.Icons.error
        }
    }
    
    var color: Color {
        switch severity {
        case .info: return AppTheme.Colors.info
        case .warning: return AppTheme.Colors.warning
        case .error: return AppTheme.Colors.error
        case .critical: return AppTheme.Colors.error
        }
    }
    
    static func from(_ serviceError: ServiceError) -> AppError {
        switch serviceError {
        case .networkError(let message):
            return .network(NetworkError.connectionFailed(message))
        case .authenticationError(let message):
            return .authentication(AuthError.invalidCredentials(message))
        case .validationError(let message):
            return .validation(ValidationError.invalidInput("general", message))
        case .cacheError(let message):
            return .cache(CacheError.readFailed(message))
        case .unknownError(let message):
            return .unknown(message)
        }
    }
}

// MARK: - Specific Error Types

enum NetworkError {
    case noConnection
    case timeout
    case serverError(Int)
    case connectionFailed(String)
    case invalidResponse
    
    var code: String {
        switch self {
        case .noConnection: return "NO_CONNECTION"
        case .timeout: return "TIMEOUT"
        case .serverError(let code): return "SERVER_\(code)"
        case .connectionFailed: return "CONNECTION_FAILED"
        case .invalidResponse: return "INVALID_RESPONSE"
        }
    }
    
    var message: String {
        switch self {
        case .noConnection:
            return "Aucune connexion internet"
        case .timeout:
            return "Délai d'attente dépassé"
        case .serverError(let code):
            return "Erreur serveur (\(code))"
        case .connectionFailed(let details):
            return "Connexion échouée: \(details)"
        case .invalidResponse:
            return "Réponse invalide du serveur"
        }
    }
    
    var reason: String {
        switch self {
        case .noConnection:
            return "Votre appareil n'est pas connecté à internet"
        case .timeout:
            return "Le serveur met trop de temps à répondre"
        case .serverError:
            return "Le serveur rencontre des difficultés"
        case .connectionFailed:
            return "Impossible d'établir une connexion avec le serveur"
        case .invalidResponse:
            return "Le serveur a renvoyé des données incorrectes"
        }
    }
    
    var recoverySuggestion: String {
        switch self {
        case .noConnection:
            return "Vérifiez votre connexion Wi-Fi ou données mobiles"
        case .timeout:
            return "Réessayez dans quelques instants"
        case .serverError:
            return "Réessayez plus tard ou contactez le support"
        case .connectionFailed:
            return "Vérifiez votre connexion et réessayez"
        case .invalidResponse:
            return "Redémarrez l'application"
        }
    }
    
    var severity: ErrorSeverity {
        switch self {
        case .noConnection: return .warning
        case .timeout: return .warning
        case .serverError: return .error
        case .connectionFailed: return .error
        case .invalidResponse: return .critical
        }
    }
}

enum AuthError {
    case invalidCredentials(String)
    case sessionExpired
    case accountLocked
    case emailNotVerified
    case weakPassword
    
    var code: String {
        switch self {
        case .invalidCredentials: return "INVALID_CREDENTIALS"
        case .sessionExpired: return "SESSION_EXPIRED"
        case .accountLocked: return "ACCOUNT_LOCKED"
        case .emailNotVerified: return "EMAIL_NOT_VERIFIED"
        case .weakPassword: return "WEAK_PASSWORD"
        }
    }
    
    var message: String {
        switch self {
        case .invalidCredentials(let details):
            return "Identifiants incorrects: \(details)"
        case .sessionExpired:
            return "Session expirée"
        case .accountLocked:
            return "Compte verrouillé"
        case .emailNotVerified:
            return "Email non vérifié"
        case .weakPassword:
            return "Mot de passe trop faible"
        }
    }
    
    var reason: String {
        switch self {
        case .invalidCredentials:
            return "L'email ou le mot de passe est incorrect"
        case .sessionExpired:
            return "Votre session a expiré pour des raisons de sécurité"
        case .accountLocked:
            return "Votre compte a été temporairement verrouillé"
        case .emailNotVerified:
            return "Vous devez vérifier votre adresse email"
        case .weakPassword:
            return "Le mot de passe ne respecte pas les critères de sécurité"
        }
    }
    
    var recoverySuggestion: String {
        switch self {
        case .invalidCredentials:
            return "Vérifiez vos identifiants ou réinitialisez votre mot de passe"
        case .sessionExpired:
            return "Reconnectez-vous à votre compte"
        case .accountLocked:
            return "Contactez le support ou attendez avant de réessayer"
        case .emailNotVerified:
            return "Vérifiez votre boîte mail et cliquez sur le lien de confirmation"
        case .weakPassword:
            return "Choisissez un mot de passe plus complexe"
        }
    }
    
    var severity: ErrorSeverity {
        switch self {
        case .invalidCredentials: return .warning
        case .sessionExpired: return .warning
        case .accountLocked: return .error
        case .emailNotVerified: return .warning
        case .weakPassword: return .warning
        }
    }
}

enum ValidationError {
    case invalidInput(String, String)
    case missingRequired(String)
    case formatError(String, String)
    case rangeError(String, String)
    
    var field: String {
        switch self {
        case .invalidInput(let field, _): return field
        case .missingRequired(let field): return field
        case .formatError(let field, _): return field
        case .rangeError(let field, _): return field
        }
    }
    
    var message: String {
        switch self {
        case .invalidInput(_, let message): return message
        case .missingRequired(let field): return "Le champ \(field) est requis"
        case .formatError(let field, let format): return "Le champ \(field) doit respecter le format: \(format)"
        case .rangeError(let field, let range): return "Le champ \(field) doit être dans la plage: \(range)"
        }
    }
    
    var reason: String {
        switch self {
        case .invalidInput: return "La valeur saisie n'est pas valide"
        case .missingRequired: return "Cette information est obligatoire"
        case .formatError: return "Le format de la donnée est incorrect"
        case .rangeError: return "La valeur est en dehors des limites autorisées"
        }
    }
    
    var recoverySuggestion: String {
        switch self {
        case .invalidInput: return "Vérifiez la valeur saisie"
        case .missingRequired: return "Remplissez tous les champs obligatoires"
        case .formatError: return "Respectez le format demandé"
        case .rangeError: return "Choisissez une valeur dans la plage autorisée"
        }
    }
}

enum CacheError {
    case readFailed(String)
    case writeFailed(String)
    case corruptedData(String)
    case storageFull
    
    var operation: String {
        switch self {
        case .readFailed: return "read"
        case .writeFailed: return "write"
        case .corruptedData: return "corrupted"
        case .storageFull: return "storage_full"
        }
    }
    
    var message: String {
        switch self {
        case .readFailed(let details): return "Lecture du cache échouée: \(details)"
        case .writeFailed(let details): return "Écriture du cache échouée: \(details)"
        case .corruptedData(let details): return "Données corrompues: \(details)"
        case .storageFull: return "Espace de stockage insuffisant"
        }
    }
    
    var reason: String {
        switch self {
        case .readFailed: return "Impossible de lire les données en cache"
        case .writeFailed: return "Impossible de sauvegarder en cache"
        case .corruptedData: return "Les données en cache sont corrompues"
        case .storageFull: return "L'espace de stockage est plein"
        }
    }
    
    var recoverySuggestion: String {
        switch self {
        case .readFailed: return "Redémarrez l'application"
        case .writeFailed: return "Libérez de l'espace de stockage"
        case .corruptedData: return "Videz le cache dans les paramètres"
        case .storageFull: return "Supprimez des fichiers ou videz le cache"
        }
    }
}

// MARK: - Error Severity

enum ErrorSeverity {
    case info
    case warning
    case error
    case critical
}

// MARK: - Error Views

struct AppErrorView: View {
    let error: AppError
    let onRetry: (() -> Void)?
    let onDismiss: () -> Void
    
    init(error: AppError, onRetry: (() -> Void)? = nil, onDismiss: @escaping () -> Void) {
        self.error = error
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Icon
            Image(systemName: error.icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(error.color)
            
            // Content
            VStack(spacing: AppTheme.Spacing.md) {
                Text(error.errorDescription ?? "Erreur")
                    .font(AppTheme.Typography.title3)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                if let reason = error.failureReason {
                    Text(reason)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(AppTheme.Typography.callout)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Actions
            VStack(spacing: AppTheme.Spacing.sm) {
                if let onRetry = onRetry {
                    Button("Réessayer") {
                        onRetry()
                    }
                    .themedButton(style: .primary)
                }
                
                Button("Fermer") {
                    onDismiss()
                }
                .themedButton(style: .tertiary)
            }
        }
        .padding(AppTheme.Spacing.xl)
        .themedCard()
        .padding(AppTheme.Spacing.lg)
    }
}

struct InlineErrorView: View {
    let error: AppError
    let onRetry: (() -> Void)?
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: error.icon)
                .foregroundColor(error.color)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(error.errorDescription ?? "Erreur")
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(AppTheme.Typography.footnote)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            if let onRetry = onRetry {
                Button("Réessayer") {
                    onRetry()
                }
                .font(AppTheme.Typography.footnote)
                .foregroundColor(error.color)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(error.color.opacity(0.1))
        .cornerRadius(AppTheme.CornerRadius.sm)
    }
}

struct ErrorBanner: View {
    let error: AppError
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: error.icon)
                .foregroundColor(.white)
            
            Text(error.errorDescription ?? "Erreur")
                .font(AppTheme.Typography.callout)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(error.color)
        .cornerRadius(AppTheme.CornerRadius.sm)
    }
}

// MARK: - Error Handling Extensions

extension View {
    func errorAlert(errorManager: ErrorStateManager) -> some View {
        self.alert(
            "Erreur",
            isPresented: Binding(get: { errorManager.isShowingError }, set: { errorManager.isShowingError = $0 }),
            presenting: errorManager.currentError
        ) { error in
            Button("OK") {
                errorManager.clearError()
            }
        } message: { error in
            Text(error.errorDescription ?? "Une erreur s'est produite")
        }
    }
    
    func errorSheet(errorManager: ErrorStateManager, onRetry: (() -> Void)? = nil) -> some View {
        self.modifier(ErrorSheetModifier(errorManager: errorManager, onRetry: onRetry))
    }
}

struct ErrorSheetModifier: ViewModifier {
    @ObservedObject var errorManager: ErrorStateManager
    let onRetry: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $errorManager.isShowingError) {
                if let error = errorManager.currentError {
                    AppErrorView(
                        error: error,
                        onRetry: onRetry,
                        onDismiss: errorManager.clearError
                    )
                }
            }
    }
}