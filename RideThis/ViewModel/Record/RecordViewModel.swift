import Foundation

class RecordViewModel {
    // MARK: - 기록 화면 버튼 동작
    // TODO: - 버튼 동작 구현
    
    let isLogin = false
    let isBluetooth = true
    
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
        // 1. 블루투스 연결 확인
        // 1-1. 연결안됐으면 블루투스 연결 알림 팝업
    }
    
    func resetRecording() {
        // reset 버튼
        isRecording = false
        print("reset pushed")
        // 기록 시작 후 누르면 리셋하고 초기상태
    }
    
    func finishRecording() {
        // 기록 종료 버튼
        isRecording = false
        print("finish pushed")
        
        // 누르면 종료 전까지의 기록 저장 후 요약페이지 이동
        onFinishRecording?()
    }
    
    func pauseRecording() {
        // 기록 일시정지
        isRecording = false
        print("pause pushed")
    }
    
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
        // 1-1. 미로그인 시 로그인 안내 문구 팝업
        onSaveRecroding?()
    }
}
