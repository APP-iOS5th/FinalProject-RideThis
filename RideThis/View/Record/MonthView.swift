//
//  MonthView.swift
//  RideThis
//
//  Created by 황승혜 on 8/28/24.
//

import UIKit
import SnapKit

class MonthView: UIView {
    private let monthLabel = UILabel()
    private let countLabel = UILabel()
    private let timeLabel = UILabel()
    private let distanceLabel = UILabel()
    private let avgDistanceLabel = UILabel()
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
        //backgroundColor = .systemBackground
        layer.cornerRadius = 10
        layer.masksToBounds = true

        addSubview(monthLabel)
        addSubview(countLabel)
        addSubview(timeLabel)
        addSubview(distanceLabel)
        addSubview(avgDistanceLabel)
        addSubview(tableView)

        monthLabel.font = UIFont.boldSystemFont(ofSize: 18)
        countLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        distanceLabel.font = UIFont.systemFont(ofSize: 14)
        avgDistanceLabel.font = UIFont.systemFont(ofSize: 14)

        tableView.register(RecordCell.self, forCellReuseIdentifier: "RecordCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
//        tableView.separatorStyle = .none

        setupConstraints()
    }

    private var tableViewHeightConstraint: Constraint?
    
    private func setupConstraints() {
        monthLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(16)
        }

        countLabel.snp.makeConstraints { make in
            make.top.equalTo(monthLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(16)
        }

        distanceLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(16)
        }

        avgDistanceLabel.snp.makeConstraints { make in
            make.top.equalTo(distanceLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(avgDistanceLabel.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
            make.bottom.equalToSuperview()
            self.tableViewHeightConstraint = make.height.equalTo(0).constraint
        }
    }

    func configure(month: String, records: [RecordModel]) {
        self.records = records
        
        monthLabel.text = month
        countLabel.text = "횟수: \(records.count)"
        
        let totalTime = records.reduce(0) { $0 + (Double($1.record_timer.split(separator: ":")[0]) ?? 0) * 60 + (Double($1.record_timer.split(separator: ":")[1]) ?? 0) }
        let hours = Int(totalTime / 3600)
        let minutes = Int((totalTime.truncatingRemainder(dividingBy: 3600)) / 60)
        timeLabel.text = "시간: \(hours)h \(minutes)m"
        
        let totalDistance = records.reduce(0.0) { $0 + $1.record_distance }
        distanceLabel.text = "거리: \(String(format: "%.3f", totalDistance)) Km"
        
        let avgDistance = totalDistance / Double(records.count)
        avgDistanceLabel.text = "평균 거리: \(String(format: "%.3f", avgDistance)) Km"
        
        tableView.reloadData()
        
        // 테이블 뷰 높이 동적으로 설정
        self.tableViewHeightConstraint?.update(offset: CGFloat(records.count) * 70)
        
        // 레이아웃 업데이트
        layoutIfNeeded()
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
