//
//  StartConpetitionViewModel.swift
//  RideThis
//
//  Created by SeongKook on 8/16/24.
//

import Foundation
import UIKit

class StartCometitionViewModel {
    var timer: String = "00:00" {
        didSet {
            timerUpdateCallback?(timer)
        }
    }
    var cadence: Double = 121.23
    var speed: Double = 29.32
    var distance: Double = 19.2
    var calorie: Double = 1267
    
    var startTime: Date?
    var elapsedTime: TimeInterval = 0
    
    var timerUpdateCallback: ((String) -> Void)?
    
    init(startTime: Date) {
        self.startTime = startTime
    }
    
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
}
