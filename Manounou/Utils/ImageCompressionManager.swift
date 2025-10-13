import SwiftUI
import UIKit
import Combine

// MARK: - Image Compression Configuration
struct ImageCompressionConfig {
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    let compressionQuality: CGFloat
    let maxFileSize: Int // in bytes
    
    static let thumbnail = ImageCompressionConfig(
        maxWidth: 150,
        maxHeight: 150,
        compressionQuality: 0.7,
        maxFileSize: 50_000 // 50KB
    )
    
    static let medium = ImageCompressionConfig(
        maxWidth: 800,
        maxHeight: 600,
        compressionQuality: 0.8,
        maxFileSize: 500_000 // 500KB
    )
    
    static let high = ImageCompressionConfig(
        maxWidth: 1200,
        maxHeight: 900,
        compressionQuality: 0.85,
        maxFileSize: 1_000_000 // 1MB
    )
    
    static let original = ImageCompressionConfig(
        maxWidth: 2048,
        maxHeight: 1536,
        compressionQuality: 0.9,
        maxFileSize: 2_000_000 // 2MB
    )
}

// MARK: - Compression Result
struct CompressionResult {
    let compressedData: Data
    let originalSize: Int
    let compressedSize: Int
    let compressionRatio: Double
    let processingTime: TimeInterval
    
    var compressionPercentage: Double {
        return (1.0 - Double(compressedSize) / Double(originalSize)) * 100.0
    }
}

// MARK: - Image Compression Manager
@MainActor
class ImageCompressionManager: ObservableObject {
    static let shared = ImageCompressionManager()
    
    @Published var isProcessing = false
    @Published var compressionProgress: Double = 0.0
    
    private let compressionQueue = DispatchQueue(label: "image.compression", qos: .userInitiated)
    private var compressionTasks: [UUID: Task<CompressionResult?, Error>] = [:]
    
    private init() {}
    
    // MARK: - Main Compression Methods
    
    /// Compresses an image with adaptive quality based on content analysis
    func compressImage(
        _ image: UIImage,
        config: ImageCompressionConfig = .medium,
        adaptiveCompression: Bool = true
    ) async throws -> CompressionResult {
        let taskId = UUID()
        
        return try await withTaskCancellation(id: taskId) {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            await MainActor.run {
                isProcessing = true
                compressionProgress = 0.0
            }
            
            // Step 1: Resize image if needed
            await updateProgress(0.2)
            let resizedImage = await resizeImage(image, to: config)
            
            // Step 2: Analyze image content for adaptive compression
            await updateProgress(0.4)
            let adaptiveConfig = adaptiveCompression ? 
                await analyzeAndAdaptConfig(resizedImage, baseConfig: config) : config
            
            // Step 3: Apply compression
            await updateProgress(0.6)
            let compressedData = await compressImageData(resizedImage, config: adaptiveConfig)
            
            // Step 4: Validate and optimize if needed
            await updateProgress(0.8)
            let finalData = try await optimizeIfNeeded(compressedData, image: resizedImage, config: adaptiveConfig)
            
            await updateProgress(1.0)
            
            let endTime = CFAbsoluteTimeGetCurrent()
            let processingTime = endTime - startTime
            
            let originalData = image.jpegData(compressionQuality: 1.0) ?? Data()
            
            await MainActor.run {
                isProcessing = false
                compressionProgress = 0.0
            }
            
            return CompressionResult(
                compressedData: finalData,
                originalSize: originalData.count,
                compressedSize: finalData.count,
                compressionRatio: Double(finalData.count) / Double(originalData.count),
                processingTime: processingTime
            )
        }
    }
    
    /// Batch compress multiple images
    func compressImages(
        _ images: [UIImage],
        config: ImageCompressionConfig = .medium,
        progressCallback: @escaping (Double) -> Void = { _ in }
    ) async throws -> [CompressionResult] {
        var results: [CompressionResult] = []
        
        for (index, image) in images.enumerated() {
            let result = try await compressImage(image, config: config)
            results.append(result)
            
            let progress = Double(index + 1) / Double(images.count)
            await MainActor.run {
                progressCallback(progress)
            }
        }
        
        return results
    }
    
    // MARK: - Helper Methods
    
    private func resizeImage(_ image: UIImage, to config: ImageCompressionConfig) async -> UIImage {
        return await withCheckedContinuation { continuation in
            compressionQueue.async {
                let size = image.size
                let aspectRatio = size.width / size.height
                
                var newSize = size
                
                // Calculate new size while maintaining aspect ratio
                if size.width > config.maxWidth || size.height > config.maxHeight {
                    if aspectRatio > 1 {
                        // Landscape
                        newSize.width = min(config.maxWidth, size.width)
                        newSize.height = newSize.width / aspectRatio
                    } else {
                        // Portrait or square
                        newSize.height = min(config.maxHeight, size.height)
                        newSize.width = newSize.height * aspectRatio
                    }
                }
                
                let renderer = UIGraphicsImageRenderer(size: newSize)
                let resizedImage = renderer.image { _ in
                    image.draw(in: CGRect(origin: .zero, size: newSize))
                }
                
                continuation.resume(returning: resizedImage)
            }
        }
    }
    
