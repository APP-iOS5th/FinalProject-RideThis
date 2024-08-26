import Foundation
import FirebaseFirestore
import FirebaseStorage

class FireBaseService {
    
    enum ReturnUserType {
        case user(User?)
        case userSnapshot(QueryDocumentSnapshot?)
    }
    
    private let db = Firestore.firestore()
    
    // MARK: UserId로 파이어베이스에 유저 확인
    func fetchUser(at userId: String, userType: Bool) async throws -> ReturnUserType {
        let querySnapshot = try await db.collection("USERS")
            .whereField("user_id", isEqualTo: userId)
            .getDocuments()
        
        if userType {
            let foundUser = try querySnapshot.documents.first?.data(as: User.self)
            
            return .user(foundUser)
        } else {
            return .userSnapshot(querySnapshot.documents.first)
        }
    }
    
    // MARK: UserId배열로 유저 확인
    func fetchUsers(by userIds: [String]) async throws -> [User] {
        var returnUserData: [User] = []
        
        for id in userIds {
            do {
                if case .user(let userData) = try await fetchUser(at: id, userType: true) {
                    guard let user = userData else { continue }
                    returnUserData.append(user)
                }
            } catch {
                print(error)
            }
        }
        
        return returnUserData
    }
    
    // MARK: 검색한 text로 이메일, 닉네임이 포함되는 유저 검색
    func findUser(text: String) async -> [User] {
        var allUsers: [User] = []
        do {
            let allUsersSnapshot = try await self.fetchAllUsers()
            for snapshot in allUsersSnapshot {
                let userData = try snapshot.data(as: User.self)
                if !userData.user_email.contains(text) && !userData.user_nickname.contains(text) {
                    continue
                }
                allUsers.append(userData)
            }
        } catch {
            print(error)
        }
        return allUsers
    }
    
