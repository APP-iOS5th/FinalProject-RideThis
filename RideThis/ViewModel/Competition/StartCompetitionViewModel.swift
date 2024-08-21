//
//  StartConpetitionViewModel.swift
//  RideThis
//
//  Created by SeongKook on 8/16/24.
//

import Foundation
import UIKit
import Combine

class StartCometitionViewModel {
    private let firebaseService = FireBaseService()
    
    var timer: String = "00:00" {
        didSet {
            timerUpdateCallback?(timer)
        }
    }
    var cadence: Double = 38.13
    var speed: Double = 29.32
    var distance: Double = 39.2
    var calorie: Double = 1592.12
    
    var startTime: Date?
    var endTime: Date?
    var elapsedTime: TimeInterval = 0
    
    var goalDistance: Double
    @Published var isFinished: Bool = false
    
    var timerUpdateCallback: ((String) -> Void)?
    
    var shouldSaveNewRecord = true
    
    init(startTime: Date, goalDistnace: Double) {
        self.startTime = startTime
        self.goalDistance = goalDistnace
    }
    
    func updateTimer() {
        if let startTime = startTime {
            elapsedTime = Date().timeIntervalSince(startTime)
            let minutes = Int(elapsedTime) / 60
            let seconds = Int(elapsedTime) % 60
            timer = String(format: "%02d:%02d", minutes, seconds)
            
            // 뷰 전환 타이머 초로 테스트
            if Double(seconds) >= goalDistance {
                endTime = Date()
                isFinished = true
            }
        }
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    // MARK: Update Firebase
    func competitionUpdateData() async {
        do {
            // 유저아이디가 존재하는지 확인
            guard let userDocument = try await firebaseService.fetchUser(at: "test") else {
                print("유저를 찾을 수 없습니다.")
                return
            }
            
            // USERS 도큐먼트에서 Collection 찾기
            let recordsCollection = firebaseService.fetchCollection(document: userDocument, collectionName: "RECORDS")
            
            // competitionStatus = true, goalDistance가 일치하는 데이터 찾기
            let recordsSnapshot = try await firebaseService.fetchCompetitionSnapshot(collection: recordsCollection, competitionStatus: true, goalDistance: goalDistance)
            
            // 기존 기록을 비교하고, 더 빠른 기록만 남김
            for document in recordsSnapshot.documents {
                let existingTimer = document.data()["record_timer"] as? String ?? "00:00"
                
                if compareTimers(existingTimer, timer) {
                    try await firebaseService.fetchDeleteDocument(at: nil, withId: nil, collection: recordsCollection, document: document)
                    
                } else {
                    shouldSaveNewRecord = false
                }
            }
            
            // 새로운 기록을 저장할지 여부 결정
            if shouldSaveNewRecord {
                try await firebaseService.fetchRecord(collection: recordsCollection, timer: timer, cadence: cadence, speed: speed, distance: distance, calorie: calorie, startTime: startTime ?? Date(), endTime: endTime ?? Date(), date: startTime ?? Date(), competetionStatus: true, tagetDistance: goalDistance)
                print("경쟁 기록 추가")
            } else {
                print("새로운 기록이 저장되지 않았습니다. 기존 기록이 더 빠릅니다.")
            }
        } catch {
            print("경쟁 기록 처리 에러: \(error.localizedDescription)")
        }
    }
    
    // MARK: 타이머 시간 비교
    func compareTimers(_ timer1: String, _ timer2: String) -> Bool {
        let components1 = timer1.split(separator: ":").compactMap { Int($0) }
        let components2 = timer2.split(separator: ":").compactMap { Int($0) }
        
        guard components1.count == 2, components2.count == 2 else {
            return false
        }
        
        let totalSeconds1 = components1[0] * 60 + components1[1]
        let totalSeconds2 = components2[0] * 60 + components2[1]
        
        // 새로운 타이머가 더 빠르거나 같으면 true 반환
        return totalSeconds2 <= totalSeconds1
    }
}
