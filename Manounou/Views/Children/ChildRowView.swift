import SwiftUI

// MARK: - Child Row View
struct ChildRowView: View, Equatable {
    let child: FunctionalChild
    let onTap: () -> Void
    
    static func == (lhs: ChildRowView, rhs: ChildRowView) -> Bool {
        lhs.child.id == rhs.child.id &&
        lhs.child.firstName == rhs.child.firstName &&
        lhs.child.lastName == rhs.child.lastName &&
        lhs.child.birthDate == rhs.child.birthDate
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Profile Image
                Group {
                    if let profileImage = child.profileImage {
                        AsyncImage(url: profileImage) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                )
                        }
                    } else {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .overlay(
                                Text(child.initials)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            )
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                // Child Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(child.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(child.ageDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - FunctionalChild Extensions
extension FunctionalChild {
    var name: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    var ageDescription: String {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year, .month], from: birthDate, to: now)
        
        if let years = ageComponents.year, years > 0 {
            return years == 1 ? "1 an" : "\(years) ans"
        } else if let months = ageComponents.month, months > 0 {
            return months == 1 ? "1 mois" : "\(months) mois"
        } else {
            return "Nouveau-né"
        }
    }
}

// MARK: - Preview
struct ChildRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ChildRowView(
                child: FunctionalChild(
                    id: UUID(),
                    firstName: "Emma",
                    lastName: "Dupont",
                    birthDate: Calendar.current.date(byAdding: .year, value: -5, to: Date()) ?? Date(),
                    profileImage: nil
                )
            ) {
                // Action
            }
            
            ChildRowView(
                child: FunctionalChild(
                    id: UUID(),
                    firstName: "Lucas",
                    lastName: "Martin",
                    birthDate: Calendar.current.date(byAdding: .month, value: -8, to: Date()) ?? Date(),
                    profileImage: nil
                )
            ) {
                // Action
            }
        }
        .listStyle(PlainListStyle())
    }
}