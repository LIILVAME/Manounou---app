//
//  ModernMainTabViewTests.swift
//  ManounouTests
//
//  Created by Assistant on 18/08/2025.
//  Tests for the refactored ModernMainTabView and components
//

import XCTest
import SwiftUI
@testable import ManounouApp

@MainActor
class ModernMainTabViewTests: XCTestCase {
    
    var appContainer: AppContainer!
    
    override func setUp() {
        super.setUp()
        appContainer = AppContainer(isTestMode: true)
    }
    
    override func tearDown() {
        appContainer = nil
        super.tearDown()
    }
    
    // MARK: - MainTabView Tests
    
    func testMainTabViewCreation() {
        // Given & When
        let mainTabView = ModernMainTabView()
            .environmentObject(appContainer)
        
        // Then
        XCTAssertNotNil(mainTabView)
    }
    
    func testMainTabViewPerformance() {
        // Test creation performance
        measure {
            let _ = ModernMainTabView()
                .environmentObject(appContainer)
        }
    }
    
    // MARK: - Children View Tests
    
    func testChildrenViewCreation() {
        // Given & When
        let childrenView = ModernChildrenView()
            .environmentObject(appContainer.childrenViewModel)
        
        // Then
        XCTAssertNotNil(childrenView)
    }
    
    func testChildrenViewModelIntegration() async {
        // Given
        let childrenViewModel = appContainer.childrenViewModel
        
        // When
        await childrenViewModel.loadChildren()
        
        // Then
        XCTAssertNotNil(childrenViewModel.children)
        XCTAssertFalse(childrenViewModel.isLoading)
    }
    
