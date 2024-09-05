import Foundation

class RecordSumUpViewModel {
    private let firebaseService = FireBaseService()
    
    var summaryData: SummaryData
    
    init(summaryData: SummaryData) {
        self.summaryData = summaryData
    }
    
    weak var delegate: RecordSumUpViewModelDelegate?
    
    func updateSummaryData(cadence: Double, speed: Double, distance: Double, calorie: Double) {
        summaryData = SummaryData(
            recordedTime: summaryData.recordedTime,
            cadence: cadence,
            speed: speed,
            distance: distance,
            calorie: calorie,
            startTime: summaryData.startTime,
            endTime: summaryData.endTime
        )
    }
    
    func cancelSaveRecording() {
        print("save cancel pushed")
        // 기록 요약 화면에서 취소 버튼 누르면 이전 화면(기록 화면)으로 이동
        delegate?.didCancelSaveRecording()
    }
    
    func saveRecording() async {
        print("save pushed")
        
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
                
                try await firebaseService.fetchRecord(collection: recordsCollection, timer: summaryData.recordedTime, cadence: summaryData.cadence, speed: summaryData.speed, distance: summaryData.distance, calorie: summaryData.calorie, startTime: summaryData.startTime, endTime: summaryData.endTime, date: Date(), competetionStatus: false, tagetDistance: nil)
                
                print("기록 추가")
                
                await MainActor.run {
                    self.delegate?.didSaveRecording()
                }
            }
        } catch {
            print("기록 처리 에러: \(error.localizedDescription)")
        }
    }
}

protocol RecordSumUpViewModelDelegate: AnyObject {
    func didCancelSaveRecording()
    func didSaveRecording()
}
