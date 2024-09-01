//
//  MonthView.swift
//  RideThis
//
//  Created by 황승혜 on 8/28/24.
//

import UIKit
import SnapKit

class MonthView: UIView {
    // 기록 레이블 선언
    private let monthLabel = RideThisLabel(fontType: .classification, fontColor: .black)
    private let titleLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black, text: "전체")
    private let avgTitleLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black, text: "평균")
    
    private let countLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black)
    private let timeLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black)
    private let distanceLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black)
    
    private let avgCountLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black)
    private let avgTimeLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black)
    private let avgDistanceLabel = RideThisLabel(fontType: .defaultSize, fontColor: .black)
    
    private let tableView = UITableView()
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
         avgCountLabel, avgTimeLabel, avgDistanceLabel, tableView].forEach { addSubview($0) }
        
        tableView.register(RecordCell.self, forCellReuseIdentifier: "RecordCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        
        setupConstraints()
    }
    
    private var tableViewHeightConstraint: Constraint?
    
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
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(28)
            make.bottom.equalToSuperview().offset(-16)
            self.tableViewHeightConstraint = make.height.equalTo(0).constraint
        }
    }
    
    func configure(month: String, records: [RecordModel]) {
        self.records = records
        
        let stats = calculateStats(records: records)
        updateLabels(month: month, stats: stats)
        
        tableView.reloadData()
        
        // 테이블 뷰 높이 동적으로 설정
        let cellHeight: CGFloat = 60
        let tableHeight = CGFloat(records.count) * cellHeight
        
        // 안전하게 제약 조건 업데이트
                if let heightConstraint = self.tableViewHeightConstraint {
                    heightConstraint.update(offset: tableHeight)
                } else {
                    tableView.snp.makeConstraints { make in
                        self.tableViewHeightConstraint = make.height.equalTo(tableHeight).constraint
                    }
                }

        // 전체 뷰의 높이 계산
        let labelsHeight: CGFloat = 150 // 대략적인 라벨들의 총 높이
        let totalHeight = labelsHeight + tableHeight + 50 // 50은 여유 공간

        self.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }

        // 레이아웃 업데이트
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func calculateStats(records: [RecordModel]) -> (total: (count: Int, time: Int, distance: Double),
                                                            avg: (count: Float, time: Int, distance: Double)) {
        let totalCount = records.count
        let totalTime = records.reduce(0) { $0 + (Double($1.record_timer.split(separator: ":")[0]) ?? 0) * 60 + (Double($1.record_timer.split(separator: ":")[1]) ?? 0) }
        let totalDistance = records.reduce(0.0) { $0 + $1.record_distance }
        
        let uniqueDays = Set(records.compactMap { Calendar.current.dateComponents([.year, .month, .day], from: $0.record_start_time ?? Date()).day }).count
        
        // 0으로 나누는 것을 방지
        if uniqueDays == 0 {
            return ((totalCount, Int(totalTime), totalDistance), (0, 0, 0))
        }
        
        let avgCount = Float(totalCount) / Float(uniqueDays)
        let avgTime = Int(totalTime / Double(uniqueDays))
        let avgDistance = totalDistance / Double(uniqueDays)
        
        return ((totalCount, Int(totalTime), totalDistance), (avgCount, avgTime, avgDistance))
    }
    
    private func updateLabels(month: String, stats: (total: (count: Int, time: Int, distance: Double),
                                                     avg: (count: Float, time: Int, distance: Double))) {
        monthLabel.text = month
        
        countLabel.text = "횟수       \(stats.total.count)"
        timeLabel.text = "시간       \(formatTime(minutes: stats.total.time))"
        distanceLabel.text = "거리       \(String(format: "%.3f Km", stats.total.distance))"
        
        avgCountLabel.text = stats.avg.count.isNaN ? "0" : String(format: "%.1f", stats.avg.count)
        avgTimeLabel.text = formatTime(minutes: stats.avg.time)
        avgDistanceLabel.text = stats.avg.distance.isNaN ? "0 Km" : String(format: "%.3f Km", stats.avg.distance)
    }
    private func formatTime(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}

extension MonthView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! RecordCell
        let record = records[indexPath.row]
        cell.configure(with: record)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRecord = records[indexPath.row]
        onRecordSelected?(selectedRecord)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
