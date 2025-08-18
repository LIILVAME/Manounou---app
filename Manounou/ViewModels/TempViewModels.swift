//
//  TempViewModels.swift
//  Manounou
//
//  Created by Assistant on 18/08/2025.
//  Temporary ViewModels extracted from MainTabView for better organization
//

import SwiftUI
import Foundation

// MARK: - Temporary Children ViewModel

@MainActor
class TempChildrenViewModel: ObservableObject {
    @Published var children: [TempChild] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadChildren() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        children = [
            TempChild(
                firstName: "Emma",
                lastName: "Dupont",
                birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
                gender: .female,
                notes: "Aime les livres et les puzzles"
            ),
            TempChild(
                firstName: "Lucas",
                lastName: "Martin",
                birthDate: Calendar.current.date(byAdding: .month, value: -18, to: Date()) ?? Date(),
                gender: .male,
                notes: "Très actif et curieux"
            )
        ]
        isLoading = false
    }
}

// MARK: - Temporary Events ViewModel

@MainActor
class TempEventsViewModel: ObservableObject {
    @Published var events: [TempEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadEvents() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        events = [
            TempEvent(
                title: "Rendez-vous médecin",
                startDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                eventType: .medical
            ),
            TempEvent(
                title: "Réunion école",
                startDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                eventType: .school
            )
        ]
        isLoading = false
    }
}

// MARK: - Temporary Documents ViewModel

@MainActor
class TempDocumentsViewModel: ObservableObject {
    @Published var documents: [TempDocument] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadDocuments() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        documents = [
            TempDocument(
                title: "Carnet de santé Emma",
                documentType: .medical,
                createdAt: Date()
            ),
            TempDocument(
                title: "Bulletin scolaire Lucas",
                documentType: .school,
                createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
            )
        ]
        isLoading = false
    }
}