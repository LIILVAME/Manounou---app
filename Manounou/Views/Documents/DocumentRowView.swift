import SwiftUI

// MARK: - Document Row View
struct DocumentRowView: View, Equatable {
    let document: FunctionalDocument
    
    static func == (lhs: DocumentRowView, rhs: DocumentRowView) -> Bool {
        lhs.document.id == rhs.document.id &&
        lhs.document.title == rhs.document.title &&
        lhs.document.dateAdded == rhs.document.dateAdded &&
        lhs.document.size == rhs.document.size
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Document Type Icon
            RoundedRectangle(cornerRadius: 12)
                .fill(documentTypeColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    VStack(spacing: 2) {
                        Image(systemName: documentTypeIcon)
                            .font(.title3)
                            .foregroundColor(documentTypeColor)
                        
                        Text(document.type.uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(documentTypeColor)
                    }
                )
            
            // Document Info
            VStack(alignment: .leading, spacing: 4) {
                Text(document.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Image(systemName: "folder")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(document.category.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(document.size)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(document.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if document.isRecent {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Récent")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Spacer()
            
            // Status indicator
            VStack(alignment: .trailing, spacing: 4) {
                if document.isRecent {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    private var documentTypeColor: Color {
        switch document.type.lowercased() {
        case "pdf":
            return .red
        case "jpg", "jpeg", "png":
            return .blue
        case "doc", "docx":
            return .indigo
        case "xls", "xlsx":
            return .green
        default:
            return .orange
        }
    }
    
    private var documentTypeIcon: String {
        switch document.type.lowercased() {
        case "pdf":
            return "doc.text.fill"
        case "jpg", "jpeg", "png":
            return "photo.fill"
        case "doc", "docx":
            return "doc.text"
        case "xls", "xlsx":
            return "tablecells"
        default:
            return "doc"
        }
    }
}

// MARK: - FunctionalDocument Extensions
extension FunctionalDocument {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        
        if Calendar.current.isDateInToday(dateAdded) {
            return "Aujourd'hui"
        } else if Calendar.current.isDateInYesterday(dateAdded) {
            return "Hier"
        } else if Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.contains(dateAdded) == true {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: dateAdded)
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: dateAdded)
        }
    }
    
    var isRecent: Bool {
        let daysSinceAdded = Calendar.current.dateComponents([.day], from: dateAdded, to: Date()).day ?? 0
        return daysSinceAdded <= 7
    }
    
    var sizeInBytes: Int {
        let components = size.components(separatedBy: " ")
        guard let value = Double(components.first ?? "0") else { return 0 }
        
        let unit = components.last?.uppercased() ?? "B"
        switch unit {
        case "KB":
            return Int(value * 1024)
        case "MB":
            return Int(value * 1024 * 1024)
        case "GB":
            return Int(value * 1024 * 1024 * 1024)
        default:
            return Int(value)
        }
    }
}

// MARK: - Preview
struct DocumentRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            DocumentRowView(
                document: FunctionalDocument(
                    id: UUID(),
                    title: "Certificat de naissance",
                    type: "PDF",
                    size: "2.3 MB",
                    dateAdded: Date(),
                    category: .medical
                )
            )
            
            DocumentRowView(
                document: FunctionalDocument(
                    id: UUID(),
                    title: "Photo d'identité",
                    type: "JPG",
                    size: "0.3 MB",
                    dateAdded: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                    category: .identity
                )
            )
            
            DocumentRowView(
                document: FunctionalDocument(
                    id: UUID(),
                    title: "Bulletin scolaire",
                    type: "PDF",
                    size: "0.9 MB",
                    dateAdded: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
                    category: .education
                )
            )
        }
        .listStyle(PlainListStyle())
    }
}