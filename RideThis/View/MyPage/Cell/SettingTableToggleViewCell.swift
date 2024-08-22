import UIKit
import SnapKit

class SettingTableToggleViewCell: UITableViewCell {
    private let settingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        if let signedUser = UserService.shared.combineUser {
            toggle.setOn(signedUser.user_account_public, animated: false)
        }
        toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        
        return toggle
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureCell()
    }
    
    private func configureCell() {
        self.contentView.backgroundColor = .primaryBackgroundColor
        [self.settingLabel, self.toggleSwitch].forEach{ self.contentView.addSubview($0) }
        
        settingLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.contentView.snp.centerY)
            $0.left.equalTo(self.contentView.snp.left).offset(10)
        }
        
        toggleSwitch.snp.makeConstraints {
            $0.centerY.equalTo(self.contentView.snp.centerY)
            $0.right.equalTo(self.contentView.snp.right).offset(-10)
        }
        
    }
    
    func configureCell(text: String) {
        self.settingLabel.text = text
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
        firebaseService.editProfileInfo(user: changedUser)
    }
}
