//
//  BluetoothModel.swift
//  RideThis
//
//  Created by SeongKook on 8/26/24.
//

import Foundation

struct BluetoothModel: Codable {
    let device_firmware_version: String
    let device_name: String
    let device_registration_status: Bool
    let device_serial_number: String
    let device_wheel_circumference: Double
    
}
