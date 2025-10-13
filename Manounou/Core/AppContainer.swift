//
//  AppContainer.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation
import SwiftUI
import Supabase
import UserNotifications

/// Container principal pour l'injection de dépendances
@MainActor
class AppContainer: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = AppContainer()
    
    // MARK: - Services
    let supabaseClient: SupabaseClient
    let authService: AuthServiceProtocol
    let cacheService: CacheService
    let eventsService: EventsService
    let childrenService: ChildrenService
    let documentsService: DocumentsService
    
    // MARK: - ViewModels
    
    @Published var authViewModel: AuthViewModel
    @Published var eventsViewModel: EventsViewModel
    @Published var childrenViewModel: ChildrenViewModel
    @Published var documentsViewModel: DocumentsViewModel
    @Published var notificationManager: NotificationManager
    
    // MARK: - Configuration
    
    private let isTestMode: Bool
    
    // MARK: - Initialization
    
    private init(isTestMode: Bool = false) {
        self.isTestMode = isTestMode
        
        // Configuration Supabase
        self.supabaseClient = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey
        )
        
        // Initialisation des services
        self.cacheService = CacheService.shared
        if isTestMode {
            self.authService = MockAuthService()
            self.eventsService = EventsService(supabaseClient: supabaseClient, cacheService: cacheService)
            self.childrenService = ChildrenService(supabaseClient: supabaseClient, cacheService: cacheService)
            self.documentsService = DocumentsService(supabaseClient: supabaseClient, cacheService: cacheService)
        } else {
            self.authService = AuthService(supabaseClient: supabaseClient)
            self.eventsService = EventsService(supabaseClient: supabaseClient, cacheService: cacheService)
            self.childrenService = ChildrenService(supabaseClient: supabaseClient, cacheService: cacheService)
            self.documentsService = DocumentsService(supabaseClient: supabaseClient, cacheService: cacheService)
        }
        
        // Initialisation des ViewModels avec injection de dépendances
        self.authViewModel = AuthViewModel(authService: authService)
        self.eventsViewModel = EventsViewModel(eventsService: eventsService)
        self.childrenViewModel = ChildrenViewModel(childrenService: childrenService)
        self.documentsViewModel = DocumentsViewModel(documentsService: documentsService)
        self.notificationManager = NotificationManager()
    }
    
    // MARK: - Factory Methods for Testing
    
    static func createForTesting() -> AppContainer {
        return AppContainer(isTestMode: true)
    }
    
    static func createForProduction() -> AppContainer {
        return AppContainer(isTestMode: false)
    }
    
    // MARK: - Lifecycle Methods
    
    func initialize() async {
        // Initialisation asynchrone des services
        await authViewModel.checkAuthenticationStatus()
        
        // Chargement initial des données si l'utilisateur est connecté
        if authViewModel.isAuthenticated {
            await loadInitialData()
        }
    }
    
    private func loadInitialData() async {
        async let eventsTask = eventsViewModel.loadEvents()
        async let childrenTask = childrenViewModel.loadChildren()
        async let documentsTask = documentsViewModel.loadDocuments()
        
        // Attendre que toutes les tâches se terminent
        await eventsTask
        await childrenTask
        await documentsTask
    }
    
    // MARK: - Authentication State Management
    
    func handleAuthenticationChange() async {
        if authViewModel.isAuthenticated {
            await loadInitialData()
        } else {
            clearUserData()
        }
    }
    
    private func clearUserData() {
        eventsViewModel.clearEvents()
        childrenViewModel.clearChildren()
        cacheService.clearCache()
    }
}

