import SwiftUI

// MARK: - ThemedTextField
struct ThemedTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    
    init(
        _ title: String,
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(AppTheme.Typography.footnote)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            TextField(placeholder, text: $text)
                .font(AppTheme.Typography.body)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .textFieldStyle(.roundedBorder)
        }
    }
}

// MARK: - ThemedButton
struct ThemedButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    
    init(_ title: String, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.body)
                .frame(maxWidth: .infinity)
        }
        .themedButton(style: style)
    }
}

// MARK: - LoadingView
struct LoadingView: View {
    let message: String
    
    init(_ message: String = "Chargement...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(AppTheme.Colors.primary)
            
            Text(message)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(AppTheme.Spacing.xl)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.card)
        .shadow(
            color: AppTheme.Shadow.card.color,
            radius: AppTheme.Shadow.card.radius,
            x: AppTheme.Shadow.card.x,
            y: AppTheme.Shadow.card.y
        )
    }
}

// MARK: - ErrorView
struct ErrorView: View {
    let message: String
    var onRetry: (() -> Void)? = nil
    
    init(message: String, onRetry: (() -> Void)? = nil) {
        self.message = message
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.Colors.error)
            
            Text("Erreur")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text(message)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            if let onRetry = onRetry {
                Button("Réessayer", action: onRetry)
                    .themedButton(style: .primary)
            }
        }
        .padding(AppTheme.Spacing.xl)
        .background(AppTheme.Colors.surface)
        .cornerRadius(AppTheme.CornerRadius.card)
        .shadow(
            color: AppTheme.Shadow.card.color,
            radius: AppTheme.Shadow.card.radius,
            x: AppTheme.Shadow.card.x,
            y: AppTheme.Shadow.card.y
        )
    }
}

// MARK: - Preview
#if DEBUG
struct ThemedComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ThemedTextField(
                "Email",
                text: .constant("test@example.com"),
                placeholder: "Entrez votre email",
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            
            ThemedButton("Connexion") {
                print("Button tapped")
            }
            
            LoadingView("Chargement en cours...")
            
            ErrorView(message: "Une erreur s'est produite") {
                print("Retry tapped")
            }
        }
        .padding()
        .background(AppTheme.Colors.background)
    }
}
#endif