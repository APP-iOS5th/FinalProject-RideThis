import UIKit
import SnapKit

enum SettingCellCase {
    case navigationLink
    case toggleButton
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
    
    private lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        return toggle
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTable()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTable()
    }
    
    func configureTable() {
        self.contentView.backgroundColor = .primaryBackgroundColor
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
        case .toggleButton:
            self.toggleSwitch.isHidden = false
            if let signedUser = UserService.shared.combineUser {
                self.toggleSwitch.setOn(signedUser.user_account_public, animated: false)
            }
            self.contentView.addSubview(self.toggleSwitch)
            self.toggleSwitch.snp.makeConstraints {
                $0.centerY.equalTo(self.contentView.snp.centerY)
                $0.right.equalTo(self.contentView.snp.right).offset(-10)
            }
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
                               user_account_public: sender.isOn)
        
        let firebaseService = FireBaseService()
        firebaseService.updateUserInfo(updated: changedUser, update: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        settingLabel.text = nil
        
        navigationButton.isHidden = true
        
        toggleSwitch.isOn = false
        toggleSwitch.isHidden = true
    }
}