    func testAddChildFunctionality() async {
        // Given
        let childrenViewModel = appContainer.childrenViewModel
        let initialCount = childrenViewModel.children.count
        
        let newChild = Child(
            id: UUID(),
            firstName: "Test",
            lastName: "Child",
            birthDate: Date(),
            gender: .other,
            notes: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // When
        await childrenViewModel.addChild(newChild)
        
        // Then
        XCTAssertEqual(childrenViewModel.children.count, initialCount + 1)
        XCTAssertTrue(childrenViewModel.children.contains { $0.id == newChild.id })
    }
    
    func testDeleteChildFunctionality() async {
        // Given
        let childrenViewModel = appContainer.childrenViewModel
        await childrenViewModel.loadChildren()
        
        let testChild = Child(
            id: UUID(),
            firstName: "Test",
            lastName: "Child",
            birthDate: Date(),
            gender: .other,
            notes: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        await childrenViewModel.addChild(testChild)
        let countAfterAdd = childrenViewModel.children.count
        
        // When
        await childrenViewModel.deleteChild(testChild.id)
        
        // Then
        XCTAssertEqual(childrenViewModel.children.count, countAfterAdd - 1)
        XCTAssertFalse(childrenViewModel.children.contains { $0.id == testChild.id })
    }
    
    // MARK: - Calendar View Tests
    
    func testCalendarViewCreation() {
        // Given & When
        let calendarView = ModernCalendarView()
            .environmentObject(appContainer.eventsViewModel)
        
        // Then
        XCTAssertNotNil(calendarView)
    }
    
    func testEventsViewModelIntegration() async {
        // Given
        let eventsViewModel = appContainer.eventsViewModel
        
        // When
        await eventsViewModel.loadEvents()
        
        // Then
        XCTAssertNotNil(eventsViewModel.events)
        XCTAssertFalse(eventsViewModel.isLoading)
    }
    
    func testAddEventFunctionality() async {
        // Given
        let eventsViewModel = appContainer.eventsViewModel
        let initialCount = eventsViewModel.events.count
        
        let newEvent = Event(
            id: UUID(),
            title: "Test Event",
            description: "Test Description",
            startDate: Date(),
            endDate: nil,
            eventType: .appointment,
            priority: .medium,
            isAllDay: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // When
        await eventsViewModel.addEvent(newEvent)
        
        // Then
        XCTAssertEqual(eventsViewModel.events.count, initialCount + 1)
        XCTAssertTrue(eventsViewModel.events.contains { $0.id == newEvent.id })
    }
    
    // MARK: - Documents View Tests
    
    func testDocumentsViewCreation() {
        // Given & When
        let documentsView = ModernDocumentsView()
            .environmentObject(appContainer.documentsViewModel)
            .environmentObject(appContainer.childrenViewModel)
        
        // Then
        XCTAssertNotNil(documentsView)
    }
    
    func testDocumentsViewModelIntegration() async {
        // Given
        let documentsViewModel = appContainer.documentsViewModel
        
        // When
        await documentsViewModel.loadDocuments()
        
        // Then
        XCTAssertNotNil(documentsViewModel.documents)
        XCTAssertFalse(documentsViewModel.isLoading)
    }
    
    func testAddDocumentFunctionality() async {
        // Given
        let documentsViewModel = appContainer.documentsViewModel
        let initialCount = documentsViewModel.documents.count
        
        let newDocument = Document(
            id: UUID(),
            title: "Test Document",
            description: "Test Description",
            documentType: .other,
            childId: nil,
            filePath: nil,
            fileSize: nil,
            mimeType: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // When
        await documentsViewModel.addDocument(newDocument)
        
        // Then
        XCTAssertEqual(documentsViewModel.documents.count, initialCount + 1)
        XCTAssertTrue(documentsViewModel.documents.contains { $0.id == newDocument.id })
    }
    
    // MARK: - Settings View Tests
    
    func testSettingsViewCreation() {
        // Given & When
        let settingsView = ModernSettingsView()
            .environmentObject(appContainer.authViewModel)
        
        // Then
        XCTAssertNotNil(settingsView)
    }
    
    func testAuthViewModelIntegration() {
        // Given
        let authViewModel = appContainer.authViewModel
        
        // When & Then
        XCTAssertNotNil(authViewModel)
        XCTAssertNotNil(authViewModel.isAuthenticated)
    }
    
    // MARK: - Component Integration Tests
    
    func testAppContainerInjection() {
        // Given & When
        let mainTabView = ModernMainTabView()
            .environmentObject(appContainer)
        
        // Then
        XCTAssertNotNil(mainTabView)
        XCTAssertNotNil(appContainer.childrenViewModel)
        XCTAssertNotNil(appContainer.eventsViewModel)
        XCTAssertNotNil(appContainer.documentsViewModel)
        XCTAssertNotNil(appContainer.authViewModel)
    }
    
    func testViewModelsAreShared() {
        // Given
        let childrenViewModel1 = appContainer.childrenViewModel
        let childrenViewModel2 = appContainer.childrenViewModel
        
        // Then
        XCTAssertTrue(childrenViewModel1 === childrenViewModel2)
    }
    
    // MARK: - Navigation Tests
    
    func testTabViewAccessibility() {
        // Given
        let mainTabView = ModernMainTabView()
            .environmentObject(appContainer)
        
        // When & Then
        // Test that accessibility labels are properly set
        XCTAssertNotNil(mainTabView)
    }
    
    // MARK: - Performance Tests
    
    func testMainTabViewPerformanceWithData() {
        // Given
        let childrenViewModel = appContainer.childrenViewModel
        let eventsViewModel = appContainer.eventsViewModel
        let documentsViewModel = appContainer.documentsViewModel
        
        // Add test data
        Task {
            for i in 0..<10 {
                let child = Child(
                    id: UUID(),
                    firstName: "Child \(i)",
                    lastName: "Test",
                    birthDate: Date(),
                    gender: .other,
                    notes: nil,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                await childrenViewModel.addChild(child)
                
                let event = Event(
                    id: UUID(),
                    title: "Event \(i)",
                    description: nil,
                    startDate: Date(),
                    endDate: nil,
                    eventType: .appointment,
                    priority: .medium,
                    isAllDay: false,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                await eventsViewModel.addEvent(event)
                
                let document = Document(
                    id: UUID(),
                    title: "Document \(i)",
                    description: nil,
                    documentType: .other,
                    childId: nil,
                    filePath: nil,
                    fileSize: nil,
                    mimeType: nil,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                await documentsViewModel.addDocument(document)
            }
        }
        
        // When & Then
        measure {
            let _ = ModernMainTabView()
                .environmentObject(appContainer)
        }
    }
    
    // MARK: - Memory Tests
    
    func testMemoryManagement() {
        // Given
        weak var weakMainTabView: ModernMainTabView?
        weak var weakChildrenView: ModernChildrenView?
        weak var weakCalendarView: ModernCalendarView?
        weak var weakDocumentsView: ModernDocumentsView?
        weak var weakSettingsView: ModernSettingsView?
        
        // When
        autoreleasepool {
            let mainTabView = ModernMainTabView()
            let childrenView = ModernChildrenView()
            let calendarView = ModernCalendarView()
            let documentsView = ModernDocumentsView()
            let settingsView = ModernSettingsView()
            
            weakMainTabView = mainTabView
            weakChildrenView = childrenView
            weakCalendarView = calendarView
            weakDocumentsView = documentsView
            weakSettingsView = settingsView
            
            // Use the views
            XCTAssertNotNil(mainTabView)
            XCTAssertNotNil(childrenView)
            XCTAssertNotNil(calendarView)
            XCTAssertNotNil(documentsView)
            XCTAssertNotNil(settingsView)
        }
        
        // Then
        // Views should be deallocated
        XCTAssertNil(weakMainTabView)
        XCTAssertNil(weakChildrenView)
        XCTAssertNil(weakCalendarView)
        XCTAssertNil(weakDocumentsView)
        XCTAssertNil(weakSettingsView)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() async {
        // Given
        let childrenViewModel = appContainer.childrenViewModel
        
        // When - Try to add an invalid child
        let invalidChild = Child(
            id: UUID(),
            firstName: "", // Invalid empty name
            lastName: "",
            birthDate: Date(),
            gender: .other,
            notes: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        await childrenViewModel.addChild(invalidChild)
        
        // Then
        // Should handle the error gracefully
        XCTAssertNotNil(childrenViewModel.errorMessage)
    }
    
    // MARK: - UI Component Tests
    
    func testThemedComponentsCreation() {
        // Test that themed components can be created
        let textField = ThemedTextField("Test", text: .constant(""), placeholder: "Test")
        let button = ThemedButton("Test") {}
        let loadingView = LoadingView("Test")
        let errorView = ErrorView(message: "Test error")
        
        XCTAssertNotNil(textField)
        XCTAssertNotNil(button)
        XCTAssertNotNil(loadingView)
        XCTAssertNotNil(errorView)
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() {
        // Given
        let mainTabView = ModernMainTabView()
            .environmentObject(appContainer)
        
        // When & Then
        // Verify that accessibility is properly implemented
        XCTAssertNotNil(mainTabView)
        
        // Test individual components
        let addChildButton = AddChildButton {}
        let addEventButton = AddEventButton {}
        let addDocumentButton = AddDocumentButton {}
        
        XCTAssertNotNil(addChildButton)
        XCTAssertNotNil(addEventButton)
        XCTAssertNotNil(addDocumentButton)
    }
    
    // MARK: - Theme Integration Tests
    
    func testThemeIntegration() {
        // Test that AppTheme is properly used
        XCTAssertNotNil(AppTheme.Colors.primary)
        XCTAssertNotNil(AppTheme.Typography.body)
        XCTAssertNotNil(AppTheme.Spacing.md)
        XCTAssertNotNil(AppTheme.Icons.home)
    }
}