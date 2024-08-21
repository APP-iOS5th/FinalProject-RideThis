import UIKit
import SnapKit

// 기록 탭 초기 화면
class RecordView: RideThisViewController {
    let viewModel = RecordViewModel()
    
    // 커스텀 타이틀
    private let customTitleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "기록")
    
    // 기록 뷰 선언
    private let timerRecord = RecordContainer(title: "Timer", recordText: "00:00", view: "record")
    private let cadenceRecord = RecordContainer(title: "Cadence", recordText: "0 RPM", view: "record")
    private let speedRecord = RecordContainer(title: "Speed", recordText: "0 km/h", view: "record")
    private let distanceRecord = RecordContainer(title: "Distance", recordText: "0 km", view: "record")
    private let calorieRecord = RecordContainer(title: "Calories", recordText: "0 kcal", view: "record")
    
    // 버튼 선언
    let resetButton = RideThisButton(buttonTitle: "Reset")
    let recordButton = RideThisButton(buttonTitle: "시작")
    let finishButton = RideThisButton(buttonTitle: "기록 종료")
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        // 버튼 상태 설정
        resetButton.backgroundColor = .systemGray
        finishButton.backgroundColor = .systemGray
        resetButton.isEnabled = false
        finishButton.isEnabled = false
        
        // 버튼 액션
        resetButton.addAction(UIAction { [weak self] _ in
            self?.showAlert(alertTitle: "기록을 리셋할까요?", msg: "지금까지의 기록이 초기화됩니다.", confirm: "리셋"
            ) {
                self?.viewModel.resetRecording()
            }
        }, for: .touchUpInside)
        
        // TODO: - 클릭 시 버튼이 눌리는 모션이 보이지 않음(확인 필요)
        // 커스텀이라 그런가
        recordButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            // TODO: - 최초 기록 시작일 때 카운트다운 추가
            
            // 블루투스 연결 상태 확인
            if self.viewModel.isBluetooth {
                if self.viewModel.isRecording {
                    self.viewModel.pauseRecording()
                    resetButton.isEnabled = true
                    finishButton.isEnabled = true
                    resetButton.backgroundColor = .black
                    finishButton.backgroundColor = .black
                } else {
                    self.viewModel.startRecording()
                    // 기록 시작 시 탭바 비활성화
                    self.tabBarController?.tabBar.items?.forEach { $0.isEnabled = false }
                }
            } else {
                showAlert(alertTitle: "장치연결이 필요합니다.", msg: "사용하시려면 장치를 연결해주세요.", confirm: "장치연결") {
                    print("connect Bluetooth")
                    // TODO: - 장치 연결 페이지 이동 추가
                }
            }
        }, for: .touchUpInside)
        
        finishButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.showAlert(alertTitle: "기록을 종료할까요?", msg: "요약 화면으로 이동합니다.", confirm: "기록 종료"
            ) {
                self.viewModel.finishRecording()
                self.tabBarController?.tabBar.items?.forEach { $0.isEnabled = true }
            }
        }, for: .touchUpInside)
        
        // ViewModel의 상태 변경 클로저 설정
        viewModel.onRecordingStatusChanged = { [weak self] isRecording in
            guard let self = self else { return }
            self.updateUI(isRecording: isRecording)
        }
        
        // 뷰 모델에서 기록 종료 트리거 처리
        viewModel.onFinishRecording = { [weak self] in
            self?.navigateToSummaryView()
        }
        
        // 기록 뷰 추가
        self.view.addSubview(timerRecord)
        self.view.addSubview(cadenceRecord)
        self.view.addSubview(speedRecord)
        self.view.addSubview(distanceRecord)
        self.view.addSubview(calorieRecord)
        
        // 버튼 추가
        self.view.addSubview(resetButton)
        self.view.addSubview(recordButton)
        self.view.addSubview(finishButton)
        
        // MARK: - 제약조건 추가
        // 기록 뷰 제약조건
        timerRecord.snp.makeConstraints { timer in
            timer.top.equalToSuperview().offset(80)
            timer.left.equalToSuperview().offset(20)
            timer.right.equalToSuperview().offset(-20)
            timer.height.equalTo(150)
        }
        
        cadenceRecord.snp.makeConstraints { cadence in
            cadence.top.equalTo(timerRecord.snp.bottom).offset(40)
            cadence.left.equalToSuperview().offset(20)
            cadence.width.equalToSuperview().multipliedBy(0.5).offset(-25)
            cadence.height.equalTo(110)
        }
        
        speedRecord.snp.makeConstraints { speed in
            speed.top.equalTo(timerRecord.snp.bottom).offset(40)
            speed.left.equalTo(cadenceRecord.snp.right).offset(10)
            speed.right.equalToSuperview().offset(-20)
            speed.height.equalTo(110)
        }
        
        distanceRecord.snp.makeConstraints { distance in
            distance.top.equalTo(cadenceRecord.snp.bottom).offset(15)
            distance.left.equalToSuperview().offset(20)
            distance.width.equalToSuperview().multipliedBy(0.5).offset(-25)
            distance.height.equalTo(110)
        }
        
        calorieRecord.snp.makeConstraints { calory in
            calory.top.equalTo(speedRecord.snp.bottom).offset(15)
            calory.left.equalTo(distanceRecord.snp.right).offset(10)
            calory.right.equalToSuperview().offset(-20)
            calory.height.equalTo(110)
        }
        
        // 버튼 제약조건
        recordButton.snp.makeConstraints { [weak self] btn in
            guard let self = self else { return }
            btn.top.equalTo(calorieRecord.snp.bottom).offset(67)
            btn.centerX.equalToSuperview()
            btn.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).multipliedBy(0.66)
        }
        
        resetButton.snp.makeConstraints { [weak self] btn in
            guard let self = self else { return }
            btn.top.equalTo(calorieRecord.snp.bottom).offset(67)
            btn.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            btn.right.equalTo(recordButton.snp.left).offset(-15)
        }
        
        finishButton.snp.makeConstraints { [weak self] btn in
            guard let self = self else { return }
            btn.top.equalTo(calorieRecord.snp.bottom).offset(67)
            btn.left.equalTo(recordButton.snp.right).offset(15)
            btn.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
        }
    }
    
    // 버튼 UI 업데이트
    private func updateUI(isRecording: Bool) {
        if isRecording { // 기록중일 때
            resetButton.isEnabled = true
            finishButton.isEnabled = true
            resetButton.backgroundColor = .black
            finishButton.backgroundColor = .black
            
            recordButton.setTitle("정지", for: .normal)
        } else { // 정지, 리셋, 종료 눌렸을 때
            resetButton.isEnabled = false
            finishButton.isEnabled = false
            resetButton.backgroundColor = .systemGray
            finishButton.backgroundColor = .systemGray
            
            recordButton.setTitle("시작", for: .normal)
        }
    }
    
    private func navigateToSummaryView() {
        let summaryViewController = RecordSumUpView()
        self.navigationController?.pushViewController(summaryViewController, animated: true) // 요약 화면으로 이동
        // TODO: - 요약 페이지 뒤로가기 버튼 해결
    }
    
    // MARK: Navigation Bar
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // 커스텀 타이틀 레이블을 왼쪽 바 버튼 아이템으로 설정
        let leftBarButtonItem = UIBarButtonItem(customView: customTitleLabel)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    // MARK: - 탭바 활성화
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.items?.forEach { $0.isEnabled = true }
    }

}

// MARK: - Preview
#Preview {
    UINavigationController(rootViewController: RecordView())
}
