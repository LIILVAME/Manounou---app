//
//  EventsViewModelTests.swift
//  ManounouTests
//
//  Tests du `EventsViewModel` via le mock embarqué `MockEventsService`
//  (injecté par protocole). Le mock est pré-rempli avec 2 événements,
//  dont un commençant maintenant (utile pour `todayEvents`).
//

import XCTest
import SwiftUI
@testable import Manounou

@MainActor
final class EventsViewModelTests: XCTestCase {

    private func makeViewModel(shouldFail: Bool = false) -> EventsViewModel {
        EventsViewModel(eventsService: MockEventsService(shouldFailRequests: shouldFail))
    }

    // MARK: - État initial

    func testInitialState() {
        let viewModel = makeViewModel()
        XCTAssertTrue(viewModel.events.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Chargement

    func testLoadEventsSuccess() async {
        let viewModel = makeViewModel()
        await viewModel.loadEvents()
        XCTAssertEqual(viewModel.events.count, 2) // mock pré-rempli
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadEventsFailureSetsErrorMessage() async {
        let viewModel = makeViewModel(shouldFail: true)
        await viewModel.loadEvents()
        XCTAssertTrue(viewModel.events.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - todayEvents

    func testTodayEventsContainsOnlyTodaysEvents() async {
        let viewModel = makeViewModel()
        await viewModel.loadEvents()
        XCTAssertFalse(viewModel.todayEvents.isEmpty)
        XCTAssertTrue(viewModel.todayEvents.allSatisfy {
            Calendar.current.isDateInToday($0.startDate)
        })
    }

    // MARK: - Création

    func testCreateEventReloadsList() async {
        let viewModel = makeViewModel()
        let now = Date()
        let newEvent = Event(
            title: "Goûter",
            startDate: now,
            endDate: now.addingTimeInterval(3600),
            eventType: EventType(name: "Repas", icon: "fork.knife", color: .orange)
        )
        await viewModel.createEvent(newEvent)
        XCTAssertEqual(viewModel.events.count, 3) // 2 + 1
        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Nettoyage

    func testClearEvents() async {
        let viewModel = makeViewModel()
        await viewModel.loadEvents()
        XCTAssertFalse(viewModel.events.isEmpty)
        viewModel.clearEvents()
        XCTAssertTrue(viewModel.events.isEmpty)
    }
}
