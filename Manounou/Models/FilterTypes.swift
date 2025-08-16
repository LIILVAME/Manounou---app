//
//  FilterTypes.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI
import Foundation

// MARK: - Gender Enum
enum Gender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .male:
            return "Garçon"
        case .female:
            return "Fille"
        case .other:
            return "Autre"
        }
    }
    
    var icon: String {
        switch self {
        case .male:
            return "figure.child"
        case .female:
            return "figure.child"
        case .other:
            return "person"
        }
    }
    
    var color: Color {
        switch self {
        case .male:
            return .blue
        case .female:
            return .pink
        case .other:
            return .purple
        }
    }
}

// MARK: - Age Category Enum
enum AgeCategory: String, CaseIterable, Codable {
    case baby = "baby"           // 0-2 ans
    case toddler = "toddler"     // 2-4 ans
    case preschool = "preschool" // 4-6 ans
    case school = "school"       // 6-12 ans
    case teen = "teen"           // 12+ ans
    
    var displayName: String {
        switch self {
        case .baby:
            return "Bébé (0-2 ans)"
        case .toddler:
            return "Bambin (2-4 ans)"
        case .preschool:
            return "Préscolaire (4-6 ans)"
        case .school:
            return "Scolaire (6-12 ans)"
        case .teen:
            return "Adolescent (12+ ans)"
        }
    }
    
    var shortName: String {
        switch self {
        case .baby:
            return "Bébé"
        case .toddler:
            return "Bambin"
        case .preschool:
            return "Préscolaire"
        case .school:
            return "Scolaire"
        case .teen:
            return "Ado"
        }
    }
    
    var icon: String {
        switch self {
        case .baby:
            return "figure.child.circle"
        case .toddler:
            return "figure.walk"
        case .preschool:
            return "figure.run"
        case .school:
            return "backpack"
        case .teen:
            return "figure.wave"
        }
    }
    
    var color: Color {
        switch self {
        case .baby:
            return .mint
        case .toddler:
            return .green
        case .preschool:
            return .orange
        case .school:
            return .blue
        case .teen:
            return .purple
        }
    }
    
    var ageRange: ClosedRange<Int> {
        switch self {
        case .baby:
            return 0...2
        case .toddler:
            return 2...4
        case .preschool:
            return 4...6
        case .school:
            return 6...12
        case .teen:
            return 12...25
        }
    }
    
    static func category(for age: Int) -> AgeCategory {
        switch age {
        case 0...2:
            return .baby
        case 2...4:
            return .toddler
        case 4...6:
            return .preschool
        case 6...12:
            return .school
        default:
            return .teen
        }
    }
}

// MARK: - Sort Option Enum
enum SortOption: String, CaseIterable, Codable {
    case nameAscending = "name_asc"
    case nameDescending = "name_desc"
    case ageAscending = "age_asc"
    case ageDescending = "age_desc"
    
    var title: String {
        switch self {
        case .nameAscending:
            return "Nom A-Z"
        case .nameDescending:
            return "Nom Z-A"
        case .ageAscending:
            return "Plus jeune"
        case .ageDescending:
            return "Plus âgé"
        }
    }
    
    var icon: String {
        switch self {
        case .nameAscending:
            return "textformat.abc"
        case .nameDescending:
            return "textformat.abc"
        case .ageAscending:
            return "arrow.up.circle"
        case .ageDescending:
            return "arrow.down.circle"
        }
    }
    
    var description: String {
        switch self {
        case .nameAscending:
            return "Trier par nom de A à Z"
        case .nameDescending:
            return "Trier par nom de Z à A"
        case .ageAscending:
            return "Trier du plus jeune au plus âgé"
        case .ageDescending:
            return "Trier du plus âgé au plus jeune"
        }
    }
}

// MARK: - Filter State
struct FilterState {
    var searchText: String = ""
    var selectedGender: Gender? = nil
    var selectedAgeCategory: AgeCategory? = nil
    var sortOption: SortOption = .nameAscending
    
    var hasActiveFilters: Bool {
        return !searchText.isEmpty || selectedGender != nil || selectedAgeCategory != nil || sortOption != .nameAscending
    }
    
    var activeFiltersCount: Int {
        var count = 0
        if !searchText.isEmpty { count += 1 }
        if selectedGender != nil { count += 1 }
        if selectedAgeCategory != nil { count += 1 }
        if sortOption != .nameAscending { count += 1 }
        return count
    }
    
    mutating func clearAll() {
        searchText = ""
        selectedGender = nil
        selectedAgeCategory = nil
        sortOption = .nameAscending
    }
}

// MARK: - Child Extensions for Filtering
extension TemporaryChild {
    var gender: Gender {
        // Pour l'instant, on assigne aléatoirement basé sur le prénom
        let femaleNames = ["Emma", "Léa", "Chloé", "Manon", "Sarah", "Jade", "Lola", "Anaïs", "Lucie", "Océane"]
        return femaleNames.contains(firstName) ? .female : .male
    }
    
    var ageInYears: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year ?? 0
    }
    
    var ageCategory: AgeCategory {
        return AgeCategory.category(for: ageInYears)
    }
    
    func matches(filter: FilterState) -> Bool {
        // Recherche textuelle
        if !filter.searchText.isEmpty {
            let searchLower = filter.searchText.lowercased()
            let fullNameLower = fullName.lowercased()
            if !fullNameLower.contains(searchLower) {
                return false
            }
        }
        
        // Filtre par genre
        if let selectedGender = filter.selectedGender {
            if gender != selectedGender {
                return false
            }
        }
        
        // Filtre par catégorie d'âge
        if let selectedAgeCategory = filter.selectedAgeCategory {
            if ageCategory != selectedAgeCategory {
                return false
            }
        }
        
        return true
    }
}

// MARK: - Array Extensions for Sorting
extension Array where Element == TemporaryChild {
    func sorted(by option: SortOption) -> [TemporaryChild] {
        switch option {
        case .nameAscending:
            return self.sorted { $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedAscending }
        case .nameDescending:
            return self.sorted { $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedDescending }
        case .ageAscending:
            return self.sorted { $0.birthDate > $1.birthDate } // Plus récent = plus jeune
        case .ageDescending:
            return self.sorted { $0.birthDate < $1.birthDate } // Plus ancien = plus âgé
        }
    }
    
    func filtered(by filterState: FilterState) -> [TemporaryChild] {
        return self.filter { $0.matches(filter: filterState) }
    }
    
    func filteredAndSorted(by filterState: FilterState) -> [TemporaryChild] {
        return self.filtered(by: filterState).sorted(by: filterState.sortOption)
    }
}