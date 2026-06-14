//
//  SmokeTests.swift
//  ManounouTests
//
//  Tests de fumée exerçant les modèles cœur de l'app.
//  NOTE: les anciens fichiers de test de ce dossier (CacheManagerTests,
//  ModernMainTabViewTests, OptimizedViewsTests, etc.) ne sont volontairement
//  PAS inclus dans la cible : ils visent un ancien module `ManounouApp`,
//  redéfinissent des mocks désormais présents dans l'app et référencent des
//  types supprimés. Ils doivent être modernisés avant réintégration.
//

import XCTest
@testable import Manounou

final class SmokeTests: XCTestCase {

    func testDocumentTypeDisplayNamesAreNonEmpty() {
        for type in DocumentType.allCases {
            XCTAssertFalse(type.displayName.isEmpty, "displayName vide pour \(type)")
            XCTAssertFalse(type.icon.isEmpty, "icon vide pour \(type)")
        }
    }

    func testDocumentComputedProperties() {
        let doc = Document(
            title: "Carnet de santé",
            documentType: .medical,
            fileName: "carnet.pdf",
            fileSize: 2_048_000,
            mimeType: "application/pdf",
            userId: UUID()
        )

        XCTAssertEqual(doc.displayFileName, "carnet.pdf")
        XCTAssertTrue(doc.isPDF)
        XCTAssertFalse(doc.isImage)
        XCTAssertEqual(doc.fileExtension, "pdf")
        XCTAssertFalse(doc.fileSizeText.isEmpty)
    }

    func testDocumentImageDetection() {
        let photo = Document(
            title: "Photo",
            documentType: .photo,
            mimeType: "image/jpeg",
            userId: UUID()
        )
        XCTAssertTrue(photo.isImage)
        XCTAssertFalse(photo.isPDF)
    }

    func testDocumentFallsBackToTitleWhenNoFileName() {
        let doc = Document(title: "Sans fichier", documentType: .other, userId: UUID())
        XCTAssertEqual(doc.displayFileName, "Sans fichier")
    }
}

// MARK: - Pajemploi (calcul réel de la déclaration mensuelle)

final class PajemploiDeclarationTests: XCTestCase {

    private func parisCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris") ?? .current
        return calendar
    }

    private func date(_ calendar: Calendar, day: Int, hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 5, day: day, hour: hour))!
    }

    private func gardeSlot(_ calendar: Calendar, day: Int, from: Int, to: Int) -> Event {
        Event(
            title: "Garde",
            description: PajemploiDeclaration.babysitterTag,
            startDate: date(calendar, day: day, hour: from),
            endDate: date(calendar, day: day, hour: to),
            eventType: EventType.defaultTypes[0]
        )
    }

    func testDeclarationFromRealBabysitterSlots() {
        let calendar = parisCalendar()
        let month = date(calendar, day: 1, hour: 0)

        // 2 jours gardés, 8 h chacun = 16 h.
        let slots = [
            gardeSlot(calendar, day: 5,  from: 9, to: 17),
            gardeSlot(calendar, day: 12, from: 9, to: 17)
        ]

        var schedule = PlanningSchedule.default
        schedule.netHourlyRate = 5.0
        schedule.upkeepPerDay  = 4.0
        schedule.mealPerDay    = 0.0
        schedule.carerName     = "Fatou"

        let decl = PajemploiDeclaration.from(
            month: month, events: slots, schedule: schedule, calendar: calendar
        )

        XCTAssertEqual(decl.hours, 16, accuracy: 0.001)
        XCTAssertEqual(decl.days, 2)
        XCTAssertEqual(decl.netSalary, 80, accuracy: 0.001)       // 16 × 5
        XCTAssertEqual(decl.upkeepAllowance, 8, accuracy: 0.001)  // 2 × 4
        XCTAssertEqual(decl.netToPay, 88, accuracy: 0.001)        // 80 + 8
        XCTAssertEqual(decl.taxCredit, 44, accuracy: 0.001)       // 50 %
        XCTAssertEqual(decl.nounouFirstName, "Fatou")
    }

    func testDeclarationIgnoresOtherMonthsAndNonGardeEvents() {
        let calendar = parisCalendar()
        let month = date(calendar, day: 1, hour: 0)

        // Créneau de garde mais le mois SUIVANT → exclu.
        let nextMonth = Event(
            title: "Garde", description: PajemploiDeclaration.babysitterTag,
            startDate: calendar.date(from: DateComponents(year: 2026, month: 6, day: 3, hour: 9))!,
            endDate: calendar.date(from: DateComponents(year: 2026, month: 6, day: 3, hour: 17))!,
            eventType: EventType.defaultTypes[0]
        )
        // Rendez-vous médical le bon mois mais PAS un créneau de garde → exclu.
        let medical = Event(
            title: "Pédiatre", description: "medical",
            startDate: date(calendar, day: 8, hour: 10),
            endDate: date(calendar, day: 8, hour: 11),
            eventType: EventType.defaultTypes[0]
        )

        let decl = PajemploiDeclaration.from(
            month: month, events: [nextMonth, medical],
            schedule: .default, calendar: calendar
        )

        XCTAssertEqual(decl.hours, 0, accuracy: 0.001)
        XCTAssertEqual(decl.days, 0)
        XCTAssertEqual(decl.netToPay, 0, accuracy: 0.001)
    }
}
