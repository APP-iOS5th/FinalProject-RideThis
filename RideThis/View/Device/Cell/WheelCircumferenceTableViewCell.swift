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
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        containerView.addSubview(arrowImageView)
        
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
    
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}
