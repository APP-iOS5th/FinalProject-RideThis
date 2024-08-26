import UIKit
import SnapKit

class WheelCircumferenceViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: DeviceViewModel
    private let wheelSearchLabel = RideThisLabel(fontType: .sectionTitle,
                                                 fontColor: .black,
                                                 text: "휠 찾기")
    private let searchTextField = UITextField()
    private let infoLabel = RideThisLabel(fontType: .infoMessage, 
                                          fontColor: .recordTitleColor,
                                          text: "*일반적인 표준 로드 자전거 타이어 크기는 2110(700c X 25)mm이며, 이는 표준 로드 타이어로 직경 약 700mm, 폭 25mm를 나타냅니다.")
    private let tableView = UITableView(frame: .zero,
                                        style: .insetGrouped)
    
    var selectedCircumference: String?
    var onCircumferenceSelected: ((String) -> Void)?
    
    
    // MARK: - Initialization
    /// WheelCircumferenceViewController를 주어진 ViewModel로 초기화.
    /// - Parameter viewModel: WheelCircumferenceViewController에서 사용할 ViewModel.
    init(viewModel: DeviceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupTableView()
    }
    
    
    // MARK: - Setup NavigationBar
    private func setupNavigationBar() {
        title = "휠 둘레"
        navigationItem.backButtonTitle = "Back"
    }
    
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .primaryBackgroundColor
        
        configureSearchTextField()
        configureInfoLabel()
        configureTableView()
        
        addSubviews()
        setupConstraints()
    }
    
    
    // MARK: - Configure SearchTextField
    private func configureSearchTextField() {
        searchTextField.placeholder = "휠 크기를 검색해주세요.(ex: 1020mm)"
        searchTextField.borderStyle = .roundedRect
        searchTextField.backgroundColor = .white
        searchTextField.font = UIFont.systemFont(ofSize: FontCase.defaultSize.rawValue)
    }
    
    
    // MARK: - Configure InfoLabel
    private func configureInfoLabel() {
        infoLabel.numberOfLines = 0
    }
    
    
    // MARK: - Configure TableView
    private func configureTableView() {
        tableView.register(WheelCircumferenceSelectionCell.self, forCellReuseIdentifier: "WheelCircumferenceSelectionCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .primaryBackgroundColor
        tableView.isScrollEnabled = true
    }
    
    
    // MARK: - Add Subviews
    private func addSubviews() {
        view.addSubview(wheelSearchLabel)
        view.addSubview(searchTextField)
        view.addSubview(infoLabel)
        view.addSubview(tableView)
    }
    
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        wheelSearchLabel.snp.makeConstraints { wheelSearchLabel in
            wheelSearchLabel.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            wheelSearchLabel.left.right.equalToSuperview().inset(20)
        }
        
        searchTextField.snp.makeConstraints { searchTextField in
            searchTextField.top.equalTo(wheelSearchLabel.snp.bottom).offset(10)
            searchTextField.left.right.equalToSuperview().inset(20)
            searchTextField.height.equalTo(45)
        }
        
        infoLabel.snp.makeConstraints { infoLabel in
            infoLabel.top.equalTo(searchTextField.snp.bottom).offset(10)
            infoLabel.left.right.equalToSuperview().inset(20)
        }
        
        tableView.snp.makeConstraints { tableView in
            tableView.top.equalTo(infoLabel.snp.bottom).offset(10)
            tableView.left.equalTo(infoLabel.snp.left).offset(-20)
            tableView.right.equalTo(infoLabel.snp.right).offset(20)
            tableView.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    
    // MARK: - Setup TableView
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension WheelCircumferenceViewController: UITableViewDelegate, UITableViewDataSource {
    /// numberOfRowsInSection.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.wheelCircumferences.count
    }
    
    /// cellForRowAt.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WheelCircumferenceSelectionCell", for: indexPath) as? WheelCircumferenceSelectionCell else {
            return UITableViewCell()
        }
        
        let wheelCircumference = viewModel.wheelCircumferences[indexPath.row]
        cell.configure(with: wheelCircumference)
        cell.isSelected = wheelCircumference.millimeter == selectedCircumference
        
        return cell
    }
    
    /// didSelectRowAt.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCircumference = viewModel.wheelCircumferences[indexPath.row].millimeter
        self.selectedCircumference = selectedCircumference
        onCircumferenceSelected?(selectedCircumference)
        tableView.reloadData()
    }
    
    /// heightForRowAt.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
