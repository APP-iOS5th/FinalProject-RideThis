import Foundation
import UIKit
import SnapKit

class AlarmTableViewCell: UITableViewCell {
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        self.contentView.addSubview(bodyLabel)
        
        bodyLabel.snp.makeConstraints {
            $0.centerX.equalTo(contentView.snp.centerX)
            $0.centerY.equalTo(contentView.snp.centerY)
        }
    }
    
    func configureCell(alarmInfo: AlarmModel) {
        self.bodyLabel.text = alarmInfo.alarm_body
    }
}
