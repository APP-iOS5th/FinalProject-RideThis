import UIKit
import SnapKit

class DeviceTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "DeviceTableViewCell"
    
    private let deviceLabel = RideThisLabel(fontType: .defaultSize, fontColor: .label)
    private let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    
    // MARK: - Initialization
    
    /// DeviceTableViewCell의 새 인스턴스 초기화
    /// - Parameters:
    ///   - style: Cell 스타일
    ///   - reuseIdentifier: tableView Cell을 재사용하기 위해 사용하는 식별자
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        configureChevronImageView()
        addSubviews()
        setupConstraints()
    }
    
    /// 화살표 iamgeView 설정
    private func configureChevronImageView() {
        chevronImageView.tintColor = .gray
        chevronImageView.contentMode = .scaleAspectFit
    }
    
    /// subviews를 contentView에 추가
    private func addSubviews() {
        contentView.addSubview(deviceLabel)
        contentView.addSubview(chevronImageView)
    }
    
    /// SnapKit 사용하여 UI 제약 조건 설정
    private func setupConstraints() {
        deviceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().offset(10)   
            make.bottom.equalToSuperview().offset(-10)
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    
    // MARK: - Configuration
    
    /// 주어진 Device 셀을 구성
    /// - Parameter device: Cell에 표시할 Device
    func configure(with device: Device) {
        deviceLabel.text = device.name
    }
}
