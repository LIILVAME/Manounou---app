//
//  AddDocumentSheet.swift
//  Manounou
//
//  Created by Assistant on 17/08/2025.
//

import SwiftUI
import PhotosUI

struct AddDocumentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var documentsViewModel: DocumentsViewModel
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedChild: Child?
    @State private var documentType: Document.DocumentType = .medical
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations du document") {
                    TextField("Titre", text: $title)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Type", selection: $documentType) {
                        Text("Médical").tag(Document.DocumentType.medical)
                        Text("Scolaire").tag(Document.DocumentType.school)
                        Text("Administratif").tag(Document.DocumentType.administrative)
                        Text("Photo").tag(Document.DocumentType.photo)
                        Text("Autre").tag(Document.DocumentType.other)
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Enfant concerné") {
                    Picker("Sélectionner un enfant", selection: $selectedChild) {
                        Text("Document général").tag(nil as Child?)
                        ForEach(childrenViewModel.children, id: \.id) { child in
                            Text("\(child.firstName) \(child.lastName)")
                                .tag(child as Child?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Fichier") {
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .any(of: [.images, .not(.videos)])
                    ) {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                                .foregroundColor(.blue)
                            Text("Sélectionner un fichier")
                            Spacer()
                            if selectedPhoto != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Ajouter le document") {
                        addDocument()
                    }
                    .disabled(isLoading || title.isEmpty)
                }
            }
            .navigationTitle("Nouveau document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
            .alert("Document", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("succès") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func addDocument() {
        isLoading = true
        
        Task {
            do {
                // Simuler l'upload du fichier
                var fileURL: String?
                if selectedPhoto != nil {
                    // Simuler l'upload
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 seconde
                    fileURL = "https://example.com/documents/\(UUID().uuidString).jpg"
                }
                
                let newDocument = Document(
                    id: UUID(),
                    title: title,
                    description: description.isEmpty ? nil : description,
                    fileURL: fileURL,
                    fileName: selectedPhoto != nil ? "\(title).jpg" : nil,
                    fileSize: selectedPhoto != nil ? 1024000 : nil, // 1MB simulé
                    mimeType: selectedPhoto != nil ? "image/jpeg" : nil,
                    documentType: documentType,
                    childId: selectedChild?.id,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                await documentsViewModel.addDocument(newDocument)
                
                await MainActor.run {
                    alertMessage = "Document ajouté avec succès"
                    showingAlert = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Erreur lors de l'ajout du document"
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    AddDocumentSheet()
        .environmentObject(DocumentsViewModel())
        .environmentObject(ChildrenViewModel())
}