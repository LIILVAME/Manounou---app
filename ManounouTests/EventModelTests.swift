//
//  EventModelTests.swift
//  ManounouTests
//
//  Tests de logique pure du modèle `Event` : durée et statuts temporels
//  (aujourd'hui / en cours / passé / futur).
//

import XCTest
import SwiftUI
@testable import Manounou

final class EventModelTests: XCTestCase {

    private let eventType = EventType(name: "Médical", icon: "stethoscope", color: .red)

    private func event(start: Date, end: Date) -> Event {
        Event(title: "Test", startDate: start, endDate: end, eventType: eventType)
    }

    func testDurationInMinutes() {
        let start = Date()
        let end = start.addingTimeInterval(90 * 60) // +90 min
        XCTAssertEqual(event(start: start, end: end).durationInMinutes, 90)
    }

    func testPastEvent() {
        let now = Date()
        let e = event(start: now.addingTimeInterval(-2 * 3600), end: now.addingTimeInterval(-3600))
        XCTAssertTrue(e.isPast)
        XCTAssertFalse(e.isFuture)
        XCTAssertFalse(e.isOngoing)
    }

    func testFutureEvent() {
        let now = Date()
        let e = event(start: now.addingTimeInterval(3600), end: now.addingTimeInterval(2 * 3600))
        XCTAssertTrue(e.isFuture)
        XCTAssertFalse(e.isPast)
        XCTAssertFalse(e.isOngoing)
    }

    func testOngoingEvent() {
        let now = Date()
        let e = event(start: now.addingTimeInterval(-60), end: now.addingTimeInterval(3600))
        XCTAssertTrue(e.isOngoing)
        XCTAssertFalse(e.isPast)
        XCTAssertFalse(e.isFuture)
    }

    func testIsTodayForCurrentEvent() {
        let now = Date()
        let e = event(start: now, end: now.addingTimeInterval(3600))
        XCTAssertTrue(e.isToday)
    }
}
