// AuthenticationView.swift — Manounou
// Sign in / Sign up screen with brand design.
// Contient aussi l'écran de reconnexion (ReconnectionView) — handoff
// « Connexion - Déconnecté » : état A (compte mémorisé + Face ID) / état B
// (connexion simple) + overlay biométrique. Regroupé ici pour rester dans la
// target Xcode sans modifier project.pbxproj (le projet n'utilise pas les
// groupes synchronisés ; un fichier neuf ne serait pas compilé).

import SwiftUI
import LocalAuthentication
import Security
import AuthenticationServices
import CryptoKit

// MARK: - Sign in with Apple (helpers partagés)

/// Outils « Sign in with Apple ».
///
/// ⚠️ Pré-requis runtime : la capacité *Sign in with Apple* (entitlement
/// `com.apple.developer.applesignin`) doit être activée sur l'App ID, ce qui
/// nécessite un compte **Apple Developer Program payant**. Sans elle, la requête
/// d'autorisation échoue à l'exécution (ASAuthorizationError code 1000). Le code
/// ci-dessous est néanmoins complet et correct : il suffira d'activer la
/// capacité dans Xcode + le provider Apple côté Supabase pour qu'il fonctionne.
enum AppleSignIn {
    /// Nonce aléatoire (valeur **brute**, à transmettre à Supabase).
    static func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var bytes = [UInt8](repeating: 0, count: length)
        guard SecRandomCopyBytes(kSecRandomDefault, length, &bytes) == errSecSuccess else {
            return UUID().uuidString + UUID().uuidString
        }
        return String(bytes.map { charset[Int($0) % charset.count] })
    }

    /// SHA256 du nonce (valeur **hashée**, à placer dans la requête Apple).
    static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

/// Bouton natif « Continuer avec Apple » avec gestion du nonce (anti-rejeu).
/// `onToken` reçoit l'idToken Apple et le nonce **brut** à passer à Supabase.
struct AppleSignInButton: View {
    var onToken: (_ idToken: String, _ nonce: String) -> Void
    var onError: (String) -> Void = { _ in }
    @State private var currentNonce: String?

    var body: some View {
        SignInWithAppleButton(.continue) { request in
            let nonce = AppleSignIn.randomNonceString()
            currentNonce = nonce
            request.requestedScopes = [.fullName, .email]
            request.nonce = AppleSignIn.sha256(nonce)
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                guard
                    let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                    let tokenData = credential.identityToken,
                    let idToken = String(data: tokenData, encoding: .utf8),
                    let nonce = currentNonce
                else {
                    onError("Jeton Apple invalide.")
                    return
                }
                onToken(idToken, nonce)
            case .failure(let error):
                // L'annulation volontaire ne doit pas afficher d'erreur.
                if (error as? ASAuthorizationError)?.code == .canceled { return }
                onError(error.localizedDescription)
            }
        }
    }
}

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

// =====================================================================
// MARK: - Reconnexion (handoff « Connexion - Déconnecté »)
// =====================================================================

// MARK: Identité mémorisée (dernier utilisateur connecté)

/// Identité affichée sur l'écran « compte mémorisé ».
struct RememberedIdentity {
    let email: String
    let displayName: String
}

/// Stockage du dernier utilisateur connecté.
/// - Infos d'affichage (email, nom) : `UserDefaults`.
/// - Mot de passe : Keychain lié à la biométrie (`.userPresence` + passcode), lu
///   uniquement via un `LAContext` déjà évalué pour éviter un second prompt.
enum RememberedAccount {
    private static let kEmail = "manounou_last_email"
    private static let kName  = "manounou_last_name"
    private static let pwdAccount = "manounou_last_password"

    static var current: RememberedIdentity? {
        let d = UserDefaults.standard
        guard let email = d.string(forKey: kEmail), !email.isEmpty else { return nil }
        let name = d.string(forKey: kName) ?? displayName(from: email)
        return RememberedIdentity(email: email, displayName: name)
    }

