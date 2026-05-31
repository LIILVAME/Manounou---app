// OnboardingView.swift — Manounou
// 6-step guided onboarding flow with carousel intro.
//
// Steps:
//   -1  Carousel (3 slides)
//    0  Créer le compte
//    1  Votre foyer
//    2  Votre enfant
//    3  Votre nounou / baby-sitter
//    4  Récapitulatif

import SwiftUI
import AuthenticationServices

// MARK: - Public entry point

public struct OnboardingView: View {

    // MARK: Navigation callback
    public var onComplete: () -> Void

    // MARK: Environment
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var appContainer: AppContainer

    // MARK: State
    @State private var step: Int = -1
    @State private var carouselPage: Int = 0

    // Account creation control
    @State private var isCreatingAccount = false
    @State private var accountError: String? = nil
    @State private var isCompletingOnboarding = false
    /// Nonce brut courant pour Sign in with Apple (transmis ensuite à Supabase).
    @State private var currentNonce: String? = nil

    // Step 0
    @State private var email: String = ""
    @State private var password: String = ""

    // Step 1
    @State private var foyerName: String = ""

    // Step 2
    @State private var childFirstName: String = ""
    @State private var childAge: String = ""
    @State private var allergies: Set<String> = []

    // Step 3
    @State private var nannyEmail: String = ""
    @State private var hourlyRate: String = "4.50"
    @State private var maintenanceRate: String = "3.50"

    // Step 4
    @State private var notificationsEnabled: Bool = true

    // Keyboard dismissal
    @FocusState private var focusedField: OnboardingField?

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    // MARK: Body

