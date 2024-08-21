import UIKit
import SnapKit

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
        [self.settingLabel, self.navigationButton].forEach{ self.contentView.addSubview($0) }
        
        self.settingLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.contentView.snp.centerY)
            $0.left.equalTo(self.contentView.snp.left).offset(10)
        }
        
        self.navigationButton.snp.makeConstraints {
            $0.centerY.equalTo(self.contentView.snp.centerY)
            $0.right.equalTo(self.contentView.snp.right).offset(-10)
        }
    }
    
    func configureCell(text: String) {
        self.settingLabel.text = text
    }
}
