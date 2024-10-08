import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Alamofire

class FireBaseService {
    
    enum ReturnUserType {
        case user(User?)
        case userSnapshot(QueryDocumentSnapshot?)
    }
    
    private let db = Firestore.firestore()
    
    func createUser(userInfo: [String: Any], createComplete: @escaping (User) -> Void) {
        let usersCollection = db.collection("USERS")
        
        usersCollection.document(userInfo["user_id"] as! String).setData(userInfo) { error in
            if let error = error {
                print("문서 생성 실패: \(error.localizedDescription)")
            } else {
                print("문서 생성 및 필드 추가 성공")
                
                let createdUser = User(user_id: userInfo["user_id"] as! String,
                                       user_image: userInfo["user_image"] as? String,
                                       user_email: userInfo["user_email"] as! String,
                                       user_nickname: userInfo["user_nickname"] as! String,
                                       user_weight: userInfo["user_weight"] as! Int,
                                       user_tall: userInfo["user_tall"] as! Int,
                                       user_following: userInfo["user_following"] as! [String],
                                       user_follower: userInfo["user_follower"] as! [String],
                                       user_account_public: false,
                                       user_alarm_status: AlarmManager.shared.isUse ?? true)
                
                createComplete(createdUser)
            }
        }
    }
    
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
    
    // MARK: 검색한 text로 닉네임이 포함되는 유저 검색
    func findUser(text: String) async -> [User] {
        var allUsers: [User] = []
        do {
            let allUsersSnapshot = try await self.fetchAllUsers()
            for snapshot in allUsersSnapshot {
                let userData = try snapshot.data(as: User.self)
                if  !userData.user_nickname.contains(text) {
                    continue
                }
                allUsers.append(userData)
            }
        } catch {
            print(error)
        }
        return allUsers
    }
    
    // MARK: 서버에 동일한 닉네임이 있는지 검사
    func findUser(nickName: String) async -> Int {
        do {
            let querySnapshot = try await db.collection("USERS")
                .whereField("user_nickname", isEqualTo: nickName)
                .getDocuments()
            
            return querySnapshot.count
        } catch {
            print("error \(#function)")
        }
        return 0
    }
    
    func findUserCountBy(email: String) async -> Int {
        do {
            let querySnapshot = try await db.collection("USERS")
                .whereField("user_email", isEqualTo: email)
                .getDocuments()
            
            return querySnapshot.count
        } catch {
            print("error \(#function)")
        }
        return 0
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
            "user_alarm_status": user.user_alarm_status,
            "user_email": user.user_email,
            "user_follower": user.user_follower,
            "user_following": user.user_following,
            "user_id": user.user_id,
            "user_image": user.user_image ?? "",
            "user_nickname": user.user_nickname,
            "user_tall": user.user_tall,
            "user_weight": user.user_weight
        ]
        
        userInfo.updateData(updateData) { error in
            if let error = error {
                print("Error updating document: \(error)")
            }
        }
        
