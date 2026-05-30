//
//  ModernDocumentsView.swift
//  Manounou
//
//  Created by Assistant on 18/08/2025.
//  Modern refactored version of DocumentsView with NavigationStack
//

import SwiftUI

struct ModernDocumentsView: View {
    @EnvironmentObject var documentsViewModel: DocumentsViewModel
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @State private var showingAddDocument = false
    @State private var selectedDocument: Document? = nil
    @State private var searchText = ""
    @State private var selectedFilter: DocumentType? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and Filter Bar
                SearchAndFilterBar(
                    searchText: $searchText,
                    selectedFilter: $selectedFilter
                )
                
                // Documents Content
                if filteredDocuments.isEmpty {
                    if documentsViewModel.documents.isEmpty {
                        EmptyDocumentsView {
                            showingAddDocument = true
                        }
                    } else {
                        NoResultsView(searchText: searchText)
                    }
                } else {
                    groupedDocuments
                }
            }
            .navigationTitle("Documents")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AddDocumentButton {
                        showingAddDocument = true
                    }
                }
            }
            .sheet(isPresented: $showingAddDocument) {
                AddDocumentSheet(children: childrenViewModel.children) { newDocument in
                    Task {
                        await documentsViewModel.createDocument(newDocument)
                    }
                }
            }
            .sheet(item: $selectedDocument) { document in
                DocumentDetailSheet(
                    document: document,
                    children: childrenViewModel.children
                ) { updatedDocument in
                    Task {
                        await documentsViewModel.updateDocument(updatedDocument)
                    }
                }
            }
            .task {
                await loadData()
            }
            .refreshable {
                await loadData()
            }
        }
        .searchable(text: $searchText, prompt: "Rechercher des documents...")
    }
    
    private var filteredDocuments: [Document] {
        var documents = documentsViewModel.documents
        
        // Filter by search text
        if !searchText.isEmpty {
            documents = documents.filter { document in
                document.title.localizedCaseInsensitiveContains(searchText) ||
                (document.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Filter by document type
        if let selectedFilter = selectedFilter {
            documents = documents.filter { $0.documentType == selectedFilter }
        }
        
        return documents.sorted { $0.createdAt > $1.createdAt }
    }
    
    private func loadData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await documentsViewModel.loadDocuments() }
            group.addTask { await childrenViewModel.loadChildren() }
        }
    }
    
    // MARK: - Grouped documents (cf. « Focus Documents » : sections par catégorie)

    private var groupedDocuments: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                ForEach(DocCategory.ordered, id: \.self) { category in
                    let docs = filteredDocuments.filter { DocCategory.from($0.documentType) == category }
                    if !docs.isEmpty {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text(category.label.uppercased())
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .foregroundColor(AppTheme.Colors.muted)
                                .tracking(1)
                                .padding(.leading, 4)

                            VStack(spacing: 0) {
                                ForEach(Array(docs.enumerated()), id: \.element.id) { idx, doc in
                                    DocCategoryRow(document: doc, category: category) {
                                        selectedDocument = doc
                                    }
                                    if idx < docs.count - 1 {
                                        Rectangle()
                                            .fill(AppTheme.Colors.divider)
                                            .frame(height: 1)
                                            .padding(.leading, 64)
                                    }
                                }
                            }
                            .background(AppTheme.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
                            .shadow(color: AppTheme.Shadow.small.color,
                                    radius: AppTheme.Shadow.small.radius,
                                    x: AppTheme.Shadow.small.x,
                                    y: AppTheme.Shadow.small.y)
                        }
                    }
                }

                // Bouton « Ajouter un document » en pointillé (design .dashed)
                Button {
                    showingAddDocument = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                        Text("Ajouter un document")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(AppTheme.Colors.brand)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(RoundedRectangle(cornerRadius: 15).fill(AppTheme.Colors.brandGhost))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.8, dash: [6, 4]))
                            .foregroundColor(AppTheme.Colors.brand)
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, AppTheme.Spacing.xs)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.sm)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
        .background(AppTheme.Colors.paper.ignoresSafeArea())
    }
}

