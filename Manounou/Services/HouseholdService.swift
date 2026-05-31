import Foundation
import Supabase

// MARK: - Domain Model

struct HouseholdMember: Identifiable {
    let id: UUID
    let userId: UUID
    var name: String
    var color: String   // hex "#RRGGBB"
    var role: String
    var sortOrder: Int
}

// MARK: - DTO

private struct HouseholdMemberDTO: Codable {
    var id: UUID?
    let userId: UUID
    var name: String
    var color: String
    var role: String
    var sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userId    = "user_id"
        case name, color, role
        case sortOrder = "sort_order"
    }
}

// MARK: - Service

class HouseholdService {
    private let supabaseClient: SupabaseClient

    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }

    func fetchMembers(userId: UUID) async throws -> [HouseholdMember] {
        let dtos: [HouseholdMemberDTO] = try await supabaseClient
            .from(Config.Tables.householdMembers)
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("sort_order")
            .execute()
            .value
        return dtos.compactMap { dto in
            guard let id = dto.id else { return nil }
            return HouseholdMember(id: id, userId: dto.userId, name: dto.name,
                                   color: dto.color, role: dto.role, sortOrder: dto.sortOrder)
        }
    }

    /// Inserts default members ("Papa", "Maman") on first use if the table is empty.
    func seedDefaultMembers(userId: UUID) async throws {
        let existing = try await fetchMembers(userId: userId)
        guard existing.isEmpty else { return }
        let defaults: [(name: String, color: String, role: String)] = [
            ("Papa",  "#2E7BEE", "parent"),
            ("Maman", "#7A5AE0", "parent")
        ]
        for (i, m) in defaults.enumerated() {
            let dto = HouseholdMemberDTO(id: nil, userId: userId,
                                         name: m.name, color: m.color,
                                         role: m.role, sortOrder: i)
            try await supabaseClient
                .from(Config.Tables.householdMembers)
                .insert(dto)
                .execute()
        }
    }

    func addMember(userId: UUID, name: String, color: String, role: String) async throws -> HouseholdMember {
        let count = try await fetchMembers(userId: userId).count
        let dto = HouseholdMemberDTO(id: nil, userId: userId, name: name,
                                     color: color, role: role, sortOrder: count)
        let response: HouseholdMemberDTO = try await supabaseClient
            .from(Config.Tables.householdMembers)
            .insert(dto)
            .select()
            .single()
            .execute()
            .value
        guard let id = response.id else {
            throw ServiceError.unknownError("ID manquant après insertion")
        }
        return HouseholdMember(id: id, userId: response.userId, name: response.name,
                               color: response.color, role: response.role, sortOrder: response.sortOrder)
    }
}