        if now {
            UserService.shared.signedUser = user
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
    
    /// 사용자 정보 삭제
    ///  - Parameters:
    ///   - userId: 사용자 UID
    func deleteUser(userId: String) {
        
        DispatchQueue.global().async {
            ["ALARMS", "DEVICES", "RECORDS"].forEach { collection in
                self.db.collection("USERS").document(userId).collection(collection).getDocuments { snapshot, err in
                    guard let snapshot = snapshot else { return }
                    if snapshot.documents.count > 0 {
                        snapshot.documents.forEach{
                            $0.reference.delete() { error in
                                if let error = error {
                                    print(error)
                                } else {
                                    print("\(collection) 삭제 완료!")
                                }
                            }
                        }
                    }
                }
            }
        }
        
        db.collection("USERS").document(userId).delete() { error in
            if let error = error {
                print(error)
            } else {
                print("사용자 삭제 완료!")
            }
        }
        
        let storage = Storage.storage()
        let imagePath = "userProfileImage/\(userId).jpg"
        let imageRef = storage.reference(withPath: imagePath)
        
        imageRef.delete { error in
            if let error = error {
                print("error in deleteUser >> \(error.localizedDescription)")
            } else {
                print("image delete complete")
            }
        }
        
        Task {
            let followerData = try await db.collection("USERS")
                .whereField("user_follower", arrayContains: userId)
                .getDocuments()
                .documents
                .map{ try $0.data(as: User.self) }
            
            for follow in followerData {
                if let idx = follow.user_follower.firstIndex(of: userId) {
                    follow.user_follower.remove(at: idx)
                    self.updateUserInfo(updated: follow, update: false)
                }
            }
            
            let followingData = try await db.collection("USERS")
                .whereField("user_following", arrayContains: userId)
                .getDocuments()
                .documents
                .map{ try $0.data(as: User.self) }
            
            for follow in followingData {
                if let idx = follow.user_following.firstIndex(of: userId) {
                    follow.user_following.remove(at: idx)
                    self.updateUserInfo(updated: follow, update: false)
                }
            }
        }
        if let currentUser = Auth.auth().currentUser {
            currentUser.delete() { error in
                if let error = error {
                    print("error while delete auth user >> \(error.localizedDescription)")
                } else {
                    print("complete to delete user")
                }
            }
        }
        UserService.shared.logout()
    }
    
    // MARK: - 디바이스 관리
        
    /// 사용자의 디바이스 정보 추가 또는 업데이트
    /// - Parameters:
    ///   - device: 디바이스 객체
    ///   - userId: 유저 ID
    func upsertDeviceInFirebase(_ device: Device, for userId: String) async throws {
        let userRef = db.collection("USERS").document(userId)
        let deviceRef = userRef.collection("DEVICES").document(device.name)
        
        try await deviceRef.setData([
            "device_name": device.name,
            "device_serial_number": device.serialNumber,
            "device_firmware_version": device.firmwareVersion,
            "device_registration_status": device.registrationStatus,
            "device_wheel_circumference": device.wheelCircumference
        ], merge: true)
    }
    
    /// 사용자의 모든 디바이스 상태 업데이트
    /// - Parameters:
    ///   - userId: 유저 ID
    ///   - exceptDevice: 제외할 디바이스 이름
    func updateAllDevicesStatus(for userId: String, exceptDevice: String) async throws {
        let userRef = db.collection("USERS").document(userId)
        let devicesRef = userRef.collection("DEVICES")
        
        let snapshot = try await devicesRef.getDocuments()
        for doc in snapshot.documents {
            if doc.documentID != exceptDevice {
                try await doc.reference.updateData([
                    "device_registration_status": false
                ])
            }
        }
    }
    
    func saveNoUserRecordData(user: User, completion: @escaping () -> Void) async {
        guard let device = DataPersistenceService.shared.loadUnkownedDevices(),
              let record = DataPersistenceService.shared.getUnloginUserSummary() else { return }
        
        do {
            if let registeredDevice = try await getRegisteredDevice(for: user.user_id) {
                var updatedDevice = registeredDevice
                updatedDevice.registrationStatus = false
                
                try await upsertDeviceInFirebase(updatedDevice, for: user.user_id)
            }
            
            try await updateAllDevicesStatus(for: user.user_id, exceptDevice: device.name)
            
            try await upsertDeviceInFirebase(device, for: user.user_id)
            
            if case .userSnapshot(let userSnapshot) = try await self.fetchUser(at: user.user_id, userType: false) {
                guard let doc = userSnapshot else {
                    print("유저를 찾을 수 없습니다.")
                    return
                }
                let recordsCollection = self.fetchCollection(document: doc, collectionName: "RECORDS")
                try await fetchRecord(collection: recordsCollection,
                                      timer: record.recordedTime,
                                      cadence: record.cadence,
                                      speed: record.speed,
                                      distance: record.distance,
                                      calorie: record.calorie,
                                      startTime: record.startTime,
                                      endTime: record.endTime,
                                      date: Date(),
                                      competetionStatus: false,
                                      tagetDistance: nil)
                
                completion()
            }
        } catch {
            print(error)
        }
    }
    
    /// 사용자의 등록된 디바이스 가져오기
    /// - Parameter userId: 유저 ID
    /// - Returns: 등록된 Device 객체
    func getRegisteredDevice(for userId: String) async throws -> Device? {
        let userRef = db.collection("USERS").document(userId)
        let devicesRef = userRef.collection("DEVICES")
        
        let snapshot = try await devicesRef.whereField("device_registration_status", isEqualTo: true).getDocuments()
        
        if let doc = snapshot.documents.first {
            return Device(
                name: doc["device_name"] as? String ?? "",
                serialNumber: doc["device_serial_number"] as? String ?? "",
                firmwareVersion: doc["device_firmware_version"] as? String ?? "",
                registrationStatus: doc["device_registration_status"] as? Bool ?? false,
                wheelCircumference: doc["device_wheel_circumference"] as? Int ?? 0
            )
        }
        return nil
    }
    
    /// 디바이스의 바퀴 둘레 정보 업데이트
    /// - Parameters:
    ///   - userId: 유저 ID
    ///   - deviceName: 디바이스 이름
    ///   - circumference: 업데이트할 바퀴 둘레 값
    func updateDeviceWheelCircumference(userId: String, deviceName: String, circumference: Int) async throws {
        let userRef = db.collection("USERS").document(userId)
        let deviceRef = userRef.collection("DEVICES").document(deviceName)
        
        try await deviceRef.updateData([
            "device_wheel_circumference": circumference
        ])
    }
    
    /// 디바이스 삭제
    /// - Parameters:
    ///   - userId: 유저 ID
    ///   - deviceName: 삭제할 디바이스 이름
    func deleteDevice(userId: String, deviceName: String) async throws {
        let userRef = db.collection("USERS").document(userId)
        let deviceRef = userRef.collection("DEVICES").document(deviceName)
        
        try await deviceRef.delete()
    }

    // MARK: FCM 토큰 업데이트
    func updateUserFCMToken(userId: String, fcmToken: String) async throws {
        let userRef = db.collection("USERS").document(userId)
        
        try await userRef.updateData([
            "user_fcmtoken": fcmToken
        ])
    }
    
    // MARK: Message Token
    func fetchAccessToken(completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://ride-this-server.vercel.app/token")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching access token: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let accessToken = json["accessToken"] as? String {
                    completion(accessToken)
                } else {
                    print("Invalid response data")
                    completion(nil)
                }
            } catch {
                print("Error parsing JSON: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func fetchFCM(signedUser: User, cellUser: User, alarmCase: AlarmCase) {
        db.collection("USERS").document(cellUser.user_id).getDocument { document, error in
            if let document = document, document.exists {
                if let userFCMToken = document.data()?["user_fcmtoken"] as? String {
                    // FCM 메시지 전송
                    self.sendFCM(to: userFCMToken, signedUser: signedUser, cellUser: cellUser, alarmCase: alarmCase)
                } else {
                    print("user_fcmtoken 필드가 없습니다.")
                }
            } else {
                print("해당 유저를 찾을 수 없습니다: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func sendFCM(to userFCMToken: String, signedUser: User, cellUser: User, alarmCase: AlarmCase) {
        fetchAccessToken { accessToken in
            guard let accessToken = accessToken else {
                print("Failed to obtain access token")
                return
            }
            
            guard let projectID = FirebaseApp.app()?.options.projectID else {
                print("Failed to get Firebase project ID")
                return
            }

            let urlString = "https://fcm.googleapis.com/v1/projects/\(projectID)/messages:send"
            
            let messageTitle = alarmCase.rawValue
            let messageBody = "\(signedUser.user_nickname)님이 팔로우했습니다."

            let message: [String: Any] = [
                "message": [
                    "token": userFCMToken,
                    "notification": [
                        "title": messageTitle,
                        "body": messageBody
                    ]
                ]
            ]

            AF.request(urlString, method: .post, parameters: message, encoding: JSONEncoding.default, headers: [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]).response { response in
                if let error = response.error {
                    print("FCM 통신 오류: \(error)")
                } else if let httpResponse = response.response, httpResponse.statusCode != 200 {
                    if let data = response.data, let _ = String(data: data, encoding: .utf8) {
                        print("FCM Status Error: \(httpResponse.statusCode)")
                    } else {
                        print("FCM notification failed with status code: \(httpResponse.statusCode), but no response body was returned.")
                    }
                } else {
                    print("FCM 알람 성공")
                    
                    // Firestore에 ALAMS 컬렉션에 데이터 추가
                    self.addAlarms(signedUser: signedUser, cellUser: cellUser, title: messageTitle, body: messageBody)
                }
            }
        }
    }

    func addAlarms(signedUser: User, cellUser: User, title: String, body: String) {
        let db = Firestore.firestore()
        let alamsCollection = db.collection("USERS").document(cellUser.user_id).collection("ALARMS")
        
        let alamData: [String: Any] = [
            "alarm_category": title,
            "alarm_date": Timestamp(date: Date()),
            "alarm_body": body,
            "alarm_status": false,
            "alarm_user": signedUser.user_id
        ]
        
        alamsCollection.addDocument(data: alamData) { error in
            if let error = error {
                print("Error adding notification to Firestore: \(error)")
            } else {
                print("Notification added to Firestore successfully.")
            }
        }
    }
    
    func updateAlarm(user: User, alarm: AlarmModel) async {
        do {
            let alarmDocs = try await db.collection("USERS").document(user.user_id)
                .collection("ALARMS")
                .whereField("alarm_body", isEqualTo: alarm.alarm_body)
                .whereField("alarm_category", isEqualTo: alarm.alarm_category)
                .whereField("alarm_status", isEqualTo: false)
                .getDocuments()
                .documents
            
            if let searchedAlarm = alarmDocs.first {
                try await searchedAlarm.reference.updateData([
                    "alarm_status": true
                ])
            }
        } catch {
            print(error)
        }
    }
    
    func fetchAlarms(userId: String) async -> [AlarmModel] {
        do {
            if case .userSnapshot(let userSnapshot) = try await self.fetchUser(at: userId, userType: false), let snapShot = userSnapshot {
                var alarms: [AlarmModel] = []
                
                for doc in try await self.fetchCollection(document: snapShot, collectionName: "ALARMS").getDocuments().documents {
                    alarms.append(try doc.data(as: AlarmModel.self))
                }
                
                return alarms.sorted(by: { $0.alarm_date > $1.alarm_date })
            }
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
}
