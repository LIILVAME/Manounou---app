import SwiftUI

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    let placeholder: String
    
    init(text: Binding<String>, isSearching: Binding<Bool>, placeholder: String = "Rechercher...") {
        self._text = text
        self._isSearching = isSearching
        self.placeholder = placeholder
    }
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onTapGesture {
                        isSearching = true
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        isSearching = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if isSearching {
                Button("Annuler") {
                    text = ""
                    isSearching = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSearching)
    }
}

// MARK: - Error State View
struct ErrorStateView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Erreur")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Réessayer") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Loading State View
struct LoadingStateView: View {
    let message: String
    
    init(message: String = "Chargement...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    VStack(spacing: 20) {
        SearchBar(text: .constant(""), isSearching: .constant(false))
        
        SearchBar(text: .constant("Test"), isSearching: .constant(true))
        
        ErrorStateView(error: NSError(domain: "Test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Erreur de test"])) {
            print("Retry tapped")
        }
        
        LoadingStateView()
    }
    .padding()
}