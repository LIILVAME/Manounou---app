// OverlaysView.swift — Manounou
// Trois overlays du handoff « Focus Overlays » qui se posent au-dessus des
// 4 onglets, ouverts depuis Profil / Réglages :
//   • #4 Avenant de tarif        → RateProposalView    (la nounou propose, le parent valide)
//   • #5 Écran verrouillé        → LockScreenPreviewView (aperçu d'une push iOS)
//   • #6 Réglages de notifications → NotificationSettingsView
// (#1 Notifications, #2 Messagerie, #3 Déclaration vivent déjà ailleurs.)

import SwiftUI

// =====================================================================
// MARK: - #4 Avenant de tarif (RateProposalView)
// =====================================================================

/// Une modification de tarif proposée par la nounou, soumise à l'accord du parent.
struct RateChange: Identifiable {
    let id = UUID()
    let label: String
    let oldValue: String
    let newValue: String
    let unit: String
}

/// Overlay « Proposition de tarif » : le parent voit *ce qui change* (ancien → nouveau)
/// et accepte ou refuse. Rien ne s'applique avant son accord (réalité d'un avenant).
struct RateProposalView: View {
    @Environment(\.dismiss) private var dismiss

    /// Prénom de la nounou à l'origine de la proposition.
    var nounouFirstName: String = "Fatou"
    /// Lignes modifiées par l'avenant.
    var changes: [RateChange] = [
        RateChange(label: "Taux horaire net",     oldValue: "4,50", newValue: "5,00", unit: "€/h"),
        RateChange(label: "Indemnité d'entretien", oldValue: "3,50", newValue: "4,00", unit: "€/j")
    ]
    var onAccept: () -> Void = {}
    var onRefuse: () -> Void = {}

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    proposerCard

                    Text("CE QUI CHANGE")
                        .font(.system(size: 10.5, weight: .heavy, design: .rounded))
                        .foregroundColor(AppTheme.Colors.muted)
                        .tracking(1)
                        .padding(.leading, 2)

                    changesCard

                    Button {
                        onAccept(); dismiss()
                    } label: {
                        Text("Accepter le nouveau tarif")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.Colors.brand))
                            .shadow(color: AppTheme.Colors.brandShadow, radius: 12, x: 0, y: 6)
                    }
                    .padding(.top, 6)

                    Button {
                        onRefuse(); dismiss()
                    } label: {
                        Text("Refuser")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(AppTheme.Colors.mutedHeavy)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(AppTheme.Colors.surface)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.Colors.border, lineWidth: 1.7))
                            )
                    }
                }
                .padding(AppTheme.Spacing.md)
            }
            .background(AppTheme.Colors.paper.ignoresSafeArea())
            .navigationTitle("Proposition de tarif")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") { dismiss() }.foregroundColor(AppTheme.Colors.brand)
                }
            }
        }
    }

    private var proposerCard: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AppTheme.Colors.brand)
                .frame(width: 46, height: 46)
                .overlay(
                    Text(String(nounouFirstName.prefix(1)).uppercased())
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text("\(nounouFirstName) propose un avenant")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(AppTheme.Colors.ink)
                Text("À votre validation")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.muted)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
        .shadow(color: AppTheme.Shadow.card.color, radius: AppTheme.Shadow.card.radius, x: 0, y: 3)
    }

    private var changesCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(changes.enumerated()), id: \.element.id) { index, change in
                changeRow(change)
                if index < changes.count - 1 {
                    Divider().background(AppTheme.Colors.divider)
                }
            }
        }
        .padding(.horizontal, 14)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
        .shadow(color: AppTheme.Shadow.card.color, radius: AppTheme.Shadow.card.radius, x: 0, y: 3)
    }

    private func changeRow(_ change: RateChange) -> some View {
        HStack {
            Text(change.label)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.Colors.ink)
            Spacer()
            HStack(spacing: 8) {
                Text(change.oldValue)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.muted)
                    .strikethrough()
                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.Colors.muted)
                Text(change.newValue)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.brand)
                Text(change.unit)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.muted)
            }
        }
        .padding(.vertical, 13)
    }
}

