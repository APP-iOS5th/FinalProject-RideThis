import UIKit
import SnapKit

class SettingView: RideThisViewController {
    
    var settingCoordinator: SettingCoordinator?
    
    private lazy var settingTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(SettingTableViewCell.self, forCellReuseIdentifier: "SettingTableViewCell")
        table.backgroundColor = .white
        table.layer.cornerRadius = 13
        
        return table
    }()
    
    private let items: [String] = ["계정 설정", "비공개 설정", "알림 설정", "개인정보 처리방침"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "설정"
        setTableView()
        setObserver()
    }
    
    func setTableView() {
        self.view.addSubview(self.settingTableView)
        
        self.settingTableView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.left.equalTo(self.view.snp.left).offset(20)
            $0.right.equalTo(self.view.snp.right).offset(-20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
    
    func setObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appDidBecomeActive() {
        AlarmManager.shared.checkCurrentAlarmStatus() { status in
            guard let currentUser = UserService.shared.combineUser else { return }
            currentUser.user_alarm_status = status
            
            let firebaseService = FireBaseService()
            firebaseService.updateUserInfo(updated: currentUser, update: false)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}

extension SettingView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.item]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as? SettingTableViewCell else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0, 2, 3:
            cell.configureCell(text: item, cellCase: .navigationLink)
        case 1:
            cell.configureCell(text: item, cellCase: .publicToggle)
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let accountSettingCoordinator = AccountSettingCoordinator(navigationController: self.navigationController!)
            self.navigationController?.topViewController?.navigationItem.backButtonTitle = "설정"
            
            accountSettingCoordinator.start()
        } else if indexPath.row == 2 {
            AlarmManager.shared.openAppSettings()
        } else if indexPath.row == 3 {
            settingCoordinator?.showPrivacyPolicy()
        }
    }
}
