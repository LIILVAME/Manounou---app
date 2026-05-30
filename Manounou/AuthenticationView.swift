// AuthenticationView.swift — Manounou
// Sign in / Sign up screen with brand design.

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @FocusState private var focusedField: AuthField?
    @State private var showingPasswordReset = false
    @State private var firstName = ""
    @State private var lastName  = ""

    enum AuthField { case email, password, firstName, lastName }

    var body: some View {
        ZStack {
            AppTheme.Colors.paper.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    authHeader
                        .padding(.top, 60)
                        .padding(.bottom, 40)

                    // Form card
                    formCard
                        .padding(.horizontal, 24)

                    // Toggle mode
                    toggleButton
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .alert("Erreur", isPresented: Binding(
            get: { authViewModel.errorMessage != nil },
            set: { if !$0 { authViewModel.clearError() } }
        )) {
            Button("OK") { authViewModel.clearError() }
        } message: {
            Text(authViewModel.errorMessage ?? "Une erreur inattendue est survenue")
        }
        .sheet(isPresented: $showingPasswordReset) {
            PasswordResetSheet()
                .environmentObject(authViewModel)
        }
    }

    // MARK: - Header

    private var authHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.Colors.brand, Color(hex: "D4305A")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: AppTheme.Colors.brandShadow, radius: 16, x: 0, y: 6)
                Image(systemName: "heart.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 6) {
                Text("Manounou")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.ink)
                Text(authViewModel.isSignUpMode
                     ? "Créez votre compte"
                     : "Bon retour parmi nous")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.muted)
            }
        }
    }

    // MARK: - Form card

    private var formCard: some View {
        VStack(spacing: 16) {
            // Sign-up extra fields
            if authViewModel.isSignUpMode {
                HStack(spacing: 12) {
                    AuthTextField(
                        placeholder: "Prénom",
                        text: $firstName,
                        focused: $focusedField,
                        field: .firstName,
                        nextField: .lastName,
                        contentType: .givenName
                    )
                    AuthTextField(
                        placeholder: "Nom",
                        text: $lastName,
                        focused: $focusedField,
                        field: .lastName,
                        nextField: .email,
                        contentType: .familyName
                    )
                }
            }

            AuthTextField(
                placeholder: "Adresse e-mail",
                text: .init(get: { authViewModel.email }, set: { authViewModel.email = $0 }),
                focused: $focusedField,
                field: .email,
                nextField: .password,
                contentType: .emailAddress,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )

            AuthTextField(
                placeholder: "Mot de passe",
                text: .init(get: { authViewModel.password }, set: { authViewModel.password = $0 }),
                focused: $focusedField,
                field: .password,
                secure: true,
                contentType: authViewModel.isSignUpMode ? .newPassword : .password
            )

            // Forgot password (sign in only)
            if !authViewModel.isSignUpMode {
                Button("Mot de passe oublié ?") {
                    showingPasswordReset = true
                }
                .font(AppTheme.Typography.footnote)
                .foregroundColor(AppTheme.Colors.brand)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            // CTA button
            Button {
                Task {
                    if authViewModel.isSignUpMode {
                        await authViewModel.signUp()
                        // Update profile name after account creation
                        if !firstName.isEmpty {
                            await authViewModel.updateProfile(firstName: firstName, lastName: lastName)
                        }
                    } else {
                        await authViewModel.signIn()
                    }
                }
            } label: {
                ZStack {
                    if authViewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(authViewModel.isSignUpMode ? "Créer mon compte" : "Se connecter")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(ctaEnabled
                              ? LinearGradient(colors: [AppTheme.Colors.brand, Color(hex: "D4305A")],
                                               startPoint: .leading, endPoint: .trailing)
                              : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                               startPoint: .leading, endPoint: .trailing))
                )
                .shadow(color: ctaEnabled ? AppTheme.Colors.brandShadow : .clear,
                        radius: 10, x: 0, y: 4)
            }
            .disabled(!ctaEnabled || authViewModel.isLoading)
            .animation(AppTheme.Animation.quick, value: ctaEnabled)
        }
        .padding(20)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl))
        .shadow(color: AppTheme.Shadow.card.color,
                radius: AppTheme.Shadow.card.radius,
                x: AppTheme.Shadow.card.x,
                y: AppTheme.Shadow.card.y)
    }

    // MARK: - Toggle mode

    private var toggleButton: some View {
        Button {
            withAnimation(AppTheme.Animation.standard) {
                authViewModel.toggleMode()
            }
        } label: {
            HStack(spacing: 4) {
                Text(authViewModel.isSignUpMode
                     ? "Vous avez déjà un compte ?"
                     : "Pas encore de compte ?")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.muted)
                Text(authViewModel.isSignUpMode ? "Se connecter" : "S'inscrire")
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.brand)
            }
        }
    }

    // MARK: - Validation

    private var ctaEnabled: Bool {
        let emailOk = authViewModel.email.contains("@")
        let passOk  = authViewModel.password.count >= 6
        if authViewModel.isSignUpMode {
            return emailOk && passOk && !firstName.isEmpty
        }
        return emailOk && passOk
    }
}

// MARK: - Auth TextField

private struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var focused: FocusState<AuthenticationView.AuthField?>.Binding
    let field: AuthenticationView.AuthField
    var nextField: AuthenticationView.AuthField? = nil
    var secure: Bool = false
    var contentType: UITextContentType? = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .words

    var body: some View {
        Group {
            if secure {
                SecureField(placeholder, text: $text)
                    .textContentType(contentType)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled()
                    .textContentType(contentType)
            }
        }
        .font(AppTheme.Typography.body)
        .focused(focused, equals: field)
        .submitLabel(nextField == nil ? .done : .next)
        .onSubmit {
            if let next = nextField { focused.wrappedValue = next }
            else { focused.wrappedValue = nil }
        }
        .padding(.horizontal, 14)
        .frame(height: 50)
        .background(AppTheme.Colors.paper)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(focused.wrappedValue == field
                        ? AppTheme.Colors.brand
                        : AppTheme.Colors.border,
                        lineWidth: focused.wrappedValue == field ? 1.5 : 1)
        )
    }
}

// MARK: - Password Reset Sheet

private struct PasswordResetSheet: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var resetEmail = ""
    @State private var sent = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "envelope.badge.shield.half.filled.fill")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.Colors.brand)
                    .padding(.top, 20)

                VStack(spacing: 8) {
                    Text("Réinitialiser le mot de passe")
                        .font(AppTheme.Typography.title3)
                    Text("Entrez votre e-mail pour recevoir un lien de réinitialisation.")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.muted)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)

                if sent {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(AppTheme.Colors.green)
                        Text("E-mail envoyé !")
                            .font(AppTheme.Typography.headline)
                        Text("Vérifiez votre boîte de réception.")
                            .font(AppTheme.Typography.footnote)
                            .foregroundColor(AppTheme.Colors.muted)
                    }
                    .padding()
                } else {
                    TextField("Adresse e-mail", text: $resetEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 14)
                        .frame(height: 50)
                        .background(AppTheme.Colors.paper)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.Colors.border))
                        .padding(.horizontal, 24)

                    Button {
                        Task {
                            await authViewModel.resetPassword(email: resetEmail)
                            sent = true
                        }
                    } label: {
                        Text("Envoyer le lien")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(resetEmail.contains("@") ? AppTheme.Colors.brand : Color.gray.opacity(0.3))
                            )
                    }
                    .disabled(!resetEmail.contains("@"))
                    .padding(.horizontal, 24)
                }

                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") { dismiss() }
                        .foregroundColor(AppTheme.Colors.brand)
                }
            }
        }
    }
}
