//
//  CountViewModle.swift
//  RideThis
//
//  Created by SeongKook on 8/14/24.
//

import Foundation
import Combine

class CountViewModel {
    @Published var currentCount: Int = 5
    
    private var countdown: Timer?
    
    // MARK: Start Countdown
    func startCountdown() {
        countdown = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    // MARK: Countdown Start
    @objc private func updateCountdown() {
        if currentCount > 0 {
            currentCount -= 1
        } else {
            countdown?.invalidate()
            countdown = nil
        }
    }
    
    deinit {
        countdown?.invalidate()
    }
}
