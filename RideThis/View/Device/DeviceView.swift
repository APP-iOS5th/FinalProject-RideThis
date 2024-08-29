import UIKit
import Combine

class DeviceView: RideThisViewController {
    
    var coordinator: DeviceCoordinator?
    
    // 커스텀 타이틀
    private let customTitleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "장치연결")
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let findDeviceButton = RideThisButton(buttonTitle: "장치찾기")
    private let emptyLabel = RideThisLabel(fontType: .defaultSize, fontColor: .gray, text: "등록된 장치 없음")
    
    private let viewModel = DeviceViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        bindViewModel()
        setupActions()
        viewModel.loadRegisteredDevices()
    }
    
    
    // MARK: - Setup UI
    private func setupUI() {
        setupNavigationBar()
        setupLayout()
        configureEmptyLabel()
    }
    
    // MARK: - Setup NavigationBar
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
    
    
    // MARK: - Setup Layout
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
    
    // MARK: - Configure EmptyLabel
    private func configureEmptyLabel() {
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
        
        emptyLabel.snp.makeConstraints { emptyLabel in
            emptyLabel.center.equalTo(tableView)
        }
    }
    
    
    // MARK: - Setup TableView
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: DeviceTableViewCell.identifier)
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
    }
    
    
    // MARK: - Setup Actions
    private func setupActions() {
        findDeviceButton.addAction(UIAction { [weak self] _ in
            self?.presentDeviceSearchBottomSheet()
        }, for: .touchUpInside)
    }
    
    
    // MARK: - ViewModel Binding
    /// 데이터 변경 시 UI 업데이트
    private func bindViewModel() {
        viewModel.$devices // viewModel의 Device 목록 구독
            .receive(on: DispatchQueue.main) // Main Thread에서 처리
            .sink { [weak self] devices in
                self?.tableView.reloadData() // 데이터 변경 시 tableView reload
                self?.updateEmptyLabelVisibility(isEmpty: devices.isEmpty) // Device 목록이 비었을 때 lable을 업데이트
            }
            .store(in: &cancellables) // 구독 취소 가능하도록 저장
    }
    
    
    // MARK: - Present Device Search BottomSheet
    private func presentDeviceSearchBottomSheet() {
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
                            self.presentDeviceSearchVC()
                        }
                    } catch {
                        print("Error deleting device: \(error)")
                    }
                }
            }
        } else {
            presentDeviceSearchVC()
        }
    }
    
    /// DeviceSearchViewController를 페이지 시트로 표시하고 기기 검색을 시작하는 함수
    private func presentDeviceSearchVC() {
        let deviceSearchVC = DeviceSearchViewController(viewModel: viewModel)
        deviceSearchVC.modalPresentationStyle = .pageSheet
        
        if let sheet = deviceSearchVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(deviceSearchVC, animated: true) {
            self.viewModel.startDeviceSearch()
        }
    }
    
    /// Device 목록이 비었을 때 빈 레이블 업데이트.
    /// - Parameter isEmpty: Device 목록 비었는지 여부
    private func updateEmptyLabelVisibility(isEmpty: Bool) {
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension DeviceView: UITableViewDelegate, UITableViewDataSource {
    /// numberOfRowsInSection.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.devices.count
    }
    
    /// cellForRowAt.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DeviceTableViewCell.identifier, for: indexPath) as? DeviceTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: viewModel.devices[indexPath.row])
        return cell
    }
    
    /// heightForRowAt.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    /// didSelectRowAt.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedDeviceName = viewModel.devices[indexPath.row].name
        let deviceDetailVC = DeviceDetailViewController(viewModel: viewModel, deviceName: selectedDeviceName)
        
        deviceDetailVC.onDeviceDeleted = { [weak self] in
            self?.viewModel.deleteDevice(selectedDeviceName)
            self?.tableView.reloadData()
        }
        
        navigationController?.pushViewController(deviceDetailVC, animated: true)
    }
}
