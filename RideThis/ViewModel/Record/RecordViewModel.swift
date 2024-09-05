import Foundation
import Combine

class RecordViewModel: BluetoothManagerDelegate {
    // MARK: - Published properties
    @Published var isBluetoothConnected: Bool = false
    @Published var isPaused: Bool = false
    @Published var cadence: Double = 0
    @Published var speed: Double = 0
    @Published var distance: Double = 0
    @Published var calorie: Double = 0
    @Published var elapsedTime: TimeInterval = 0.0
    @Published var startTime: Date?
    @Published var endTime: Date?
    @Published private(set) var isMeasuring: Bool = false
    
    private var timer: Timer?
    weak var delegate: RecordViewModelDelegate?
    var recordedTime: TimeInterval = 0.0
    var onTimerUpdated: ((String) -> Void)?
    var onRecordingStatusChanged: ((Bool) -> Void)?
    let firebaseService = FireBaseService()
    // MARK: 블루투스 연결을 하기위해 device정보가 필요하기 때문에 RecordViewModel이 init()할 때 fetchDeviceData()를 통해 기기를 먼저 불러오고 RecordView가 viewWillAppear() 시점에 블루투스 연결(updateBTManager())을 시킴(이게 맞는지는 다같이 얘기할 필요..)
    // MARK: 또 기기 삭제 및 추가 후 다시 기록탭에 들어왔을 때 등록된 기기가 있는지 확인하기 위해 RecordView의 viewWillAppear() 시점마다 deviceModel을 업데이트함
    var deviceModel = RecordDeviceModel(device_firmware_version: "", device_name: "", device_registration_status: false, device_serial_number: "", device_wheel_circumference: 0)
    var btManager: BluetoothManager?
    
    init() {
        Task {
            deviceModel = try await self.fetchDeviceData()
        }
    }
    
    func fetchDeviceData() async throws -> RecordDeviceModel {
        let userDocument = try await firebaseService.fetchUser(at: UserService.shared.combineUser?.user_id ?? "", userType: false)
        
        if case .userSnapshot(let queryDocumentSnapshot) = userDocument {
            guard let doc = queryDocumentSnapshot else {
                throw NSError(domain: "RecordCoordinator", code: 1, userInfo: [NSLocalizedDescriptionKey: "User가 존재하지 않습니다."])
            }
            let recordsCollection = firebaseService.fetchCollection(document: doc, collectionName: "DEVICES")
            let deviceDocuments = try await recordsCollection.getDocuments()
            
            if let activeDeviceDocument = deviceDocuments.documents.first(where: { document in
                return document["device_registration_status"] as? Bool == true
            }) {
                return RecordDeviceModel(
                    device_firmware_version: activeDeviceDocument["device_firmware_version"] as? String ?? "",
                    device_name: activeDeviceDocument["device_name"] as? String ?? "",
                    device_registration_status: activeDeviceDocument["device_registration_status"] as? Bool ?? false,
                    device_serial_number: activeDeviceDocument["device_serial_number"] as? String ?? "",
                    device_wheel_circumference: activeDeviceDocument["device_wheel_circumference"] as? Double ?? 0
                )
            } else {
                throw NSError(domain: "RecordCoordinator", code: 2, userInfo: [NSLocalizedDescriptionKey: "등록된 DEVICES가 없습니다."])
            }
        } else {
            throw NSError(domain: "RecordCoordinator", code: 3, userInfo: [NSLocalizedDescriptionKey: "FIREBASE 통신 오류"])
        }
    }
    
    func updateBTManager() {
        self.btManager = BluetoothManager(targetDeviceName: deviceModel.device_name,
                                          userWeight: Double(UserService.shared.combineUser?.user_weight ?? -1),
                                          wheelCircumference: deviceModel.device_wheel_circumference)
        self.btManager?.connect()
    }
    
    func checkBluetoothConnection() -> Bool {
        guard let btManager = self.btManager else { return false }
        return btManager.isConnected()
    }
    
    func disConnectBT() {
        self.btManager?.disConnect()
        self.btManager = nil
    }
    
    // MARK: - Other properties
    private(set) var isRecording: Bool = false {
        didSet {
            onRecordingStatusChanged?(isRecording)
        }
    }
    
    var isUserLoggedIn: Bool {
        return UserService.shared.loginStatus == .appleLogin
    }
    
    // MARK: - BluetoothManagerDelegate Methods
    func didUpdateCadence(_ cadence: Double) {
        guard isMeasuring else { return }
        DispatchQueue.main.async {
            self.cadence = cadence
            self.isBluetoothConnected = true
        }
    }
    
    func didUpdateSpeed(_ speed: Double) {
        guard isMeasuring else { return }
        DispatchQueue.main.async {
            self.speed = speed
            self.isBluetoothConnected = true
        }
    }
    
    func didUpdateDistance(_ distance: Double) {
        guard isMeasuring else { return }
        DispatchQueue.main.async {
            self.distance = distance
            self.isBluetoothConnected = true
        }
    }
    
    func didUpdateCalories(_ calories: Double) {
        guard isMeasuring else { return }
        DispatchQueue.main.async {
            self.calorie = calories
            self.isBluetoothConnected = true
        }
    }
    
    // MARK: - Recording Methods
    func startRecording() {
        isRecording = true
        isMeasuring = true
        isPaused = false
        print("start pushed")
        startTime = Date()
        startTimer()
        print("start time: \(String(describing: startTime))")
        delegate?.didStartRecording()
    }
    
    func resetRecording() {
        isRecording = false
        isMeasuring = false
        isPaused = false
        print("record reset")
        stopTimer()
        elapsedTime = 0.0
        recordedTime = 0.0
        startTime = nil
        endTime = nil
        cadence = 0
        speed = 0
        distance = 0
        calorie = 0
        onTimerUpdated?(formatTime(elapsedTime))
        delegate?.didResetRecording()
        btManager?.resetTotalCalories()
    }
    
    func finishRecording() {
        isRecording = false
        isMeasuring = false
        print("finish pushed")
        stopTimer()
        recordedTime = elapsedTime
        endTime = Date()
        print("end time: \(String(describing: endTime))")
        self.btManager?.disConnect()
        delegate?.didFinishRecording()
        btManager?.resetTotalCalories()
    }
    
    func pauseRecording() {
        isRecording = false
        isMeasuring = false
        isPaused = true
        print("pause pushed")
        stopTimer()
        delegate?.didPauseRecording()
    }
    
    func resumeRecording() {
        isRecording = true
        isMeasuring = true
        isPaused = false
        startTimer()
        delegate?.didStartRecording()
    }
    
    // MARK: - Timer Methods
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
    
    func updateTimerDisplay() -> String {
        return formatTime(elapsedTime)
    }
    
    // MARK: - Summary Data Method
    func getSummaryData() -> SummaryData {
        return SummaryData(
            recordedTime: formatTime(recordedTime),
            cadence: cadence,
            speed: speed,
            distance: distance,
            calorie: calorie,
            startTime: startTime ?? Date(),
            endTime: endTime ?? Date()
        )
    }
    
    func bluetoothDidConnect() {
    }
}

protocol RecordViewModelDelegate: AnyObject {
    func didFinishRecording()
    func didPauseRecording()
    func didStartRecording()
    func didResetRecording()
}
