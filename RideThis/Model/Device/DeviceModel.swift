import Foundation

/// 디바이스 속성.
struct Device {
    let name: String
    let serialNumber: String
    let firmwareVersion: String
    let registrationStatus: String
    var wheelCircumference: String
}

/// 휠 둘레 속성.
struct WheelCircumference {
    let millimeter: String
    let tireSize: String
    let inch: String
}
