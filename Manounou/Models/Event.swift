//
//  Event.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation
import SwiftUI

// MARK: - Event Model

struct Event: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var description: String?
    var startDate: Date
    var endDate: Date
    var isAllDay: Bool
    var eventType: EventType
    var childrenIds: [UUID]
    var hasReminder: Bool
    var reminderTime: ReminderTime?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = false,
        eventType: EventType,
        childrenIds: [UUID] = [],
        hasReminder: Bool = false,
        reminderTime: ReminderTime? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.eventType = eventType
        self.childrenIds = childrenIds
        self.hasReminder = hasReminder
        self.reminderTime = reminderTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Event Type

struct EventType: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    let color: Color
    
    init(id: UUID = UUID(), name: String, icon: String, color: Color) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
    }
    
    // Codable conformance pour Color
    enum CodingKeys: String, CodingKey {
        case id, name, icon, colorData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        
        let colorData = try container.decode(Data.self, forKey: .colorData)
        if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            color = Color(uiColor)
        } else {
            color = .blue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        
        let uiColor = UIColor(color)
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
        try container.encode(colorData, forKey: .colorData)
    }
}

// MARK: - Reminder Time

enum ReminderTime: String, CaseIterable, Codable {
    case fiveMinutes = "5min"
    case fifteenMinutes = "15min"
    case thirtyMinutes = "30min"
    case oneHour = "1h"
    case twoHours = "2h"
    case oneDay = "1j"
    
    var displayName: String {
        switch self {
        case .fiveMinutes: return "5 minutes avant"
        case .fifteenMinutes: return "15 minutes avant"
        case .thirtyMinutes: return "30 minutes avant"
        case .oneHour: return "1 heure avant"
        case .twoHours: return "2 heures avant"
        case .oneDay: return "1 jour avant"
        }
    }
    
    var timeInterval: TimeInterval {
        switch self {
        case .fiveMinutes: return -5 * 60
        case .fifteenMinutes: return -15 * 60
        case .thirtyMinutes: return -30 * 60
        case .oneHour: return -60 * 60
        case .twoHours: return -2 * 60 * 60
        case .oneDay: return -24 * 60 * 60
        }
    }
}

// MARK: - Event Type Presets

extension EventType {
    
    static let defaultTypes: [EventType] = [
        EventType(name: "Rendez-vous médical", icon: "stethoscope", color: .red),
        EventType(name: "École", icon: "book", color: .blue),
        EventType(name: "Activité", icon: "figure.run", color: .green),
        EventType(name: "Repas", icon: "fork.knife", color: .orange),
        EventType(name: "Sommeil", icon: "bed.double", color: .purple),
        EventType(name: "Jeu", icon: "gamecontroller", color: .pink),
        EventType(name: "Sortie", icon: "car", color: .cyan),
        EventType(name: "Famille", icon: "house", color: .brown),
        EventType(name: "Autre", icon: "circle", color: .gray)
    ]
}

// MARK: - Event Extensions

extension Event {
    
    /// Durée de l'événement en minutes
    var durationInMinutes: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }
    
    /// Vérifie si l'événement est aujourd'hui
    var isToday: Bool {
        Calendar.current.isDateInToday(startDate)
    }
    
    /// Vérifie si l'événement est en cours
    var isOngoing: Bool {
        let now = Date()
        return startDate <= now && now <= endDate
    }
    
    /// Vérifie si l'événement est passé
    var isPast: Bool {
        endDate < Date()
    }
    
    /// Vérifie si l'événement est futur
    var isFuture: Bool {
        startDate > Date()
    }
    
    /// Texte formaté pour la durée
    var durationText: String {
        DateFormatters.durationText(from: startDate, to: endDate)
    }
    
    /// Texte formaté pour l'heure
    var timeText: String {
        if isAllDay {
            return "Toute la journée"
        } else {
            let start = DateFormatters.timeFormatter.string(from: startDate)
            let end = DateFormatters.timeFormatter.string(from: endDate)
            return "\(start) - \(end)"
        }
    }
}

// MARK: - Sample Data

#if DEBUG
extension Event {
    
    static let sampleEvents: [Event] = [
        Event(
            title: "Rendez-vous pédiatre",
            description: "Visite de contrôle annuelle",
            startDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date(),
            eventType: EventType.defaultTypes[0],
            hasReminder: true,
            reminderTime: .thirtyMinutes
        ),
        Event(
            title: "École maternelle",
            startDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.date(byAdding: .hour, value: 6, to: Date()) ?? Date()) ?? Date(),
            eventType: EventType.defaultTypes[1]
        ),
        Event(
            title: "Cours de natation",
            description: "Piscine municipale",
            startDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 2, to: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()) ?? Date(),
            eventType: EventType.defaultTypes[2]
        )
    ]
}
#endif