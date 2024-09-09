import UIKit
import SnapKit

enum SettingCellCase {
    case navigationLink
    case publicToggle
    case alarmToggle
}

class SettingTableViewCell: UITableViewCell {
    private let settingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let navigationButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .recordTitleColor
        btn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        return btn
    }()
    
    private lazy var publicToggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        
        return toggle
    }()
    
//    private lazy var alarmToggleSwitch: UISwitch = {
//        let toggle = UISwitch()
//        toggle.translatesAutoresizingMaskIntoConstraints = false
//        toggle.addTarget(self, action: #selector(alarmToggleChanged(_:)), for: .valueChanged)
//        
//        return toggle
//    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTable()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTable()
    }
    
    func configureTable() {
        self.contentView.backgroundColor = .white
        [self.settingLabel].forEach{ self.contentView.addSubview($0) }
        
        self.settingLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.contentView.snp.centerY)
            $0.left.equalTo(self.contentView.snp.left).offset(10)
        }
    }
    
    func configureCell(text: String, cellCase: SettingCellCase) {
        self.settingLabel.text = text
        
        switch cellCase {
        case .navigationLink:
            self.navigationButton.isHidden = false
            self.contentView.addSubview(self.navigationButton)
            self.navigationButton.snp.makeConstraints {
                $0.centerY.equalTo(self.contentView.snp.centerY)
                $0.right.equalTo(self.contentView.snp.right).offset(-10)
            }
        case .publicToggle:
            self.publicToggleSwitch.isHidden = false
            if let signedUser = UserService.shared.combineUser {
                self.publicToggleSwitch.setOn(signedUser.user_account_public, animated: false)
            }
            self.contentView.addSubview(self.publicToggleSwitch)
            self.publicToggleSwitch.snp.makeConstraints {
                $0.centerY.equalTo(self.contentView.snp.centerY)
                $0.right.equalTo(self.contentView.snp.right).offset(-10)
            }
        case .alarmToggle:
            self.navigationButton.isHidden = false
            self.contentView.addSubview(self.navigationButton)
            self.navigationButton.snp.makeConstraints {
                $0.centerY.equalTo(self.contentView.snp.centerY)
                $0.right.equalTo(self.contentView.snp.right).offset(-10)
            }
//            self.alarmToggleSwitch.isHidden = false
//            if let signedUser = UserService.shared.combineUser {
//                self.alarmToggleSwitch.setOn(signedUser.user_alarm_status, animated: false)
//            }
//            self.contentView.addSubview(self.alarmToggleSwitch)
//            self.alarmToggleSwitch.snp.makeConstraints {
//                $0.centerY.equalTo(self.contentView.snp.centerY)
//                $0.right.equalTo(self.contentView.snp.right).offset(-10)
//            }
        }
    }
    
    @objc func toggleChanged(_ sender: UISwitch) {
        guard let user = UserService.shared.combineUser else { return }
        let changedUser = User(user_id: user.user_id,
                               user_image: user.user_image,
                               user_email: user.user_email,
                               user_nickname: user.user_nickname,
                               user_weight: user.user_weight,
                               user_tall: user.user_tall,
                               user_following: user.user_following,
                               user_follower: user.user_follower,
                               user_account_public: sender.isOn,
                               user_alarm_status: user.user_alarm_status)
        
        let firebaseService = FireBaseService()
        firebaseService.updateUserInfo(updated: changedUser, update: true)
    }
    
//    @objc func alarmToggleChanged(_ sender: UISwitch) {
//        guard let user = UserService.shared.combineUser else { return }
//        let changedUser = User(user_id: user.user_id,
//                               user_image: user.user_image,
//                               user_email: user.user_email,
//                               user_nickname: user.user_nickname,
//                               user_weight: user.user_weight,
//                               user_tall: user.user_tall,
//                               user_following: user.user_following,
//                               user_follower: user.user_follower,
//                               user_account_public: user.user_account_public,
//                               user_alarm_status: sender.isOn)
//        
//        let firebaseService = FireBaseService()
//        firebaseService.updateUserInfo(updated: changedUser, update: true)
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        settingLabel.text = nil
        
        navigationButton.isHidden = true
        
        publicToggleSwitch.isOn = false
        publicToggleSwitch.isHidden = true
//        alarmToggleSwitch.isOn = false
//        alarmToggleSwitch.isHidden = true
    }
}