    private func analyzeAndAdaptConfig(_ image: UIImage, baseConfig: ImageCompressionConfig) async -> ImageCompressionConfig {
        return await withCheckedContinuation { continuation in
            compressionQueue.async {
                guard let cgImage = image.cgImage else {
                    continuation.resume(returning: baseConfig)
                    return
                }
                
                // Analyze image complexity
                let complexity = self.analyzeImageComplexity(cgImage)
                
                // Adapt compression quality based on complexity
                var adaptedQuality = baseConfig.compressionQuality
                
                switch complexity {
                case .low:
                    adaptedQuality = max(0.6, baseConfig.compressionQuality - 0.1)
                case .medium:
                    adaptedQuality = baseConfig.compressionQuality
                case .high:
                    adaptedQuality = min(0.95, baseConfig.compressionQuality + 0.05)
                }
                
                let adaptedConfig = ImageCompressionConfig(
                    maxWidth: baseConfig.maxWidth,
                    maxHeight: baseConfig.maxHeight,
                    compressionQuality: adaptedQuality,
                    maxFileSize: baseConfig.maxFileSize
                )
                
                continuation.resume(returning: adaptedConfig)
            }
        }
    }
    
    private func compressImageData(_ image: UIImage, config: ImageCompressionConfig) async -> Data {
        return await withCheckedContinuation { continuation in
            compressionQueue.async {
                let data = image.jpegData(compressionQuality: config.compressionQuality) ?? Data()
                continuation.resume(returning: data)
            }
        }
    }
    
    private func optimizeIfNeeded(_ data: Data, image: UIImage, config: ImageCompressionConfig) async throws -> Data {
        if data.count <= config.maxFileSize {
            return data
        }
        
        // If still too large, apply progressive compression
        var quality = config.compressionQuality
        var optimizedData = data
        let qualityStep: CGFloat = 0.1
        
        while optimizedData.count > config.maxFileSize && quality > 0.3 {
            quality -= qualityStep
            optimizedData = await compressImageData(image, config: ImageCompressionConfig(
                maxWidth: config.maxWidth,
                maxHeight: config.maxHeight,
                compressionQuality: quality,
                maxFileSize: config.maxFileSize
            ))
        }
        
        return optimizedData
    }
    
    private func analyzeImageComplexity(_ cgImage: CGImage) -> ImageComplexity {
        let width = cgImage.width
        let height = cgImage.height
        let totalPixels = width * height
        
        // Simple complexity analysis based on image size and estimated detail
        // In a real implementation, you might analyze color variance, edge detection, etc.
        
        if totalPixels < 100_000 { // Small images
            return .low
        } else if totalPixels < 500_000 { // Medium images
            return .medium
        } else { // Large images
            return .high
        }
    }
    
    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            compressionProgress = progress
        }
    }
    
    private func withTaskCancellation<T>(id: UUID, operation: () async throws -> T) async throws -> T {
        let task = Task {
            try await operation()
        }
        
        compressionTasks[id] = task
        defer { compressionTasks.removeValue(forKey: id) }
        
        return try await task.value
    }
    
    // MARK: - Utility Methods
    
    func cancelAllCompressions() {
        compressionTasks.values.forEach { $0.cancel() }
        compressionTasks.removeAll()
        
        Task { @MainActor in
            isProcessing = false
            compressionProgress = 0.0
        }
    }
    
    func getOptimalConfig(for imageSize: CGSize, targetUsage: ImageUsage) -> ImageCompressionConfig {
        switch targetUsage {
        case .thumbnail:
            return .thumbnail
        case .listDisplay:
            return .medium
        case .fullScreen:
            return .high
        case .storage:
            return .original
        }
    }
}

// MARK: - Supporting Types

enum ImageComplexity {
    case low
    case medium
    case high
}

enum ImageUsage {
    case thumbnail
    case listDisplay
    case fullScreen
    case storage
}

// MARK: - SwiftUI Integration

struct CompressedAsyncImage: View {
    let url: URL?
    let config: ImageCompressionConfig
    @State private var compressedImage: UIImage?
    @State private var isLoading = false
    @State private var error: Error?
    
    init(url: URL?, config: ImageCompressionConfig = .medium) {
        self.url = url
        self.config = config
    }
    
    var body: some View {
        Group {
            if let compressedImage = compressedImage {
                Image(uiImage: compressedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if isLoading {
                ProgressView()
                    .frame(width: 50, height: 50)
            } else if error != nil {
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            } else {
                Color.clear
            }
        }
        .task {
            await loadAndCompressImage()
        }
    }
    
    private func loadAndCompressImage() async {
        guard let url = url else { return }
        
        isLoading = true
        error = nil
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                throw ImageCompressionError.invalidImageData
            }
            
            let result = try await ImageCompressionManager.shared.compressImage(image, config: config)
            
            if let compressedUIImage = UIImage(data: result.compressedData) {
                await MainActor.run {
                    self.compressedImage = compressedUIImage
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
}

// MARK: - Error Types

enum ImageCompressionError: LocalizedError {
    case invalidImageData
    case compressionFailed
    case fileSizeTooLarge
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Données d'image invalides"
        case .compressionFailed:
            return "Échec de la compression"
        case .fileSizeTooLarge:
            return "Taille de fichier trop importante"
        }
    }
}