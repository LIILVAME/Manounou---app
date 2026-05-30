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
