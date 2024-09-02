import UIKit
import SnapKit
import Combine

// 기록 탭 초기 화면
class RecordView: RideThisViewController {
    
    var coordinator: RecordCoordinator?
    var viewModel: RecordViewModel?
    
    private var cancellables = Set<AnyCancellable>()
    
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
        
        if viewModel == nil {
            viewModel = RecordViewModel()
        }
        
        setupNavigationBar()
        setupButtons()
        
        if let viewModel = viewModel {
            setupBindings()
            
            // ViewModel의 상태 변경 클로저 설정
            viewModel.onRecordingStatusChanged = { [weak self] isRecording in
                guard let self = self else { return }
                self.updateUI(isRecording: isRecording)
            }
            
            // 뷰 모델에서 기록 종료 트리거 처리
            viewModel.delegate = self
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
        
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // RecordSumUpView에서 돌아올 때 타이머 초기화
        if !(viewModel?.isRecording ?? false) {
            viewModel?.resetRecording()
            updateTimerDisplay()
            updateUI(isRecording: false)
        }
    }
    
    private func updateTimerDisplay() {
        timerRecord.updateRecordText(text: viewModel?.updateTimerDisplay() ?? "00:00")
    }
    
    // MARK: - 레이아웃 설정
    private func setupConstraints() {
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
    
    // MARK: - 버튼 설정
    private func setupButtons() {
        resetButton.backgroundColor = .systemGray
        finishButton.backgroundColor = .systemGray
        resetButton.isEnabled = false
        finishButton.isEnabled = false
        
        // 버튼 액션
        resetButton.addAction(UIAction { [weak self] _ in
            self?.showAlert(alertTitle: "기록을 리셋할까요?", msg: "지금까지의 기록이 초기화됩니다.", confirm: "리셋"
            ) {
                self?.viewModel?.resetRecording()
                self?.enableTabBar()
            }
        }, for: .touchUpInside)
        
        recordButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            // TODO: - 최초 기록 시작일 때 카운트다운 추가
            // 블루투스 연결 상태 확인
            if self.viewModel?.isBluetoothConnected == true {
                if self.viewModel?.isRecording == true {
                    self.viewModel?.pauseRecording()
                } else {
                    self.viewModel?.startRecording()
                    self.disableTabBar() // 탭바 비활성화
                }
            } else {
                showAlert(alertTitle: "장치연결이 필요합니다.", msg: "사용하시려면 장치를 연결해주세요.", confirm: "장치연결") {
                    print("connect Bluetooth")
                    self.coordinator?.showDeviceConnectionView()
                }
            }
        }, for: .touchUpInside)
        
        finishButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.showAlert(alertTitle: "기록을 종료할까요?", msg: "요약 화면으로 이동합니다.", confirm: "기록 종료"
            ) {
                self.viewModel?.finishRecording()
                self.enableTabBar() // 탭바 활성화
            }
        }, for: .touchUpInside)
    }
    
    // MARK: - 탭바 활성화 / 비활성화
    private func enableTabBar() {
        tabBarController?.tabBar.items?.forEach { $0.isEnabled = true }
    }
    
    private func disableTabBar() {
        tabBarController?.tabBar.items?.forEach { $0.isEnabled = false }
    }
    
    // 바인딩 설정
    private func setupBindings() {
        // elapsedTime이 변경될 때마다 timerRecord의 recordText 업데이트
        viewModel?.$elapsedTime
            .map { elapsedTime -> String in
                let minutes = Int(elapsedTime) / 60
                let seconds = Int(elapsedTime) % 60
                return String(format: "%02d:%02d", minutes, seconds)
            }
            .assign(to: \.recordLabel.text, on: timerRecord)
            .store(in: &cancellables)
        
        self.viewModel?.$cadence
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cadence in
                self?.cadenceRecord.updateRecordText(text: "\(cadence.formattedWithThousandsSeparator()) RPM")
            }
            .store(in: &cancellables)
        
        self.viewModel?.$speed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] speed in
                self?.speedRecord.updateRecordText(text: "\(speed.formattedWithThousandsSeparator()) Km/h")
            }
            .store(in: &cancellables)
        
        self.viewModel?.$distance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] distance in
                self?.distanceRecord.updateRecordText(text: "\(distance.formattedWithThousandsSeparator()) Km")
            }
            .store(in: &cancellables)
        
        self.viewModel?.$calorie
            .receive(on: DispatchQueue.main)
            .sink { [weak self] calorie in
                self?.calorieRecord.updateRecordText(text: "\(calorie.formattedWithThousandsSeparator()) Kcal")
            }
            .store(in: &cancellables)
    }
    
    // 버튼 UI 업데이트
    private func updateUI(isRecording: Bool) {
        DispatchQueue.main.async {
            if isRecording { // 기록중일 때
                self.resetButton.isEnabled = true
                self.finishButton.isEnabled = true
                self.resetButton.backgroundColor = .black
                self.finishButton.backgroundColor = .black

                self.recordButton.setTitle("정지", for: .normal)
            } else if self.viewModel?.isPaused == true { // 일시정지일 때
                self.resetButton.isEnabled = true
                self.finishButton.isEnabled = true
                self.resetButton.backgroundColor = .black
                self.finishButton.backgroundColor = .black
                
                self.recordButton.setTitle("시작", for: .normal)
            } else { // 정지, 리셋, 종료 눌렸을 때
                self.resetButton.isEnabled = false
                self.finishButton.isEnabled = false
                self.resetButton.backgroundColor = .systemGray
                self.finishButton.backgroundColor = .systemGray
                
                self.recordButton.setTitle("시작", for: .normal)
            }
        }
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
        
        // 오른쪽 바 버튼 아이템에 기록 목록 추가
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(recordListButtonTapped))
        rightBarButtonItem.tintColor = .primaryColor
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc private func recordListButtonTapped() {
        coordinator?.showRecordListView()
        print("기록 목록 출력")
    }
    
    // MARK: - 탭바 활성화
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        enableTabBar()
    }
    
}

extension RecordView: RecordViewModelDelegate {
    func didFinishRecording() {
        coordinator?.showSummaryView(viewModel: viewModel ?? RecordViewModel())
        enableTabBar()
    }
    
    func didPauseRecording() {
        updateUI(isRecording: false)
        disableTabBar()
    }
    
    func didStartRecording() {
        updateUI(isRecording: true)
        disableTabBar()
    }
    
    func didResetRecording() {
        updateUI(isRecording: false)
        updateTimerDisplay()
        enableTabBar()
    }
}

// 블루투스가 꺼졌을 때
extension RecordView: BluetoothViewDelegate {
    func bluetoothDidTurnOff() {
        DispatchQueue.main.async {
            self.showAlert(alertTitle: "블루투스 꺼짐", msg: "블루투스가 꺼졌습니다. 다시 켜주세요.", confirm: "확인") {
                print("블루투스 꺼짐")
            }
        }
    }
}
