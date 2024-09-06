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

enum ViewCase: Int {
    case home = 0
    case competition = 1
    case record = 2
    case device = 3
    case myPage = 4
    case summary = 5
}
