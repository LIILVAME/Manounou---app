//
//  DocumentCardView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

struct DocumentCardView: View {
    let document: Document
    let geometry: GeometryProxy
    let onTap: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: geometry.size.height * 0.015) {
                // Document preview
                documentPreview
                
                // Document info
                documentInfo
            }
            .padding(geometry.size.width * 0.04)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: geometry.size.width * 0.01,
                        x: 0,
                        y: geometry.size.width * 0.005
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Document Preview
    private var documentPreview: some View {
        VStack(spacing: geometry.size.height * 0.01) {
            // File type icon and actions
            HStack {
                Spacer()
                
                // Edit button
                Button(action: onEdit) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(
                            width: geometry.size.width * 0.07,
                            height: geometry.size.width * 0.07
                        )
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Main file icon
            ZStack {
                RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                    .fill(
                        LinearGradient(
                            colors: [document.documentType.color.opacity(0.2), document.documentType.color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * 0.25,
                        height: geometry.size.width * 0.3
                    )
                
                VStack(spacing: geometry.size.height * 0.008) {
                    // File type icon
                    Image(systemName: document.fileTypeIcon)
                        .font(.system(size: geometry.size.width * 0.08, weight: .medium))
                        .foregroundColor(document.fileTypeColor)
                    
                    // File extension
                    if !document.fileExtension.isEmpty {
                        Text(document.fileExtension.uppercased())
                            .font(.system(size: geometry.size.width * 0.025, weight: .bold))
                            .foregroundColor(document.fileTypeColor)
                    }
                }
            }
            
            // Document type badge
            HStack(spacing: geometry.size.width * 0.015) {
                Image(systemName: document.documentType.icon)
                    .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                    .foregroundColor(document.documentType.color)
                
                Text(document.documentType.displayName)
                    .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                    .foregroundColor(document.documentType.color)
            }
            .padding(.horizontal, geometry.size.width * 0.02)
            .padding(.vertical, geometry.size.height * 0.005)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.015)
                    .fill(document.documentType.color.opacity(0.1))
            )
        }
    }
    
    // MARK: - Document Info
    private var documentInfo: some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.008) {
            // Title
            Text(document.title)
                .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Description or filename
            if let description = document.description, !description.isEmpty {
                Text(description)
                    .font(.system(size: geometry.size.width * 0.032, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if let fileName = document.fileName {
                Text(fileName)
                    .font(.system(size: geometry.size.width * 0.032, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // File info
            VStack(alignment: .leading, spacing: geometry.size.height * 0.003) {
                // File size
                Text(document.fileSizeText)
                    .font(.system(size: geometry.size.width * 0.028, weight: .medium))
                    .foregroundColor(.secondary)
                
                // Created date
                Text(relativeDateText)
                    .font(.system(size: geometry.size.width * 0.028, weight: .regular))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Status indicators
            HStack(spacing: geometry.size.width * 0.02) {
                // Recent indicator
                if document.isRecent {
                    HStack(spacing: geometry.size.width * 0.01) {
                        Circle()
                            .fill(Color.green)
                            .frame(
                                width: geometry.size.width * 0.015,
                                height: geometry.size.width * 0.015
                            )
                        
                        Text("Récent")
                            .font(.system(size: geometry.size.width * 0.025, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                // File type indicator
                if document.isImage {
                    Image(systemName: "photo")
                        .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                        .foregroundColor(.green)
                } else if document.isPDF {
                    Image(systemName: "doc.richtext")
                        .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var relativeDateText: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(document.createdAt) {
            return "Aujourd'hui"
        } else if calendar.isDateInYesterday(document.createdAt) {
            return "Hier"
        } else {
            let daysDifference = calendar.dateComponents([.day], from: document.createdAt, to: now).day ?? 0
            
            if daysDifference <= 7 {
                return "Il y a \(daysDifference) jour(s)"
            } else if daysDifference <= 30 {
                let weeks = daysDifference / 7
                return "Il y a \(weeks) semaine(s)"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.locale = Locale(identifier: "fr_FR")
                return formatter.string(from: document.createdAt)
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
struct DocumentCardView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2),
                spacing: 16
            ) {
                ForEach(Document.sampleDocuments, id: \.id) { document in
                    DocumentCardView(
                        document: document,
                        geometry: geometry,
                        onTap: {
                            Logger.info("Document tapped", category: .ui)
                        },
                        onEdit: {
                            Logger.info("Document edit action triggered", category: .ui)
                        }
                    )
                }
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif