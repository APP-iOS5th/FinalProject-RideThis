import UIKit
import SnapKit

class DailyRecordView: UIView {
    private let containerView = UIView()
    private let dateLabel = RideThisLabel(fontType: .defaultSize, fontColor: .gray)
    private let distanceLabel = RideThisLabel(fontType: .profileFont, fontColor: .black)
    private let iconImageView = UIImageView()
    private let arrowImageView = UIImageView()
    
    var onTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(dateLabel)
        containerView.addSubview(distanceLabel)
        containerView.addSubview(arrowImageView)
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        
        // TODO: - 프로필 이미지로 수정
        iconImageView.image = UIImage(named: "bokdonge")
        iconImageView.contentMode = .scaleAspectFit
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .gray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        containerView.addGestureRecognizer(tapGesture)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(80)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40) // 아이콘 크기를 40x40으로 증가
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(16) // 간격을 조금 더 늘림
            make.top.equalToSuperview().offset(20)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.left.equalTo(dateLabel)
            make.top.equalTo(dateLabel.snp.bottom).offset(6)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    func configure(with record: RecordModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateLabel.text = dateFormatter.string(from: record.record_start_time ?? Date())
        distanceLabel.text = "\(String(format: "%.3f", record.record_distance)) Km"
    }
    
    @objc private func viewTapped() {
        onTap?()
    }
}
