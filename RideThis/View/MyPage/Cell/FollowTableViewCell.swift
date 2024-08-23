import UIKit
import SnapKit
import Kingfisher

class FollowTableViewCell: UITableViewCell {
    
    var cellUser: User?
    private let profileImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.widthAnchor.constraint(equalToConstant: 60).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 60).isActive = true
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 30
        
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
//        followButton.addAction(UIAction { [weak self] _ in
//            guard let self = self else { return }
//            
//        }, for: .touchUpInside)
    }
    
    func configureUserInfo() {
        guard let user = cellUser else { return }
        self.userNickName.text = user.user_nickname
        self.userEmail.text = user.user_email
        if let imgUrl = user.user_image {
            self.profileImage.kf.setImage(with: URL(string: imgUrl))
        }
        
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitleColor(.systemBlue, for: .normal)
//        switch type {
//        case .follower:
//            followButton.setTitle(eachFollow ? "Unfollow" : "Follow", for: .normal)
//            followButton.setTitleColor(eachFollow ? .systemRed : .systemBlue, for: .normal)
//        case .following:
//            followButton.setTitle("Unfollow", for: .normal)
//            followButton.setTitleColor(.systemRed, for: .normal)
//        }
    }
}
