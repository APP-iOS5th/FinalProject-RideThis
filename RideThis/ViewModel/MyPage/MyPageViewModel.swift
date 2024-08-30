import Foundation
import Combine

enum RecordPeriodCase: String, CaseIterable {
    case oneWeek = "1주"
    case oneMonth = "1개월"
    case threeMonths = "3개월"
    case sixMonths = "6개월"
    
    var periodCondition: Date {
        let today = Date()
        let calendar = Calendar.current
        
        switch self {
        case .oneWeek:
            return calendar.date(byAdding: .day, value: -6, to: today)!
        case .oneMonth:
            return calendar.date(byAdding: .month, value: -1, to: today)!
        case .threeMonths:
            return calendar.date(byAdding: .month, value: -3, to: today)!
        case .sixMonths:
            return calendar.date(byAdding: .month, value: -6, to: today)!
        }
    }
    
    var graphXAxis: [String] {
        let today = Date()
        let calendar = Calendar.current
        var dates: [String] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        var dateCount = 0
        switch self {
        case .oneWeek:
            let weekDays = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"]

            let todayIndex = calendar.component(.weekday, from: today) - 1
            return Array(weekDays[todayIndex+1..<weekDays.count] + weekDays[0...todayIndex])
        case .oneMonth:
            dateCount = 30
        case .threeMonths:
            dateCount = 90
        case .sixMonths:
            dateCount = 180
        }
        
        for i in (0..<dateCount).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateString = dateFormatter.string(from: date)
                dates.append(dateString)
            }
        }
        return dates
    }
}

class MyPageViewModel {
    
    @Published var recordsData: [RecordModel] = []
    @Published var cadenceAvg: Double = 0
    @Published var distanceAvg: Double = 0
    @Published var speedAvg: Double = 0
    @Published var caloriesAvg: Double = 0
    private var cancellable = Set<AnyCancellable>()
    var firebaseService: FireBaseService
    var periodCase: RecordPeriodCase
    
    init(firebaseService: FireBaseService, periodCase: RecordPeriodCase) {
        self.firebaseService = firebaseService
        self.periodCase = periodCase
    }
    
    func getRecords(userId: String) async {
        let allRecords = await firebaseService.findRecordsBy(userId: userId)
        recordsData = allRecords.filter { !$0.record_competetion_status }
    }
    
    func getRecordsBy(period: RecordPeriodCase, dataCase: RecordDataCase? = nil) -> [RecordModel] {
        let filteredData = recordsData.filter { $0.record_data! >= period.periodCondition && $0.record_data! <= Date() && !$0.record_competetion_status }
                          .sorted(by: { $0.record_data! < $1.record_data! })
        
        if let dataCase = dataCase {
            getTypeAverageby(records: filteredData, dataCase: dataCase, periodCase: period)
        }
        
        return filteredData
    }
    
    func getRecordTimeDiff(endDate: Date, startDate: Date) -> Int {
        let timeInterval = endDate.timeIntervalSince(startDate)
        return Int(timeInterval)
    }
    
    func getTypeAverageby(records: [RecordModel], dataCase: RecordDataCase, periodCase: RecordPeriodCase) {
        if records.count > 0 {
            switch dataCase {
            case .cadence:
                cadenceAvg = (records.map{ $0.record_cadence }.reduce(0, +) / Double(records.count)).getTwoDecimal
            case .distance:
                distanceAvg = (records.map{ $0.record_distance }.reduce(0, +) / Double(records.count)).getTwoDecimal
            case .speed:
                speedAvg = (records.map{ $0.record_speed }.reduce(0, +) / Double(records.count)).getTwoDecimal
            case .calories:
                caloriesAvg = (records.map{ $0.record_calories }.reduce(0, +) / Double(records.count)).getTwoDecimal
            }
        }
    }
}