// MARK: - Document category (mappe DocumentType → catégorie du design)

enum DocCategory: Hashable {
    case sante, autorisations, scolaire, administratif, souvenirs

    static let ordered: [DocCategory] = [.sante, .autorisations, .scolaire, .administratif, .souvenirs]

    static func from(_ type: DocumentType) -> DocCategory {
        switch type {
        case .medical: return .sante
        case .legal:   return .autorisations
        case .school:  return .scolaire
        case .photo:   return .souvenirs
        case .other:   return .administratif
        }
    }

    var label: String {
        switch self {
        case .sante:         return "Santé"
        case .autorisations: return "Autorisations"
        case .scolaire:      return "Scolaire"
        case .administratif: return "Administratif"
        case .souvenirs:     return "Souvenirs"
        }
    }

    var color: Color {
        switch self {
        case .sante:         return AppTheme.Colors.green
        case .autorisations: return AppTheme.Colors.brand
        case .scolaire:      return AppTheme.Colors.blue
        case .administratif: return AppTheme.Colors.blue
        case .souvenirs:     return AppTheme.Colors.purple
        }
    }

    var icon: String {
        switch self {
        case .sante:         return "cross.case.fill"
        case .autorisations: return "checkmark.seal.fill"
        case .scolaire:      return "graduationcap.fill"
        case .administratif: return "doc.text.fill"
        case .souvenirs:     return "photo.fill"
        }
    }
}

// MARK: - DocCategoryRow

private struct DocCategoryRow: View {
    let document: Document
    let category: DocCategory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 11)
                    .fill(category.color)
                    .frame(width: 38, height: 38)
                    .overlay(
                        Image(systemName: category.icon)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    )
                VStack(alignment: .leading, spacing: 1) {
                    Text(document.title)
                        .font(.system(size: 14.5, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.Colors.ink)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.Colors.muted)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.Colors.muted.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var subtitle: String {
        if let desc = document.description, !desc.isEmpty { return desc }
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "fr_FR")
        fmt.dateFormat = "d MMM yyyy"
        return "Ajouté le \(fmt.string(from: document.createdAt))"
    }
}

// MARK: - Search and Filter Bar Component
struct SearchAndFilterBar: View {
    @Binding var searchText: String
    @Binding var selectedFilter: DocumentType?
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    FilterPill(
                        title: "Tous",
                        isSelected: selectedFilter == nil
                    ) {
                        selectedFilter = nil
                    }
                    
                    ForEach(DocumentType.allCases, id: \.self) { type in
                        FilterPill(
                            title: type.displayName,
                            isSelected: selectedFilter == type
                        ) {
                            selectedFilter = selectedFilter == type ? nil : type
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.surface)
    }
}

// MARK: - Filter Pill Component
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.callout)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : AppTheme.Colors.textPrimary)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                        .fill(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surfaceSecondary)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Filtre: \(title)")
        .accessibilityHint(isSelected ? "Actuellement sélectionné" : "Appuyez pour filtrer")
    }
}

// MARK: - Empty Documents Component
struct EmptyDocumentsView: View {
    let onAddDocument: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: AppTheme.Icons.documents)
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.primary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Aucun document")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("Organisez vos documents importants en un seul endroit")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }
            
            Button("Ajouter un document", action: onAddDocument)
                .themedButton(style: .primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Aucun document. Organisez vos documents importants en un seul endroit")
        .accessibilityAction(named: "Ajouter un document", onAddDocument)
    }
}

// MARK: - No Results Component
struct NoResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.textTertiary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Aucun résultat")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Text("Aucun document trouvé pour \"\(searchText)\"")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppTheme.Spacing.xl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Aucun résultat trouvé pour \(searchText)")
    }
}

// MARK: - Add Document Button Component
struct AddDocumentButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(AppTheme.Colors.primary)
        }
        .accessibilityLabel("Ajouter un document")
        .accessibilityHint("Ouvre le formulaire pour ajouter un nouveau document")
    }
}