    public var body: some View {
        ZStack {
            AppTheme.Colors.paper.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Top bar (back button + progress) ──
                topBar

                // ── Content ──
                Group {
                    if step == -1 {
                        carouselStep
                    } else if step == 0 {
                        accountStep
                    } else if step == 1 {
                        foyerStep
                    } else if step == 2 {
                        childStep
                    } else if step == 3 {
                        nannyStep
                    } else {
                        summaryStep
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(step)
            }
        }
        .animation(AppTheme.Animation.standard, value: step)
        .onTapGesture { focusedField = nil }
    }

    // MARK: - Top bar

    @ViewBuilder
    private var topBar: some View {
        if step >= 0 {
            HStack(spacing: AppTheme.Spacing.md) {
                // Back chevron (steps 1–4 only)
                if step >= 1 {
                    Button {
                        withAnimation(AppTheme.Animation.standard) {
                            if step == 1 && authViewModel.isAuthenticated {
                                step = -1
                            } else {
                                step -= 1
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.Colors.ink)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.Colors.surface)
                            .clipShape(Circle())
                            .shadow(color: AppTheme.Shadow.small.color,
                                    radius: AppTheme.Shadow.small.radius,
                                    x: AppTheme.Shadow.small.x,
                                    y: AppTheme.Shadow.small.y)
                    }
                } else {
                    Spacer().frame(width: 36)
                }

                // Progress bar (steps 0–4, 5 segments)
                progressBar

                Spacer().frame(width: 36)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.sm)
            .padding(.bottom, AppTheme.Spacing.md)
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.Colors.brand.opacity(0.15))
                    .frame(height: 6)

                Capsule()
                    .fill(AppTheme.Colors.brand)
                    .frame(
                        width: geo.size.width * CGFloat(step + 1) / 5.0,
                        height: 6
                    )
                    .animation(AppTheme.Animation.standard, value: step)
            }
        }
        .frame(height: 6)
    }

    // MARK: - Step −1: Carousel

    private var carouselStep: some View {
        VStack(spacing: 0) {
            TabView(selection: $carouselPage) {
                ForEach(0..<OnboardingSlide.all.count, id: \.self) { index in
                    carouselSlide(OnboardingSlide.all[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .onAppear {
                UIPageControl.appearance().currentPageIndicatorTintColor =
                    UIColor(AppTheme.Colors.brand)
                UIPageControl.appearance().pageIndicatorTintColor =
                    UIColor(AppTheme.Colors.brand.opacity(0.25))
            }

            // "Passer" / "Commencer" buttons
            VStack(spacing: AppTheme.Spacing.sm) {
                BrandButton(title: carouselPage == 2 ? "Commencer" : "Suivant") {
                    withAnimation(AppTheme.Animation.standard) {
                        if carouselPage < 2 {
                            carouselPage += 1
                        } else {
                            step = authViewModel.isAuthenticated ? 1 : 0
                        }
                    }
                }

                if carouselPage < 2 {
                    Button("Passer") {
                        withAnimation(AppTheme.Animation.standard) {
                            step = authViewModel.isAuthenticated ? 1 : 0
                        }
                    }
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(AppTheme.Colors.muted)
                    .frame(height: 44)
                } else {
                    // Placeholder to keep layout stable
                    Color.clear.frame(height: 44)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }

    private func carouselSlide(_ slide: OnboardingSlide) -> some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.Colors.brand.opacity(0.10))
                    .frame(width: 120, height: 120)
                Image(systemName: slide.icon)
                    .font(.system(size: 52, weight: .medium))
                    .foregroundColor(AppTheme.Colors.brand)
            }

            VStack(spacing: AppTheme.Spacing.sm) {
                Text(slide.title)
                    .font(AppTheme.Typography.title1)
                    .foregroundColor(AppTheme.Colors.ink)
                    .multilineTextAlignment(.center)

                Text(slide.subtitle)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xl)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Step 0: Créer le compte

    private var accountStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                stepHeader(
                    eyebrow: "ÉTAPE 1 SUR 5",
                    title: "Créer le compte",
                    subtitle: "Rejoignez Manounou en quelques secondes."
                )

                // Apple Sign In
                SignInWithAppleButton(.signIn) { request in
                    let nonce = AppleSignIn.randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.email, .fullName]
                    request.nonce = AppleSignIn.sha256(nonce)
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        guard
                            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                            let idTokenData = credential.identityToken,
                            let idToken = String(data: idTokenData, encoding: .utf8),
                            let nonce = currentNonce
                        else { return }
                        Task {
                            isCreatingAccount = true
                            accountError = nil
                            await authViewModel.signInWithApple(idToken: idToken, nonce: nonce)
                            isCreatingAccount = false
                            if authViewModel.errorMessage == nil {
                                withAnimation(AppTheme.Animation.standard) { step = 1 }
                            } else {
                                accountError = authViewModel.errorMessage
                                authViewModel.clearError()
                            }
                        }
                    case .failure(let error):
                        accountError = error.localizedDescription
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.button))

                // OR divider
                HStack(spacing: AppTheme.Spacing.sm) {
                    Rectangle()
                        .fill(AppTheme.Colors.border)
                        .frame(height: 1)
                    Text("OU")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.muted)
                    Rectangle()
                        .fill(AppTheme.Colors.border)
                        .frame(height: 1)
                }

                // Email field
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    OnboardingTextField(
                        placeholder: "votre@email.com",
                        text: $email,
                        keyboardType: .emailAddress,
                        autocapitalization: .never,
                        isSecure: false,
                        focusedField: $focusedField,
                        fieldTag: .email
                    )
                }

                // Password field
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    SectionLabel("MOT DE PASSE (8+ CARACTÈRES)")
                    OnboardingTextField(
                        placeholder: "••••••••",
                        text: $password,
                        keyboardType: .default,
                        autocapitalization: .never,
                        isSecure: true,
                        focusedField: $focusedField,
                        fieldTag: .password
                    )
                    if !password.isEmpty && password.count < 8 {
                        Text("Le mot de passe doit contenir au moins 8 caractères.")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.red)
                    }
                }

                if let error = accountError {
                    Text(error)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.red)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: AppTheme.Spacing.xl)

                BrandButton(title: isCreatingAccount ? "Création…" : "Continuer",
                            disabled: !isAccountStepValid || isCreatingAccount) {
                    Task { await signUpAndContinue() }
                }
            }
            .padding(AppTheme.Spacing.md)
        }
    }

    private var isAccountStepValid: Bool {
        email.contains("@") && email.contains(".") && password.count >= 8
    }

    // MARK: - Step 1: Votre foyer

    private var foyerStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                stepHeader(
                    eyebrow: "ÉTAPE 2 SUR 5",
                    title: "Votre foyer",
                    subtitle: "Comment s'appelle votre famille ?"
                )

                OnboardingTextField(
                    placeholder: "Famille Dupont",
                    text: $foyerName,
                    keyboardType: .default,
                    autocapitalization: .words,
                    isSecure: false,
                    focusedField: $focusedField,
                    fieldTag: .foyerName
                )

                // Quick chips
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    SectionLabel("SUGGESTIONS RAPIDES")
                    HStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(["Famille Martin", "Famille Dubois", "Famille Bernard"], id: \.self) { name in
                            QuickChip(label: name) {
                                foyerName = name
                                focusedField = nil
                            }
                        }
                        Spacer()
                    }
                }

                Spacer(minLength: AppTheme.Spacing.xl)

                BrandButton(title: "Continuer", disabled: foyerName.trimmingCharacters(in: .whitespaces).isEmpty) {
                    withAnimation(AppTheme.Animation.standard) { step = 2 }
                }
            }
            .padding(AppTheme.Spacing.md)
        }
    }

    // MARK: - Step 2: Votre enfant

    private let ageOptions = ["0–1 an", "1–3 ans", "3–6 ans", "6+ ans"]
    private let allergyOptions = ["Arachides", "Lait", "Œufs", "Gluten", "Autres"]

    private var childStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                stepHeader(
                    eyebrow: "ÉTAPE 3 SUR 5",
                    title: "Votre enfant",
                    subtitle: "Dites-nous en plus sur votre enfant."
                )

                // First name
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    SectionLabel("PRÉNOM DE VOTRE ENFANT")
                    OnboardingTextField(
                        placeholder: "Emma",
                        text: $childFirstName,
                        keyboardType: .default,
                        autocapitalization: .words,
                        isSecure: false,
                        focusedField: $focusedField,
                        fieldTag: .childName
                    )
                }

                // Age single-select chips
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    SectionLabel("ÂGE")
                    FlowLayout(spacing: AppTheme.Spacing.sm) {
                        ForEach(ageOptions, id: \.self) { age in
                            SelectChip(
                                label: age,
                                isSelected: childAge == age
                            ) {
                                childAge = (childAge == age) ? "" : age
                            }
                        }
                    }
                }

                // Allergies multi-select chips
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    SectionLabel("ALLERGIES")
                    FlowLayout(spacing: AppTheme.Spacing.sm) {
                        ForEach(allergyOptions, id: \.self) { allergy in
                            SelectChip(
                                label: allergy,
                                isSelected: allergies.contains(allergy)
                            ) {
                                if allergies.contains(allergy) {
                                    allergies.remove(allergy)
                                } else {
                                    allergies.insert(allergy)
                                }
                            }
                        }
                    }
                }

                Spacer(minLength: AppTheme.Spacing.xl)

                BrandButton(
                    title: "Continuer",
                    disabled: childFirstName.trimmingCharacters(in: .whitespaces).isEmpty || childAge.isEmpty
                ) {
                    withAnimation(AppTheme.Animation.standard) { step = 3 }
                }
            }
            .padding(AppTheme.Spacing.md)
        }
    }

    // MARK: - Step 3: Votre nounou

    private var nannyStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                stepHeader(
                    eyebrow: "ÉTAPE 4 SUR 5",
                    title: "Votre nounou",
                    subtitle: "Invitez votre nounou ou baby-sitter."
                )

                // Invite email
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    SectionLabel("INVITER VOTRE NOUNOU")
                    OnboardingTextField(
                        placeholder: "nounou@email.com",
                        text: $nannyEmail,
                        keyboardType: .emailAddress,
                        autocapitalization: .never,
                        isSecure: false,
                        focusedField: $focusedField,
                        fieldTag: .nannyEmail
                    )
                }

                // Share link button
                Button {
                    // Share sheet — hook up to UIActivityViewController at integration time
                    let items: [Any] = ["Rejoins-moi sur Manounou : https://manounou.app/invite"]
                    let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let root = scene.windows.first?.rootViewController {
                        root.present(av, animated: true)
                    }
                } label: {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "link")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Ou partager le lien")
                            .font(AppTheme.Typography.bodyMedium)
                    }
                    .foregroundColor(AppTheme.Colors.brand)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppTheme.Colors.brand.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.button))
                }

                // Remuneration section
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    SectionLabel("RÉMUNÉRATION CONVENUE (AU CONTRAT)")

                    // Hourly rate
                    HStack(spacing: AppTheme.Spacing.sm) {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Taux horaire net")
                                .font(AppTheme.Typography.footnote)
                                .foregroundColor(AppTheme.Colors.muted)
                            RateField(value: $hourlyRate, suffix: "€/h", fieldTag: .hourlyRate, focusedField: $focusedField)
                        }
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Indemnité d'entretien")
                                .font(AppTheme.Typography.footnote)
                                .foregroundColor(AppTheme.Colors.muted)
                            RateField(value: $maintenanceRate, suffix: "€/j", fieldTag: .maintenanceRate, focusedField: $focusedField)
                        }
                    }
                }

                Spacer(minLength: AppTheme.Spacing.xl)

                // Plus tard / Continuer
                HStack(spacing: AppTheme.Spacing.sm) {
                    Button("Plus tard") {
                        withAnimation(AppTheme.Animation.standard) { step = 4 }
                    }
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.muted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppTheme.Colors.surfaceAlt)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.button))

                    BrandButton(title: "Continuer") {
                        withAnimation(AppTheme.Animation.standard) { step = 4 }
                    }
                }
            }
            .padding(AppTheme.Spacing.md)
        }
    }

    // MARK: - Step 4: Récapitulatif

    private var summaryStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                stepHeader(
                    eyebrow: "ÉTAPE 5 SUR 5",
                    title: "C'est prêt !",
                    subtitle: "Voici ce que nous avons configuré pour vous."
                )

                // Checklist card
                VStack(alignment: .leading, spacing: 0) {
                    ChecklistRow(
                        icon: "house.fill",
                        title: "Foyer",
                        detail: foyerName.isEmpty ? nil : foyerName,
                        isChecked: !foyerName.isEmpty
                    )
                    Divider().padding(.leading, 52)

                    ChecklistRow(
                        icon: "figure.child",
                        title: "Enfant",
                        detail: childFirstName.isEmpty ? nil : "\(childFirstName)\(childAge.isEmpty ? "" : ", \(childAge)")",
                        isChecked: !childFirstName.isEmpty
                    )
                    Divider().padding(.leading, 52)

                    ChecklistRow(
                        icon: "person.badge.plus",
                        title: "Nounou",
                        detail: nannyEmail.isEmpty ? "Invitation à envoyer" : nannyEmail,
                        isChecked: !nannyEmail.isEmpty
                    )
                }
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
                .shadow(color: AppTheme.Shadow.card.color,
                        radius: AppTheme.Shadow.card.radius,
                        x: AppTheme.Shadow.card.x,
                        y: AppTheme.Shadow.card.y)

                // Notifications toggle card
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Activer les notifications")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.Colors.ink)
                        Text("Rappels, confirmations et messages.")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.muted)
                    }
                    Spacer()
                    Toggle("", isOn: $notificationsEnabled)
                        .tint(AppTheme.Colors.brand)
                        .labelsHidden()
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
                .shadow(color: AppTheme.Shadow.card.color,
                        radius: AppTheme.Shadow.card.radius,
                        x: AppTheme.Shadow.card.x,
                        y: AppTheme.Shadow.card.y)

                Spacer(minLength: AppTheme.Spacing.xl)

                BrandButton(title: isCompletingOnboarding ? "Finalisation…" : "Entrer dans Manounou",
                            disabled: isCompletingOnboarding) {
                    Task { await finishOnboarding() }
                }
            }
            .padding(AppTheme.Spacing.md)
        }
    }

    // MARK: - Async actions

    private func signUpAndContinue() async {
        isCreatingAccount = true
        accountError = nil
        await authViewModel.signUp(email: email, password: password)
        isCreatingAccount = false
        if authViewModel.errorMessage == nil {
            withAnimation(AppTheme.Animation.standard) { step = 1 }
        } else {
            accountError = authViewModel.errorMessage
            authViewModel.clearError()
        }
    }

    private func finishOnboarding() async {
        isCompletingOnboarding = true
        if !childFirstName.trimmingCharacters(in: .whitespaces).isEmpty {
            let notes = allergies.isEmpty
                ? nil
                : "Allergies: \(allergies.sorted().joined(separator: ", "))"
            let child = Child(
                firstName: childFirstName,
                lastName: "",
                birthDate: birthDateFromAgeCategory(childAge),
                gender: .other,
                notes: notes
            )
            await appContainer.childrenViewModel.createChild(child)
        }
        if notificationsEnabled {
            appContainer.notificationManager.requestPermission()
        }
        isCompletingOnboarding = false
        onComplete()
    }

    private func birthDateFromAgeCategory(_ category: String) -> Date {
        let cal = Calendar.current
        switch category {
        case "0–1 an":  return cal.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        case "1–3 ans": return cal.date(byAdding: .year, value: -2, to: Date()) ?? Date()
        case "3–6 ans": return cal.date(byAdding: .year, value: -4, to: Date()) ?? Date()
        case "6+ ans":  return cal.date(byAdding: .year, value: -8, to: Date()) ?? Date()
        default:        return cal.date(byAdding: .year, value: -3, to: Date()) ?? Date()
        }
    }

    // MARK: - Shared helpers

    @ViewBuilder
    private func stepHeader(eyebrow: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(eyebrow)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.muted)
                .tracking(1.2)

            Text(title)
                .font(AppTheme.Typography.title1)
                .foregroundColor(AppTheme.Colors.ink)

            Text(subtitle)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.muted)
        }
        .padding(.bottom, AppTheme.Spacing.xs)
    }
}

