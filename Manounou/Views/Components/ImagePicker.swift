import SwiftUI
import PhotosUI
import UIKit

// MARK: - Enhanced Image Picker with Compression
struct EnhancedImagePicker: View {
    @Binding var selectedImage: UIImage?
    @State private var isShowingPhotoPicker = false
    @State private var isShowingCamera = false
    @State private var isCompressing = false
    @State private var compressionProgress: Double = 0.0
    @State private var compressionResult: CompressionResult?
    @State private var showCompressionDetails = false
    
    let config: ImageCompressionConfig
    let onImageSelected: ((UIImage, CompressionResult) -> Void)?
    
    init(
        selectedImage: Binding<UIImage?>,
        config: ImageCompressionConfig = .medium,
        onImageSelected: ((UIImage, CompressionResult) -> Void)? = nil
    ) {
        self._selectedImage = selectedImage
        self.config = config
        self.onImageSelected = onImageSelected
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Image Display Area
            imageDisplayArea
            
            // Action Buttons
            actionButtons
            
            // Compression Progress
            if isCompressing {
                compressionProgressView
            }
            
            // Compression Details
            if let result = compressionResult, showCompressionDetails {
                compressionDetailsView(result)
            }
        }
        .sheet(isPresented: $isShowingPhotoPicker) {
            PhotosPicker(
                selection: .constant(nil),
                matching: .images
            ) { selection in
                Task {
                    if let data = try? await selection?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await processSelectedImage(image)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraView { image in
                Task {
                    await processSelectedImage(image)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var imageDisplayArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(height: 200)
            
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .onTapGesture {
                        showCompressionDetails.toggle()
                    }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("Aucune image sélectionnée")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("Appuyez sur les boutons ci-dessous pour ajouter une image")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                isShowingPhotoPicker = true
            }) {
                Label("Galerie", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isCompressing)
            
            Button(action: {
                isShowingCamera = true
            }) {
                Label("Appareil photo", systemImage: "camera")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isCompressing)
            
            if selectedImage != nil {
                Button(action: {
                    selectedImage = nil
                    compressionResult = nil
                    showCompressionDetails = false
                }) {
                    Label("Supprimer", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
                .disabled(isCompressing)
            }
        }
    }
    
    private var compressionProgressView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Compression en cours...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(compressionProgress * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            ProgressView(value: compressionProgress)
                .progressViewStyle(LinearProgressViewStyle())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func compressionDetailsView(_ result: CompressionResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Détails de compression")
                    .font(.headline)
                
                Spacer()
                
                Button("Fermer") {
                    showCompressionDetails = false
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Taille originale")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatFileSize(result.originalSize))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Taille compressée")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatFileSize(result.compressedSize))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Réduction")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(result.compressionPercentage))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Temps de traitement")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.2f", result.processingTime))s")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    
    private func processSelectedImage(_ image: UIImage) async {
        await MainActor.run {
            isCompressing = true
            compressionProgress = 0.0
        }
        
        do {
            // Monitor compression progress
            let progressTask = Task {
                while isCompressing {
                    await MainActor.run {
                        compressionProgress = ImageCompressionManager.shared.compressionProgress
                    }
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                }
            }
            
            let result = try await ImageCompressionManager.shared.compressImage(
                image,
                config: config,
                adaptiveCompression: true
            )
            
            progressTask.cancel()
            
            if let compressedImage = UIImage(data: result.compressedData) {
                await MainActor.run {
                    selectedImage = compressedImage
                    compressionResult = result
                    isCompressing = false
                    showCompressionDetails = true
                }
                
                onImageSelected?(compressedImage, result)
                
                Logger.info("Image compressed successfully: \(result.compressionPercentage)% reduction", category: .ui)
            }
        } catch {
            await MainActor.run {
                isCompressing = false
            }
            Logger.error("Image compression failed: \(error.localizedDescription)", category: .ui)
        }
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Optimized Image View
struct OptimizedImageView: View {
    let image: UIImage?
    let config: ImageCompressionConfig
    @State private var optimizedImage: UIImage?
    @State private var isOptimizing = false
    
    init(image: UIImage?, config: ImageCompressionConfig = .medium) {
        self.image = image
        self.config = config
    }
    
    var body: some View {
        Group {
            if let optimizedImage = optimizedImage {
                Image(uiImage: optimizedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if isOptimizing {
                ProgressView()
                    .frame(width: 50, height: 50)
            } else if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            }
        }
        .task {
            await optimizeImageIfNeeded()
        }
        .onChange(of: image) { _ in
            Task {
                await optimizeImageIfNeeded()
            }
        }
    }
    
    private func optimizeImageIfNeeded() async {
        guard let image = image else { return }
        
        // Check if optimization is needed
        let imageData = image.jpegData(compressionQuality: 1.0) ?? Data()
        if imageData.count <= config.maxFileSize {
            optimizedImage = image
            return
        }
        
        isOptimizing = true
        
        do {
            let result = try await ImageCompressionManager.shared.compressImage(image, config: config)
            if let compressed = UIImage(data: result.compressedData) {
                optimizedImage = compressed
            } else {
                optimizedImage = image
            }
        } catch {
            optimizedImage = image
            Logger.error("Failed to optimize image: \(error.localizedDescription)", category: .ui)
        }
        
        isOptimizing = false
    }
}

#Preview {
    VStack(spacing: 20) {
        EnhancedImagePicker(
            selectedImage: .constant(nil),
            config: .medium
        ) { image, result in
            print("Image selected with \(result.compressionPercentage)% compression")
        }
        
        OptimizedImageView(
            image: UIImage(systemName: "photo"),
            config: .thumbnail
        )
        .frame(height: 100)
    }
    .padding()
}