// =====================================================================
// MARK: - #6 Réglages de notifications (NotificationSettingsView)
// =====================================================================

/// Réglages des notifications, rangés en trois familles (Rappels / Activité /
/// Organisation). Tout est activé par défaut ; le délai n'apparaît qu'une fois
/// « Dépôt & récupération » actif. Porte d'entrée vers l'aperçu écran verrouillé.
struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var pickupReminder   = true
    @State private var leadMinutes      = 30
    @State private var confirmations    = true
    @State private var nounouMessages   = true
    @State private var planningChanges  = true
    @State private var babysitter       = false
    @State private var documents        = true
    @State private var lateAlerts       = true
    @State private var showingLockScreen = false

    private let leadOptions = [15, 30, 45]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {

                    // ── Rappels ──
                    sectionLabel("Rappels")
                    card {
                        toggleRow(icon: "clock.fill", color: AppTheme.Colors.brand,
                                  title: "Dépôt & récupération", subtitle: "Avant chaque garde",
                                  isOn: $pickupReminder)
                    }
                    if pickupReminder { leadTimeRow }

                    // ── Activité ──
                    sectionLabel("Activité")
                    card {
                        toggleRow(icon: "checkmark", color: AppTheme.Colors.green,
                                  title: "Confirmations", subtitle: "« Déposé » / « Récupéré »",
                                  isOn: $confirmations)
                        Divider().padding(.leading, 60).background(AppTheme.Colors.divider)
                        toggleRow(icon: "bubble.left.fill", color: AppTheme.Colors.blue,
                                  title: "Messages de la nounou", subtitle: nil,
                                  isOn: $nounouMessages)
                    }

                    // ── Organisation ──
                    sectionLabel("Organisation")
                    card {
                        toggleRow(icon: "calendar", color: AppTheme.Colors.purple,
                                  title: "Changements de planning", subtitle: nil,
                                  isOn: $planningChanges)
                        Divider().padding(.leading, 60).background(AppTheme.Colors.divider)
                        toggleRow(icon: "person.fill", color: AppTheme.Colors.orange,
                                  title: "Baby-sitter ponctuel", subtitle: nil,
                                  isOn: $babysitter)
                        Divider().padding(.leading, 60).background(AppTheme.Colors.divider)
                        toggleRow(icon: "doc.fill", color: AppTheme.Colors.amber,
                                  title: "Documents", subtitle: nil,
                                  isOn: $documents)
                        Divider().padding(.leading, 60).background(AppTheme.Colors.divider)
                        toggleRow(icon: "exclamationmark.triangle.fill", color: AppTheme.Colors.red,
                                  title: "Retards signalés", subtitle: nil,
                                  isOn: $lateAlerts)
                    }

                    // ── Aperçu écran verrouillé (→ #5) ──
                    Button { showingLockScreen = true } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "iphone")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Aperçu sur l'écran verrouillé")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(AppTheme.Colors.ink)
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background(
                            RoundedRectangle(cornerRadius: 13)
                                .fill(AppTheme.Colors.surface)
                                .overlay(RoundedRectangle(cornerRadius: 13).stroke(AppTheme.Colors.border, lineWidth: 1.7))
                        )
                    }
                    .padding(.top, 4)
                }
                .padding(AppTheme.Spacing.md)
            }
            .background(AppTheme.Colors.paper.ignoresSafeArea())
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") { dismiss() }.foregroundColor(AppTheme.Colors.brand)
                }
            }
            .fullScreenCover(isPresented: $showingLockScreen) {
                LockScreenPreviewView()
            }
        }
    }

    // MARK: Pièces

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10.5, weight: .heavy, design: .rounded))
            .foregroundColor(AppTheme.Colors.muted)
            .tracking(1)
            .padding(.leading, 2)
            .padding(.top, 4)
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) { content() }
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
            .shadow(color: AppTheme.Shadow.card.color, radius: AppTheme.Shadow.card.radius, x: 0, y: 3)
    }

    private func toggleRow(icon: String, color: Color, title: String,
                           subtitle: String?, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(RoundedRectangle(cornerRadius: 10).fill(color))
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.Colors.muted)
                }
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppTheme.Colors.brand)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
    }

    private var leadTimeRow: some View {
        HStack(spacing: 11) {
            Image(systemName: "clock")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.ink)
            Text("Me prévenir")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.Colors.ink)
            Spacer()
            HStack(spacing: 6) {
                ForEach(leadOptions, id: \.self) { minutes in
                    let selected = minutes == leadMinutes
                    Button { leadMinutes = minutes } label: {
                        Text("\(minutes) min")
                            .font(.system(size: 12.5, weight: .heavy, design: .rounded))
                            .foregroundColor(selected ? .white : AppTheme.Colors.ink)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 9)
                                    .fill(selected ? AppTheme.Colors.brand : AppTheme.Colors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 9)
                                            .stroke(selected ? Color.clear : AppTheme.Colors.border, lineWidth: 1.5)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
        .shadow(color: AppTheme.Shadow.card.color, radius: AppTheme.Shadow.card.radius, x: 0, y: 3)
    }
}

