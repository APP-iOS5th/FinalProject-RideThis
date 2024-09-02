import UIKit
import Combine

class DeviceDetailView: RideThisViewController {
    // MARK: - Properties
    private let viewModel: DeviceViewModel
    private let deviceName: String
    private var cancellables = Set<AnyCancellable>()

    private let deviceInfoTableView = UITableView(frame: .zero, style: .insetGrouped)
    private let wheelCircumferenceTableView = UITableView(frame: .zero, style: .insetGrouped)
    private lazy var deleteDeviceButton = RideThisButton(buttonTitle: "장치 삭제")
    
    var onDeviceDeleted: (() -> Void)?
    
    
    // MARK: - Initialization
    
    /// DeviceDetailViewController 새 인스턴스 초기화
    /// - Parameters:
    ///   - viewModel: DeviceDetailViewController에서 사용할 viewModel
    ///   - deviceName: 표시할 Device 이름
    init(viewModel: DeviceViewModel, deviceName: String) {
        self.viewModel = viewModel
        self.deviceName = deviceName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableViews()
        bindViewModel()
        viewModel.selectDevice(name: deviceName)
    }
    
    
    // MARK: - ViewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewHeights()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = "장치 상세"
        view.backgroundColor = .primaryBackgroundColor
        setupLayout()
        setupDeleteButton()
    }
    
    
    // MARK: - Setup Layout
    private func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide
        let screenHeight = UIScreen.main.bounds.height
        
        [deviceInfoTableView, wheelCircumferenceTableView, deleteDeviceButton].forEach { view.addSubview($0) }
        
        setupDeviceInfoTableViewConstraints(safeArea)
        setupWheelCircumferenceTableViewConstraints(safeArea)
        setupDeleteButtonConstraints(safeArea, screenHeight)
    }
    
    /// 장치 정보 TableView 제약 조건 설정
    /// - Parameter safeArea: View의 safeArea 가이드
    private func setupDeviceInfoTableViewConstraints(_ safeArea: UILayoutGuide) {
        deviceInfoTableView.snp.makeConstraints { deviceInfoTableView in
            deviceInfoTableView.top.equalTo(safeArea.snp.top).offset(20)
            deviceInfoTableView.right.equalTo(safeArea.snp.right).offset(-5)
            deviceInfoTableView.left.equalTo(safeArea.snp.left).offset(5)
            deviceInfoTableView.height.equalTo(220)
        }
    }
    
    /// 휠 둘레 TableView 제약 조건 설정
    /// - Parameter safeArea: View의 safeArea 가이드
    private func setupWheelCircumferenceTableViewConstraints(_ safeArea: UILayoutGuide) {
        wheelCircumferenceTableView.snp.makeConstraints { wheelCircumferenceTableView in
            wheelCircumferenceTableView.top.equalTo(deviceInfoTableView.snp.bottom).offset(10)
            wheelCircumferenceTableView.right.equalTo(safeArea.snp.right).offset(-5)
            wheelCircumferenceTableView.left.equalTo(safeArea.snp.left).offset(5)
            wheelCircumferenceTableView.height.equalTo(100)
        }
    }
    
    /// DeleteButton 제약 조건 설정
    /// - Parameters:
    ///   - safeArea: View의 safeArea 가이드
    ///   - screenHeight: 화면 높이
    private func setupDeleteButtonConstraints(_ safeArea: UILayoutGuide, _ screenHeight: CGFloat) {
        deleteDeviceButton.snp.makeConstraints { deleteDeviceButton in
            deleteDeviceButton.top.greaterThanOrEqualTo(wheelCircumferenceTableView.snp.bottom).offset(20)
            deleteDeviceButton.bottom.equalTo(safeArea.snp.bottom).offset(screenHeight < 668 ? -20 : -50)
            deleteDeviceButton.right.equalTo(safeArea.snp.right).offset(-20)
            deleteDeviceButton.left.equalTo(safeArea.snp.left).offset(20)
        }
    }
    
    
    // MARK: - Setup DeleteButton
    private func setupDeleteButton() {
        deleteDeviceButton.addAction(UIAction { [weak self] _ in
            self?.deleteDeviceTapped()
        }, for: .touchUpInside)
    }
    
    
    // MARK: - Setup TableViews
    private func setupTableViews() {
        [deviceInfoTableView, wheelCircumferenceTableView].forEach { configureTableView($0) }
        
        deviceInfoTableView.register(DeviceInfoTableViewCell.self, forCellReuseIdentifier: DeviceInfoTableViewCell.identifier)
        wheelCircumferenceTableView.register(WheelCircumferenceTableViewCell.self, forCellReuseIdentifier: WheelCircumferenceTableViewCell.identifier)
        
        deviceInfoTableView.reloadData()
        wheelCircumferenceTableView.reloadData()
    }
    
    /// TableView 공통 속성 설정
    /// - Parameter tableView: 설정할 tableView
    private func configureTableView(_ tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .primaryBackgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.$selectedDevice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                guard let device = device else { return }
                self?.updateUI(with: device)
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - UI Updates
    
    /// Device Data를 사용하여 UI 업데이트
    /// - Parameter device: 표시할 Device Data
    private func updateUI(with device: Device) {
        deviceInfoTableView.reloadData()
        wheelCircumferenceTableView.reloadData()
        updateTableViewHeights()
    }
    
    /// TableView content에 따라 높이 업데이트
    private func updateTableViewHeights() {
        deviceInfoTableView.layoutIfNeeded()
        wheelCircumferenceTableView.layoutIfNeeded()
        
        deviceInfoTableView.snp.updateConstraints { deviceInfoTV in
            deviceInfoTV.height.equalTo(deviceInfoTableView.contentSize.height)
        }
        
        wheelCircumferenceTableView.snp.updateConstraints { wheelCircumferenceTV in
            wheelCircumferenceTV.height.equalTo(wheelCircumferenceTableView.contentSize.height)
        }
    }
    
    
    // MARK: - Actions
    /// deleteDeviceButton을 눌렀을 때 실행
    private func deleteDeviceTapped() {
        showAlert(alertTitle: "장치 삭제", msg: "정말로 이 장치를 삭제하시겠습니까?", confirm: "삭제") { [weak self] in
            guard let self = self else { return }
            Task {
                do {
                    try await self.viewModel.deleteDeviceFromFirebase(self.deviceName)
                    DispatchQueue.main.async {
                        self.viewModel.deleteDevice(self.deviceName)
                        self.onDeviceDeleted?()
                        self.navigationController?.popViewController(animated: true)
                    }
                } catch {
                    print("Error deleting device: \(error)")
                }
            }
        }
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension DeviceDetailView: UITableViewDelegate, UITableViewDataSource {
    /// numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == deviceInfoTableView ? 4 : 1
    }
    
    /// cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == deviceInfoTableView {
            return configureDeviceInfoCell(for: indexPath)
        } else {
            return configureWheelCircumferenceCell(for: indexPath)
        }
    }
    
    /// didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == wheelCircumferenceTableView {
            presentWheelCircumferenceViewController()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /// DeviceInfoTableView Cell 구성하고 반환
    /// - Parameter indexPath: Cell 인덱스 경로
    /// - Returns: 구성된 UITableViewCell
    private func configureDeviceInfoCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = deviceInfoTableView.dequeueReusableCell(withIdentifier: DeviceInfoTableViewCell.identifier, for: indexPath) as! DeviceInfoTableViewCell
        
        guard let device = viewModel.selectedDevice else { return cell }
        
        let infoData: [(String, String)] = [
            ("이름", device.name),
            ("일련번호", device.serialNumber),
            ("펌웨어 버전", device.firmwareVersion),
            ("등록 상태", device.registrationStatus ? "등록" : "미등록")
        ]
        
        let (title, value) = infoData[indexPath.row]
        cell.configure(title: title, value: value, isSerialNumber: indexPath.row == 1)

        return cell
    }
    
    /// 테이블 뷰의 각 행의 높이 결정
    /// - Parameters:
    ///   - tableView: 높이 요청하는 테이블 뷰
    ///   - indexPath: 높이 요청하는 행의 인덱스
    /// - Returns: 해당 행의 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == deviceInfoTableView && indexPath.row == 1 {
            return 85
        }
        return UITableView.automaticDimension
    }
        
    /// 휠 둘레 tableView Cell 구성하고 반환
    /// - Parameter indexPath: Cell 인덱스 경로
    /// - Returns: 구성된 UITableViewCell
    private func configureWheelCircumferenceCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = wheelCircumferenceTableView.dequeueReusableCell(withIdentifier: WheelCircumferenceTableViewCell.identifier, for: indexPath) as! WheelCircumferenceTableViewCell

        if let wheelCircumference = viewModel.selectedDevice?.wheelCircumference {
            cell.configure(title: "휠 둘레", value: "\(wheelCircumference)mm")
        } else {
            cell.configure(title: "휠 둘레", value: "")
        }

        return cell
    }
    
    /// 휠 둘레 선택 화면 표시
    private func presentWheelCircumferenceViewController() {
        let wheelCircumferenceVC = WheelCircumferenceView(viewModel: viewModel)
        
        if let selectedDevice = viewModel.selectedDevice {
            wheelCircumferenceVC.selectedCircumference = (selectedDevice.wheelCircumference, selectedDevice.name)
        }
        
        wheelCircumferenceVC.onCircumferenceSelected = { [weak self] (millimeter: Int, tireSize: String) in
            Task {
                do {
                    try await self?.viewModel.updateWheelCircumferenceInFirebase(millimeter)
                    DispatchQueue.main.async {
                        self?.wheelCircumferenceTableView.reloadData()
                    }
                } catch {
                    print("Error updating wheel circumference: \(error)")
                }
            }
        }
        
        navigationController?.pushViewController(wheelCircumferenceVC, animated: true)
    }
}