    static func remember(email: String, displayName: String, password: String) {
        let d = UserDefaults.standard
        d.set(email, forKey: kEmail)
        d.set(displayName, forKey: kName)
        KeychainStore.set(password, account: pwdAccount)
    }

    static func savedPassword(using context: LAContext) -> String? {
        KeychainStore.get(account: pwdAccount, context: context)
    }

    static func forget() {
        let d = UserDefaults.standard
        d.removeObject(forKey: kEmail)
        d.removeObject(forKey: kName)
        KeychainStore.delete(account: pwdAccount)
    }

    /// Dérive un nom lisible depuis la partie locale de l'email (ex. « awa.diallo » → « Awa Diallo »).
    static func displayName(from email: String) -> String {
        let local = email.split(separator: "@").first.map(String.init) ?? email
        let parts = local.split(whereSeparator: { $0 == "." || $0 == "_" || $0 == "-" })
        let cleaned = parts.map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined(separator: " ")
        return cleaned.isEmpty ? local : cleaned
    }
}

// MARK: Keychain (mot de passe protégé biométrie/passcode)

enum KeychainStore {
    private static let service = "com.manounou.credentials"

    static func set(_ value: String, account: String) {
        let base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(base as CFDictionary)
        // Protège l'item : lecture impossible sans biométrie ou code d'accès.
        // kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly garantit device-only +
        // invalidation si passcode retiré.
        guard let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            .userPresence,
            nil
        ) else { return }
        var add = base
        add[kSecValueData as String] = Data(value.utf8)
        add[kSecAttrAccessControl as String] = access
        SecItemAdd(add as CFDictionary, nil)
    }

    // Le contexte doit avoir été évalué via LAContext.evaluatePolicy avant l'appel
    // pour éviter un second prompt biométrique.
    static func get(account: String, context: LAContext) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: context
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let s = String(data: data, encoding: .utf8) else { return nil }
        return s
    }

    static func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: Biométrie (Face ID / Touch ID)

enum BiometricAuth {
    static var isAvailable: Bool {
        var error: NSError?
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    static var biometryType: LABiometryType {
        let ctx = LAContext()
        _ = ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return ctx.biometryType
    }

    static var label: String {
        switch biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "la biométrie"
        }
    }

    static var iconName: String {
        switch biometryType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        default: return "lock.fill"
        }
    }

    // Retourne le contexte évalué pour qu'il puisse être passé à KeychainStore.get
    // sans déclencher un second prompt biométrique.
    static func authenticate(reason: String) async -> LAContext? {
        let ctx = LAContext()
        do {
            let ok = try await ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            return ok ? ctx : nil
        } catch {
            return nil
        }
    }
}

// MARK: - ReconnectionView

