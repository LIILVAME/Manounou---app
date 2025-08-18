//
//  ChildrenViewModelTests.swift
//  ManounouTests
//
//  Created by Assistant on 17/08/2025.
//

import XCTest
@testable import Manounou

@MainActor
class ChildrenViewModelTests: XCTestCase {
    
    var viewModel: ChildrenViewModel!
    var mockService: MockChildrenService!
    
    override func setUp() {
        super.setUp()
        mockService = MockChildrenService()
        viewModel = ChildrenViewModel(childrenService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertTrue(viewModel.children.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.childrenCount, 0)
        XCTAssertFalse(viewModel.hasChildren)
    }
    
    // MARK: - Load Children Tests
    
    func testLoadChildrenSuccess() async {
        // Given
        let expectedChildren = Child.sampleChildren
        mockService.mockChildren = expectedChildren
        
        // When
        await viewModel.loadChildren()
        
        // Then
        XCTAssertEqual(viewModel.children.count, expectedChildren.count)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.hasChildren)
    }
    
    func testLoadChildrenFailure() async {
        // Given
        mockService.shouldFail = true
        
        // When
        await viewModel.loadChildren()
        
        // Then
        XCTAssertTrue(viewModel.children.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.hasChildren)
    }
    
    // MARK: - Create Child Tests
    
    func testCreateChildSuccess() async {
        // Given
        let newChild = Child.sampleChildren.first!
        
        // When
        await viewModel.createChild(newChild)
        
        // Then
        XCTAssertEqual(viewModel.children.count, 1)
        XCTAssertEqual(viewModel.children.first?.id, newChild.id)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Search and Filter Tests
    
    func testSearchChildren() {
        // Given
        viewModel.children = Child.sampleChildren
        
        // When
        let results = viewModel.searchChildren(query: "Emma")
        
        // Then
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.fullName.localizedCaseInsensitiveContains("Emma") })
    }
    
    func testFilterChildrenByGender() {
        // Given
        viewModel.children = Child.sampleChildren
        
        // When
        let femaleChildren = viewModel.filterChildren(by: .female)
        
        // Then
        XCTAssertTrue(femaleChildren.allSatisfy { $0.gender == .female })
    }
    
    // MARK: - Sorting Tests
    
    func testChildrenByName() {
        // Given
        viewModel.children = Child.sampleChildren
        
        // When
        let sortedChildren = viewModel.childrenByName()
        
        // Then
        for i in 0..<(sortedChildren.count - 1) {
            let current = sortedChildren[i].firstName
            let next = sortedChildren[i + 1].firstName
            XCTAssertTrue(current.localizedCaseInsensitiveCompare(next) != .orderedDescending)
        }
    }
    
    func testChildrenByAge() {
        // Given
        viewModel.children = Child.sampleChildren
        
        // When
        let sortedChildren = viewModel.childrenByAge()
        
        // Then
        for i in 0..<(sortedChildren.count - 1) {
            let current = sortedChildren[i].birthDate
            let next = sortedChildren[i + 1].birthDate
            XCTAssertTrue(current >= next) // Plus jeunes en premier
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testClearError() {
        // Given
        viewModel.errorMessage = "Test error"
        
        // When
        viewModel.clearError()
        
        // Then
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testClearChildren() {
        // Given
        viewModel.children = Child.sampleChildren
        
        // When
        viewModel.clearChildren()
        
        // Then
        XCTAssertTrue(viewModel.children.isEmpty)
        XCTAssertEqual(viewModel.childrenCount, 0)
        XCTAssertFalse(viewModel.hasChildren)
    }
}

// MARK: - Mock Service

class MockChildrenService: ChildrenServiceProtocol {
    var mockChildren: [Child] = []
    var shouldFail = false
    
    func fetchChildren() async throws -> [Child] {
        if shouldFail {
            throw ServiceError.networkError("Mock error")
        }
        return mockChildren
    }
    
    func createChild(_ child: Child) async throws -> Child {
        if shouldFail {
            throw ServiceError.networkError("Mock error")
        }
        return child
    }
    
    func updateChild(_ child: Child) async throws -> Child {
        if shouldFail {
            throw ServiceError.networkError("Mock error")
        }
        return child
    }
    
    func deleteChild(id: UUID) async throws {
        if shouldFail {
            throw ServiceError.networkError("Mock error")
        }
    }
    
    func fetchChild(id: UUID) async throws -> Child? {
        if shouldFail {
            throw ServiceError.networkError("Mock error")
        }
        return mockChildren.first { $0.id == id }
    }
}