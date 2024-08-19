import UIKit
import SnapKit

class SettingTableToggleViewCell: UITableViewCell {
    private let settingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        
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
}