// MARK: - Focus field enum

private enum OnboardingField: Hashable {
    case email, password
    case foyerName
    case childName
    case nannyEmail
    case hourlyRate, maintenanceRate
}

// MARK: - BrandButton

private struct BrandButton: View {
    let title: String
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(disabled ? AppTheme.Colors.brand.opacity(0.40) : AppTheme.Colors.brand)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.button))
                .shadow(
                    color: disabled ? .clear : AppTheme.Colors.brandShadow,
                    radius: 8, x: 0, y: 4
                )
        }
        .disabled(disabled)
        .animation(AppTheme.Animation.quick, value: disabled)
    }
}

// MARK: - SectionLabel

private struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(AppTheme.Typography.caption)
            .foregroundColor(AppTheme.Colors.muted)
            .tracking(1.0)
    }
}

// MARK: - OnboardingTextField

private struct OnboardingTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var isSecure: Bool = false
    @FocusState.Binding var focusedField: OnboardingField?
    let fieldTag: OnboardingField

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .focused($focusedField, equals: fieldTag)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled(true)
                    .focused($focusedField, equals: fieldTag)
            }
        }
        .font(AppTheme.Typography.body)
        .foregroundColor(AppTheme.Colors.ink)
        .padding(.horizontal, AppTheme.Spacing.md)
        .frame(height: 52)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.button))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.button)
                .stroke(
                    focusedField == fieldTag ? AppTheme.Colors.brand : Color.black.opacity(0.10),
                    lineWidth: focusedField == fieldTag ? 1.5 : 1
                )
        )
        .animation(AppTheme.Animation.quick, value: focusedField == fieldTag)
    }
}

