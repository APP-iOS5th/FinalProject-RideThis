import Foundation

class HomeViewModel {
    struct WeeklyRecord {
        let runCount: Int
        let runTime: String
        let runDistance: Double
    }
    
    let weeklyRecord: WeeklyRecord
    
    init() {
        self.weeklyRecord = WeeklyRecord(runCount: 6, runTime: "15시간 34분", runDistance: 404.51)
    }
}