    // MARK: USERS 컬렉션의 모든 데이터 가져오기
    func fetchAllUsers() async throws -> [QueryDocumentSnapshot] {
        let querySnapshot = try await db.collection("USERS").getDocuments()
        return querySnapshot.documents
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
    
    // MARK: 각 USERS 문서의 RECORDS 컬렉션의 모든 데이터 가져오기
    func fetchAllRecordsForUsers(_ userSnapshots: [QueryDocumentSnapshot]) async throws -> [RecordModel] {
        var allRecordData: [RecordModel] = []

        for userSnapshot in userSnapshots {
            let userNickname = userSnapshot["user_nickname"] as? String ?? ""
            let userId = userSnapshot["user_id"] as? String ?? ""
            let recordsCollectionRef = userSnapshot.reference.collection("RECORDS")
            let recordsQuerySnapshot = try await recordsCollectionRef.getDocuments()

            for recordSnapshot in recordsQuerySnapshot.documents {
                let recordData = RecordModel(
                    record_timer: recordSnapshot["record_timer"] as? String ?? "",
                    record_cadence: recordSnapshot["record_cadence"] as? Double ?? 0.0,
                    record_speed: recordSnapshot["record_speed"] as? Double ?? 0.0,
                    record_distance: recordSnapshot["record_distance"] as? Double ?? 0.0,
                    record_calories: recordSnapshot["record_calories"] as? Double ?? 0.0,
                    record_start_time: (recordSnapshot["record_start_time"] as? Timestamp)?.dateValue(),
                    record_end_time: (recordSnapshot["record_end_time"] as? Timestamp)?.dateValue(),
                    record_data: (recordSnapshot["record_date"] as? Timestamp)?.dateValue(),
                    record_competetion_status: recordSnapshot["record_competetion_status"] as? Bool ?? false,
                    record_target_distance: recordSnapshot["record_target_distance"] as? Int ?? 0,
                    user_nickname: userNickname,
                    user_id: userId
                )
                allRecordData.append(recordData)
            }
        }

        return allRecordData
    }
    
    func findRecordsBy(userId: String) async -> [RecordModel] {
        var records: [RecordModel] = []
        do {
            if case .userSnapshot(let userSnapshot) = try await fetchUser(at: userId, userType: false) {
                guard let snapshot = userSnapshot else { return [] }
                let recordCollection = snapshot.reference.collection("RECORDS")
                let recordSnapshots = try await recordCollection.getDocuments()
                let userNickname = snapshot["user_nickname"] as? String ?? ""
                let userId = snapshot["user_id"] as? String ?? ""
                
                for recordSnapshot in recordSnapshots.documents {
                    let recordData = RecordModel(
                        record_timer: recordSnapshot["record_timer"] as? String ?? "",
                        record_cadence: recordSnapshot["record_cadence"] as? Double ?? 0.0,
                        record_speed: recordSnapshot["record_speed"] as? Double ?? 0.0,
                        record_distance: recordSnapshot["record_distance"] as? Double ?? 0.0,
                        record_calories: recordSnapshot["record_calories"] as? Double ?? 0.0,
                        record_start_time: (recordSnapshot["record_start_time"] as? Timestamp)?.dateValue(),
                        record_end_time: (recordSnapshot["record_end_time"] as? Timestamp)?.dateValue(),
                        record_data: (recordSnapshot["record_date"] as? Timestamp)?.dateValue(),
                        record_competetion_status: recordSnapshot["record_competetion_status"] as? Bool ?? false,
                        record_target_distance: recordSnapshot["record_target_distance"] as? Int ?? 0,
                        user_nickname: userNickname,
                        user_id: userId
                    )
                    records.append(recordData)
                }
            }
        } catch {
            print(error)
        }
        return records
    }
    
    // MARK: Following목록 가져오기
    func fetchUserFollowing(userId: String) async throws -> [String] {
        if case .userSnapshot(let userSnapshot) = try await fetchUser(at: userId, userType: false) {
            guard let userFollowing = userSnapshot?.get("user_following") as? [String] else {
                return []
            }
            return userFollowing
        }
        return []
    }
    
    // MARK: 유저 정보 수정
    func updateUserInfo(updated user: User, update now: Bool) {
        let userInfo = db.collection("USERS").document(user.user_id)
        let updateData: [String: Any] = [
            "user_account_public": user.user_account_public,
            "user_email": user.user_email,
            "user_follower": user.user_follower,
            "user_following": user.user_following,
            "user_id": user.user_id,
            "user_image": user.user_image ?? "",
            "user_nickname": user.user_nickname,
            "user_tall": user.user_tall ?? "",
            "user_weight": user.user_weight
        ]
        
        userInfo.updateData(updateData) { error in
            if let error = error {
                print("Error updating document: \(error)")
            }
        }
        
        if now {
            UserService.shared.combineUser = user
        }
    }
    
    func saveImage(image: UIImage, userId: String, completion: @escaping (URL) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("이미지 변환 오류")
            return
        }
        
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("userProfileImage/\(userId).jpg")
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("이미지 업로드 실패: \(error.localizedDescription)")
                return
            }

            // 업로드 완료 후 메타데이터 확인
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("이미지 다운로드 URL 가져오기 실패: \(error.localizedDescription)")
                    return
                }

                if let downloadURL = url {
                    completion(downloadURL)
                }
            }
        }

        // 업로드 진행 상태를 모니터링할 수 있습니다.
        /*
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("업로드 진행률: \(percentComplete)%")
        }
        */
    }
    
    func loadImage(userId: String, loadCompletion: @escaping (URL?) -> Void) {
        // Firebase Storage 참조
        let storageRef = Storage.storage().reference()

        // 다운로드할 이미지의 경로 설정 (예: "images/example.jpg")
        let imageRef = storageRef.child("userProfileImage/\(userId).jpg")

        // 이미지의 다운로드 URL 가져오기
        imageRef.downloadURL { url, error in
            if let error = error {
                print("이미지 다운로드 URL 가져오기 실패: \(error.localizedDescription)")
                return
            }

            loadCompletion(url)
        }
    }
}
