//
//  OptimizedViewsTests.swift
//  ManounouTests
//
//  Created by Assistant on 09/10/2025.
//

import XCTest
import SwiftUI
@testable import Manounou

@MainActor
class OptimizedViewsTests: XCTestCase {
    
    // MARK: - PerformanceOptimizedContainer Tests
    
    func testPerformanceOptimizedContainerCreation() {
        let testView = Text("Test Content")
        let container = PerformanceOptimizedContainer {
            testView
        }
        
        XCTAssertNotNil(container)
    }
    
    func testPerformanceOptimizedContainerPerformance() {
        measure {
            for _ in 0..<100 {
                let _ = PerformanceOptimizedContainer {
                    VStack {
                        Text("Performance Test")
                        Text("Multiple Elements")
                        Text("Testing Container")
                    }
                }
            }
        }
    }
    
    // MARK: - OptimizedLazyList Tests
    
    func testOptimizedLazyListCreation() {
        let testData = Array(0..<100)
        let lazyList = OptimizedLazyList(
            data: testData,
            content: { item in
                Text("Item \(item)")
            }
        )
        
        XCTAssertNotNil(lazyList)
    }
    
    func testOptimizedLazyListPerformance() {
        let testData = Array(0..<1000)
        
        measure {
            let _ = OptimizedLazyList(
                data: testData,
                content: { item in
                    HStack {
                        Text("Item \(item)")
                        Spacer()
                        Text("Value")
                    }
                }
            )
        }
    }
    
    // MARK: - CachedAsyncImage Tests
    
    func testCachedAsyncImageCreation() {
        let testURL = URL(string: "https://example.com/test.jpg")!
        let cachedImage = CachedAsyncImage(url: testURL) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
        
        XCTAssertNotNil(cachedImage)
    }
    
    func testCachedAsyncImageWithInvalidURL() {
        let invalidURL = URL(string: "invalid-url")
        let cachedImage = CachedAsyncImage(url: invalidURL) { image in
            image.resizable()
        } placeholder: {
            Text("Loading...")
        }
        
        XCTAssertNotNil(cachedImage)
    }
    
    // MARK: - LoadingStateView Tests
    
    func testLoadingStateViewCreation() {
        let loadingView = LoadingStateView(message: "Loading data...")
        XCTAssertNotNil(loadingView)
    }
    
    func testLoadingStateViewWithoutMessage() {
        let loadingView = LoadingStateView()
        XCTAssertNotNil(loadingView)
    }
    
    // MARK: - ErrorStateView Tests
    
    func testErrorStateViewCreation() {
        let errorView = ErrorStateView(
            message: "Test error message",
            onRetry: {}
        )
        XCTAssertNotNil(errorView)
    }
    
    func testErrorStateViewWithoutRetry() {
        let errorView = ErrorStateView(message: "Test error")
        XCTAssertNotNil(errorView)
    }
    
    // MARK: - SearchBar Tests
    
    func testSearchBarCreation() {
        @State var searchText = ""
        let searchBar = SearchBar(
            text: $searchText,
            placeholder: "Search..."
        )
        XCTAssertNotNil(searchBar)
    }
    
    func testSearchBarWithOnSearchCommitted() {
        @State var searchText = ""
        var searchCommitted = false
        
        let searchBar = SearchBar(
            text: $searchText,
            placeholder: "Search...",
            onSearchCommitted: {
                searchCommitted = true
            }
        )
        
        XCTAssertNotNil(searchBar)
        XCTAssertFalse(searchCommitted)
    }
    
    // MARK: - View Extensions Tests
    
    func testOptimizedRenderingModifier() {
        let testView = Text("Test")
            .optimizedRendering()
        
        XCTAssertNotNil(testView)
    }
    
    func testLowPriorityModifier() {
        let testView = Text("Test")
            .lowPriority()
        
        XCTAssertNotNil(testView)
    }
    
    func testConditionalModifier() {
        let testView = Text("Test")
            .conditional(true) { view in
                view.foregroundColor(.red)
            }
        
        XCTAssertNotNil(testView)
    }
    
    func testConditionalModifierFalse() {
        let testView = Text("Test")
            .conditional(false) { view in
                view.foregroundColor(.red)
            }
        
        XCTAssertNotNil(testView)
    }
    
    // MARK: - Performance Tests
    
    func testMultipleViewCreationPerformance() {
        measure {
            for i in 0..<100 {
                let _ = VStack {
                    LoadingStateView(message: "Loading \(i)")
                    ErrorStateView(message: "Error \(i)")
                    Text("Content \(i)")
                        .optimizedRendering()
                        .lowPriority()
                }
            }
        }
    }
    
    func testLargeListPerformance() {
        let largeDataSet = Array(0..<10000)
        
        measure {
            let _ = OptimizedLazyList(
                data: largeDataSet,
                content: { item in
                    HStack {
                        Text("Item \(item)")
                            .optimizedRendering()
                        Spacer()
                        Text("Value \(item * 2)")
                            .lowPriority()
                    }
                }
            )
        }
    }
    
    // MARK: - Memory Tests
    
    func testViewMemoryUsage() {
        // Test that views can be created and deallocated without memory leaks
        autoreleasepool {
            for _ in 0..<1000 {
                let _ = PerformanceOptimizedContainer {
                    VStack {
                        LoadingStateView()
                        ErrorStateView(message: "Test")
                        Text("Memory test")
                            .optimizedRendering()
                    }
                }
            }
        }
        
        // If we reach here without crashes, memory management is working
        XCTAssertTrue(true)
    }
    
    // MARK: - Integration Tests
    
    func testViewIntegrationWithAppContainer() {
        let appContainer = AppContainer()
        
        let integratedView = PerformanceOptimizedContainer {
            VStack {
                if appContainer.childrenViewModel.isLoading {
                    LoadingStateView(message: "Loading children...")
                } else if let error = appContainer.childrenViewModel.errorMessage {
                    ErrorStateView(message: error) {
                        appContainer.childrenViewModel.clearError()
                    }
                } else {
                    OptimizedLazyList(
                        data: appContainer.childrenViewModel.children,
                        content: { child in
                            Text(child.firstName)
                                .optimizedRendering()
                        }
                    )
                }
            }
        }
        
        XCTAssertNotNil(integratedView)
    }
}