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
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.pink)
                        
                        Text("Manounou")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Votre carnet de famille numérique")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 20) {
                        if isSignUp {
                            signUpForm
                        } else {
                            signInForm
                        }
                        
                        // Action Button
                        Button(action: handleAuthentication) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text(isSignUp ? "Créer mon compte" : "Se connecter")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(authManager.isLoading || !isFormValid)
                        
                        // Toggle Sign In/Up
                        Button(action: { isSignUp.toggle() }) {
                            Text(isSignUp ? "Déjà un compte ? Se connecter" : "Pas de compte ? S'inscrire")
                                .foregroundColor(.pink)
                                .fontWeight(.medium)
                        }
                        
                        // Forgot Password
                        if !isSignUp {
                            Button("Mot de passe oublié ?") {
                                showingForgotPassword = true
                            }
                            .foregroundColor(.secondary)
                            .font(.footnote)
                        }
                    }
                    .padding(.horizontal, 32)
                    
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
        VStack(spacing: 16) {
            CustomTextField(
                title: "Email",
                text: $email,
                keyboardType: .emailAddress
            )
            
            CustomSecureField(
                title: "Mot de passe",
                text: $password
            )
        }
    }
    
    // MARK: - Sign Up Form
    private var signUpForm: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                CustomTextField(
                    title: "Prénom",
                    text: $firstName
                )
                
                CustomTextField(
                    title: "Nom",
                    text: $lastName
                )
            }
            
            CustomTextField(
                title: "Email",
                text: $email,
                keyboardType: .emailAddress
            )
            
            CustomSecureField(
                title: "Mot de passe",
                text: $password
            )
            
            CustomSecureField(
                title: "Confirmer le mot de passe",
                text: $confirmPassword
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
                    password: password
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

// MARK: - Custom Text Field
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            TextField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
    }
}

// MARK: - Custom Secure Field
struct CustomSecureField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            SecureField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

// MARK: - Forgot Password View
struct ForgotPasswordView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 60))
                        .foregroundColor(.pink)
                    
                    Text("Réinitialiser le mot de passe")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Entrez votre email pour recevoir un lien de réinitialisation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 20) {
                    CustomTextField(
                        title: "Email",
                        text: $email,
                        keyboardType: .emailAddress
                    )
                    
                    Button(action: resetPassword) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Envoyer le lien")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(email.isEmpty ? Color.gray : Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(email.isEmpty || isLoading)
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .padding(.top, 40)
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