// MARK: - RateField

private struct RateField: View {
    @Binding var value: String
    let suffix: String
    let fieldTag: OnboardingField
    @FocusState.Binding var focusedField: OnboardingField?

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            TextField("0.00", text: $value)
                .keyboardType(.decimalPad)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.Colors.ink)
                .multilineTextAlignment(.center)
                .focused($focusedField, equals: fieldTag)

            Text(suffix)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.muted)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.button))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.button)
                .stroke(
                    focusedField == fieldTag ? AppTheme.Colors.brand : Color.black.opacity(0.10),
                    lineWidth: focusedField == fieldTag ? 1.5 : 1
                )
        )
        .animation(AppTheme.Animation.quick, value: focusedField == fieldTag)
    }
}

// MARK: - SelectChip

private struct SelectChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(AppTheme.Typography.footnote)
                .foregroundColor(isSelected ? .white : AppTheme.Colors.ink)
                .padding(.horizontal, AppTheme.Spacing.md)
                .frame(height: 34)
                .background(isSelected ? AppTheme.Colors.brand : AppTheme.Colors.surfaceAlt)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? AppTheme.Colors.brand : Color.black.opacity(0.10),
                            lineWidth: 1
                        )
                )
        }
        .animation(AppTheme.Animation.quick, value: isSelected)
    }
}

