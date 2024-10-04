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
            
            Task {
                if case .user(let currentUser) = try await self.firebaseService.fetchUser(at: signedUser.user_id, userType: true),
                   case .user(let selectedUser) = try await self.firebaseService.fetchUser(at: cellUser.user_id, userType: true),
                   let currentUser = currentUser, let selectedUser = selectedUser {
                    if let title = btnLabel.text {
                        if title == "Follow" {
                            self.followButton.setTitle("Unfollow", for: .normal)
                            self.followButton.setTitleColor(.systemRed, for: .normal)
                            currentUser.user_following.append(selectedUser.user_id)
                            selectedUser.user_follower.append(currentUser.user_id)
                            
                            if selectedUser.user_alarm_status {
                                self.firebaseService.fetchFCM(signedUser: currentUser, cellUser: selectedUser, alarmCase: .follow)
                            }
                            
                            self.firebaseService.updateUserInfo(updated: selectedUser, update: false)
                            self.firebaseService.updateUserInfo(updated: currentUser, update: true)
                        } else {
                            self.unfollowDelegate?.unfollowUser(cellUser: selectedUser, signedUser: currentUser) { (updatedCellUser, updatedSignUser) in
                                self.followButton.setTitle("Follow", for: .normal)
                                self.followButton.setTitleColor(.systemBlue, for: .normal)
                                
                                self.firebaseService.updateUserInfo(updated: updatedCellUser, update: false)
                                self.firebaseService.updateUserInfo(updated: updatedSignUser, update: true)
                            }
                        }
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
