import UIKit
import SnapKit
import Combine

class DeviceSearchView: RideThisViewController {
    // MARK: - Properties
    var coordinator: DeviceSearchCoordinator?
    
    private let viewModel: DeviceViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let titleView = UIView()
    private let titleLabel = RideThisLabel(fontType: .defaultSize, text: "장치 검색")
    private let cancelButton = UIButton(type: .system)
    private let contentView = UIView()
    private let imageView = UIImageView(image: UIImage(named: "deviceSearch"))
    private let searchingLabel = RideThisLabel(fontType: .sectionTitle, text: "검색중...")
    private let deviceTableView = UITableView(frame: .zero, style: .insetGrouped)
    private var isProcessingSelection = false
    
    // MARK: - Initialization
    
    /// DeviceSearchView의 새 인스턴스를 초기화
    /// - Parameter viewModel: DeviceSearchView에서 사용할 ViewModel
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
        setupActions()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.startDeviceSearch()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopDeviceSearch()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        configureViewHierarchy()
        configureViewProperties()
        setupConstraints()
    }
    
    /// subViews를 추가하여 뷰 계층 구성
    private func configureViewHierarchy() {
        view.addSubview(titleView)
        titleView.addSubview(titleLabel)
        titleView.addSubview(cancelButton)
        
        view.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(searchingLabel)
        contentView.addSubview(deviceTableView)
    }
    
    /// View 속성 구성
    private func configureViewProperties() {
        view.backgroundColor = .primaryBackgroundColor
        titleView.backgroundColor = .white
        contentView.backgroundColor = .primaryBackgroundColor
        imageView.contentMode = .scaleAspectFit
        cancelButton.setTitle("Cancel", for: .normal)
        configureTableView()
    }
    
    /// 뷰 제약 조건 설정
    private func setupConstraints() {
        titleView.snp.makeConstraints { titleView in
            titleView.top.left.right.equalToSuperview()
            titleView.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { titleLabel in
            titleLabel.center.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { cancelBtn in
            cancelBtn.left.equalToSuperview().offset(16)
            cancelBtn.centerY.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { contentView in
            contentView.top.equalTo(titleView.snp.bottom)
            contentView.left.right.bottom.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { imageView in
            imageView.top.equalToSuperview().offset(40)
            imageView.centerX.equalToSuperview()
            imageView.width.height.equalTo(100)
        }
        
        searchingLabel.snp.makeConstraints { searchingLabel in
            searchingLabel.top.equalTo(imageView.snp.bottom).offset(20)
            searchingLabel.centerX.equalToSuperview()
        }
        
        deviceTableView.snp.makeConstraints { deviceTableView in
            deviceTableView.top.equalTo(searchingLabel.snp.bottom).offset(20)
            deviceTableView.left.right.equalToSuperview()
            deviceTableView.height.equalTo(9 * 44)
            deviceTableView.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    /// TableView 구성
    private func configureTableView() {
        deviceTableView.translatesAutoresizingMaskIntoConstraints = false
        deviceTableView.layer.cornerRadius = 10
        deviceTableView.clipsToBounds = true
        deviceTableView.isScrollEnabled = true
        deviceTableView.backgroundColor = .primaryBackgroundColor
        deviceTableView.rowHeight = 44
    }
    
    /// TableView의 delegate와 dataSource를 설정하고 cell을 등록
    private func setupTableView() {
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        deviceTableView.register(DeviceSearchTableViewCell.self, forCellReuseIdentifier: DeviceSearchTableViewCell.identifier)
    }
    
    /// 버튼 액션 설정
    private func setupActions() {
        cancelButton.addAction(UIAction { [weak self] _ in
            self?.coordinator?.dismissView()
        }, for: .touchUpInside)
    }
    
    // MARK: - ViewModel Binding
    
    /// ViewModel과 View를 바인딩
    private func bindViewModel() {
        viewModel.$searchedDevices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.deviceTableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension DeviceSearchView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchedDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeviceSearchTableViewCell.identifier, for: indexPath) as! DeviceSearchTableViewCell
        cell.configure(with: viewModel.searchedDevices[indexPath.row].name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isProcessingSelection else { return }
        isProcessingSelection = true
        
        let selectedDevice = viewModel.searchedDevices[indexPath.row]
        
        if UserService.shared.loginStatus == .appleLogin {
            Task {
                do {
                    try await viewModel.addDeviceWithDefaultSettings(selectedDevice)
                    DispatchQueue.main.async {
                        self.coordinator?.dismissView()
                    }
                } catch {
                    print("Error adding device: \(error)")
                }
                isProcessingSelection = false
            }
        } else {
            self.viewModel.addDeviceUnkownedUser(selectedDevice)
            
            DispatchQueue.main.async {
                self.coordinator?.dismissView()
            }
            
            isProcessingSelection = false
        }
        
        
    }
}
