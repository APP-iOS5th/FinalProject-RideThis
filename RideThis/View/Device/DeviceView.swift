import UIKit
import Combine

class DeviceView: RideThisViewController {
    // MARK: - Properties
    
    var coordinator: DeviceCoordinator?
    
    private let customTitleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "장치연결")
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let findDeviceButton = RideThisButton(buttonTitle: "장치찾기")
    private let emptyLabel = RideThisLabel(fontType: .defaultSize, fontColor: .gray, text: "등록된 장치 없음")
    
    private var viewModel = DeviceViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - Initialization
    init(viewModel: DeviceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        bindViewModel()
        setupActions()
        viewModel.loadRegisteredDevices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserService.shared.loginStatus == .appleLogin {
            viewModel.loadRegisteredDevices()
        } else {
            viewModel.loadUnkownedDevices()
        }
        tableView.reloadData()
    }
    
    // MARK: - UI Setup
    
    /// UI 요소들을 설정
    private func setupUI() {
        setupNavigationBar()
        setupLayout()
        configureEmptyLabel()
    }
    
    /// NavigationBar 설정
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customTitleLabel)
    }
    
    /// UI 요소들의 레이아웃 설정
    private func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide
        let screenHeight = UIScreen.main.bounds.height
        
        view.addSubview(tableView)
        view.addSubview(findDeviceButton)
        
        tableView.snp.makeConstraints { tableView in
            tableView.top.equalTo(safeArea.snp.top).offset(20)
            tableView.right.equalTo(safeArea.snp.right).offset(-20)
            tableView.left.equalTo(safeArea.snp.left).offset(20)
            tableView.bottom.equalTo(findDeviceButton.snp.top).offset(-30)
        }
        
        findDeviceButton.snp.makeConstraints { findDeviceButton in
            findDeviceButton.bottom.equalTo(safeArea.snp.bottom).offset(screenHeight < 668 ? -20 : -50)
            findDeviceButton.right.equalTo(safeArea.snp.right).offset(-20)
            findDeviceButton.left.equalTo(safeArea.snp.left).offset(20)
        }
    }
    
    /// 빈 라벨 구성
    private func configureEmptyLabel() {
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
        
        emptyLabel.snp.makeConstraints { emptyLabel in
            emptyLabel.center.equalTo(tableView)
        }
    }
    
    /// TableView 설정
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: DeviceTableViewCell.identifier)
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
    }
    
    /// 버튼 액션을 설정합니다.
    private func setupActions() {
        findDeviceButton.addAction(UIAction { [weak self] _ in
            self?.presentDeviceSearchBottomSheet()
        }, for: .touchUpInside)
    }
    
    // MARK: - ViewModel Binding
    
    /// ViewModel과 View를 바인딩
    private func bindViewModel() {
        viewModel.$devices // viewModel의 Device 목록 구독
            .receive(on: DispatchQueue.main) // Main Thread에서 처리
            .sink { [weak self] devices in
                self?.tableView.reloadData() // 데이터 변경 시 tableView reload
            }
            .store(in: &cancellables)
        
        viewModel.$unownedDevices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] unownedDevices in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.isEmptyState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                self?.updateEmptyLabelVisibility(isEmpty: isEmpty)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Device Search
    
    /// 장치 검색 BottomSheet 표시
    private func presentDeviceSearchBottomSheet() {
        if UserService.shared.loginStatus == .appleLogin {
            // 회원일 경우
            if viewModel.devices.count == 1 {
                showAlert(
                    alertTitle: "블루투스 기기는 1대만 등록이 가능합니다.",
                    msg: "등록되어있던 블루투스 기기를 삭제하시겠습니까?",
                    confirm: "삭제"
                ) { [weak self] in
                    guard let self = self, let deviceToDelete = self.viewModel.devices.first else { return }
                    
                    Task {
                        do {
                            try await self.viewModel.deleteDeviceFromFirebase(deviceToDelete.name)
                            DispatchQueue.main.async {
                                self.viewModel.deleteDevice(deviceToDelete.name)
                                self.updateEmptyLabelVisibility(isEmpty: self.viewModel.devices.isEmpty)
                                self.coordinator?.showDeviceSearchView()
                            }
                        } catch {
                            print("Error deleting device: \(error)")
                        }
                    }
                }
            } else {
                coordinator?.showDeviceSearchView()
            }
        } else {
            // 비회원일 경우
            if viewModel.unownedDevices.count == 1 {
                showAlert(
                    alertTitle: "블루투스 기기는 1대만 등록이 가능합니다.",
                    msg: "등록되어있던 블루투스 기기를 삭제하시겠습니까?",
                    confirm: "삭제"
                ) { [weak self] in
                    guard let self = self, let deviceToDelete = self.viewModel.unownedDevices.first else { return }
                    
                    // 비회원 장치 삭제
                    self.viewModel.deleteDeviceUnkownedUser(deviceToDelete.name)
                    DispatchQueue.main.async {
                        self.updateEmptyLabelVisibility(isEmpty: self.viewModel.unownedDevices.isEmpty)
                        self.tableView.reloadData()
                        self.coordinator?.showDeviceSearchView()
                    }
                }
            } else {
                coordinator?.showDeviceSearchView()
            }
        }
    }
    
    /// Device 목록이 비었을 때 빈 레이블 업데이트
    /// - Parameter isEmpty: Device 목록 비었는지 여부
    private func updateEmptyLabelVisibility(isEmpty: Bool) {
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    func refreshDeviceList() {
        if UserService.shared.loginStatus == .appleLogin {
            viewModel.loadRegisteredDevices()
        } else {
            viewModel.loadUnkownedDevices()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension DeviceView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserService.shared.loginStatus == .appleLogin {
            return viewModel.devices.count
        } else {
            return viewModel.unownedDevices.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DeviceTableViewCell.identifier, for: indexPath) as? DeviceTableViewCell else {
            return UITableViewCell()
        }

        let device: Device
        if UserService.shared.loginStatus == .appleLogin {
            device = viewModel.devices[indexPath.row]
        } else {
            device = viewModel.unownedDevices[indexPath.row]
        }
        cell.configure(with: device)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if UserService.shared.loginStatus == .appleLogin {
            let selectedDeviceName = viewModel.devices[indexPath.row].name
            coordinator?.showDeviceDetailView(for: selectedDeviceName, viewModel: viewModel)
        } else {
            let selectedDeviceName = viewModel.unownedDevices[indexPath.row].name
            coordinator?.showDeviceDetailView(for: selectedDeviceName, viewModel: viewModel)
        }
    }
}
