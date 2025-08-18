//
//  DocumentsView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI
import PhotosUI

struct DocumentsView: View {
    @EnvironmentObject var documentsViewModel: DocumentsViewModel
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @State private var showingAddDocument = false
    @State private var selectedDocumentType: DocumentType? = nil
    @State private var selectedChild: Child? = nil
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header with filters
                    headerSection(geometry: geometry)
                    
                    // Content
                    if filteredDocuments.isEmpty {
                        if documentsViewModel.documents.isEmpty {
                            // Empty state
                            emptyState(geometry: geometry)
                        } else {
                            // No results from filters
                            noResultsView(geometry: geometry)
                        }
                    } else {
                        // Documents grid
                        documentsGrid(geometry: geometry)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddDocument) {
            AddDocumentView()
                .environmentObject(documentsViewModel)
                .environmentObject(childrenViewModel)
        }
        .onAppear {
            Task {
                await documentsViewModel.loadDocuments()
            }
        }
    }
    
    // MARK: - Header Section
    private func headerSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            // Title and add button
            HStack {
                VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                    Text("Documents")
                        .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if !documentsViewModel.documents.isEmpty {
                        Text("\(documentsViewModel.documents.count) document(s)")
                            .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Add button
                Button(action: { showingAddDocument = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(
                            width: geometry.size.width * 0.12,
                            height: geometry.size.width * 0.12
                        )
                        .background(
                            Circle()
                                .fill(Color.blue)
                        )
                        .shadow(
                            color: Color.blue.opacity(0.3),
                            radius: geometry.size.width * 0.02,
                            x: 0,
                            y: geometry.size.width * 0.01
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Rechercher un document...", text: $searchText)
                    .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(geometry.size.width * 0.04)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                    .fill(Color(.systemGray6))
            )
            
            // Filters
            filtersSection(geometry: geometry)
        }
        .padding(.horizontal, geometry.size.width * 0.05)
        .padding(.top, geometry.size.height * 0.02)
    }
    
    // MARK: - Filters Section
    private func filtersSection(geometry: GeometryProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: geometry.size.width * 0.03) {
                // Document type filter
                Menu {
                    Button("Tous les types") {
                        selectedDocumentType = nil
                    }
                    
                    ForEach(DocumentType.allCases, id: \.self) { docType in
                        Button(docType.displayName) {
                            selectedDocumentType = docType
                        }
                    }
                } label: {
                    filterButton(
                        title: selectedDocumentType?.displayName ?? "Type",
                        icon: selectedDocumentType?.icon ?? "tag",
                        isSelected: selectedDocumentType != nil,
                        geometry: geometry
                    )
                }
                
                // Child filter
                Menu {
                    Button("Tous les enfants") {
                        selectedChild = nil
                    }
                    
                    ForEach(childrenViewModel.children, id: \.id) { child in
                        Button(child.fullName) {
                            selectedChild = child
                        }
                    }
                } label: {
                    filterButton(
                        title: selectedChild?.firstName ?? "Enfant",
                        icon: "person",
                        isSelected: selectedChild != nil,
                        geometry: geometry
                    )
                }
                
                // Clear filters
                if selectedDocumentType != nil || selectedChild != nil {
                    Button(action: clearFilters) {
                        filterButton(
                            title: "Effacer",
                            icon: "xmark",
                            isSelected: false,
                            geometry: geometry
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, geometry.size.width * 0.05)
        }
    }
    
    // MARK: - Filter Button
    private func filterButton(
        title: String,
        icon: String,
        isSelected: Bool,
        geometry: GeometryProxy
    ) -> some View {
        HStack(spacing: geometry.size.width * 0.02) {
            Image(systemName: icon)
                .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                .foregroundColor(isSelected ? .white : .blue)
            
            Text(title)
                .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                .foregroundColor(isSelected ? .white : .blue)
                .lineLimit(1)
        }
        .padding(.horizontal, geometry.size.width * 0.03)
        .padding(.vertical, geometry.size.height * 0.01)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
        )
    }
    
    // MARK: - Documents Grid
    private func documentsGrid(geometry: GeometryProxy) -> some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: geometry.size.width * 0.03), count: 2),
                spacing: geometry.size.height * 0.02
            ) {
                ForEach(filteredDocuments, id: \.id) { document in
                    DocumentCardView(
                        document: document,
                        geometry: geometry,
                        onTap: {
                            // TODO: Show document details
                        },
                        onEdit: {
                            // TODO: Edit document
                        }
                    )
                }
            }
            .padding(.horizontal, geometry.size.width * 0.05)
            .padding(.top, geometry.size.height * 0.02)
        }
        .refreshable {
            await documentsViewModel.loadDocuments()
        }
    }
    
    // MARK: - Empty State
    private func emptyState(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.03) {
            Spacer()
            
            // Illustration
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * 0.3,
                        height: geometry.size.width * 0.3
                    )
                
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: geometry.size.width * 0.12, weight: .light))
                    .foregroundColor(.purple)
            }
            
            // Message
            VStack(spacing: geometry.size.height * 0.015) {
                Text("Aucun document ajouté")
                    .font(.system(size: geometry.size.width * 0.06, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Ajoutez vos premiers documents pour organiser vos fichiers familiaux")
                    .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(.horizontal, geometry.size.width * 0.08)
            
            // Add button
            Button(action: { showingAddDocument = true }) {
                HStack(spacing: geometry.size.width * 0.03) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Ajouter un document")
                        .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height * 0.07)
                .background(
                    LinearGradient(
                        colors: [Color.purple, Color.purple.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(geometry.size.width * 0.04)
                .shadow(
                    color: Color.purple.opacity(0.3),
                    radius: geometry.size.width * 0.02,
                    x: 0,
                    y: geometry.size.width * 0.01
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, geometry.size.width * 0.06)
            
            Spacer()
        }
    }
    
    // MARK: - No Results View
    private func noResultsView(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: geometry.size.width * 0.1, weight: .light))
                .foregroundColor(.secondary)
            
            Text("Aucun résultat")
                .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Essayez de modifier vos filtres")
                .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                .foregroundColor(.secondary)
            
            Button("Effacer les filtres") {
                clearFilters()
                searchText = ""
            }
            .foregroundColor(.blue)
            
            Spacer()
        }
    }
    
    // MARK: - Helper Functions
    private func clearFilters() {
        selectedDocumentType = nil
        selectedChild = nil
    }
    
    // MARK: - Computed Properties
    private var filteredDocuments: [Document] {
        var documents = documentsViewModel.documents
        
        // Apply search filter
        if !searchText.isEmpty {
            documents = documents.filter { document in
                document.title.localizedCaseInsensitiveContains(searchText) ||
                (document.description?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (document.fileName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Apply document type filter
        if let selectedDocumentType = selectedDocumentType {
            documents = documents.filter { $0.documentType == selectedDocumentType }
        }
        
        // Apply child filter
        if let selectedChild = selectedChild {
            documents = documents.filter { $0.childId == selectedChild.id }
        }
        
        return documents.sorted { $0.createdAt > $1.createdAt }
    }
}

// MARK: - Preview
#if DEBUG
struct DocumentsView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsView()
            .environmentObject(DocumentsViewModel(documentsService: MockDocumentsService()))
            .environmentObject(ChildrenViewModel(childrenService: MockChildrenService()))
    }
}
#endif