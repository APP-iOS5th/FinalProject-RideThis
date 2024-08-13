import Foundation
import Combine

enum RankingSegment: String, CaseIterable {
    case totalRanking = "전체 순위"
    case followingRanking = "팔로잉 순위"
}

enum DistanceSelection: String, CaseIterable {
    case fiveKm = "5"
    case tenKm = "10"
    case thirtyKm = "30"
    case hundredKm = "100"
}

class CompetitionViewModel {
    var selectedSegment: RankingSegment = .totalRanking
    var selectedDistance: DistanceSelection = .fiveKm
    
    let isLogin = true
    let isBluetooth = true
    
    @Published var records: [RecordsMockData] = []
    
    init() {
        updateRecords()
    }
    
    // MARK: Selected Ranking Segment
    func selectedSegment(selected: RankingSegment) {
        selectedSegment = selected
        updateRecords()
    }
    
    // MARK: Selected Distance
    func selectedDistance(selected: DistanceSelection) {
        selectedDistance = selected
        updateRecords()
    }
    
    // MARK: Update Records
    private func updateRecords() {
        guard let targetDistance = Int(selectedDistance.rawValue) else {
            records = []
            return
        }
        
        if selectedSegment == .totalRanking {
            records = RecordsMockData.sample.filter { record in
                record.record_competetion_status == true && record.record_target_distance == targetDistance
            }
        } else if selectedSegment == .followingRanking {
            if isLogin {
                records = RecordsMockData.sample.filter { record in
                    record.record_competetion_status == false && record.record_target_distance == targetDistance
                }
            } else {
                records = []
            }
        }
        
        records.sort { first, second in
            return timeInterval(from: first.record_timer) < timeInterval(from: second.record_timer)
        }
    }
    
    // MARK: Change String Time
    private func timeInterval(from timerString: String) -> TimeInterval {
        let components = timerString.split(separator: ":").map { String($0) }
        guard components.count == 2,
              let minutes = Double(components[0]),
              let seconds = Double(components[1]) else {
            return 0
        }
        return (minutes * 60) + seconds
    }
}
