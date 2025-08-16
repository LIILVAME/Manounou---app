//
//  ChildrenListView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

struct ChildrenListView: View {
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @State private var searchText = ""
    @State private var selectedGenderFilter: Gender? = nil
    @State private var selectedAgeCategoryFilter: AgeCategory? = nil
    @State private var sortOption: SortOption = .nameAscending
    @State private var showingAddChild = false
    @State private var showingFilters = false
    @State private var selectedChild: Child? = nil
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header with search and filters
                    headerSection(geometry: geometry)
                    
                    // Content
                    if filteredChildren.isEmpty {
                        if childrenViewModel.children.isEmpty {
                            // Empty state
                            EmptyChildrenView(
                                geometry: geometry,
                                onAddChild: {
                                    showingAddChild = true
                                }
                            )
                        } else {
                            // No results from search/filter
                            noResultsView(geometry: geometry)
                        }
                    } else {
                        // Children list
                        childrenList(geometry: geometry)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddChild) {
            AddChildView()
        }
        .sheet(item: $selectedChild) { child in
            ChildDetailView(child: child)
        }
        .onAppear {
            Task {
                await childrenViewModel.loadChildren()
            }
        }
    }
    
    // MARK: - Header Section
    private func headerSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            // Title and add button
            HStack {
                VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                    Text("Enfants")
                        .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if !childrenViewModel.children.isEmpty {
                        Text("\(childrenViewModel.children.count) enfant(s)")
                            .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Add button
                Button(action: { showingAddChild = true }) {
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
                            radius: geometry.size.width * 0.01,
                            x: 0,
                            y: geometry.size.width * 0.005
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Search bar
            if !childrenViewModel.children.isEmpty {
                searchBar(geometry: geometry)
                
                // Filters and sort
                filtersSection(geometry: geometry)
            }
        }
        .padding(.horizontal, geometry.size.width * 0.05)
        .padding(.top, geometry.size.height * 0.02)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Search Bar
    private func searchBar(geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.03) {
            HStack(spacing: geometry.size.width * 0.03) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Rechercher un enfant...", text: $searchText)
                    .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                    .textFieldStyle(PlainTextFieldStyle())
                
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
            )
        }
    }
    
    // MARK: - Filters Section
    private func filtersSection(geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.03) {
            // Gender filter
            filterButton(
                title: selectedGenderFilter?.displayName ?? "Genre",
                isActive: selectedGenderFilter != nil,
                geometry: geometry
            ) {
                // Cycle through gender options
                if selectedGenderFilter == nil {
                    selectedGenderFilter = .male
                } else if selectedGenderFilter == .male {
                    selectedGenderFilter = .female
                } else if selectedGenderFilter == .female {
                    selectedGenderFilter = .other
                } else {
                    selectedGenderFilter = nil
                }
            }
            
            // Age category filter
            filterButton(
                title: selectedAgeCategoryFilter?.displayName ?? "Âge",
                isActive: selectedAgeCategoryFilter != nil,
                geometry: geometry
            ) {
                // Cycle through age category options
                if selectedAgeCategoryFilter == nil {
                    selectedAgeCategoryFilter = .baby
                } else if selectedAgeCategoryFilter == .baby {
                    selectedAgeCategoryFilter = .preschooler
                } else if selectedAgeCategoryFilter == .preschooler {
                    selectedAgeCategoryFilter = .schoolAge
                } else {
                    selectedAgeCategoryFilter = nil
                }
            }
            
            Spacer()
            
            // Sort button
            sortButton(geometry: geometry)
        }
    }
    
    private func filterButton(
        title: String,
        isActive: Bool,
        geometry: GeometryProxy,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                .foregroundColor(isActive ? .white : .primary)
                .padding(.horizontal, geometry.size.width * 0.03)
                .padding(.vertical, geometry.size.height * 0.01)
                .background(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                        .fill(isActive ? Color.blue : Color(.systemGray6))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func sortButton(geometry: GeometryProxy) -> some View {
        Button(action: {
            // Cycle through sort options
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
        }) {
            Image(systemName: sortOption.icon)
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.blue)
                .frame(
                    width: geometry.size.width * 0.08,
                    height: geometry.size.width * 0.08
                )
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Children List
    private func childrenList(geometry: GeometryProxy) -> some View {
        ScrollView {
            LazyVStack(spacing: geometry.size.height * 0.015) {
                ForEach(filteredChildren, id: \.id) { child in
                    ChildCardView(
                        child: child,
                        geometry: geometry,
                        onTap: {
                            selectedChild = child
                        },
                        onEdit: {
                            // TODO: Implement edit functionality
                            print("Edit \(child.fullName)")
                        }
                    )
                }
            }
            .padding(.horizontal, geometry.size.width * 0.05)
            .padding(.top, geometry.size.height * 0.02)
        }
        .refreshable {
            await childrenViewModel.loadChildren()
        }
    }
    
    // MARK: - No Results View
    private func noResultsView(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.03) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: geometry.size.width * 0.15, weight: .light))
                .foregroundColor(.secondary)
            
            Text("Aucun résultat")
                .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Essayez de modifier vos critères de recherche")
                .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Effacer les filtres") {
                searchText = ""
                selectedGenderFilter = nil
                selectedAgeCategoryFilter = nil
            }
            .font(.system(size: geometry.size.width * 0.04, weight: .medium))
            .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Computed Properties
    private var filteredChildren: [Child] {
        var children = childrenViewModel.children
        
        // Apply search filter
        if !searchText.isEmpty {
            children = children.filter { child in
                child.fullName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply gender filter
        if let genderFilter = selectedGenderFilter {
            children = children.filter { $0.gender == genderFilter }
        }
        
        // Apply age category filter
        if let ageCategoryFilter = selectedAgeCategoryFilter {
            children = children.filter { $0.ageCategory == ageCategoryFilter }
        }
        
        // Apply sorting
        return children.sorted { child1, child2 in
            switch sortOption {
            case .nameAscending:
                return child1.fullName < child2.fullName
            case .nameDescending:
                return child1.fullName > child2.fullName
            case .ageAscending:
                return child1.birthDate > child2.birthDate // Younger first
            case .ageDescending:
                return child1.birthDate < child2.birthDate // Older first
            }
        }
    }
}

// MARK: - Sort Options
enum SortOption: CaseIterable {
    case nameAscending
    case nameDescending
    case ageAscending
    case ageDescending
    
    var icon: String {
        switch self {
        case .nameAscending:
            return "textformat.abc"
        case .nameDescending:
            return "textformat.abc"
        case .ageAscending:
            return "arrow.up.circle"
        case .ageDescending:
            return "arrow.down.circle"
        }
    }
    
    var title: String {
        switch self {
        case .nameAscending:
            return "Nom A-Z"
        case .nameDescending:
            return "Nom Z-A"
        case .ageAscending:
            return "Plus jeune"
        case .ageDescending:
            return "Plus âgé"
        }
    }
}

// MARK: - Preview
#if DEBUG
struct ChildrenListView_Previews: PreviewProvider {
    static var previews: some View {
        ChildrenListView()
            .environmentObject(ChildrenViewModel())
    }
}
#endif