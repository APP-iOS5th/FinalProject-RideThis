import Foundation
import Combine
import CoreBluetooth

class DeviceViewModel: NSObject, CBCentralManagerDelegate {
    // MARK: - Published Properties
    @Published private(set) var devices: [Device] = []
    @Published private(set) var searchedDevices: [Device] = []
    @Published private(set) var selectedDevice: Device?
    @Published private(set) var filteredWheelCircumferences: [WheelCircumference]
    @Published private(set) var isEmptyState: CurrentValueSubject<Bool, Never> = CurrentValueSubject(true)
    // 비회원
    @Published var unownedDevices: [Device] = []
    
    // MARK: - Properties
    let wheelCircumferences: [WheelCircumference]
    private var centralManager: CBCentralManager!
    private var cancellables = Set<AnyCancellable>()
    
    private let cadenceServiceUUID = CBUUID(string: "1816")

    // MARK: - Initialization
    
    /// 초기화 메서드
    /// 휠 둘레 목록을 생성하고, 블루투스 센트럴 매니저를 초기화
    override init() {
        self.wheelCircumferences = Self.createWheelCircumferences()
        self.filteredWheelCircumferences = self.wheelCircumferences
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    
    /// 디바이스 이름으로 디바이스 선택
    /// - Parameter name: 선택할 디바이스 이름
    func selectDevice(name: String) {
        if UserService.shared.loginStatus == .appleLogin {
            selectedDevice = devices.first { $0.name == name }
        } else {
            selectedDevice = unownedDevices.first { $0.name == name }
        }
    }
    
    /// 디바이스 이름으로 디바이스 삭제
    /// - Parameter deviceName: 삭제할 디바이스 이름
    func deleteDevice(_ deviceName: String) {
        devices.removeAll { $0.name == deviceName }
        if selectedDevice?.name == deviceName {
            selectedDevice = nil
        }
        updateEmptyState()
    }
    
    /// 새 디바이스를 목록에 추가
    /// - Parameter device: 추가할 디바이스
    func addDevice(_ device: Device) {
        guard !devices.contains(where: { $0.name == device.name }) else { return }
        devices.append(device)
    }
    
    /// 선택된 디바이스의 휠 둘레 업데이트
    /// - Parameter circumference: 새로운 휠 둘레
    func updateWheelCircumference(_ circumference: Int) {
        guard var device = selectedDevice else { return }
        device.wheelCircumference = circumference
        if let index = devices.firstIndex(where: { $0.name == device.name }) {
            devices[index] = device
        }
        selectedDevice = device
    }
    
    /// 휠 둘레 목록을 검색어에 따라 필터링
    /// - Parameter searchText: 필터링에 사용할 검색어
    func filterWheelCircumferences(with searchText: String) {
        if searchText.isEmpty {
            filteredWheelCircumferences = wheelCircumferences
        } else {
            filteredWheelCircumferences = wheelCircumferences.filter { circumference in
                String(circumference.millimeter).contains(searchText) ||
                circumference.tireSize.lowercased().contains(searchText.lowercased()) ||
                circumference.inch.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    /// 새 디바이스를 기본 설정으로 추가
    /// - Parameter device: 추가할 디바이스
    func addDeviceWithDefaultSettings(_ device: Device) async throws {
        guard let userId = UserService.shared.combineUser?.user_id else { return }
        
        // 이미 등록된 디바이스인지 확인
        let firebaseService = FireBaseService()
        if let existingDevice = try await firebaseService.getRegisteredDevice(for: userId) {
            if existingDevice.name == device.name {
                print("Device already registered")
                return
            }
        }
        
        let newDevice = Device(
            name: device.name,
            serialNumber: device.serialNumber,
            firmwareVersion: device.firmwareVersion,
            registrationStatus: true,
            wheelCircumference: 2110
        )
        
        // 기존에 등록된 디바이스가 있다면 상태 변경
        if let registeredDevice = try await firebaseService.getRegisteredDevice(for: userId) {
            var updatedDevice = registeredDevice
            updatedDevice.registrationStatus = false
            
            // Firebase 업데이트
            try await firebaseService.upsertDeviceInFirebase(updatedDevice, for: userId)
        }
        
        // 다른 모든 디바이스 상태 업데이트
        try await firebaseService.updateAllDevicesStatus(for: userId, exceptDevice: newDevice.name)
        
        // 새 디바이스 추가
        try await firebaseService.upsertDeviceInFirebase(newDevice, for: userId)
        
        // UI 업데이트는 메인 스레드에서 수행
        await MainActor.run {
            self.devices.append(newDevice)
            self.updateEmptyState()
        }
    }
    
    // MARK: 비회원시 유저디폴트 데이터저장
    func addDeviceUnkownedUser(_ device: Device) {
            let defaults = UserDefaults.standard
            let newDevice = Device(
                name: device.name,
                serialNumber: device.serialNumber,
                firmwareVersion: device.firmwareVersion,
                registrationStatus: true,
                wheelCircumference: 2110
            )
            

            if let savedDevicesData = defaults.data(forKey: "unkownedDevices"),
               let savedDevices = try? JSONDecoder().decode([Device].self, from: savedDevicesData) {
                var updatedDevices = savedDevices
                updatedDevices.append(newDevice)
                
                if let updatedData = try? JSONEncoder().encode(updatedDevices) {
                    defaults.set(updatedData, forKey: "unkownedDevices")
                }
                
                DispatchQueue.main.async {
                    self.unownedDevices = updatedDevices
                    self.updateEmptyState()
                }
            } else {
                let newDeviceArray = [newDevice]
                if let newData = try? JSONEncoder().encode(newDeviceArray) {
                    defaults.set(newData, forKey: "unkownedDevices")
                }

                DispatchQueue.main.async {
                    self.unownedDevices = newDeviceArray
                }
            }
        }
    
    func loadUnkownedDevices() {
        let defaults = UserDefaults.standard
        if let savedDevicesData = defaults.data(forKey: "unkownedDevices"),
           let savedDevices = try? JSONDecoder().decode([Device].self, from: savedDevicesData) {
            DispatchQueue.main.async {
                self.unownedDevices = savedDevices
                self.updateEmptyState()
            }
        } else {
            DispatchQueue.main.async {
                self.unownedDevices = []
                self.updateEmptyState()
            }
        }
    }
    
    func deleteDeviceUnkownedUser(_ deviceName: String) {
        let defaults = UserDefaults.standard
        if let savedDevicesData = defaults.data(forKey: "unkownedDevices"),
           var savedDevices = try? JSONDecoder().decode([Device].self, from: savedDevicesData) {
            // 장치를 찾아서 삭제
            savedDevices.removeAll { $0.name == deviceName }
            
            // 업데이트된 장치 목록을 다시 저장
            if let updatedData = try? JSONEncoder().encode(savedDevices) {
                defaults.set(updatedData, forKey: "unkownedDevices")
            }
            
            // ViewModel의 unownedDevices 배열 업데이트
            DispatchQueue.main.async {
                self.unownedDevices = savedDevices
                self.updateEmptyState()
            }
        }
    }
    
    func updateWheelCircumferenceForUnownedUser(newCircumference: Int) {
        let defaults = UserDefaults.standard

        if let savedDeviceData = defaults.data(forKey: "unkownedDevices"),
           var savedDevices = try? JSONDecoder().decode([Device].self, from: savedDeviceData) {
            
            // 첫 번째 디바이스의 wheelCircumference 업데이트
            if !savedDevices.isEmpty {
                savedDevices[0].wheelCircumference = newCircumference
                
                // selectedDevice 업데이트
                if selectedDevice?.name == savedDevices[0].name {
                    selectedDevice?.wheelCircumference = newCircumference
                }

                // 유저디폴트에 업데이트된 데이터 저장
                if let updatedData = try? JSONEncoder().encode(savedDevices) {
                    defaults.set(updatedData, forKey: "unkownedDevices")
                }

                DispatchQueue.main.async {
                    self.unownedDevices = savedDevices
                }
            }
        }
    }
    
    /// Firebase에서 등록된 디바이스 로드
    func loadRegisteredDevices() {
        guard let userId = UserService.shared.combineUser?.user_id else {
            print("사용자 ID를 찾을 수 없습니다.")
            return
        }
        
        Task {
            do {
                if let registeredDevice = try await FireBaseService().getRegisteredDevice(for: userId) {
                    DispatchQueue.main.async {
                        self.devices = [registeredDevice]
                        self.updateEmptyState()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.devices = []
                        self.updateEmptyState()
                    }
                }
            } catch {
                print("디바이스 로딩 중 오류 발생: \(error)")
                DispatchQueue.main.async {
                    self.devices = []
                    self.updateEmptyState()
                }
            }
        }
    }
    
    /// 선택된 디바이스의 휠 둘레 업데이트 및 Firebase 동기화
    /// - Parameter circumference: 새로운 휠 둘레
    func updateWheelCircumference(_ circumference: Int) async throws {
        guard var device = selectedDevice else { return }
        device.wheelCircumference = circumference
        if let index = devices.firstIndex(where: { $0.name == device.name }) {
            devices[index] = device
        }
        selectedDevice = device
        
        // Firebase 업데이트
        guard let userId = UserService.shared.combineUser?.user_id else { return }
        try await FireBaseService().updateDeviceWheelCircumference(userId: userId, deviceName: device.name, circumference: circumference)
    }
    
    /// Firebase에서 휠 둘레 업데이트
    /// - Parameter circumference: 새로운 휠 둘레
    func updateWheelCircumferenceInFirebase(_ circumference: Int) async throws {
        guard let userId = UserService.shared.combineUser?.user_id,
              let deviceName = selectedDevice?.name else { return }
        
        let firebaseService = FireBaseService()
        try await firebaseService.updateDeviceWheelCircumference(userId: userId, deviceName: deviceName, circumference: circumference)
        
        // 로컬 상태 업데이트
        try await self.updateWheelCircumference(circumference)
    }
    
    /// Firebase에서 디바이스 삭제
    /// - Parameter deviceName: 삭제할 디바이스 이름
    func deleteDeviceFromFirebase(_ deviceName: String) async throws {
        guard let userId = UserService.shared.combineUser?.user_id else { return }
        
        let firebaseService = FireBaseService()
        try await firebaseService.deleteDevice(userId: userId, deviceName: deviceName)
    }
    
    // MARK: - Bluetooth Scanning Methods
    
    /// 블루투스 장치 검색 시작
    func startDeviceSearch() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [cadenceServiceUUID], options: nil)
        }
    }
    
    /// 블루투스 장치 검색 중지
    func stopDeviceSearch() {
        centralManager.stopScan()
    }
    
    // MARK: - CBCentralManagerDelegate Methods
    
    /// 블루투스 상태 변경 시 호출되는 메서드
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startDeviceSearch()
        }
    }
    
    /// 블루투스 장치를 발견했을 때 호출되는 메서드
    ///
    /// 이 메서드는 주위에서 발견된 블루투스 장치를 처리하며, 새로운 장치가 이미 목록에 없으면
    /// 해당 장치를 `searchedDevices` 배열에 추가합니다.
    ///
    /// - Parameters:
    ///   - central: 블루투스 연결을 관리하는 CBCentralManager 인스턴스
    ///   - peripheral: 새로 발견된 주변 장치 (CBPeripheral 인스턴스)
    ///   - advertisementData: 발견된 장치의 광고 데이터 (주변 장치가 전송하는 메타 정보)
    ///   - RSSI: 신호 강도 (NSNumber 형식의 신호 세기)
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name != nil {
            let newDevice = Device(name: peripheral.name ?? "Unknown",
                                   serialNumber: peripheral.identifier.uuidString,
                                   firmwareVersion: "Unknown",
                                   registrationStatus: false,
                                   wheelCircumference: 0)
            
            if !searchedDevices.contains(where: { $0.name == newDevice.name }) {
                searchedDevices.append(newDevice)
            }
        }
    }
    
    /// 현재 기기 데이터를 기반 View의 빈 상태를 업데이트
    /// - `devices`와 `unownedDevices` 배열이 모두 비어 있으면 뷰는 빈 상태로 간주됩니다.
    /// - 현재 상태에 대한 정보를 뷰에 알리기 위해 `isEmptyState` 속성에 boolean 값(`true` 또는 `false`)을 전송합니다.
    private func updateEmptyState() {
        let isEmpty: Bool
        if UserService.shared.loginStatus == .appleLogin {
            isEmpty = self.devices.isEmpty
        } else {
            isEmpty = self.unownedDevices.isEmpty
        }
        self.isEmptyState.send(isEmpty)
    }

    // MARK: - Private Methods
    
    /// 휠 둘레 목록 생성
    /// - Returns: WheelCircumference 객체 배열 반환
    private static func createWheelCircumferences() -> [WheelCircumference] {
        return [
            WheelCircumference(millimeter: 935, tireSize: "12x1.75", inch: "11"),
            WheelCircumference(millimeter: 940, tireSize: "12x1.95", inch: "12"),
            WheelCircumference(millimeter: 1020, tireSize: "14x1.50", inch: "14"),
            WheelCircumference(millimeter: 1055, tireSize: "14x1.75", inch: "14"),
            WheelCircumference(millimeter: 1185, tireSize: "16x1.50", inch: "14"),
            WheelCircumference(millimeter: 1195, tireSize: "16x1.75", inch: "16"),
            WheelCircumference(millimeter: 1245, tireSize: "16x2.00", inch: "16"),
            WheelCircumference(millimeter: 1290, tireSize: "16x1-1/8", inch: "16"),
            WheelCircumference(millimeter: 1300, tireSize: "16x1-3/8", inch: "16"),
            WheelCircumference(millimeter: 1340, tireSize: "17x1-1/4 (369)", inch: "16"),
            WheelCircumference(millimeter: 1340, tireSize: "18x1.50", inch: "16"),
            WheelCircumference(millimeter: 1350, tireSize: "18x1.75", inch: "18"),
            WheelCircumference(millimeter: 1450, tireSize: "20x1.25", inch: "18"),
            WheelCircumference(millimeter: 1460, tireSize: "20x1.35", inch: "18"),
            WheelCircumference(millimeter: 1490, tireSize: "20x1.50", inch: "18"),
            WheelCircumference(millimeter: 1515, tireSize: "20x1.75", inch: "18"),
            WheelCircumference(millimeter: 1565, tireSize: "20x1.95", inch: "18"),
            WheelCircumference(millimeter: 1545, tireSize: "20x1-1/8", inch: "18"),
            WheelCircumference(millimeter: 1615, tireSize: "20x1-3/8", inch: "20"),
            WheelCircumference(millimeter: 1770, tireSize: "22x1-3/8", inch: "22"),
            WheelCircumference(millimeter: 1785, tireSize: "22x1-1/2", inch: "22"),
            WheelCircumference(millimeter: 1890, tireSize: "24x1.75", inch: "24"),
            WheelCircumference(millimeter: 1925, tireSize: "24x2.00", inch: "24"),
            WheelCircumference(millimeter: 1965, tireSize: "24x2.125", inch: "24"),
            WheelCircumference(millimeter: 1753, tireSize: "24x1(520)", inch: "24"),
            WheelCircumference(millimeter: 1785, tireSize: "24x3/4 Tubular", inch: "24"),
            WheelCircumference(millimeter: 1795, tireSize: "24x1-1/8", inch: "24"),
            WheelCircumference(millimeter: 1905, tireSize: "24x1-1/4", inch: "24"),
            WheelCircumference(millimeter: 1913, tireSize: "26x1(559)", inch: "24"),
            WheelCircumference(millimeter: 2170, tireSize: "26x3.00", inch: "24"),
            WheelCircumference(millimeter: 1970, tireSize: "26x1-1/8", inch: "24"),
            WheelCircumference(millimeter: 2068, tireSize: "26x1-3/8", inch: "24"),
            WheelCircumference(millimeter: 2100, tireSize: "26x1-1/2", inch: "26"),
            WheelCircumference(millimeter: 1920, tireSize: "650C Tubular 26x7/8", inch: "26"),
            WheelCircumference(millimeter: 1938, tireSize: "650x20C", inch: "26"),
            WheelCircumference(millimeter: 1944, tireSize: "650x23C", inch: "26"),
            WheelCircumference(millimeter: 1952, tireSize: "650x25C 26x1(571)", inch: "26"),
            WheelCircumference(millimeter: 2125, tireSize: "650x38A", inch: "26"),
            WheelCircumference(millimeter: 2130, tireSize: "650x38B", inch: "26"),
            WheelCircumference(millimeter: 2145, tireSize: "27x1(630)", inch: "26"),
            WheelCircumference(millimeter: 2155, tireSize: "27x1-1/8", inch: "27"),
            WheelCircumference(millimeter: 2161, tireSize: "27x1-1/4", inch: "27"),
            WheelCircumference(millimeter: 2169, tireSize: "27x1-3/8", inch: "27"),
            WheelCircumference(millimeter: 2079, tireSize: "27.5x1.50", inch: "27"),
            WheelCircumference(millimeter: 2090, tireSize: "27.5x1.95", inch: "27"),
            WheelCircumference(millimeter: 2148, tireSize: "27.5x2.1", inch: "27.5"),
            WheelCircumference(millimeter: 2182, tireSize: "27.5x2.25", inch: "27.5"),
            WheelCircumference(millimeter: 2070, tireSize: "700x18C", inch: "27.5"),
            WheelCircumference(millimeter: 2080, tireSize: "700x19C", inch: "27.5"),
            WheelCircumference(millimeter: 2086, tireSize: "700x20C", inch: "27.5"),
            WheelCircumference(millimeter: 2096, tireSize: "700x23C", inch: "27.5"),
            WheelCircumference(millimeter: 2110, tireSize: "700x25C", inch: "27.5"),
            WheelCircumference(millimeter: 2136, tireSize: "700x28C", inch: "27.5"),
            WheelCircumference(millimeter: 2146, tireSize: "700x30C", inch: "27.5"),
            WheelCircumference(millimeter: 2155, tireSize: "700x32C", inch: "27.5"),
            WheelCircumference(millimeter: 2130, tireSize: "700C Tubular", inch: "700c"),
            WheelCircumference(millimeter: 2168, tireSize: "700x35C", inch: "700c"),
            WheelCircumference(millimeter: 2180, tireSize: "700x38C", inch: "700c"),
        ]
    }
}
