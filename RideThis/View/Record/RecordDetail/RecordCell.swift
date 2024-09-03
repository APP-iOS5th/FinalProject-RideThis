import UIKit
import SnapKit

class RecordCell: UITableViewCell {
    private let dateLabel = RideThisLabel(fontType: .defaultSize, fontColor: .gray)
    private let distanceLabel = RideThisLabel(fontType: .profileFont, fontColor: .black)
    private let arrowImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 제약조건
    private func setupViews() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(arrowImageView)

        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .gray

        dateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        distanceLabel.snp.makeConstraints { make in
            make.right.equalTo(arrowImageView.snp.left).offset(-8)
            make.centerY.equalToSuperview()
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
}
