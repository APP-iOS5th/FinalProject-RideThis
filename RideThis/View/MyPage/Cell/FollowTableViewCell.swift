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
    private let firebaseService = FireBaseService()
    
    private let profileImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.widthAnchor.constraint(equalToConstant: 80).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 80).isActive = true
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 40
        
        return iv
    }()
    private let userNickName = RideThisLabel()
    private let userEmail: UILabel = {
        let label = RideThisLabel(fontColor: .recordTitleColor)
        label.lineBreakMode = .byTruncatingTail // 줄임표 표시 설정
        return label
    }()
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
        contentView.addSubview(userEmail)
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
            $0.centerY.equalTo(contentView.snp.centerY).offset(-15)
            $0.left.equalTo(profileImage.snp.right).offset(10)
            $0.right.equalTo(followButton.snp.left).offset(-10)
        }
        
        userEmail.snp.makeConstraints {
            $0.centerY.equalTo(contentView.snp.centerY).offset(15)
            $0.left.equalTo(userNickName.snp.left)
            $0.right.equalTo(followButton.snp.left).offset(-10)  // followButton 왼쪽에 맞추기
        }
        
        userEmail.numberOfLines = 1
        followButton.addAction(UIAction { [weak self] _ in
            guard let self = self, 
                  let btnLabel = self.followButton.titleLabel,
                  let cellUser = self.cellUser,
                  let signedUser = self.signedUser else { return }
            // 버튼의 title이 Unfollow면 signedUser.user_following에서 cellUser.user_id를 삭제하고 cellUser.user_follower에서 signedUser.user_id를 삭제한다.
            // 근데 바로 tableView에 업데이트 하지않고 title만 Unfollow -> Follow / Follow -> Unfollow로 수정하고 백그라운드에서 firebase에 데이터를 수정한다. 그리고 다시 화면을 띄울 때 적용된 화면을 보여준다
            if let title = btnLabel.text {
                if title == "Follow" {
                    self.followButton.setTitle("Unfollow", for: .normal)
                    self.followButton.setTitleColor(.systemRed, for: .normal)
                    cellUser.user_follower.append(signedUser.user_id)
                    signedUser.user_following.append(cellUser.user_id)
                } else {
                    self.followButton.setTitle("Follow", for: .normal)
                    self.followButton.setTitleColor(.systemBlue, for: .normal)
                    cellUser.user_follower.remove(at: cellUser.user_follower.firstIndex(of: signedUser.user_id)!)
                    signedUser.user_following.remove(at: signedUser.user_following.firstIndex(of: cellUser.user_id)!)
                }
                firebaseService.updateUserInfo(updated: cellUser, update: false)
                firebaseService.updateUserInfo(updated: signedUser, update: true)
            }
        }, for: .touchUpInside)
    }
    
    func configureUserInfo(viewType: FollowViewType, followType: FollowType) {
        guard let user = cellUser, let signedUser = signedUser else { return }
        self.userNickName.text = user.user_nickname
        self.userEmail.text = user.user_email
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
