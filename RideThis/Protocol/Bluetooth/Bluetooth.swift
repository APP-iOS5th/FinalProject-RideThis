//
//  Bluetooth.swift
//  RideThis
//
//  Created by SeongKook on 8/30/24.
//

import Foundation


protocol BluetoothManagerDelegate: AnyObject {
    func didUpdateCadence(_ cadence: Double)
    func didUpdateSpeed(_ speed: Double)
    func didUpdateDistance(_ distance: Double)
    func didUpdateCalories(_ calories: Double)
    func bluetoothDidConnect()

}

protocol BluetoothViewDelegate: AnyObject {
    func bluetoothDidTurnOff()
}