/// Écran de reconnexion (app installée, utilisateur déconnecté).
/// État A : compte mémorisé + Face ID. État B : connexion simple email/mot de passe.
struct ReconnectionView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    private enum Screen { case remembered, plain }
    enum FacePhase: Equatable { case scan, done }

    @State private var screen: Screen
    @State private var face: FacePhase? = nil
    @State private var showAlt: Bool = false      // bottom sheet « Comment vous connecter ? »
    @State private var usePwd: Bool = false       // champ mot de passe inline (écran A)
    @State private var pwdA: String = ""          // mot de passe écran A
    @State private var emailB: String = ""        // email écran B
    @State private var pwdB: String = ""          // mot de passe écran B
    @FocusState private var focus: FieldID?

    private enum FieldID { case pwdA, emailB, pwdB }

    private let remembered = RememberedAccount.current

    init() {
        _screen = State(initialValue: RememberedAccount.current != nil ? .remembered : .plain)
    }

    // Tokens locaux dérivés du design system
    private let acc = AppTheme.Colors.brand
    private var accShadow: Color { AppTheme.Colors.brand.opacity(0.45) }
    private var accGhost: Color { AppTheme.Colors.brand.opacity(0.14) }
    private let disabledBg = Color(hex: "E7C9D2")
    private let ink = AppTheme.Colors.ink
    private let secondary = Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.6)
    private let validBorder = Color(hex: "1FA87A").opacity(0.45)

    var body: some View {
        ZStack {
            AppTheme.Colors.paper.ignoresSafeArea()
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: "FFE6EE"), Color(hex: "FFE6EE").opacity(0)]),
                center: UnitPoint(x: 0.5, y: -0.05), startRadius: 0, endRadius: 460
            )
            .ignoresSafeArea()

            Group {
                switch screen {
                case .remembered: rememberedScreen
                case .plain:      plainScreen
                }
            }
            .transition(.opacity)

            if showAlt {
                AltSignInSheet(
                    faceIdAvailable: BiometricAuth.isAvailable,
                    onFace: {
                        withAnimation(.easeInOut(duration: 0.2)) { showAlt = false }
                        Task { await unlockWithBiometrics() }
                    },
                    appleButton: appleButton,
                    onPassword: {
                        withAnimation { showAlt = false; usePwd = true; focus = .pwdA }
                    },
                    onClose: { withAnimation(.easeInOut(duration: 0.2)) { showAlt = false } }
                )
                .transition(.opacity)
                .zIndex(1)
            }

            if let face { FaceIdOverlay(phase: face, name: remembered?.displayName ?? "") }
        }
        .animation(.easeInOut(duration: 0.4), value: screen)
        .animation(.easeInOut(duration: 0.25), value: face != nil)
        .alert("Erreur", isPresented: Binding(
            get: { authViewModel.errorMessage != nil },
            set: { if !$0 { authViewModel.clearError() } }
        )) {
            Button("OK") { authViewModel.clearError() }
        } message: {
            Text(authViewModel.errorMessage ?? "Une erreur inattendue est survenue")
        }
    }

    // MARK: État A — compte mémorisé

    private var rememberedScreen: some View {
        VStack(spacing: 0) {
            HStack { Spacer(); ReconLogo(size: 30); Spacer() }

            Spacer(minLength: 0)

            VStack(spacing: 0) {
                VStack(spacing: 5) {
                    Text("Bon retour 👋")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(ink).tracking(-0.4)
                    Text("Reconnectez-vous pour retrouver votre foyer.")
                        .font(.system(size: 15.5, weight: .semibold, design: .rounded))
                        .foregroundColor(secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 26)

                // La carte d'identité est un bouton : elle ouvre la feuille
                // « Comment vous connecter ? » (Face ID · Apple · mot de passe).
                accountCardButton.padding(.bottom, usePwd ? 16 : 0)

                if usePwd {
                    ReconField(text: $pwdA, placeholder: "Mot de passe", secure: true,
                               valid: false, focused: focus == .pwdA, trailing: "Oublié ?")
                        .focused($focus, equals: .pwdA)
                    PrimaryButton(title: "Se connecter", systemIcon: nil,
                                  enabled: !pwdA.isEmpty) {
                        Task { await signInWithPassword(email: remembered?.email ?? "", password: pwdA) }
                    }
                    .padding(.top, 14)
                }
            }

            Spacer(minLength: 0)

            // Bas : séparateur « OU » conservé + « Changer de compte ».
            // (Apple et Face ID vivent désormais dans la feuille de connexion.)
            VStack(spacing: 0) {
                orSeparator.padding(.vertical, 4)
                Button {
                    withAnimation { screen = .plain; focus = .emailB }
                } label: {
                    HStack(spacing: 4) {
                        Text("Ce n'est pas vous ?").foregroundColor(secondary)
                        Text("Changer de compte").foregroundColor(acc)
                    }
                    .font(.system(size: 14.5, weight: .bold, design: .rounded))
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
            }
        }
        .padding(EdgeInsets(top: 64, leading: 26, bottom: 40, trailing: 26))
    }

    private var accountCardButton: some View {
        Button {
            focus = nil
            withAnimation(.easeInOut(duration: 0.2)) { showAlt = true }
        } label: {
            HStack(spacing: 14) {
                ZStack(alignment: .bottomTrailing) {
                    Circle().fill(AppTheme.Colors.blue).frame(width: 54, height: 54)
                    Text(String(remembered?.displayName.prefix(1) ?? "?"))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 54, height: 54)
                    Circle().fill(Color.white).frame(width: 20, height: 20)
                        .overlay(Image(systemName: "house.fill").font(.system(size: 9, weight: .bold)).foregroundColor(acc))
                        .shadow(color: .black.opacity(0.15), radius: 1.5, y: 1)
                        .offset(x: 3, y: 3)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(remembered?.displayName ?? "Mon compte")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(ink)
                    Text(remembered?.email ?? "")
                        .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.58))
                        .lineLimit(1)
                    Text("Toucher pour se connecter")
                        .font(.system(size: 12.5, weight: .bold, design: .rounded))
                        .foregroundColor(acc)
                        .padding(.top, 5)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.3))
            }
            .padding(18)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.black.opacity(0.07), lineWidth: 1.8))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(ReconPressStyle())
    }

    // MARK: État B — connexion simple

    private var plainScreen: some View {
        VStack(spacing: 0) {
            HStack {
                if remembered != nil {
                    Button { withAnimation { screen = .remembered } } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(ink)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(Color.white))
                            .overlay(Circle().stroke(Color.black.opacity(0.10), lineWidth: 1.6))
                    }
                    .buttonStyle(.plain)
                } else {
                    Spacer().frame(width: 38, height: 38)
                }
                Spacer()
                ReconLogo(size: 26)
                Spacer()
                Spacer().frame(width: 38, height: 38)
            }

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Content de vous revoir")
                        .font(.system(size: 29, weight: .bold, design: .rounded))
                        .foregroundColor(ink).tracking(-0.4)
                    Text("Connectez-vous à votre compte Manounou.")
                        .font(.system(size: 15.5, weight: .semibold, design: .rounded))
                        .foregroundColor(secondary)
                }
                .padding(.bottom, 22)

                appleButton
                orSeparator.padding(.vertical, 18)

                fieldLabel("EMAIL")
                ReconField(text: $emailB, placeholder: "vous@exemple.fr", secure: false,
                           valid: isEmail(emailB), focused: focus == .emailB,
                           keyboard: .emailAddress)
                    .focused($focus, equals: .emailB)
                    .padding(.bottom, 14)

                fieldLabel("MOT DE PASSE")
                ReconField(text: $pwdB, placeholder: "Votre mot de passe", secure: true,
                           valid: false, focused: focus == .pwdB, trailing: "Oublié ?")
                    .focused($focus, equals: .pwdB)

                PrimaryButton(title: "Se connecter", systemIcon: nil,
                              enabled: isEmail(emailB) && !pwdB.isEmpty) {
                    Task { await signInWithPassword(email: emailB, password: pwdB) }
                }
                .padding(.top, 20)
            }

            Spacer(minLength: 0)

            Button { authViewModel.toggleMode() } label: {
                HStack(spacing: 4) {
                    Text("Pas encore de compte ?").foregroundColor(secondary)
                    Text("Créer un foyer").foregroundColor(acc)
                }
                .font(.system(size: 14.5, weight: .bold, design: .rounded))
            }
            .buttonStyle(.plain)
        }
        .padding(EdgeInsets(top: 64, leading: 26, bottom: 40, trailing: 26))
    }

    // MARK: Sous-vues partagées

    private func fieldLabel(_ s: String) -> some View {
        Text(s)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundColor(Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.62))
            .tracking(0.2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 7)
    }

    private var orSeparator: some View {
        HStack(spacing: 10) {
            Rectangle().fill(Color.black.opacity(0.07)).frame(height: 1.5)
            Text("OU").font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(Color.black.opacity(0.22))
            Rectangle().fill(Color.black.opacity(0.07)).frame(height: 1.5)
        }
    }

    /// Bouton « Continuer avec Apple » natif, stylé pour matcher le design system.
    private var appleButton: some View {
        AppleSignInButton(
            onToken: { idToken, nonce in
                Task { await authViewModel.signInWithApple(idToken: idToken, nonce: nonce) }
            },
            onError: { message in authViewModel.errorMessage = message }
        )
        .signInWithAppleButtonStyle(.whiteOutline)
        .frame(height: 54)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.12), lineWidth: 1.8))
    }

    // MARK: Logique

    private func isEmail(_ s: String) -> Bool {
        s.range(of: "\\S+@\\S+\\.\\S+", options: .regularExpression) != nil
    }

    private func unlockWithBiometrics() async {
        face = .scan
        guard let ctx = await BiometricAuth.authenticate(reason: "Déverrouiller Manounou"),
              let id = remembered,
              let pwd = RememberedAccount.savedPassword(using: ctx) else {
            face = nil
            withAnimation { usePwd = true; focus = .pwdA }
            return
        }
        face = .done
        try? await Task.sleep(nanoseconds: 800_000_000)
        await authViewModel.signIn(email: id.email, password: pwd)
        if !authViewModel.isAuthenticated {
            face = nil
            withAnimation { usePwd = true }
        }
        // En cas de succès, RootView remplace cet écran automatiquement.
    }

    private func signInWithPassword(email: String, password: String) async {
        await authViewModel.signIn(email: email, password: password)
        if authViewModel.isAuthenticated {
            RememberedAccount.remember(
                email: email,
                displayName: remembered?.displayName ?? RememberedAccount.displayName(from: email),
                password: password
            )
        }
    }
}

