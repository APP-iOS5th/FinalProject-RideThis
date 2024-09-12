import UIKit
import SnapKit

class WheelCircumferenceTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "WheelCircumferenceTableViewCell"
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    
    // MARK: - Initialization
    
    /// WheelCircumferenceTableViewCell 새 인스턴스 초기화
    /// - Parameters:
    ///   - style: Cell 스타일
    ///   - reuseIdentifier: tableView에서 Cell을 재사용하기 위한 식별자
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        configureSubviews()
        addSubviews()
        setupConstraints()
    }
    
    /// subviews 속성 설정
    private func configureSubviews() {
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textAlignment = .right
        arrowImageView.tintColor = .gray
        arrowImageView.contentMode = .scaleAspectFit
    }
    
    /// subviews를 contentView에 추가
    private func addSubviews() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        containerView.addSubview(arrowImageView)
    }
    
    /// SnapKit 사용하여 UI 제약 조건 설정
    private func setupConstraints() {
        containerView.snp.makeConstraints { containerView in
            containerView.edges.equalToSuperview()
            containerView.height.greaterThanOrEqualTo(44)
        }
        
        titleLabel.snp.makeConstraints { titleLabel in
            titleLabel.left.equalTo(containerView).offset(16)
            titleLabel.centerY.equalTo(containerView)
        }
        
        valueLabel.snp.makeConstraints { valueLabel in
            valueLabel.right.equalTo(arrowImageView.snp.left).offset(-8)
            valueLabel.centerY.equalTo(containerView)
        }
        
        arrowImageView.snp.makeConstraints { arrowImageView in
            arrowImageView.right.equalTo(containerView).offset(-16)
            arrowImageView.centerY.equalTo(containerView)
            arrowImageView.width.height.equalTo(20)
        }
    }
    
    
    // MARK: - Configuration
    
    /// 주어진 Title 값으로 Cell 구성
    /// - Parameters:
    ///   - title: Cell에 표시할 title
    ///   - value: Cell에 표시할 value
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}