// =====================================================================
// MARK: - #5 Écran verrouillé (LockScreenPreviewView)
// =====================================================================

private struct LockPush: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let app: String
    let title: String
    let body: String
}

/// Aperçu d'une push Manounou sur l'écran verrouillé iOS : fond sombre glassmorphe,
/// fidèle au système. Pas un vrai écran d'app — un argument de réassurance.
struct LockScreenPreviewView: View {
    @Environment(\.dismiss) private var dismiss

    private let pushes: [LockPush] = [
        LockPush(icon: "clock.fill", color: AppTheme.Colors.brand,
                 app: "Manounou · maintenant",
                 title: "Récupération dans 30 min", body: "Awa · 17h00 par Maman"),
        LockPush(icon: "bubble.left.fill", color: AppTheme.Colors.blue,
                 app: "Manounou · 9 min",
                 title: "Fatou", body: "Awa a bien dormi, belle journée 😊"),
        LockPush(icon: "doc.fill", color: AppTheme.Colors.amber,
                 app: "Manounou · 9h00",
                 title: "Document à signer", body: "Autorisation de sortie au parc")
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "3A1020"), Color(hex: "6A1F3A"), Color(hex: "20141C")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill").font(.system(size: 12))
                    Text("Vendredi 30 mai")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.85))
                .padding(.top, 12)

                Text("9:41")
                    .font(.system(size: 62, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 2)

                VStack(spacing: 8) {
                    ForEach(pushes) { push in pushCard(push) }
                }
                .padding(.top, 34)
                .padding(.horizontal, 16)

                Spacer()

                Button { dismiss() } label: {
                    Text("Fermer l'aperçu")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 11)
                        .background(Capsule().fill(.white.opacity(0.18)))
                        .overlay(Capsule().stroke(.white.opacity(0.25), lineWidth: 0.5))
                }
                .padding(.bottom, 28)
            }
        }
    }

    private func pushCard(_ push: LockPush) -> some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 11)
                .fill(push.color)
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: push.icon).font(.system(size: 16, weight: .bold)).foregroundColor(.white))
            VStack(alignment: .leading, spacing: 1) {
                Text(push.app.uppercased())
                    .font(.system(size: 9.5, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(0.4)
                Text(push.title)
                    .font(.system(size: 13.5, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text(push.body)
                    .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.18), lineWidth: 0.5))
    }
}

// MARK: - Previews

#Preview("Avenant") { RateProposalView() }
#Preview("Réglages notif") { NotificationSettingsView() }
#Preview("Écran verrouillé") { LockScreenPreviewView() }
