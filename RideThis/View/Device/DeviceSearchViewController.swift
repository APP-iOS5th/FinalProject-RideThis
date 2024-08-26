import UIKit
import SnapKit
import Combine

class DeviceSearchViewController: RideThisViewController {
    // MARK: - Properties
    private let viewModel: DeviceViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let titleView = UIView()
    private let titleLabel = RideThisLabel(fontType: .defaultSize, text: "장치 검색")
    private let cancelButton = UIButton(type: .system)
    private let contentView = UIView()
    private let imageView = UIImageView(image: UIImage(named: "deviceSearch"))
    private let searchingLabel = RideThisLabel(fontType: .sectionTitle, text: "검색중...")
    private let deviceTableView = UITableView(frame: .zero, style: .insetGrouped)
    
    
    // MARK: - Initialization
    
    /// DeviceSearchViewController를 주어진 ViewModel로 초기화.
    /// - Parameter viewModel: DeviceSearchViewController에서 사용할 ViewModel.
    init(viewModel: DeviceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        bindViewModel()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        configureViewHierarchy()
        configureViewProperties()
        setupConstraints()
    }
    
    /// subViews를 추가하여 뷰 계층 구성.
    private func configureViewHierarchy() {
        view.addSubview(titleView)
        titleView.addSubview(titleLabel)
        titleView.addSubview(cancelButton)
        
        view.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(searchingLabel)
        contentView.addSubview(deviceTableView)
    }
    
    // MARK: - Configure View Properties
    private func configureViewProperties() {
        view.backgroundColor = .primaryBackgroundColor
        titleView.backgroundColor = .white
        contentView.backgroundColor = .primaryBackgroundColor
        imageView.contentMode = .scaleAspectFit
        cancelButton.setTitle("Cancel", for: .normal)
        configureTableView()
    }
    
    // MARK: - Setup Constraints
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
    
    // MARK: - Configure TableView
    private func configureTableView() {
        deviceTableView.translatesAutoresizingMaskIntoConstraints = false
        deviceTableView.layer.cornerRadius = 10
        deviceTableView.clipsToBounds = true
        deviceTableView.isScrollEnabled = true
        deviceTableView.backgroundColor = .primaryBackgroundColor
        deviceTableView.rowHeight = 44
    }
    
    // MARK: - Setup TableView
    private func setupTableView() {
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        deviceTableView.register(DeviceSearchTableViewCell.self, forCellReuseIdentifier: DeviceSearchTableViewCell.identifier)
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        cancelButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }, for: .touchUpInside)
    }
    
    // MARK: - ViewModel Binding
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
extension DeviceSearchViewController: UITableViewDelegate, UITableViewDataSource {
    /// numberOfRowsInSection.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchedDevices.count
    }
    
    /// cellForRowAt.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeviceSearchTableViewCell.identifier, for: indexPath) as! DeviceSearchTableViewCell
        cell.configure(with: viewModel.searchedDevices[indexPath.row].name)
        return cell
    }
    
    /// didSelectRowAt.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDevice = viewModel.searchedDevices[indexPath.row]
        viewModel.addDevice(selectedDevice)
        dismiss(animated: true, completion: nil)
    }
}
