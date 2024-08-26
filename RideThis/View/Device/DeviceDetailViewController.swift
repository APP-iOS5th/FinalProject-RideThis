import UIKit
import Combine

class DeviceDetailViewController: RideThisViewController {
    private let viewModel: DeviceViewModel
    private let deviceName: String
    private var cancellables = Set<AnyCancellable>()
    
    /// 장치 정보 테이블뷰
    private let deviceInfoTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .primaryBackgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        return tableView
    }()
    
    /// 휠 둘레 테이블뷰
    private let wheelCircumferenceTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .primaryBackgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        return tableView
    }()
    
    /// 장치 삭제 버튼
    private lazy var deleteDeviceButton: RideThisButton = {
        let button = RideThisButton(buttonTitle: "장치 삭제")
        button.addAction(UIAction { [weak self] _ in
            self?.deleteDeviceTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    // MARK: Init
    init(viewModel: DeviceViewModel, deviceName: String) {
        self.viewModel = viewModel
        self.deviceName = deviceName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableViews()
        bindViewModel()
        viewModel.selectDevice(name: deviceName)
    }
    
    // MARK: Binding Data
    private func bindViewModel() {
        viewModel.$selectedDevice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                guard let device = device else { return }
                self?.updateUI(with: device)
            }
            .store(in: &cancellables)
    }
    
    // MARK: Update UI
    private func updateUI(with device: Device) {
        deviceInfoTableView.reloadData()
        wheelCircumferenceTableView.reloadData()
        updateTableViewHeights()
    }
    
    // MARK: SetupUI
    private func setupUI() {
        title = "장치 상세"
        view.backgroundColor = .primaryBackgroundColor
        
        let safeArea = self.view.safeAreaLayoutGuide
        let screenHeight = UIScreen.main.bounds.height
        
        self.view.addSubview(deviceInfoTableView)
        self.view.addSubview(wheelCircumferenceTableView)
        self.view.addSubview(deleteDeviceButton)
        
        deviceInfoTableView.snp.makeConstraints { diTable in
            diTable.top.equalTo(safeArea.snp.top).offset(20)
            diTable.right.equalTo(safeArea.snp.right).offset(-5)
            diTable.left.equalTo(safeArea.snp.left).offset(5)
            diTable.height.equalTo(220) // 초기 높이 설정
        }
        
        wheelCircumferenceTableView.snp.makeConstraints { wcTable in
            wcTable.top.equalTo(deviceInfoTableView.snp.bottom).offset(10)
            wcTable.right.equalTo(safeArea.snp.right).offset(-5)
            wcTable.left.equalTo(safeArea.snp.left).offset(5)
            wcTable.height.equalTo(100) // 초기 높이 설정
        }
        
        deleteDeviceButton.snp.makeConstraints { btn in
            btn.top.greaterThanOrEqualTo(wheelCircumferenceTableView.snp.bottom).offset(20)
            if screenHeight < 668 {
                btn.bottom.equalTo(safeArea.snp.bottom).offset(-20)
            } else {
                btn.bottom.equalTo(safeArea.snp.bottom).offset(-50)
            }
            btn.right.equalTo(safeArea.snp.right).offset(-20)
            btn.left.equalTo(safeArea.snp.left).offset(20)
        }
    }
    
    // MARK: Update TableView Heights
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewHeights()
    }
    
    private func updateTableViewHeights() {
        deviceInfoTableView.snp.updateConstraints { diTable in
            diTable.height.equalTo(deviceInfoTableView.contentSize.height)
        }
        
        wheelCircumferenceTableView.snp.updateConstraints { wcTable in
            wcTable.height.equalTo(wheelCircumferenceTableView.contentSize.height)
        }
    }
    
    // MARK: TableViews 설정
    private func setupTableViews() {
        deviceInfoTableView.delegate = self
        deviceInfoTableView.dataSource = self
        deviceInfoTableView.register(DeviceInfoTableViewCell.self, forCellReuseIdentifier: DeviceInfoTableViewCell.identifier)
        
        wheelCircumferenceTableView.delegate = self
        wheelCircumferenceTableView.dataSource = self
        wheelCircumferenceTableView.register(WheelCircumferenceTableViewCell.self, forCellReuseIdentifier: WheelCircumferenceTableViewCell.identifier)
        
        deviceInfoTableView.reloadData()
        wheelCircumferenceTableView.reloadData()
    }
    
    var onDeviceDeleted: (() -> Void)?
    
    /// 장치 삭제 버튼
    private func deleteDeviceTapped() {
        showAlert(alertTitle: "장치 삭제", msg: "정말로 이 장치를 삭제하시겠습니까?", confirm: "삭제") { [weak self] in
            guard let self = self else { return }
            self.viewModel.deleteDevice(self.deviceName)
            self.onDeviceDeleted?()
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: Extension TableView
extension DeviceDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == deviceInfoTableView ? 4 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == deviceInfoTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: DeviceInfoTableViewCell.identifier, for: indexPath) as! DeviceInfoTableViewCell
            
            guard let device = viewModel.selectedDevice else { return cell }
            
            let infoData = [
                ("이름", device.name),
                ("일련번호", device.serialNumber),
                ("펌웨어 버전", device.firmwareVersion),
                ("등록 상태", device.registrationStatus)
            ]
            
            let (title, value) = infoData[indexPath.row]
            cell.configure(title: title, value: value)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: WheelCircumferenceTableViewCell.identifier, for: indexPath) as! WheelCircumferenceTableViewCell
            
            cell.configure(title: "휠 둘레", value: viewModel.selectedDevice?.wheelCircumference ?? "")
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == wheelCircumferenceTableView {
            let wheelCircumferenceVC = WheelCircumferenceViewController(viewModel: viewModel)
            wheelCircumferenceVC.selectedCircumference = viewModel.selectedDevice?.wheelCircumference
            wheelCircumferenceVC.onCircumferenceSelected = { [weak self] circumference in
                self?.viewModel.updateWheelCircumference(circumference)
                self?.wheelCircumferenceTableView.reloadData()
            }
            navigationController?.pushViewController(wheelCircumferenceVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
