import UIKit
import SnapKit

// 기록 탭 초기 화면
class RecordView: RideThisViewController {
    let viewModel = RecordViewModel()
    
    let recordContainerView = RecordContainerView()
    
    // 버튼 선언
    let resetButton = RideThisButton(buttonTitle: "Reset")
    let recordButton = RideThisButton(buttonTitle: "시작")
    let finishButton = RideThisButton(buttonTitle: "기록 종료")
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 대형 타이틀 활성화
        // TODO: - UI 맞춰서 수정할 것
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .inline
        self.navigationItem.title = "기록"
        
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
            if self.viewModel.isRecording {
                self.viewModel.pauseRecording()
                resetButton.isEnabled = true
                finishButton.isEnabled = true
                resetButton.backgroundColor = .black
                finishButton.backgroundColor = .black
            } else {
                self.viewModel.startRecording()
            }
        }, for: .touchUpInside)
        
        finishButton.addAction(UIAction { [weak self] _ in
            self?.showAlert(alertTitle: "기록을 종료할까요?", msg: "요약 화면으로 이동합니다.", confirm: "기록 종료"
            ) {
                self?.viewModel.finishRecording()
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
        
        self.view.addSubview(recordContainerView)
        self.view.addSubview(resetButton)
        self.view.addSubview(recordButton)
        self.view.addSubview(finishButton)
        
        // MARK: - 제약조건 추가
        recordContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(400)
        }
        
        // 버튼 제약조건
        recordButton.snp.makeConstraints { [weak self] btn in
            guard let self = self else { return }
            btn.top.equalTo(recordContainerView.snp.bottom).offset(90)
            btn.centerX.equalToSuperview()
            btn.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).multipliedBy(0.66)
        }
        
        resetButton.snp.makeConstraints { [weak self] btn in
            guard let self = self else { return }
            btn.top.equalTo(recordContainerView.snp.bottom).offset(90)
            btn.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            btn.right.equalTo(recordButton.snp.left).offset(-15)
        }
        
        finishButton.snp.makeConstraints { [weak self] btn in
            guard let self = self else { return }
            btn.top.equalTo(recordContainerView.snp.bottom).offset(90)
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
}

// MARK: - Preview
#Preview {
    UINavigationController(rootViewController: RecordView())
}
