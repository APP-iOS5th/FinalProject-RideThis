import Foundation
import Combine

class UserProfileViewModel {
    @Published var recordsData: [RecordModel] = []
    @Published var cadenceAvg: Double = 0
    @Published var distanceAvg: Double = 0
    @Published var speedAvg: Double = 0
    @Published var caloriesAvg: Double = 0
    var firebaseService: FireBaseService
    
    init(firebaseService: FireBaseService) {
        self.firebaseService = firebaseService
    }
    
    func getRecords(userId: String) async {
        recordsData = await firebaseService.findRecordsBy(userId: userId)
    }
    
    func getRecordTimeDiff(endDate: Date, startDate: Date) -> Int {
        let timeInterval = endDate.timeIntervalSince(startDate)
        return Int(timeInterval)
    }
    
    func getRecordsBy(period: RecordPeriodCase, dataCase: RecordDataCase? = nil) -> [RecordModel] {
        let filteredData = recordsData.filter { $0.record_data! >= period.periodCondition && $0.record_data! <= Date() }
                          .sorted(by: { $0.record_data! < $1.record_data! })
        
        if let dataCase = dataCase {
            getTypeAverageby(records: filteredData, dataCase: dataCase, periodCase: period)
        }
        
        return filteredData
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
