import Foundation
import Supabase

// MARK: - DTO (also the domain model — no translation needed)

struct PlanConfigDTO: Codable {
    let id: String
    let displayName: String
    let priceLabel: String
    let maxChildren: Int
    let maxDocuments: Int
    let colorHex: String

    enum CodingKeys: String, CodingKey {
        case id
        case displayName  = "display_name"
        case priceLabel   = "price_label"
        case maxChildren  = "max_children"
        case maxDocuments = "max_documents"
        case colorHex     = "color_hex"
    }
}

// MARK: - Service

class PlansService {
    private let supabaseClient: SupabaseClient

    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }

    /// Returns all plans keyed by plan id ("free", "starter", "full").
    func fetchAllPlans() async throws -> [String: PlanConfigDTO] {
        let dtos: [PlanConfigDTO] = try await supabaseClient
            .from(Config.Tables.plans)
            .select()
            .execute()
            .value
        return Dictionary(uniqueKeysWithValues: dtos.map { ($0.id, $0) })
    }
}
