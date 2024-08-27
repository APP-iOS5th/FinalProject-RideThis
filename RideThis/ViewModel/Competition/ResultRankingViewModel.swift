//
//  ResultRankingViewModel.swift
//  RideThis
//
//  Created by SeongKook on 8/19/24.
//

import Foundation
import Combine

class ResultRankingViewModel {
    
    private let firebaseService = FireBaseService()
    let service = UserService.shared
    
    let nickName: String?
    let distance: Double
    @Published var myRank: Int = 0
    
    var records: [RecordModel] = []
    var displayedRecords: [(index: Int, record: RecordModel)] = []
    
    init(distance: Double, nickName: String) {
        self.distance = distance
        self.nickName = (service.combineUser != nil) ? service.combineUser?.user_nickname : "UNKOWNED"
        
        updateRecords()
    }
    
    // MARK: Record 찾기
    private func updateRecords() {
        Task {
            do {
                let userSnapshots = try await firebaseService.fetchAllUsers()
                let allRecordData = try await firebaseService.fetchAllRecordsForUsers(userSnapshots)
                self.records = allRecordData
                
                filterAndSortRecords()
                prepareDisplayedRecords()
            } catch {
                print("FIREBASE통신 오류")
            }
        }
    }
    
    // MARK: Distance Data Sorted
    private func filterAndSortRecords() {
        records = records.filter { record in
            record.record_competetion_status == true && record.record_target_distance == Int(distance)
        }
        
        records.sort { first, second in
            return timeInterval(from: first.record_timer) < timeInterval(from: second.record_timer)
        }
        
        self.myRank = records.firstIndex { $0.user_nickname == nickName } ?? 0
    }
    
    // MARK: Prepare Displayed Records
    private func prepareDisplayedRecords() {
        
        displayedRecords.removeAll()
        
        if myRank > 8 {

            for i in 0..<7 {
                displayedRecords.append((index: i + 1, record: records[i]))
            }
            

            displayedRecords.append((index: -1, record: RecordModel(record_timer: "", record_cadence: 0, record_speed: 0, record_distance: 0, record_calories: 0, record_start_time: nil, record_end_time: nil, record_data: nil, record_competetion_status: false, record_target_distance: 0, user_nickname: "test", user_id: "tt123")))
            

            if myRank == records.count - 1 {
                // myRank가 마지막 인덱스인 경우
                displayedRecords.append((index: myRank + 1, record: records[myRank]))
            } else {
                // myRank 이후부터 출력
                for i in myRank..<records.count {
                    displayedRecords.append((index: i + 1, record: records[i]))
                }
            }

        } else {
            for i in 0..<records.count {
                displayedRecords.append((index: i + 1, record: records[i]))
            }
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
