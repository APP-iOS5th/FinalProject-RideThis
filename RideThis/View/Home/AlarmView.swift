import Foundation
import UIKit
import SnapKit
import Combine

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
        return AlarmCase.allCases.filter{ $0.rawValue == str }.first!
    }
}

class AlarmView: RideThisViewController {
    
    private let viewModel = AlarmViewModel()
    private var cancellable = Set<AnyCancellable>()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setCombineData()
    }
    
    func configureUI() {
        setTableView()
    }
    
    func setTableView() {
        view.addSubview(alarmTableView)
        
        alarmTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.equalTo(view.snp.left)
            $0.right.equalTo(view.snp.right)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func setCombineData() {
        viewModel.$alarams
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alarm in
                guard let self = self else { return }
                
                self.alarmTableView.reloadData()
            }
            .store(in: &cancellable)
        
        viewModel.fetchAlarmDatas()
    }
}

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
        cell.configureCell(alarmInfo: alarm)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
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
