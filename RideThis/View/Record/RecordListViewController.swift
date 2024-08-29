//
//  RecordListViewController.swift
//  RideThis
//
//  Created by 황승혜 on 8/22/24.
//

import UIKit
import SnapKit
import Combine

class RecordListViewController: RideThisViewController, UIScrollViewDelegate {
    private var scrollView: UIScrollView!
    private var contentView: UIStackView!
    private var records: [String: [RecordModel]] = [:] // 월별로 그룹화된 기록
    private var months: [String] = [] // 정렬된 월 목록
    private var loadedMonths = 0
    private let monthsToLoadPerBatch = 3
    
    private let firebaseService = FireBaseService()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "기록 목록"
        
        setupScrollView()
        setupContentView()
        fetchRecordsFromFirebase()
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.transfersVerticalScrollingToParent = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { scrol in
            scrol.edges.equalToSuperview()
        }
    }
    
    private func setupContentView() {
        contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 20
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
    }
    
    private func fetchRecordsFromFirebase() {
        guard let userId = UserService.shared.signedUser?.user_id else {
            print("사용자 ID를 찾을 수 없습니다.")
            return
        }
        
        Task {
            do {
                let fetchedRecords = await firebaseService.findRecordsBy(userId: userId)
                organizeRecords(fetchedRecords)
                await MainActor.run {
                    loadMoreMonths()
                }
            } catch {
                print("error: \(error)")
            }
        }
    }
    
    private func organizeRecords(_ fetchedRecords: [RecordModel]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        
        for record in fetchedRecords {
            guard let startTime = record.record_start_time else { continue }
            let monthKey = dateFormatter.string(from: startTime)
            if records[monthKey] == nil {
                records[monthKey] = []
            }
            records[monthKey]?.append(record)
        }
        
        // 월 및 기록 정렬
        months = records.keys.sorted(by: >)
        for month in months {
            records[month]?.sort { $0.record_start_time ?? Date() > $1.record_start_time ?? Date() }
        }
    }
    
    private func loadMoreMonths() {
        let endIndex = min(loadedMonths + monthsToLoadPerBatch, months.count)
        for i in loadedMonths..<endIndex {
            let month = months[i]
            let monthView = createMonthView(for: month, with: records[month] ?? [])
            contentView.addArrangedSubview(monthView)
        }
        loadedMonths = endIndex
    }
    
    private func createMonthView(for month: String, with records: [RecordModel]) -> UIView {
        let monthView = MonthView()
        monthView.configure(month: month, records: records)
        monthView.onRecordSelected = { [weak self] record in
            self?.showRecordDetail(record: record)
        }
        return monthView
    }
    
    private func showRecordDetail(record: RecordModel) {
        let detailVC = RecordDetailViewController()
        detailVC.record = record
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - scrollViewHeight - 100 {
            if loadedMonths < months.count {
                loadMoreMonths()
            }
        }
    }
}

