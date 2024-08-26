import UIKit
import SnapKit

class DeviceSearchTableViewCell: UITableViewCell {
    static let identifier = "DeviceSearchTableViewCell"
    
    private let deviceLabel = RideThisLabel(fontType: .defaultSize)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(deviceLabel)
        
        deviceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        // 오른쪽 화살표 제거
        accessoryType = .none
    }
    
    func configure(with deviceName: String) {
        deviceLabel.text = deviceName
    }
}
