//
//  ChildrenViewModelTests.swift
//  ManounouTests
//
//  Tests du `ChildrenViewModel` via le mock embarqué `MockChildrenService`
//  (injecté par protocole). Le mock est pré-rempli avec 3 enfants
//  d'exemple et simule un délai réseau.
//
//  NOTE : version modernisée. L'ancien fichier ciblait le module disparu
//  `ManounouApp` et une API de ViewModel (search/filter/sort) qui n'existe
//  plus ; il n'est donc pas réintroduit tel quel.
//

import XCTest
@testable import Manounou

@MainActor
final class ChildrenViewModelTests: XCTestCase {

    private func makeViewModel(shouldFail: Bool = false) -> ChildrenViewModel {
        ChildrenViewModel(childrenService: MockChildrenService(shouldFailRequests: shouldFail))
    }

    // MARK: - État initial

    func testInitialState() {
        let viewModel = makeViewModel()
        XCTAssertTrue(viewModel.children.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Chargement

    func testLoadChildrenSuccess() async {
        let viewModel = makeViewModel()
        await viewModel.loadChildren()
        XCTAssertEqual(viewModel.children.count, 3) // mock pré-rempli
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadChildrenFailureSetsErrorMessage() async {
        let viewModel = makeViewModel(shouldFail: true)
        await viewModel.loadChildren()
        XCTAssertTrue(viewModel.children.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Création

    func testCreateChildReloadsList() async {
        let viewModel = makeViewModel()
        let newChild = Child(
            firstName: "Noé",
            lastName: "Durand",
            birthDate: Date(),
            gender: .male
        )
        await viewModel.createChild(newChild)
        XCTAssertEqual(viewModel.children.count, 4) // 3 + 1
        XCTAssertNil(viewModel.errorMessage)
    }

    func testCreateChildFailureSetsErrorMessage() async {
        let viewModel = makeViewModel(shouldFail: true)
        let newChild = Child(firstName: "Noé", lastName: "Durand", birthDate: Date(), gender: .male)
        await viewModel.createChild(newChild)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Nettoyage

    func testClearChildren() async {
        let viewModel = makeViewModel()
        await viewModel.loadChildren()
        XCTAssertFalse(viewModel.children.isEmpty)
        viewModel.clearChildren()
        XCTAssertTrue(viewModel.children.isEmpty)
    }

    func testClearError() {
        let viewModel = makeViewModel()
        viewModel.errorMessage = "Erreur de test"
        viewModel.clearError()
        XCTAssertNil(viewModel.errorMessage)
    }
}
