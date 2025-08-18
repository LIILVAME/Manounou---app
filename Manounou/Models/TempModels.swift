//
//  TempModels.swift
//  Manounou
//
//  Created by Assistant on 18/08/2025.
//  Temporary models extracted from MainTabView for better organization
//

import SwiftUI
import Foundation

// MARK: - Temporary Child Model

struct TempChild: Identifiable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let birthDate: Date
    let gender: TempGender
    let notes: String?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    var formattedAge: String {
        let components = Calendar.current.dateComponents([.year, .month], from: birthDate, to: Date())
        let years = components.year ?? 0
        let months = components.month ?? 0
        
        if years == 0 {
            return "\(months) mois"
        } else if months == 0 {
            return "\(years) an\(years > 1 ? "s" : "")"
        } else {
            return "\(years) an\(years > 1 ? "s" : "") et \(months) mois"
        }
    }
}

enum TempGender: String, CaseIterable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .male: return "Garçon"
        case .female: return "Fille"
        case .other: return "Autre"
        }
    }
    
    var color: Color {
        switch self {
        case .male: return .blue
        case .female: return .pink
        case .other: return .purple
        }
    }
}

// MARK: - Temporary Event Model

struct TempEvent: Identifiable {
    let id = UUID()
    let title: String
    let startDate: Date
    let eventType: TempEventType
    
    var isToday: Bool {
        Calendar.current.isDateInToday(startDate)
    }
}

enum TempEventType {
    case medical, school, activity, other
    
    var color: Color {
        switch self {
        case .medical: return .red
        case .school: return .blue
        case .activity: return .green
        case .other: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .medical: return "cross.fill"
        case .school: return "book.fill"
        case .activity: return "figure.run"
        case .other: return "calendar"
        }
    }
}

// MARK: - Temporary Document Model

struct TempDocument: Identifiable {
    let id = UUID()
    let title: String
    let documentType: TempDocumentType
    let createdAt: Date
    
    var isRecent: Bool {
        let daysSinceCreation = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
        return daysSinceCreation <= 7
    }
}

enum TempDocumentType {
    case medical, school, legal, other
    
    var displayName: String {
        switch self {
        case .medical: return "Médical"
        case .school: return "Scolaire"
        case .legal: return "Légal"
        case .other: return "Autre"
        }
    }
    
    var color: Color {
        switch self {
        case .medical: return .red
        case .school: return .blue
        case .legal: return .purple
        case .other: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .medical: return "cross.fill"
        case .school: return "book.fill"
        case .legal: return "doc.text.fill"
        case .other: return "doc.fill"
        }
    }
}