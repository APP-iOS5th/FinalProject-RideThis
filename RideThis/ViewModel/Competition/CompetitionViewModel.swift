import Foundation
import Combine

enum RankingSegment: String, CaseIterable {
    case totalRanking = "전체 순위"
    case followingRanking = "팔로잉 순위"
}

class CompetitionViewModel {
    
    private let firebaseService = FireBaseService()
    let service = UserService.shared
    
    var selectedSegment: RankingSegment = .totalRanking
    var selectedDistance: DistanceCase = .fiveKm
    
    let isLogin: Bool
    var isBluetooth: Bool = false
    
    let nickName: String?
    
    private var allRecords: [RecordModel] = []
    @Published var records: [RecordModel] = []
    
    var followingUserIds: [String] = []
    
    // isLoading
    @Published var isLoading: Bool = false
    
    init(isLogin: Bool, nickName: String) {
        self.isLogin = isLogin
        self.nickName = nickName
    }
    
    // MARK: Following
    private func fetchFollowingUsers() {
        Task {
            do {
                self.followingUserIds = try await self.firebaseService.fetchUserFollowing(userId: self.service.combineUser?.user_id ?? "")
                
                self.followingUserIds.append(self.service.combineUser?.user_id ?? "")
                self.updateRecords()
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

        var filteredRecords: [RecordModel] = []
        
        if selectedSegment == .totalRanking {
            filteredRecords = allRecords.filter { record in
                record.record_competetion_status == true && record.record_target_distance == targetDistance
            }
        } else if selectedSegment == .followingRanking {
            if isLogin {
                filteredRecords = allRecords.filter { record in
                    record.record_competetion_status == true &&
                    record.record_target_distance == targetDistance &&
                    followingUserIds.contains(record.user_id)
                }
            } else {
                filteredRecords = []
            }
        }
        
        var bestRecordsByUserId: [String: RecordModel] = [:]
        
        for record in filteredRecords {
            if let existingRecord = bestRecordsByUserId[record.user_id] {
                if timeInterval(from: record.record_timer) < timeInterval(from: existingRecord.record_timer) {
                    bestRecordsByUserId[record.user_id] = record
                }
            } else {
                bestRecordsByUserId[record.user_id] = record
            }
        }
        
        records = Array(bestRecordsByUserId.values)
        records.sort { first, second in
            return timeInterval(from: first.record_timer) < timeInterval(from: second.record_timer)
        }
    }
    
    // MARK: allUSERS
    func fetchAllRecords() {
        self.isLoading = true
        Task {
            do {
                let userSnapshots = try await firebaseService.fetchAllUsers()
                let allRecordData = try await firebaseService.fetchAllRecordsForUsers(userSnapshots)
                self.allRecords = allRecordData
                
                fetchFollowingUsers()
                updateRecords()
            } catch {
                print("FIREBASE통신 오류")
            }
            self.isLoading = false
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
    
    // MARK: Bluetooth 상태 확인
    func checkBluetoothStatus() {
        Task {
            self.isBluetooth = await checkBluetooth()
        }
    }
    
    // MARK: Bluetooth 확인
    private func checkBluetooth() async -> Bool {
        do {
            let userDocument = try await firebaseService.fetchUser(at: service.combineUser?.user_id ?? "", userType: false)
            
            if case .userSnapshot(let queryDocumentSnapshot) = userDocument {
                guard let doc = queryDocumentSnapshot else {
                    print("User가 존재하지 않습니다.")
                    return false
                }
                
                let recordsCollection = firebaseService.fetchCollection(document: doc, collectionName: "DEVICES")
                
                let deviceDocuments = try await recordsCollection.getDocuments()
                
                for deviceDocument in deviceDocuments.documents {
                    if let registrationStatus = deviceDocument["device_registration_status"] as? Bool {
                        if registrationStatus {
                            return true
                        }
                    } else {
                        print("Device상태를 가져올 수 없습니다.")
                    }
                }
            } else {
                print("DEVICE데이터를 찾을 수 없습니다.")
            }
        } catch {
            print("FIREBASE 통신 오류: \(error.localizedDescription)")
            return false
        }
        
        return false
    }
    
    func getUserData(userId: String) async throws -> User? {
        if case .user(let user) = try await firebaseService.fetchUser(at: userId, userType: true) {
            return user
        }
        
        return nil
    }
}
