import Foundation
import Combine

enum RankingSegment: String, CaseIterable {
    case totalRanking = "전체 순위"
    case followingRanking = "팔로잉 순위"
}

class CompetitionViewModel {
    
    private let firebaseService = FireBaseService()
    
    var selectedSegment: RankingSegment = .totalRanking
    var selectedDistance: DistanceCase = .fiveKm
    
    let isLogin = true
    let isBluetooth = true
    
    private var allRecords: [RecordModel] = []
    @Published var records: [RecordModel] = []
    
    var followingUserIds: [String] = []
    
    init() {
        fetchAllRecords()
        fetchFollowingUsers()
    }
    
    // MARK: Following
    private func fetchFollowingUsers() {
        Task {
            do {
                self.followingUserIds = try await firebaseService.fetchUserFollowing(userId: "test") // 로그인한 현재 아이디
                
                followingUserIds.append("test") // 로그인한 현재 아이디
                updateRecords()
            } catch {
                print("팔로잉 목록 가져오기 실패")
            }
        }
    }
    
    // MARK: Selected Ranking Segment
    func selectedSegment(selected: RankingSegment) {
        selectedSegment = selected
        updateRecords()
    }
    
    // MARK: Selected Distance
    func selectedDistance(selected: DistanceCase) {
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
            records = allRecords.filter { record in
                record.record_competetion_status == true && record.record_target_distance == targetDistance
            }

        } else if selectedSegment == .followingRanking {
            if isLogin {
                records = allRecords.filter { record in
                    record.record_competetion_status == true &&
                    record.record_target_distance == targetDistance &&
                    followingUserIds.contains(record.user_id)
                }
            } else {
                records = []
            }
        }
        
        records.sort { first, second in
            return timeInterval(from: first.record_timer) < timeInterval(from: second.record_timer)
        }
    }
    
    // MARK: allUSERS
    func fetchAllRecords() {
        Task {
            do {
                let userSnapshots = try await firebaseService.fetchAllUsers()
                let allRecordData = try await firebaseService.fetchAllRecordsForUsers(userSnapshots)
                self.allRecords = allRecordData
                updateRecords()
            } catch {
                print("FIREBASE통신 오류")
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
