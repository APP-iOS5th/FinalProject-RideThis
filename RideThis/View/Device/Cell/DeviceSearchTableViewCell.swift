import UIKit
import SnapKit

class DeviceSearchTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "DeviceSearchTableViewCell"
    
    private let deviceLabel = RideThisLabel(fontType: .defaultSize)
    
    
    // MARK: - Initialization
    
    /// DeviceSearchTableViewCell 새 인스턴스 초기화.
    /// - Parameters:
    ///   - style: Cell 스타일.
    ///   - reuseIdentifier: tableView Cell을 재사용하기 위해 사용하는 식별자.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        addSubviews()
        setupConstraints()
        configureCell()
    }
    
    /// subViews를 content에 추가.
    private func addSubviews() {
        contentView.addSubview(deviceLabel)
    }
    
    /// SnapKit 사용하여 UI 제약 조건 설정.
    private func setupConstraints() {
        deviceLabel.snp.makeConstraints { deviceLabel in
            deviceLabel.leading.equalToSuperview().offset(16)
            deviceLabel.centerY.equalToSuperview()
        }
    }
    
    /// 추가적인 Cell 속성 설정.
    private func configureCell() {
        accessoryType = .none
    }
    
    
    // MARK: - Configuration
    
    /// 주어진 Device 이름으로 Cell 구성.
    /// - Parameter deviceName: Cell에 표시할 Device 이름.
    func configure(with deviceName: String) {
        deviceLabel.text = deviceName
    }
}
