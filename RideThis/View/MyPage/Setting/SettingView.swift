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
        table.backgroundColor = .primaryBackgroundColor
        
        return table
    }()
    
    private let items: [String] = ["계정 설정", "비공개 설정", "알림 설정"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "설정"
        setTableView()
    }
    
    func setTableView() {
        self.view.addSubview(self.settingTableView)
        
        self.settingTableView.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.top)
            $0.left.equalTo(self.view.snp.left)
            $0.right.equalTo(self.view.snp.right)
            $0.bottom.equalTo(self.view.snp.bottom)
        }
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
        case 0:
            cell.configureCell(text: item, cellCase: .navigationLink)
        case 1:
            cell.configureCell(text: item, cellCase: .publicToggle)
        case 2:
            cell.configureCell(text: item, cellCase: .alarmToggle)
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let accountSettingCoordinator = AccountSettingCoordinator(navigationController: self.navigationController!)
            accountSettingCoordinator.start()
        }
    }
}
