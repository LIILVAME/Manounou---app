//
//  ModernChildrenView.swift
//  Manounou
//
//  Created by Assistant on 18/08/2025.
//  Modern refactored version of ChildrenView with NavigationStack
//

import SwiftUI

struct ModernChildrenView: View {
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @State private var showingAddChild = false
    @State private var selectedChild: Child? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                if childrenViewModel.children.isEmpty {
                    EmptyChildrenView {
                        showingAddChild = true
                    }
                } else {
                    ChildrenListView(
                        children: childrenViewModel.children,
                        onChildSelected: { child in
                            selectedChild = child
                        },
                        onDeleteChildren: { offsets in
                            deleteChildren(offsets: offsets)
                        }
                    )
                }
            }
            .navigationTitle("Enfants")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AddChildButton {
                        showingAddChild = true
                    }
                }
            }
            .sheet(isPresented: $showingAddChild) {
                AddChildSheet { newChild in
                    Task {
                        await childrenViewModel.addChild(newChild)
                    }
                }
            }
            .sheet(item: $selectedChild) { child in
                ChildDetailSheet(child: child) { updatedChild in
                    Task {
                        await childrenViewModel.updateChild(updatedChild)
                    }
                }
            }
            .task {
                await childrenViewModel.loadChildren()
            }
            .refreshable {
                await childrenViewModel.loadChildren()
            }
        }
    }
    
    private func deleteChildren(offsets: IndexSet) {
        Task {
            for index in offsets {
                let child = childrenViewModel.children[index]
                await childrenViewModel.deleteChild(child.id)
            }
        }
    }
}

// MARK: - Empty State Component
struct EmptyChildrenView: View {
    let onAddChild: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: AppTheme.Icons.children)
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.primary)
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Aucun enfant ajouté")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("Commencez par ajouter le profil de votre premier enfant")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }
            
            Button("Ajouter un enfant", action: onAddChild)
                .themedButton(style: .primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Aucun enfant ajouté. Commencez par ajouter le profil de votre premier enfant")
        .accessibilityAction(named: "Ajouter un enfant", onAddChild)
    }
}

// MARK: - Children List Component
struct ChildrenListView: View {
    let children: [Child]
    let onChildSelected: (Child) -> Void
    let onDeleteChildren: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(children) { child in
                ModernChildRowView(child: child) {
                    onChildSelected(child)
                }
            }
            .onDelete(perform: onDeleteChildren)
        }
        .listStyle(.insetGrouped)
        .accessibilityLabel("Liste des enfants")
    }
}

// MARK: - Modern Child Row Component
struct ModernChildRowView: View {
    let child: Child
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    genderColor.opacity(0.3),
                                    genderColor.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Text(child.initials)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(genderColor)
                }
                
                // Child Info
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(child.fullName)
                        .font(AppTheme.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(child.formattedAge)
                        .font(AppTheme.Typography.footnote)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    if let notes = child.notes, !notes.isEmpty {
                        Text(notes)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
            .padding(.vertical, AppTheme.Spacing.xs)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Enfant: \(child.fullName), âge: \(child.formattedAge)")
        .accessibilityHint("Appuyez pour voir les détails")
    }
    
    private var genderColor: Color {
        switch child.gender {
        case .male:
            return AppTheme.Colors.genderMale
        case .female:
            return AppTheme.Colors.genderFemale
        case .other:
            return AppTheme.Colors.genderOther
        }
    }
}

// MARK: - Add Child Button Component
struct AddChildButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(AppTheme.Colors.primary)
        }
        .accessibilityLabel("Ajouter un enfant")
        .accessibilityHint("Ouvre le formulaire pour ajouter un nouvel enfant")
    }
}

