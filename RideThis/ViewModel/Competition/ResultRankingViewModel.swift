//
//  ResultRankingViewModel.swift
//  RideThis
//
//  Created by SeongKook on 8/19/24.
//

import Foundation

class ResultRankingViewModel {
    let name: String = "매드카우"
    let distance: Double = 10
    let ranking: Double = 34
    
    var records: [RecordModel] = []
    var displayedRecords: [(index: Int, record: RecordModel)] = []
    
    init() {
        records = RecordModel.sample
        sortedRecord()
        prepareDisplayedRecords()
    }
    
    private func sortedRecord() {
        records.sort { first, second in
            return timeInterval(from: first.record_timer) < timeInterval(from: second.record_timer)
        }
    }
    
    // MARK: Prepare Displayed Records
    private func prepareDisplayedRecords() {
        // 1번부터 7번까지
        for i in 0..<7 {
            displayedRecords.append((index: i + 1, record: records[i]))
        }
        
        // 생략된 부분
        displayedRecords.append((index: -1, record: RecordModel(record_timer: "", record_cadence: 0, record_speed: 0, record_distance: 0, record_calories: 0, record_start_time: nil, record_end_time: nil, record_data: nil, record_competetion_status: false, record_target_distance: 0, user_nickname: "test", user_id: "tt123")))
        
        // 10번부터 12번까지
        for i in 9..<12 {
            displayedRecords.append((index: i + 1, record: records[i]))
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
