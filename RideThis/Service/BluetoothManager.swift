//
//  BluetoothManager.swift
//  RideThis
//
//  Created by SeongKook on 8/26/24.
//

import Foundation
import CoreBluetooth

protocol BluetoothManagerDelegate: AnyObject {
    func didUpdateCadence(_ cadence: Double)
    func didUpdateSpeed(_ speed: Double)
    func didUpdateDistance(_ distance: Double)
    func didUpdateCalories(_ calories: Double)
    

}

protocol BluetoothViewDelegate: AnyObject {
    func bluetoothDidTurnOff()
}

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    weak var delegate: BluetoothManagerDelegate?
    weak var viewDelegate: BluetoothViewDelegate?
    
    private var centralManager: CBCentralManager!
    private var cadencePeripheral: CBPeripheral?
    
    private var targetDeviceName: String
    private let cadenceServiceUUID = CBUUID(string: "1816")
    private let cadenceCharacteristicUUID = CBUUID(string: "2A5B")
    
    private var lastCrankEventTime: UInt16 = 0
    private var lastCrankRevolutions: UInt16 = 0
    private var lastWheelEventTime: UInt16 = 0
    private var lastWheelRevolutions: UInt32 = 0

    private var lastValidCadence: Double = 0
    private var lastValidSpeed: Double = 0
    private var isFirstMeasurement = true
    private let validCadenceTimeout: TimeInterval = 2
    private var lastValidCadenceTime: Date?
    
    private var totalDistance: Double = 0
    private var totalCalories: Double = 0
    private var lastUpdateTime: Date?
    private var userWeight: Double
    private var wheelCircumference: Double

    // MARK: 블루투스 초기화
    init(targetDeviceName: String, userWeight: Double, wheelCircumference: Double) {
        self.targetDeviceName = targetDeviceName
        self.userWeight = userWeight
        self.wheelCircumference = wheelCircumference
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: 블루투스 장치 검색 후 연결 시도
    func connect() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    // MARK: 블루투스 장치 해제
    func disConnect() {
        if let peripheral = cadencePeripheral {
              centralManager.cancelPeripheralConnection(peripheral)
          }

    }

    
    // MARK: - CBCentralManagerDelegate Methods
    
    // MARK: 블루투스 상태 변경
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            connect()
            print("블루투스가 켜졌습니다.")
        } else {
            print("블루투스가 꺼졌거나 사용 불가능한 상태입니다.")
            viewDelegate?.bluetoothDidTurnOff()
        }
    }
    
    // MARK: 실제 연결 기기와 데이터베이스 기기와 확인
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let peripheralName = peripheral.name else {
            print("발견된 기기의 이름이 없습니다.")
            return
        }
        
        // 특정 기기 이름과 일치하는지 확인
        if peripheralName == targetDeviceName {
            centralManager.stopScan()
            cadencePeripheral = peripheral
            cadencePeripheral?.delegate = self
            centralManager.connect(peripheral, options: nil)
            print("기기 이름이 일치하여 연결 시도 중입니다.")
        }
    }
    
    // MARK: 주변 장치와의 연결이 성공했을 때 호출
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([cadenceServiceUUID])
    }
    
    // MARK: 자동으로 재연결
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connect()
    }
    
    // MARK: - CBPeripheralDelegate Methods
    // MARK: 기기 있을시 서비스 호출
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            if service.uuid == cadenceServiceUUID {
                peripheral.discoverCharacteristics([cadenceCharacteristicUUID], for: service)
                break
            }
        }
    }

    // MARK: 서비스의 특성이 발견되었을 때 호출
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == cadenceCharacteristicUUID {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }

    // MARK: 특성의 값이 업데이트되었을 때 호출
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == cadenceCharacteristicUUID {
            if let data = characteristic.value {
                parseCadenceData(data)
            }
        }
    }
    
    // MARK: - Data Parsing and Calculation
    // MARK: 장치에서 수신한 데이터를 분석하고, 케이던스, 속도 등을 계산
    private func parseCadenceData(_ data: Data) {
        guard data.count >= 5 else { return }

        let crankRevolutions = UInt16(data[1]) | (UInt16(data[2]) << 8)
        let crankEventTime = UInt16(data[3]) | (UInt16(data[4]) << 8)

        var currentCadence: Double = 0
        var currentSpeed: Double = 0

        if !isFirstMeasurement {
            let crankDiff = (crankRevolutions >= lastCrankRevolutions) ? (crankRevolutions - lastCrankRevolutions) : (crankRevolutions &+ (0xFFFF - lastCrankRevolutions))
            let crankTimeDiff = (crankEventTime >= lastCrankEventTime) ? (crankEventTime - lastCrankEventTime) : (crankEventTime &+ (0xFFFF - lastCrankEventTime))

            if crankTimeDiff > 0 {
                currentCadence = Double(crankDiff) / (Double(crankTimeDiff) / 1024.0) * 60.0
            }

            if data.count >= 11 {
                let wheelRevolutions = UInt32(data[5]) | (UInt32(data[6]) << 8) | (UInt32(data[7]) << 16) | (UInt32(data[8]) << 24)
                let wheelEventTime = UInt16(data[9]) | (UInt16(data[10]) << 8)

                let wheelDiff = (wheelRevolutions >= lastWheelRevolutions) ? (wheelRevolutions - lastWheelRevolutions) : (wheelRevolutions &+ (0xFFFFFFFF - lastWheelRevolutions))
                let wheelTimeDiff = (wheelEventTime >= lastWheelEventTime) ? (wheelEventTime - lastWheelEventTime) : (wheelEventTime &+ (0xFFFF - lastWheelEventTime))

                if wheelTimeDiff > 0 {
                    let wheelRPM = Double(wheelDiff) / (Double(wheelTimeDiff) / 1024.0) * 60.0
                    currentSpeed = wheelRPM * wheelCircumference / 60000.0
                }

                lastWheelRevolutions = wheelRevolutions
                lastWheelEventTime = wheelEventTime
            } else {
                currentSpeed = estimateSpeedFromCadence(currentCadence)
            }
        } else {
            isFirstMeasurement = false
        }

        if currentCadence > 0 {
            lastValidCadence = currentCadence
            lastValidCadenceTime = Date()
        } else {
            // 연속적으로 0이 들어올 때만 일정 시간 동안 이전 값을 유지하고, 그 후에는 0으로 설정
            if let lastCadenceTime = lastValidCadenceTime, Date().timeIntervalSince(lastCadenceTime) >= validCadenceTimeout {
                lastValidCadence = 0
                lastValidSpeed = 0
            }
        }

        if currentSpeed > 0 {
            lastValidSpeed = currentSpeed
        }

        if currentCadence == 0 {
            // 이전 값이 일정 시간 내에 0이 아닌 값으로 업데이트되지 않으면 0으로 출력
            if let lastCadenceTime = lastValidCadenceTime, Date().timeIntervalSince(lastCadenceTime) >= validCadenceTimeout {
                currentCadence = 0
                currentSpeed = 0
            } else {
                currentCadence = lastValidCadence
                currentSpeed = lastValidSpeed
            }
        }

        delegate?.didUpdateCadence(currentCadence)
        delegate?.didUpdateSpeed(currentSpeed)

        lastCrankRevolutions = crankRevolutions
        lastCrankEventTime = crankEventTime

        updateDistanceAndCalories(speed: currentSpeed)
    }

    // MARK: 케이던스로 속도 계산
    private func estimateSpeedFromCadence(_ cadence: Double) -> Double {
        let rotationsPerHour = cadence * 60
        let distancePerHour = rotationsPerHour * wheelCircumference / 1000000
        return distancePerHour
    }
    
    // MARK: 케이던스로 거리 및 칼로리 계산
    private func updateDistanceAndCalories(speed: Double) {
        let currentTime = Date()
        if let lastTime = lastUpdateTime {
            let timeInterval = currentTime.timeIntervalSince(lastTime) / 3600
            let distance = speed * timeInterval
            totalDistance += distance
            
            let met = estimateMET(speed: speed)
            let calories = met * userWeight * timeInterval
            totalCalories += calories
            
            delegate?.didUpdateDistance(totalDistance)
            delegate?.didUpdateCalories(totalCalories)
        }
        lastUpdateTime = currentTime
    }

    // MARK: 속도로 MET(운동 강도 측정)
    private func estimateMET(speed: Double) -> Double {
        if speed < 16 {
            return 4
        } else if speed < 20 {
            return 6
        } else {
            return 8
        }
    }
}

