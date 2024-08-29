import Foundation

struct HomeModel {
    // MARK: - Nested Structs
    struct WeeklyRecord {
        let runCount: Int
        let runTime: String
        let runDistance: Double
    }
    
    // MARK: - Properties
    var weeklyRecord: WeeklyRecord
    var userName: String
    
    // MARK: - Initialization
    init(weeklyRecord: WeeklyRecord, userName: String) {
        self.weeklyRecord = weeklyRecord
        self.userName = userName
    }
}
