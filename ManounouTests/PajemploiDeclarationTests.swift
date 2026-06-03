//
//  PajemploiDeclarationTests.swift
//  ManounouTests
//
//  Tests de la logique financière pure de `PajemploiDeclaration` :
//  crédit d'impôt (avance immédiate URSSAF = 50 %), reste à charge et
//  formatage des valeurs recopiées dans le formulaire Pajemploi.
//

import XCTest
@testable import Manounou

final class PajemploiDeclarationTests: XCTestCase {

    private func declaration(netToPay: Double, hours: Double = 86) -> PajemploiDeclaration {
        PajemploiDeclaration(
            month: Date(),
            nounouFirstName: "Fatou",
            hours: hours,
            days: 20,
            netSalary: 387,
            upkeepAllowance: 70,
            netToPay: netToPay
        )
    }

    // MARK: - Crédit d'impôt

    func testTaxCreditIsHalfOfNetToPay() {
        let decl = declaration(netToPay: 472)
        XCTAssertEqual(decl.taxCredit, 236, accuracy: 0.0001)
    }

    func testRemainingCostIsNetMinusTaxCredit() {
        let decl = declaration(netToPay: 472)
        XCTAssertEqual(decl.remainingCost, 236, accuracy: 0.0001)
        XCTAssertEqual(decl.taxCredit + decl.remainingCost, decl.netToPay, accuracy: 0.0001)
    }

    func testTaxCreditWithOddAmount() {
        let decl = declaration(netToPay: 501)
        XCTAssertEqual(decl.taxCredit, 250.5, accuracy: 0.0001)
    }

    func testSampleMatchesDesignHandoff() {
        let sample = PajemploiDeclaration.sample
        XCTAssertEqual(sample.netToPay, 472, accuracy: 0.0001)
        XCTAssertEqual(sample.taxCredit, 236, accuracy: 0.0001)
    }

    // MARK: - Formatage

    func testIntegerHoursAreFormattedWithoutDecimals() {
        let decl = declaration(netToPay: 472, hours: 86)
        XCTAssertEqual(decl.copyHours, "86")
        XCTAssertEqual(decl.formattedHours, "86 h")
    }

    func testFractionalHoursKeepOneDecimal() {
        let decl = declaration(netToPay: 472, hours: 86.5)
        // Locale fr_FR → séparateur décimal virgule. On vérifie la présence
        // de la fraction sans dépendre du symbole exact.
        XCTAssertTrue(decl.copyHours.contains("5"), "copyHours attendu avec décimale, obtenu \(decl.copyHours)")
    }

    func testFormattedAmountsAreNonEmpty() {
        let decl = declaration(netToPay: 472)
        XCTAssertFalse(decl.formattedNetToPay.isEmpty)
        XCTAssertFalse(decl.formattedTaxCredit.isEmpty)
        XCTAssertFalse(decl.monthTitle.isEmpty)
    }
}
