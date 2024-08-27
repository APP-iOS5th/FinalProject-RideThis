//
//  RecordListViewController.swift
//  RideThis
//
//  Created by 황승혜 on 8/22/24.
//

import UIKit
import SnapKit

class RecordListViewController: RideThisViewController {
    var records = RecordModel.sampleRecords
    var groupedData = [(String, [RecordModel])]()
//    var records = [RecordModel]()
//    private let userService = UserService.shared
//    private let firebaseService = FireBaseService()
    
    private let customTitleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "기록 목록")
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupScrollView()
        
        // fetchUserRecords()
        
        groupedData = groupRecordsByMonth(records)
        
        for (month, monthRecords) in groupedData {
            let monthView = createMonthView(for: month, with: monthRecords)
            stackView.addArrangedSubview(monthView)
        }
    }
    
    // 특정 유저의 기록을 가져오는 메서드
//    func fetchUserRecords() {
//        Task {
//            do {
//                guard let userId = userService.signedUser?.user_id else {
//                    print("Unknown user id")
//                    return
//                }
//                
//                guard let userSnapshot = try await firebaseService.fetchUser(at: userId) else {
//                    print("Unknown user data")
//                    return
//                }
//                
//                let userRecords = try await firebaseService.fetchAllRecordsForUsers([userSnapshot])
//                
//                // records 배열에 유저의 기록 저장하고 뷰 업데이트
//                DispatchQueue.main.async {
//                    self.records = userRecords
//                    self.updateViewWithRecords()
//                }
//            } catch {
//                print("기록을 가져오는 중 오류 발생: \(error)")
//            }
//        }
//    }
    
    // 뷰 업데이트 메서드
//    func updateViewWithRecords() {
//        let groupedData = groupRecordsByMonth(records)
//        
//        for (month, monthRecords) in groupedData {
//            let monthView = createMonthView(for: month, with: monthRecords)
//            stackView.addArrangedSubview(monthView)
//        }
//    }
    
    func setupScrollView() {
        scrollView.transfersVerticalScrollingToParent = false
        view.addSubview(scrollView)
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { scrol in
            scrol.top.equalToSuperview()
            scrol.trailing.equalToSuperview()
            scrol.leading.equalToSuperview()
            scrol.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { stak in
            stak.top.equalTo(scrollView.snp.top).offset(16)
            stak.leading.equalTo(scrollView.snp.leading).offset(16)
            stak.trailing.equalTo(scrollView.snp.trailing).offset(-16)
            stak.bottom.equalTo(scrollView.snp.bottom).offset(-16)
            stak.width.equalTo(view.snp.width).offset(-32)
        }
    }
    
    func groupRecordsByMonth(_ records: [RecordModel]) -> [(String, [RecordModel])] {
        var groupedRecords = [String: [RecordModel]]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        
        for record in records {
            let dateKey = record.record_start_time != nil ? dateFormatter.string(from: record.record_start_time!) : "임의의 월"
            
            if groupedRecords[dateKey] == nil {
                groupedRecords[dateKey] = []
            }
            groupedRecords[dateKey]?.append(record)
        }
        
        let sortedGroupedRecords = groupedRecords.sorted { $0.key > $1.key }
        return sortedGroupedRecords.map { ($0.key, $0.value.sorted { $0.record_start_time ?? Date() > $1.record_start_time ?? Date() }) }
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        let leftBarButtonItem = UIBarButtonItem(customView: customTitleLabel)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func createMonthView(for month: String, with records: [RecordModel]) -> UIView {
        let containerView = UIView()
        
        let totalWorkouts = Double(records.count)
        let totalDuration = records.reduce(0) { $0 + parseTimeToSeconds($1.record_timer) }
//        let averageDuration = Double(totalDuration) / totalWorkouts
        
        let totalDistance = records.reduce(0) { $0 + $1.record_distance }
        let averageDistance = totalDistance / totalWorkouts
        
        // 월 타이틀 레이블
        let monthLabel = RideThisLabel(fontType: .recordInfoTitle, fontColor: .black, text: month)
        
        // 총 운동 횟수 레이블
        let totalWorkoutsLabel = RideThisLabel(fontType: .recordTitle, fontColor: .black, text: "횟수: \(Int(totalWorkouts))")
        
        // 총 운동 시간 레이블
        let totalDurationLabel = RideThisLabel(fontType: .recordTitle, fontColor: .black, text: "시간: \(formatSecondsToTime(totalDuration))")
        
        // 총 운동 거리 레이블
        let totalDistanceLabel = RideThisLabel(fontType: .recordTitle, fontColor: .black, text: "거리: \(String(format: "%.3f", totalDistance)) Km")
        
        // 평균 운동 거리 레이블
        let avgDistanceLabel = RideThisLabel(fontType: .recordTitle, fontColor: .black, text: "평균 거리: \(String(format: "%.3f", averageDistance)) Km")
        
        // 테이블뷰 설정
        let recordTableView = UITableView()
        recordTableView.dataSource = self
        recordTableView.delegate = self
        recordTableView.register(RecordTableViewCell.self, forCellReuseIdentifier: "RecordCell")
        recordTableView.isScrollEnabled = false  // 테이블뷰의 스크롤을 비활성화하고 스크롤뷰가 스크롤되도록 함
//        recordTableView.tag = records.hashValue // 테이블 뷰의 태그를 설정하여 구분
//        recordTableView.separatorStyle = .none
        
        // 레이아웃 구성
        let monthStack = UIStackView(arrangedSubviews: [monthLabel, totalWorkoutsLabel, totalDurationLabel, totalDistanceLabel, avgDistanceLabel, recordTableView])
        monthStack.axis = .vertical
        monthStack.spacing = 8
        
        containerView.addSubview(monthStack)
        
        monthStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        // 테이블뷰 높이 설정 (셀 개수에 따라 동적 조정)
        recordTableView.snp.makeConstraints { make in
            make.height.equalTo(CGFloat(records.count) * 65).priority(.low)  // 각 셀의 높이를 70으로 가정
            make.height.greaterThanOrEqualTo(1).priority(.high)
        }
        
        return containerView
    }
    
    func parseTimeToSeconds(_ time: String) -> Int {
        let components = time.split(separator: ":").map { Int($0) ?? 0 }
        let minutes = components[0]
        let seconds = components[1]
        return minutes * 60 + seconds
    }
    
    func formatSecondsToTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return String(format: "%02dh %02dm", hours, minutes)
    }
}

