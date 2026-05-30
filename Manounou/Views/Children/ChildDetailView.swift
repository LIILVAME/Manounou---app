//
//  ChildDetailView.swift
//  Manounou
//
//  Created by Assistant on 18/08/2025.
//  Overlay « Fiche enfant » — drill-down depuis Profil ▸ Enfants.
//  Recréé d'après le design handoff « Focus Profil · Overlays » (overlay n°1) :
//  barre de retour + identité en tête, sections en cartes blanches arrondies,
//  système de design Manounou (accent rose, SF Rounded, fond papier).
//
//  Périmètre : uniquement les données réellement portées par le modèle `Child`
//  (identité, date de naissance, genre, catégorie d'âge, notes). Les sections
//  Santé / Habitudes / Contacts d'urgence du design nécessitent un backend
//  dédié (non encore en place) et sont volontairement hors scope ici.
//

import SwiftUI

struct ChildDetailView: View {
    let child: Child
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditChild = false

    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.Colors.paper
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    overlayBar
                    identityBlock
                    informationSection

                    if let notes = child.notes,
                       !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        notesSection(notes: notes)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showingEditChild) {
            EditChildView(child: child)
        }
    }

    // MARK: - Overlay Bar (retour · titre · Modifier)

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

            Text(child.firstName)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.Colors.ink)

            Spacer()

            Button(action: { showingEditChild = true }) {
                Text("Modifier")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(AppTheme.Colors.brand)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Identité (gros avatar + nom + âge)

    private var identityBlock: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(child.gender.color.opacity(0.14))
                    .frame(width: 86, height: 86)

                if let url = child.profileImageURL, !url.isEmpty {
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        avatarInitials
                    }
                    .frame(width: 86, height: 86)
                    .clipShape(Circle())
                } else {
                    avatarInitials
                }
            }

            VStack(spacing: 2) {
                Text(child.fullName)
                    .font(.system(size: 23, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.ink)
                    .multilineTextAlignment(.center)

                Text("\(child.formattedAge) · \(bornText)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.muted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }

    private var avatarInitials: some View {
        Text(child.initials)
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundColor(child.gender.color)
    }

    private var bornText: String {
        let prefix = child.gender == .female ? "née le" : "né le"
        return "\(prefix) \(child.birthDateText)"
    }

    // MARK: - Section Informations

    private var informationSection: some View {
        VStack(spacing: 8) {
            sectionLabel("Informations")
            card {
                detailRow(
                    icon: "calendar",
                    iconColor: AppTheme.Colors.blue,
                    title: child.birthDateText,
                    subtitle: "Date de naissance",
                    showDivider: true
                )
                detailRow(
                    icon: child.gender.icon,
                    iconColor: child.gender.color,
                    title: child.gender.displayName,
                    subtitle: "Genre",
                    showDivider: true
                )
                detailRow(
                    icon: child.ageCategory.icon,
                    iconColor: child.ageCategory.color,
                    title: child.ageCategory.displayName,
                    subtitle: "Catégorie d'âge",
                    showDivider: false
                )
            }
        }
    }

    // MARK: - Section Notes (À savoir)

    private func notesSection(notes: String) -> some View {
        VStack(spacing: 8) {
            sectionLabel("À savoir")
            card {
                detailRow(
                    icon: "note.text",
                    iconColor: AppTheme.Colors.amber,
                    title: notes,
                    subtitle: nil,
                    showDivider: false
                )
            }
        }
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

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(.horizontal, 15)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }

    private func detailRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String?,
        showDivider: Bool
    ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(iconColor)
                    .frame(width: 34, height: 34)
                    .background(RoundedRectangle(cornerRadius: 9).fill(iconColor.opacity(0.10)))

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 14.5, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.Colors.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.Colors.muted)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 13)

            if showDivider {
                Rectangle()
                    .fill(AppTheme.Colors.divider)
                    .frame(height: 1)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ChildDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChildDetailView(child: Child.sampleChildren[0])
    }
}
#endif
