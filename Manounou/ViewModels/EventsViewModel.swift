//
//  EventsViewModel.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation
import SwiftUI
import Supabase

/// ViewModel pour la gestion des événements avec cache et optimisations
@MainActor
class EventsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedDate = Date()
    @Published var selectedEventType: EventType?
    
    // MARK: - Private Properties
    
    private let cacheService = CacheService.shared
    private let supabase = SupabaseClient(
        supabaseURL: AppConfig.Supabase.apiURL,
        supabaseKey: AppConfig.Supabase.anonKey
    )
    
    // MARK: - Computed Properties
    
    /// Événements pour la date sélectionnée
    var eventsForSelectedDate: [Event] {
        events.filter { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: selectedDate)
        }.sorted { $0.startDate < $1.startDate }
    }
    
    /// Événements d'aujourd'hui
    var todayEvents: [Event] {
        events.filter { $0.isToday }.sorted { $0.startDate < $1.startDate }
    }
    
    /// Événements en cours
    var ongoingEvents: [Event] {
        events.filter { $0.isOngoing }
    }
    
    /// Événements à venir (prochaines 24h)
    var upcomingEvents: [Event] {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return events.filter { event in
            event.isFuture && event.startDate < tomorrow
        }.sorted { $0.startDate < $1.startDate }
    }
    
    /// Événements groupés par date
    var groupedEvents: [Date: [Event]] {
        Dictionary(grouping: events) { event in
            Calendar.current.startOfDay(for: event.startDate)
        }
    }
    
    // MARK: - Initialization
    
    init() {
        loadCachedEvents()
    }
    
    // MARK: - Data Loading
    
    /// Charge les événements avec cache intelligent
    func loadEvents(forceRefresh: Bool = false) async {
        // Si on a des données en cache et qu'on ne force pas le refresh
        if !forceRefresh && !events.isEmpty && cacheService.isCacheValid() {
            return
        }
        
        // Charger depuis le cache d'abord pour une UX fluide
        if !forceRefresh {
            loadCachedEvents()
        }
        
        // Puis charger depuis l'API en arrière-plan
        await loadEventsFromAPI()
    }
    
    /// Charge les événements depuis le cache
    private func loadCachedEvents() {
        if let cachedEvents = cacheService.getCachedEvents() {
            self.events = cachedEvents
        }
    }
    
    /// Charge les événements depuis l'API
    private func loadEventsFromAPI() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Simulation d'appel API - À remplacer par l'appel Supabase réel
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 seconde
            
            #if DEBUG
            // Données de test en mode debug
            let loadedEvents = Event.sampleEvents
            #else
            // TODO: Implémenter l'appel Supabase réel
            let loadedEvents: [Event] = []
            #endif
            
            self.events = loadedEvents
            
            // Mettre en cache les nouvelles données
            cacheService.cacheEvents(loadedEvents)
            
        } catch {
            self.errorMessage = "Erreur lors du chargement des événements: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Event Management
    
    /// Ajoute un nouvel événement
    func addEvent(_ event: Event) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Implémenter l'ajout via Supabase
            
            // Mise à jour locale immédiate pour une UX fluide
            events.append(event)
            events.sort { $0.startDate < $1.startDate }
            
            // Mettre à jour le cache
            cacheService.cacheEvents(events)
            
        } catch {
            // Retirer l'événement en cas d'erreur
            events.removeAll { $0.id == event.id }
            errorMessage = "Erreur lors de l'ajout de l'événement: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Met à jour un événement existant
    func updateEvent(_ event: Event) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Implémenter la mise à jour via Supabase
            
            // Mise à jour locale immédiate
            if let index = events.firstIndex(where: { $0.id == event.id }) {
                events[index] = event
                events.sort { $0.startDate < $1.startDate }
            }
            
            // Mettre à jour le cache
            cacheService.cacheEvents(events)
            
        } catch {
            errorMessage = "Erreur lors de la mise à jour de l'événement: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Supprime un événement
    func deleteEvent(_ event: Event) async {
        isLoading = true
        errorMessage = nil
        
        // Sauvegarder l'événement pour le restaurer en cas d'erreur
        let eventToDelete = event
        let originalIndex = events.firstIndex(where: { $0.id == event.id })
        
        do {
            // Suppression locale immédiate
            events.removeAll { $0.id == event.id }
            
            // TODO: Implémenter la suppression via Supabase
            
            // Mettre à jour le cache
            cacheService.cacheEvents(events)
            
        } catch {
            // Restaurer l'événement en cas d'erreur
            if let index = originalIndex {
                events.insert(eventToDelete, at: min(index, events.count))
            } else {
                events.append(eventToDelete)
            }
            events.sort { $0.startDate < $1.startDate }
            
            errorMessage = "Erreur lors de la suppression de l'événement: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Filtering and Searching
    
    /// Filtre les événements par type
    func filterEvents(by eventType: EventType?) {
        selectedEventType = eventType
    }
    
    /// Événements filtrés selon le type sélectionné
    var filteredEvents: [Event] {
        guard let selectedType = selectedEventType else {
            return events
        }
        
        return events.filter { $0.eventType.id == selectedType.id }
    }
    
    /// Recherche d'événements par titre
    func searchEvents(query: String) -> [Event] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return events
        }
        
        return events.filter { event in
            event.title.localizedCaseInsensitiveContains(query) ||
            (event.description?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
    
    // MARK: - Date Navigation
    
    /// Navigue vers la date précédente
    func navigateToPreviousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }
    
    /// Navigue vers la date suivante
    func navigateToNextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }
    
    /// Navigue vers aujourd'hui
    func navigateToToday() {
        selectedDate = Date()
    }
    
    // MARK: - Error Handling
    
    /// Efface le message d'erreur
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Refresh
    
    /// Actualise les données
    func refresh() async {
        await loadEvents(forceRefresh: true)
    }
}

// MARK: - Event Statistics

extension EventsViewModel {
    
    /// Statistiques des événements
    var eventStatistics: EventStatistics {
        EventStatistics(
            totalEvents: events.count,
            todayEvents: todayEvents.count,
            upcomingEvents: upcomingEvents.count,
            ongoingEvents: ongoingEvents.count,
            eventsByType: Dictionary(grouping: events, by: { $0.eventType.name })
                .mapValues { $0.count }
        )
    }
}

struct EventStatistics {
    let totalEvents: Int
    let todayEvents: Int
    let upcomingEvents: Int
    let ongoingEvents: Int
    let eventsByType: [String: Int]
}