// MARK: - QuickChip

private struct QuickChip: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(AppTheme.Typography.footnote)
                .foregroundColor(AppTheme.Colors.brand)
                .padding(.horizontal, AppTheme.Spacing.md)
                .frame(height: 34)
                .background(AppTheme.Colors.brandLight)
                .clipShape(Capsule())
        }
    }
}

// MARK: - ChecklistRow

private struct ChecklistRow: View {
    let icon: String
    let title: String
    let detail: String?
    let isChecked: Bool

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(isChecked ? AppTheme.Colors.green.opacity(0.12) : AppTheme.Colors.surfaceAlt)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isChecked ? AppTheme.Colors.green : AppTheme.Colors.muted)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.ink)
                if let detail {
                    Text(detail)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.muted)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20))
                .foregroundColor(isChecked ? AppTheme.Colors.green : AppTheme.Colors.muted.opacity(0.40))
        }
        .padding(AppTheme.Spacing.md)
    }
}

// MARK: - FlowLayout

/// A simple left-aligned wrapping layout for chips.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let width = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width && currentX > 0 {
                currentY += lineHeight + spacing
                currentX = 0
                lineHeight = 0
            }
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxWidth = max(maxWidth, currentX)
        }
        currentY += lineHeight
        return CGSize(width: maxWidth, height: currentY)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentY += lineHeight + spacing
                currentX = bounds.minX
                lineHeight = 0
            }
            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: ProposedViewSize(size)
            )
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
    }
}

// MARK: - Carousel data

private struct OnboardingSlide {
    let icon: String
    let title: String
    let subtitle: String

    static let all: [OnboardingSlide] = [
        OnboardingSlide(
            icon: "calendar",
            title: "Planifiez la garde",
            subtitle: "Horaires fixes ou décalés, tout s'adapte."
        ),
        OnboardingSlide(
            icon: "shield.fill",
            title: "Gérez les allergies",
            subtitle: "Toutes les infos santé en un endroit sûr."
        ),
        OnboardingSlide(
            icon: "bubble.left.and.bubble.right.fill",
            title: "Gardez le contact",
            subtitle: "Messages, confirmations, photos en direct."
        )
    ]
}

// MARK: - Preview

#if DEBUG
#Preview("Onboarding – Carousel") {
    let container = AppContainer.createForTesting()
    return OnboardingView(onComplete: {})
        .environmentObject(container)
        .environmentObject(container.authViewModel)
}

#Preview("Onboarding – Step 0") {
    let container = AppContainer.createForTesting()
    return OnboardingView(onComplete: {})
        .environmentObject(container)
        .environmentObject(container.authViewModel)
}
#endif
