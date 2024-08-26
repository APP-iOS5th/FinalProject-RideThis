import UIKit
import Combine

// 장치연결 초기 화면
class DeviceView: RideThisViewController {
    
    // 커스텀 타이틀
    private let customTitleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "장치연결")
    
    // TableView
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        return tableView
    }()
    
    // 장치찾기 버튼
    private let competitionBtn = RideThisButton(buttonTitle: "장치찾기")
    
    private let emptyLabel: RideThisLabel = {
        let label = RideThisLabel(fontType: .defaultSize, fontColor: .gray, text: "등록된 장치 없음")
        label.isHidden = true
        return label
    }()
    
    private let viewModel = DeviceViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        bindViewModel()
        
        competitionBtn.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            
            let deviceSearchVC = DeviceSearchViewController(viewModel: viewModel)
            deviceSearchVC.modalPresentationStyle = .pageSheet
            
            if let sheet = deviceSearchVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            self.present(deviceSearchVC, animated: true, completion: nil)
        }, for: .touchUpInside)
    }
    
    private func setupActions() {
        competitionBtn.addAction(UIAction { [weak self] _ in
            self?.presentDeviceSearchBottomSheet()
        }, for: .touchUpInside)
    }
    
    private func presentDeviceSearchBottomSheet() {
        let deviceSearchVC = DeviceSearchViewController(viewModel: viewModel)
        deviceSearchVC.modalPresentationStyle = .pageSheet
        
        if let sheet = deviceSearchVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(deviceSearchVC, animated: true, completion: nil)
    }
    
    // MARK: setupUI
    private func setupUI() {
        setupNavigationBar()
        setupLayout()
        
        view.addSubview(emptyLabel)
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
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
        
        let leftBarButtonItem = UIBarButtonItem(customView: customTitleLabel)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    // MARK: Layout
    private func setupLayout() {
        let safeArea = self.view.safeAreaLayoutGuide
        let screenHeight = UIScreen.main.bounds.height
        
        self.view.addSubview(tableView)
        self.view.addSubview(competitionBtn)
        
        tableView.snp.makeConstraints { table in
            table.top.equalTo(safeArea.snp.top).offset(20)
            table.right.equalTo(safeArea.snp.right).offset(-20)
            table.left.equalTo(safeArea.snp.left).offset(20)
            table.bottom.equalTo(competitionBtn.snp.top).offset(-30)
        }
        
        competitionBtn.snp.makeConstraints { btn in
            if screenHeight < 668 {
                btn.bottom.equalTo(safeArea.snp.bottom).offset(-20)
            } else {
                btn.bottom.equalTo(safeArea.snp.bottom).offset(-50)
            }
            
            btn.right.equalTo(safeArea.snp.right).offset(-20)
            btn.left.equalTo(safeArea.snp.left).offset(20)
        }
    }
    
    // MARK: Setup TableView
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: DeviceTableViewCell.identifier)
    }
    
    // MARK: Binding Data
    private func bindViewModel() {
        viewModel.$devices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] devices in
                self?.tableView.reloadData()
                self?.updateEmptyLabelVisibility(isEmpty: devices.isEmpty)
            }
            .store(in: &cancellables)
    }
    
    private func updateEmptyLabelVisibility(isEmpty: Bool) {
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

// MARK: Extension TableView
extension DeviceView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DeviceTableViewCell.identifier, for: indexPath) as? DeviceTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: viewModel.devices[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
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

// MARK: Preview
#Preview {
    UINavigationController(rootViewController: DeviceView())
}
