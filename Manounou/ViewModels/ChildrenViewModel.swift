//
//  ChildrenViewModel.swift
//  Manounou
//
//  Created by Assistant on 17/08/2025.
//

import Foundation
import SwiftUI

@MainActor
class ChildrenViewModel: ObservableObject {
    @Published var children: [Child] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let childrenService: ChildrenServiceProtocol
    
    init(childrenService: ChildrenServiceProtocol = ChildrenService()) {
        self.childrenService = childrenService
    }
    
    // MARK: - Children Management
    
    func loadChildren() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedChildren = try await childrenService.fetchChildren()
            self.children = fetchedChildren
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createChild(_ child: Child) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let createdChild = try await childrenService.createChild(child)
            self.children.append(createdChild)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateChild(_ child: Child) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedChild = try await childrenService.updateChild(child)
            
            if let index = children.firstIndex(where: { $0.id == child.id }) {
                children[index] = updatedChild
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteChild(_ child: Child) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await childrenService.deleteChild(id: child.id)
            children.removeAll { $0.id == child.id }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchChild(id: UUID) async -> Child? {
        do {
            return try await childrenService.fetchChild(id: id)
        } catch {
            self.errorMessage = error.localizedDescription
            return nil
        }
    }
    
    func clearChildren() {
        children.removeAll()
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Computed Properties
    
    var childrenCount: Int {
        children.count
    }
    
    var hasChildren: Bool {
        !children.isEmpty
    }
    
    func childrenByAge() -> [Child] {
        children.sorted { $0.birthDate > $1.birthDate } // Plus jeunes en premier
    }
    
    func childrenByName() -> [Child] {
        children.sorted { $0.firstName.localizedCaseInsensitiveCompare($1.firstName) == .orderedAscending }
    }
    
    func searchChildren(query: String) -> [Child] {
        guard !query.isEmpty else { return children }
        
        return children.filter { child in
            child.firstName.localizedCaseInsensitiveContains(query) ||
            child.lastName.localizedCaseInsensitiveContains(query) ||
            child.fullName.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterChildren(by gender: Gender) -> [Child] {
        children.filter { $0.gender == gender }
    }
    
    func filterChildren(by ageCategory: AgeCategory) -> [Child] {
        children.filter { $0.ageCategory == ageCategory }
    }
}