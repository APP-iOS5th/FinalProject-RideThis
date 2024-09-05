import Foundation
import UIKit
import SnapKit
import Combine

// MARK: - Enums

enum AlarmCase: String, CaseIterable {
    case follow = "Follow"
    
    var followForLabel: String {
        get {
            switch self {
            case .follow:
                return "팔로우"
            }
        }
    }
    
    func findCase(str: String) -> Self {
        return AlarmCase.allCases.first { $0.rawValue == str }!
    }
}

// MARK: - AlarmView

class AlarmView: RideThisViewController {
    
    // MARK: - Properties
    
    private let firebaseService = FireBaseService()
    private var cancellable = Set<AnyCancellable>()
    private lazy var viewModel = AlarmViewModel(firebaseService: self.firebaseService)
    
    // MARK: - UI Components
    
    private lazy var alarmTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(AlarmTableViewCell.self, forCellReuseIdentifier: "AlarmTableViewCell")
        table.backgroundColor = .primaryBackgroundColor
        table.separatorStyle = .none
        return table
    }()
    
    private let noAlarmLabel: RideThisLabel = {
        let label = RideThisLabel(fontType: .defaultSize, fontColor: .gray, text: "알람이 없습니다")
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setCombineData()
        setupNavigationBar()
    }
    
    // MARK: - UI Setup
    
    /// UI 구성 요소 설정
    private func configureUI() {
        setTableView()
        setupNoAlarmLabel()
    }
    
    /// NavigationBar 설정
    private func setupNavigationBar() {
        title = "알람 목록"
    }
    
    /// TableView뷰 설정
    private func setTableView() {
        view.addSubview(alarmTableView)
        
        alarmTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.equalTo(view.snp.left)
            $0.right.equalTo(view.snp.right)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    /// '알람 없음' 라벨 설정
    private func setupNoAlarmLabel() {
        view.addSubview(noAlarmLabel)
        noAlarmLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    // MARK: - Data Binding
    
    /// Combine을 사용하여 데이터 바인딩 설정
    private func setCombineData() {
        viewModel.$alarams
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alarms in
                guard let self = self else { return }
                
                self.alarmTableView.reloadData()
                self.updateNoAlarmLabelVisibility()
            }
            .store(in: &cancellable)
        
        viewModel.fetchAlarmDatas()
    }
    
    /// 알람 유무에 따라 '알람 없음' 라벨과 테이블 뷰의 가시성 업데이트
    private func updateNoAlarmLabelVisibility() {
        noAlarmLabel.isHidden = !viewModel.alarams.isEmpty
        alarmTableView.isHidden = viewModel.alarams.isEmpty
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AlarmView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.alarams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmTableViewCell", for: indexPath) as? AlarmTableViewCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        let alarm = viewModel.alarams[indexPath.row]
        cell.configureCell(alarmInfo: alarm, firebaseService: firebaseService)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alarm = viewModel.alarams[indexPath.row]
        if !alarm.alarm_status {
            alarm.alarm_status = true
            if let cell = tableView.cellForRow(at: indexPath) as? AlarmTableViewCell {
                cell.hideUnreadMark()
            }
            viewModel.updateAlarm(user: UserService.shared.combineUser!, alarm: alarm)
        }
    }
}
