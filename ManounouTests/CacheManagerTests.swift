//
//  CacheManagerTests.swift
//  ManounouTests
//
//  Created by Assistant on 09/10/2025.
//

import XCTest
@testable import Manounou

class CacheManagerTests: XCTestCase {
    
    var cacheManager: CacheManager!
    var imageCacheManager: ImageCacheManager!
    
    override func setUp() {
        super.setUp()
        cacheManager = CacheManager()
        imageCacheManager = ImageCacheManager()
    }
    
    override func tearDown() {
        cacheManager.clear()
        imageCacheManager.clearCache()
        cacheManager = nil
        imageCacheManager = nil
        super.tearDown()
    }
    
    // MARK: - CacheManager Tests
    
    func testCacheSetAndGet() {
        let key = "test_key"
        let value = "test_value"
        
        cacheManager.set(value, forKey: key)
        let retrievedValue: String? = cacheManager.get(forKey: key)
        
        XCTAssertEqual(retrievedValue, value)
    }
    
    func testCacheWithDifferentTypes() {
        // Test String
        cacheManager.set("string_value", forKey: "string_key")
        let stringValue: String? = cacheManager.get(forKey: "string_key")
        XCTAssertEqual(stringValue, "string_value")
        
        // Test Int
        cacheManager.set(42, forKey: "int_key")
        let intValue: Int? = cacheManager.get(forKey: "int_key")
        XCTAssertEqual(intValue, 42)
        
        // Test Array
        let testArray = [1, 2, 3, 4, 5]
        cacheManager.set(testArray, forKey: "array_key")
        let arrayValue: [Int]? = cacheManager.get(forKey: "array_key")
        XCTAssertEqual(arrayValue, testArray)
    }
    
    func testCacheExpiration() {
        let key = "expiring_key"
        let value = "expiring_value"
        let shortTTL: TimeInterval = 0.1 // 100ms
        
        cacheManager.set(value, forKey: key, ttl: shortTTL)
        
        // Should be available immediately
        let immediateValue: String? = cacheManager.get(forKey: key)
        XCTAssertEqual(immediateValue, value)
        
        // Wait for expiration
        let expectation = XCTestExpectation(description: "Cache expiration")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let expiredValue: String? = self.cacheManager.get(forKey: key)
            XCTAssertNil(expiredValue)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCacheRemove() {
        let key = "removable_key"
        let value = "removable_value"
        
        cacheManager.set(value, forKey: key)
        XCTAssertNotNil(cacheManager.get(forKey: key) as String?)
        
        cacheManager.remove(forKey: key)
        XCTAssertNil(cacheManager.get(forKey: key) as String?)
    }
    
    func testCacheClear() {
        cacheManager.set("value1", forKey: "key1")
        cacheManager.set("value2", forKey: "key2")
        cacheManager.set("value3", forKey: "key3")
        
        // Verify all values are cached
        XCTAssertNotNil(cacheManager.get(forKey: "key1") as String?)
        XCTAssertNotNil(cacheManager.get(forKey: "key2") as String?)
        XCTAssertNotNil(cacheManager.get(forKey: "key3") as String?)
        
        cacheManager.clear()
        
        // Verify all values are cleared
        XCTAssertNil(cacheManager.get(forKey: "key1") as String?)
        XCTAssertNil(cacheManager.get(forKey: "key2") as String?)
        XCTAssertNil(cacheManager.get(forKey: "key3") as String?)
    }
    
    // MARK: - ImageCacheManager Tests
    
    func testImageCacheSetAndGet() {
        let testURL = URL(string: "https://example.com/test.jpg")!
        let testImage = createTestImage()
        
        imageCacheManager.setImage(testImage, forURL: testURL)
        let retrievedImage = imageCacheManager.getImage(forURL: testURL)
        
        XCTAssertNotNil(retrievedImage)
    }
    
    func testImageCacheRemove() {
        let testURL = URL(string: "https://example.com/test.jpg")!
        let testImage = createTestImage()
        
        imageCacheManager.setImage(testImage, forURL: testURL)
        XCTAssertNotNil(imageCacheManager.getImage(forURL: testURL))
        
        imageCacheManager.removeImage(forURL: testURL)
        XCTAssertNil(imageCacheManager.getImage(forURL: testURL))
    }
    
    func testImageCacheClear() {
        let testURL1 = URL(string: "https://example.com/test1.jpg")!
        let testURL2 = URL(string: "https://example.com/test2.jpg")!
        let testImage = createTestImage()
        
        imageCacheManager.setImage(testImage, forURL: testURL1)
        imageCacheManager.setImage(testImage, forURL: testURL2)
        
        XCTAssertNotNil(imageCacheManager.getImage(forURL: testURL1))
        XCTAssertNotNil(imageCacheManager.getImage(forURL: testURL2))
        
        imageCacheManager.clearCache()
        
        XCTAssertNil(imageCacheManager.getImage(forURL: testURL1))
        XCTAssertNil(imageCacheManager.getImage(forURL: testURL2))
    }
    
    // MARK: - Performance Tests
    
    func testCachePerformance() {
        measure {
            for i in 0..<1000 {
                cacheManager.set("value_\(i)", forKey: "key_\(i)")
            }
            
            for i in 0..<1000 {
                let _: String? = cacheManager.get(forKey: "key_\(i)")
            }
        }
    }
    
    func testImageCachePerformance() {
        let testImage = createTestImage()
        
        measure {
            for i in 0..<100 {
                let url = URL(string: "https://example.com/test_\(i).jpg")!
                imageCacheManager.setImage(testImage, forURL: url)
            }
            
            for i in 0..<100 {
                let url = URL(string: "https://example.com/test_\(i).jpg")!
                let _ = imageCacheManager.getImage(forURL: url)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.blue.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}