import UIKit
import SnapKit

class WheelCircumferenceTableViewCell: UITableViewCell {
    static let identifier = "WheelCircumferenceTableViewCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(44)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(16)
            make.centerY.equalTo(containerView)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.right.equalTo(containerView).offset(-16)
            make.centerY.equalTo(containerView)
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(8)
        }
    }
    
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}
