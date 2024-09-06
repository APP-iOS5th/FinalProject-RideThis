import UIKit
import SnapKit
import Combine

// 기록 탭 초기 화면
class RecordView: RideThisViewController {
    
    var coordinator: RecordCoordinator?
    var viewModel: RecordViewModel
    
    init(viewModel: RecordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var lastDataUpdateTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // 커스텀 타이틀
    private let customTitleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "기록")
    private var recordListButton: UIBarButtonItem?
    
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
    
    private let mainStackView = UIStackView()
    private let recordsStackView = UIStackView()
    private let buttonStackView = UIStackView()
    
    private var stopButtonTabbed: Bool = false
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupMainStackView()
        setupRecordsStackView()
        setupButtonStackView()
        setupButtons()
        setupBindings()
        viewModel.onRecordingStatusChanged = { [weak self] isRecording in
            guard let self = self else { return }
            self.updateUI(isRecording: isRecording)
        }
        
        viewModel.delegate = self
        tabBarController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.stopButtonTabbed = false
        
        // RecordSumUpView에서 돌아올 때 타이머 초기화
        if !(viewModel.isRecording) {
            viewModel.resetRecording()
            updateTimerDisplay()
            updateUI(isRecording: false)
        }
        
        if UserService.shared.loginStatus == .appleLogin {
            Task {
                do {
                    viewModel.deviceModel = try await viewModel.fetchDeviceData()
                    viewModel.updateBTManager()
                } catch {
                    print("장치 정보를 가져오는 중 오류 발생: \(error)")
                }
            }
        } else {
            viewModel.updateBTManager()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.disConnectBT()
    }
    
    private func setupMainStackView() {
        view.addSubview(mainStackView)
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill

        mainStackView.snp.makeConstraints { make in
            if isLargeDevice() {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40) // 큰 기기에 대한 상단 여백
            } else {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20) // 작은 기기에 대한 상단 여백
            }
            make.left.right.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-120)
        }

        mainStackView.addArrangedSubview(timerRecord)
        mainStackView.addArrangedSubview(recordsStackView)

        timerRecord.snp.makeConstraints { make in
            make.height.equalTo(150)
        }

        if isLargeDevice() {
            // 큰 기기에서 추가 여백을 주기 위한 빈 뷰
            let topSpacerView = UIView()
            let bottomSpacerView = UIView()
            mainStackView.insertArrangedSubview(topSpacerView, at: 0)
            mainStackView.addArrangedSubview(bottomSpacerView)
            
            topSpacerView.snp.makeConstraints { make in
                make.height.equalTo(20)
            }
            bottomSpacerView.snp.makeConstraints { make in
                make.height.equalTo(20)
            }
        }
    }
    
    private func setupRecordsStackView() {
        recordsStackView.axis = .vertical
        recordsStackView.spacing = 15
        recordsStackView.distribution = .fillEqually
        
        let topRecordStack = UIStackView(arrangedSubviews: [cadenceRecord, speedRecord])
        topRecordStack.axis = .horizontal
        topRecordStack.spacing = 10
        topRecordStack.distribution = .fillEqually
        
        let bottomRecordStack = UIStackView(arrangedSubviews: [distanceRecord, calorieRecord])
        bottomRecordStack.axis = .horizontal
        bottomRecordStack.spacing = 10
        bottomRecordStack.distribution = .fillEqually
        
        recordsStackView.addArrangedSubview(topRecordStack)
        recordsStackView.addArrangedSubview(bottomRecordStack)
        
        // 각 RecordContainer의 크기 제한
        [cadenceRecord, speedRecord, distanceRecord, calorieRecord].forEach { container in
            container.snp.makeConstraints { make in
                make.height.equalTo(110)
            }
        }
    }
    
    private func setupButtonStackView() {
        view.addSubview(buttonStackView)
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 10
        buttonStackView.distribution = .fillEqually
        
        buttonStackView.addArrangedSubview(resetButton)
        buttonStackView.addArrangedSubview(recordButton)
        buttonStackView.addArrangedSubview(finishButton)
        
        buttonStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - 레이아웃 조정
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isLargeDevice() {
            mainStackView.spacing = 20
        } else {
            mainStackView.spacing = 10
        }
    }
    
    private func isLargeDevice() -> Bool {
        let screenSize = UIScreen.main.bounds.size
        let minDimension = min(screenSize.width, screenSize.height)
        let maxDimension = max(screenSize.width, screenSize.height)
        
        // iPhone 11, 11 Pro, 11 Pro Max, 12, 12 Pro, 12 Pro Max, 13, 13 Pro, 13 Pro Max, 14, 14 Pro, 14 Pro Max, 15, 15 Pro, 15 Pro Max
        return minDimension >= 390 && maxDimension >= 844
    }
    
    private func updateTimerDisplay() {
        timerRecord.updateRecordText(text: viewModel.updateTimerDisplay())
    }
    
    private var hasShownBluetoothAlert = false
    
    func resetBluetoothAlert() {
        hasShownBluetoothAlert = false
    }
    
    // MARK: - 버튼 설정
    private func setupButtons() {
        resetButton.backgroundColor = .systemGray
        finishButton.backgroundColor = .systemGray
        resetButton.isEnabled = false
        finishButton.isEnabled = false
        
        // 버튼 액션
        resetButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.pauseRecording()
            self.showAlert(alertTitle: "기록을 리셋할까요?", msg: "지금까지의 기록이 초기화됩니다.", confirm: "리셋"
            ) {
                self.viewModel.resetRecording()
                self.enableTabBar()
            } cancelAction: {
                if self.stopButtonTabbed == false {
                    self.viewModel.resumeRecording()
                }
            }
        }, for: .touchUpInside)
        
        recordButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            
            Task {
                let isConnected = await self.viewModel.checkBluetoothConnection()
                if !isConnected {
                    if UserService.shared.loginStatus == .appleLogin {
                        self.showBluetoothDisconnectedAlert()
                    } else {
                        self.showUnownedUserBluetoothAlert()
                    }
                    return
                }
                
                if !self.viewModel.isRecording && !self.viewModel.isPaused {
                    self.stopButtonTabbed = false
                    let countDownCoordinator = RecordCountCoordinator(navigationController: self.navigationController!)
                    countDownCoordinator.start()
                } else {
                    if self.viewModel.isRecording {
                        self.stopButtonTabbed = true
                    } else {
                        self.stopButtonTabbed = false
                    }
                }
                
#if targetEnvironment(simulator)
                // 시뮬레이터에서는 블루투스 연결 확인을 건너뛰고 바로 기록을 시작합니다.
                if viewModel.isRecording {
                    viewModel.pauseRecording()
                } else if viewModel.isPaused {
                    viewModel.resumeRecording()
                } else {
                    viewModel.startRecording()
                    self.disableTabBar()
                }
                self.updateUI(isRecording: viewModel.isRecording)
#else
                if self.viewModel.isRecording || self.viewModel.isPaused {
                    self.startRecordProcess()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.viewModel.btManager?.delegate = self
                        self.viewModel.btManager?.viewDelegate = self
                        self.startRecordProcess()
                    }
                }
