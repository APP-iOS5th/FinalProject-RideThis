import Foundation
import Combine

class RecordViewModel: BluetoothManagerDelegate {
    
    // MARK: - 기록 화면 동작
    
    var bluetoothManager: BluetoothManager!
    var deviceInfo: RecordDeviceModel = RecordDeviceModel(device_firmware_version: "test123", device_name: "test", device_registration_status: false, device_serial_number: "13", device_wheel_circumference: 123)
    
    let isLogin = false
    @Published var isBluetoothConnected: Bool = false
    
    func initializeBluetoothManager() {
        fetchDeviceData()
    }
    
    // 타이머
    var recordedTime: TimeInterval = 0.0
    
    // 타이머 업데이트 클로저
    var onTimerUpdated: ((String) -> Void)?
    
    private var timer: Timer?
    @Published var elapsedTime: TimeInterval = 0.0
    
    // 상태 변경을 알리는 클로저
    var onRecordingStatusChanged: ((Bool) -> Void)?
    
    private(set) var isRecording: Bool = false {
        didSet {
            // 상태 변경 시 클로저 호출
            onRecordingStatusChanged?(isRecording)
        }
    }
    
    // 기록 종료 시 화면 전환을 위한 클로저
    var onFinishRecording: (() -> Void)?
    
    // 기록 시작 시간 & 종료 시간 저장
    @Published var startTime: Date?
    @Published var endTime: Date?
    
    func startRecording() {
        // 기록 시작
        isRecording = true
        print("start pushed")
        startTime = Date()
        startTimer()
        print("start time: \(String(describing: startTime))")
    }
    
    func resetRecording() {
        // 기록 시작 후 누르면 리셋하고 초기상태
        isRecording = false
        print("reset pushed")
        stopTimer()
        elapsedTime = 0.0
        recordedTime = 0.0
        startTime = nil
        endTime = nil
        onTimerUpdated?(formatTime(elapsedTime))
    }
    
    func finishRecording() {
        // 누르기 전까지의 기록 저장 후 요약페이지 이동
        isRecording = false
        print("finish pushed")
        stopTimer()
        recordedTime = elapsedTime
        endTime = Date()
        print("end time: \(String(describing: endTime))")
        onFinishRecording?()
    }
    
    func pauseRecording() {
        // 기록 일시정지
        isRecording = false
        print("pause pushed")
        stopTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
            self.onTimerUpdated?(self.formatTime(self.elapsedTime))
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - 기록 요약 화면 버튼 동작
    @Published var cadence: Double = 0
    @Published var speed: Double = 0
    @Published var distance: Double = 0
    @Published var calorie: Double = 0
    @Published var competitionStatus: Bool = false
    @Published var targetDistance: Double? = nil
    
    private let firebaseService = FireBaseService()
    
    // 저장 또는 취소 시 화면 전환을 위한 클로저
    var onCancelSaveRecording: (() -> Void)?
    var onSaveRecording: (() -> Void)?
    
    func cancelSaveRecording() {
        print("save cancel pushed")
        // 기록 요약 화면에서 취소 버튼 누르면 이전 화면(기록 화면)으로 이동
        onCancelSaveRecording?()
    }
    
    func saveRecording() async {
        print("save pushed")
        
        // 기록이 없는 상태에서는 저장을 시도하지 않도록 확인
        guard let startTime = startTime else {
            print("기록이 시작되지 않았습니다.")
            print("start time: \(String(describing: startTime))")
            return
        }
        
        guard let endTime = endTime else {
            print("기록이 종료되지 않았습니다.")
            return
        }
        
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
                
                try await firebaseService.fetchRecord(collection: recordsCollection, timer: formatTime(recordedTime), cadence: cadence, speed: speed, distance: distance, calorie: calorie, startTime: startTime, endTime: endTime, date: Date(), competetionStatus: false, tagetDistance: nil)
                
                print("기록 추가")
                
                await MainActor.run {
                    self.onSaveRecording?()
                }
            }
        } catch {
            print("기록 처리 에러: \(error.localizedDescription)")
        }
    }
    
    // MARK: Fetch User Device Data
    func fetchDeviceData() {
        Task {
            do {
                let userDocument = try await firebaseService.fetchUser(at: UserService.shared.combineUser?.user_id ?? "", userType: false)
                
                if case .userSnapshot(let queryDocumentSnapshot) = userDocument {
                    guard let doc = queryDocumentSnapshot else {
                        print("User가 존재하지 않습니다.")
                        return
                    }
                    let recordsCollection = firebaseService.fetchCollection(document: doc, collectionName: "DEVICE")
                    let deviceDocuments = try await recordsCollection.getDocuments()
                    
                    if let activeDeviceDocument = deviceDocuments.documents.first(where: { document in
                        return document["device_registration_status"] as? Bool == true
                    }) {
                        deviceInfo = RecordDeviceModel(
                            device_firmware_version: activeDeviceDocument["device_firmware_version"] as? String ?? "",
                            device_name: activeDeviceDocument["device_name"] as? String ?? "",
                            device_registration_status: activeDeviceDocument["device_registration_status"] as? Bool ?? false,
                            device_serial_number: activeDeviceDocument["device_serial_number"] as? String ?? "",
                            device_wheel_circumference: activeDeviceDocument["device_wheel_circumference"] as? Double ?? 0
                        )
                        
                        DispatchQueue.main.async {
                            self.bluetoothManager = BluetoothManager(
                                targetDeviceName: self.deviceInfo.device_name,
                                userWeight: Double(UserService.shared.combineUser?.user_weight ?? -1),
                                wheelCircumference: self.deviceInfo.device_wheel_circumference
                            )
                            self.bluetoothManager.delegate = self
                            self.bluetoothManager.connect()
                        }
                    } else {
                        print("등록된 DEVICE가 없습니다.")
                    }
                }
            } catch {
                print("FIREBASE 통신 오류: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - BluetoothManagerDelegate Methods
    func didUpdateCadence(_ cadence: Double) {
        DispatchQueue.main.async {
            self.cadence = cadence
        }
    }
    
    func didUpdateSpeed(_ speed: Double) {
        DispatchQueue.main.async {
            self.speed = speed
        }
    }
    
    func didUpdateDistance(_ distance: Double) {
        DispatchQueue.main.async {
            self.distance = distance
        }
    }
    
    func didUpdateCalories(_ calories: Double) {
        DispatchQueue.main.async {
            self.calorie = calories
        }
    }
    
    func didConnectBluetooth() {
        isBluetoothConnected = true
    }
    
    func didDisconnectBluetooth() {
        isBluetoothConnected = false
    }
}
