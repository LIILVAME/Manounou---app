//
//  AuthenticationView.swift
//  Manounou
//
//  Created by Assistant on 2025-01-13.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                LogoView(size: .large, style: .full)
                    .padding(.top, 40)
                
                Group {
                    if authViewModel.isSignUpMode {
                        signUpForm
                    } else {
                        signInForm
                    }
                }
                .padding(.horizontal)
                
                toggleModeButton
                    .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle(authViewModel.isSignUpMode ? "Créer un compte" : "Se connecter")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fermer") { hideKeyboard() }
                }
            }
            .alert("Erreur", isPresented: Binding<Bool>(
                get: { authViewModel.errorMessage != nil },
                set: { newVal in if !newVal { authViewModel.clearError() } }
            )) {
                Button("OK") { authViewModel.clearError() }
            } message: {
                Text(authViewModel.errorMessage ?? "Une erreur inattendue est survenue")
            }
        }
    }
    
    private var signInForm: some View {
        VStack(spacing: 16) {
            TextField("Email", text: Binding(
                get: { authViewModel.email },
                set: { authViewModel.email = $0 }
            ))
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .focused($isEmailFocused)
            .submitLabel(.next)
            
            SecureField("Mot de passe", text: Binding(
                get: { authViewModel.password },
                set: { authViewModel.password = $0 }
            ))
            .focused($isPasswordFocused)
            .submitLabel(.go)
            
            Button(action: {
                Task { await authViewModel.signIn() }
            }) {
                Text("Se connecter")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(authViewModel.isLoading || authViewModel.email.isEmpty || authViewModel.password.isEmpty)
            
            Button("Mot de passe oublié ?") {
                Task { await authViewModel.resetPassword() }
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
    }
    
    private var signUpForm: some View {
        VStack(spacing: 16) {
            TextField("Email", text: Binding(
                get: { authViewModel.email },
                set: { authViewModel.email = $0 }
            ))
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .focused($isEmailFocused)
            .submitLabel(.next)
            
            SecureField("Mot de passe", text: Binding(
                get: { authViewModel.password },
                set: { authViewModel.password = $0 }
            ))
            .focused($isPasswordFocused)
            .submitLabel(.go)
            
            Button(action: {
                Task { await authViewModel.signUp() }
            }) {
                Text("Créer le compte")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(authViewModel.isLoading || authViewModel.email.isEmpty || authViewModel.password.isEmpty)
        }
    }
    
    private var toggleModeButton: some View {
        Button(action: { authViewModel.toggleMode() }) {
            HStack(spacing: 6) {
                Text(authViewModel.isSignUpMode ? "Déjà inscrit ?" : "Nouveau sur Manounou ?")
                Text(authViewModel.isSignUpMode ? "Se connecter" : "Créer un compte")
                    .fontWeight(.semibold)
            }
        }
        .buttonStyle(.plain)
        .tint(colorScheme == .dark ? .white : .blue)
    }
    
    private func hideKeyboard() {
        isEmailFocused = false
        isPasswordFocused = false
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AppContainer.shared.authViewModel)
}