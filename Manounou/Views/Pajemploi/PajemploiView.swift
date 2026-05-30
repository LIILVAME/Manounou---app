//
//  PajemploiView.swift
//  Manounou
//
//  Écran « Déclarer sur Pajemploi » — killer feature de Manounou.
//  Recréé d'après le design handoff « Focus Pajemploi » :
//   • Brique 1 — Déclaration assistée (FAISABLE AUJOURD'HUI) : les 4 valeurs
//     pré-calculées, copiables champ par champ, deep link vers pajemploi.urssaf.fr,
//     puis « J'ai terminé » qui marque le mois déclaré.
//   • Brique 2 — Avance immédiate du crédit d'impôt (pédagogie + orientation) :
//     net à payer + reste à charge réel après les 50 %, lien d'activation URSSAF.
//
//  Brique 3 (« Connexion de compte Pajemploi ») est volontairement hors scope :
//  le design la marque « VISION · partenariat requis » et précise qu'on ne l'expose
//  pas en prod tant qu'aucun accord URSSAF n'existe.
//
//  Aucune API ne permet de déclarer à la place du parent : Manounou pré-remplit,
//  guide le copier-coller et oriente vers le dispositif officiel.
//

import SwiftUI
import UIKit

struct PajemploiView: View {
    let declaration: PajemploiDeclaration

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var copiedFields: Set<CopyField> = []
    @State private var isDeclared = false

    // Site officiel : « Ouvrir Pajemploi » comme « Activer l'avance immédiate »
    // renvoient vers l'espace URSSAF où le parent agit lui-même.
    private let pajemploiURL = URL(string: "https://www.pajemploi.urssaf.fr")

    private enum CopyField: Hashable { case hours, salary, upkeep, net }

    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.Colors.paper
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    overlayBar
                    heroCard
                    taxCreditCard
                    assistedSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 36)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Overlay Bar (retour · titre mois)

    private var overlayBar: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.Colors.ink)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(AppTheme.Colors.surface))
                    .overlay(Circle().stroke(AppTheme.Colors.border, lineWidth: 1.6))
            }
            .buttonStyle(.plain)

            Text("Déclaration · \(declaration.monthTitle)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.Colors.ink)

            Spacer()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Hero (net à payer)

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("NET À PAYER À \(declaration.nounouFirstName.uppercased())")
                .font(.system(size: 10.5, weight: .heavy, design: .rounded))
                .tracking(1)
                .foregroundColor(.white.opacity(0.9))

            Text(declaration.formattedNetToPay)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            HStack(spacing: 22) {
                heroStat(label: "Heures", value: declaration.formattedHours)
                heroStat(label: "Jours", value: declaration.formattedDays)
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(17)
        .background(AppTheme.Colors.brand)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: AppTheme.Colors.brand.opacity(0.35), radius: 14, x: 0, y: 10)
    }

    private func heroStat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.system(size: 10.5, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }

    // MARK: - Avance immédiate (crédit d'impôt)

    private var taxCreditCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 9) {
                Image(systemName: "eurosign.circle.fill")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(RoundedRectangle(cornerRadius: 10).fill(AppTheme.Colors.green))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Avance immédiate")
                        .font(.system(size: 13.5, weight: .heavy, design: .rounded))
                        .foregroundColor(AppTheme.Colors.ink)
                    Text("Crédit d'impôt · Pajemploi+")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.Colors.green)
                }
                Spacer(minLength: 0)
            }
            .padding(.bottom, 9)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(declaration.formattedTaxCredit)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.green)
                Text("déduits tout de suite")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.muted)
            }

            Text("Avec l'avance immédiate, l'URSSAF prend en charge 50 % : vous ne réglez que \(declaration.formattedRemainingCost) au lieu de \(declaration.formattedNetToPay). Estimation selon votre situation — Manounou n'est pas un conseil fiscal.")
                .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.Colors.muted)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)

            Button(action: openPajemploi) {
                Text("Activer l'avance immédiate")
                    .font(.system(size: 15.5, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppTheme.Colors.green)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
        }
        .padding(14)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.Colors.green.opacity(0.35), lineWidth: 1.6)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }

    // MARK: - Déclaration assistée (copier-coller guidé)

    private var assistedSection: some View {
        VStack(spacing: 8) {
            sectionLabel("Déclaration assistée")

            Text("Recopiez ces 4 valeurs sur pajemploi.urssaf.fr. Touchez Copier, collez dans le champ correspondant.")
                .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.Colors.muted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)

            copyStep(field: .hours, number: 1, label: "Heures d'accueil",
                     value: declaration.formattedHours, copyValue: declaration.copyHours)
            copyStep(field: .salary, number: 2, label: "Salaire net",
                     value: declaration.formattedNetSalary, copyValue: declaration.copyNetSalary)
            copyStep(field: .upkeep, number: 3, label: "Indemnités d'entretien",
                     value: declaration.formattedUpkeep, copyValue: declaration.copyUpkeep)
            copyStep(field: .net, number: 4, label: "Net à payer",
                     value: declaration.formattedNetToPay, copyValue: declaration.copyNetToPay)

            Button(action: openPajemploi) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.forward.square")
                        .font(.system(size: 16, weight: .bold))
                    Text("Ouvrir Pajemploi")
                        .font(.system(size: 15.5, weight: .heavy, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppTheme.Colors.brand)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)

            Button(action: { isDeclared.toggle() }) {
                HStack(spacing: 6) {
                    Image(systemName: isDeclared ? "checkmark.seal.fill" : "checkmark")
                        .font(.system(size: 13, weight: .bold))
                    Text(isDeclared ? "Mois déclaré" : "J'ai terminé ma déclaration")
                        .font(.system(size: 12.5, weight: .heavy, design: .rounded))
                }
                .foregroundColor(AppTheme.Colors.green)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Copy step row

    private func copyStep(field: CopyField, number: Int, label: String, value: String, copyValue: String) -> some View {
        let isCopied = copiedFields.contains(field)
        return HStack(spacing: 11) {
            ZStack {
                Circle()
                    .fill(isCopied ? AppTheme.Colors.green : AppTheme.Colors.brand)
                    .frame(width: 24, height: 24)
                if isCopied {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(number)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(0.3)
                    .foregroundColor(AppTheme.Colors.muted)
                Text(value)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.ink)
            }

            Spacer(minLength: 8)

            Button(action: { copy(field: field, value: copyValue) }) {
                HStack(spacing: 5) {
                    Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 12, weight: .bold))
                    Text(isCopied ? "Copié" : "Copier")
                        .font(.system(size: 11.5, weight: .heavy, design: .rounded))
                }
                .foregroundColor(isCopied ? AppTheme.Colors.green : AppTheme.Colors.brand)
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 11)
                        .fill((isCopied ? AppTheme.Colors.green : AppTheme.Colors.brand).opacity(0.12))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(isCopied ? AppTheme.Colors.green.opacity(0.07) : AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }

    // MARK: - Building blocks

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .tracking(1)
            .foregroundColor(AppTheme.Colors.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 2)
    }

    // MARK: - Actions

    private func copy(field: CopyField, value: String) {
        UIPasteboard.general.string = value
        withAnimation(.easeOut(duration: 0.2)) {
            _ = copiedFields.insert(field)
        }
    }

    private func openPajemploi() {
        guard let url = pajemploiURL else { return }
        openURL(url)
    }
}

// MARK: - Preview

#if DEBUG
struct PajemploiView_Previews: PreviewProvider {
    static var previews: some View {
        PajemploiView(declaration: .sample)
    }
}
#endif
