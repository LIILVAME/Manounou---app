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
        GeometryReader { geometry in
            ZStack {
                // Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.3),
                        Color.pink.opacity(0.2),
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Top curved background
                        VStack {
                            Spacer()
                        }
                        .frame(height: geometry.size.height * 0.4)
                        .background(
                            RoundedRectangle(cornerRadius: 0)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.purple.opacity(0.8),
                                            Color.pink.opacity(0.6)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        
                        // White content area
                        VStack(spacing: 30) {
                            // Header
                            VStack(spacing: 16) {
                                Text(isSignUp ? "Create account" : "Login")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                if !isSignUp {
                                    HStack {
                                        Text("Don't have an account?")
                                            .foregroundColor(.gray)
                                        Button("sign up") {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                isSignUp = true
                                            }
                                        }
                                        .foregroundColor(.purple)
                                        .fontWeight(.medium)
                                    }
                                    .font(.subheadline)
                                } else {
                                    HStack {
                                        Text("Already have an account?")
                                            .foregroundColor(.gray)
                                        Button("sign in") {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                isSignUp = false
                                            }
                                        }
                                        .foregroundColor(.purple)
                                        .fontWeight(.medium)
                                    }
                                    .font(.subheadline)
                                }
                            }
                            .padding(.top, -20)
                    
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
                                            Text(isSignUp ? "Sign up" : "Login")
                                                .fontWeight(.semibold)
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.purple,
                                                Color.pink
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(28)
                                }
                                .disabled(authManager.isLoading || !isFormValid)
                                
                                // Forgot Password
                                if !isSignUp {
                                    Button("FORGOT?") {
                                        showingForgotPassword = true
                                    }
                                    .foregroundColor(.purple)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                }
                                
                                // Social Login (placeholder)
                                if !isSignUp {
                                    HStack(spacing: 20) {
                                        SocialLoginButton(icon: "apple.logo", color: .black)
                                        SocialLoginButton(icon: "f.circle.fill", color: .blue)
                                        SocialLoginButton(icon: "g.circle.fill", color: .red)
                                        SocialLoginButton(icon: "message.circle.fill", color: .blue)
                                    }
                                    .padding(.top, 20)
                                }
                            }
                            .padding(.horizontal, 32)
                            
                            Spacer(minLength: 40)
                        }
                        .background(Color.white)
                        .cornerRadius(30, corners: [.topLeft, .topRight])
                        .padding(.top, -30)
                    }
                }
            }
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

// MARK: - Custom Text Field
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(title, text: $text)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
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
            SecureField(title, text: $text)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
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

struct SocialLoginButton: View {
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthManager())
}