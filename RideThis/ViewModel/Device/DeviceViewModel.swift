import Foundation
import Combine

class DeviceViewModel {
    // MARK: - Published Properties
    @Published private(set) var devices: [Device] = []
    @Published private(set) var searchedDevices: [Device] = []
    @Published private(set) var selectedDevice: Device?
    let wheelCircumferences: [WheelCircumference]
    
    // MARK: - Initialization
    init() {
        self.wheelCircumferences = Self.createWheelCircumferences() // 휠 둘레 목록 생성.
        self.searchedDevices = Self.createMockSearchedDevices() // 더미 데이터 검색된 디바이스 목록 생성.
    }
    
    
    // MARK: - Public Methods
    
    /// 디바이스 이름으로 디바이스 선택.
    /// - Parameter name: 선택할 디바이스 이름.
    func selectDevice(name: String) {
        selectedDevice = devices.first { $0.name == name }
    }
    
    /// 디바이스 이름으로 디바이스를 삭제.
    /// - Parameter deviceName: 삭제할 디바이스 이름.
    func deleteDevice(_ deviceName: String) {
        devices.removeAll { $0.name == deviceName }
        if selectedDevice?.name == deviceName {
            selectedDevice = nil
        }
    }
    
    /// 새 디바이스를 목록에 추가.
    /// - Parameter device: 추가할 디바이스.
    func addDevice(_ device: Device) {
        guard !devices.contains(where: { $0.name == device.name }) else { return }
        devices.append(device)
    }
    
    /// 선택된 디바이스의 휠 둘레 업데이트.
    /// - Parameter circumference: 새로운 휠 둘레.
    func updateWheelCircumference(_ circumference: String) {
        guard var device = selectedDevice else { return }
        device.wheelCircumference = circumference
        if let index = devices.firstIndex(where: { $0.name == device.name }) {
            devices[index] = device
        }
        selectedDevice = device
    }
    
    
    // MARK: - Private Methods
    
    /// 검색된 디바이스 목록 생성.
    /// - Returns: Device 객체 배열 반환.
    private static func createMockSearchedDevices() -> [Device] {
        return [
            Device(name: "30832-1", serialNumber: "Serial 30832-1", firmwareVersion: "1.112", registrationStatus: "완료", wheelCircumference: "2110mm"),
            Device(name: "30832-2", serialNumber: "Serial 0832-2", firmwareVersion: "2.521", registrationStatus: "미완료", wheelCircumference: "1195mm"),
            Device(name: "30832-3", serialNumber: "Serial 0832-3", firmwareVersion: "3.164", registrationStatus: "미완료", wheelCircumference: "1920mm")
        ]
    }
    