#endif
            }
        }, for: .touchUpInside)
        
//        recordButton.addAction(UIAction { [weak self] _ in
//            guard let self = self else { return }
//            // MARK: 카운트다운 modal 뷰 present -> 5초 후 dismiss -> 타이머 시작
//
//
//            let isConnected = self.viewModel.checkBluetoothConnection()
//            if !isConnected {
//                self.showBluetoothDisconnectedAlert()
//                return
//            }
//
//            if !viewModel.isRecording && !viewModel.isPaused {
//                stopButtonTabbed = false
//                let countDownCoordinator = RecordCountCoordinator(navigationController: self.navigationController!)
//                countDownCoordinator.start()
//            } else {
//                if viewModel.isRecording {
//                    stopButtonTabbed = true
//                } else {
//                    stopButtonTabbed = false
//                }
//            }
//
//    #if targetEnvironment(simulator)
//            // 시뮬레이터에서는 블루투스 연결 확인을 건너뛰고 바로 기록을 시작합니다.
//            if viewModel.isRecording {
//                viewModel.pauseRecording()
//            } else if viewModel.isPaused {
//                viewModel.resumeRecording()
//            } else {
//                viewModel.startRecording()
//                self.disableTabBar()
//            }
//            self.updateUI(isRecording: viewModel.isRecording)
//#else
//            if viewModel.isRecording || viewModel.isPaused {
//                startRecordProcess()
//            } else {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                    self.viewModel.btManager?.delegate = self
//                    self.viewModel.btManager?.viewDelegate = self
//                    self.startRecordProcess()
//                }
//            }
//    #endif
//        }, for: .touchUpInside)
        
        /*
         MARK: 정지 -> 기록 종료 -> 취소 : recording: false / pause: true
         MARK: 기록 종료 -> 취소: recording: false / pause: true
         */
        
        finishButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            viewModel.pauseRecording()
            self.showAlert(alertTitle: "기록을 종료할까요?", msg: "요약 화면으로 이동합니다.", confirm: "기록 종료") {
                self.viewModel.finishRecording()
                self.enableTabBar() // 탭바 활성화
            } cancelAction: {
                // MARK: 현재 기록중이었을 때만 종료버튼 후 alert에서 취소를 누르면 계속 기록이 진행되게 하기위해서
                if self.stopButtonTabbed == false {
                    self.viewModel.resumeRecording()
                }
            }
        }, for: .touchUpInside)
    }
    
    private func showUnownedUserBluetoothAlert() {
        showAlert(alertTitle: "장치 연결 필요", msg: "기록을 시작하려면 먼저 장치를 연결해야 합니다.", confirm: "장치 연결") {
            self.coordinator?.showDeviceConnectionView()
        }
    }
    
    func startRecordProcess() {
        Task {
            let isConnected = await self.viewModel.checkBluetoothConnection()
            if isConnected {
                if self.viewModel.isRecording {
                    self.viewModel.pauseRecording()
                } else if self.viewModel.isPaused {
                    self.viewModel.resumeRecording()
                } else {
                    self.viewModel.startRecording()
                    self.disableTabBar()
                }
                self.updateUI(isRecording: self.viewModel.isRecording)
            } else {
                self.showBluetoothDisconnectedAlert()
            }
        }
    }

    
    private func showBluetoothDisconnectedAlert() {
        showAlert(alertTitle: "장치연결이 필요합니다.", msg: "사용하시려면 장치를 연결해주세요.", confirm: "장치연결") {
            self.coordinator?.showDeviceConnectionView()
        }
        hasShownBluetoothAlert = true
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
        viewModel.$elapsedTime
            .map { elapsedTime -> String in
                let minutes = Int(elapsedTime) / 60
                let seconds = Int(elapsedTime) % 60
                return String(format: "%02d:%02d", minutes, seconds)
            }
            .assign(to: \.recordLabel.text, on: timerRecord)
            .store(in: &cancellables)
        
        self.viewModel.$cadence
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cadence in
                self?.cadenceRecord.updateRecordText(text: "\(cadence.getTwoDecimal.formattedWithThousandsSeparator()) RPM")
            }
            .store(in: &cancellables)
        
        self.viewModel.$speed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] speed in
                self?.speedRecord.updateRecordText(text: "\(speed.getTwoDecimal.formattedWithThousandsSeparator()) Km/h")
            }
            .store(in: &cancellables)
        
        self.viewModel.$distance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] distance in
                self?.distanceRecord.updateRecordText(text: "\(distance.getTwoDecimal.formattedWithThousandsSeparator()) Km")
            }
            .store(in: &cancellables)
        
        self.viewModel.$calorie
            .receive(on: DispatchQueue.main)
            .sink { [weak self] calorie in
                self?.calorieRecord.updateRecordText(text: "\(calorie.getTwoDecimal.formattedWithThousandsSeparator()) Kcal")
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
                self.recordListButton?.isEnabled = false
            } else if self.viewModel.isPaused == true { // 일시정지일 때
                self.resetButton.isEnabled = true
                self.finishButton.isEnabled = true
                self.resetButton.backgroundColor = .black
                self.finishButton.backgroundColor = .black
                self.recordButton.setTitle("재시작", for: .normal)
                self.recordListButton?.isEnabled = false
            } else { // 정지, 리셋, 종료 눌렸을 때
                self.resetButton.isEnabled = false
                self.finishButton.isEnabled = false
                self.resetButton.backgroundColor = .systemGray
                self.finishButton.backgroundColor = .systemGray
                self.recordButton.setTitle("시작", for: .normal)
                self.recordListButton?.isEnabled = true
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
        recordListButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(recordListButtonTapped))
        recordListButton?.tintColor = .primaryColor
        navigationItem.rightBarButtonItem = recordListButton
    }
    
    @objc private func recordListButtonTapped() {
        if viewModel.isUserLoggedIn == true {
            coordinator?.showRecordListView()
        } else {
            showLoginAlert()
        }
    }
    
    private func showLoginAlert() {
        showAlert(
            alertTitle: "로그인 필요",
            msg: "기록 목록을 보려면 로그인이 필요합니다. 로그인 하시겠습니까?",
            confirm: "로그인"
        ) {
            self.coordinator?.showLoginView()
        }
    }
    
    // MARK: - 탭바 활성화
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        enableTabBar()
    }
    
}

