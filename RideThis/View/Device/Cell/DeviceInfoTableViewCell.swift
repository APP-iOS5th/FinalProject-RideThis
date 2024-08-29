import UIKit
import SnapKit

class DeviceInfoTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "DeviceInfoTableViewCell"
    
    private let titleLabel = RideThisLabel(fontType: .defaultSize, fontColor: .label)
    private let valueLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black)
    
    // MARK: - Initialization
    
    /// DeviceInfoTableViewCell 새 인스턴스 초기화
    /// - Parameters:
    ///   - style: Cell 스타일
    ///   - reuseIdentifier: tableView의 여러 행을 그리기 위해 재사용될 셀 객체 식별하는 문자열
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    /// UI 설정 초기화, Subviews 추가 및 제약 조건 설정
    private func setupUI() {
        addSubviews()
        setupConstraints()
    }
    
    /// subviews를 contentView에 추가
    private func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
    }
    
    /// SnapKit을 사용하여 UI 요소의 제약 조건 설정
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { titleLabel in
            titleLabel.leading.top.equalToSuperview().offset(16)
        }
        
        valueLabel.snp.makeConstraints { valueLabel in
            valueLabel.trailing.equalToSuperview().offset(-16)
            valueLabel.top.equalTo(titleLabel.snp.bottom).offset(4)
            valueLabel.bottom.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: - Configuration
    
    /// 주어진 타이틀과 값을 사용하여 셀을 구성
    /// - Parameters:
    ///   - title: Cell에 표시할 title
    ///   - value: Cell에 표시할 value
    func configure(title: String, value: String, isSerialNumber: Bool = false) {
        titleLabel.text = title
        valueLabel.text = value

        if isSerialNumber {
            valueLabel.numberOfLines = 1
            valueLabel.adjustsFontSizeToFitWidth = true
            valueLabel.minimumScaleFactor = 0.5
            valueLabel.textAlignment = .left
            
            titleLabel.snp.remakeConstraints { titleLabel in
                titleLabel.leading.top.equalToSuperview().offset(16)
            }
            
            valueLabel.snp.remakeConstraints { valueLabel in
                valueLabel.top.equalTo(titleLabel.snp.bottom).offset(8)
                valueLabel.leading.equalTo(titleLabel).offset(16)
                valueLabel.trailing.equalToSuperview().offset(-16)
                valueLabel.bottom.equalToSuperview().offset(-16)
            }
        } else {
            valueLabel.numberOfLines = 1
            valueLabel.adjustsFontSizeToFitWidth = false
            valueLabel.minimumScaleFactor = 1.0
            valueLabel.textAlignment = .left
            
            titleLabel.snp.remakeConstraints { titleLabel in
                titleLabel.leading.equalToSuperview().offset(16)
                titleLabel.centerY.equalToSuperview()
            }
            
            valueLabel.snp.remakeConstraints { valueLabel in
                valueLabel.trailing.equalToSuperview().offset(-16)
                valueLabel.centerY.equalToSuperview()
            }
        }

        setNeedsLayout()
    }
}
