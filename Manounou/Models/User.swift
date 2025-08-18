//
//  User.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation

// MARK: - User Model
struct User: Identifiable, Codable {
    let id: UUID
    var email: String
    var firstName: String
    var lastName: String
    var phoneNumber: String?
    var avatarUrl: String?
    var language: String
    var role: UserRole
    var plan: UserPlan
    var planStatus: PlanStatus
    let createdAt: Date
    var updatedAt: Date
    
    // MARK: - Computed Properties
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    var displayName: String {
        if firstName.isEmpty && lastName.isEmpty {
            return email
        }
        return fullName
    }
    
    // MARK: - Initializers
    init(
        id: UUID = UUID(),
        email: String,
        firstName: String,
        lastName: String,
        phoneNumber: String? = nil,
        avatarUrl: String? = nil,
        language: String = "fr",
        role: UserRole = .parent,
        plan: UserPlan = .free,
        planStatus: PlanStatus = .active,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.avatarUrl = avatarUrl
        self.language = language
        self.role = role
        self.plan = plan
        self.planStatus = planStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - User Role
enum UserRole: String, CaseIterable, Codable {
    case parent = "parent"
    case nanny = "nanny"
    case admin = "admin"
    
    var displayName: String {
        switch self {
        case .parent:
            return "Parent"
        case .nanny:
            return "Nounou"
        case .admin:
            return "Administrateur"
        }
    }
    
    var icon: String {
        switch self {
        case .parent:
            return "person.2.fill"
        case .nanny:
            return "heart.fill"
        case .admin:
            return "crown.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .parent:
            return .blue
        case .nanny:
            return .pink
        case .admin:
            return .purple
        }
    }
}

// MARK: - User Plan
enum UserPlan: String, CaseIterable, Codable {
    case free = "free"
    case starter = "starter"
    case full = "full"
    
    var displayName: String {
        switch self {
        case .free:
            return "Gratuit"
        case .starter:
            return "Starter"
        case .full:
            return "Complet"
        }
    }
    
    var maxChildren: Int {
        switch self {
        case .free:
            return 2
        case .starter:
            return 5
        case .full:
            return 20
        }
    }
    
    var maxDocuments: Int {
        switch self {
        case .free:
            return 10
        case .starter:
            return 100
        case .full:
            return 1000
        }
    }
    
    var price: String {
        switch self {
        case .free:
            return "0€/mois"
        case .starter:
            return "9€/mois"
        case .full:
            return "19€/mois"
        }
    }
    
    var color: Color {
        switch self {
        case .free:
            return .gray
        case .starter:
            return .blue
        case .full:
            return .purple
        }
    }
}

// MARK: - Plan Status
enum PlanStatus: String, CaseIterable, Codable {
    case active = "active"
    case pastDue = "past_due"
    case canceled = "canceled"
    
    var displayName: String {
        switch self {
        case .active:
            return "Actif"
        case .pastDue:
            return "Paiement en retard"
        case .canceled:
            return "Annulé"
        }
    }
    
    var color: Color {
        switch self {
        case .active:
            return .green
        case .pastDue:
            return .orange
        case .canceled:
            return .red
        }
    }
}

// MARK: - Language Support
enum SupportedLanguage: String, CaseIterable, Codable {
    case french = "fr"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .french:
            return "Français"
        case .english:
            return "English"
        }
    }
    
    var flag: String {
        switch self {
        case .french:
            return "🇫🇷"
        case .english:
            return "🇬🇧"
        }
    }
}

// MARK: - Sample Data
#if DEBUG
extension User {
    static let sampleUser = User(
        email: "parent@example.com",
        firstName: "Marie",
        lastName: "Dupont",
        phoneNumber: "+33 6 12 34 56 78",
        language: "fr",
        role: .parent,
        plan: .starter,
        planStatus: .active
    )
    
    static let sampleUsers: [User] = [
        sampleUser,
        User(
            email: "nounou@example.com",
            firstName: "Sophie",
            lastName: "Martin",
            phoneNumber: "+33 6 98 76 54 32",
            language: "fr",
            role: .nanny,
            plan: .free,
            planStatus: .active
        ),
        User(
            email: "admin@example.com",
            firstName: "Jean",
            lastName: "Admin",
            language: "fr",
            role: .admin,
            plan: .full,
            planStatus: .active
        )
    ]
}
#endif