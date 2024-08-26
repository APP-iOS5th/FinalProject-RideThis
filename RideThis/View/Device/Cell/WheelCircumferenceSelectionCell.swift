import UIKit
import SnapKit

class WheelCircumferenceSelectionCell: UITableViewCell {
    private let millimeterLabel = UILabel()
    private let tireSizeLabel = UILabel()
    private let inchLabel = UILabel()
    private let radioButton = UIButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(millimeterLabel)
        contentView.addSubview(tireSizeLabel)
        contentView.addSubview(inchLabel)
        contentView.addSubview(radioButton)

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

        updateRadioButton(isSelected: false)
    }

    func configure(with wheelCircumference: WheelCircumference) {
        millimeterLabel.text = "\(wheelCircumference.millimeter)"
        tireSizeLabel.text = wheelCircumference.tireSize
        inchLabel.text = wheelCircumference.inch
    }

    override var isSelected: Bool {
        didSet {
            updateRadioButton(isSelected: isSelected)
        }
    }

    private func updateRadioButton(isSelected: Bool) {
        let imageName = isSelected ? "largecircle.fill.circle" : "circle"
        let image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
        
        radioButton.setImage(image, for: .normal)
        radioButton.tintColor = .primaryColor
    }
}
