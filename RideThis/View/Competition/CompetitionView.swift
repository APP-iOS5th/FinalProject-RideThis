import UIKit
import SnapKit
import Combine

// 경쟁 탭 초기 화면
class CompetitionView: RideThisViewController {
    
    var coordinator: CompetitionCoordinator?
    
    private let viewModel = CompetitionViewModel(isLogin: false, nickName: "")
    
    private var cancellables = Set<AnyCancellable>()
    
    // 커스텀 타이틀
    private let customTitleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "경쟁")
    
    // Segment(전체 순위, 팔로잉 순위)
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: RankingSegment.allCases.map { $0.rawValue })
        control.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold)], for: .selected)
        control.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)], for: .normal)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // 드롭다운 메뉴 버튼
    private let dropdownButton: UIButton = {
        let button = UIButton(type: .custom)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(red: 246/255, green: 246/255, blue: 245/255, alpha: 1)
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 0)
        
        var titleAttr = AttributedString("5Km")
        titleAttr.font = .systemFont(ofSize: 17, weight: .semibold)
        config.attributedTitle = titleAttr
        
        button.configuration = config
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // TableView
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CompetitionTVCell.self, forCellReuseIdentifier: "CompetitionTVCell")
        
        return tableView
    }()
    
    
    // 로그인 안되어 있을경우 문구
    private let loginLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black, text: "로그인 후 사용해주세요.")
    
    // 로그인 유도 버튼
    private let loginButton: UIButton = {
        let button = UIButton(type: .custom)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .systemBackground
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        
        var titleAttr = AttributedString("로그인")
        titleAttr.font = .systemFont(ofSize: 24, weight: .semibold)
        config.attributedTitle = titleAttr
        
        button.configuration = config
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // 기록 없을시 문구
    private let noRecordLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black, text: "순위에 등록된 인원이 없습니다.")
    
    // 경쟁하기 버튼
    private let competitionBtn = RideThisButton(buttonTitle: "경쟁하기", height: 50)
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupUI()
        setupDropdownMenu()
        setupBinding()
        setupAction()
    }
    
    // MARK: ViewWillAppear
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          
          // 데이터를 새로고침
          self.viewModel.fetchAllRecords()
          self.viewModel.checkBluetoothStatus()
      }
    
    // MARK: setupUI
    private func setupUI() {
        
        setupNavigationBar()
        setupLayout()
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
        
        // 커스텀 타이틀 레이블을 왼쪽 바 버튼 아이템으로 설정
        let leftBarButtonItem = UIBarButtonItem(customView: customTitleLabel)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    // MARK: Layout
    private func setupLayout() {
        let safeArea = self.view.safeAreaLayoutGuide
        
        self.view.addSubview(segmentedControl)
        self.view.addSubview(dropdownButton)
        self.view.addSubview(tableView)
        self.view.addSubview(loginLabel)
        self.view.addSubview(loginButton)
        self.view.addSubview(noRecordLabel)
        self.view.addSubview(competitionBtn)
        
        let screenHeight = UIScreen.main.bounds.height
        
        
        segmentedControl.snp.makeConstraints { segment in
            segment.top.equalTo(safeArea.snp.top).offset(20)
            segment.right.equalTo(safeArea.snp.right).offset(-20)
            segment.left.equalTo(safeArea.snp.left).offset(20)
            if screenHeight < 668 {
                segment.height.equalTo(30)
            } else {
                segment.height.equalTo(40)
            }
        }
        
        dropdownButton.snp.makeConstraints { drop in
            drop.top.equalTo(segmentedControl.snp.bottom).offset(20)
            drop.left.equalTo(safeArea.snp.left).offset(20)
            drop.width.equalTo(safeArea.snp.width).multipliedBy(0.5)
            drop.height.equalTo(safeArea.snp.height).multipliedBy(0.05)
        }
        
        tableView.snp.makeConstraints { table in
            table.top.equalTo(dropdownButton.snp.bottom).offset(10)
            table.right.equalTo(safeArea.snp.right).offset(-20)
            table.left.equalTo(safeArea.snp.left).offset(20)
            table.bottom.equalTo(competitionBtn.snp.top).offset(-30)
        }
        
        loginLabel.snp.makeConstraints { label in
            label.centerX.equalTo(safeArea.snp.centerX)
            label.centerY.equalTo(safeArea.snp.centerY)
        }
        
        loginButton.snp.makeConstraints { button in
            button.centerX.equalTo(safeArea.snp.centerX)
            button.top.equalTo(loginLabel.snp.bottom).offset(20)
        }
        
        noRecordLabel.snp.makeConstraints { label in
            label.centerX.equalTo(safeArea.snp.centerX)
            label.centerY.equalTo(safeArea.snp.centerY)
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
    
    // MARK: Binding Data
    private func setupBinding() {
        self.viewModel.$records
            .receive(on: DispatchQueue.main)
            .sink { [weak self] records in
                self?.updateUI(for: records)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(for records: [RecordModel]) {
        let isLoggedIn = self.viewModel.isLogin
        let isFollowingSegmentSelected = self.viewModel.selectedSegment.rawValue == "팔로잉 순위"
        
        // isLoggedIn 명확하게 보기 위해 == false 사용
        if isLoggedIn == false && isFollowingSegmentSelected {
            tableView.isHidden = true
            noRecordLabel.isHidden = true
            loginLabel.isHidden = false
            loginButton.isHidden = false
        } else if records.isEmpty {
            tableView.isHidden = true
            noRecordLabel.isHidden = false
            loginLabel.isHidden = true
            loginButton.isHidden = true
        } else {
            tableView.isHidden = false
            noRecordLabel.isHidden = true
            loginLabel.isHidden = true
            loginButton.isHidden = true
            tableView.reloadData()
        }
    }
    
    // MARK: 구간설정(DropDown Menu)
    private func setupDropdownMenu() {
        var menuItems: [UIAction] = []
        
        for distance in DistanceCase.allCases {
            let action = UIAction(title: "\(distance.rawValue)Km") { [weak self] action in
                self?.dropdownButton.setTitle("\(distance.rawValue)Km", for: .normal)
                self?.viewModel.selectedDistance(selected: distance)
            }
            menuItems.append(action)
        }
        
        let menu = UIMenu(children: menuItems)
        dropdownButton.menu = menu
        dropdownButton.showsMenuAsPrimaryAction = true
    }
    
    // MARK: Segment Control Action
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        if let selectedStatus = RankingSegment(rawValue: sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "") {
            self.viewModel.selectedSegment(selected: selectedStatus)
        }
    }
    
    // MARK: Button Action
    private func setupAction() {
        competitionBtn.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            
            if self.viewModel.isLogin {
                if self.viewModel.isBluetooth {
                    self.coordinator?.moveToDistanceSelectionView()
                } else {
                    showAlert(alertTitle: "장치연결이 필요합니다.", msg: "사용하시려면 장치를 연결해주세요.", confirm: "장치연결") {
                        self.coordinator?.moveToDeviceView()
                    }
                }
            } else {
                showAlert(alertTitle: "로그인이 필요합니다.", msg: "경쟁하기는 로그인이 필요한 서비스입니다.", confirm: "로그인") {
                    // 코디네이터 패턴(개발 예정)
                    let loginVC = LoginView()
                    self.navigationController?.pushViewController(loginVC, animated: true)
                }
            }
            
        }, for: .touchUpInside)
        
        loginButton.addAction(UIAction { [weak self] _ in
            let loginVC = LoginView()
            self?.navigationController?.pushViewController(loginVC, animated: true)
        }, for: .touchUpInside)
    }
}

// MARK: Extension TableView
extension CompetitionView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompetitionTVCell", for: indexPath) as! CompetitionTVCell
        
        let record = self.viewModel.records[indexPath.row]
        cell.selectionStyle = .none
        cell.configure(item: record, number: indexPath.row, viewModel: self.viewModel)
        
        return cell
    }
}

#Preview {
    UINavigationController(rootViewController: CompetitionView())
}
