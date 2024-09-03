import UIKit
import SnapKit

class WheelCircumferenceSelectionCell: UITableViewCell {
    // MARK: - Properties
    private let millimeterLabel = UILabel()
    private let tireSizeLabel = UILabel()
    private let inchLabel = UILabel()
    private let radioButton = UIButton()
    
    
    // MARK: - Initialization
    
    /// WheelCircumferenceSelectionCell 새 인스턴스 초기화
    /// - Parameters:
    ///   - style: Cell 스타일
    ///   - reuseIdentifier: tableView에서 Cell을 재사용하기 위해 사용하는 식별자
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
        updateRadioButton(isSelected: false)
    }
    
    /// subViews를 contentView에 추가
    private func addSubviews() {
        contentView.addSubview(millimeterLabel)
        contentView.addSubview(tireSizeLabel)
        contentView.addSubview(inchLabel)
        contentView.addSubview(radioButton)
    }
    
    /// SnapKit 사용하여 UI 제약 조건 설정
    private func setupConstraints() {
        millimeterLabel.snp.makeConstraints { millimeterLabel in
            millimeterLabel.left.equalToSuperview().offset(16)
            millimeterLabel.centerY.equalToSuperview()
            millimeterLabel.width.equalTo(90)
        }
        
        tireSizeLabel.snp.makeConstraints { tireSizeLabel in
            tireSizeLabel.left.equalTo(millimeterLabel.snp.right).offset(16)
            tireSizeLabel.centerY.equalToSuperview()
            tireSizeLabel.width.equalTo(100)
        }
        
        inchLabel.snp.makeConstraints { inchLabel in
            inchLabel.left.equalTo(tireSizeLabel.snp.right).offset(16)
            inchLabel.centerY.equalToSuperview()
            inchLabel.width.equalTo(50)
        }
        
        radioButton.snp.makeConstraints { radioButton in
            radioButton.right.equalToSuperview().offset(-16)
            radioButton.centerY.equalToSuperview()
            radioButton.width.height.equalTo(24)
        }
    }
    
    
    // MARK: - Configuration
    
    /// 주어진 휠 둘레 데이터를 사용하여 Cell 구성
    /// - Parameter wheelCircumference: Cell 표시할 휠 둘레 데이터
    func configure(with wheelCircumference: WheelCircumference) {
        millimeterLabel.text = "\(wheelCircumference.millimeter)mm"
        tireSizeLabel.text = wheelCircumference.tireSize
        inchLabel.text = wheelCircumference.inch
    }
    
    /// Cell 선택 상태를 업데이트
    override var isSelected: Bool {
        didSet {
            updateRadioButton(isSelected: isSelected)
        }
    }
    
    /// radioButton image를 업데이트
    /// - Parameter isSelected: Cell 선택되었는지 여부
    private func updateRadioButton(isSelected: Bool) {
        let imageName = isSelected ? "largecircle.fill.circle" : "circle"
        let image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
        
        radioButton.setImage(image, for: .normal)
        radioButton.tintColor = .primaryColor
    }
}
