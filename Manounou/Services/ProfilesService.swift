import Foundation
import Supabase

// MARK: - DTO

struct ProfileDTO: Codable {
    let id: UUID
    var firstName: String?
    var lastName: String?
    var phone: String?
    var avatarUrl: String?
    var language: String
    var role: String
    var plan: String
    var planStatus: String
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case firstName  = "first_name"
        case lastName   = "last_name"
        case phone
        case avatarUrl  = "avatar_url"
        case language, role, plan
        case planStatus = "plan_status"
        case createdAt  = "created_at"
        case updatedAt  = "updated_at"
    }

    /// Merge DB profile data into an auth-derived User (email kept from auth).
    func applyTo(_ user: User) -> User {
        User(
            id: id,
            email: user.email,
            firstName: firstName ?? user.firstName,
            lastName: lastName ?? user.lastName,
            phoneNumber: phone,
            avatarUrl: avatarUrl,
            language: language,
            role: UserRole(rawValue: role) ?? .parent,
            plan: UserPlan(rawValue: plan) ?? .free,
            planStatus: PlanStatus(rawValue: planStatus) ?? .active,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Service

class ProfilesService {
    private let supabaseClient: SupabaseClient

    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }

    func fetchProfile(userId: UUID) async throws -> ProfileDTO {
        return try await supabaseClient
            .from(Config.Tables.profiles)
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value
    }

    func upsertProfile(_ profile: ProfileDTO) async throws {
        try await supabaseClient
            .from(Config.Tables.profiles)
            .upsert(profile)
            .execute()
    }
}
