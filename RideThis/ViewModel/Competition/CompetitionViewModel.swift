import Foundation
import Combine

class CompetitionViewModel {
    let segmentStatus = ["전체 순위", "팔로잉 순위"]
    let distanceSelection = ["5", "10", "30", "100"]
    
    var selectedSegment = "전체 순위"
    var selectedDistance = "5"
    
    let isLogin = true
    
    let isBluetooth = false
    
    @Published var records: [RecordsMockData] = []
    
    init() {
        updateRecords()
    }
    
    func selectedSegment(selected: String) {
        selectedSegment = selected
        updateRecords()
    }
    
    func selectedDistance(selected: String) {
        selectedDistance = selected
        updateRecords()
    }
    
    // Records 배열을 업데이트하고 정렬하는 함수
    private func updateRecords() {
        guard let targetDistance = Int(selectedDistance) else {
            records = []
            return
        }
        
        // 전체 순위는 항상 보여주고, 팔로잉 순위에서만 로그인 상태를 체크
        if selectedSegment == "전체 순위" {
            records = RecordsMockData.sample.filter { record in
                record.record_competetion_status == true && record.record_target_distance == targetDistance
            }
        } else if selectedSegment == "팔로잉 순위" {
            if isLogin {
                records = RecordsMockData.sample.filter { record in
                    record.record_competetion_status == false && record.record_target_distance == targetDistance
                }
            } else {
                records = []
            }
        }
        
        // record_timer에 따라 정렬
        records.sort { first, second in
            return timeInterval(from: first.record_timer) < timeInterval(from: second.record_timer)
        }
    }
    
    // "mm:ss" 형식의 시간을 TimeInterval로 변환하는 함수
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