    /// 휠 둘레 목록 생성.
    /// - Returns: WheelCircumference 객체 배열 반환.
    private static func createWheelCircumferences() -> [WheelCircumference] {
        return [
            WheelCircumference(millimeter: "935mm", tireSize: "12x1.75", inch: "11"),
            WheelCircumference(millimeter: "940mm", tireSize: "12x1.95", inch: "12"),
            WheelCircumference(millimeter: "1020mm", tireSize: "14x1.50", inch: "14"),
            WheelCircumference(millimeter: "1055mm", tireSize: "14x1.75", inch: "14"),
            WheelCircumference(millimeter: "1185mm", tireSize: "16x1.50", inch: "14"),
            WheelCircumference(millimeter: "1195mm", tireSize: "16x1.75", inch: "16"),
            WheelCircumference(millimeter: "1245mm", tireSize: "16x2.00", inch: "16"),
            WheelCircumference(millimeter: "1290mm", tireSize: "16x1-1/8", inch: "16"),
            WheelCircumference(millimeter: "1300mm", tireSize: "16x1-3/8", inch: "16"),
            WheelCircumference(millimeter: "1340mm", tireSize: "17x1-1/4 (369)", inch: "16"),
            WheelCircumference(millimeter: "1340mm", tireSize: "18x1.50", inch: "16"),
            WheelCircumference(millimeter: "1350mm", tireSize: "18x1.75", inch: "18"),
            WheelCircumference(millimeter: "1450mm", tireSize: "20x1.25", inch: "18"),
            WheelCircumference(millimeter: "1460mm", tireSize: "20x1.35", inch: "18"),
            WheelCircumference(millimeter: "1490mm", tireSize: "20x1.50", inch: "18"),
            WheelCircumference(millimeter: "1515mm", tireSize: "20x1.75", inch: "18"),
            WheelCircumference(millimeter: "1565mm", tireSize: "20x1.95", inch: "18"),
            WheelCircumference(millimeter: "1545mm", tireSize: "20x1-1/8", inch: "18"),
            WheelCircumference(millimeter: "1615mm", tireSize: "20x1-3/8", inch: "20"),
            WheelCircumference(millimeter: "1770mm", tireSize: "22x1-3/8", inch: "22"),
            WheelCircumference(millimeter: "1785mm", tireSize: "22x1-1/2", inch: "22"),
            WheelCircumference(millimeter: "1890mm", tireSize: "24x1.75", inch: "24"),
            WheelCircumference(millimeter: "1925mm", tireSize: "24x2.00", inch: "24"),
            WheelCircumference(millimeter: "1965mm", tireSize: "24x2.125", inch: "24"),
            WheelCircumference(millimeter: "1753mm", tireSize: "24x1(520)", inch: "24"),
            WheelCircumference(millimeter: "1785mm", tireSize: "24x3/4 Tubular", inch: "24"),
            WheelCircumference(millimeter: "1795mm", tireSize: "24x1-1/8", inch: "24"),
            WheelCircumference(millimeter: "1905mm", tireSize: "24x1-1/4", inch: "24"),
            WheelCircumference(millimeter: "1913mm", tireSize: "26x1(559)", inch: "24"),
            WheelCircumference(millimeter: "2170mm", tireSize: "26x3.00", inch: "24"),
            WheelCircumference(millimeter: "1970mm", tireSize: "26x1-1/8", inch: "24"),
            WheelCircumference(millimeter: "2068mm", tireSize: "26x1-3/8", inch: "24"),
            WheelCircumference(millimeter: "2100mm", tireSize: "26x1-1/2", inch: "26"),
            WheelCircumference(millimeter: "1920mm", tireSize: "650C Tubular 26x7/8", inch: "26"),
            WheelCircumference(millimeter: "1938mm", tireSize: "650x20C", inch: "26"),
            WheelCircumference(millimeter: "1944mm", tireSize: "650x23C", inch: "26"),
            WheelCircumference(millimeter: "1952mm", tireSize: "650x25C 26x1(571)", inch: "26"),
            WheelCircumference(millimeter: "2125mm", tireSize: "650x38A", inch: "26"),
            WheelCircumference(millimeter: "2130mm", tireSize: "650x38B", inch: "26"),
            WheelCircumference(millimeter: "2145mm", tireSize: "27x1(630)", inch: "26"),
            WheelCircumference(millimeter: "2155mm", tireSize: "27x1-1/8", inch: "27"),
            WheelCircumference(millimeter: "2161mm", tireSize: "27x1-1/4", inch: "27"),
            WheelCircumference(millimeter: "2169mm", tireSize: "27x1-3/8", inch: "27"),
            WheelCircumference(millimeter: "2079mm", tireSize: "27.5x1.50", inch: "27"),
            WheelCircumference(millimeter: "2090mm", tireSize: "27.5x1.95", inch: "27"),
            WheelCircumference(millimeter: "2148mm", tireSize: "27.5x2.1", inch: "27.5"),
            WheelCircumference(millimeter: "2182mm", tireSize: "27.5x2.25", inch: "27.5"),
            WheelCircumference(millimeter: "2070mm", tireSize: "700x18C", inch: "27.5"),
            WheelCircumference(millimeter: "2080mm", tireSize: "700x19C", inch: "27.5"),
            WheelCircumference(millimeter: "2086mm", tireSize: "700x20C", inch: "27.5"),
            WheelCircumference(millimeter: "2096mm", tireSize: "700x23C", inch: "27.5"),
            WheelCircumference(millimeter: "2110mm", tireSize: "700x25C", inch: "27.5"),
            WheelCircumference(millimeter: "2136mm", tireSize: "700x28C", inch: "27.5"),
            WheelCircumference(millimeter: "2146mm", tireSize: "700x30C", inch: "27.5"),
            WheelCircumference(millimeter: "2155mm", tireSize: "700x32C", inch: "27.5"),
            WheelCircumference(millimeter: "2130mm", tireSize: "700C Tubular", inch: "700c"),
            WheelCircumference(millimeter: "2168mm", tireSize: "700x35C", inch: "700c"),
            WheelCircumference(millimeter: "2180mm", tireSize: "700x38C", inch: "700c"),
        ]
    }
}
