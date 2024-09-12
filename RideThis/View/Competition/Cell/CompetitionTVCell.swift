import UIKit

class CompetitionTVCell: UITableViewCell {
    
    private let numberImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "medal.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let userNameLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black, text: "user")
    private let timeLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black)
    
    // MARK: 초기화
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: SetupUI
    private func setupUI() {
        self.contentView.addSubview(numberImage)
        self.contentView.addSubview(userNameLabel)
        self.contentView.addSubview(timeLabel)
        setupLayout()
    }
    
    // MARK: Layout
    private func setupLayout() {
        numberImage.snp.makeConstraints { image in
            image.top.equalTo(self.contentView.snp.top).offset(10)
            image.left.equalTo(self.contentView.snp.left).offset(20)
            image.bottom.equalTo(self.contentView.snp.bottom).offset(-10)
            image.width.equalTo(20)
        }
        
        userNameLabel.snp.makeConstraints { name in
            name.top.equalTo(self.contentView.snp.top).offset(10)
            name.left.equalTo(numberImage.snp.right).offset(6)
            name.bottom.equalTo(self.contentView.snp.bottom).offset(-10)
        }
        
        timeLabel.snp.makeConstraints { time in
            time.top.equalTo(self.contentView.snp.top).offset(10)
            time.right.equalTo(self.contentView.snp.right).offset(-20)
            time.bottom.equalTo(self.contentView.snp.bottom).offset(-10)
        }
    }
    
    // MARK: Configure
    func configure(item: RecordModel, number: Int, viewModel: CompetitionViewModel) {
        let ranking = number + 1
        
        userNameLabel.text = "\(ranking). \(item.user_nickname)"
        if item.user_nickname == viewModel.nickName {
            userNameLabel.text = "\(ranking). \(item.user_nickname) (나)"
            userNameLabel.textColor = UIColor.primaryColor
        } else {
            userNameLabel.textColor = .black
        }
        timeLabel.text = item.record_timer
        timeLabel.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .bold)
        
        // 인덱스에 따른 색상 및 이미지 표시
        switch ranking {
        case 1:
            timeLabel.textColor = UIColor(red: 251/255, green: 72/255, blue: 0/255, alpha: 1)
            numberImage.isHidden = false
            numberImage.tintColor = UIColor(red: 251/255, green: 72/255, blue: 0/255, alpha: 1)
        case 2:
            timeLabel.textColor = UIColor(red: 153/255, green: 153/255, blue: 100/255, alpha: 1)
            numberImage.isHidden = false
            numberImage.tintColor = UIColor(red: 153/255, green: 153/255, blue: 100/255, alpha: 1)
        case 3:
            timeLabel.textColor = UIColor(red: 215/255, green: 110/255, blue: 51/255, alpha: 1)
            numberImage.isHidden = false
            numberImage.tintColor = UIColor(red: 215/255, green: 110/255, blue: 51/255, alpha: 1)
        default:
            timeLabel.textColor = .black
            numberImage.isHidden = true
        }
    }
}
