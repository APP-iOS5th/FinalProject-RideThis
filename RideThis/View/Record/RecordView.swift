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
            self?.viewModel.resetRecording()
        }, for: .touchUpInside)
        
        // TODO: - 클릭 시 버튼이 눌리는 모션이 보이지 않음(확인 필요)
        // 커스텀이라 그런가
        recordButton.addAction(UIAction { [weak self] _ in
            // TODO: - 시작/정지 상태 처리
            if self!.viewModel.isRecording {
                self?.viewModel.pauseRecording()
            } else {
                self?.viewModel.startRecording()
            }
        }, for: .touchUpInside)
        
        finishButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.finishRecording()
        }, for: .touchUpInside)
        
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
}

// MARK: - Preview
#Preview {
    UINavigationController(rootViewController: RecordView())
}