// MARK: - Composants Reconnexion

private struct ReconLogo: View {
    var size: CGFloat = 30
    var body: some View {
        HStack(spacing: 9) {
            FourPointStar().fill(AppTheme.Colors.brand).frame(width: size, height: size)
            Text("Manounou")
                .font(.system(size: size * 0.82, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.Colors.ink)
                .tracking(-0.5)
        }
    }
}

private struct FourPointStar: Shape {
    func path(in rect: CGRect) -> Path {
        let pts: [(CGFloat, CGFloat)] = [
            (12, 2), (14.3, 8.6), (21, 11), (14.3, 13.4),
            (12, 20), (9.7, 13.4), (3, 11), (9.7, 8.6)
        ]
        let sx = rect.width / 24, sy = rect.height / 24
        var p = Path()
        for (i, pt) in pts.enumerated() {
            let point = CGPoint(x: rect.minX + pt.0 * sx, y: rect.minY + pt.1 * sy)
            if i == 0 { p.move(to: point) } else { p.addLine(to: point) }
        }
        p.closeSubpath()
        return p
    }
}

private struct ReconPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct PrimaryButton: View {
    let title: String
    var systemIcon: String?
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: { if enabled { action() } }) {
            HStack(spacing: 10) {
                if let systemIcon { Image(systemName: systemIcon).font(.system(size: 18, weight: .semibold)) }
                Text(title)
            }
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(enabled ? AppTheme.Colors.brand : Color(hex: "E7C9D2"))
            )
            .shadow(color: enabled ? AppTheme.Colors.brand.opacity(0.45) : .clear,
                    radius: 12, x: 0, y: 8)
        }
        .buttonStyle(ReconPressStyle())
        .disabled(!enabled)
    }
}

