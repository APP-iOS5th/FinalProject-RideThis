import UIKit
import SnapKit

class RecordSumUpView: RideThisViewController {
    let viewModel: RecordSumUpViewModel
    weak var coordinator: RecordSumUpCoordinator?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 커스텀 타이틀
    private let customTitleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "운동기록 요약")
    
    var recordedTime: String = "00:00"
    
    // 기록 뷰 선언
    private let timerRecord = RecordContainer(title: "Timer", recordText: "00:00", view: "summary")
    private let cadenceRecord = RecordContainer(title: "Cadence", recordText: "0 RPM", view: "summary")
    private let speedRecord = RecordContainer(title: "Speed", recordText: "0 km/h", view: "summary")
    private let distanceRecord = RecordContainer(title: "Distance", recordText: "0 km", view: "summary")
    private let calorieRecord = RecordContainer(title: "Calories", recordText: "0 kcal", view: "summary")
    
    // 버튼 선언
    let cancelButton = RideThisButton(buttonTitle: "취소")
    let saveButton = RideThisButton(buttonTitle: "저장")
    
    init(viewModel: RecordSumUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupButtons()
        
        timerRecord.updateRecordText(text: recordedTime)
        updateUI(with: viewModel.summaryData)
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
    }
    
    private func setupViews() {
        [timerRecord, cadenceRecord, speedRecord, distanceRecord, calorieRecord, cancelButton, saveButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        timerRecord.snp.makeConstraints { timer in
            timer.top.equalTo(contentView).offset(20)
            timer.left.equalTo(contentView).offset(20)
            timer.right.equalTo(contentView).offset(-20)
            timer.height.equalTo(100)
        }
        
        cadenceRecord.snp.makeConstraints { cadence in
            cadence.top.equalTo(timerRecord.snp.bottom).offset(20)
            cadence.left.equalTo(contentView).offset(20)
            cadence.right.equalTo(contentView).offset(-20)
            cadence.height.equalTo(100)
        }
        
        speedRecord.snp.makeConstraints { speed in
            speed.top.equalTo(cadenceRecord.snp.bottom).offset(20)
            speed.left.equalTo(contentView).offset(20)
            speed.right.equalTo(contentView).offset(-20)
            speed.height.equalTo(100)
        }
        
        distanceRecord.snp.makeConstraints { distance in
            distance.top.equalTo(speedRecord.snp.bottom).offset(20)
            distance.left.equalTo(contentView).offset(20)
            distance.right.equalTo(contentView).offset(-20)
            distance.height.equalTo(100)
        }
        
        calorieRecord.snp.makeConstraints { calorie in
            calorie.top.equalTo(distanceRecord.snp.bottom).offset(20)
            calorie.left.equalTo(contentView).offset(20)
            calorie.right.equalTo(contentView).offset(-20)
            calorie.height.equalTo(100)
        }
        
        cancelButton.snp.makeConstraints { btn in
            btn.top.equalTo(calorieRecord.snp.bottom).offset(30)
            btn.left.equalTo(contentView).offset(20)
            btn.right.equalTo(contentView.snp.centerX).offset(-10)
            btn.height.equalTo(50)
        }
        
        saveButton.snp.makeConstraints { btn in
            btn.top.equalTo(calorieRecord.snp.bottom).offset(30)
            btn.left.equalTo(contentView.snp.centerX).offset(10)
            btn.right.equalTo(contentView).offset(-20)
            btn.height.equalTo(50)
            btn.bottom.equalTo(contentView).offset(-20) // 마지막 요소의 하단에 여백 추가
        }
    }
    
    private func setupButtons() {
        cancelButton.backgroundColor = .black
        
        cancelButton.addAction(UIAction { [weak self] _ in
            self?.coordinator?.didCancelSaveRecording()
        }, for: .touchUpInside)
        
        saveButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            
            if UserService.shared.loginStatus == .appleLogin {
                print("로그인 유저")
                self.showAlert(alertTitle: "기록 저장", msg: "기록을 저장하시겠습니까?", confirm: "저장") {
                    self.updateViewModelWithRecordData()
                    
                    Task {
                        await self.viewModel.saveRecording()
                        self.coordinator?.didSaveRecording()
                    }
                }
            } else {
                print("Not logined")
                self.showAlert(alertTitle: "로그인이 필요합니다.", msg: "기록 저장은 로그인이 필요한 서비스입니다.", confirm: "로그인") {
                    print("go to login")
                    
                    let loginVC = LoginView()
                    self.navigationController?.pushViewController(loginVC, animated: true)
                }
            }
        }, for: .touchUpInside)
    }
    
    private func updateViewModelWithRecordData() {
        let cadence = Double(cadenceRecord.recordLabel.text!.replacingOccurrences(of: " RPM", with: "")) ?? 0
        let speed = Double(speedRecord.recordLabel.text!.replacingOccurrences(of: " km/h", with: "")) ?? 0
        let distance = Double(distanceRecord.recordLabel.text!.replacingOccurrences(of: " km", with: "")) ?? 0
        let calorie = Double(calorieRecord.recordLabel.text!.replacingOccurrences(of: " kcal", with: "")) ?? 0
        
        viewModel.updateSummaryData(cadence: cadence, speed: speed, distance: distance, calorie: calorie)
    }
    
    private func updateUI(with data: RecordViewModel.SummaryData) {
        timerRecord.updateRecordText(text: data.recordedTime)
        cadenceRecord.updateRecordText(text: "\(data.cadence) RPM")
        speedRecord.updateRecordText(text: "\(data.speed) km/h")
        distanceRecord.updateRecordText(text: "\(data.distance) km")
        calorieRecord.updateRecordText(text: "\(data.calorie) kcal")
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
}
