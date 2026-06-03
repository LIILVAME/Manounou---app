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
    let profilesService: ProfilesService
    let planningScheduleService: PlanningScheduleService
    let householdService: HouseholdService
    let plansService: PlansService

    // MARK: - ViewModels

    @Published var authViewModel: AuthViewModel
    @Published var eventsViewModel: EventsViewModel
    @Published var childrenViewModel: ChildrenViewModel
    @Published var documentsViewModel: DocumentsViewModel
    @Published var notificationManager: NotificationManager
    @Published var planningScheduleViewModel: PlanningScheduleViewModel
    @Published var householdViewModel: HouseholdViewModel
    @Published var plansConfig: [String: PlanConfigDTO] = [:]
    
    // MARK: - Configuration
    
    private let isTestMode: Bool
    
    // MARK: - Initialization
    
    private init(isTestMode: Bool = false) {
        self.isTestMode = isTestMode
        
        // Configuration Supabase
        self.supabaseClient = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey,
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    autoRefreshToken: true
                )
            )
        )
        
        // Initialisation des services
        self.cacheService = CacheService.shared
        self.profilesService = ProfilesService(supabaseClient: supabaseClient)
        self.planningScheduleService = PlanningScheduleService(supabaseClient: supabaseClient)
        self.householdService = HouseholdService(supabaseClient: supabaseClient)
        self.plansService = PlansService(supabaseClient: supabaseClient)
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
        self.planningScheduleViewModel = PlanningScheduleViewModel(service: planningScheduleService)
        self.householdViewModel = HouseholdViewModel(service: householdService)
        setupAuthStateListener()
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
        let timer = PerformanceTimer("Initial preload")
        // Précharger depuis le cache pour un rendu immédiat
        if let cachedEvents = cacheService.getCachedEvents() {
            eventsViewModel.events = cachedEvents
            Logger.dataLoad("cached events", count: cachedEvents.count)
        }
        if let cachedChildren = cacheService.getCachedChildren() {
            childrenViewModel.children = cachedChildren
            Logger.dataLoad("cached children", count: cachedChildren.count)
        }
        if let cachedDocuments = cacheService.getCachedDocuments() {
            documentsViewModel.documents = cachedDocuments
            Logger.dataLoad("cached documents", count: cachedDocuments.count)
        }

        // Charger le profil Supabase (role, plan, plan_status, nom) + données dépendantes
        if let supabaseUser = try? await supabaseClient.auth.user() {
            let userId = supabaseUser.id
            planningScheduleViewModel.configure(userId: userId)
            householdViewModel.configure(userId: userId)

            if let profile = try? await profilesService.fetchProfile(userId: userId) {
                let fallback = authViewModel.currentUser ?? User(
                    id: userId,
                    email: supabaseUser.email ?? "",
                    firstName: supabaseUser.email?.components(separatedBy: "@").first?.capitalized ?? "Utilisateur",
                    lastName: ""
                )
                authViewModel.currentUser = profile.applyTo(fallback)
            }
        }

        // Chargement réseau concurrent pour rafraîchir les données
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [self] in await self.eventsViewModel.loadEvents() }
            group.addTask { [self] in await self.childrenViewModel.loadChildren() }
            group.addTask { [self] in await self.documentsViewModel.loadDocuments() }
            group.addTask { [self] in await self.planningScheduleViewModel.loadSchedule() }
            group.addTask { [self] in await self.householdViewModel.loadMembers() }
            group.addTask { [self] in
                if let configs = try? await self.plansService.fetchAllPlans() {
                    await MainActor.run { self.plansConfig = configs }
                }
            }
            await group.waitForAll()
        }
        timer.end(extra: "network refreshed")
    }

    private func setupAuthStateListener() {
        Task {
            for await state in supabaseClient.auth.authStateChanges {
                switch state.event {
                case .initialSession, .signedIn, .signedOut:
                    await MainActor.run {
                        self.authViewModel.isAuthenticated = state.session != nil
                    }
                    await self.handleAuthenticationChange()
                default:
                    break
                }
            }
        }
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
        documentsViewModel.clearDocuments()
        planningScheduleViewModel.clear()
        householdViewModel.clear()
        plansConfig = [:]
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
    // Added UI-bound fields
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isSignUpMode: Bool = false

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // Convenience wrappers used by AuthenticationView
    func toggleMode() {
        isSignUpMode.toggle()
        clearError()
    }

    func signIn() async {
        await signIn(email: email, password: password)
    }

    func signUp() async {
        await signUp(email: email, password: password)
    }

    func resetPassword() async {
        await resetPassword(email: email)
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
    
    func signInWithApple(idToken: String, nonce: String?) async {
        isLoading = true
        errorMessage = nil
        do {
            let user = try await authService.signInWithApple(idToken: idToken, nonce: nonce)
            currentUser = user
            isAuthenticated = true
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
    
    func updateProfile(firstName: String, lastName: String) async {
        isLoading = true
        errorMessage = nil
        
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
    
    private let eventsService: EventsServiceProtocol

    var todayEvents: [Event] {
        events.filter { Calendar.current.isDateInToday($0.startDate) }
    }

    init(eventsService: EventsServiceProtocol) {
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
            _ = try await eventsService.createEvent(event)
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
    
    private let childrenService: ChildrenServiceProtocol

    init(childrenService: ChildrenServiceProtocol) {
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
            _ = try await childrenService.createChild(child)
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
        await createDocument(document, fileData: nil, fileName: nil, mimeType: nil)
    }

    /// Crée un document en uploadant d'abord la pièce jointe optionnelle dans
    /// Supabase Storage (bucket privé `documents`). En cas de `fileData`, les
    /// champs `file_url` (= chemin de l'objet), `file_name`, `file_size` et
    /// `mime_type` sont renseignés avant l'insertion en base.
    func createDocument(_ document: Document, fileData: Data?, fileName: String?, mimeType: String?) async {
        isLoading = true
        errorMessage = nil
        var uploadedPath: String? = nil
        do {
            var toCreate = document
            if let fileData, let fileName {
                let path = try await documentsService.uploadFile(
                    data: fileData,
                    fileName: fileName,
                    mimeType: mimeType ?? "application/octet-stream"
                )
                uploadedPath = path
                toCreate.fileUrl = path
                toCreate.fileName = fileName
                toCreate.fileSize = fileData.count
                toCreate.mimeType = mimeType
            }
            _ = try await documentsService.createDocument(toCreate)
            await loadDocuments() // Reload to get updated list
        } catch {
            // Compensation : l'upload a réussi mais l'insertion a échoué →
            // on supprime l'objet Storage orphelin pour éviter une fuite.
            if let uploadedPath {
                try? await documentsService.deleteFile(url: uploadedPath)
            }
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// URL signée temporaire pour consulter la pièce jointe d'un document.
    func signedURL(for document: Document) async -> URL? {
        guard let path = document.fileUrl, !path.isEmpty else { return nil }
        do {
            return try await documentsService.signedURL(path: path)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func updateDocument(_ document: Document) async {
        await updateDocument(document, fileData: nil, fileName: nil, mimeType: nil)
    }

    /// Met à jour un document, en remplaçant la pièce jointe si `fileData` est
    /// fourni (upload du nouveau fichier puis suppression best-effort de l'ancien).
    func updateDocument(_ document: Document, fileData: Data?, fileName: String?, mimeType: String?) async {
        isLoading = true
        errorMessage = nil
        let oldPath = document.fileUrl
        var uploadedPath: String? = nil
        do {
            var toUpdate = document
            if let fileData, let fileName {
                let path = try await documentsService.uploadFile(
                    data: fileData,
                    fileName: fileName,
                    mimeType: mimeType ?? "application/octet-stream"
                )
                uploadedPath = path
                toUpdate.fileUrl = path
                toUpdate.fileName = fileName
                toUpdate.fileSize = fileData.count
                toUpdate.mimeType = mimeType
            }
            _ = try await documentsService.updateDocument(toUpdate)
            // Succès : supprimer best-effort l'ancien fichier remplacé.
            if uploadedPath != nil, let oldPath, !oldPath.isEmpty, oldPath != toUpdate.fileUrl {
                try? await documentsService.deleteFile(url: oldPath)
            }
            await loadDocuments() // Reload to get updated list
        } catch {
            // Compensation : l'upload du NOUVEAU fichier a réussi mais la mise à
            // jour a échoué → on supprime l'objet orphelin (l'ancien est conservé).
            if let uploadedPath {
                try? await documentsService.deleteFile(url: uploadedPath)
            }
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteDocument(_ document: Document) async {
        errorMessage = nil
        do {
            try await documentsService.deleteDocument(id: document.id)
            // Nettoyage best-effort de la pièce jointe (le row est déjà supprimé).
            if let path = document.fileUrl, !path.isEmpty {
                try? await documentsService.deleteFile(url: path)
            }
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
    
    init() {}
    
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

// MARK: - PlanningScheduleViewModel

@MainActor
class PlanningScheduleViewModel: ObservableObject {
    @Published var scheduleMode: Int    = 0
    @Published var activeDays: Set<Int> = [1, 2, 3, 4, 5]
    @Published var dropTime: String     = "09:00"
    @Published var pickTime: String     = "17:00"
    @Published var dropBy: String       = "Papa"
    @Published var pickBy: String       = "Maman"
    @Published var carerName: String    = "la nounou"
    @Published var isLoading: Bool      = false

    private let service: PlanningScheduleService
    private var userId: UUID?

    init(service: PlanningScheduleService) {
        self.service = service
    }

    func configure(userId: UUID) {
        self.userId = userId
    }

    func loadSchedule() async {
        guard let userId else { return }
        isLoading = true
        if let s = try? await service.fetchSchedule(userId: userId) {
            scheduleMode = s.scheduleMode
            activeDays   = s.activeDays
            dropTime     = s.dropTime
            pickTime     = s.pickTime
            dropBy       = s.dropBy
            pickBy       = s.pickBy
            carerName    = s.carerName
        }
        isLoading = false
    }

    func saveSchedule() async {
        guard let userId else { return }
        let schedule = PlanningSchedule(
            scheduleMode: scheduleMode,
            activeDays: activeDays,
            dropTime: dropTime,
            pickTime: pickTime,
            dropBy: dropBy,
            pickBy: pickBy,
            carerName: carerName
        )
        try? await service.upsertSchedule(schedule, userId: userId)
    }

    var currentSchedule: PlanningSchedule {
        PlanningSchedule(scheduleMode: scheduleMode, activeDays: activeDays,
                         dropTime: dropTime, pickTime: pickTime,
                         dropBy: dropBy, pickBy: pickBy, carerName: carerName)
    }

    func clear() {
        let d = PlanningSchedule.default
        scheduleMode = d.scheduleMode
        activeDays   = d.activeDays
        dropTime     = d.dropTime
        pickTime     = d.pickTime
        dropBy       = d.dropBy
        pickBy       = d.pickBy
        carerName    = d.carerName
        userId       = nil
    }
}

// MARK: - HouseholdViewModel

@MainActor
class HouseholdViewModel: ObservableObject {
    @Published var members: [HouseholdMember] = []
    @Published var isLoading: Bool = false

    private let service: HouseholdService
    private var userId: UUID?

    init(service: HouseholdService) {
        self.service = service
    }

    func configure(userId: UUID) {
        self.userId = userId
    }

    func loadMembers() async {
        guard let userId else { return }
        isLoading = true
        do {
            try await service.seedDefaultMembers(userId: userId)
            members = try await service.fetchMembers(userId: userId)
        } catch {
            // Keep existing on error
        }
        isLoading = false
    }

    var memberNames: [String] { members.map { $0.name } }

    func hexColor(for name: String) -> String {
        members.first { $0.name == name }?.color ?? "#7A5AE0"
    }

    func clear() {
        members = []
        userId  = nil
    }
}