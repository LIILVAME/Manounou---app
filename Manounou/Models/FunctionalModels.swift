//
//  FunctionalModels.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation

// MARK: - Functional Child Model
struct FunctionalChild: Identifiable {
    let id = UUID()
    var firstName: String
    var lastName: String
    var birthDate: Date
    var gender: String
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
}

// MARK: - Functional Event Model
struct FunctionalEvent: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var description: String
}

// MARK: - Functional Document Model
struct FunctionalDocument: Identifiable {
    let id = UUID()
    var title: String
    var type: String
    var size: String
    var dateAdded: Date
    let category: DocumentCategory
}