private struct GhostButton: View {
    let title: String
    var systemIcon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                if let systemIcon { Image(systemName: systemIcon).font(.system(size: 17)) }
                Text(title)
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(AppTheme.Colors.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.12), lineWidth: 1.8))
        }
        .buttonStyle(ReconPressStyle())
    }
}

private struct ReconField: View {
    @Binding var text: String
    let placeholder: String
    let secure: Bool
    let valid: Bool
    let focused: Bool
    var keyboard: UIKeyboardType = .default
    var trailing: String? = nil

    private var borderColor: Color {
        if focused { return AppTheme.Colors.brand }
        if valid { return Color(hex: "1FA87A").opacity(0.45) }
        return Color.black.opacity(0.10)
    }

    var body: some View {
        HStack(spacing: 8) {
            Group {
                if secure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(AppTheme.Colors.ink)

            if let trailing {
                Text(trailing)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.55))
            }
        }
        .padding(.horizontal, 15)
        .frame(height: 54)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(borderColor, lineWidth: 1.8))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.Colors.brand.opacity(focused ? 0.14 : 0), lineWidth: 4))
        .animation(.easeInOut(duration: 0.15), value: focused)
        .animation(.easeInOut(duration: 0.15), value: valid)
    }
}

// MARK: Overlay Face ID