// MARK: - UITableView DataSource & Delegate
extension RecordListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
//        if let parentView = tableView.superview?.superview as? UIStackView,
//           let containerIndex = parentView.arrangedSubviews.firstIndex(of: tableView.superview!) {
//            return groupedData[containerIndex].1.count  // groupedData 사용
//        }
//        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! RecordTableViewCell
        let record = records[indexPath.row]
        
//        if let parentView = tableView.superview?.superview as? UIStackView,
//           let containerIndex = parentView.arrangedSubviews.firstIndex(of: tableView.superview!) {
//            let recordsForMonth = groupedData[containerIndex].1  // groupedData 사용
//            let record = recordsForMonth[indexPath.row]
//            
//            cell.configure(with: record)
//        }
//        
        cell.configure(with: record)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = records[indexPath.row]
        
        let detailVC = RecordDetailViewController()
        detailVC.record = record
        
        navigationController?.pushViewController(detailVC, animated: true)
        
        print("Detail for \(record)")
    }
}

// MARK: - RecordTableViewCell
class RecordTableViewCell: UITableViewCell {
    
    let dateLabel = UILabel()
    let distanceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stack = UIStackView(arrangedSubviews: [dateLabel, distanceLabel])
        stack.axis = .vertical
        stack.spacing = 4
        
        contentView.addSubview(stack)
        
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with record: RecordModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        if let date = record.record_start_time {
            dateLabel.text = dateFormatter.string(from: date)
        } else {
            dateLabel.text = "Unknown Date"
        }
        
        distanceLabel.text = "\(String(format: "%.3f", record.record_distance)) Km"
    }
}

#Preview {
    UINavigationController(rootViewController: RecordListViewController())
}