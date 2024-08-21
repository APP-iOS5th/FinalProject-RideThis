import Foundation
import Combine

class RecordViewModel: ObservableObject {
    // MARK: - 기록 화면 동작
    
    let isLogin = false
    let isBluetooth = true
    
    // 타이머
//    @Published private(set) var elapsedTime: TimeInterval = 0
//    private var timer: AnyCancellable?
    
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
    
    func startRecording() {
        // 기록 시작
        isRecording = true
        print("start pushed")
        startTimer()
        //        elapsedTime = 0
        //        Timer.publish(every: 1.0, on: .main, in: .common)
        //            .autoconnect()
        //            .sink { [weak self] _ in
        //                self?.elapsedTime += 1
        //            }
        //            .store(in: &cancellables)
    }
    
    func resetRecording() {
        // 기록 시작 후 누르면 리셋하고 초기상태
        isRecording = false
        print("reset pushed")
        stopTimer()
        //        cancellables.forEach { $0.cancel() }
        elapsedTime = 0.0
        recordedTime = 0.0
        onTimerUpdated?(formatTime(elapsedTime))
    }
    
    func finishRecording() {
        // 누르기 전까지의 기록 저장 후 요약페이지 이동
        isRecording = false
        print("finish pushed")
        stopTimer()
        recordedTime = elapsedTime
        onFinishRecording?()
        //        cancellables.forEach { $0.cancel() }
    }
    
    func pauseRecording() {
        // 기록 일시정지
        isRecording = false
        print("pause pushed")
        stopTimer()
        //        cancellables.forEach { $0.cancel() }
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
    
//    private func startTimer() {
//        timer = Timer.publish(every: 1, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                self?.elapsedTime += 1
//            }
//    }
//    
//    private func stopTimer() {
//        timer?.cancel()
//        timer = nil
//    }
    
    // MARK: - 기록 요약 화면 버튼 동작
    // TODO: - 버튼 동작 구현
    
    // 저장 또는 취소 시 화면 전환을 위한 클로저
    var onCancelSaveRecording: (() -> Void)?
    var onSaveRecroding: (() -> Void)?
    
    func cancelSaveRecording() {
        print("save cancel pushed")
        // 기록 요약 화면에서 취소 버튼 누르면 이전 화면(기록 화면)으로 이동
        onCancelSaveRecording?()
    }
    
    func saveRecording() {
        print("save pushed")
        // 기록 요약 화면에서 저장 버튼 누르면
        onSaveRecroding?()
    }
}
