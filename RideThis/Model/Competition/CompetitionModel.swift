import Foundation

struct RecordModel {
    let record_timer: String
    let record_cadence: Double
    let record_speed: Double
    let record_distance: Double
    let record_calories: Double
    let record_start_time: Date?
    let record_end_time: Date?
    let record_data: Date?
    let record_competetion_status: Bool
    let record_target_distance: Int
    let user_nickname: String
    let user_id: String
}
