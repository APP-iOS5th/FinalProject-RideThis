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

extension RecordModel {
    static var sample: [RecordModel] = [
        RecordModel(
            record_timer: "25:30",
            record_cadence: 28.4,
            record_speed: 15.8,
            record_distance: 60,
            record_calories: 850,
            record_start_time: nil,
            record_end_time: nil,
            record_data: nil,
            record_competetion_status: true,
            record_target_distance: 5,
            user_nickname: "1",
            user_id: "test1"
        ),
        RecordModel(
            record_timer: "35:45",
            record_cadence: 30.2,
            record_speed: 17.5,
            record_distance: 75,
            record_calories: 950,
            record_start_time: nil,
            record_end_time: nil,
            record_data: nil,
            record_competetion_status: true,
            record_target_distance: 10,
            user_nickname: "2",
            user_id: "test2"
        ),
        RecordModel(
            record_timer: "50:10",
            record_cadence: 29.8,
            record_speed: 19.1,
            record_distance: 120,
            record_calories: 1100,
            record_start_time: nil,
            record_end_time: nil,
            record_data: nil,
            record_competetion_status: true,
            record_target_distance: 30,
            user_nickname: "3",
            user_id: "test3"
        ),
        RecordModel(
            record_timer: "40:25",
            record_cadence: 27.6,
            record_speed: 16.5,
            record_distance: 95,
            record_calories: 1020,
            record_start_time: nil,
            record_end_time: nil,
            record_data: nil,
            record_competetion_status: true,
            record_target_distance: 100,
            user_nickname: "4",
            user_id: "test4"
        ),
        RecordModel(
            record_timer: "20:15",
            record_cadence: 31.1,
            record_speed: 18.3,
            record_distance: 50,
            record_calories: 780,
            record_start_time: nil,
            record_end_time: nil,
            record_data: nil,
            record_competetion_status: true,
            record_target_distance: 5,
            user_nickname: "5",
            user_id: "test5"
        ),
        RecordModel(
            record_timer: "45:00",
            record_cadence: 26.9,
            record_speed: 14.7,
            record_distance: 110,
            record_calories: 1080,
            record_start_time: nil,
            record_end_time: nil,
            record_data: nil,
            record_competetion_status: true,
            record_target_distance: 30,
            user_nickname: "6",
            user_id: "test6"
        ),
        RecordModel(
            record_timer: "30:20",
            record_cadence: 29.5,
            record_speed: 16.8,
            record_distance: 80,
            record_calories: 880,
            record_start_time: nil,
            record_end_time: nil,
            record_data: nil,
            record_competetion_status: true,
            record_target_distance: 10,
            user_nickname: "7",
            user_id: "test7"
        ),
        RecordModel(
            record_timer: "55:50",
            record_cadence: 28.3,
            record_speed: 20.0,
            record_distance: 140,
            record_calories: 1150,
            record_start_time: nil,
            record_end_time: nil,
            record_data: nil,
            record_competetion_status: true,
            record_target_distance: 100,
            user_nickname: "8",
            user_id: "test8"
        ),
        RecordModel(
            record_timer: "38:35",
            record_cadence: 30.0,
            record_speed: 18.0,
            record_distance: 90,
            record_calories: 920,
            record_start_time: nil,
            record_end_time: nil,
            record_data: nil,
            record_competetion_status: true,
            record_target_distance: 10,
            user_nickname: "9",
            user_id: "test9"
        ),
        RecordModel(
            record_timer: "42:20",
            record_cadence: 27.0,
            record_speed: 17.0,
            record_distance: 100,
            record_calories: 1000,
            record_start_time: nil,
            record_end_time: nil,
            record_data: nil,
            record_competetion_status: false,
            record_target_distance: 30,
            user_nickname: "10",
            user_id: "test10"
        ),
        RecordModel(
            record_timer: "32:21",
            record_cadence: 22.0,
            record_speed: 40.0,
            record_distance: 100,
            record_calories: 1000,
            record_start_time: nil,
            record_end_time: nil,
            record_data: nil,
            record_competetion_status: true,
            record_target_distance: 5,
            user_nickname: "11",
            user_id: "test11"
        ),
        RecordModel(
            record_timer: "34:12",
            record_cadence: 22.0,
            record_speed: 40.0,
            record_distance: 100,
            record_calories: 1000,
            record_start_time: nil,
            record_end_time: nil,
            record_data: nil,
            record_competetion_status: true,
            record_target_distance: 5,
            user_nickname: "12",
            user_id: "test12"
        )
    ]
}
