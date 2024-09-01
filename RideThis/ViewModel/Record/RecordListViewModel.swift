//
//  RecordListViewModel.swift
//  RideThis
//
//  Created by 황승혜 on 9/2/24.
//

import Foundation
import Combine

class RecordListViewModel {
    private let firebaseService = FireBaseService()
    @Published var records: [String: [RecordModel]] = [:] // 월별로 그룹화된 기록
    @Published var months: [String] = [] // 정렬된 월 목록
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchRecordsFromFirebase() {
        guard let userId = UserService.shared.signedUser?.user_id else {
            print("사용자 ID를 찾을 수 없습니다.")
            return
        }
        
        Task {
            do {
                let fetchedRecords = await firebaseService.findRecordsBy(userId: userId)
                organizeRecords(fetchedRecords)
            }
        }
    }
    
    private func organizeRecords(_ fetchedRecords: [RecordModel]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월"
        
        var newRecords: [String: [RecordModel]] = [:]
        
        for record in fetchedRecords {
            guard let startTime = record.record_start_time else { continue }
            let monthKey = dateFormatter.string(from: startTime)
            if newRecords[monthKey] == nil {
                newRecords[monthKey] = []
            }
            newRecords[monthKey]?.append(record)
        }
        
        // 월 및 기록 정렬
        months = newRecords.keys.sorted(by: >)
        for month in months {
            newRecords[month]?.sort { $0.record_start_time ?? Date() > $1.record_start_time ?? Date() }
        }
        
        records = newRecords
    }
    
    func getRecordsForMonth(_ month: String) -> [RecordModel] {
        return records[month] ?? []
    }
}
