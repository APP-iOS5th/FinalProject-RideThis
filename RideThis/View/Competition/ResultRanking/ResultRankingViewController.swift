import UIKit
import SnapKit
import Combine

class ResultRankingViewController: RideThisViewController {
    
    var coordinator: ResultRankingCoordinator?
    
    private let viewModel: ResultRankingViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    private let container: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .leading
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    private let nameLabel = RideThisLabel(fontType: .recordInfo, text: "")
    private let infoLabel = RideThisLabel(fontType: .recordInfo, text: "")
    
    // TableView
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ResultRankingTVCell.self, forCellReuseIdentifier: "ResultRankingTVCell")
        tableView.rowHeight = 41
        
        return tableView
    }()
    
    private let finishBtn = RideThisButton(buttonTitle: "종료")
    private let retryBtn = RideThisButton(buttonTitle: "재도전")
    
    // MARK: 초기화 및 데이터 바인딩
    init(distance: Double) {
        self.viewModel = ResultRankingViewModel(distance: distance, nickName: "")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        setupUI()
        setupBinding()
        setupAction()
    }
    
    // MARK: SetupUI
    private func setupUI() {
        self.title = "경쟁 결과"
        finishBtn.backgroundColor = .black
        
        setupLayout()
    }
    
    // MARK: Setup Binding
    private func setupBinding() {
        // Double -> String으로 변환 소수점 지우기.
        let distanceText = String(format: "%.0f", viewModel.distance)
        
        
        let nameText = "\(viewModel.nickName ?? "")님"
        let attributedName = NSMutableAttributedString(string: nameText)
        
        let range = (nameText as NSString).range(of: viewModel.nickName ?? "")
        attributedName.addAttribute(.foregroundColor, value: UIColor.primaryColor, range: range)
        
        self.nameLabel.attributedText = attributedName
        self.infoLabel.text = "\(distanceText)Km 순위는 0위 입니다."
        
        // Ranking Combined
        self.viewModel.$myRank
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rank in
                let rankingText = "\(rank + 1)"
                self?.infoLabel.text = "\(distanceText)Km 순위는 \(rankingText)위 입니다."
                
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
    }
    
    // MARK: setupLayout
    private func setupLayout() {
        self.view.addSubview(container)
        self.container.addArrangedSubview(nameLabel)
        self.container.addArrangedSubview(infoLabel)
        self.view.addSubview(tableView)
        self.view.addSubview(finishBtn)
        self.view.addSubview(retryBtn)

        let safeArea = self.view.safeAreaLayoutGuide
        
        let screenHeight = UIScreen.main.bounds.height
        
        container.snp.makeConstraints { con in
            con.top.equalTo(safeArea.snp.top).offset(20)
            con.left.equalToSuperview().offset(20)
            con.right.equalToSuperview().offset(-20)
        }
        
        tableView.snp.makeConstraints { table in
            table.top.equalTo(container.snp.bottom).offset(20)
            table.right.equalTo(safeArea.snp.right).offset(-20)
            table.left.equalTo(safeArea.snp.left).offset(20)
            table.bottom.equalTo(finishBtn.snp.top).offset(-30)
        }
        
        finishBtn.snp.makeConstraints { finish in
            if screenHeight < 668 {
                finish.bottom.equalTo(safeArea.snp.bottom).offset(-20)
            } else {
                finish.bottom.equalTo(safeArea.snp.bottom).offset(-50)
            }
            finish.left.equalToSuperview().offset(20)
            finish.right.equalTo(retryBtn.snp.left).offset(-20)
            finish.width.equalTo(retryBtn.snp.width)
        }
        
        retryBtn.snp.makeConstraints { retry in
            if screenHeight < 668 {
                retry.bottom.equalTo(safeArea.snp.bottom).offset(-20)
            } else {
                retry.bottom.equalTo(safeArea.snp.bottom).offset(-50)
            }
            retry.right.equalToSuperview().offset(-20)
            retry.left.equalTo(finishBtn.snp.right).offset(20)
            retry.width.equalTo(finishBtn.snp.width)
        }
    }
    
    // MARK: Setup Button Action
    private func setupAction() {
        finishBtn.addAction(UIAction { [weak self] _ in
            self?.coordinator?.popToRootView()
        }, for: .touchUpInside)
        
        retryBtn.addAction(UIAction { [weak self] _ in
            self?.coordinator?.moveToRetry()
            DeviceManager.shared.isCompetetionUse = true
        }, for: .touchUpInside)
    }
}

// MARK: TableView Delegate
extension ResultRankingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayedRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultRankingTVCell", for: indexPath) as? ResultRankingTVCell else {
            return UITableViewCell()
        }
        let recordTuple = viewModel.displayedRecords[indexPath.row]
        
        // 10위권 단위로 Cell 분기처리
        if self.viewModel.myRank > 8 {
            if recordTuple.index == -1 {
                cell.configure(item: RecordModel(record_timer: "", record_cadence: 0, record_speed: 0, record_distance: 0, record_calories: 0, record_start_time: nil, record_end_time: nil, record_data: nil, record_competetion_status: false, record_target_distance: 0, user_nickname: "SSAM", user_id: "test12"), number: -1, viewModel: self.viewModel)

            } else {
                cell.configure(item: recordTuple.record, number: recordTuple.index, viewModel: self.viewModel)
            }
        } else {
            cell.configure(item: recordTuple.record, number: recordTuple.index, viewModel: self.viewModel)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
}