// MARK: - Add Child Sheet Component
struct AddChildSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Child) -> Void
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var birthDate = Date()
    @State private var gender = Gender.other
    @State private var notes = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations personnelles") {
                    ThemedTextField(
                        "Prénom",
                        text: $firstName,
                        placeholder: "Entrez le prénom"
                    )
                    
                    ThemedTextField(
                        "Nom",
                        text: $lastName,
                        placeholder: "Entrez le nom de famille"
                    )
                    
                    DatePicker(
                        "Date de naissance",
                        selection: $birthDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .font(AppTheme.Typography.body)
                    
                    Picker("Genre", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { genderOption in
                            Text(genderOption.displayName).tag(genderOption)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Notes (optionnel)") {
                    TextField(
                        "Ajoutez des notes...",
                        text: $notes,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                    .font(AppTheme.Typography.body)
                }
            }
            .navigationTitle("Nouvel enfant")
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
                        saveChild()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .disabled(firstName.isEmpty || lastName.isEmpty || isLoading)
                }
            }
        }
        .interactiveDismissDisabled(isLoading)
    }
    
    private func saveChild() {
        isLoading = true
        
        let newChild = Child(
            id: UUID(),
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate: birthDate,
            gender: gender,
            notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: Date(),
            updatedAt: Date()
        )
        
        onSave(newChild)
        dismiss()
    }
}

// MARK: - Child Detail Sheet Component
struct ChildDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let child: Child
    let onSave: (Child) -> Void
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var birthDate: Date
    @State private var gender: Gender
    @State private var notes: String
    @State private var isLoading = false
    
    init(child: Child, onSave: @escaping (Child) -> Void) {
        self.child = child
        self.onSave = onSave
        self._firstName = State(initialValue: child.firstName)
        self._lastName = State(initialValue: child.lastName)
        self._birthDate = State(initialValue: child.birthDate)
        self._gender = State(initialValue: child.gender)
        self._notes = State(initialValue: child.notes ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations personnelles") {
                    ThemedTextField(
                        "Prénom",
                        text: $firstName,
                        placeholder: "Entrez le prénom"
                    )
                    
                    ThemedTextField(
                        "Nom",
                        text: $lastName,
                        placeholder: "Entrez le nom de famille"
                    )
                    
                    DatePicker(
                        "Date de naissance",
                        selection: $birthDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .font(AppTheme.Typography.body)
                    
                    Picker("Genre", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { genderOption in
                            Text(genderOption.displayName).tag(genderOption)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Notes") {
                    TextField(
                        "Ajoutez des notes...",
                        text: $notes,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                    .font(AppTheme.Typography.body)
                }
                
                Section("Informations") {
                    HStack {
                        Text("Âge")
                        Spacer()
                        Text(child.formattedAge)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    HStack {
                        Text("Créé le")
                        Spacer()
                        Text(child.createdAt, style: .date)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
            }
            .navigationTitle("Modifier l'enfant")
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
                        saveChild()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .disabled(firstName.isEmpty || lastName.isEmpty || isLoading)
                }
            }
        }
        .interactiveDismissDisabled(isLoading)
    }
    
    private func saveChild() {
        isLoading = true
        
        let updatedChild = Child(
            id: child.id,
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate: birthDate,
            gender: gender,
            notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: child.createdAt,
            updatedAt: Date()
        )
        
        onSave(updatedChild)
        dismiss()
    }
}

// MARK: - Gender Extension
extension Gender {
    var displayName: String {
        switch self {
        case .male: return "Garçon"
        case .female: return "Fille"
        case .other: return "Autre"
        }
    }
}

// MARK: - Preview
#if DEBUG
struct ModernChildrenView_Previews: PreviewProvider {
    static var previews: some View {
        ModernChildrenView()
            .environmentObject(ChildrenViewModel(childrenService: MockChildrenService()))
            .preferredColorScheme(.light)
        
        ModernChildrenView()
            .environmentObject(ChildrenViewModel(childrenService: MockChildrenService()))
            .preferredColorScheme(.dark)
    }
}
#endif