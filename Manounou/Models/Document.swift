//
//  Document.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation
import SwiftUI

// MARK: - Document Model

struct Document: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var description: String?
    var documentType: DocumentType
    var fileName: String?
    var fileUrl: String?
    var fileSize: Int? // in bytes
    var mimeType: String?
    var childId: UUID?
    var userId: UUID
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        documentType: DocumentType,
        fileName: String? = nil,
        fileUrl: String? = nil,
        fileSize: Int? = nil,
        mimeType: String? = nil,
        childId: UUID? = nil,
        userId: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.documentType = documentType
        self.fileName = fileName
        self.fileUrl = fileUrl
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.childId = childId
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Document Type

enum DocumentType: String, CaseIterable, Codable {
    case medical = "medical"
    case school = "school"
    case legal = "legal"
    case photo = "photo"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .medical:
            return "Médical"
        case .school:
            return "École"
        case .legal:
            return "Légal"
        case .photo:
            return "Photo"
        case .other:
            return "Autre"
        }
    }
    
    var icon: String {
        switch self {
        case .medical:
            return "stethoscope"
        case .school:
            return "book"
        case .legal:
            return "doc.text"
        case .photo:
            return "photo"
        case .other:
            return "doc"
        }
    }
    
    var color: Color {
        switch self {
        case .medical:
            return .red
        case .school:
            return .blue
        case .legal:
            return .purple
        case .photo:
            return .green
        case .other:
            return .gray
        }
    }
    
    var description: String {
        switch self {
        case .medical:
            return "Carnets de santé, ordonnances, résultats d'examens"
        case .school:
            return "Bulletins, certificats, autorisations scolaires"
        case .legal:
            return "Actes de naissance, passeports, documents officiels"
        case .photo:
            return "Photos de famille, souvenirs, événements"
        case .other:
            return "Autres documents importants"
        }
    }
}

// MARK: - Document Extensions

extension Document {
    
    // MARK: - Computed Properties
    
    var fileSizeText: String {
        guard let fileSize = fileSize else { return "Taille inconnue" }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSize))
    }
    
    var isImage: Bool {
        guard let mimeType = mimeType else { return false }
        return mimeType.hasPrefix("image/")
    }
    
    var isPDF: Bool {
        guard let mimeType = mimeType else { return false }
        return mimeType == "application/pdf"
    }
    
    var fileExtension: String {
        guard let fileName = fileName else { return "" }
        return (fileName as NSString).pathExtension.lowercased()
    }
    
    var displayFileName: String {
        return fileName ?? title
    }
    
    var createdDateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: createdAt)
    }
    
    var updatedDateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: updatedAt)
    }
    
    var isRecent: Bool {
        let daysSinceCreation = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
        return daysSinceCreation <= 7
    }
    
    // MARK: - File Type Detection
    
    var fileTypeIcon: String {
        if isImage {
            return "photo"
        } else if isPDF {
            return "doc.richtext"
        } else {
            switch fileExtension {
            case "doc", "docx":
                return "doc.text"
            case "xls", "xlsx":
                return "tablecells"
            case "ppt", "pptx":
                return "rectangle.on.rectangle"
            case "txt":
                return "doc.plaintext"
            case "zip", "rar":
                return "archivebox"
            default:
                return "doc"
            }
        }
    }
    
    var fileTypeColor: Color {
        if isImage {
            return .green
        } else if isPDF {
            return .red
        } else {
            switch fileExtension {
            case "doc", "docx":
                return .blue
            case "xls", "xlsx":
                return .green
            case "ppt", "pptx":
                return .orange
            case "txt":
                return .gray
            case "zip", "rar":
                return .purple
            default:
                return .secondary
            }
        }
    }
}

// MARK: - Sample Data

#if DEBUG
extension Document {
    static let sampleDocuments: [Document] = [
        Document(
            title: "Carnet de santé Emma",
            description: "Carnet de santé complet avec vaccinations",
            documentType: .medical,
            fileName: "carnet_sante_emma.pdf",
            fileSize: 2048000, // 2MB
            mimeType: "application/pdf",
            userId: UUID()
        ),
        Document(
            title: "Bulletin scolaire T1",
            description: "Premier trimestre - Très bon travail",
            documentType: .school,
            fileName: "bulletin_t1_2024.pdf",
            fileSize: 512000, // 512KB
            mimeType: "application/pdf",
            userId: UUID()
        ),
        Document(
            title: "Acte de naissance",
            description: "Copie intégrale de l'acte de naissance",
            documentType: .legal,
            fileName: "acte_naissance.pdf",
            fileSize: 1024000, // 1MB
            mimeType: "application/pdf",
            userId: UUID()
        ),
        Document(
            title: "Photo anniversaire 5 ans",
            description: "Fête d'anniversaire avec les amis",
            documentType: .photo,
            fileName: "anniversaire_5ans.jpg",
            fileSize: 3072000, // 3MB
            mimeType: "image/jpeg",
            userId: UUID()
        ),
        Document(
            title: "Autorisation sortie scolaire",
            description: "Sortie au musée des sciences",
            documentType: .school,
            fileName: "autorisation_sortie.pdf",
            fileSize: 256000, // 256KB
            mimeType: "application/pdf",
            userId: UUID()
        )
    ]
    
    static let sampleDocument = sampleDocuments[0]
}
#endif