private struct FaceIdOverlay: View {
    let phase: ReconnectionView.FacePhase
    let name: String
    @State private var scanY: CGFloat = -28

    var body: some View {
        ZStack {
            Color(red: 20/255, green: 14/255, blue: 18/255).opacity(0.55)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                ZStack {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(phase == .done ? Color(hex: "1FA87A") : Color.white.opacity(0.16))
                        .frame(width: 96, height: 96)
                        .overlay(RoundedRectangle(cornerRadius: 26).stroke(Color.white.opacity(0.25), lineWidth: 1))

                    if phase == .done {
                        Image(systemName: "checkmark")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "faceid")
                            .font(.system(size: 50, weight: .regular))
                            .foregroundColor(.white)
                        Rectangle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 70, height: 2)
                            .shadow(color: .white.opacity(0.8), radius: 6)
                            .offset(y: scanY)
                    }
                }
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 26))

                VStack(spacing: 4) {
                    Text(phase == .done ? "Bienvenue\(name.isEmpty ? "" : ", \(name)")" : "\(BiometricAuth.label)…")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(phase == .done ? "Ouverture de votre foyer" : "Regardez votre écran")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .onAppear {
            scanY = -28
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { scanY = 28 }
        }
    }
}

// MARK: Feuille « Comment vous connecter ? »

/// Bottom sheet ouverte en touchant la carte du compte mémorisé.
/// Propose les modes de connexion : Face ID (si dispo), Apple, mot de passe.
private struct AltSignInSheet<AppleButton: View>: View {
    let faceIdAvailable: Bool
    let onFace: () -> Void
    let appleButton: AppleButton
    let onPassword: () -> Void
    let onClose: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 20/255, green: 14/255, blue: 18/255).opacity(0.4)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 0) {
                Capsule().fill(Color.black.opacity(0.16))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12).padding(.bottom, 16)

                Text("Comment vous connecter ?")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.ink)
                Text("Choisissez votre mode de connexion.")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.6))
                    .padding(.top, 3).padding(.bottom, 20)

                VStack(spacing: 12) {
                    if faceIdAvailable {
                        PrimaryButton(title: "Déverrouiller avec \(BiometricAuth.label)",
                                      systemIcon: BiometricAuth.iconName, enabled: true,
                                      action: onFace)
                    }
                    appleButton
                    GhostButton(title: "Saisir le mot de passe", systemIcon: "key.fill",
                                action: onPassword)
                }

                Button("Annuler", action: onClose)
                    .buttonStyle(.plain)
                    .font(.system(size: 14.5, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.55))
                    .padding(.top, 14)
            }
            .padding(EdgeInsets(top: 0, leading: 22, bottom: 30, trailing: 22))
            .frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(topLeadingRadius: 26, topTrailingRadius: 26)
                    .fill(Color(hex: "F6F3EF"))
            )
            .shadow(color: .black.opacity(0.16), radius: 30, x: 0, y: -8)
            .offset(y: appeared ? 0 : 600)
        }
        .onAppear {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) { appeared = true }
        }
    }
}
