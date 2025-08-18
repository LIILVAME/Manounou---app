//
//  ProfileView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingEditProfile = false
    @State private var showingChangePassword = false
    @State private var showingSignOutConfirmation = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.03) {
                        // Profile Header
                        profileHeader(geometry: geometry)
                        
                        // Profile Information
                        profileInformation(geometry: geometry)
                        
                        // Account Settings
                        accountSettings(geometry: geometry)
                        
                        // Plan Information
                        planInformation(geometry: geometry)
                        
                        // Action Buttons
                        actionButtons(geometry: geometry)
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.top, geometry.size.height * 0.02)
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingEditProfile) {
            editProfileSheet()
        }
        .sheet(isPresented: $showingChangePassword) {
            changePasswordSheet()
        }
        .alert("Déconnexion", isPresented: $showingSignOutConfirmation) {
            Button("Déconnexion", role: .destructive) {
                Task {
                    await authManager.signOut()
                }
            }
            Button("Annuler", role: .cancel) { }
        } message: {
            Text("Êtes-vous sûr de vouloir vous déconnecter ?")
        }
    }
    
    // MARK: - Profile Header
    private func profileHeader(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * 0.25,
                        height: geometry.size.width * 0.25
                    )
                
                if let avatarUrl = authManager.userProfile?.avatarUrl {
                    // TODO: Load image from URL
                    AsyncImage(url: URL(string: avatarUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Text(initials)
                            .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .frame(
                        width: geometry.size.width * 0.25,
                        height: geometry.size.width * 0.25
                    )
                    .clipShape(Circle())
                } else {
                    Text(initials)
                        .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                        .foregroundColor(.blue)
                }
                
                // Edit button overlay
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingEditProfile = true }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: geometry.size.width * 0.06))
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                }
                .frame(
                    width: geometry.size.width * 0.25,
                    height: geometry.size.width * 0.25
                )
            }
            
            // Name and email
            VStack(spacing: geometry.size.height * 0.005) {
                Text(displayName)
                    .font(.system(size: geometry.size.width * 0.06, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(authManager.currentUser?.email ?? "")
                    .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                    .foregroundColor(.secondary)
                
                // Role badge
                HStack(spacing: geometry.size.width * 0.02) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Text("Parent")
                        .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, geometry.size.width * 0.03)
                .padding(.vertical, geometry.size.height * 0.008)
                .background(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                        .fill(Color.blue.opacity(0.1))
                )
            }
        }
    }
    
    // MARK: - Profile Information
    private func profileInformation(geometry: GeometryProxy) -> some View {
        informationCard(
            title: "Informations personnelles",
            icon: "person.circle",
            iconColor: .blue,
            geometry: geometry
        ) {
            VStack(spacing: geometry.size.height * 0.015) {
                informationRow(
                    label: "Prénom",
                    value: authManager.userProfile?.firstName ?? "Non renseigné",
                    geometry: geometry
                )
                
                informationRow(
                    label: "Nom",
                    value: authManager.userProfile?.lastName ?? "Non renseigné",
                    geometry: geometry
                )
                
                informationRow(
                    label: "Email",
                    value: authManager.currentUser?.email ?? "Non renseigné",
                    geometry: geometry
                )
                
                informationRow(
                    label: "Téléphone",
                    value: "Non renseigné", // TODO: Add phone to UserProfile
                    geometry: geometry
                )
                
                informationRow(
                    label: "Membre depuis",
                    value: memberSinceText,
                    geometry: geometry
                )
            }
        }
    }
    
    // MARK: - Account Settings
    private func accountSettings(geometry: GeometryProxy) -> some View {
        informationCard(
            title: "Paramètres du compte",
            icon: "gearshape.circle",
            iconColor: .gray,
            geometry: geometry
        ) {
            VStack(spacing: geometry.size.height * 0.015) {
                settingRow(
                    icon: "pencil.circle",
                    title: "Modifier le profil",
                    subtitle: "Nom, prénom, téléphone",
                    iconColor: .blue,
                    geometry: geometry
                ) {
                    showingEditProfile = true
                }
                
                settingRow(
                    icon: "lock.circle",
                    title: "Changer le mot de passe",
                    subtitle: "Sécurité du compte",
                    iconColor: .orange,
                    geometry: geometry
                ) {
                    showingChangePassword = true
                }
                
                settingRow(
                    icon: "globe.circle",
                    title: "Langue",
                    subtitle: "Français",
                    iconColor: .green,
                    geometry: geometry
                ) {
                    // TODO: Language selection
                }
            }
        }
    }
    
    // MARK: - Plan Information
    private func planInformation(geometry: GeometryProxy) -> some View {
        informationCard(
            title: "Abonnement",
            icon: "crown.circle",
            iconColor: .purple,
            geometry: geometry
        ) {
            VStack(spacing: geometry.size.height * 0.015) {
                HStack {
                    VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                        Text("Plan Gratuit")
                            .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("0€/mois")
                            .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("Actif")
                        .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, geometry.size.width * 0.03)
                        .padding(.vertical, geometry.size.height * 0.008)
                        .background(
                            RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                                .fill(Color.green)
                        )
                }
                
                Divider()
                
                VStack(spacing: geometry.size.height * 0.01) {
                    limitRow(
                        title: "Enfants",
                        current: 0, // TODO: Get from children count
                        maximum: 2,
                        geometry: geometry
                    )
                    
                    limitRow(
                        title: "Documents",
                        current: 0, // TODO: Get from documents count
                        maximum: 10,
                        geometry: geometry
                    )
                }
                
                Button(action: {
                    // TODO: Upgrade plan
                }) {
                    Text("Améliorer le plan")
                        .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: geometry.size.height * 0.05)
                        .background(
                            LinearGradient(
                                colors: [Color.purple, Color.purple.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(geometry.size.width * 0.03)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Action Buttons
    private func actionButtons(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            // Sign out button
            Button(action: { showingSignOutConfirmation = true }) {
                HStack(spacing: geometry.size.width * 0.03) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: geometry.size.width * 0.045, weight: .medium))
                        .foregroundColor(.red)
                    
                    Text("Se déconnecter")
                        .font(.system(size: geometry.size.width * 0.045, weight: .medium))
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height * 0.06)
                .background(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                        .fill(Color.red.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // App version
            Text("Version 1.0.0")
                .font(.system(size: geometry.size.width * 0.03, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(.top, geometry.size.height * 0.02)
    }
    
    // MARK: - Helper Components
    private func informationCard<Content: View>(
        title: String,
        icon: String,
        iconColor: Color,
        geometry: GeometryProxy,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            HStack(spacing: geometry.size.width * 0.03) {
                Image(systemName: icon)
                    .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            content()
        }
        .padding(geometry.size.width * 0.04)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                .fill(Color(.systemGray6))
        )
    }
    
    private func informationRow(
        label: String,
        value: String,
        geometry: GeometryProxy
    ) -> some View {
        HStack {
            Text(label)
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
    
    private func settingRow(
        icon: String,
        title: String,
        subtitle: String,
        iconColor: Color,
        geometry: GeometryProxy,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: geometry.size.width * 0.03) {
                Image(systemName: icon)
                    .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: geometry.size.width * 0.08)
                
                VStack(alignment: .leading, spacing: geometry.size.height * 0.003) {
                    Text(title)
                        .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: geometry.size.width * 0.035, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func limitRow(
        title: String,
        current: Int,
        maximum: Int,
        geometry: GeometryProxy
    ) -> some View {
        HStack {
            Text(title)
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(current)/\(maximum)")
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Computed Properties
    private var initials: String {
        let firstName = authManager.userProfile?.firstName ?? ""
        let lastName = authManager.userProfile?.lastName ?? ""
        let firstInitial = firstName.first?.uppercased() ?? "U"
        let lastInitial = lastName.first?.uppercased() ?? "S"
        return "\(firstInitial)\(lastInitial)"
    }
    
    private var displayName: String {
        let firstName = authManager.userProfile?.firstName ?? ""
        let lastName = authManager.userProfile?.lastName ?? ""
        
        if firstName.isEmpty && lastName.isEmpty {
            return "Utilisateur"
        }
        
        return "\(firstName) \(lastName)"
    }
    
    private var memberSinceText: String {
        guard let createdAt = authManager.userProfile?.createdAt else {
            return "Récemment"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: createdAt)
    }
    
    // MARK: - Integrated Edit Profile Sheet
    
    private func editProfileSheet() -> some View {
        EditProfileIntegratedView(authManager: authManager)
    }
    
    // MARK: - Integrated Change Password Sheet
    
    private func changePasswordSheet() -> some View {
        ChangePasswordIntegratedView(authManager: authManager)
    }
}

// MARK: - Integrated Edit Profile View

struct EditProfileIntegratedView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authManager: AuthManager
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var isLoading = false
    
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidEmail(email)
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.03) {
                        profilePhotoSection(geometry: geometry)
                        formFields(geometry: geometry)
                        saveButton(geometry: geometry)
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.top, geometry.size.height * 0.02)
                }
            }
            .navigationTitle("Modifier le profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
        .disabled(isLoading)
        .onAppear { loadCurrentData() }
    }
    
    private func profilePhotoSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: geometry.size.width * 0.25, height: geometry.size.width * 0.25)
                
                Text(initials)
                    .font(.system(size: geometry.size.width * 0.08, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            Button("Changer la photo") {
                // Photo picker logic
            }
            .font(.system(size: geometry.size.width * 0.035, weight: .medium))
            .foregroundColor(.blue)
        }
    }
    
    private func formFields(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.025) {
            formField(title: "Prénom", text: $firstName, placeholder: "Votre prénom", keyboardType: .default, geometry: geometry)
            formField(title: "Nom", text: $lastName, placeholder: "Votre nom", keyboardType: .default, geometry: geometry)
            formField(title: "Email", text: $email, placeholder: "votre@email.com", keyboardType: .emailAddress, geometry: geometry)
            formField(title: "Téléphone", text: $phoneNumber, placeholder: "Optionnel", keyboardType: .phonePad, geometry: geometry)
        }
    }
    
    private func formField(title: String, text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType, geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.008) {
            Text(title)
                .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                .foregroundColor(.primary)
            
            TextField(placeholder, text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardType)
        }
    }
    
    private func saveButton(geometry: GeometryProxy) -> some View {
        Button(action: saveProfile) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                }
                Text(isLoading ? "Enregistrement..." : "Enregistrer")
                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height * 0.06)
            .background(isFormValid ? Color.blue : Color.gray)
            .cornerRadius(geometry.size.width * 0.03)
        }
        .disabled(!isFormValid || isLoading)
    }
    
    private func loadCurrentData() {
        firstName = authManager.userProfile?.firstName ?? ""
        lastName = authManager.userProfile?.lastName ?? ""
        email = authManager.currentUser?.email ?? ""
    }
    
    private func saveProfile() {
        Task {
            isLoading = true
            // Save logic here
            await Task.sleep(nanoseconds: 1_000_000_000)
            isLoading = false
            dismiss()
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? "U"
        let lastInitial = lastName.first?.uppercased() ?? "S"
        return "\(firstInitial)\(lastInitial)"
    }
}

// MARK: - Integrated Change Password View

struct ChangePasswordIntegratedView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authManager: AuthManager
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var showSuccessAlert = false
    
    private var isFormValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmPassword &&
        newPassword != currentPassword
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.03) {
                        headerIllustration(geometry: geometry)
                        securityNotice(geometry: geometry)
                        formFields(geometry: geometry)
                        if !newPassword.isEmpty {
                            passwordStrengthIndicator(geometry: geometry)
                        }
                        changePasswordButton(geometry: geometry)
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.top, geometry.size.height * 0.02)
                }
            }
            .navigationTitle("Changer le mot de passe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
        .disabled(isLoading)
        .alert("Mot de passe modifié", isPresented: $showSuccessAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Votre mot de passe a été modifié avec succès.")
        }
    }
    
    private func headerIllustration(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                
                Image(systemName: "lock.shield")
                    .font(.system(size: geometry.size.width * 0.08, weight: .medium))
                    .foregroundColor(.green)
            }
        }
    }
    
    private func securityNotice(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
            Text("Sécurité renforcée")
                .font(.system(size: geometry.size.width * 0.05, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: geometry.size.height * 0.008) {
                securityTip("• Utilisez au moins 6 caractères", geometry: geometry)
                securityTip("• Mélangez lettres, chiffres et symboles", geometry: geometry)
                securityTip("• Évitez les mots de passe évidents", geometry: geometry)
            }
        }
        .padding(geometry.size.width * 0.04)
        .background(Color(.systemGray6))
        .cornerRadius(geometry.size.width * 0.03)
    }
    
    private func securityTip(_ text: String, geometry: GeometryProxy) -> some View {
        Text(text)
            .font(.system(size: geometry.size.width * 0.035, weight: .regular))
            .foregroundColor(.secondary)
    }
    
    private func formFields(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.025) {
            passwordField(title: "Mot de passe actuel", text: $currentPassword, placeholder: "Entrez votre mot de passe actuel", isSecure: !showCurrentPassword, showPassword: $showCurrentPassword, geometry: geometry)
            passwordField(title: "Nouveau mot de passe", text: $newPassword, placeholder: "Entrez votre nouveau mot de passe", isSecure: !showNewPassword, showPassword: $showNewPassword, geometry: geometry)
            passwordField(title: "Confirmer le mot de passe", text: $confirmPassword, placeholder: "Confirmez votre nouveau mot de passe", isSecure: !showConfirmPassword, showPassword: $showConfirmPassword, geometry: geometry)
        }
    }
    
    private func passwordField(title: String, text: Binding<String>, placeholder: String, isSecure: Bool, showPassword: Binding<Bool>, geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.008) {
            Text(title)
                .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                }
                
                Button(action: { showPassword.wrappedValue.toggle() }) {
                    Image(systemName: isSecure ? "eye" : "eye.slash")
                        .foregroundColor(.secondary)
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private func passwordStrengthIndicator(geometry: GeometryProxy) -> some View {
        let strength = evaluatePasswordStrength(newPassword)
        
        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
            Text("Force du mot de passe: \(strength.description)")
                .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                .foregroundColor(strength.color)
            
            HStack(spacing: 4) {
                ForEach(1...4, id: \.self) { level in
                    Rectangle()
                        .fill(level <= strength.level ? strength.color : Color(.systemGray5))
                        .frame(height: 4)
                }
            }
        }
    }
    
    private func changePasswordButton(geometry: GeometryProxy) -> some View {
        Button(action: changePassword) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                }
                Text(isLoading ? "Modification..." : "Changer le mot de passe")
                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height * 0.06)
            .background(isFormValid ? Color.blue : Color.gray)
            .cornerRadius(geometry.size.width * 0.03)
        }
        .disabled(!isFormValid || isLoading)
    }
    
    private func changePassword() {
        Task {
            isLoading = true
            // Change password logic here
            await Task.sleep(nanoseconds: 2_000_000_000)
            isLoading = false
            showSuccessAlert = true
        }
    }
    
    private func evaluatePasswordStrength(_ password: String) -> PasswordStrength {
        var score = 0
        
        if password.count >= 6 { score += 1 }
        if password.count >= 8 { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*")) != nil { score += 1 }
        
        switch score {
        case 0...1: return .weak
        case 2...3: return .medium
        case 4: return .strong
        default: return .veryStrong
        }
    }
}

enum PasswordStrength {
    case weak, medium, strong, veryStrong
    
    var description: String {
        switch self {
        case .weak: return "Faible"
        case .medium: return "Moyen"
        case .strong: return "Fort"
        case .veryStrong: return "Très fort"
        }
    }
    
    var color: Color {
        switch self {
        case .weak: return .red
        case .medium: return .orange
        case .strong: return .green
        case .veryStrong: return .blue
        }
    }
    
    var level: Int {
        switch self {
        case .weak: return 1
        case .medium: return 2
        case .strong: return 3
        case .veryStrong: return 4
        }
    }
}

// MARK: - Preview
#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthManager())
    }
}
#endif