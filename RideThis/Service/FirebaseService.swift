import Foundation
import FirebaseFirestore

class FireBaseService {
    
    private let db = Firestore.firestore()
    
    // MARK: UserId로 파이어베이스에 유저 확인
    func fetchUser(at userId: String) async throws -> QueryDocumentSnapshot? {
        let querySnapshot = try await db.collection("USERS")
            .whereField("user_id", isEqualTo: userId)
            .getDocuments()
        
        return querySnapshot.documents.first
    }
    
    // MARK: USERS 하위 Collection 찾기
    func fetchCollection(document: QueryDocumentSnapshot, collectionName: String) -> CollectionReference {
        return document.reference.collection(collectionName)
    }
    
    // MARK: 도큐먼트 삭제
    func fetchDeleteDocument(at path: String?, withId id: String?, collection: CollectionReference?, document: QueryDocumentSnapshot?) async throws {
        if let collection = collection {
            try await collection.document(document?.documentID ?? "").delete()
        } else {
            try await db.collection(path ?? "").document(id ?? "").delete()
        }
    }

    // MARK: 경쟁 뷰 상태 및 목표 거리 체크
    func fetchCompetitionSnapshot(collection: CollectionReference, competitionStatus: Bool, goalDistance: Double) async throws -> QuerySnapshot {
        return try await collection
            .whereField("record_competetion_status", isEqualTo: competitionStatus)
            .whereField("record_target_distance", isEqualTo: goalDistance)
            .getDocuments()
    }

    // MARK: 경쟁, 기록 업데이트
    func fetchRecord(collection: CollectionReference, timer: String, cadence: Double, speed: Double, distance: Double, calorie: Double, startTime: Date, endTime: Date, date: Date, competetionStatus: Bool, tagetDistance: Double?) async throws {
        
        try await collection.addDocument(data: [
            "record_timer": timer,
            "record_cadence": cadence,
            "record_speed": speed,
            "record_distance": distance,
            "record_calories": calorie,
            "record_start_time": startTime,
            "record_end_time": endTime,
            "record_date": startTime,
            "record_competetion_status": competetionStatus,
            "record_target_distance": tagetDistance ?? 0
        ])

    }
}
