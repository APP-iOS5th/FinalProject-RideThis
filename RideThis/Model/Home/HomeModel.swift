import Foundation

// MARK: - Nested Structs
struct WeeklyRecord {
    let runCount: Int
    let runTime: String
    let runDistance: Double
}

struct HomeModel {
    
    // MARK: - Properties
    var weeklyRecord: WeeklyRecord
    var userName: String
    
    // MARK: - Initialization
    init(weeklyRecord: WeeklyRecord, userName: String) {
        self.weeklyRecord = weeklyRecord
        self.userName = userName
    }
}
