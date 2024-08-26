import Foundation
import Combine

class DeviceViewModel {
    @Published private(set) var devices: [Device] = []
    
    @Published private(set) var searchedDevices: [Device] = [
        Device(name: "30832-1", serialNumber: "Serial 30832-1", firmwareVersion: "1.112", registrationStatus: "완료", wheelCircumference: "2.07m"),
        Device(name: "30832-2", serialNumber: "Serial 0832-2", firmwareVersion: "2.521", registrationStatus: "미완료", wheelCircumference: "4.08m"),
        Device(name: "30832-3", serialNumber: "Serial 0832-3", firmwareVersion: "3.164", registrationStatus: "미완료", wheelCircumference: "6.09m")
    ]
    
    @Published private(set) var selectedDevice: Device?
    
    func selectDevice(name: String) {
        selectedDevice = devices.first { $0.name == name }
    }
    
    func deleteDevice(_ deviceName: String) {
        devices.removeAll { $0.name == deviceName }
        if selectedDevice?.name == deviceName {
            selectedDevice = nil
        }
    }
    
    func addDevice(_ device: Device) {
        guard !devices.contains(where: { $0.name == device.name }) else { return }
        devices.append(device)
    }
}
