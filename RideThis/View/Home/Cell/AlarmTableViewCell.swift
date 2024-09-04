import Foundation
import UIKit
import SnapKit
import Kingfisher

class AlarmTableViewCell: UITableViewCell {
    
    private let container: UIView = {
        let uv = UIView()
        uv.backgroundColor = .white
        uv.layer.cornerRadius = 8
        uv.layer.shadowColor = UIColor.black.cgColor
        uv.layer.shadowOpacity = 0.1
        uv.layer.shadowOffset = CGSize(width: 0, height: 1)
        uv.layer.shadowRadius = 2
        
        return uv
    }()
    
    private lazy var alarmImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.height.equalTo(40)
        }
        img.image = UIImage(named: "bokdonge")
        img.clipsToBounds = true
        img.layer.cornerRadius = 20
        
        return img
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .primaryColor
        
        return label
    }()
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        
        return label
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialCell()
    }
    
    func initialCell() {
        self.backgroundColor = .primaryBackgroundColor
        contentView.addSubview(container)
        
        container.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).offset(15)
            $0.left.equalTo(contentView.snp.left).offset(25)
            $0.right.equalTo(contentView.snp.right).offset(-25)
            $0.bottom.equalTo(contentView.snp.bottom)
        }
        [alarmImage, categoryLabel, bodyLabel, dateLabel].forEach{ container.addSubview($0) }
        
        alarmImage.snp.makeConstraints {
            $0.centerY.equalTo(container.snp.centerY)
            $0.left.equalTo(container.snp.left).offset(10)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(alarmImage.snp.top)
            $0.left.equalTo(alarmImage.snp.right).offset(10)
        }
        
        bodyLabel.snp.makeConstraints {
//            $0.centerY.equalTo(container.snp.centerY).offset(5)
            $0.left.equalTo(categoryLabel.snp.left)
            $0.bottom.equalTo(alarmImage.snp.bottom).offset(-5)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.top)
            $0.right.equalTo(container.snp.right).offset(-10)
        }
    }
    
    func configureCell(alarmInfo: AlarmModel) {
        self.categoryLabel.text = alarmInfo.alarm_category
        self.bodyLabel.text = alarmInfo.alarm_body
        self.dateLabel.text = alarmInfo.alarm_date.convertedDate
        
        if let imgStr = alarmInfo.alarm_image {
            DispatchQueue.main.async {
                self.alarmImage.kf.setImage(with: URL(string: imgStr))
            }
        }
//        if alarmInfo.alarm_status {
//            self.container.backgroundColor = .white
//        } else {
//            self.container.backgroundColor = .primaryBackgroundColor
//        }
    }
}
