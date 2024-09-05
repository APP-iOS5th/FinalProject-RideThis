import UIKit
import SnapKit

class MonthView: UIView {
    // 기록 레이블 선언
    private let monthLabel = RideThisLabel(fontType: .classification, fontColor: .black)
    private let titleLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black, text: "전체")
    private let avgTitleLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black, text: "평균")
    
    private let countLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black)
    private let timeLabel = RideThisLabel(fontType: .defaultSize, fontColor: .systemGreen)
    private let distanceLabel = RideThisLabel(fontType: .defaultSize, fontColor: .systemRed)
    
    private let avgCountLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black)
    private let avgTimeLabel = RideThisLabel(fontType: .defaultSize, fontColor: .systemGreen)
    private let avgDistanceLabel = RideThisLabel(fontType: .defaultSize, fontColor: .systemRed)
    
    private let recordsStackView = UIStackView()
    private var records: [RecordModel] = []
    var onRecordSelected: ((RecordModel) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        [monthLabel, titleLabel, avgTitleLabel, countLabel, timeLabel, distanceLabel,
         avgCountLabel, avgTimeLabel, avgDistanceLabel, recordsStackView].forEach { addSubview($0) }
        
        recordsStackView.axis = .vertical
        recordsStackView.spacing = 15
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        monthLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(monthLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(80)
        }
        
        avgTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel)
            make.left.equalTo(snp.centerX).offset(26)
        }
        
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(19)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(19)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(19)
        }
        
        avgCountLabel.snp.makeConstraints { make in
            make.top.equalTo(countLabel)
            make.left.equalTo(avgTitleLabel)
        }
        
        avgTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel)
            make.left.equalTo(avgTitleLabel)
        }
        
        avgDistanceLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel)
            make.left.equalTo(avgTitleLabel)
        }
        
        recordsStackView.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(19)
            make.bottom.equalToSuperview().offset(-19)
        }
    }
    
    func configure(month: String, records: [RecordModel]) {
        self.records = records
        
        let stats = calculateStats(records: records)
        updateLabels(month: month, stats: stats)
        
        recordsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for record in records {
            let dailyRecordView = DailyRecordView()
            dailyRecordView.configure(with: record)
            dailyRecordView.onTap = { [weak self] in
                self?.onRecordSelected?(record)
            }
            recordsStackView.addArrangedSubview(dailyRecordView)
        }
        
        // 전체 뷰의 높이 계산 및 업데이트
        let labelsHeight: CGFloat = 150 // 대략적인 라벨들의 총 높이
        let recordsHeight = CGFloat(records.count) * 80 // DailyRecordView의 높이 증가
        let totalHeight = labelsHeight + recordsHeight + CGFloat(records.count - 1) * 15 + 36 // 스택 뷰의 spacing과 상하 여백 포함
        
        self.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func calculateStats(records: [RecordModel]) -> (total: (count: Int, time: Int, distance: Double),
                                                            avg: (count: Float, time: Int, distance: Double)) {
        let totalCount = records.count
        let times = records.map{ ($0.record_start_time, $0.record_end_time) }.map{ self.getRecordTimeDiff(endDate: $0.1!, startDate: $0.0!) }.reduce(0, +)
//        let totalTime = records.reduce(0) { $0 + (Double($1.record_timer.split(separator: ":")[0]) ?? 0) * 60 + (Double($1.record_timer.split(separator: ":")[1]) ?? 0) }
        let totalDistance = records.reduce(0.0) { $0 + $1.record_distance }
        
        let uniqueDays = Set(records.compactMap { Calendar.current.dateComponents([.year, .month, .day], from: $0.record_start_time ?? Date()).day }).count
        
        // 0으로 나누는 것을 방지
        if uniqueDays == 0 {
            return ((totalCount, Int(times), totalDistance), (0, 0, 0))
        }
        print(uniqueDays)
        let avgCount = Float(totalCount) / Float(uniqueDays)
        let avgTime = Int(Double(times) / Double(uniqueDays))
        let avgDistance = totalDistance / Double(uniqueDays)
        
        return ((totalCount, Int(times), totalDistance), (avgCount, avgTime, avgDistance))
    }
    
    func getRecordTimeDiff(endDate: Date, startDate: Date) -> Int {
        let timeInterval = endDate.timeIntervalSince(startDate)
        return Int(timeInterval)
    }
    
    private func updateLabels(month: String, stats: (total: (count: Int, time: Int, distance: Double),
                                                     avg: (count: Float, time: Int, distance: Double))) {
        monthLabel.text = month
        
        countLabel.text = "횟수       \(stats.total.count)"
//        timeLabel.text = "시간       \(formatTime(minutes: stats.total.time))"
        timeLabel.text = "시간       \(stats.total.time.secondsToRecordTimeForRecords)"
        distanceLabel.text = "거리       \(String(format: "%.3f Km", stats.total.distance))"
        
        avgCountLabel.text = stats.avg.count.isNaN ? "0" : String(format: "%.1f", stats.avg.count)
//        avgTimeLabel.text = formatTime(minutes: stats.avg.time)
        avgTimeLabel.text = stats.avg.time.secondsToRecordTimeForRecords
        avgDistanceLabel.text = stats.avg.distance.isNaN ? "0 Km" : String(format: "%.3f Km", stats.avg.distance)
    }
    private func formatTime(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}
