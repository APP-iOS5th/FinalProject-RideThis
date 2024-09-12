

import Foundation

class NonMemberRecordSummaryViewModel {
    
    private let firebaseService = FireBaseService()
    
    var recordedTime: String
    var cadence: Double
    var speed: Double
    var distance: Double
    var calorie: Double
    var startTime: Date
    var endTime: Date
    
    init() {
        self.recordedTime = "00:00"
        self.cadence = 0.0
        self.speed = 0.0
        self.distance = 0.0
        self.calorie = 0.0
        self.startTime = Date()
        self.endTime = Date()
        
        if let userSummary = self.loadUnloginUserSummaryFromDefaults() {
            self.recordedTime = userSummary.recordedTime
            self.cadence = userSummary.cadence
            self.speed = userSummary.speed
            self.distance = userSummary.distance
            self.calorie = userSummary.calorie
            self.startTime = userSummary.startTime
            self.endTime = userSummary.endTime
        }
    }
    
    
    // MARK: 유저디폴트 데이터 가져오기
    func loadUnloginUserSummaryFromDefaults() -> SummaryData? {
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "UnloginUserSummary") as? Data {
            let decoder = JSONDecoder()
            if let summary = try? decoder.decode(SummaryData.self, from: savedData) {
                return summary
            }
        }

        return nil
    }
    
    // MARK: 유저디폴트 데이터 삭제하기
    func deleteUnloginUserSummaryFromDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "UnloginUserSummary")
    }
    
    // MARK: 데이터 저장
    func saveRecording() async {
        do {
            // 유저아이디가 존재하는지 확인
            let userDocument = try await firebaseService.fetchUser(at: UserService.shared.signedUser?.user_id ?? "", userType: false)
            
            if case .userSnapshot(let queryDocumentSnapshot) = userDocument {
                guard let doc = queryDocumentSnapshot else {
                    print("유저를 찾을 수 없습니다.")
                    return
                }
                // USERS 도큐먼트에서 Collection 찾기
                let recordsCollection = firebaseService.fetchCollection(document: doc, collectionName: "RECORDS")
                
                try await firebaseService.fetchRecord(collection: recordsCollection, timer: self.recordedTime, cadence: self.cadence, speed: self.speed, distance: self.distance, calorie: self.calorie, startTime: self.startTime, endTime: self.endTime, date: Date(), competetionStatus: false, tagetDistance: nil)
                
                deleteUnloginUserSummaryFromDefaults()
            }
        } catch {
            print("라이딩 처리 에러: \(error.localizedDescription)")
        }
    }
}
