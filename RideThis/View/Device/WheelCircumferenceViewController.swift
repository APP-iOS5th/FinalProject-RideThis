import UIKit
import SnapKit

class WheelCircumferenceViewController: UIViewController {
    private let viewModel: DeviceViewModel
    
    // 휠 찾기 레이블
    private let wheelSearchLabel: RideThisLabel = {
        let label = RideThisLabel(fontType: .sectionTitle, fontColor: .black, text: "휠 찾기")
        return label
    }()
    
    // 휠 찾기 텍스트 필드
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "휠 크기를 검색해주세요.(ex: 1020mm)"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.font = UIFont.systemFont(ofSize: FontCase.defaultSize.rawValue)
        return textField
    }()
    
    // 정보 레이블
    private let infoLabel: RideThisLabel = {
        let label = RideThisLabel(
            fontType: .infoMessage,
            fontColor: .recordTitleColor,
            text: "*일반적인 표준 로드 자전거 타이어 크기는 2110(700c X 25)mm이며, 이는 표준 로드 타이어로 직경 약 700mm, 폭 25mm를 나타냅니다."
        )
        label.numberOfLines = 0
        return label
    }()
    
    // 테이블 뷰
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(WheelCircumferenceSelectionCell.self, forCellReuseIdentifier: "WheelCircumferenceSelectionCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .primaryBackgroundColor
        tableView.isScrollEnabled = true
        return tableView
    }()
    
    var selectedCircumference: String?
    var onCircumferenceSelected: ((String) -> Void)?
    
    // MARK: init
    init(viewModel: DeviceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "휠 둘레"
        navigationItem.backButtonTitle = "Back"
        
        setupUI()
        setupTableView()
    }
    
    // MARK: SetupUI
    private func setupUI() {
        view.backgroundColor = .primaryBackgroundColor
        
        view.addSubview(wheelSearchLabel)
        view.addSubview(searchTextField)
        view.addSubview(infoLabel)
        view.addSubview(tableView)
        
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
    
    // MARK: Setup TableView
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: Extension Table
extension WheelCircumferenceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.wheelCircumferences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WheelCircumferenceSelectionCell", for: indexPath) as? WheelCircumferenceSelectionCell else {
            return UITableViewCell()
        }
        
        let wheelCircumference = viewModel.wheelCircumferences[indexPath.row]
        cell.configure(with: wheelCircumference)
        cell.isSelected = wheelCircumference.millimeter == selectedCircumference
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCircumference = viewModel.wheelCircumferences[indexPath.row].millimeter
        self.selectedCircumference = selectedCircumference
        onCircumferenceSelected?(selectedCircumference)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
