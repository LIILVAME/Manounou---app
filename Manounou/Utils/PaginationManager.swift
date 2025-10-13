//
//  PaginationManager.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import Foundation
import SwiftUI
import os.log

// MARK: - Pagination Configuration
struct PaginationConfig {
    let pageSize: Int
    let prefetchThreshold: Int
    let maxCachedPages: Int
    
    static let `default` = PaginationConfig(
        pageSize: 20,
        prefetchThreshold: 5,
        maxCachedPages: 10
    )
    
    static let small = PaginationConfig(
        pageSize: 10,
        prefetchThreshold: 3,
        maxCachedPages: 5
    )
    
    static let large = PaginationConfig(
        pageSize: 50,
        prefetchThreshold: 10,
        maxCachedPages: 20
    )
}

// MARK: - Pagination State
enum PaginationState {
    case idle
    case loading
    case loaded
    case error(Error)
    case endReached
}

// MARK: - Paginated Result
struct PaginatedResult<T> {
    let items: [T]
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let hasNextPage: Bool
    let hasPreviousPage: Bool
}

// MARK: - Pagination Manager
@MainActor
class PaginationManager<T: Identifiable>: ObservableObject {
    @Published var items: [T] = []
    @Published var state: PaginationState = .idle
    @Published var currentPage: Int = 0
    @Published var hasNextPage: Bool = true
    
    private let config: PaginationConfig
    private let loadPage: (Int, Int) async throws -> PaginatedResult<T>
    private var cachedPages: [Int: [T]] = [:]
    private var loadingPages: Set<Int> = []
    
    init(
        config: PaginationConfig = .default,
        loadPage: @escaping (Int, Int) async throws -> PaginatedResult<T>
    ) {
        self.config = config
        self.loadPage = loadPage
    }
    
    // MARK: - Public Methods
    
    func loadInitialPage() async {
        await loadPage(0)
    }
    
    func loadNextPage() async {
        guard hasNextPage && state != .loading else { return }
        await loadPage(currentPage + 1)
    }
    
    func refresh() async {
        cachedPages.removeAll()
        loadingPages.removeAll()
        items.removeAll()
        currentPage = 0
        hasNextPage = true
        state = .idle
        
        await loadInitialPage()
    }
    
    func shouldLoadMore(for item: T) -> Bool {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return false
        }
        
        return index >= items.count - config.prefetchThreshold && hasNextPage
    }
    
    func prefetchIfNeeded(for item: T) async {
        if shouldLoadMore(for: item) {
            await loadNextPage()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadPage(_ page: Int) async {
        guard !loadingPages.contains(page) else { return }
        
        loadingPages.insert(page)
        
        if page == 0 {
            state = .loading
        }
        
        do {
            let result = try await loadPage(page, config.pageSize)
            
            cachedPages[page] = result.items
            
            if page == 0 {
                items = result.items
            } else {
                items.append(contentsOf: result.items)
            }
            
            currentPage = page
            hasNextPage = result.hasNextPage
            state = result.items.isEmpty && page == 0 ? .endReached : .loaded
            
            // Manage cache size
            manageCacheSize()
            
            Logger.info("Loaded page \(page) with \(result.items.count) items", category: .performance)
            
        } catch {
            state = .error(error)
            Logger.error("Failed to load page \(page): \(error.localizedDescription)", category: .performance)
        }
        
        loadingPages.remove(page)
    }
    
    private func manageCacheSize() {
        guard cachedPages.count > config.maxCachedPages else { return }
        
        let sortedPages = cachedPages.keys.sorted()
        let pagesToRemove = sortedPages.prefix(cachedPages.count - config.maxCachedPages)
        
        for page in pagesToRemove {
            cachedPages.removeValue(forKey: page)
        }
        
        Logger.info("Cache cleaned, removed \(pagesToRemove.count) pages", category: .performance)
    }
}

// MARK: - Pagination View Modifier
struct PaginatedList<T: Identifiable, Content: View>: View {
    @StateObject private var paginationManager: PaginationManager<T>
    let content: (T) -> Content
    let emptyStateView: () -> AnyView
    let errorStateView: (Error) -> AnyView
    
    init(
        config: PaginationConfig = .default,
        loadPage: @escaping (Int, Int) async throws -> PaginatedResult<T>,
        @ViewBuilder content: @escaping (T) -> Content,
        @ViewBuilder emptyStateView: @escaping () -> some View = { EmptyView() },
        @ViewBuilder errorStateView: @escaping (Error) -> some View = { _ in EmptyView() }
    ) {
        self._paginationManager = StateObject(wrappedValue: PaginationManager(config: config, loadPage: loadPage))
        self.content = content
        self.emptyStateView = { AnyView(emptyStateView()) }
        self.errorStateView = { AnyView(errorStateView($0)) }
    }
    
    var body: some View {
        Group {
            switch paginationManager.state {
            case .idle, .loading where paginationManager.items.isEmpty:
                ProgressView("Chargement...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .error(let error) where paginationManager.items.isEmpty:
                errorStateView(error)
                
            case .endReached where paginationManager.items.isEmpty:
                emptyStateView()
                
            default:
                List {
                    ForEach(paginationManager.items) { item in
                        content(item)
                            .onAppear {
                                Task {
                                    await paginationManager.prefetchIfNeeded(for: item)
                                }
                            }
                    }
                    
                    if paginationManager.hasNextPage {
                        HStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .refreshable {
                    await paginationManager.refresh()
                }
            }
        }
        .task {
            if paginationManager.items.isEmpty {
                await paginationManager.loadInitialPage()
            }
        }
    }
}

// MARK: - Pagination Extensions
extension View {
    func paginatedList<T: Identifiable>(
        items: [T],
        config: PaginationConfig = .default,
        loadPage: @escaping (Int, Int) async throws -> PaginatedResult<T>
    ) -> some View {
        self.modifier(PaginationViewModifier(items: items, config: config, loadPage: loadPage))
    }
}

struct PaginationViewModifier<T: Identifiable>: ViewModifier {
    let items: [T]
    let config: PaginationConfig
    let loadPage: (Int, Int) async throws -> PaginatedResult<T>
    
    func body(content: Content) -> some View {
        content
    }
}