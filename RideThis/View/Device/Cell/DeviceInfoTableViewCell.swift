import UIKit
import SnapKit

class DeviceInfoTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "DeviceInfoTableViewCell"
    
    private let titleLabel = RideThisLabel(fontType: .defaultSize, fontColor: .label)
    private let valueLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black)
    
    
    // MARK: - Initialization
    
    /// DeviceInfoTableViewCell 새 인스턴스 초기화.
    /// - Parameters:
    ///   - style: Cell 스타일.
    ///   - reuseIdentifier: tableView의 여러 행을 그리기 위해 재사용될 셀 객체 식별하는 문자열.
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
    }
    
    /// subviews를 contentView에 추가.
    private func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
    }
    
    /// SnapKit을 사용하여 UI 요소의 제약 조건 설정.
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    
    // MARK: - Configuration
    
    /// 주어진 타이틀과 값을 사용하여 셀을 구성.
    /// - Parameters:
    ///   - title: Cell에 표시할 title.
    ///   - value: Cell에 표시할 value.
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}
