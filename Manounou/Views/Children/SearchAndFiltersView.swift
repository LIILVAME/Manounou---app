//
//  SearchAndFiltersView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

struct SearchAndFiltersView: View {
    @Binding var searchText: String
    @Binding var selectedGenderFilter: Gender?
    @Binding var selectedAgeCategoryFilter: AgeCategory?
    @Binding var sortOption: SortOption
    @State private var showingFilterSheet = false
    let geometry: GeometryProxy
    let onClearFilters: () -> Void
    
    var hasActiveFilters: Bool {
        selectedGenderFilter != nil || selectedAgeCategoryFilter != nil || !searchText.isEmpty
    }
    
    var body: some View {
        VStack(spacing: geometry.size.height * 0.015) {
            // Barre de recherche principale
            searchBar
            
            // Filtres rapides et boutons
            filtersRow
        }
        .sheet(isPresented: $showingFilterSheet) {
            AdvancedFiltersSheet(
                selectedGenderFilter: $selectedGenderFilter,
                selectedAgeCategoryFilter: $selectedAgeCategoryFilter,
                sortOption: $sortOption,
                geometry: geometry,
                onClearAll: onClearFilters
            )
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: geometry.size.width * 0.03) {
            HStack(spacing: geometry.size.width * 0.03) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Rechercher un enfant...", text: $searchText)
                    .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                    .textFieldStyle(PlainTextFieldStyle())
                    .submitLabel(.search)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, geometry.size.width * 0.04)
            .padding(.vertical, geometry.size.height * 0.015)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                            .stroke(searchText.isEmpty ? Color.clear : Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Filters Row
    private var filtersRow: some View {
        HStack(spacing: geometry.size.width * 0.03) {
            // Filtres rapides
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: geometry.size.width * 0.025) {
                    // Filtre genre
                    if let gender = selectedGenderFilter {
                        FilterChip(
                            title: gender.displayName,
                            icon: gender.icon,
                            color: gender.color,
                            isActive: true,
                            geometry: geometry
                        ) {
                            selectedGenderFilter = nil
                        }
                    }
                    
                    // Filtre catégorie d'âge
                    if let ageCategory = selectedAgeCategoryFilter {
                        FilterChip(
                            title: ageCategory.displayName,
                            icon: ageCategory.icon,
                            color: ageCategory.color,
                            isActive: true,
                            geometry: geometry
                        ) {
                            selectedAgeCategoryFilter = nil
                        }
                    }
                    
                    // Indicateur de tri
                    FilterChip(
                        title: sortOption.title,
                        icon: sortOption.icon,
                        color: .blue,
                        isActive: sortOption != .nameAscending,
                        geometry: geometry
                    ) {
                        cycleSortOption()
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.01)
            }
            
            Spacer()
            
            // Bouton filtres avancés
            Button(action: { showingFilterSheet = true }) {
                HStack(spacing: geometry.size.width * 0.02) {
                    Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .font(.system(size: geometry.size.width * 0.045, weight: .medium))
                        .foregroundColor(hasActiveFilters ? .white : .blue)
                    
                    if hasActiveFilters {
                        Text("\(activeFiltersCount)")
                            .font(.system(size: geometry.size.width * 0.03, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.03)
                .padding(.vertical, geometry.size.height * 0.01)
                .background(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                        .fill(hasActiveFilters ? Color.blue : Color.blue.opacity(0.1))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Bouton effacer tout
            if hasActiveFilters {
                Button(action: onClearFilters) {
                    Image(systemName: "trash")
                        .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                        .foregroundColor(.red)
                        .frame(
                            width: geometry.size.width * 0.08,
                            height: geometry.size.width * 0.08
                        )
                        .background(
                            Circle()
                                .fill(Color.red.opacity(0.1))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Helper Methods
    private var activeFiltersCount: Int {
        var count = 0
        if selectedGenderFilter != nil { count += 1 }
        if selectedAgeCategoryFilter != nil { count += 1 }
        if !searchText.isEmpty { count += 1 }
        if sortOption != .nameAscending { count += 1 }
        return count
    }
    
    private func cycleSortOption() {
        switch sortOption {
        case .nameAscending:
            sortOption = .nameDescending
        case .nameDescending:
            sortOption = .ageAscending
        case .ageAscending:
            sortOption = .ageDescending
        case .ageDescending:
            sortOption = .nameAscending
        }
    }
}

// MARK: - Filter Chip Component
struct FilterChip: View {
    let title: String
    let icon: String
    let color: Color
    let isActive: Bool
    let geometry: GeometryProxy
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: geometry.size.width * 0.015) {
                Image(systemName: icon)
                    .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                    .foregroundColor(isActive ? .white : color)
                
                Text(title)
                    .font(.system(size: geometry.size.width * 0.032, weight: .medium))
                    .foregroundColor(isActive ? .white : color)
                
                if isActive {
                    Image(systemName: "xmark")
                        .font(.system(size: geometry.size.width * 0.025, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, geometry.size.width * 0.025)
            .padding(.vertical, geometry.size.height * 0.008)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                    .fill(isActive ? color : color.opacity(0.15))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Advanced Filters Sheet
struct AdvancedFiltersSheet: View {
    @Binding var selectedGenderFilter: Gender?
    @Binding var selectedAgeCategoryFilter: AgeCategory?
    @Binding var sortOption: SortOption
    @Environment(\.dismiss) private var dismiss
    let geometry: GeometryProxy
    let onClearAll: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: geometry.size.height * 0.03) {
                    // Section Genre
                    filterSection(
                        title: "Genre",
                        icon: "person.2",
                        color: .purple
                    ) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: geometry.size.width * 0.02), count: 3), spacing: geometry.size.width * 0.02) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                FilterOptionCard(
                                    title: gender.displayName,
                                    icon: gender.icon,
                                    color: gender.color,
                                    isSelected: selectedGenderFilter == gender,
                                    geometry: geometry
                                ) {
                                    selectedGenderFilter = selectedGenderFilter == gender ? nil : gender
                                }
                            }
                        }
                    }
                    
                    // Section Catégorie d'âge
                    filterSection(
                        title: "Catégorie d'âge",
                        icon: "figure.walk",
                        color: .green
                    ) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: geometry.size.width * 0.02), count: 3), spacing: geometry.size.width * 0.02) {
                            ForEach(AgeCategory.allCases, id: \.self) { category in
                                FilterOptionCard(
                                    title: category.displayName,
                                    icon: category.icon,
                                    color: category.color,
                                    isSelected: selectedAgeCategoryFilter == category,
                                    geometry: geometry
                                ) {
                                    selectedAgeCategoryFilter = selectedAgeCategoryFilter == category ? nil : category
                                }
                            }
                        }
                    }
                    
                    // Section Tri
                    filterSection(
                        title: "Trier par",
                        icon: "arrow.up.arrow.down",
                        color: .blue
                    ) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: geometry.size.width * 0.02), count: 2), spacing: geometry.size.width * 0.02) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                FilterOptionCard(
                                    title: option.title,
                                    icon: option.icon,
                                    color: .blue,
                                    isSelected: sortOption == option,
                                    geometry: geometry
                                ) {
                                    sortOption = option
                                }
                            }
                        }
                    }
                }
                .padding(geometry.size.width * 0.05)
            }
            .navigationTitle("Filtres")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Effacer tout") {
                        onClearAll()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Terminé") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func filterSection<Content: View>(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
            HStack(spacing: geometry.size.width * 0.03) {
                Image(systemName: icon)
                    .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            content()
        }
        .padding(geometry.size.width * 0.04)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: geometry.size.width * 0.01,
                    x: 0,
                    y: geometry.size.width * 0.005
                )
        )
    }
}

// MARK: - Filter Option Card
struct FilterOptionCard: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let geometry: GeometryProxy
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: geometry.size.height * 0.01) {
                Image(systemName: icon)
                    .font(.system(size: geometry.size.width * 0.06, weight: .medium))
                    .foregroundColor(isSelected ? .white : color)
                
                Text(title)
                    .font(.system(size: geometry.size.width * 0.032, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height * 0.08)
            .padding(.vertical, geometry.size.height * 0.01)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                    .fill(isSelected ? color : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                            .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Sort Option Extension
extension SortOption: CaseIterable {
    public static var allCases: [SortOption] {
        return [.nameAscending, .nameDescending, .ageAscending, .ageDescending]
    }
}

// MARK: - Preview
#if DEBUG
struct SearchAndFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            SearchAndFiltersView(
                searchText: .constant(""),
                selectedGenderFilter: .constant(nil),
                selectedAgeCategoryFilter: .constant(nil),
                sortOption: .constant(.nameAscending),
                geometry: geometry,
                onClearFilters: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Search and Filters")
    }
}
#endif