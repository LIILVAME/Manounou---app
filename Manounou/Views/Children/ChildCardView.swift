//
//  ChildCardView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

struct ChildCardView: View {
    let child: Child
    let geometry: GeometryProxy
    let onTap: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: geometry.size.width * 0.04) {
                // Avatar section
                childAvatar
                
                // Information section
                VStack(alignment: .leading, spacing: geometry.size.height * 0.008) {
                    // Name and age
                    HStack {
                        Text(child.fullName)
                            .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Spacer()
                        
                        Text(child.ageText)
                            .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    // Category and gender indicators
                    HStack(spacing: geometry.size.width * 0.02) {
                        // Age category badge
                        categoryBadge
                        
                        // Gender indicator
                        genderIndicator
                        
                        Spacer()
                        
                        // Edit button
                        editButton
                    }
                    
                    // Birth date
                    Text("Né(e) le \(child.birthDateText)")
                        .font(.system(size: geometry.size.width * 0.032, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(geometry.size.width * 0.04)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: geometry.size.width * 0.01,
                        x: 0,
                        y: geometry.size.width * 0.005
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Avatar Component
    private var childAvatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [child.gender.color.opacity(0.3), child.gender.color.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(
                    width: geometry.size.width * 0.15,
                    height: geometry.size.width * 0.15
                )
            
            if let profileImageURL = child.profileImageURL, !profileImageURL.isEmpty {
                // TODO: Implement AsyncImage for profile photos
                AsyncImage(url: URL(string: profileImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    initialsView
                }
                .frame(
                    width: geometry.size.width * 0.15,
                    height: geometry.size.width * 0.15
                )
                .clipShape(Circle())
            } else {
                initialsView
            }
        }
    }
    
    private var initialsView: some View {
        Text(child.initials)
            .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
            .foregroundColor(child.gender.color)
    }
    
    // MARK: - Category Badge
    private var categoryBadge: some View {
        HStack(spacing: geometry.size.width * 0.015) {
            Image(systemName: child.ageCategory.icon)
                .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                .foregroundColor(child.ageCategory.color)
            
            Text(child.ageCategory.displayName)
                .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                .foregroundColor(child.ageCategory.color)
        }
        .padding(.horizontal, geometry.size.width * 0.02)
        .padding(.vertical, geometry.size.height * 0.005)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                .fill(child.ageCategory.color.opacity(0.15))
        )
    }
    
    // MARK: - Gender Indicator
    private var genderIndicator: some View {
        HStack(spacing: geometry.size.width * 0.01) {
            Image(systemName: child.gender.icon)
                .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                .foregroundColor(child.gender.color)
            
            Text(child.gender.displayName)
                .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                .foregroundColor(child.gender.color)
        }
        .padding(.horizontal, geometry.size.width * 0.02)
        .padding(.vertical, geometry.size.height * 0.005)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                .fill(child.gender.color.opacity(0.15))
        )
    }
    
    // MARK: - Edit Button
    private var editButton: some View {
        Button(action: onEdit) {
            Image(systemName: "pencil")
                .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                .foregroundColor(.blue)
                .frame(
                    width: geometry.size.width * 0.08,
                    height: geometry.size.width * 0.08
                )
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#if DEBUG
struct ChildCardView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                ForEach(Child.sampleChildren, id: \.id) { child in
                    ChildCardView(
                        child: child,
                        geometry: geometry,
                        onTap: {
                            Logger.info("Child card tapped", category: .ui)
                        },
                        onEdit: {
                            Logger.info("Child edit action triggered", category: .ui)
                        }
                    )
                }
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Child Cards")
    }
}
#endif