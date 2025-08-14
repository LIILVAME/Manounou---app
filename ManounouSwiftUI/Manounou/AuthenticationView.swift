//
//  AuthenticationView.swift
//  Manounou
//
//  Created by Assistant on 2025-01-13.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isLoading = false
    @State private var showingForgotPassword = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header avec logo Manounou
                    VStack(spacing: ManounouSpacing.lg) {
                        ManounouLogo(size: 100)
                        
                        Text("Manounou")
                            .font(ManounouTypography.bold(ManounouTypography.hero))
                            .foregroundColor(ManounouColors.textPrimary)
                        
                        Text("Simplifiez la garde")
                            .font(ManounouTypography.medium(ManounouTypography.lg))
                            .foregroundColor(ManounouColors.primary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, ManounouSpacing.xxxl)
                    
                    // Form
                    VStack(spacing: 20) {
                        if isSignUp {
                            signUpForm
                        } else {
                            signInForm
                        }
                        
                        // Action Button avec style Manounou
                        Button(action: handleAuthentication) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text(isSignUp ? "Créer mon compte" : "Se connecter")
                                }
                            }
                        }
                        .buttonStyle(ManounouPrimaryButtonStyle(isDisabled: authManager.isLoading || !isFormValid))
                        .disabled(authManager.isLoading || !isFormValid)
                        
                        // Toggle Sign In/Up avec style Manounou
                        Button(action: { isSignUp.toggle() }) {
                            Text(isSignUp ? "Déjà un compte ? Se connecter" : "Pas de compte ? S'inscrire")
                        }
                        .buttonStyle(ManounouTertiaryButtonStyle())
                        
                        // Forgot Password avec style Manounou
                        if !isSignUp {
                            Button("Mot de passe oublié ?") {
                                showingForgotPassword = true
                            }
                            .font(ManounouTypography.sm)
                            .foregroundColor(ManounouColors.textSecondary)
                        }
                    }
                    .padding(.horizontal, ManounouSpacing.xl)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Erreur", isPresented: .constant(authManager.errorMessage != nil)) {
            Button("OK") {
                authManager.clearError()
            }
        } message: {
            Text(authManager.errorMessage ?? "")
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView()
        }
    }
    
    // MARK: - Sign In Form
    private var signInForm: some View {
        VStack(spacing: ManounouSpacing.lg) {
            ManounouTextField(
                title: "Email",
                text: $email,
                keyboardType: .emailAddress,
                isRequired: true
            )
            
            ManounouSecureField(
                title: "Mot de passe",
                text: $password,
                isRequired: true
            )
        }
    }
    
    // MARK: - Sign Up Form
    private var signUpForm: some View {
        VStack(spacing: ManounouSpacing.lg) {
            HStack(spacing: ManounouSpacing.md) {
                ManounouTextField(
                    title: "Prénom",
                    text: $firstName,
                    isRequired: true
                )
                
                ManounouTextField(
                    title: "Nom",
                    text: $lastName,
                    isRequired: true
                )
            }
            
            ManounouTextField(
                title: "Email",
                text: $email,
                keyboardType: .emailAddress,
                isRequired: true
            )
            
            ManounouSecureField(
                title: "Mot de passe",
                text: $password,
                isRequired: true
            )
            
            ManounouSecureField(
                title: "Confirmer le mot de passe",
                text: $confirmPassword,
                isRequired: true
            )
        }
    }
    
    // MARK: - Validation
    private var isFormValid: Bool {
        if isSignUp {
            return !firstName.isEmpty &&
                   !lastName.isEmpty &&
                   !email.isEmpty &&
                   password.count >= 6 &&
                   password == confirmPassword
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    // MARK: - Actions
    private func handleAuthentication() {
        Task {
            if isSignUp {
                await authManager.signUp(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName
                )
            } else {
                await authManager.signIn(email: email, password: password)
            }
            
            // Vider les champs après tentative d'authentification
            await MainActor.run {
                if authManager.isAuthenticated {
                    clearFields()
                }
            }
        }
    }
    
    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        firstName = ""
        lastName = ""
    }
}

// MARK: - Composants remplacés par le système de design Manounou
// Les composants CustomTextField et CustomSecureField ont été remplacés
// par ManounouTextField et ManounouSecureField du DesignSystem.swift

// MARK: - Forgot Password View
struct ForgotPasswordView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: ManounouSpacing.xl) {
                VStack(spacing: ManounouSpacing.lg) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 60))
                        .foregroundColor(ManounouColors.primary)
                    
                    Text("Réinitialiser le mot de passe")
                        .font(ManounouTypography.bold(ManounouTypography.xxl))
                        .foregroundColor(ManounouColors.textPrimary)
                    
                    Text("Entrez votre email pour recevoir un lien de réinitialisation")
                        .font(ManounouTypography.base)
                        .foregroundColor(ManounouColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: ManounouSpacing.lg) {
                    ManounouTextField(
                        title: "Email",
                        text: $email,
                        keyboardType: .emailAddress,
                        isRequired: true
                    )
                    
                    Button(action: resetPassword) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Envoyer le lien")
                            }
                        }
                    }
                    .buttonStyle(ManounouPrimaryButtonStyle(isDisabled: email.isEmpty || isLoading))
                    .disabled(email.isEmpty || isLoading)
                }
                .padding(.horizontal, ManounouSpacing.xl)
                
                Spacer()
            }
            .padding(.top, ManounouSpacing.xxxl)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Email envoyé", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Vérifiez votre boîte email pour le lien de réinitialisation.")
        }
    }
    
    private func resetPassword() {
        isLoading = true
        
        Task {
            await authManager.resetPassword(email: email)
            
            await MainActor.run {
                isLoading = false
                showingSuccess = true
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthManager())
}