import SwiftUI

// MARK: - Optimized Child Row View
struct OptimizedChildRowView: View, Equatable {
    let child: FunctionalChild
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            AsyncImage(url: child.profileImage) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .overlay(
                        Text(String(child.name.prefix(1)))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    )
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // Child Info
            VStack(alignment: .leading, spacing: 4) {
                Text(child.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(child.age) ans")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    static func == (lhs: OptimizedChildRowView, rhs: OptimizedChildRowView) -> Bool {
        lhs.child.id == rhs.child.id &&
        lhs.child.name == rhs.child.name &&
        lhs.child.age == rhs.child.age &&
        lhs.child.profileImage == rhs.child.profileImage
    }
}

// MARK: - Optimized Event Row View
struct OptimizedEventRowView: View, Equatable {
    let event: FunctionalEvent
    let onTap: () -> Void
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: event.date)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Date Circle
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: event.date))")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(DateFormatter().monthSymbols[Calendar.current.component(.month, from: event.date) - 1].prefix(3))
                    .font(.caption)
                    .textCase(.uppercase)
            }
            .frame(width: 50, height: 50)
            .background(Color.orange.opacity(0.2))
            .foregroundColor(.orange)
            .clipShape(Circle())
            
            // Event Info
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let description = event.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    static func == (lhs: OptimizedEventRowView, rhs: OptimizedEventRowView) -> Bool {
        lhs.event.id == rhs.event.id &&
        lhs.event.title == rhs.event.title &&
        lhs.event.date == rhs.event.date &&
        lhs.event.description == rhs.event.description
    }
}

// MARK: - Optimized Document Row View
struct OptimizedDocumentRowView: View, Equatable {
    let document: FunctionalDocument
    let onTap: () -> Void
    
    private var iconName: String {
        switch document.type.lowercased() {
        case "pdf":
            return "doc.fill"
        case "jpg", "jpeg", "png":
            return "photo.fill"
        case "doc", "docx":
            return "doc.text.fill"
        default:
            return "doc.fill"
        }
    }
    
    private var iconColor: Color {
        switch document.type.lowercased() {
        case "pdf":
            return .red
        case "jpg", "jpeg", "png":
            return .green
        case "doc", "docx":
            return .blue
        default:
            return .gray
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: document.date)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Document Icon
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 50, height: 50)
                .background(iconColor.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Document Info
            VStack(alignment: .leading, spacing: 4) {
                Text(document.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack {
                    Text(document.type.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(iconColor.opacity(0.2))
                        .foregroundColor(iconColor)
                        .clipShape(Capsule())
                    
                    Text(document.category.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    static func == (lhs: OptimizedDocumentRowView, rhs: OptimizedDocumentRowView) -> Bool {
        lhs.document.id == rhs.document.id &&
        lhs.document.title == rhs.document.title &&
        lhs.document.type == rhs.document.type &&
        lhs.document.date == rhs.document.date &&
        lhs.document.category == rhs.document.category
    }
}

// MARK: - Optimized Lazy List
struct OptimizedLazyList<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                content
            }
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Performance Optimized Container
struct PerformanceOptimizedContainer<Content: View>: View {
    let content: Content
    @State private var isVisible = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            if isVisible {
                content
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                Color.clear
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isVisible = true
                        }
                    }
            }
        }
    }
}

// MARK: - Memoized View
struct MemoizedView<Content: View & Equatable>: View {
    let content: Content
    
    var body: some View {
        content
    }
}

// MARK: - Optimized Grid
struct OptimizedGrid<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let columns: [GridItem]
    let content: (Item) -> Content
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items) { item in
                    content(item)
                }
            }
            .padding()
        }
    }
}

// MARK: - View Extensions for Performance
extension View {
    func optimizedForPerformance() -> some View {
        self
            .drawingGroup() // Rasterize complex views
            .clipped() // Prevent overdraw
    }
    
    func conditionalModifier<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        Group {
            if condition {
                transform(self)
            } else {
                self
            }
        }
    }
    
    func measurePerformance(_ label: String) -> some View {
        self
            .onAppear {
                let startTime = CFAbsoluteTimeGetCurrent()
                DispatchQueue.main.async {
                    let endTime = CFAbsoluteTimeGetCurrent()
                    print("⏱️ \(label) render time: \(String(format: "%.2f", (endTime - startTime) * 1000))ms")
                }
            }
    }
}