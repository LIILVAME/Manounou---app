//
//  UserProfile.swift
//  Manounou
//
//  Created by Assistant on 2025-01-13.
//

import Foundation

struct UserProfile: Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var avatarUrl: String?
    var createdAt: Date
    var updatedAt: Date
}