// MARK: - extension
extension RecordView: RecordViewModelDelegate {
    func didFinishRecording() {
        coordinator?.showSummaryView(viewModel: viewModel)
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

extension RecordView: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.selectedViewController {
            return true
        }
        
        // 기록 중이거나 일시정지 상태일 때 탭 전환 막기
        if viewModel.isRecording == true || viewModel.isPaused == true {
            return false
        }
        
        return true
    }
}

extension RecordView: BluetoothViewDelegate {
    func bluetoothDidTurnOff() {
        guard let tabBarController = self.navigationController?.tabBarController else {
            print("TabBarController not found")
            return
        }
        self.navigationController?.popToRootViewController(animated: true)
        tabBarController.tabBar.items?.forEach{ $0.isEnabled = true }
        tabBarController.selectedIndex = 3
    }
}

extension RecordView: BluetoothManagerDelegate {
    func bluetoothDidConnect() {
        if let recordView = navigationController?.topViewController as? RecordView {
            recordView.resetBluetoothAlert()
        }
    }

    func didUpdateCadence(_ cadence: Double) {
        lastDataUpdateTime = Date()
        viewModel.didUpdateCadence(cadence)
    }

    func didUpdateSpeed(_ speed: Double) {
        lastDataUpdateTime = Date()
        viewModel.didUpdateSpeed(speed)
    }

    func didUpdateDistance(_ distance: Double) {
        lastDataUpdateTime = Date()
        viewModel.didUpdateDistance(distance)
    }

    func didUpdateCalories(_ calories: Double) {
        lastDataUpdateTime = Date()
        viewModel.didUpdateCalories(calories)
    }
}
