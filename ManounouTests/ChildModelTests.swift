//
//  ChildModelTests.swift
//  ManounouTests
//
//  Tests de logique pure du modèle `Child` : nom complet, initiales,
//  calcul d'âge (années / mois / catégorie) et validation. Aucune
//  dépendance Supabase — n'utilise que des dates relatives à `Date()`.
//

import XCTest
@testable import Manounou

final class ChildModelTests: XCTestCase {

    /// Construit un enfant dont la date de naissance est `monthsAgo` mois
    /// avant maintenant (valeurs positives = passé).
    private func child(firstName: String = "Emma",
                       lastName: String = "Dupont",
                       monthsAgo: Int,
                       gender: Gender = .female) throws -> Child {
        let birthDate = try XCTUnwrap(
            Calendar.current.date(byAdding: .month, value: -monthsAgo, to: Date())
        )
        return Child(firstName: firstName, lastName: lastName, birthDate: birthDate, gender: gender)
    }

    // MARK: - Identité

    func testFullNameAndInitials() throws {
        let c = try child(monthsAgo: 24)
        XCTAssertEqual(c.fullName, "Emma Dupont")
        XCTAssertEqual(c.initials, "ED")
    }

    func testInitialsHandleSingleCharacterNames() throws {
        let c = try child(firstName: "A", lastName: "B", monthsAgo: 12)
        XCTAssertEqual(c.initials, "AB")
    }

    // MARK: - Âge

    func testBabyIsClassifiedAsBaby() throws {
        // 8 mois → moins de 2 ans.
        let baby = try child(monthsAgo: 8)
        XCTAssertEqual(baby.ageInYears, 0)
        XCTAssertTrue(baby.isBaby)
        XCTAssertFalse(baby.isPreschooler)
        XCTAssertFalse(baby.isSchoolAge)
        XCTAssertEqual(baby.ageCategory, .baby)
        XCTAssertTrue(baby.formattedAge.contains("mois"))
    }

    func testPreschoolerClassification() throws {
        // 3 ans 2 mois → âge préscolaire (2–5 ans).
        let kid = try child(monthsAgo: 38)
        XCTAssertEqual(kid.ageInYears, 3)
        XCTAssertFalse(kid.isBaby)
        XCTAssertTrue(kid.isPreschooler)
        XCTAssertEqual(kid.ageCategory, .preschool)
        XCTAssertTrue(kid.formattedAge.contains("an"))
    }

    func testSchoolAgeClassification() throws {
        // 7 ans → âge scolaire (6+).
        let kid = try child(monthsAgo: 84)
        XCTAssertEqual(kid.ageInYears, 7)
        XCTAssertTrue(kid.isSchoolAge)
        XCTAssertEqual(kid.ageCategory, .school)
    }

    func testAgeComponentsYearsAndMonths() throws {
        let kid = try child(monthsAgo: 38) // 3 ans + 2 mois
        XCTAssertEqual(kid.ageComponents.years, 3)
        XCTAssertGreaterThanOrEqual(kid.ageComponents.months, 0)
        XCTAssertLessThan(kid.ageComponents.months, 12)
    }

    // MARK: - Validation

    func testValidChildPassesValidation() throws {
        let c = try child(monthsAgo: 24)
        XCTAssertTrue(c.isValid)
        XCTAssertTrue(c.validationErrors.isEmpty)
    }

    func testEmptyFirstNameFailsValidation() throws {
        let c = try child(firstName: "   ", monthsAgo: 24)
        XCTAssertFalse(c.isValid)
        XCTAssertTrue(c.validationErrors.contains("Le prénom est requis"))
    }

    func testFutureBirthDateFailsValidation() throws {
        let future = try XCTUnwrap(Calendar.current.date(byAdding: .month, value: 1, to: Date()))
        let c = Child(firstName: "Léo", lastName: "Martin", birthDate: future, gender: .male)
        XCTAssertFalse(c.isValid)
        XCTAssertTrue(c.validationErrors.contains("La date de naissance ne peut pas être dans le futur"))
    }
}
