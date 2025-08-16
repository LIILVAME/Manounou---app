//
//  EventsService.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation
import Supabase

class EventsService: EventsServiceProtocol, ObservableObject {
    private let supabaseClient: SupabaseClient
    private let cacheService: CacheServiceProtocol
    
    init(supabaseClient: SupabaseClient, cacheService: CacheServiceProtocol) {
        self.supabaseClient = supabaseClient
        self.cacheService = cacheService
    }
    
    // MARK: - Events Management
    
    func fetchEvents() async throws -> [Event] {
        do {
            let response: [EventDTO] = try await supabaseClient
                .from("events")
                .select()
                .execute()
                .value
            
            let events = response.map { $0.toEvent() }
            cacheService.cacheEvents(events)
            
            return events
        } catch {
            // Fallback to cache if network fails
            if let cachedEvents = cacheService.getCachedEvents() {
                return cachedEvents
            }
            throw ServiceError.networkError("Impossible de récupérer les événements: \(error.localizedDescription)")
        }
    }
    
    func createEvent(_ event: Event) async throws -> Event {
        do {
            let eventDTO = EventDTO.from(event)
            let response: EventDTO = try await supabaseClient
                .from("events")
                .insert(eventDTO)
                .select()
                .single()
                .execute()
                .value
            
            return response.toEvent()
        } catch {
            throw ServiceError.networkError("Impossible de créer l'événement: \(error.localizedDescription)")
        }
    }
    
    func updateEvent(_ event: Event) async throws -> Event {
        do {
            let eventDTO = EventDTO.from(event)
            let response: EventDTO = try await supabaseClient
                .from("events")
                .update(eventDTO)
                .eq("id", value: event.id)
                .select()
                .single()
                .execute()
                .value
            
            return response.toEvent()
        } catch {
            throw ServiceError.networkError("Impossible de mettre à jour l'événement: \(error.localizedDescription)")
        }
    }
    
    func deleteEvent(id: UUID) async throws {
        do {
            try await supabaseClient
                .from("events")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            throw ServiceError.networkError("Impossible de supprimer l'événement: \(error.localizedDescription)")
        }
    }
    
    func fetchEventsForChild(childId: UUID) async throws -> [Event] {
        do {
            let response: [EventDTO] = try await supabaseClient
                .from("events")
                .select()
                .eq("child_id", value: childId)
                .execute()
                .value
            
            return response.map { $0.toEvent() }
        } catch {
            throw ServiceError.networkError("Impossible de récupérer les événements de l'enfant: \(error.localizedDescription)")
        }
    }
    
    func fetchEventsForDateRange(from: Date, to: Date) async throws -> [Event] {
        do {
            let response: [EventDTO] = try await supabaseClient
                .from("events")
                .select()
                .gte("start_date", value: from)
                .lte("end_date", value: to)
                .execute()
                .value
            
            return response.map { $0.toEvent() }
        } catch {
            throw ServiceError.networkError("Impossible de récupérer les événements pour la période: \(error.localizedDescription)")
        }
    }
}

// MARK: - Event Data Transfer Object

struct EventDTO: Codable {
    let id: UUID?
    let title: String
    let description: String?
    let startDate: Date
    let endDate: Date
    let childId: UUID?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case startDate = "start_date"
        case endDate = "end_date"
        case childId = "child_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    func toEvent() -> Event {
        return Event(
            id: id ?? UUID(),
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            childId: childId,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
    
    static func from(_ event: Event) -> EventDTO {
        return EventDTO(
            id: event.id,
            title: event.title,
            description: event.description,
            startDate: event.startDate,
            endDate: event.endDate,
            childId: event.childId,
            createdAt: event.createdAt,
            updatedAt: event.updatedAt
        )
    }
}

// MARK: - Mock Implementation for Testing

class MockEventsService: EventsServiceProtocol, ObservableObject {
    private var events: [Event] = []
    private var shouldFailRequests = false
    
    init(shouldFailRequests: Bool = false) {
        self.shouldFailRequests = shouldFailRequests
        self.events = Self.sampleEvents
    }
    
    func fetchEvents() async throws -> [Event] {
        if shouldFailRequests {
            throw ServiceError.networkError("Mock network failure")
        }
        
        try await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
        return events
    }
    
    func createEvent(_ event: Event) async throws -> Event {
        if shouldFailRequests {
            throw ServiceError.networkError("Mock creation failure")
        }
        
        let newEvent = Event(
            id: UUID(),
            title: event.title,
            description: event.description,
            startDate: event.startDate,
            endDate: event.endDate,
            childId: event.childId,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        events.append(newEvent)
        return newEvent
    }
    
    func updateEvent(_ event: Event) async throws -> Event {
        if shouldFailRequests {
            throw ServiceError.networkError("Mock update failure")
        }
        
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        }
        
        return event
    }
    
    func deleteEvent(id: UUID) async throws {
        if shouldFailRequests {
            throw ServiceError.networkError("Mock deletion failure")
        }
        
        events.removeAll { $0.id == id }
    }
    
    func fetchEventsForChild(childId: UUID) async throws -> [Event] {
        if shouldFailRequests {
            throw ServiceError.networkError("Mock fetch failure")
        }
        
        return events.filter { $0.childId == childId }
    }
    
    func fetchEventsForDateRange(from: Date, to: Date) async throws -> [Event] {
        if shouldFailRequests {
            throw ServiceError.networkError("Mock fetch failure")
        }
        
        return events.filter { event in
            event.startDate >= from && event.endDate <= to
        }
    }
    
    func setFailureMode(_ shouldFail: Bool) {
        self.shouldFailRequests = shouldFail
    }
    
    private static let sampleEvents: [Event] = [
        Event(
            id: UUID(),
            title: "Rendez-vous pédiatre",
            description: "Visite de contrôle mensuelle",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date(),
            childId: UUID(),
            createdAt: Date(),
            updatedAt: Date()
        ),
        Event(
            id: UUID(),
            title: "Vaccination",
            description: "Rappel vaccin ROR",
            startDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            childId: UUID(),
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
}