// MARK: - Add Document Sheet Component
struct AddDocumentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let children: [Child]
    let onSave: (Document) -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var documentType = DocumentType.other
    @State private var selectedChildId: UUID? = nil
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations du document") {
                    TextField("Entrez le titre du document", text: $title)

                    TextField("Description optionnelle", text: $description)
                }
                
                Section("Catégorie") {
                    Picker("Type de document", selection: $documentType) {
                        ForEach(DocumentType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                if !children.isEmpty {
                    Section("Associer à un enfant") {
                        Picker("Enfant", selection: $selectedChildId) {
                            Text("Aucun enfant").tag(nil as UUID?)
                            ForEach(children) { child in
                                Text(child.fullName).tag(child.id as UUID?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Fichier") {
                    Button("Sélectionner un fichier") {
                        // TODO: Implement file picker
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .navigationTitle("Nouveau document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        saveDocument()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .disabled(title.isEmpty || isLoading)
                }
            }
        }
        .interactiveDismissDisabled(isLoading)
    }
    
    private func saveDocument() {
        isLoading = true
        
        let newDocument = Document(
            id: UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            documentType: documentType,
            fileName: nil,
            fileUrl: nil, // TODO: Implement file handling
            fileSize: nil,
            mimeType: nil,
            childId: selectedChildId,
            userId: UUID(), // TODO: inject current user id
            createdAt: Date(),
            updatedAt: Date()
        )
        
        onSave(newDocument)
        dismiss()
    }
}

// MARK: - Document Detail Sheet Component
struct DocumentDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let document: Document
    let children: [Child]
    let onSave: (Document) -> Void
    
    @State private var title: String
    @State private var description: String
    @State private var documentType: DocumentType
    @State private var selectedChildId: UUID?
    @State private var isLoading = false
    
    init(document: Document, children: [Child], onSave: @escaping (Document) -> Void) {
        self.document = document
        self.children = children
        self.onSave = onSave
        self._title = State(initialValue: document.title)
        self._description = State(initialValue: document.description ?? "")
        self._documentType = State(initialValue: document.documentType)
        self._selectedChildId = State(initialValue: document.childId)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations du document") {
                    TextField("Entrez le titre du document", text: $title)

                    TextField("Description optionnelle", text: $description)
                }
                
                Section("Catégorie") {
                    Picker("Type de document", selection: $documentType) {
                        ForEach(DocumentType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                if !children.isEmpty {
                    Section("Associer à un enfant") {
                        Picker("Enfant", selection: $selectedChildId) {
                            Text("Aucun enfant").tag(nil as UUID?)
                            ForEach(children) { child in
                                Text(child.fullName).tag(child.id as UUID?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Fichier") {
                    if let fileName = document.fileName {
                        HStack {
                            Text("Fichier actuel")
                            Spacer()
                            Text(fileName)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                    
                    Button("Remplacer le fichier") {
                        // TODO: Implement file picker
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                }
                
                Section("Informations") {
                    HStack {
                        Text("Créé le")
                        Spacer()
                        Text(document.createdAt, style: .date)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    if document.updatedAt != document.createdAt {
                        HStack {
                            Text("Modifié le")
                            Spacer()
                            Text(document.updatedAt, style: .date)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                    
                    if let fileSize = document.fileSize {
                        HStack {
                            Text("Taille du fichier")
                            Spacer()
                            Text(formatFileSize(Int64(fileSize)))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                }
            }
            .navigationTitle("Modifier le document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        saveDocument()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .disabled(title.isEmpty || isLoading)
                }
            }
        }
        .interactiveDismissDisabled(isLoading)
    }
    
    private func saveDocument() {
        isLoading = true
        
        let updatedDocument = Document(
            id: document.id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            documentType: documentType,
            fileName: document.fileName,
            fileUrl: document.fileUrl,
            fileSize: document.fileSize,
            mimeType: document.mimeType,
            childId: selectedChildId,
            userId: document.userId,
            createdAt: document.createdAt,
            updatedAt: Date()
        )
        
        onSave(updatedDocument)
        dismiss()
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

