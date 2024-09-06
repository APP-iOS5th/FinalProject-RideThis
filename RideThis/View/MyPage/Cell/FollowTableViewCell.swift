import UIKit
import SnapKit
import Kingfisher

enum FollowViewType {
    case followView
    case searchView
}

class FollowTableViewCell: UITableViewCell {
    
    var cellUser: User?
    var signedUser: User?
    var unfollowDelegate: UserUnfollowDelegate?
    private let firebaseService = FireBaseService()
    
    private let profileImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.widthAnchor.constraint(equalToConstant: 80).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 80).isActive = true
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 40
        
        return iv
    }()
    private let userNickName = RideThisLabel()
    private let followButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureCell()
    }
    
    func configureCell() {
        contentView.addSubview(profileImage)
        contentView.addSubview(userNickName)
        contentView.addSubview(followButton)
        
        profileImage.snp.makeConstraints {
            $0.centerY.equalTo(contentView.snp.centerY)
            $0.left.equalTo(contentView.snp.left).offset(10)
        }
        
        followButton.snp.makeConstraints {
            $0.centerY.equalTo(contentView.snp.centerY)
            $0.right.equalTo(contentView.snp.right).offset(-10)
            $0.width.equalTo(80)  // 버튼의 너비를 고정
        }
        
        userNickName.snp.makeConstraints {
            $0.centerY.equalTo(contentView.snp.centerY)
            $0.left.equalTo(profileImage.snp.right).offset(10)
            $0.right.equalTo(followButton.snp.left).offset(-10)
        }
        
        followButton.addAction(UIAction { [weak self] _ in
            guard let self = self, 
                  let btnLabel = self.followButton.titleLabel,
                  let cellUser = self.cellUser,
                  let signedUser = self.signedUser else { return }
            
            if let title = btnLabel.text {
                if title == "Follow" {
                    self.followButton.setTitle("Unfollow", for: .normal)
                    self.followButton.setTitleColor(.systemRed, for: .normal)
                    cellUser.user_follower.append(signedUser.user_id)
                    signedUser.user_following.append(cellUser.user_id)
                    
                    Task {
                        if case .user(let receivedUser) = try await self.firebaseService.fetchUser(at: cellUser.user_id, userType: true) {
                            guard let user = receivedUser else { return }
                            if user.user_alarm_status {
                                self.firebaseService.fetchFCM(signedUser: signedUser, cellUser: cellUser, alarmCase: .follow)
                            }
                        }
                    }
                    firebaseService.updateUserInfo(updated: cellUser, update: false)
                    firebaseService.updateUserInfo(updated: signedUser, update: true)
                } else {
                    unfollowDelegate?.unfollowUser(cellUser: cellUser, signedUser: signedUser) { (updatedCellUser, updatedSignUser) in
                        self.followButton.setTitle("Follow", for: .normal)
                        self.followButton.setTitleColor(.systemBlue, for: .normal)
                        
                        self.firebaseService.updateUserInfo(updated: updatedCellUser, update: false)
                        self.firebaseService.updateUserInfo(updated: updatedSignUser, update: true)
                    }
                }
            }
        }, for: .touchUpInside)
    }
    
    func configureUserInfo(viewType: FollowViewType, followType: FollowType) {
        guard let user = cellUser, let signedUser = signedUser else { return }
        self.userNickName.text = user.user_nickname
        if let imgUrl = user.user_image {
            if imgUrl.isEmpty {
                self.profileImage.image = UIImage(named: "bokdonge")
            } else {
                self.profileImage.kf.setImage(with: URL(string: imgUrl))
            }
        }
        
        var buttonTitle: String = "Follow"
        var buttonColor: UIColor = .systemBlue
        switch viewType {
        case .followView:
            switch followType {
            case .follower:
                if signedUser.user_following.contains(where: { $0 == user.user_id }) {
                    buttonTitle = "Unfollow"
                    buttonColor = .systemRed
                }
            case .following:
                buttonTitle = "Unfollow"
                buttonColor = .systemRed
            }
        case .searchView:
            break
        }
        followButton.setTitle(buttonTitle, for: .normal)
        followButton.setTitleColor(buttonColor, for: .normal)
    }
    
    func updateUserFollowData() {
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = nil // 재사용 문제 방지
    }
}
