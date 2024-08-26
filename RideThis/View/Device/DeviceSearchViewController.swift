import UIKit
import SnapKit
import Combine

class DeviceSearchViewController: RideThisViewController {
    
    private let viewModel: DeviceViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let titleLabel = RideThisLabel(fontType: .defaultSize, text: "장치 검색")
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        return button
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryBackgroundColor
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "deviceSearch"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let searchingLabel = RideThisLabel(fontType: .sectionTitle, text: "검색중...")
    
    private let deviceTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = true
        tableView.backgroundColor = .primaryBackgroundColor
        tableView.rowHeight = 44
        return tableView
    }()
    
    private var devices: [String] = ["블루투스 기기 - 1", "블루투스 기기 - 2", "블루투스 기기 - 2", "블루투스 기기 - 2", "블루투스 기기 - 2", "블루투스 기기 - 2", "블루투스 기기 - 2", "블루투스 기기 - 2", "블루투스 기기 - 2", "블루투스 기기 - 2", "블루투스 기기 - 2"]
    
    init(viewModel: DeviceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .primaryBackgroundColor
        
        view.addSubview(titleView)
        titleView.addSubview(titleLabel)
        titleView.addSubview(cancelButton)
        view.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(searchingLabel)
        contentView.addSubview(deviceTableView)
        
        titleView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        searchingLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        deviceTableView.snp.makeConstraints { make in
            make.top.equalTo(searchingLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(9 * 44)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    private func setupTableView() {
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        deviceTableView.register(DeviceSearchTableViewCell.self, forCellReuseIdentifier: DeviceSearchTableViewCell.identifier)
    }
    
    private func setupActions() {
        cancelButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }, for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.$searchedDevices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.deviceTableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension DeviceSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchedDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeviceSearchTableViewCell.identifier, for: indexPath) as! DeviceSearchTableViewCell
        cell.configure(with: viewModel.searchedDevices[indexPath.row].name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDevice = viewModel.searchedDevices[indexPath.row]
        viewModel.addDevice(selectedDevice)
        dismiss(animated: true, completion: nil)
    }
}
