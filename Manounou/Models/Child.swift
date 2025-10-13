//
//  Child.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation
import SwiftUI

// MARK: - Child Model

struct Child: Identifiable, Codable, Hashable {
    let id: UUID
    var firstName: String
    var lastName: String
    var birthDate: Date
    var gender: Gender
    var profileImageURL: String?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        birthDate: Date,
        gender: Gender,
        profileImageURL: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.gender = gender
        self.profileImageURL = profileImageURL
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


// MARK: - Child Extensions

extension Child {
    
    /// Nom complet de l'enfant
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    /// Initiales de l'enfant
    var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    /// Âge de l'enfant en texte formaté
    var ageText: String {
        DateFormatters.ageText(for: birthDate)
    }
    
    /// Âge formaté selon le format "X ans et Y mois"
    var formattedAge: String {
        let components = ageComponents
        let years = components.years
        let months = components.months
        
        if years == 0 {
            return "\(months) mois"
        } else if months == 0 {
            return "\(years) an\(years > 1 ? "s" : "")"
        } else {
            return "\(years) an\(years > 1 ? "s" : "") et \(months) mois"
        }
    }
    
    /// Âge de l'enfant en années
    var ageInYears: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
    
    /// Âge de l'enfant en mois (mois restants après les années complètes)
    var ageInMonths: Int {
        let components = Calendar.current.dateComponents([.year, .month], from: birthDate, to: Date())
        return components.month ?? 0
    }
    
    /// Nombre total de mois depuis la naissance
    var totalMonthsSinceBirth: Int {
        Calendar.current.dateComponents([.month], from: birthDate, to: Date()).month ?? 0
    }
    
    /// Composants d'âge détaillés (années et mois)
    var ageComponents: (years: Int, months: Int) {
        let components = Calendar.current.dateComponents([.year, .month], from: birthDate, to: Date())
        return (years: components.year ?? 0, months: components.month ?? 0)
    }
    
    /// Vérifie si l'enfant est un bébé (moins de 2 ans)
    var isBaby: Bool {
        ageInYears < 2
    }
    
    /// Vérifie si l'enfant est en âge préscolaire (2-5 ans)
    var isPreschooler: Bool {
        ageInYears >= 2 && ageInYears <= 5
    }
    
    /// Vérifie si l'enfant est en âge scolaire (6+ ans)
    var isSchoolAge: Bool {
        ageInYears >= 6
    }
    
    /// Catégorie d'âge
    var ageCategory: AgeCategory {
        if isBaby {
            return .baby
        } else if isPreschooler {
            return .preschool
        } else {
            return .school
        }
    }
    
    /// Date de naissance formatée
    var birthDateText: String {
        DateFormatters.mediumDateFormatter.string(from: birthDate)
    }
}


// MARK: - Child Validation

extension Child {
    
    /// Valide les données de l'enfant
    var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        birthDate <= Date()
    }
    
    /// Messages d'erreur de validation
    var validationErrors: [String] {
        var errors: [String] = []
        
        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Le prénom est requis")
        }
        
        if lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Le nom de famille est requis")
        }
        
        if birthDate > Date() {
            errors.append("La date de naissance ne peut pas être dans le futur")
        }
        
        let maxAge = Calendar.current.date(byAdding: .year, value: -100, to: Date()) ?? Date()
        if birthDate < maxAge {
            errors.append("La date de naissance semble incorrecte")
        }
        
        return errors
    }
}

// MARK: - Sample Data

#if DEBUG
extension Child {
    
    static let sampleChildren: [Child] = [
        Child(
            firstName: "Emma",
            lastName: "Dupont",
            birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
            gender: .female,
            notes: "Aime les livres et les puzzles"
        ),
        Child(
            firstName: "Lucas",
            lastName: "Dupont",
            birthDate: Calendar.current.date(byAdding: .year, value: -6, to: Date()) ?? Date(),
            gender: .male,
            notes: "Passionné de football et de sciences"
        ),
        Child(
            firstName: "Léa",
            lastName: "Martin",
            birthDate: Calendar.current.date(byAdding: .month, value: -8, to: Date()) ?? Date(),
            gender: .female,
            notes: "Bébé très calme, dort bien"
        )
    ]
}
#endif