// MARK: - ViewModels with Dependency Injection

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var userProfile: UserProfile?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signIn(email: email, password: password)
            currentUser = user
            isAuthenticated = true
            // Convert User to UserProfile for compatibility
            userProfile = UserProfile(
                id: user.id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                avatarUrl: user.avatarUrl,
                createdAt: user.createdAt,
                updatedAt: user.updatedAt
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signUp(email: email, password: password)
            currentUser = user
            isAuthenticated = true
            // Convert User to UserProfile for compatibility
            userProfile = UserProfile(
                id: user.id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                avatarUrl: user.avatarUrl,
                createdAt: user.createdAt,
                updatedAt: user.updatedAt
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        
        do {
            try await authService.signOut()
            currentUser = nil
            userProfile = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func checkAuthenticationStatus() async {
        do {
            let user = try await authService.getCurrentUser()
            currentUser = user
            isAuthenticated = user != nil
            // Convert User to UserProfile for compatibility
            if let user = user {
                userProfile = UserProfile(
                    id: user.id,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    email: user.email,
                    avatarUrl: user.avatarUrl,
                    createdAt: user.createdAt,
                    updatedAt: user.updatedAt
                )
            } else {
                userProfile = nil
            }
        } catch {
            currentUser = nil
            userProfile = nil
            isAuthenticated = false
        }
    }
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.resetPassword(email: email)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateProfile(firstName: String, lastName: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Implement actual profile update with Supabase
            // For now, simulate a successful update
            if let currentUser = currentUser {
                let updatedUser = User(
                    id: currentUser.id,
                    email: currentUser.email,
                    firstName: firstName,
                    lastName: lastName,
                    avatarUrl: currentUser.avatarUrl,
                    createdAt: currentUser.createdAt,
                    updatedAt: Date()
                )
                
                self.currentUser = updatedUser
                
                // Update userProfile for compatibility
                self.userProfile = UserProfile(
                    id: updatedUser.id,
                    firstName: updatedUser.firstName,
                    lastName: updatedUser.lastName,
                    email: updatedUser.email,
                    avatarUrl: updatedUser.avatarUrl,
                    createdAt: updatedUser.createdAt,
                    updatedAt: updatedUser.updatedAt
                )
            }
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
}

@MainActor
class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let eventsService: EventsService
    
    var todayEvents: [Event] {
        events.filter { Calendar.current.isDateInToday($0.startDate) }
    }
    
    init(eventsService: EventsService) {
        self.eventsService = eventsService
    }
    
    func loadEvents() async {
        isLoading = true
        errorMessage = nil
        
        do {
            events = try await eventsService.fetchEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createEvent(_ event: Event) async {
        do {
            let newEvent = try await eventsService.createEvent(event)
            await loadEvents() // Reload to get updated list
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateEvent(_ event: Event) async {
        do {
            _ = try await eventsService.updateEvent(event)
            await loadEvents() // Reload to get updated list
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteEvent(_ event: Event) async {
        do {
            try await eventsService.deleteEvent(id: event.id)
            await loadEvents() // Reload to get updated list
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func clearEvents() {
        events.removeAll()
    }
    
    func clearError() {
        errorMessage = nil
    }
}

@MainActor
class ChildrenViewModel: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let childrenService: ChildrenService
    
    init(childrenService: ChildrenService) {
        self.childrenService = childrenService
    }
    
    func loadChildren() async {
        isLoading = true
        errorMessage = nil
        
        do {
            children = try await childrenService.fetchChildren()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createChild(_ child: Child) async {
        do {
            let newChild = try await childrenService.createChild(child)
            await loadChildren() // Reload to get updated list
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateChild(_ child: Child) async {
        do {
            _ = try await childrenService.updateChild(child)
            await loadChildren() // Reload to get updated list
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteChild(_ child: Child) async {
        do {
            try await childrenService.deleteChild(id: child.id)
            await loadChildren() // Reload to get updated list
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func clearChildren() {
        children.removeAll()
    }
    
    func clearError() {
        errorMessage = nil
    }
}

@MainActor
class DocumentsViewModel: ObservableObject {
    @Published var documents: [Document] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let documentsService: DocumentsService
    
    init(documentsService: DocumentsService) {
        self.documentsService = documentsService
    }
    
    func loadDocuments() async {
        isLoading = true
        errorMessage = nil
        
        do {
            documents = try await documentsService.fetchDocuments()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createDocument(_ document: Document) async {
        do {
            let newDocument = try await documentsService.createDocument(document)
            await loadDocuments() // Reload to get updated list
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateDocument(_ document: Document) async {
        do {
            _ = try await documentsService.updateDocument(document)
            await loadDocuments() // Reload to get updated list
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteDocument(_ document: Document) async {
        do {
            try await documentsService.deleteDocument(id: document.id)
            await loadDocuments() // Reload to get updated list
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func clearDocuments() {
        documents.removeAll()
    }
    
    func clearError() {
        errorMessage = nil
    }
}

@MainActor
class NotificationManager: ObservableObject {
    @Published var hasNotifications = false
    @Published var notificationCount = 0
    
    init() {
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.hasNotifications = granted
            }
        }
    }
    
    func scheduleNotification(title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}