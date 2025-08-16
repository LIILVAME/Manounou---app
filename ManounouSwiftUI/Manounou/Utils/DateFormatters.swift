//
//  DateFormatters.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation

/// Centralisation de tous les formatters de date pour éviter les duplications
struct DateFormatters {
    
    /// Formatter pour afficher les jours complets (ex: "Lundi 16 août 2025")
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    /// Formatter pour afficher l'heure (ex: "14:30")
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    /// Formatter pour afficher la date courte (ex: "16/08/2025")
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    /// Formatter pour afficher la date moyenne (ex: "16 août 2025")
    static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    /// Formatter pour afficher les jours de la semaine (ex: "LUN")
    static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    /// Formatter pour afficher le mois et l'année (ex: "août 2025")
    static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
}

// MARK: - Extensions utilitaires

extension DateFormatters {
    
    /// Retourne une chaîne formatée pour l'âge d'un enfant (format: "X ans et Y jours")
    static func ageText(for birthDate: Date) -> String {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year, .day], from: birthDate, to: Date())
        
        guard let years = ageComponents.year, let totalDays = ageComponents.day else {
            return "Nouveau-né"
        }
        
        if years > 0 {
            // Calculer les jours restants après avoir soustrait les années complètes
            let startOfCurrentYear = calendar.date(byAdding: .year, value: years, to: birthDate) ?? birthDate
            let remainingDays = calendar.dateComponents([.day], from: startOfCurrentYear, to: Date()).day ?? 0
            
            if remainingDays > 0 {
                return "\(years) an\(years > 1 ? "s" : "") et \(remainingDays) jour\(remainingDays > 1 ? "s" : "")"
            } else {
                return "\(years) an\(years > 1 ? "s" : "")"
            }
        } else if totalDays > 0 {
            return "\(totalDays) jour\(totalDays > 1 ? "s" : "")"
        } else {
            return "Nouveau-né"
        }
    }
    
    /// Retourne une chaîne formatée pour la durée d'un événement
    static func durationText(from startDate: Date, to endDate: Date) -> String {
        let duration = endDate.timeIntervalSince(startDate)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h\(minutes > 0 ? " \(minutes)min" : "")"
        } else {
            return "\(minutes)min"
        }
    }
}