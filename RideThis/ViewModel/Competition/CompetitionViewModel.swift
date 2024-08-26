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
    
    init(isLogin: Bool, nickName: String) {
        self.isLogin = (service.signedUser != nil) ? true : false
        self.nickName = (service.signedUser != nil) ? service.signedUser?.user_nickname : "UNKOWNED"
        
        fetchAllRecords()
        fetchFollowingUsers()
        checkBluetoothStatus()
    }
    
    // MARK: Following
    private func fetchFollowingUsers() {
        Task {
            do {
                self.followingUserIds = try await firebaseService.fetchUserFollowing(userId: service.signedUser?.user_id ?? "")
                
                followingUserIds.append(service.signedUser?.user_id ?? "")
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
    
    // MARK: Bluetooth 상태 확인
    private func checkBluetoothStatus() {
        Task {
            self.isBluetooth = await checkBluetooth()
        }
    }
    
    // MARK: Bluetooth 확인
    private func checkBluetooth() async -> Bool {
        do {
            let userDocument = try await firebaseService.fetchUser(at: service.signedUser?.user_id ?? "", userType: false)
            
            if case .userSnapshot(let queryDocumentSnapshot) = userDocument {
                guard let doc = queryDocumentSnapshot else {
                    print("User가 존재하지 않습니다.")
                    return false
                }
                
                let recordsCollection = firebaseService.fetchCollection(document: doc, collectionName: "DEVICE")
                
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
            print("Database error: \(error.localizedDescription)")
            return false
        }
        
        return false
    }
}
