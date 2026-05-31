import Foundation
import Supabase

// MARK: - Domain Model

struct PlanningSchedule {
    var scheduleMode: Int
    var activeDays: Set<Int>
    var dropTime: String
    var pickTime: String
    var dropBy: String
    var pickBy: String
    var carerName: String

    static var `default`: PlanningSchedule {
        PlanningSchedule(
            scheduleMode: 0,
            activeDays: [1, 2, 3, 4, 5],
            dropTime: "09:00",
            pickTime: "17:00",
            dropBy: "Papa",
            pickBy: "Maman",
            carerName: "la nounou"
        )
    }

    var dropHour: Int { Int(dropTime.prefix(2)) ?? 9 }
    var pickHour: Int { Int(pickTime.prefix(2)) ?? 17 }
}

// MARK: - DTO

private struct PlanningScheduleDTO: Codable {
    var id: UUID?
    let userId: UUID
    var scheduleMode: Int
    var activeDays: [Int]
    var dropTime: String
    var pickTime: String
    var dropBy: String
    var pickBy: String
    var carerName: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId       = "user_id"
        case scheduleMode = "schedule_mode"
        case activeDays   = "active_days"
        case dropTime     = "drop_time"
        case pickTime     = "pick_time"
        case dropBy       = "drop_by"
        case pickBy       = "pick_by"
        case carerName    = "carer_name"
    }
}

// MARK: - Service

class PlanningScheduleService {
    private let supabaseClient: SupabaseClient

    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }

    func fetchSchedule(userId: UUID) async throws -> PlanningSchedule? {
        do {
            let dto: PlanningScheduleDTO = try await supabaseClient
                .from(Config.Tables.planningSchedules)
                .select()
                .eq("user_id", value: userId.uuidString)
                .single()
                .execute()
                .value
            return PlanningSchedule(
                scheduleMode: dto.scheduleMode,
                activeDays: Set(dto.activeDays),
                dropTime: dto.dropTime,
                pickTime: dto.pickTime,
                dropBy: dto.dropBy,
                pickBy: dto.pickBy,
                carerName: dto.carerName
            )
        } catch {
            return nil
        }
    }

    func upsertSchedule(_ schedule: PlanningSchedule, userId: UUID) async throws {
        let dto = PlanningScheduleDTO(
            id: nil,
            userId: userId,
            scheduleMode: schedule.scheduleMode,
            activeDays: Array(schedule.activeDays).sorted(),
            dropTime: schedule.dropTime,
            pickTime: schedule.pickTime,
            dropBy: schedule.dropBy,
            pickBy: schedule.pickBy,
            carerName: schedule.carerName
        )
        try await supabaseClient
            .from(Config.Tables.planningSchedules)
            .upsert(dto, onConflict: "user_id")
            .execute()
    }
}
