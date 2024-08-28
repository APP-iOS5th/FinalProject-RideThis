//
//  StartConpetitionViewModel.swift
//  RideThis
//
//  Created by SeongKook on 8/16/24.
//

import Foundation
import UIKit
import Combine

class StartCometitionViewModel: BluetoothManagerDelegate {
    private let firebaseService = FireBaseService()
    private let service = UserService.shared
    
    var bluetoothManager: BluetoothManager!
    
    // 케이던스 정보 데이터
    var timer: String = "00:00" {
        didSet {
            timerUpdateCallback?(timer)
        }
    }
    @Published var cadence: Double = 0
    @Published var speed: Double = 0
    @Published var distance: Double = 0
    @Published var calorie: Double = 0
    var userWeight: Int
    
    var averageCadence: Double = 0
    var averageSpeed: Double = 0
    
    // 평균값 구하기
    private var cadenceValues: [Double] = []
    private var speedValues: [Double] = []
    
    // Device데이터
    var deviceInfo: RecordDeviceModel = RecordDeviceModel(device_firmware_version: "test123", device_name: "test", device_registration_status: false, device_serial_number: "13", device_wheel_circumference: 123)
    
    // 타이머 데이터
    var startTime: Date?
    var endTime: Date?
    var elapsedTime: TimeInterval = 0
    
    var goalDistance: Double
    @Published var isFinished: Bool = false
    
    var timerUpdateCallback: ((String) -> Void)?
    
    var shouldSaveNewRecord = true
    
    // MARK: 초기화
    init(startTime: Date, goalDistnace: Double, userWeight: Int) {
        self.startTime = startTime
        // self.goalDistance = goalDistnace
        self.goalDistance = 0.05
        self.userWeight = service.combineUser?.user_weight ?? 0
    }
    
    // MARK: Timer 업데이트
    func updateTimer() {
        if let startTime = startTime {
            elapsedTime = Date().timeIntervalSince(startTime)
            let minutes = Int(elapsedTime) / 60
            let seconds = Int(elapsedTime) % 60
            timer = String(format: "%02d:%02d", minutes, seconds)
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
            let userDocument = try await firebaseService.fetchUser(at: service.combineUser?.user_id ?? "", userType: false)
            
            if case .userSnapshot(let queryDocumentSnapshot) = userDocument {
                guard let doc = queryDocumentSnapshot else {
                    print("유저를 찾을 수 없습니다.")
                    return
                }
                // USERS 도큐먼트에서 Collection 찾기
                let recordsCollection = firebaseService.fetchCollection(document: doc, collectionName: "RECORDS")
                
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
            }
        } catch {
            print("경쟁 기록 처리 에러: \(error.localizedDescription)")
        }
    }
    
    // MARK: Fetch User Device Data
    func fetchDeviceData() {
        Task {
            do {
                let userDocument = try await firebaseService.fetchUser(at: service.combineUser?.user_id ?? "", userType: false)
                
                if case .userSnapshot(let queryDocumentSnapshot) = userDocument {
                    guard let doc = queryDocumentSnapshot else {
                        print("User가 존재하지 않습니다.")
                        return
                    }
                    let recordsCollection = firebaseService.fetchCollection(document: doc, collectionName: "DEVICE")
                    let deviceDocuments = try await recordsCollection.getDocuments()
                    
                    if let activeDeviceDocument = deviceDocuments.documents.first(where: { document in
                        return document["device_registration_status"] as? Bool == true
                    }) {
                        deviceInfo = RecordDeviceModel(
                            device_firmware_version: activeDeviceDocument["device_firmware_version"] as? String ?? "",
                            device_name: activeDeviceDocument["device_name"] as? String ?? "",
                            device_registration_status: activeDeviceDocument["device_registration_status"] as? Bool ?? false,
                            device_serial_number: activeDeviceDocument["device_serial_number"] as? String ?? "",
                            device_wheel_circumference: activeDeviceDocument["device_wheel_circumference"] as? Double ?? 0
                        )
                        
                        DispatchQueue.main.async {
                            self.bluetoothManager = BluetoothManager(
                                targetDeviceName: self.deviceInfo.device_name,
                                userWeight: Double(self.userWeight),
                                wheelCircumference: self.deviceInfo.device_wheel_circumference
                            )
                            self.bluetoothManager.delegate = self
                            self.bluetoothManager.connect()
                        }
                    } else {
                        print("등록된 DEVICE가 없습니다.")
                    }
                }
            } catch {
                print("FIREBASE 통신 오류: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - BluetoothManagerDelegate Methods
    func didUpdateCadence(_ cadence: Double) {
        DispatchQueue.main.async {
            self.cadence = cadence
            self.cadenceValues.append(cadence)
        }
    }
    
    func didUpdateSpeed(_ speed: Double) {
        DispatchQueue.main.async {
            self.speed = speed
            self.speedValues.append(speed)
        }
    }
    
    func didUpdateDistance(_ distance: Double) {
        DispatchQueue.main.async {
            self.distance = distance
            
            if distance >= self.goalDistance {
                self.endTime = Date()

                // 평균 계산
                let averageCadence = self.cadenceValues.isEmpty ? 0 : self.cadenceValues.reduce(0, +) / Double(self.cadenceValues.count)
                self.averageCadence = Double(averageCadence)
                let averageSpeed = self.speedValues.isEmpty ? 0 : self.speedValues.reduce(0, +) / Double(self.speedValues.count)
                self.averageSpeed = Double(averageSpeed)
                
                self.isFinished = true
                self.bluetoothManager.disConnect()
            }
        }
    }
    
    func didUpdateCalories(_ calories: Double) {
        DispatchQueue.main.async {
            self.calorie = calories
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
