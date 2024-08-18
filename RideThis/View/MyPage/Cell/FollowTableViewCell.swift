import UIKit
import SnapKit

class FollowTableViewCell: UITableViewCell {
    
    private let profileImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.widthAnchor.constraint(equalToConstant: 60).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 60).isActive = true
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 30
        iv.image = UIImage(systemName: "sun.max")
        
        return iv
    }()
    private let userNickName = RideThisLabel(text: "매드카우")
    private let userEmail = RideThisLabel(fontColor: .recordTitleColor, text: "test@gmail.com")
    private let followButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        let btnTitle = ["Follow", "Unfollow"].randomElement()!
        btn.setTitle(btnTitle, for: .normal)
        btn.setTitleColor(btnTitle == "Follow" ? .systemBlue : .systemRed, for: .normal)
        
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
        
        userNickName.snp.makeConstraints {
            $0.top.equalTo(profileImage.snp.top).offset(8)
            $0.left.equalTo(profileImage.snp.right).offset(10)
        }
        
        userEmail.snp.makeConstraints {
            $0.bottom.equalTo(profileImage.snp.bottom).offset(-8)
            $0.left.equalTo(userNickName.snp.left)
        }
        
        followButton.snp.makeConstraints {
            $0.centerY.equalTo(contentView.snp.centerY)
            $0.right.equalTo(contentView.snp.right).offset(-10)
        }
    }
}
