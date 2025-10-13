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
                    DocumentsList(
                        documents: filteredDocuments,
                        onDocumentSelected: { document in
                            selectedDocument = document
                        },
                        onDeleteDocuments: { offsets in
                            deleteDocuments(offsets: offsets)
                        }
                    )
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
                        await documentsViewModel.addDocument(newDocument)
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
    
    private func deleteDocuments(offsets: IndexSet) {
        Task {
            for index in offsets {
                let document = filteredDocuments[index]
                await documentsViewModel.deleteDocument(document.id)
            }
        }
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

// MARK: - Documents List Component
struct DocumentsList: View {
    let documents: [Document]
    let onDocumentSelected: (Document) -> Void
    let onDeleteDocuments: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(documents) { document in
                ModernDocumentRowView(document: document) {
                    onDocumentSelected(document)
                }
            }
            .onDelete(perform: onDeleteDocuments)
        }
        .listStyle(.insetGrouped)
        .accessibilityLabel("Liste des documents")
    }
}

// MARK: - Modern Document Row Component
struct ModernDocumentRowView: View {
    let document: Document
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Document Type Icon
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.sm)
                        .fill(documentTypeColor.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: documentTypeIcon)
                        .foregroundColor(documentTypeColor)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                // Document Details
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(document.title)
                        .font(AppTheme.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Text(document.documentType.displayName)
                            .font(AppTheme.Typography.footnote)
                            .foregroundColor(documentTypeColor)
                            .padding(.horizontal, AppTheme.Spacing.xs)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(documentTypeColor.opacity(0.1))
                            )
                        
                        Text(relativeDateText)
                            .font(AppTheme.Typography.footnote)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    if let description = document.description, !description.isEmpty {
                        Text(description)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // File Size (if available)
                if let fileSize = document.fileSize {
                    VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                        Text(formatFileSize(fileSize))
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }
            .padding(.vertical, AppTheme.Spacing.xs)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Document: \(document.title), type: \(document.documentType.displayName), créé \(relativeDateText)")
        .accessibilityHint("Appuyez pour voir les détails")
    }
    
    private var documentTypeColor: Color {
        switch document.documentType {
        case .medical: return AppTheme.Colors.success
        case .school: return AppTheme.Colors.primary
        case .legal: return AppTheme.Colors.warning
        case .other: return AppTheme.Colors.secondary
        }
    }
    
    private var documentTypeIcon: String {
        switch document.documentType {
        case .medical: return "cross.case.fill"
        case .school: return "graduationcap.fill"
        case .legal: return "doc.text.fill"
        case .other: return "doc.fill"
        }
    }
    
    private var relativeDateText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: document.createdAt, relativeTo: Date())
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
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
                    ThemedTextField(
                        "Titre",
                        text: $title,
                        placeholder: "Entrez le titre du document"
                    )
                    
                    ThemedTextField(
                        "Description",
                        text: $description,
                        placeholder: "Description optionnelle"
                    )
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
            childId: selectedChildId,
            filePath: nil, // TODO: Implement file handling
            fileSize: nil,
            mimeType: nil,
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
                    ThemedTextField(
                        "Titre",
                        text: $title,
                        placeholder: "Entrez le titre du document"
                    )
                    
                    ThemedTextField(
                        "Description",
                        text: $description,
                        placeholder: "Description optionnelle"
                    )
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
                    if let filePath = document.filePath {
                        HStack {
                            Text("Fichier actuel")
                            Spacer()
                            Text(URL(fileURLWithPath: filePath).lastPathComponent)
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
                            Text(formatFileSize(fileSize))
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
            childId: selectedChildId,
            filePath: document.filePath,
            fileSize: document.fileSize,
            mimeType: document.mimeType,
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

// MARK: - DocumentType Extension
extension DocumentType {
    var displayName: String {
        switch self {
        case .medical: return "Médical"
        case .school: return "École"
        case .legal: return "Légal"
        case .other: return "Autre"
        }
    }
}

// MARK: - Preview
#if DEBUG
struct ModernDocumentsView_Previews: PreviewProvider {
    static var previews: some View {
        ModernDocumentsView()
            .environmentObject(DocumentsViewModel(documentsService: MockDocumentsService()))
            .environmentObject(ChildrenViewModel(childrenService: MockChildrenService()))
            .preferredColorScheme(.light)
        
        ModernDocumentsView()
            .environmentObject(DocumentsViewModel(documentsService: MockDocumentsService()))
            .environmentObject(ChildrenViewModel(childrenService: MockChildrenService()))
            .preferredColorScheme(.dark)
    }
}
#endif