import Foundation

struct HomeModel {
    struct WeeklyRecord {
        let runCount: Int
        let runTime: String
        let runDistance: Double
    }
    
    let weeklyRecord: WeeklyRecord
    let userName: String
    
    init(weeklyRecord: WeeklyRecord, userName: String) {
        self.weeklyRecord = weeklyRecord
        self.userName = userName
    }
}
