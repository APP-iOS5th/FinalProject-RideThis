import Foundation

class RecordViewModel {
    // MARK: - 기록 화면 버튼 동작
    // TODO: - 버튼 동작 구현
    var isRecording: Bool = false
    
    func startRecording() {
        // 기록 시작
        isRecording = true
        print("start pushed")
        // 기록 시작 전에 누르면
        // 1. 블루투스 연결 확인
        // 1-1. 연결안됐으면 블루투스 연결 알림 팝업
        // 2. 기록 시작(경쟁처럼 카운트다운은 없는듯)
        // 2. reset, finish 버튼 활성화
        // 3. 레이블 시작->정지 변경
    }
    
    func resetRecording() {
        // reset 버튼
        isRecording = false
        print("reset pushed")
        // 기록 시작 후 누르면
        // 1. 리셋 확인 팝업
        // 1-1. 취소 누르면 리셋 버튼 이전 상태 지속
        // 1-2. 리셋 누르면 리셋하고 초기상태
        // 2. 기록 레이블 리셋하고 reset, finish 버튼 비활성화
    }
    
    func finishRecording() {
        // 기록 종료 버튼
        isRecording = false
        print("finish pushed")
        // 기록 시작 후 누르면
        // 1. 기록 종료 확인 팝업
        // 1-1. 취소 누르면 종료 버튼 이전 상태 지속
        // 1-2. 종료 누르면 종료 전까지의 기록 저장 후 요약페이지 이동
        // 2. 기록 레이블 리셋하고 reset, finish 버튼 비활성화
    }
    
    func pauseRecording() {
        // 기록 일시정지
        isRecording = false
        print("pause pushed")
        // 기록 시작 후 정지로 레이블 변경된 버튼 누르면
        // 1. 별도 팝업 없이 기록 일시 정지
        // 2. 레이블 정지->시작 변경
        // 3. reset, finish 버튼은 계속 활성화된 상태
    }
    
    // MARK: - 기록 요약 화면 버튼 동작
    // TODO: - 버튼 동작 구현
    func cancelSaveRecording() {
        print("save cancel pushed")
        // 기록 요약 화면에서 취소 버튼 누르면
        // 1. 이전 화면(기록 화면)으로 이동
        // 2. 기록은 저장되지 않음
    }
    
    func saveRecording() {
        print("save")
        // 기록 요약 화면에서 저장 버튼 누르면
        // 1. 팝업 노출
        // 1-1. 미로그인 시 로그인 안내 문구
        // 1-2. 로그인 시 기록 저장 안내 문구
        // 2. 취소 누르면 
    }
}
