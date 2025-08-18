//
//  AddChildView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

struct AddChildView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    
    // Form fields
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var birthDate = Date()
    @State private var selectedGender: Gender? = nil
    @State private var notes = ""
    
    // UI state
    @State private var isLoading = false
    @State private var showingDatePicker = false
    @State private var showingGenderPicker = false
    
    // Validation
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.03) {
                        // Header illustration
                        headerIllustration(geometry: geometry)
                        
                        // Form fields
                        formFields(geometry: geometry)
                        
                        // Save button
                        saveButton(geometry: geometry)
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.top, geometry.size.height * 0.02)
                }
            }
            .navigationTitle("Nouvel enfant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
        .disabled(isLoading)
    }
    
    // MARK: - Header Illustration
    private func headerIllustration(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * 0.25,
                        height: geometry.size.width * 0.25
                    )
                
                Image(systemName: "person.badge.plus")
                    .font(.system(size: geometry.size.width * 0.1, weight: .light))
                    .foregroundColor(.blue)
            }
            
            Text("Ajoutez les informations de votre enfant")
                .font(.system(size: geometry.size.width * 0.045, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Form Fields
    private func formFields(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.025) {
            // First Name
            formField(
                title: "Prénom *",
                text: $firstName,
                placeholder: "Entrez le prénom",
                geometry: geometry
            )
            
            // Last Name
            formField(
                title: "Nom de famille *",
                text: $lastName,
                placeholder: "Entrez le nom de famille",
                geometry: geometry
            )
            
            // Birth Date
            birthDateField(geometry: geometry)
            
            // Gender
            genderField(geometry: geometry)
            
            // Notes
            notesField(geometry: geometry)
        }
    }
    
    // MARK: - Form Field Component
    private func formField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        geometry: GeometryProxy
    ) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
            Text(title)
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.primary)
            
            TextField(placeholder, text: text)
                .font(.system(size: geometry.size.width * 0.045, weight: .regular))
                .padding(geometry.size.width * 0.04)
                .background(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Birth Date Field
    private func birthDateField(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
            Text("Date de naissance *")
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.primary)
            
            Button(action: { showingDatePicker = true }) {
                HStack {
                    Text(DateFormatters.mediumDateFormatter.string(from: birthDate))
                        .font(.system(size: geometry.size.width * 0.045, weight: .regular))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(geometry.size.width * 0.04)
                .background(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationView {
                VStack {
                    DatePicker(
                        "Date de naissance",
                        selection: $birthDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Date de naissance")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Terminé") {
                            showingDatePicker = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Gender Field
    private func genderField(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
            Text("Genre (optionnel)")
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.primary)
            
            HStack(spacing: geometry.size.width * 0.03) {
                ForEach([Gender.male, Gender.female], id: \.self) { gender in
                    genderOption(gender: gender, geometry: geometry)
                }
                
                // Clear selection button
                if selectedGender != nil {
                    Button(action: { selectedGender = nil }) {
                        VStack(spacing: geometry.size.height * 0.01) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: geometry.size.width * 0.06, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Text("Aucun")
                                .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, geometry.size.height * 0.015)
                        .background(
                            RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Gender Option
    private func genderOption(gender: Gender, geometry: GeometryProxy) -> some View {
        Button(action: { selectedGender = gender }) {
            VStack(spacing: geometry.size.height * 0.01) {
                Image(systemName: gender.icon)
                    .font(.system(size: geometry.size.width * 0.06, weight: .medium))
                    .foregroundColor(selectedGender == gender ? .white : gender.color)
                
                Text(gender.displayName)
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(selectedGender == gender ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, geometry.size.height * 0.015)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                    .fill(selectedGender == gender ? gender.color : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Notes Field
    private func notesField(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
            Text("Notes (optionnel)")
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.primary)
            
            TextField(
                "Ajoutez des notes sur votre enfant...",
                text: $notes,
                axis: .vertical
            )
            .font(.system(size: geometry.size.width * 0.04, weight: .regular))
            .padding(geometry.size.width * 0.04)
            .frame(minHeight: geometry.size.height * 0.1)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Save Button
    private func saveButton(geometry: GeometryProxy) -> some View {
        Button(action: saveChild) {
            HStack(spacing: geometry.size.width * 0.03) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Text(isLoading ? "Enregistrement..." : "Ajouter l'enfant")
                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height * 0.07)
            .background(
                LinearGradient(
                    colors: isFormValid ? [Color.blue, Color.blue.opacity(0.8)] : [Color.gray, Color.gray.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(geometry.size.width * 0.04)
            .shadow(
                color: isFormValid ? Color.blue.opacity(0.3) : Color.clear,
                radius: geometry.size.width * 0.02,
                x: 0,
                y: geometry.size.width * 0.01
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isFormValid || isLoading)
        .padding(.top, geometry.size.height * 0.02)
    }
    
    // MARK: - Save Child Function
    private func saveChild() {
        guard isFormValid else { return }
        
        isLoading = true
        
        let newChild = Child(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate: birthDate,
            gender: selectedGender,
            profileImageURL: nil,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        Task {
            await childrenViewModel.createChild(newChild)
            
            await MainActor.run {
                isLoading = false
                
                // Check if there was an error
                if childrenViewModel.errorMessage == nil {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
struct AddChildView_Previews: PreviewProvider {
    static var previews: some View {
        AddChildView()
            .environmentObject(ChildrenViewModel(childrenService: MockChildrenService()))
    }
}
#endif