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

    // MARK: - Other properties
    private(set) var isRecording: Bool = false {
        didSet {
            onRecordingStatusChanged?(isRecording)
        }
    }
    var recordedTime: TimeInterval = 0.0
    var onTimerUpdated: ((String) -> Void)?
    var onRecordingStatusChanged: ((Bool) -> Void)?
    weak var delegate: RecordViewModelDelegate?
    
    private var timer: Timer?

    var isUserLoggedIn: Bool {
        return UserService.shared.loginStatus == .appleLogin
    }

    // MARK: - Summary Data
    struct SummaryData {
        let recordedTime: String
        let cadence: Double
        let speed: Double
        let distance: Double
        let calorie: Double
        let startTime: Date
        let endTime: Date
    }

    // MARK: - BluetoothManagerDelegate Methods
    func didUpdateCadence(_ cadence: Double) {
        DispatchQueue.main.async {
            self.cadence = cadence
            self.isBluetoothConnected = true
        }
    }

    func didUpdateSpeed(_ speed: Double) {
        DispatchQueue.main.async {
            self.speed = speed
            self.isBluetoothConnected = true
        }
    }

    func didUpdateDistance(_ distance: Double) {
        DispatchQueue.main.async {
            self.distance = distance
            self.isBluetoothConnected = true
        }
    }

    func didUpdateCalories(_ calories: Double) {
        DispatchQueue.main.async {
            self.calorie = calories
            self.isBluetoothConnected = true
        }
    }

    // MARK: - Recording Methods
    func startRecording() {
        isRecording = true
        isPaused = false
        print("start pushed")
        startTime = Date()
        startTimer()
        print("start time: \(String(describing: startTime))")
        delegate?.didStartRecording()
    }

    func resetRecording() {
        isRecording = false
        isPaused = false
        print("record reset")
        stopTimer()
        elapsedTime = 0.0
        recordedTime = 0.0
        startTime = nil
        endTime = nil
        onTimerUpdated?(formatTime(elapsedTime))
        delegate?.didResetRecording()
    }

    func finishRecording() {
        isRecording = false
        print("finish pushed")
        stopTimer()
        recordedTime = elapsedTime
        endTime = Date()
        print("end time: \(String(describing: endTime))")
        delegate?.didFinishRecording()
    }

    func pauseRecording() {
        isRecording = false
        isPaused = true
        print("pause pushed")
        stopTimer()
        delegate?.didPauseRecording()
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
}

protocol RecordViewModelDelegate: AnyObject {
    func didFinishRecording()
    func didPauseRecording()
    func didStartRecording()
    func didResetRecording()
}
